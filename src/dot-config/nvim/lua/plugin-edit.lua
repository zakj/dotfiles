return {
  { 'tpope/vim-sleuth',   lazy = false },
  { 'rhysd/clever-f.vim', event = 'VeryLazy' }, -- TODO consider hop/leap/etc.

  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = {},
  },

  {
    'kylechui/nvim-surround',
    event = 'VeryLazy',
    opts = {},
  },

  -- TODO: testing
  {
    'echasnovski/mini.files',
    opts = {},
    keys = {
      { '<Leader>m', function() require('mini.files').open() end, desc = 'File explorer' },
    },
  },
}
