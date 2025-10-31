-- OCaml-specific completion processor
-- Based on Zed's OCaml extension: https://github.com/zed-extensions/ocaml/blob/main/src/ocaml.rs
-- Creates synthetic OCaml code to display completion items more clearly

local M = {}

local OPERATOR_CHARS = { "~", "!", "?", "%", "<", ":", ".", "$", "&", "*", "+", "-", "/", "=", ">", "@", "^" }

--- Check if a string contains any operator characters
---@param str string
---@return boolean
local function contains_operator_char(str)
  for _, char in ipairs(OPERATOR_CHARS) do
    if str:find(char, 1, true) then
      return true
    end
  end
  return false
end

--- Check if a string starts with any of the given prefixes
---@param str string
---@param prefixes string[]
---@return boolean
local function starts_with_any(str, prefixes)
  for _, prefix in ipairs(prefixes) do
    if vim.startswith(str, prefix) then
      return true
    end
  end
  return false
end

--- Parse OCaml type to count arguments in a product type (tuples)
---@param type_str string
---@return number
local function count_tuple_arguments(type_str)
  -- Count * separators at the top level (not inside parens/brackets)
  local depth = 0
  local count = 1 -- Start with 1 since n asterisks means n+1 elements

  for i = 1, #type_str do
    local char = type_str:sub(i, i)
    if char == "(" or char == "[" or char == "{" then
      depth = depth + 1
    elseif char == ")" or char == "]" or char == "}" then
      depth = depth - 1
    elseif char == "*" and depth == 0 then
      -- Top-level * means tuple separator
      count = count + 1
    end
  end

  return count
end

--- Generate placeholder text for constructor arguments
---@param argument string|nil The argument type string
---@return string|nil snippet The snippet text with placeholders
local function generate_constructor_snippet(name, argument)
  if not argument then
    return name
  end

  -- Count the number of arguments
  local arg_count = count_tuple_arguments(argument)

  -- Generate placeholders: Constructor (${1:_}, ${2:_}, ${3:_})
  local placeholders = {}
  for i = 1, arg_count do
    table.insert(placeholders, "${" .. i .. ":_}")
  end

  return name .. " (" .. table.concat(placeholders, ", ") .. ")"
end

--- Check if a type is a record type by looking for '{' and '}'
---@param type_str string
---@return boolean
local function is_record_type(type_str)
  return type_str:find("{", 1, true) ~= nil and type_str:find("}", 1, true) ~= nil
end

--- Parse record type and extract field names
---@param type_str string
---@return string[]|nil fields List of field names
local function parse_record_fields(type_str)
  -- Match content between { and }
  local record_content = type_str:match("{%s*(.-)%s*}")
  if not record_content then
    return nil
  end

  local fields = {}
  -- Split by semicolon or newline
  for field_def in record_content:gmatch("[^;]+") do
    -- Extract field name (before the colon)
    local field_name = field_def:match("^%s*([%w_]+)%s*:")
    if field_name then
      table.insert(fields, field_name)
    end
  end

  return #fields > 0 and fields or nil
end

--- Generate record literal with placeholders
---@param fields string[] List of field names
---@return string snippet The snippet text
local function generate_record_snippet(fields)
  local placeholder_idx = 1
  local field_snippets = {}

  for _, field in ipairs(fields) do
    table.insert(field_snippets, field .. " = ${" .. placeholder_idx .. ":_}")
    placeholder_idx = placeholder_idx + 1
  end

  return "{ " .. table.concat(field_snippets, "; ") .. " }"
end

--- Process OCaml completion label similar to Zed's label_for_completion
--- This modifies the insertion text to include placeholders for arguments
---@param item table The LSP completion item
---@return table The transformed item fields
function M.label_for_completion(item)
  local name = item.label
  local detail = item.detail
  local kind = item.kind

  -- Clean up detail (remove newlines)
  if detail then
    detail = detail:gsub("\n", " ")
  end

  -- Constructor or EnumMember - add argument placeholders
  if (kind == 4 or kind == 20) and detail then -- Constructor = 4, EnumMember = 20
    local argument, return_t = detail:match("^(.-)%->%s*(.+)$")
    if argument then
      argument = vim.trim(argument)
      return_t = vim.trim(return_t)
    else
      argument = nil
      return_t = detail
    end

    -- If constructor has arguments, generate snippet with placeholders
    if argument then
      local insert_text = generate_constructor_snippet(name, argument)

      return {
        insertText = insert_text,
        insertTextFormat = 2, -- Snippet format
        filterText = name, -- Keep original name for filtering
      }
    end
  end

  -- Type/Struct/Class/Interface - check if it's a record type for labeled argument completion
  if (kind == 22 or kind == 7 or kind == 5 or kind == 8) and detail then -- Struct = 22, Class = 7, Field = 5, Interface = 8
    -- Check if the detail shows a record type
    if is_record_type(detail) then
      local fields = parse_record_fields(detail)
      if fields then
        local insert_text = generate_record_snippet(fields)

        return {
          insertText = insert_text,
          insertTextFormat = 2, -- Snippet format
          filterText = name, -- Keep original name for filtering
        }
      end
    end
  end

  -- Field (including labeled arguments like ~x or ?x)
  if kind == 5 and detail then -- Field = 5
    local is_labeled = starts_with_any(name, { "~", "?" })

    if is_labeled then
      -- For optional/labeled args, insert as ~name:value or ?name:value
      local insert_text = name .. ":${1:_}"

      return {
        insertText = insert_text,
        insertTextFormat = 2, -- Snippet format
        filterText = name, -- Keep original name for filtering
      }
    end
  end

  -- Default: no transformation
  return nil
end

--- Full item processor for additional OCaml-specific transformations
---@param item table The LSP completion item
---@return table The processed item
function M.process_item(item)
  -- Apply label transformation
  local label_result = M.label_for_completion(item)
  if label_result then
    -- Merge the changes
    item = vim.tbl_deep_extend("force", item, label_result)

    -- IMPORTANT: Also update textEdit.newText if it exists
    -- This is necessary because blink.cmp uses textEdit.newText if present,
    -- falling back to insertText only if textEdit doesn't exist
    if item.textEdit and label_result.insertText then
      item.textEdit.newText = label_result.insertText
    end
  end

  return item
end

return M
