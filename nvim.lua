-- Ensure packer is installed. This is a bit buggy due to async config application.
local packer_bootstrap = (function()
  local fn = vim.fn
  local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) == 0 then return false end
  fn.system({
    'git', 'clone', '--depth', '1',
    'https://github.com/wbthomason/packer.nvim', install_path
  })
  vim.cmd [[packadd packer.nvim]]
  return true
end)()

-- Reload/recompile packer when saving nvim config.
vim.cmd [[au! BufWritePost $MYVIMRC,~/etc/nvim.lua source <afile> | PackerCompile]]

require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'

  -- Sensible defaults, indent detection, repeat for complex actions.
  use {'tpope/vim-sensible', 'tpope/vim-sleuth', 'tpope/vim-repeat'}

  -- Minimal colorscheme.
  use {
    'mcchrish/zenbones.nvim',
    requires = 'rktjmp/lush.nvim',
    config = function()
      vim.opt.termguicolors = true
      vim.cmd [[colorscheme zenbones]]
    end
  }

  -- Improved statusline.
  use {
    'nvim-lualine/lualine.nvim',
    config = function()
      vim.opt.showmode = false
      local function diff()
        local gitsigns = vim.b.gitsigns_status_dict
        if gitsigns then
          return {
            added = gitsigns.added,
            modified = gitsigns.changed,
            removed = gitsigns.removed,
          }
        end
      end
      require('lualine').setup({
        options = {
          icons_enabled = false,
        },
        sections = {
          lualine_b = {'b:gitsigns_head', {'diff', source = diff}},
          lualine_c = {{'filename', path = 1}},
          lualine_x = {'diagnostics', 'filetype'},
        },
        inactive_sections = {
          lualine_c = {{'filename', path = 1}},
        },
      })
    end
  }

  -- ,x to save/close a buffer without affecting window positions.
  use {
    'moll/vim-bbye',
    config = function()
      local cmd = '<cmd>update<cr><cmd>Bdelete<cr>'
      vim.keymap.set('n', '<leader>x', cmd, {silent = true})
    end
  }

  -- Improved `f`, which also frees up `,` and `;`.
  use 'rhysd/clever-f.vim'

  -- gc<...> commands for commenting (gb for block).
  use {
    'numToStr/Comment.nvim',
    config = function() require('Comment').setup() end
  }

  -- Git gutter and some bindings.
  use {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup({
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local function map(mode, l, r)
            vim.keymap.set(mode, l, r, {buffer = bufnr})
          end
          map({'n', 'v'}, '<leader>hs', gs.stage_hunk)
          map({'n', 'v'}, '<leader>hr', gs.reset_hunk)
          map('n', '<leader>hu', gs.undo_stage_hunk)
        end
      })
    end
  }

  -- Smarter syntax, used by many other plugins.
  use {
    'nvim-treesitter/nvim-treesitter',
    run = function()
      require('nvim-treesitter.install').update({with_sync = true})
    end
  }

  -- Multi-purpose fuzzyfinder.
  use {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    requires = 'nvim-lua/plenary.nvim',
    config = function()
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>e', builtin.find_files)
      vim.keymap.set('n', '<leader>f', builtin.buffers)

      local actions = require('telescope.actions')
      require('telescope').setup({
        defaults = {
          mappings = {
            i = {
              ['<esc>'] = actions.close,
              ['<c-u>'] = false,
            },
          },
        }
      })
    end
  }

  if packer_bootstrap then require('packer').sync() end
end)

vim.g.mapleader = ','
vim.opt.ruler = false
vim.keymap.set({'n', 'v'}, ';', ':')
vim.keymap.set('n', '<c-j>', '<cmd>bnext<cr>', {silent = true})
vim.keymap.set('n', '<c-k>', '<cmd>bprevious<cr>', {silent = true})

-- TODO: consider keybinding organization; it's a little haphazard now.
-- TODO: move over a few more common bindings from vim config
