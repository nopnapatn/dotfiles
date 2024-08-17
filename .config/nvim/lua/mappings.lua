require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("i", "jk", "<ESC>")
map("n", ";", ":", { desc = "CMD enter command mode" })

-- increment/ decrement
map("n", "+", "<C-a>")
map("n", "-", "<C-x>")

-- select all
map("n", "<C-a>", "gg<S-v>G")

-- new tabedit
map("n", "te", ":tabedit")
map("n", "tn", ":tabnext<Return>")
map("n", "tb", ":tabprev<Return>")

-- split window
map("n", "ss", ":split<Return>")
map("n", "sv", ":vsplit<Return>")

-- move window
map("n", "sh", "<C-w>h")
map("n", "sk", "<C-w>k")
map("n", "sj", "<C-w>j")
map("n", "sl", "<C-w>l")

-- quit window
map("n", "sx", ":q<Return>")

-- resize window
map("n", "<C-w><left>", "<C-w><")
map("n", "<C-w><right>", "<C-w>>")
map("n", "<C-w><up>", "<C-w>+")
map("n", "<C-w><down>", "<C-w>-")

-- close buffer
map("n", "tx", function()
  require("nvchad.tabufline").close_buffer()
end, { desc = "buffer close" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- GitHub Copilot mappings
map("i", "<Tab>", function()
  vim.fn.feedkeys(vim.fn["copilot#Accept"](), "")
end, { replace_keycodes = true, nowait = true, silent = true, expr = true, noremap = true })

