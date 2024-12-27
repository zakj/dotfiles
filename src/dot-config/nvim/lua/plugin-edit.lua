return {
  { 'tpope/vim-sleuth',   lazy = false },
  { 'rhysd/clever-f.vim', lazy = false }, -- TODO consider hop/leap/etc.

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
    event = 'VeryLazy',
    opts = {},
  },
}
