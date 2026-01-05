local M = {}

M.run_command_in_new_terminal_window = function (args, opts)
  local cmd_args = { "jj", "--no-pager", "--color=always" }
  vim.list_extend(cmd_args, args)

  -- Build shell command
  local cmd_str = table.concat(vim.tbl_map(vim.fn.shellescape, cmd_args), " ")
  local shell_cmd = "sh -c " .. vim.fn.shellescape(cmd_str)

  -- Create terminal buffer
  vim.cmd("botright split term://" .. vim.fn.fnameescape(shell_cmd))

  local window = vim.api.nvim_get_current_win()
  local buffer = vim.api.nvim_get_current_buf()

  -- Set buffer options to ensure it's properly cleaned up
  vim.bo[buffer].bufhidden = 'wipe'  -- Auto-wipe when hidden
  vim.bo[buffer].buflisted = false   -- Don't show in buffer lists

  pcall(vim.api.nvim_buf_set_name, buffer, opts.title or "[JJ]")
  vim.api.nvim_win_set_height(window, math.floor(vim.o.lines * 0.4))

  if opts.on_ready then
    opts.on_ready(window, buffer)
  end

  -- Auto-cleanup on buffer wipeout
  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = buffer,
    once = true,
    callback = opts.on_close
  })
end

return M
