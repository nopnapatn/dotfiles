return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  { require("plugins.telescope") },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },
  {
  	"williamboman/mason.nvim",
  	opts = {
  		ensure_installed = {
  			"lua-language-server", "stylua",
  			"html-lsp", "css-lsp" , "prettier",
        "eslint-lsp", "prettierd", "gopls",
        "typescript-language-server",
        "tailwindcss-language-server",
  		},
  	},
  },

  {
  	"nvim-treesitter/nvim-treesitter",
  	opts = {
  		ensure_installed = {
  			"vim", "lua", "vimdoc",
        "html", "css",
        "javascript",
        "typescript", "tsx",
        "go",
  		},
  	},
  },
  {
    -- autotag
    "windwp/nvim-ts-autotag",
    ft = {
      "javascript",
      "javascriptreact",
      "typescript",
      "typescriptreact",
    },
    config = function()
      require("nvim-ts-autotag").setup()
    end
  },
  {
    -- nvim-autopairs
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup()
    end,
  },
  {
    -- nvim-colorizer
    "norcalli/nvim-colorizer.lua",
    ft = {
      "html",
      "css",
      "sass",
      "vim",
      "typescript",
      "typescriptreact",
      "javascript",
      "javascriptreact",
    },
    config = function()
      require("colorizer").setup()
    end,
  },

  -- test new blink
  { import = "nvchad.blink.lazyspec" },
}
