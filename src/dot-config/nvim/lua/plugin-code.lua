return {
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

  -- Used for LSP code actions.
  {
    'nvim-telescope/telescope-ui-select.nvim',
    event = 'VeryLazy',
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

}
