local M = {}

local default_config = {
	-- Pixel-perfect layout configuration
	layout = {
		code = {
			width_percent = 0.8, -- 80% width
			height_percent = 1.0, -- Full height
			row = 0, -- Top edge
			col = 0, -- Left edge
		},
		io_panel = {
			width_percent = 0.2, -- 20% width
			height_percent = 0.2, -- 20% total height (10% input + 10% output)
			row = 0, -- Top edge
			col = 0.8, -- Starts at 80% from left
		},
	},
	filenames = {
		input = "input.txt",
		output = "output.txt",
	},
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

			local screen_width = vim.o.columns
			local screen_height = vim.o.lines

			-- Main code window (left 80%)
			local code_win = vim.api.nvim_get_current_win()
			vim.api.nvim_win_set_config(code_win, {
				relative = "editor",
				width = math.floor(screen_width * config.layout.code.width_percent),
				height = screen_height,
				row = 0,
				col = 0,
				focusable = true,
			})

			-- Calculate IO panel dimensions
			local io_width = math.floor(screen_width * config.layout.io_panel.width_percent)
			local io_height = math.floor(screen_height * config.layout.io_panel.height_percent)
			local io_col = math.floor(screen_width * config.layout.io_panel.col)

			-- Input window (top half of IO panel)
			vim.cmd("vsplit") -- Split vertically to the right
			vim.cmd("wincmd l") -- Move to the new window
			vim.cmd("edit " .. config.filenames.input)
			local input_win = vim.api.nvim_get_current_win()
			vim.api.nvim_win_set_config(input_win, {
				relative = "editor",
				width = io_width,
				height = math.floor(io_height / 2), -- Exactly half height
				row = 0,
				col = io_col,
				focusable = true,
			})

			-- Output window (bottom half of IO panel)
			vim.cmd("split") -- Split horizontally below the current window (input)
			vim.cmd("edit " .. config.filenames.output)
			local output_win = vim.api.nvim_get_current_win()
			vim.api.nvim_win_set_config(output_win, {
				relative = "editor",
				width = io_width,
				height = math.floor(io_height / 2), -- Exactly half height
				row = math.floor(io_height / 2), -- Starts right below input
				col = io_col,
				focusable = true,
			})

			-- Configure buffers
			vim.api.nvim_buf_set_option(vim.api.nvim_win_get_buf(input_win), "filetype", "text")
			vim.api.nvim_buf_set_option(vim.api.nvim_win_get_buf(output_win), "filetype", "text")

			-- Return focus to code window
			vim.api.nvim_set_current_win(code_win)
		end,
	})

	-- F5 Compilation keybinding (unchanged)
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "cpp",
		callback = function()
			vim.keymap.set("n", "<F5>", function()
				local input_path = vim.fn.expand(config.filenames.input .. ":p")
				local output_path = vim.fn.expand(config.filenames.output .. ":p")
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
