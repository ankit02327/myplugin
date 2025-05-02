local M = {}

local default_configuration = {
	code_width_percentage = 0.8,
	input_height_percentage = 0.5,
	output_height_percentage = 0.5,
	input_file = "input.txt",
	output_file = "output.txt",
	compile_command = "g++ % -o %< && ./%< < {input} > {output}",
}

function M.setup(user_configuration)
	local configuration = vim.tbl_deep_extend("force", default_configuration, user_configuration or {})

	vim.api.nvim_create_autocmd("FileType", {
		pattern = "cpp",
		callback = function()
			if vim.bo.buftype ~= "" or vim.bo.filetype ~= "cpp" then
				return
			end

			local actual_screen_width = vim.o.columns
			local actual_screen_height = vim.o.lines
			local code_width = math.floor(actual_screen_width * configuration.code_width_percentage)
			local input_width = actual_screen_width - code_width
			local output_width = math.floor(actual_screen_height * configuration.output_height_percentage)

			local cpp_window_id = vim.api.nvim_get_current_win()

			local input_buf = vim.fn.bufnr(configuration.input_file)
			if input_buf == -1 then
				vim.cmd("vsplit " .. configuration.input_file)
				local input_window_id = vim.api.nvim_get_current_win()
				vim.api.nvim_win_set_width(input_window_id, input_width)
			end

			local output_buf = vim.fn.bufnr(configuration.output_file)
			if output_buf == -1 then
				-- If output.txt isn't open,/output create the horizontal split
				vim.cmd("split " .. configuration.output_file)
				local output_window_id = vim.api.nvim_get_current_win()
			end

			vim.api.nvim_set_current_win(cpp_window_id)
		end,
	})

	-- Set up F5 keybinding for compiling
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "cpp",
		callback = function()
			vim.keymap.set("n", "<F5>", function()
				local file = vim.fn.expand("%")
				local input = configuration.input_file
				local output = configuration.output_file
				local cmd = configuration.compile_command
				cmd = cmd:gsub("%%", file)
				cmd = cmd:gsub("%%<", vim.fn.expand("%:r"))
				cmd = cmd:gsub("{input}", input)
				cmd = cmd:gsub("{output}", output)

				vim.cmd("w") -- Save file
				vim.cmd("silent !" .. cmd)
				vim.cmd("checktime " .. output) -- Reload output file
			end, { buffer = true })
		end,
	})
end

return M
