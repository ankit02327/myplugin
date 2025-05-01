local M = {}

-- Default configuration
local default_config = {
	code_window_height = 25,
	side_window_width = 40,
	input_filename = "input.txt",
	output_filename = "output.txt",
}

function M.setup(user_config)
	-- Merge user config with defaults
	local config = vim.tbl_deep_extend("force", default_config, user_config or {})

	vim.api.nvim_create_autocmd("FileType", {
		pattern = "cpp",
		callback = function()
			-- Only proceed if we're in the main cpp buffer (not in a help window, etc.)
			if vim.bo.buftype ~= "" then
				return
			end

			-- Save current window to return to later
			local current_win = vim.api.nvim_get_current_win()

			-- Create vertical split for input file
			vim.cmd("vsplit " .. config.input_filename)
			local input_win = vim.api.nvim_get_current_win()

			-- Create vertical split for output file
			vim.cmd("vsplit " .. config.output_filename)
			local output_win = vim.api.nvim_get_current_win()

			-- Resize windows
			vim.api.nvim_win_set_width(input_win, config.side_window_width)
			vim.api.nvim_win_set_width(output_win, config.side_window_width)
			vim.api.nvim_set_current_win(current_win)
			vim.api.nvim_win_set_height(current_win, config.code_window_height)

			-- Set filetypes for the new buffers
			vim.api.nvim_buf_set_option(vim.api.nvim_win_get_buf(input_win), "filetype", "text")
			vim.api.nvim_buf_set_option(vim.api.nvim_win_get_buf(output_win), "filetype", "text")
		end,
	})
end

-- Automatically call setup when the module is required
M.setup()

return M
