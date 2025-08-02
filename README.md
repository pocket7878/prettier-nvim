# prettier-nvim

A Neovim plugin that provides Prettier formatting functionality for your code. This plugin automatically finds local Prettier installations and formats your buffers using them.

## Features

- **Local Prettier Detection**: Automatically resolves and uses local `node_modules/.bin/prettier` installations
- **Synchronous and Asynchronous Formatting**: Choose between sync and async formatting modes
- **Built-in Commands**: Pre-defined commands for easy formatting and debugging
- **File Type Support**: Works with any file type supported by Prettier (JavaScript, TypeScript, JSON, CSS, HTML, etc.)
- **Error Handling**: Comprehensive error reporting and graceful failure handling

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "pocket7878/prettier-nvim",
}
```

Using [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use "pocket7878/prettier-nvim"
```

## Usage

### Built-in Commands

The plugin provides the following commands out of the box:

- `:Prettier` - Format current buffer synchronously
- `:PrettierAsync` - Format current buffer asynchronously
- `:PrettierCliPath` - Show the resolved Prettier CLI path
- `:PrettierCliVersion` - Show the Prettier CLI version

### Custom Configuration

You can create custom commands and autocommands for more advanced usage:

```lua
local prettier = require("prettier")

-- Custom format command
vim.api.nvim_create_user_command("FormatFile", function()
    prettier.format_buffer_sync(vim.api.nvim_get_current_buf())
end, {})

-- Format on save for specific file types
vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function(args)
    local ft = vim.bo[args.buf].filetype
    if ft == "typescript"
      or ft == "javascript"
      or ft == "typescriptreact"
      or ft == "javascriptreact"
      or ft == "json"
      or ft == "css"
      or ft == "scss"
      or ft == "html" then
      prettier.format_buffer_sync(args.buf)
    end
  end,
})
```

### Resolver Usage

You can also use the resolver directly to check Prettier availability:

```lua
local resolver = require("prettier.resolver")

-- Check if Prettier is available for current buffer
local cli_path = resolver.resolve_cli_path_for_buffer(vim.api.nvim_get_current_buf())
if cli_path then
    print("Prettier found at: " .. cli_path)
else
    print("No local Prettier installation found")
end
```

## API Reference

### prettier.format_buffer_sync(bufnr)

Formats the specified buffer synchronously using Prettier.

- `bufnr`: Buffer number to format
- Returns: `boolean` - `true` if formatting succeeded, `false` otherwise

### prettier.format_buffer_async(bufnr)

Formats the specified buffer asynchronously using Prettier.

- `bufnr`: Buffer number to format
- Returns: `nil` (async operation)

### prettier.prettier_cli_version(bufnr)

Gets the version of the Prettier CLI for the specified buffer.

- `bufnr`: Buffer number to check
- Returns: `string|nil` - Version string or `nil` if unavailable

### prettier.resolver.resolve_cli_path_for_buffer(bufnr)

Resolves the Prettier CLI path for the specified buffer by traversing up the directory tree to find `node_modules/.bin/prettier`.

- `bufnr`: Buffer number to resolve for
- Returns: `string|nil` - Path to Prettier CLI or `nil` if not found

## How It Works

1. **Path Resolution**: The plugin traverses up from the current file's directory to find the nearest `node_modules/.bin/prettier` executable
2. **Formatting**: Uses `--stdin-filepath` option to format content while preserving file-specific Prettier configurations
3. **Diff Detection**: Only updates the buffer if the formatted content differs from the original
4. **Error Handling**: Provides clear error messages for common issues like missing Prettier installations or formatting errors

## Requirements

- Neovim 0.7+
- A local Prettier installation in your project (`npm install prettier` or `npm install -D prettier`)

## License

Apache License 2.0

