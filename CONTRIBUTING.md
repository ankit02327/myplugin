# Contribution Guide 🤝

Thank you for considering contributing to the C++ Runner for Neovim! This guide will help you get started with the development workflow and outline our expectations.

## Prerequisites ✅

Before you begin, ensure you have:

- Neovim 0.8+ installed
- Basic Lua knowledge (for plugin changes)
- g++ compiler (for testing C++ functionality)
- Git installed and configured

## Development Workflow 🔄

### 1. Setup

1. **Fork the repository** by clicking the Fork button in the top right corner of the repository page.

2. **Clone your fork locally**:

   ```bash
   git clone https://github.com/YOUR_USERNAME/neovim-cpp-runner.git
   cd neovim-cpp-runner
   ```

3. **Add the original repository as an upstream remote**:
   ```bash
   git remote add upstream https://github.com/ankit02327/neovim-cpp-runner.git
   ```

### 2. Create a Branch

Create a branch with a descriptive name for your changes:

```bash
git checkout -b type/short-description
```

Where `type` can be:

- `feature/` - New functionality
- `fix/` - Bug fixes
- `docs/` - Documentation updates
- `refactor/` - Code refactoring
- `test/` - Adding or improving tests

### 3. Make Your Changes

1. **Modify the code** according to your feature or fix.

2. **Test your changes thoroughly**:

   ```bash
   # Start Neovim with only this plugin loaded
   nvim --noplugin -u test/minimal_init.lua

   # Or use a test C++ file
   nvim test/example.cpp
   ```

3. **Commit your changes** with a clear and descriptive message:
   ```bash
   git add .
   git commit -m "fix: resolve issue with input window sizing"
   ```

### 4. Submit a Pull Request

1. **Push your branch** to your fork:

   ```bash
   git push origin type/short-description
   ```

2. **Create a Pull Request** from your branch to the main repository's `main` branch.

3. **Include in your PR description**:
   - A clear explanation of what your changes do
   - Reference to any related issues (e.g., "Fixes #123")
   - Screenshots if you've made UI changes
   - Any new dependencies or requirements introduced

## Code Style Guidelines 📝

To maintain code quality and consistency:

- Use 2-space indentation in Lua files
- Follow existing naming conventions:
  - `snake_case` for variables and functions
  - `PascalCase` for classes
- Keep functions small and focused
- Add comments for complex logic
- Document public functions with docstrings:
  ```lua
  --- Opens the input window
  -- @param opts table Options for configuring the window
  -- @return nil
  local function open_input_window(opts)
    -- function code
  end
  ```

## Testing 🧪

- Add tests for new functionality if possible
- Ensure existing tests pass with your changes
- Test your changes on different operating systems if applicable

## Documentation 📚

- Update the README.md if you've added or changed functionality
- Add comments to explain complex code
- Keep the documentation up to date with code changes

## Review Process 👀

After submitting your PR:

1. Maintainers will review your code
2. CI checks will run automatically
3. You may need to make requested changes
4. Once approved, your PR will be merged

## Getting Help 💬

If you need help at any stage of the contribution process:

- Ask questions in GitHub Discussions
- Open an issue for technical problems
- Comment on your PR if you're stuck

## Code of Conduct 🌈

Please note that this project follows a Code of Conduct. By participating, you are expected to uphold this code.

---

Thank you for contributing to make C++ Runner for Neovim better for everyone! ❤️
