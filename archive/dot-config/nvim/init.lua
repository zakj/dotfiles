-- TODO consider vim.opt.wildmode = 'longest:full'
-- TODO consider michaeljsmith/vim-indent-object or similar

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

  -- TODO trying this out
  {
    'rmagatti/auto-session',
    lazy = false,
    opts = { allowed_dirs = { '~/etc', '~/src/*' } }
    -- TODO consider keymaps for SessionSearch, maybe Autosession delete
  },

  {
    'folke/noice.nvim',
    dependencies = { 'MunifTanjim/nui.nvim' },
    event = 'VeryLazy',
    opts = { cmdline = { view = "cmdline" } },
  },

  {
    'nvim-lualine/lualine.nvim',
    lazy = false,
    opts = {
      sections = {
        lualine_b = { function() return require('auto-session.lib').current_session_name(true) end, 'diff' },
        lualine_c = { { 'filename', path = 1 } },
        lualine_x = { 'diagnostics', { 'filetype', icons_enabled = false } },
      },
    },
  },

  {
    'lewis6991/gitsigns.nvim',
    event = 'VeryLazy',
    opts = {},
    -- TODO should I only add these on attach? seems not to matter.
    keys = {
      { ']h',         function() require('gitsigns').next_hunk() end,           desc = 'Next hunk' },
      { '[h',         function() require('gitsigns').prev_hunk() end,           desc = 'Previous hunk' },
      { '<Leader>hd', function() require('gitsigns').preview_hunk_inline() end, desc = 'Show diff' },
      { '<Leader>hR', function() require('gitsigns').reset_hunk() end,          desc = 'Reset hunk' },
    },
    -- TODO it would be nice if these were shades of the existing Add/Change/DeleteLn colors
    -- also this should end up in upstream
    init = function()
      vim.cmd.highlight('link GitSignsAddInline DiffText')
      vim.cmd.highlight('link GitSignsChangeInline DiffText')
      vim.cmd.highlight('link GitSignsDeleteInline DiffText')
    end
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
    opts = {
      defaults = {
        mappings = {
          i = {
            ['<esc>'] = function(buf) require('telescope.actions').close(buf) end,
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
    },
    keys = {
      { '<Leader>e', function() require('telescope.builtin').find_files() end, desc = "Find files" },
      { '<Leader>f', function() require('telescope.builtin').buffers() end,    desc = "Find open buffers" },
      { '<Leader>g', function() require('telescope.builtin').live_grep() end,  desc = "Live grep" },
    }
  },

  -- Used primarily for a code actions menu.
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
      { '<Leader>l', function() require('mini.files').open(vim.api.nvim_buf_get_name(0)) end, desc = 'File explorer' },
    },
  },

  -- Editing -- {{{1

  { 'tpope/vim-sleuth',       lazy = false },
  { 'rhysd/clever-f.vim',     event = 'VeryLazy' }, -- TODO consider hop/leap/etc.
  { 'windwp/nvim-autopairs',  event = 'InsertEnter', opts = {} },
  { 'kylechui/nvim-surround', event = 'VeryLazy',    opts = {} },

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

  -- LSP {{{1

  {
    'williamboman/mason-lspconfig.nvim',
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    dependencies = {
      { 'williamboman/mason.nvim', opts = {} },
      { 'neovim/nvim-lspconfig' },
      {
        'saghen/blink.cmp',
        version = '*',
        opts = {
          keymap = { preset = 'super-tab' },
          sources = { default = { 'lsp', 'path' } },
        }
      },
    },
    opts = {
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
            { '<Leader>ca', vim.lsp.buf.code_action, desc = 'Code actions' },
            { '<Leader>cd', vim.lsp.buf.definition,  desc = 'Go to definition' },
            { '<Leader>cr', vim.lsp.buf.rename,      desc = 'Rename symbol' },
            {
              '<Leader>co',
              function()
                builtin.lsp_document_symbols({ ignore_symbols = 'variable' })
              end,
              desc = 'Find symbols'
            },
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
      -- See foo <https://github.com/williamboman/mason.nvim/issues/392>
      -- Maybe just automate via lazy.nvim's 'build' config?
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
