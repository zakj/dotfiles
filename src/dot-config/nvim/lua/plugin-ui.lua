return {
  {
    'mcchrish/zenbones.nvim',
    dependencies = 'rktjmp/lush.nvim',
    lazy = false,
    priority = 1000,
    config = function() vim.cmd.colorscheme('zenbones') end,
  },

  {
    'folke/noice.nvim',
    dependencies = { 'MunifTanjim/nui.nvim' },
    event = 'VeryLazy',
    opts = {
      cmdline = { view = "cmdline" },
    },
  },

  {
    'nvim-lualine/lualine.nvim',
    lazy = false,
    opts = {
      sections = {
        lualine_b = { 'branch', 'diff' },
        lualine_c = { { 'filename', path = 1 } },
        lualine_x = { 'diagnostics', { 'filetype', icons_enabled = false } },
      },
    },
  },

  {
    'folke/which-key.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    event = 'VeryLazy',
    opts = { preset = "helix" },
    keys = {
      { ';',         ':',               desc = 'Command line',   mode = { 'n', 'v' } },
      { '<D-s>',     vim.cmd.write,     desc = 'Write buffer',   mode = { 'n', 'i', 'v' } },
      { '<C-j>',     vim.cmd.bnext,     desc = 'Next buffer' },
      { '<C-k>',     vim.cmd.bprevious, desc = 'Previous buffer' },
      { '<Leader>x', vim.cmd.bdelete,   desc = 'Delete buffer' },
      {
        '<Leader><Leader>',
        function() vim.cmd.buffer('#') end,
        desc = 'Alternate buffer',
      },
    }
  },

  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-tree/nvim-web-devicons' },
    cmd = 'Telescope',
    opts = function()
      return {
        defaults = {
          mappings = {
            i = {
              ['<esc>'] = require('telescope.actions').close,
              ['<C-u>'] = false,
            },
          }
        },
        -- TODO this is specific to telescope-file-browser; it should live there
        -- extensions = {
        --   file_browser = {
        --     hijack_netrw = true,
        --     display_stat = false,
        --     files = false,
        --     preview = { hide_on_startup = true },
        --     layout_strategy = 'vertical',
        --     layout_config = { width = 0.5, height = 0.4 },
        --   },
        -- },
        pickers = {
          buffers = {
            preview = { hide_on_startup = true },
            layout_strategy = 'vertical',
            layout_config = { width = 0.5, height = 0.4 },
          },
        }
      }
    end,
    keys = function()
      return {
        { '<leader>e', require('telescope.builtin').find_files, desc = "Find files" },
        { '<leader>f', require('telescope.builtin').buffers,    desc = "Find open buffers" },
        { '<leader>g', require('telescope.builtin').live_grep,  desc = "Live grep" },
      }
    end
  },

  -- TODO trying this out as a quick way to create new files.
  -- Other options are mini.file/oil.nvim
  -- {
  --   "nvim-telescope/telescope-file-browser.nvim",
  --   dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
  --   event = 'VeryLazy',
  --   keys = function()
  --     return {
  --       { '<leader>E', require('telescope').extensions.file_browser.file_browser, desc = "Folder browser" }
  --     }
  --   end,
  -- },

  -- {
  --   "stevearc/oil.nvim",
  --   -- event = 'VeryLazy',
  --   opts = {
  --     view_options = {
  --       -- Show files and directories that start with "."
  --       show_hidden = true,
  --     },
  --     keymaps = {
  --       ['q'] = { 'actions.close', mode = 'n' },
  --     },
  --     float = {
  --       -- Padding around the floating window
  --       padding = 2,
  --       max_width = 60,
  --       max_height = 0,
  --       -- border = "rounded",
  --       win_options = {
  --         winblend = 0,
  --       },
  --     },
  --     -- Optional dependencies
  --     dependencies = { "nvim-tree/nvim-web-devicons" },
  --   },
  --   keys = function()
  --     return {
  --       { '<Leader>O', require('oil').toggle_float, desc = 'XXX TOOD' },
  --     }
  --   end,
  -- },

  -- TODO how well does this work with jujutsu?
  {
    'lewis6991/gitsigns.nvim',
    event = 'VeryLazy',
    opts = {}
  }
}
