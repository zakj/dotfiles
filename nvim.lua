-- Ensure lazy.nvim is installed.
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git', 'clone', '--filter=blob:none', '--branch=stable',
    'https://github.com/folke/lazy.nvim.git', lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local not_vscode = vim.g.vscode == nil

vim.g.mapleader = ','
vim.opt.shortmess:append 'I'
vim.opt.title = true
vim.opt.wildmode = 'longest:full'
vim.keymap.set({ 'n', 'v' }, ';', ':')
vim.keymap.set('v', '<leader>s', ':sort i<cr>')

require('lazy').setup({
  -- Minimal colorscheme.
  {
    'mcchrish/zenbones.nvim',
    lazy = false,
    priority = 1000,
    dependencies = { 'rktjmp/lush.nvim' },
    cond = not_vscode,
    config = function()
      vim.opt.termguicolors = true
      vim.cmd.colorscheme('zenbones')
    end,
  },

  -- Indent detection, surrounds/indent objects, auto-insert bracket pairs.
  'tpope/vim-sleuth',
  'michaeljsmith/vim-indent-object',
  { 'kylechui/nvim-surround', config = true },
  { 'windwp/nvim-autopairs',  config = true },
  -- Improved `f`, which also frees up `,` and `;`.
  { 'rhysd/clever-f.vim' },
  -- gc<...> commands for commenting (gb for block).
  { 'numToStr/Comment.nvim',  config = true, cond = not_vscode },

  -- ,x to save/close a buffer without affecting window positions.
  {
    'moll/vim-bbye',
    cond = not_vscode,
    config = function()
      local cmd = '<cmd>update<cr><cmd>Bdelete<cr>'
      vim.keymap.set('n', '<leader>x', cmd, { silent = true })
    end
  },

  -- Improved statusline.
  {
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
  },


  -- Git gutter and some bindings.
  {
    'lewis6991/gitsigns.nvim',
    cond = not_vscode,
    config = function()
      require('gitsigns').setup({
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local function map(mode, l, r)
            vim.keymap.set(mode, l, r, { buffer = bufnr })
          end

          map({ 'n', 'v' }, '<leader>hn', gs.next_hunk)
          map({ 'n', 'v' }, '<leader>hp', gs.preview_hunk)
          map({ 'n', 'v' }, '<leader>hr', gs.reset_hunk)
          map({ 'n', 'v' }, '<leader>hs', gs.stage_hunk)
          map('n', '<leader>hu', gs.undo_stage_hunk)
        end
      })
    end
  },

  -- Smarter syntax, used by many other plugins.
  {
    'nvim-treesitter/nvim-treesitter',
    cond = not_vscode,
    build = function()
      require('nvim-treesitter.install').update({ with_sync = true })
    end
  },

  -- Multi-purpose fuzzyfinder.
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim' },
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
  },

  -- Better nvim :terminal.
  { 'akinsho/toggleterm.nvim', version = "*", config = true, cond = not_vscode },

}, {
  ui = {
    icons = {
      cmd = "⌘",
      config = "🛠",
      event = "📅",
      ft = "📂",
      init = "⚙",
      keys = "🗝",
      lazy = "💤 ",
      plugin = "🔌",
      require = "🌙",
      runtime = "💻",
      source = "📄",
      start = "🚀",
    },
  },
})


if vim.g.vscode ~= nil then
  local function vscode(cmd) return '<cmd>call VSCodeNotify("' .. cmd .. '")<cr>' end

  vim.keymap.set('n', '<leader>e', vscode('workbench.action.quickOpen'))
  vim.keymap.set('n', '<leader>f', vscode('workbench.action.showAllEditors'))
  vim.keymap.set('n', '<leader>g', vscode('workbench.action.findInFiles'))

  vim.keymap.set('n', 'gr', vscode('editor.action.rename'))
  vim.keymap.set('n', 'gcc', '<Plug>VSCodeCommentaryLine')
  vim.keymap.set('v', 'gc', '<Plug>VSCodeCommentary')
else
  vim.keymap.set('n', '<leader><leader>', '<cmd>buffer#<cr>')
  vim.keymap.set('n', '<c-j>', '<cmd>bnext<cr>', { silent = true })
  vim.keymap.set('n', '<c-k>', '<cmd>bprevious<cr>', { silent = true })
end
