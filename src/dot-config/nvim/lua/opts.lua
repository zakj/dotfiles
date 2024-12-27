vim.g.mapleader = " "

-- TODO: consider: to get "1 line yanked"/"1 line less" messages
-- vim.opt.report = 0
vim.opt.shortmess:append 'I'
vim.opt.title = true

vim.diagnostic.config({
  severity_sort = true,
  signs = false,
  virtual_text = { prefix = '▎' },
})
