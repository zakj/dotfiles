-- TODO move some VeryLazy to cmd/keys
-- TODO normalize leader/Leader
-- TODO consider vim.opt.wildmode = 'longest:full'
-- TODO consider michaeljsmith/vim-indent-object
-- TODO gitsigns keymap
--   map({ 'n', 'v' }, '<leader>hn', gs.next_hunk, "Next hunk")
--   map({ 'n', 'v' }, '<leader>hp', gs.preview_hunk, "Preview hunk")
--   map({ 'n', 'v' }, '<leader>hr', gs.reset_hunk, "Reset hunk")
--   map({ 'n', 'v' }, '<leader>hs', gs.stage_hunk, "Stage hunk")
--   map('n', '<leader>hu', gs.undo_stage_hunk, "Undo stage hunk")

vim.g.mapleader = " "

vim.opt.shortmess:append 'I'
vim.opt.title = true

vim.diagnostic.config({
  severity_sort = true,
  signs = false,
  virtual_text = { prefix = '▎' },
})

local init_group = vim.api.nvim_create_augroup('init', {})

vim.api.nvim_create_autocmd('TextYankPost', {
  group = init_group,
  -- TODO renamed to vim.hl in 0.11
  callback = function() vim.highlight.on_yank({ timeout = 150 }) end,
  desc = "Briefly highlight yanked text"
})

local plugins = {
  -- UI -- {{{1

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

  { 'lewis6991/gitsigns.nvim', event = 'VeryLazy',    opts = {} },

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
      { '<Leader>s', ':sort i<CR>',     desc = 'Sort lines',     mode = 'v' },
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
      -- TODO is this what's causing early load?
      return {
        { '<leader>e', require('telescope.builtin').find_files, desc = "Find files" },
        { '<leader>f', require('telescope.builtin').buffers,    desc = "Find open buffers" },
        { '<leader>g', require('telescope.builtin').live_grep,  desc = "Live grep" },
      }
    end
  },

  -- Used primarily for LSP code actions.
  {
    'nvim-telescope/telescope-ui-select.nvim',
    -- TODO figure out how to lazy load better
    event = 'VeryLazy',
    dependencies = { 'nvim-telescope/telescope.nvim' },
    opts = {},
    config = function()
      local telescope = require('telescope')
      telescope.setup({
        extensions = {
          ['ui-select'] = { require('telescope.themes').get_dropdown() }
        }
      })
      telescope.load_extension('ui-select')
    end
  },

  -- TODO: testing
  {
    'echasnovski/mini.files',
    opts = {},
    keys = {
      { '<Leader>m', function() require('mini.files').open() end, desc = 'File explorer' },
    },
  },

  -- Editing -- {{{1

  { 'tpope/vim-sleuth',        lazy = false },
  { 'rhysd/clever-f.vim',      event = 'VeryLazy' }, -- TODO consider hop/leap/etc.
  { 'windwp/nvim-autopairs',   event = 'InsertEnter', opts = {} },
  { 'kylechui/nvim-surround',  event = 'VeryLazy',    opts = {} },

  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = 'VeryLazy',
    opts = {
      highlight = { enable = true },
      indent = { enable = true },
      ensure_installed = {
        'astro',
        'css',
        'html',
        'javascript',
        'json',
        'jsonc',
        'lua',
        'python',
        'svelte',
        'toml',
        'typescript',
      },
    },
  },

  -- LSP  {{{1

  {
    'neovim/nvim-lspconfig',
    -- TODO: steal LazyFile from LazyVim?
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },

    dependencies = {
      {
        'saghen/blink.cmp',
        version = '*',
        opts = {
          keymap = { preset = 'super-tab' }
        }
      },
      { 'williamboman/mason.nvim',           opts = {} },
      { 'williamboman/mason-lspconfig.nvim', opts = {} },
    },

    opts = {
      -- TODO should this go in mason-lspconfig?
      ensure_installed = {
        'astro',
        'lua_ls',
        'prettier',
        'pyright',
        'ruff',
        'svelte',
      }
    },
    config = function()
      local capabilities = require('blink.cmp').get_lsp_capabilities()
      local lspconfig = require('lspconfig')

      require('mason-lspconfig').setup_handlers({
        function(server_name)
          lspconfig[server_name].setup({ capabilities = capabilities })
        end,
      })

      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local builtin = require('telescope.builtin')
          require('which-key').add({
            { '<Leader>ca', vim.lsp.buf.code_action,      desc = 'Code actions' },
            { '<Leader>cd', vim.lsp.buf.definition,       desc = 'Go to definition' },
            { '<Leader>cr', vim.lsp.buf.rename,           desc = 'Rename symbol' },
            { '<Leader>co', builtin.lsp_document_symbols, desc = 'Find symbols' },
            buffer = args.buf
          })
        end
      })
    end,
  },

  {
    'stevearc/conform.nvim',
    event = 'VeryLazy',
    opts = {
      -- TODO: needed to `npm i prettier-plugin-astro prettier-plugin-svelte`
      -- from ~/.local/share/nvim/mason/packages/prettier/ to make this work,
      -- and also add a .prettierrc.mjs to the appropriate repository.
      -- See <https://github.com/williamboman/mason.nvim/issues/392>
      formatters_by_ft = {
        astro = { 'prettier' },
        javascript = { 'prettier' },
        typescript = { 'prettier' },
        lua = { lsp_format = "fallback" },
        python = { 'ruff_organize_imports', 'ruff_format' },
        svelte = { 'prettier' },
      },
      format_on_save = true,
    },
  },

  -- }}}
}

-- lazy.nvim  {{{1
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    'git', 'clone', '--filter=blob:none', '--branch=stable',
    'https://github.com/folke/lazy.nvim.git', lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  spec = plugins,
  defaults = { lazy = true },
  rocks = { enabled = false },
  change_detection = { notify = false }
})

-- vim: foldmethod=marker foldlevel=0
