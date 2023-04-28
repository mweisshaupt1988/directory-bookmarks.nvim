local M = {}

local buf, win, start_win
local config
local prefix

M.setup = function(options)
    config = options
    prefix = ' ' .. config.icon .. ' '

    vim.api.nvim_create_user_command("DirectoryBookmarks", function() M.directoryBookmarks() end, {})
end


local bookmarks

local function setMappings()
  for k,v in pairs(config.mappings) do
    vim.api.nvim_buf_set_keymap(buf, 'n', k, ':lua require("directory-bookmarks.bookmarks").' .. v .. '<cr>', { nowait = true, noremap = true, silent = true })
  end
end

-- https://dev.to/2nit/how-to-make-ui-for-neovim-plugins-in-lua-3b6e
local function createWin()
  start_win = vim.api.nvim_get_current_win()

  -- vim.api.nvim_command("topleft vnew") -- We open a new vertical window at the far right
  vim.api.nvim_command("aboveleft new") -- We open a new vertical window at the far right
  win = vim.api.nvim_get_current_win() -- We save our navigation window handle...
  buf = vim.api.nvim_get_current_buf() -- ...and it's buffer handle.

  vim.api.nvim_buf_set_name(buf, 'Bookmarks #' .. buf)
  vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(buf, 'swapfile', false)
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(buf, 'buflisted', false)
  vim.api.nvim_buf_set_option(buf, 'filetype', 'directory-bookmarks')
  vim.api.nvim_win_set_option(win, 'wrap', false)
  vim.api.nvim_win_set_option(win, 'cursorline', true)
  vim.api.nvim_win_set_option(win, 'number', false)
  vim.api.nvim_win_set_option(win, 'relativenumber', false)

  setMappings()
end

function M.openBookmark()
    if vim.api.nvim__buf_stats(buf).current_lnum > 1 then
        local selectedEntry = vim.api.nvim_get_current_line():gsub(prefix, "")
        local path = bookmarks[selectedEntry]

        if vim.api.nvim_win_is_valid(start_win) then
          vim.api.nvim_set_current_win(start_win)
          vim.api.nvim_command('cd ' .. path)
        else
          -- if there is no starting window we create new from lest side
          vim.api.nvim_command('leftabove vsplit ' .. path)
          -- and set it as our new starting window
          start_win = vim.api.nvim_get_current_win()
        end
    end
end

function M.closeBookmark()
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
  end
end

local function readFromFile(path)
    local file = io.open(path, "r")
    if not file then return nil end

    local lines = {}
    for line in file:lines() do
        local splitLine = vim.split(line, " ")
        lines[splitLine[1]] = splitLine[2]
    end

    return lines
end

local function redraw()
    vim.api.nvim_buf_set_option(buf, 'modifiable', true)

    local list = {}
    table.insert(list, 1, " Bookmarks")

    print(config.bookmarks_file)

    -- bookmarks = readFromFile(os.getenv("HOME") .. "/.NERDTreeBookmarks")
    bookmarks = readFromFile(config.bookmarks_file)
    if (bookmarks ~= nil) then
        for k,v in pairs(bookmarks) do table.insert(list, #list + 1, prefix .. k) end
        -- for k,v in pairs(bookmarks) do table.insert(list, #list + 1, prefix .. k .. " [" .. v .. "]") end
    end

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, list)
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    vim.api.nvim_win_set_height(win, #list + 1)
end

function M.directoryBookmarks()
    if win and vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_set_current_win(win)
    else
        createWin()
    end

    redraw()
end


return M
