local M = {}

-- Default configuration
local default_config = {
	code_width_percent = 0.8, -- 80% for code
	io_height_percent = 0.5, -- 50% for input/output
	input_filename = "input.txt",
	output_filename = "output.txt",
	compile_command = "g++ % -o %< && ./%< < {input} > {output}",
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

			-- Save current window (C++ file)
			local cpp_win = vim.api.nvim_get_current_win()

			-- Create vertical split for IO panel
			vim.cmd("vsplit")
			local io_win = vim.api.nvim_get_current_win()
			vim.api.nvim_win_set_width(io_win, io_width)

			-- Open input.txt in IO panel (no extra split)
			vim.cmd("edit " .. config.input_filename)
			local input_win = vim.api.nvim_get_current_win()
			local input_buf = vim.api.nvim_win_get_buf(input_win)

			-- Split for output.txt (creates horizontal split)
			vim.cmd("split " .. config.output_filename)
			local output_win = vim.api.nvim_get_current_win()
			local output_buf = vim.api.nvim_win_get_buf(output_win)

			-- Resize IO panel (50% height for input, 50% for output)
			local io_height = math.floor(height * config.io_height_percent)
			vim.api.nvim_win_set_height(input_win, io_height / 2)
			vim.api.nvim_win_set_height(output_win, io_height / 2)

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

				-- Replace placeholders
				local cmd = config
					.compile_command
					:gsub("%%", vim.fn.expand("%")) -- Current file
					:gsub("%%<", vim.fn.expand("%:r")) -- File without extension
					:gsub("{input}", input_file) -- Input file
					:gsub("{output}", output_file) -- Output file

				-- Save all files
				vim.cmd("w")
				vim.cmd("silent !" .. cmd) -- Run command
				vim.cmd("e " .. output_file) -- Refresh output
			end, { buffer = true })
		end,
	})
end

return M
