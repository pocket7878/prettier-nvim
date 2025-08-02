local resolver = require("prettier.resolver")

local M = {}

--- 現在バッファを Prettier でフォーマット(同期)
function M.format_current_buffer_sync()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("Buffer has no name (unsaved new file)", vim.log.levels.WARN)
    return false
  end

  local cli_path = resolver.resolve_cli_path_for_current_buffer()
  if not cli_path then
    vim.notify("No local prettier found", vim.log.levels.WARN)
    return false
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local orig_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local text = table.concat(orig_lines, "\n")

  local cmd = { cli_path, "--stdin-filepath", file }

  local output = vim.fn.systemlist(cmd, text)

  if vim.v.shell_error ~= 0 then
      vim.notify("Prettier failed: " .. table.concat(output, "\n"), vim.log.levels.ERROR)
      return false
  end

  local same = true
  if #orig_lines ~= #output then
      same = false
  else
      for i = 1, #orig_lines do
          if orig_lines[i] ~= output[i] then
              same = false
              break
          end
      end
  end

  if not same then
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, output)
  end
end

--- 現在バッファを Prettier でフォーマット(非同期)
function M.format_current_buffer_async()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("Buffer has no name (unsaved new file)", vim.log.levels.WARN)
    return
  end

  local cli_path = resolver.resolve_cli_path_for_current_buffer()
  if not cli_path then
    vim.notify("No local prettier found", vim.log.levels.WARN)
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local orig_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local text = table.concat(orig_lines, "\n")

  local cmd = { cli_path, "--stdin-filepath", file }
  local output = {}

  local job_id = vim.fn.jobstart(cmd, {
    stdin = "pipe",
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      if data then
        vim.list_extend(output, data)
      end
    end,
    on_stderr = function(_, data)
      if data and #data > 0 then
        vim.notify(table.concat(data, "\n"), vim.log.levels.ERROR)
      end
    end,
    on_exit = function(_, code)
      if code == 0 and #output > 0 then
        -- 差分チェック
        local same = true
        if #orig_lines ~= #output then
          same = false
        else
          for i = 1, #orig_lines do
            if orig_lines[i] ~= output[i] then
              same = false
              break
            end
          end
        end

        if not same then
          vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, output)
        end
      elseif code ~= 0 then
        vim.notify("Prettier failed (exit code " .. code .. ")", vim.log.levels.ERROR)
        return
      end
    end,
  })

  vim.fn.chansend(job_id, text)
  vim.fn.chanclose(job_id, "stdin")
end

return M
