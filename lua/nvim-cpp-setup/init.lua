local M = {}

-- Default configuration
local default_config = {
	code_width_percent = 0.8, -- 80% width for code
	io_height_percent = 0.5, -- 50% height for input panel
	input_filename = "input.txt",
	output_filename = "output.txt",
	-- Command for Linux systems
	compile_command_linux = "g++ -std=c++17 -Wall % -o %< && ./%< < {input} > {output}",
	-- Command for Windows systems
	compile_command_win = "g++ -std=c++17 -Wall % -o %< && %< < {input} > {output}",
}

function M.setup(user_config)
	-- Merge user config with defaults
	local config = vim.tbl_deep_extend("force", default_config, user_config or {})

	-- Determine which compile command to use based on OS
	if vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
		config.compile_command = config.compile_command_win
	else
		config.compile_command = config.compile_command_linux
	end

	-- Setup autocmd for layout
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "cpp",
		callback = function()
			-- Only setup for normal C++ buffers
			if vim.bo.buftype ~= "" then
				return
			end

			-- First, get the current window (cpp file)
			local cpp_win = vim.api.nvim_get_current_win()
			local cpp_buf = vim.api.nvim_win_get_buf(cpp_win)

			-- Get editor dimensions
			local editor_width = vim.o.columns
			local editor_height = vim.o.lines

			-- Calculate dimensions
			local code_width = math.floor(editor_width * config.code_width_percent)
			local io_width = editor_width - code_width

			-- Resize current window (cpp code window) to take up the left side
			vim.api.nvim_win_set_width(cpp_win, code_width)

			-- Create vertical split for IO panel (right side)
			vim.cmd("vsplit")
			local right_win = vim.api.nvim_get_current_win()

			-- Open input.txt in the right panel
			local input_path = vim.fn.fnamemodify(config.input_filename, ":p")
			vim.cmd("edit " .. vim.fn.fnameescape(input_path))
			local input_buf = vim.api.nvim_get_current_buf()
			vim.api.nvim_buf_set_option(input_buf, "filetype", "text")

			-- Split the right panel horizontally for output.txt
			vim.cmd("split")
			local output_win = vim.api.nvim_get_current_win()

			-- Open output.txt in the bottom right panel
			local output_path = vim.fn.fnamemodify(config.output_filename, ":p")
			vim.cmd("edit " .. vim.fn.fnameescape(output_path))
			local output_buf = vim.api.nvim_get_current_buf()
			vim.api.nvim_buf_set_option(output_buf, "filetype", "text")

			-- Set equal height for input and output windows
			vim.cmd("wincmd =")

			-- Return focus to code window
			vim.api.nvim_set_current_win(cpp_win)

			-- Apply specific window configurations
			vim.api.nvim_win_set_option(right_win, "number", true)
			vim.api.nvim_win_set_option(output_win, "number", true)
			vim.api.nvim_win_set_option(cpp_win, "number", true)
		end,
	})

	-- Setup F5 keybinding
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "cpp",
		callback = function()
			vim.keymap.set("n", "<F5>", function()
				-- Save all files first
				vim.cmd("wa")

				-- Get absolute file paths
				local cpp_file = vim.fn.expand("%:p")
				local cpp_file_base = vim.fn.expand("%:p:r")
				local input_file = vim.fn.fnamemodify(config.input_filename, ":p")
				local output_file = vim.fn.fnamemodify(config.output_filename, ":p")

				-- Build command with proper substitutions
				local cmd = config.compile_command
					:gsub("%%", cpp_file)
					:gsub("%%<", cpp_file_base)
					:gsub("{input}", input_file)
					:gsub("{output}", output_file)

				-- Show compilation message
				vim.notify("Compiling and running...", vim.log.levels.INFO)

				-- Execute compilation and run
				vim.fn.jobstart(cmd, {
					on_exit = function(_, exit_code)
						if exit_code == 0 then
							-- Refresh all buffers
							vim.cmd("checktime")

							-- Find the output buffer and reload it
							for _, buf in ipairs(vim.api.nvim_list_bufs()) do
								local buf_name = vim.api.nvim_buf_get_name(buf)
								if buf_name:match(output_file .. "$") then
									-- Force reload the buffer
									vim.cmd("silent! e! " .. vim.fn.fnameescape(buf_name))
									break
								end
							end

							vim.notify("Compilation successful!", vim.log.levels.INFO)
						else
							vim.notify("Compilation failed!", vim.log.levels.ERROR)
						end
					end,
				})
			end, { buffer = true, desc = "Compile and run C++ code" })
		end,
	})
end

return M
