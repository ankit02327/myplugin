local M = {}

local default_config = {
	code_width_percent = 0.8, -- 80% width for code
	input_height_percent = 0.1, -- 10% height for input
	output_height_percent = 0.1, -- 10% height for output
	input_filename = "input.txt",
	output_filename = "output.txt",
	compile_command = "g++ -std=c++17 -Wall % -o %< && ./%< < {input} > {output}",
}

function M.setup(user_config)
	local config = vim.tbl_deep_extend("force", default_config, user_config or {})

	vim.api.nvim_create_autocmd("FileType", {
		pattern = "cpp",
		callback = function()
			if vim.bo.buftype ~= "" or vim.bo.filetype ~= "cpp" then
				return
			end

			-- Save current window
			local cpp_win = vim.api.nvim_get_current_win()
			local cpp_buf = vim.api.nvim_win_get_buf(cpp_win)

			-- Calculate dimensions
			local code_width = math.floor(vim.o.columns * config.code_width_percent)
			local io_width = vim.o.columns - code_width
			local input_height = math.floor(vim.o.lines * config.input_height_percent)
			local output_height = math.floor(vim.o.lines * config.output_height_percent)

			-- Create vertical split for IO panel
			vim.cmd("vsplit")
			local io_win = vim.api.nvim_get_current_win()
			vim.api.nvim_win_set_width(io_win, io_width)

			-- Open input.txt in top-right
			vim.cmd("edit " .. config.input_filename)
			local input_win = vim.api.nvim_get_current_win()
			local input_buf = vim.api.nvim_win_get_buf(input_win)
			vim.api.nvim_win_set_height(input_win, input_height)

			-- Open output.txt in bottom-right
			vim.cmd("edit " .. config.output_filename)
			local output_win = vim.api.nvim_get_current_win()
			local output_buf = vim.api.nvim_win_get_buf(output_win)
			vim.api.nvim_win_set_height(output_win, output_height)

			-- Set filetypes
			vim.api.nvim_buf_set_option(input_buf, "filetype", "text")
			vim.api.nvim_buf_set_option(output_buf, "filetype", "text")

			-- Return to code window
			vim.api.nvim_set_current_win(cpp_win)
			vim.api.nvim_win_set_width(cpp_win, code_width)
		end,
	})

	-- F5 keybinding (same robust implementation as before)
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "cpp",
		callback = function()
			vim.keymap.set("n", "<F5>", function()
				local input_path = vim.fn.expand(config.input_filename .. ":p")
				local output_path = vim.fn.expand(config.output_filename .. ":p")

				local cmd = config.compile_command
					:gsub("%%", vim.fn.expand("%:p"))
					:gsub("%%<", vim.fn.expand("%:r"))
					:gsub("{input}", input_path)
					:gsub("{output}", output_path)

				vim.cmd("wa")
				local success, _ = pcall(vim.cmd, "silent !" .. cmd)
				if not success then
					vim.notify("Compilation failed!", vim.log.levels.ERROR)
				end
				vim.cmd("e " .. output_path)
				vim.cmd("wincmd h")
			end, { buffer = true })
		end,
	})
end

return M
