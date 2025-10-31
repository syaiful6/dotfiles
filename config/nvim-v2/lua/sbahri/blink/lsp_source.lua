-- Custom LSP source for blink.cmp that supports per-language processing
-- This wraps the default LSP source and applies language-specific transformations

local language_processors = require("sbahri.blink.language_processors")
local default_lsp = require("blink.cmp.sources.lsp")

--- @class blink.cmp.CustomLSPSource : blink.cmp.LSPSource
local lsp = {}

--- Create a new instance of the custom LSP source
---@param opts? table
---@return table
function lsp.new(opts)
  -- Create the default LSP source instance
  local instance = default_lsp.new(opts)

  -- Store the original methods
  local original_get_completions = instance.get_completions
  local original_get_trigger_characters = instance.get_trigger_characters

  -- Override get_completions to process items with language processors
  instance.get_completions = function(self, context, callback)
    return original_get_completions(self, context, function(response)
      if not response or not response.items then
        callback(response)
        return
      end

      -- Get current buffer filetype
      local bufnr = context.bufnr or vim.api.nvim_get_current_buf()
      local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })

      -- Process items with language-specific processors
      local processed_items = language_processors.process_items(response.items, filetype)

      -- Return processed response
      callback({
        is_incomplete_forward = response.is_incomplete_forward,
        is_incomplete_backward = response.is_incomplete_backward,
        items = processed_items,
      })
    end)
  end

  -- Override get_trigger_characters to add language-specific triggers
  instance.get_trigger_characters = function(self)
    local triggers = original_get_trigger_characters(self)

    -- Add additional triggers for OCaml files
    local bufnr = vim.api.nvim_get_current_buf()
    local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })

    if filetype == "ocaml" or filetype == "ocaml.interface" or filetype == "ocaml.menhir" or filetype == "ocamllex" then
      triggers = vim.deepcopy(triggers)
      -- Add : for labeled arguments
      -- Add ( for function calls/constructors
      -- Add { for records
      -- Add | for pattern matching
      table.insert(triggers, ":")
      table.insert(triggers, "=")
      table.insert(triggers, "(")
      table.insert(triggers, "{")
      table.insert(triggers, "|")
      table.insert(triggers, " ")
    end

    return triggers
  end

  return instance
end

return lsp
