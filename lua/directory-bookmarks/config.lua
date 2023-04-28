local M = {}

---@class ProjectOptions
M.defaults = {
    bookmarks_file = os.getenv('HOME') .. '/.local/share/nvim/directory-bookmarks/bookmarks.txt',
    icon = '',
    mappings = {
        q = 'closeBookmark()',
        ['<cr>'] = 'openBookmark()',
    }

}

---@type ProjectOptions
M.options = {}

M.setup = function(options)
  M.options = vim.tbl_deep_extend("force", M.defaults, options or {})

  require('directory-bookmarks.bookmarks').setup(M.options)
end

return M
