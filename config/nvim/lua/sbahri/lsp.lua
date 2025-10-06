local M = {}

function M.on_attach(client, bufnr)
  local lsp_keymap = function(keys, func, desc)
    if desc then
      desc = "LSP: " .. desc
    end
    vim.keymap.set("n", keys, func, { remap = true, buffer = bufnr, desc = desc, silent = true })
  end
  lsp_keymap("<D-.>", require("tiny-code-action").code_action, "Code Action")
  lsp_keymap("K", function()
    if client.name == "rust-analyzer" then
      vim.cmd.RustLsp({ "hover", "actions" })
    else
      vim.lsp.buf.hover()
    end
  end, "Hover Documentation")
  lsp_keymap("<D-r>", vim.lsp.buf.rename, "Go to Definition")
  lsp_keymap("<D-u>", vim.lsp.buf.signature_help, "Signature Help")
  lsp_keymap("<leader>ch", function()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(), { bufnr })
  end, "Lsp toggle inlay [h]ints")

  lsp_keymap("gD", Snacks.picker.lsp_definitions, "Goto Declaration")
  lsp_keymap("gi", Snacks.picker.lsp_implementations, "Goto Implementation")
  lsp_keymap("gr", Snacks.picker.lsp_references, "References")
  lsp_keymap("<D-l>", Snacks.picker.lsp_workspace_symbols, "Search workspace symbols")

  if client.name == "ocamllsp" then
    lsp_keymap("gn", ":OCaml phrase next<cr>", "Jumps to next phrase")
    lsp_keymap("gN", ":OCaml phrase prev<cr>", "Jumps to previous phrase")
    lsp_keymap("ghn", ":OCaml jump-hole next<cr>", "Jumps to next hole")
    lsp_keymap("ghN", ":OCaml jump-hole prev<cr>", "Jumps to previous hole")
    lsp_keymap("<leader>m", ":OCaml jump<cr>", "Merlin jumps")
    lsp_keymap("gml", ":OCaml jump let<cr>", "Jumps to the beginning of the let")
    lsp_keymap("gmf", ":OCaml jump fun<cr>", "Jumps to the beginning of the function")
    lsp_keymap("gmm", ":OCaml jump module<cr>", "Jumps to the beginning of the current module")
    lsp_keymap("gms", ":OCaml jump match<cr>", "Jumps to the beginning of the current match")
    lsp_keymap("gmb", ":OCaml jump match-next-case<cr>", "Jumps to the beginning of the next case in the current match")
    lsp_keymap(
      "gmc",
      ":OCaml jump match-prev-case<cr>",
      "Jumps to the beginning of the previous case in the current match"
    )
  end
end

-- extend capabilities to support nvim-cmp, broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend("force", capabilities, require("blink.cmp").get_lsp_capabilities({}, false))
-- disable for now, bug: https://github.com/neovim/neovim/issues/23291
capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false

M.capabilties = capabilities

return M
