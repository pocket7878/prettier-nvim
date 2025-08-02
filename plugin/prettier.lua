if vim.g.loaded_prettier == 1 or vim.g.loaded_prettier == true then
    return
end

vim.api.nvim_create_user_command("Prettier", function()
    local bufnr = vim.api.nvim_get_current_buf()
    require("prettier").format_buffer_sync(bufnr)
end, {})

vim.api.nvim_create_user_command("PrettierAsync", function()
    local bufnr = vim.api.nvim_get_current_buf()
    require("prettier").format_buffer_async(bufnr)
end, {})

vim.api.nvim_create_user_command("PrettierCliPath", function ()
    local bufnr = vim.api.nvim_get_current_buf()
    local cli_path = require("prettier.resolver").resolve_cli_path_for_buffer(bufnr)
    vim.cmd.echom("'" .. cli_path .. "'")
end, {})

vim.api.nvim_create_user_command("PrettierCliVersion", function ()
    local bufnr = vim.api.nvim_get_current_buf()
    local version = require("prettier").prettier_cli_version(bufnr)
    vim.cmd.echom("'" ..version .. "'")
end, {})

vim.g.loaded_prettier = 1
