-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  'jiangmiao/auto-pairs',

  {
    'tpope/vim-fugitive',
    lazy = false, -- load immediately (optional, you can also lazy-load on git commands)
  },

  {
    'lmgraf/wsl-clipboard.nvim',
    opts = {
      mode = 'sync',
    },
  },

  {
    'nvim-tree/nvim-tree.lua',
    version = '*',
    lazy = false,
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      require('nvim-tree').setup()

      vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
    end,
  },

  { -- Typescript plugin
    'pmizio/typescript-tools.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
    opts = {
      settings = {
        tsserver_plugins = {
          '@vue/typescript-plugin',
        },
      },
      filetypes = {
        'javascript',
        'javascriptreact',
        'typescript',
        'typescriptreact',
        'vue',
      },
    },
  },

  -- React
  {
    'windwp/nvim-ts-autotag',
    opts = {
      opts = {
        enable_close = true,
        enable_rename = false,
        enable_close_on_slash = false,
      },
    },
  },

  {
    'NvChad/nvim-colorizer.lua',
    opts = {
      user_default_options = {
        tailwind = true,
      },
    },
  },

  {
    'folke/tokyonight.nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require('tokyonight').setup {
        styles = {
          comments = { italic = false }, -- Disable italics in comments
        },
      }

      -- Load tokynight colorscheme
      -- vim.cmd.colorscheme 'tokyonight-night'
    end,
  },

  {
    'rose-pine/neovim',
    priority = 1000,
    name = 'rose-pine',
    config = function()
      require('rose-pine').setup {
        styles = {
          bold = true,
          italic = false,
        },
        highlight_groups = {
          EndOfBuffer = { fg = 'base', bg = 'base' },
        },
      }

      -- Load rose pine colorscheme
      vim.cmd.colorscheme 'rose-pine'
    end,
  },

  {
    'webhooked/kanso.nvim',
    lazy = false,
    priority = 1000,
  },

  {
    'ellisonleao/gruvbox.nvim',
    priority = 1000,
    config = function()
      require('gruvbox').setup {
        italic = {
          comments = false,
          emphasis = true,
          folds = true,
          operators = false,
          strings = false,
        },
      }

      -- Load gruvbox color scheme
      -- vim.cmd.colorscheme 'gruvbox'
    end,
  },
}
