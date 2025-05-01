# nvim-cpp-setup

Professional C++ development environment for Neovim with integrated input/output workflow

## Features

- 🚀 **Smart Workspace Layout**
  - 80% width for code editing (left)
  - 20% width split vertically for:
    - `input.txt` (top-right)
    - `output.txt` (bottom-right)
- ⚡ **One-Key Execution** (`<F5>`)

  - Compiles and runs current C++ file
  - Automatically pipes input from `input.txt`
  - Displays results in `output.txt`
  - Preserves your working directory

- 🛠️ **Fully Configurable**
  - Adjustable split percentages
  - Customizable file names
  - Flexible compilation command

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "ankit02327/nvim-cpp-setup",
  ft = "cpp", -- Only loads for C++ files
  config = function()
    require("nvim-cpp-setup").setup({
      -- Customize these as needed:
      code_width_percent = 0.8,  -- 80% for code area
      io_height_percent = 0.5,   -- 50% split for input/output
      input_filename = "input.txt",
      output_filename = "output.txt",
      compile_command = "g++ -std=c++17 -Wall % -o %< && ./%< < %s > %s",
    })
  end
}
```
