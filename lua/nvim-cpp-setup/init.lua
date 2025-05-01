local M = {}

local default_config = {
	code_width = 0.8, -- 80% width for code
	input_height = 0.1, -- 10% height for input
	output_height = 0.1, -- 10% height for output
	input_file = "input.txt",
	output_file = "output.txt",
	compile_cmd = "g++ -std=c++17 -Wall % -o %< && ./%< < {input} > {output}",
}

function M.setup(user_config)
	local config = vim.tbl_deep_extend("force", default_config, user_config or {})

	vim.api.nvim_create_autocmd("FileType", {
		pattern = "cpp",
		callback = function()
			if vim.bo.buftype ~= "" or vim.bo.filetype ~= "cpp" then
				return
			end

			-- Save original window and dimensions
			local code_win = vim.api.nvim_get_current_win()
			local screen_width = vim.o.columns
			local screen_height = vim.o.lines

			-- Open input file in new window (no split command)
			vim.cmd("edit " .. config.input_file)
			local input_win = vim.api.nvim_get_current_win()
			local input_buf = vim.api.nvim_win_get_buf(input_win)

			-- Open output file in new window (no split command)
			vim.cmd("edit " .. config.output_file)
			local output_win = vim.api.nvim_get_current_win()
			local output_buf = vim.api.nvim_win_get_buf(output_win)

			-- Now apply all resizing (after all files are open)
			local code_width = math.floor(screen_width * config.code_width)
			local io_width = screen_width - code_width

			-- Position and resize windows
			vim.api.nvim_win_set_width(input_win, io_width)
			vim.api.nvim_win_set_height(input_win, math.floor(screen_height * config.input_height))

			vim.api.nvim_win_set_width(output_win, io_width)
			vim.api.nvim_win_set_height(output_win, math.floor(screen_height * config.output_height))

			-- Finally adjust main window
			vim.api.nvim_win_set_width(code_win, code_width)

			-- Configure buffers
			vim.api.nvim_buf_set_option(input_buf, "filetype", "text")
			vim.api.nvim_buf_set_option(output_buf, "filetype", "text")

			-- Return focus to code
			vim.api.nvim_set_current_win(code_win)
		end,
	})

	-- F5 keybinding
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "cpp",
		callback = function()
			vim.keymap.set("n", "<F5>", function()
				local input = vim.fn.expand(config.input_file .. ":p")
				local output = vim.fn.expand(config.output_file .. ":p")
				local cmd = config.compile_cmd
					:gsub("%%", vim.fn.expand("%:p"))
					:gsub("%%<", vim.fn.expand("%:r"))
					:gsub("{input}", input)
					:gsub("{output}", output)

				vim.cmd("wa") -- Save all files
				local success, _ = pcall(vim.cmd, "silent !" .. cmd)
				if not success then
					vim.notify("Compilation failed!", vim.log.levels.ERROR)
				end
				vim.cmd("e " .. output) -- Refresh output
				vim.cmd("wincmd h") -- Return to code
			end, { buffer = true })
		end,
	})
end

return M
