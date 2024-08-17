require "nvchad.options"

-- add yours here!
local opt = vim.opt

opt.wrap = false

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!

-- set up neovie
if vim.g.neovide then
    vim.g.neovide_transparency = 0.9
    vim.g.neovide_scale_factor = 1.0
end
