-- Language-specific completion processors registry
-- Similar to Zed's extension system where each language can provide
-- custom processing for completion items

local M = {}

-- Registry of language processors
-- Each processor can define:
-- - label_for_completion(item): Transform completion item label
-- - process_item(item): Full item transformation
M.processors = {}

--- Register a language processor
---@param filetype string|string[] The filetype(s) this processor handles
---@param processor table The processor with label_for_completion and/or process_item functions
function M.register(filetype, processor)
  if type(filetype) == "string" then
    M.processors[filetype] = processor
  elseif type(filetype) == "table" then
    for _, ft in ipairs(filetype) do
      M.processors[ft] = processor
    end
  end
end

--- Get processor for a given filetype
---@param filetype string
---@return table|nil
function M.get_processor(filetype)
  return M.processors[filetype]
end

--- Process a completion item using the appropriate language processor
---@param item table The LSP completion item
---@param filetype string The current buffer filetype
---@return table The processed completion item
function M.process_item(item, filetype)
  local processor = M.get_processor(filetype)
  if not processor then
    return item
  end

  local processed_item = vim.deepcopy(item)

  -- Apply label_for_completion if available
  if processor.label_for_completion then
    local label_result = processor.label_for_completion(processed_item)
    if label_result then
      -- Support both string return and table return (for more control)
      if type(label_result) == "string" then
        processed_item.label = label_result
      elseif type(label_result) == "table" then
        -- Allow processor to return a table with label, labelDetails, etc.
        processed_item = vim.tbl_deep_extend("force", processed_item, label_result)
      end
    end
  end

  -- Apply full item processor if available
  if processor.process_item then
    processed_item = processor.process_item(processed_item) or processed_item
  end

  return processed_item
end

--- Process a list of completion items
---@param items table[] List of LSP completion items
---@param filetype string The current buffer filetype
---@return table[] The processed completion items
function M.process_items(items, filetype)
  if not items or #items == 0 then
    return items
  end

  local processor = M.get_processor(filetype)
  if not processor then
    return items
  end

  local processed = {}
  for i, item in ipairs(items) do
    processed[i] = M.process_item(item, filetype)
  end

  return processed
end

return M
