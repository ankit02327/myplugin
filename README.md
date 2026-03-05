<img width="1893" height="966" alt="image" src="https://github.com/user-attachments/assets/d80b7b2d-bffc-4398-9780-359280c78109" />

<img width="1890" height="954" alt="image" src="https://github.com/user-attachments/assets/3d83a78e-5313-4abd-b0d5-9ce2022f54b2" />


# C++ Runner for Neovim 🚀

A powerful Neovim plugin that lets you compile and run C++ code with a single keypress, featuring dedicated input/output panes for a seamless development experience.

## ✨ Features

- **Single-key execution** - Press `F5` to instantly compile and run your C++ code
- **Dedicated I/O panels** - Separate panes for inputs and outputs
- **Fully customizable** - Configure window layout, key bindings, and compilation flags
- **Performance optimized** - Minimal overhead for quick testing iterations

## 📦 Installation

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'ankit02327/neovim-cpp-runner',
  config = function()
    require('neovim-cpp-runner').setup()
  end
}
```

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'ankit02327/neovim-cpp-runner',
  config = true,
  lazy = false,
}
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'ankit02327/neovim-cpp-runner'
" In your init.vim, after plug#end():
lua require('neovim-cpp-runner').setup()
```

## 🎯 Usage

1. Open a `.cpp` file in Neovim
2. Edit `input.txt` (left panel) with your test cases
3. Press `F5` to:
   - Compile your code
   - Run with the provided input
   - Display output in `output.txt` (bottom panel)
4. Type the following to exit at once:
   ```sh
   :qa
   ```

## ⚙️ Configuration

The plugin works out of the box with sensible defaults, but you can customize it to suit your needs:

```lua
require('neovim-cpp-runner').setup({
  -- Window layout options
  code_width = 0.8,        -- 80% width for code
  input_height = 0.3,      -- 30% height for input
  output_height = 0.3,     -- 30% height for output

  -- File options
  input_file = "input.txt",
  output_file = "output.txt",

  -- Compilation options
  compile_command = "g++ % -o %< && %< < {input} > {output}",

})
```

## 🔍 Advanced Usage

### Integration with LSP

The plugin works great with C++ LSPs like `clangd` for a complete development environment.

## ✔️ Requirements

- Neovim 0.8+
- g++ compiler
  - Ubuntu/Debian: `sudo apt install g++`
  - macOS: Install via Homebrew with `brew install gcc`
  - Windows: Install MinGW or use WSL

## 🤝 Contributing

Contributions are welcome! Feel free to open issues or submit pull requests.

## 📜 License

MIT © Ankit

---

<p align="center">If you find this plugin useful, consider starring it on GitHub!</p>
