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

-- Packer requires a function for `cond`; booleans don't work.
local function not_vscode() return vim.g.vscode == nil end

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
    cond = not_vscode,
    config = function() require('Comment').setup() end
  }

  -- ,x to save/close a buffer without affecting window positions.
  use {
    'moll/vim-bbye',
    cond = not_vscode,
    config = function()
      local cmd = '<cmd>update<cr><cmd>Bdelete<cr>'
      vim.keymap.set('n', '<leader>x', cmd, { silent = true })
    end
  }

  -- Minimal colorscheme.
  use {
    'mcchrish/zenbones.nvim',
    requires = 'rktjmp/lush.nvim',
    cond = not_vscode,
    config = function()
      vim.opt.termguicolors = true
      vim.cmd.colorscheme('zenbones')
    end
  }

  -- Improved statusline.
  use {
    'nvim-lualine/lualine.nvim',
    cond = not_vscode,
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
    cond = not_vscode,
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
    cond = not_vscode,
    run = function()
      require('nvim-treesitter.install').update({ with_sync = true })
    end
  }

  -- Multi-purpose fuzzyfinder.
  use {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    requires = 'nvim-lua/plenary.nvim',
    cond = not_vscode,
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
vim.opt.title = true
vim.opt.wildmode = 'longest:full'
vim.keymap.set({ 'n', 'v' }, ';', ':')
vim.keymap.set('v', '<leader>s', ':sort i<cr>')

if vim.g.vscode ~= nil then
  local function vscode(cmd) return '<cmd>call VSCodeNotify("' .. cmd ..'")<cr>' end
  -- TODO: 0 argument doesn't seem to work
  local function vscode_visual(cmd) return '<cmd>call VSCodeNotifyVisual("' .. cmd ..'", 0)<cr>v' end

  vim.keymap.set('n', '<leader>e', vscode('workbench.action.quickOpen'))
  vim.keymap.set('n', '<leader>f', vscode('workbench.action.showAllEditors'))
  vim.keymap.set('n', '<leader>g', vscode('workbench.action.findInFiles'))

  vim.keymap.set('n', 'gr', vscode('editor.action.rename'))
  vim.keymap.set('n', 'gcc', vscode('editor.action.commentLine'))
  vim.keymap.set('n', 'gbc', vscode('editor.action.blockComment'))
  vim.keymap.set('v', 'gc', vscode_visual('editor.action.commentLine'))
  vim.keymap.set('v', 'gb', vscode_visual('editor.action.blockComment'))
else
  vim.keymap.set('n', '<leader><leader>', '<cmd>buffer#<cr>')
  vim.keymap.set('n', '<c-j>', '<cmd>bnext<cr>', { silent = true })
  vim.keymap.set('n', '<c-k>', '<cmd>bprevious<cr>', { silent = true })
end
