# prettier-nvim

NeoVim plugin to format buffer by prettier.

## Usage

You could define custom commands like this:

```lua
local prettier_resolver = require("prettier.resolver")
local prettier = require("prettier")

vim.api.nvim_create_user_command("PrettierCliPath", function ()
    local bin = prettier_resolver.resolve_cli_path_for_current_buffer()
    if bin then
        vim.notify("Prettier resolved to: " .. bin, vim.log.levels.INFO)
    else
        vim.notify("No local prettier found", vim.log.levels.WARN)
    end
end, {})

vim.api.nvim_create_user_command("Prettier", function()
    prettier.format_current_buffer_sync()
end, {})

vim.api.nvim_create_user_command("PrettierAsync", function()
    prettier.format_current_buffer_async()
end, {})
```


Or you could apply format before save:

```lua
vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function(args)
    local ft = vim.bo[args.buf].filetype
    if ft == "typescript"
      or ft == "javascript"
      or ft == "typescriptreact"
      or ft == "json" then
      require("prettier").format_current_buffer_sync()
    end
  end,
})
```
