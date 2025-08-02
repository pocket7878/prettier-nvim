local M = {}

local function resolve_executable(file_dir, cwd)
    local dir = file_dir
    while dir and dir:find(cwd, 1, true) == 1 do
        local nm_bin_path = dir .. "/node_modules/.bin/prettier"
        if vim.fn.executable(nm_bin_path) == 1 then
            return nm_bin_path
        end

        local parent = vim.fn.fnamemodify(dir, ":h")
        if parent == dir then
            break
        end
        dir = parent
    end

    return nil
end

function M.resolve_cli_path_for_current_buffer()
    local file = vim.api.nvim_buf_get_name(0)
    if file == "" then
        return nil
    end

    local file_dir = vim.fn.fnamemodify(file, ":p:h")
    local cwd = vim.uv.cwd()
    return resolve_executable(file_dir, cwd)
end

return M
