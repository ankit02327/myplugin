local M = {}

local default_config = {
	code_width_percent = 0.8, -- 80% width for code area
	io_panel_height = 0.2, -- 20% total height for IO (10% input + 10% output)
	input_filename = "input.txt",
	output_filename = "output.txt",
	compile_command = "g++ -std=c++17 -Wall % -o %< && ./%< < {input} > {output}",
}

function M.setup(user_config)
	local config = vim.tbl_deep_extend("force", default_config, user_config or {})

	vim.api.nvim_create_autocmd("FileType", {
		pattern = "cpp",
		callback = function()
			-- Only proceed for normal C++ file buffers
			if vim.bo.buftype ~= "" or vim.bo.filetype ~= "cpp" then
				return
			end

			-- Save initial window and buffer
			local cpp_win = vim.api.nvim_get_current_win()
			local cpp_buf = vim.api.nvim_win_get_buf(cpp_win)

			-- Calculate dimensions
			local screen_width = vim.o.columns
			local screen_height = vim.o.lines
			local code_width = math.floor(screen_width * config.code_width_percent)
			local io_width = screen_width - code_width
			local io_height = math.floor(screen_height * config.io_panel_height)
			local input_height = math.floor(io_height / 2)
			local output_height = io_height - input_height

			-- Create vertical split for IO panel
			vim.cmd("vsplit")
			local io_panel_win = vim.api.nvim_get_current_win()

			-- Open input.txt in top part of IO panel
			vim.cmd("edit " .. config.input_filename)
			local input_win = vim.api.nvim_get_current_win()
			local input_buf = vim.api.nvim_win_get_buf(input_win)

			-- Create split for output.txt in bottom part
			vim.cmd("split " .. config.output_filename)
			local output_win = vim.api.nvim_get_current_win()
			local output_buf = vim.api.nvim_win_get_buf(output_win)

			-- Apply window sizes (order matters!)
			vim.api.nvim_win_set_width(io_panel_win, io_width) -- First set IO panel width
			vim.api.nvim_win_set_height(input_win, input_height) -- Then input height
			vim.api.nvim_win_set_height(output_win, output_height) -- Then output height
			vim.api.nvim_win_set_width(cpp_win, code_width) -- Finally adjust main window

			-- Configure buffers
			vim.api.nvim_buf_set_option(input_buf, "filetype", "text")
			vim.api.nvim_buf_set_option(output_buf, "filetype", "text")

			-- Return focus to code window
			vim.api.nvim_set_current_win(cpp_win)
		end,
	})

	-- Setup F5 compilation keybinding
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "cpp",
		callback = function()
			vim.keymap.set("n", "<F5>", function()
				-- Get absolute paths
				local input_path = vim.fn.expand(config.input_filename .. ":p")
				local output_path = vim.fn.expand(config.output_filename .. ":p")

				-- Build command with proper substitutions
				local cmd = config
					.compile_command
					:gsub("%%", vim.fn.expand("%:p")) -- Current file path
					:gsub("%%<", vim.fn.expand("%:r")) -- Filename without extension
					:gsub("{input}", input_path) -- Input file path
					:gsub("{output}", output_path) -- Output file path

				-- Save all files first
				vim.cmd("wa")

				-- Execute compilation and handle errors
				local success, _ = pcall(vim.cmd, "silent !" .. cmd)
				if not success then
					vim.notify("Compilation failed!", vim.log.levels.ERROR)
					return
				end

				-- Refresh output file
				vim.cmd("edit " .. output_path)

				-- Return focus to code window
				vim.cmd("wincmd h")
			end, { buffer = true })
		end,
	})
end

return M
