local M = {}

-- Default configuration
local default_config = {
	code_width_percent = 0.8, -- 80% of screen width
	io_height_percent = 0.5, -- 50% of right panel height
	input_filename = "input.txt",
	output_filename = "output.txt",
	compile_command = "g++ % -o %< && ./%< < %s > %s",
}

function M.setup(user_config)
	-- Merge user config with defaults
	local config = vim.tbl_deep_extend("force", default_config, user_config or {})

	-- Setup autocmd for layout
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "cpp",
		callback = function()
			if vim.bo.buftype ~= "" or vim.bo.filetype ~= "cpp" then
				return
			end

			local width = vim.o.columns
			local height = vim.o.lines
			local code_width = math.floor(width * config.code_width_percent)
			local io_width = width - code_width

			-- Save current window (cpp file)
			local cpp_win = vim.api.nvim_get_current_win()

			-- Create vertical split for IO panel
			vim.cmd("vsplit")
			local io_win = vim.api.nvim_get_current_win()
			vim.api.nvim_win_set_width(io_win, io_width)

			-- Create horizontal split in IO panel (input.txt)
			vim.cmd("split " .. config.input_filename)
			local input_win = vim.api.nvim_get_current_win()
			local input_buf = vim.api.nvim_win_get_buf(input_win)

			-- Create output window (output.txt)
			vim.cmd("split " .. config.output_filename)
			local output_win = vim.api.nvim_get_current_win()
			local output_buf = vim.api.nvim_win_get_buf(output_win)

			-- Resize windows
			local io_height = math.floor(height * config.io_height_percent)
			vim.api.nvim_win_set_height(input_win, io_height)

			-- Set filetypes
			vim.api.nvim_buf_set_option(input_buf, "filetype", "text")
			vim.api.nvim_buf_set_option(output_buf, "filetype", "text")

			-- Return to code window
			vim.api.nvim_set_current_win(cpp_win)
		end,
	})

	-- Setup F5 keybinding
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "cpp",
		callback = function()
			vim.keymap.set("n", "<F5>", function()
				local input_file = config.input_filename
				local output_file = config.output_filename
				local cmd = string.gsub(config.compile_command, "%%s", input_file)
				cmd = string.gsub(cmd, "%%s", output_file)
				vim.cmd("w") -- Save current file
				vim.cmd("silent !" .. cmd)
				vim.cmd("e " .. output_file) -- Refresh output file
			end, { buffer = true })
		end,
	})
end

return M
