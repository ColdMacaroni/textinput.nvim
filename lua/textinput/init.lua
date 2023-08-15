local M = {}

M.fancy_input = function(callback, opts)
  opts = vim.tbl_extend("keep", opts or {}, {
    -- Defaults
    title = "Input!",
  })

  -- Adapted from api-floatwin
  -- Unlisted scratch
  local buf = vim.api.nvim_create_buf(false, true)
  local winopts = {
    width = 30,
    height = 1,
    relative = "cursor",
    anchor = "NE",
    col = 16,
    row = 1,
    style = "minimal",
    border = "rounded",
    title = opts.title,
    title_pos = "center",
  }
  -----x-x-----
  local win = vim.api.nvim_open_win(buf, true, winopts)

  -- Kills the window and calls the given function with the last line.
  local function endwin(call)
    vim.api.nvim_win_close(win, true)

    if call then
      call(vim.api.nvim_buf_get_lines(buf, -2, -1, false)[1])
    end

    vim.api.nvim_buf_delete(buf, { force = true })
    local pos = vim.api.nvim_win_get_cursor(0)
    vim.api.nvim_win_set_cursor(0, { pos[1], pos[2] + 1 })

    vim.cmd.stopinsert()

    vim.cmd.startinsert()
  end

  -- Make enter and esc quit.
  vim.keymap.set("i", "<Return>", function()
    endwin(callback)
  end, { buffer = buf })

  vim.keymap.set("i", "<Esc>", function()
    endwin()
  end, { buffer = buf })

  vim.cmd.startinsert()
end

-- Asks for input using nvim's default.
M.ask_input = function(prompt, append)
  if append == nil then
    append = true
  end
  vim.ui.input({ prompt = prompt or "Input> " }, function(inp)
    if inp then
      M.into_line(inp, { move_cursor = true, append = append })
    end
  end)
end

-- Writes the text into the current line at the cursor's position.
M.into_line = function(text, opt)
  opt = vim.tbl_extend("keep", opt or {}, {
    -- Defaults
    append = true,
    move_cursor = true,
  })
  -- Not sure if this is the best approach
  local line = vim.api.nvim_get_current_line()
  local pos = vim.api.nvim_win_get_cursor(0)

  if opt.append then
    pos[2] = pos[2] + 1
  end

  local newline = line:sub(1, pos[2]) .. text .. line:sub(pos[2] + 1)
  vim.api.nvim_set_current_line(newline)

  if opt.move_cursor then
    vim.api.nvim_win_set_cursor(0, { pos[1], pos[2] + text:len() })
  end
end

return M
