local M = {}

-- Default configuration
local default_config = {
	code_width_percent = 0.8, -- 80% of screen width
	io_height_percent = 0.5, -- 50% of right panel height
	input_filename = "input.txt",
	output_filename = "output.txt",
	compile_command = "g++ % -o %< && ./%< < %s > %s",
	-- % = current file, %< = filename without extension
	-- first %s = input file, second %s = output file
}

function M.setup(user_config)
	-- Merge user config with defaults
	local config = vim.tbl_deep_extend("force", default_config, user_config or {})

	-- Calculate window sizes based on current screen size
	local function setup_windows()
		if vim.bo.buftype ~= "" or vim.bo.filetype ~= "cpp" then
			return
		end

		local width = vim.o.columns
		local height = vim.o.lines
		local code_width = math.floor(width * config.code_width_percent)
		local io_width = width - code_width

		-- Save current window
		local cpp_win = vim.api.nvim_get_current_win()

		-- Create vertical split for IO panel
		vim.cmd("vsplit")
		local io_win = vim.api.nvim_get_current_win()
		vim.api.nvim_win_set_width(io_win, io_width)

		-- Create horizontal split in IO panel
		vim.cmd("split")
		local input_win = vim.api.nvim_get_current_win()
		local output_win = vim.api.nvim_get_win_by_id(io_win)

		-- Resize IO windows
		local io_height = math.floor(height * config.io_height_percent)
		vim.api.nvim_win_set_height(input_win, io_height)

		-- Open files
		vim.api.nvim_win_set_buf(input_win, vim.fn.bufadd(config.input_filename))
		vim.api.nvim_win_set_buf(output_win, vim.fn.bufadd(config.output_filename))

		-- Set filetypes
		vim.api.nvim_buf_set_option(vim.api.nvim_win_get_buf(input_win), "filetype", "text")
		vim.api.nvim_buf_set_option(vim.api.nvim_win_get_buf(output_win), "filetype", "text")

		-- Return to code window
		vim.api.nvim_set_current_win(cpp_win)
	end

	-- Setup autocmd for layout
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "cpp",
		callback = setup_windows,
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
