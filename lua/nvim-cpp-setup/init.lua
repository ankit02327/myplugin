local M = {}

-- Default configuration
local default_config = {
	code_width_percent = 0.8, -- 80% width for code
	io_height_percent = 0.5, -- 50% height for input panel
	input_filename = "input.txt",
	output_filename = "output.txt",
	compile_command = "g++ -std=c++17 -Wall % -o %< && ./%< < %s > %s",
}

function M.setup(user_config)
	-- Merge user config with defaults
	local config = vim.tbl_deep_extend("force", default_config, user_config or {})

	-- Setup autocmd for layout
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "cpp",
		callback = function()
			-- Only setup for normal C++ buffers
			if vim.bo.buftype ~= "" or vim.bo.filetype ~= "cpp" then
				return
			end

			-- Save current window and buffer (cpp file)
			local cpp_win = vim.api.nvim_get_current_win()
			local cpp_buf = vim.api.nvim_win_get_buf(cpp_win)

			-- Create vertical split for IO panel (right side)
			vim.cmd("vsplit")
			local io_win = vim.api.nvim_get_current_win()
			local io_width = math.floor(vim.o.columns * (1 - config.code_width_percent))
			vim.api.nvim_win_set_width(io_win, io_width)

			-- Open input.txt in top half (no new split)
			vim.cmd("edit " .. config.input_filename)
			local input_win = vim.api.nvim_get_current_win()
			local input_buf = vim.api.nvim_win_get_buf(input_win)

			-- Create split for output.txt in bottom half
			vim.cmd("split " .. config.output_filename)
			local output_win = vim.api.nvim_get_current_win()
			local output_buf = vim.api.nvim_win_get_buf(output_win)

			-- Calculate and set window heights
			local io_height = math.floor(vim.o.lines * config.io_height_percent)
			local half_height = math.floor(io_height / 2)
			vim.api.nvim_win_set_height(input_win, half_height)
			vim.api.nvim_win_set_height(output_win, half_height)

			-- Set filetypes
			vim.api.nvim_buf_set_option(input_buf, "filetype", "text")
			vim.api.nvim_buf_set_option(output_buf, "filetype", "text")

			-- Return focus to code window
			vim.api.nvim_set_current_win(cpp_win)
		end,
	})

	-- Setup F5 keybinding
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "cpp",
		callback = function()
			vim.keymap.set("n", "<F5>", function()
				-- Get absolute file paths
				local cpp_file = vim.fn.expand("%:p")
				local input_file = vim.fn.expand(config.input_filename .. ":p")
				local output_file = vim.fn.expand(config.output_filename .. ":p")

				-- Build command with proper substitutions
				local cmd = config
					.compile_command
					:gsub("%%", cpp_file)
					:gsub("%%<", vim.fn.expand("%:r"))
					:gsub("%%s", input_file, 1) -- First replacement for input
					:gsub("%%s", output_file) -- Second replacement for output

				-- Save all files
				vim.cmd("wa")

				-- Execute compilation and redirect output
				vim.cmd("silent !" .. cmd)

				-- Refresh output file
				vim.cmd("e " .. output_file)

				-- Return to code window
				vim.cmd("wincmd h")
			end, { buffer = true })
		end,
	})
end

return M
