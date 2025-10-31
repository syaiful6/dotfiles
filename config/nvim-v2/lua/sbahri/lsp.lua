-- LSP utilities and configuration
local M = {}

function M.on_attach(client, bufnr)
  local function map(keys, func, desc)
    vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc, silent = true })
  end

  local hs_tiny_ca, tiny_ca = pcall(require, "hs-tiny.code_action")
  if hs_tiny_ca then
    map("<D-.>", tiny_ca.code_action, "Code Action")
  end

  -- Basic LSP keymaps
  map("K", vim.lsp.buf.hover, "Hover Documentation")
  map("gd", vim.lsp.buf.definition, "Goto Definition")
  map("gD", vim.lsp.buf.declaration, "Goto Declaration")
  map("gi", vim.lsp.buf.implementation, "Goto Implementation")
  map("gr", vim.lsp.buf.references, "References")
  map("<leader>rn", vim.lsp.buf.rename, "Rename")
  map("<leader>ca", vim.lsp.buf.code_action, "Code Action")
  map("<leader>f", function()
    vim.lsp.buf.format({ async = true })
  end, "Format")
  map("<C-k>", vim.lsp.buf.signature_help, "Signature Help")

  -- Toggle inlay hints if supported
  if client.server_capabilities.inlayHintProvider then
    map("<leader>th", function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
    end, "Toggle Inlay Hints")
  end

  -- OCaml-specific keymaps
  if client.name == "ocamllsp" then
    map("gn", ":OCaml phrase next<cr>", "Jump to next phrase")
    map("gN", ":OCaml phrase prev<cr>", "Jump to previous phrase")
    map("gh", ":OCaml jump-hole next<cr>", "Jump to next hole")
    map("gH", ":OCaml jump-hole prev<cr>", "Jump to previous hole")
    map("<leader>m", ":OCaml jump<cr>", "Merlin jumps")
    map("<leader>ce", ":OCaml expand-ppx<CR>", "Expand PPX")
    map("<leader>sp", ":OCaml type-search<CR>", "Type search")

    vim.keymap.set({ "n", "x" }, "<leader>cv", ":OCaml select-ast<CR>", {
      remap = true,
      silent = true,
      desc = "Select AST node",
      buffer = bufnr,
    })
  end

  -- Rust-specific keymaps
  if client.name == "rust-analyzer" or client.name == "rust_analyzer" then
    map("K", function()
      vim.cmd.RustLsp({ "hover", "actions" })
    end, "Hover with actions")
    map("<leader>cR", function()
      vim.cmd.RustLsp("codeAction")
    end, "Code action")
    map("<leader>dr", function()
      vim.cmd.RustLsp("debuggables")
    end, "Rust Debuggables")
  end
end

function M.capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()

  -- Add blink.cmp capabilities if available
  local has_blink, blink = pcall(require, "blink.cmp")
  if has_blink then
    capabilities = vim.tbl_deep_extend("force", capabilities, blink.get_lsp_capabilities({}, false))
  end

  -- Disable workspace/didChangeWatchedFiles due to neovim bug
  capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false

  return capabilities
end

return M
