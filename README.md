# Neovim C++ Setup

This plugin automatically configures a productive C++ development environment in Neovim by creating a layout with code, input, and output windows.

## Features

- Automatic layout creation when opening `.cpp` files
- Configurable window sizes
- Dedicated input/output buffers

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "ankit02327/neovim-cpp-setup",
  config = function()
    require("nvim-cpp-setup").setup({
      code_window_height = 30,  -- default: 25
      side_window_width = 45,   -- default: 40
      input_filename = "input.txt",
      output_filename = "output.txt"
    })
  end
}
```
