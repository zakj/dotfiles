-- Set up some vim options before lazy.nvim sets up, mostly for g:mapleader.
require('opts')

-- Ensure lazy.nvim is installed.
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    'git', 'clone', '--filter=blob:none', '--branch=stable',
    'https://github.com/folke/lazy.nvim.git', lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  spec = {
    { import = "plugin-ui" },
    { import = "plugin-edit" },
    { import = "plugin-code" },
  },
  defaults = { lazy = true },
  rocks = { enabled = false },
  change_detection = { notify = false }
})

-- TODO ------------------------------------------------------------


-- vim.opt.wildmode = 'longest:full'
-- vim.keymap.set('v', '<leader>s', ':sort i<cr>')

--   'michaeljsmith/vim-indent-object',

--   -- Git gutter and some bindings.
--   {
--     'lewis6991/gitsigns.nvim',
--     cond = not_vscode,
--     config = function()
--       require('gitsigns').setup({
--         on_attach = function(bufnr)
--           local gs = package.loaded.gitsigns
--           local function map(mode, l, r, desc)
--             vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
--           end
--
--           map({ 'n', 'v' }, '<leader>hn', gs.next_hunk, "Next hunk")
--           map({ 'n', 'v' }, '<leader>hp', gs.preview_hunk, "Preview hunk")
--           map({ 'n', 'v' }, '<leader>hr', gs.reset_hunk, "Reset hunk")
--           map({ 'n', 'v' }, '<leader>hs', gs.stage_hunk, "Stage hunk")
--           map('n', '<leader>hu', gs.undo_stage_hunk, "Undo stage hunk")
--         end
--       })
--     end
--   },
