-- Ensure packer is installed. This is a bit buggy due to async config application.
local packer_bootstrap = (function()
  local fn = vim.fn
  local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) == 0 then return false end
  fn.system({
    'git', 'clone', '--depth', '1',
    'https://github.com/wbthomason/packer.nvim', install_path
  })
  vim.cmd.packadd('packer.nvim')
  return true
end)()

local vscode = vim.g.vscode ~= nil

-- Reload/recompile packer when saving nvim config.
vim.cmd [[au! BufWritePost $MYVIMRC,~/etc/nvim.lua source <afile> | PackerCompile]]

require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'

  -- Indent detection, surrounds/indent objects, auto-insert bracket pairs.
  use 'tpope/vim-sleuth'
  use 'michaeljsmith/vim-indent-object'
  use { 'kylechui/nvim-surround', config = function() require('nvim-surround').setup() end }
  use { 'windwp/nvim-autopairs', config = function() require('nvim-autopairs').setup() end }
  -- Improved `f`, which also frees up `,` and `;`.
  use 'rhysd/clever-f.vim'
  -- gc<...> commands for commenting (gb for block).
  use {
    'numToStr/Comment.nvim',
    cond = not vscode,
    config = function() require('Comment').setup() end
  }

  -- ,x to save/close a buffer without affecting window positions.
  use {
    'moll/vim-bbye',
    cond = not vscode,
    config = function()
      local cmd = '<cmd>update<cr><cmd>Bdelete<cr>'
      vim.keymap.set('n', '<leader>x', cmd, { silent = true })
    end
  }

  -- Minimal colorscheme.
  use {
    'mcchrish/zenbones.nvim',
    requires = 'rktjmp/lush.nvim',
    cond = not vscode,
    config = function()
      vim.opt.termguicolors = true
      vim.cmd.colorscheme('zenbones')
    end
  }

  -- Improved statusline.
  use {
    'nvim-lualine/lualine.nvim',
    cond = not vscode,
    config = function()
      vim.opt.ruler = false
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
          lualine_b = { 'b:gitsigns_head', { 'diff', source = diff } },
          lualine_c = { { 'filename', path = 1 } },
          lualine_x = { 'diagnostics', 'filetype' },
        },
        inactive_sections = {
          lualine_c = { { 'filename', path = 1 } },
        },
      })
    end
  }

  -- Git gutter and some bindings.
  use {
    'lewis6991/gitsigns.nvim',
    cond = not vscode,
    config = function()
      require('gitsigns').setup({
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local function map(mode, l, r)
            vim.keymap.set(mode, l, r, { buffer = bufnr })
          end

          map({ 'n', 'v' }, '<leader>hs', gs.stage_hunk)
          map({ 'n', 'v' }, '<leader>hr', gs.reset_hunk)
          map('n', '<leader>hu', gs.undo_stage_hunk)
        end
      })
    end
  }

  -- Smarter syntax, used by many other plugins.
  use {
    'nvim-treesitter/nvim-treesitter',
    cond = not vscode,
    run = function()
      require('nvim-treesitter.install').update({ with_sync = true })
    end
  }

  -- Multi-purpose fuzzyfinder.
  use {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    requires = 'nvim-lua/plenary.nvim',
    cond = not vscode,
    config = function()
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>e', builtin.find_files)
      vim.keymap.set('n', '<leader>f', builtin.buffers)
      vim.keymap.set('n', '<leader>g', builtin.live_grep)

      local actions = require('telescope.actions')
      require('telescope').setup({
        defaults = {
          mappings = {
            i = {
              ['<esc>'] = actions.close,
              ['<c-u>'] = false,
            },
          },
        },
        pickers = {
          buffers = {
            preview = { hide_on_startup = true },
            layout_strategy = 'center',
            layout_config = {
              prompt_position = 'bottom'
            }
          }
        }
      })
    end
  }

  if packer_bootstrap then require('packer').sync() end
end)

vim.g.mapleader = ','
vim.opt.shortmess:append 'I'
vim.opt.wildmode = 'longest:full'
vim.keymap.set({ 'n', 'v' }, ';', ':')
vim.keymap.set('v', '<leader>s', ':sort i<cr>')

if vscode then
  vim.keymap.set('n', 'gr', [[<cmd>call VSCodeNotify("editor.action.rename")<cr>]])
  -- TODO: see if Commentary works with treesitter enabled
  vim.keymap.set('n', 'gcc', '<cmd>call VSCodeNotify("editor.action.commentLine")<cr>')
  vim.keymap.set('n', 'gbc', '<cmd>call VSCodeNotify("editor.action.blockComment")<cr>')
  vim.keymap.set('v', 'gc', '<cmd>call VSCodeNotifyVisual("editor.action.commentLine", 0)<cr>')
  vim.keymap.set('v', 'gb', '<cmd>call VSCodeNotifyVisual("editor.action.blockComment", 0)<cr>')
  -- TODO: add telescope-like bindings?
else
  vim.keymap.set('n', '<leader><leader>', '<cmd>buffer#<cr>')
  vim.keymap.set('n', '<c-j>', '<cmd>bnext<cr>', { silent = true })
  vim.keymap.set('n', '<c-k>', '<cmd>bprevious<cr>', { silent = true })
end
