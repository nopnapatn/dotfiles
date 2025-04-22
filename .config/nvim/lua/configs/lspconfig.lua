require("nvchad.configs.lspconfig").defaults()

local servers = {
  "html",
  "cssls",
  "tsserver",
  "jsonls",
  "tailwindcss",
  "gopls",
  "dartls",
}

vim.lsp.enable(servers)
