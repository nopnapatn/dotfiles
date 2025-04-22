require "nvchad.options"

-- add yours here!

local o = vim.o

o.cursorlineopt ='both' -- to enable cursorline!
o.wrap = false

-- set up neovie
if vim.g.neovide then
    vim.g.neovide_transparency = 0.9
    vim.g.neovide_scale_factor = 1.0
end
