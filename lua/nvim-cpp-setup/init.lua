local M = {}

-- Default configuration
local default_config = {
	code_width_percent = 0.8, -- 80% width for code
	io_height_percent = 0.5, -- 50% height for input panel
	input_filename = "input.txt",
	output_filename = "output.txt",
	compile_command = "g++ -std=c++17 -Wall % -o %< && ./%< < {input} > {output}",
}

function M.setup(user_config)
	-- Merge user config with defaults
	local config = vim.tbl_deep_extend("force", default_config, user_config or {})

	-- Setup autocmd for layout
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "cpp",
		callback = function()
			-- Only setup for normal C++ buffers
			if vim.bo.buftype ~= "" then
				return
			end

			-- Save current window and buffer (cpp file)
			local cpp_win = vim.api.nvim_get_current_win()

			-- Get editor dimensions
			local editor_width = vim.o.columns
			local editor_height = vim.o.lines

			-- Calculate dimensions
			local code_width = math.floor(editor_width * config.code_width_percent)
			local io_width = editor_width - code_width
			local input_height = math.floor(editor_height * config.io_height_percent)
			local output_height = editor_height - input_height

			-- Resize current window (cpp code window)
			vim.api.nvim_win_set_width(cpp_win, code_width)

			-- Create vertical split for IO panel (right side)
			vim.cmd("vsplit")
			local io_win = vim.api.nvim_get_current_win()

			-- Open input.txt in top half
			local input_path = vim.fn.fnamemodify(config.input_filename, ":p")
			vim.cmd("edit " .. vim.fn.fnameescape(input_path))
			local input_buf = vim.api.nvim_get_current_buf()

			-- Create split for output.txt in bottom half
			vim.cmd("split")
			local output_win = vim.api.nvim_get_current_win()
			local output_path = vim.fn.fnamemodify(config.output_filename, ":p")
			vim.cmd("edit " .. vim.fn.fnameescape(output_path))
			local output_buf = vim.api.nvim_get_current_buf()

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

				-- Execute compilation and run
				vim.fn.jobstart(cmd, {
					on_exit = function(_, exit_code)
						if exit_code == 0 then
							-- Refresh output file buffer
							vim.cmd("checktime")

							-- Find and focus the output window
							for _, win in ipairs(vim.api.nvim_list_wins()) do
								local buf = vim.api.nvim_win_get_buf(win)
								local buf_name = vim.api.nvim_buf_get_name(buf)
								if buf_name:match(output_file .. "$") then
									vim.api.nvim_win_set_buf(win, buf)
									vim.cmd("checktime")
									-- Go back to code window
									vim.cmd("wincmd h")
									break
								end
							end
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
