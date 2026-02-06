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
    opts = {},
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
}
