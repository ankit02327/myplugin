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
		input = {
			width_percent = 0.2, -- 20% width
			height_percent = 0.1, -- 10% height
			row = 0, -- Top edge
			col = 0.8, -- Starts at 80% from left
		},
		output = {
			width_percent = 0.2, -- 20% width
			height_percent = 0.1, -- 10% height
			row = 0.1, -- 10% from top
			col = 0.8, -- Same column as input
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

			-- Calculate absolute pixel dimensions
			local function calc_dimensions(spec)
				return {
					width = math.floor(screen_width * spec.width_percent),
					height = math.floor(screen_height * spec.height_percent),
					row = math.floor(screen_height * spec.row),
					col = math.floor(screen_width * spec.col),
				}
			end

			-- Main code window (left 80%)
			local code_win = vim.api.nvim_get_current_win()
			local code_dims = calc_dimensions(config.layout.code)
			vim.api.nvim_win_set_config(code_win, {
				relative = "editor",
				width = code_dims.width,
				height = code_dims.height,
				row = code_dims.row,
				col = code_dims.col,
				focusable = true,
			})

			-- Input window (top-right)
			vim.cmd("edit " .. config.filenames.input)
			local input_win = vim.api.nvim_get_current_win()
			local input_dims = calc_dimensions(config.layout.input)
			vim.api.nvim_win_set_config(input_win, {
				relative = "editor",
				width = input_dims.width,
				height = input_dims.height,
				row = input_dims.row,
				col = input_dims.col,
				focusable = true,
			})

			-- Output window (bottom-right)
			vim.cmd("edit " .. config.filenames.output)
			local output_win = vim.api.nvim_get_current_win()
			local output_dims = calc_dimensions(config.layout.output)
			vim.api.nvim_win_set_config(output_win, {
				relative = "editor",
				width = output_dims.width,
				height = output_dims.height,
				row = output_dims.row,
				col = output_dims.col,
				focusable = true,
			})

			-- Configure buffers
			vim.api.nvim_buf_set_option(vim.api.nvim_win_get_buf(input_win), "filetype", "text")
			vim.api.nvim_buf_set_option(vim.api.nvim_win_get_buf(output_win), "filetype", "text")

			-- Return focus to code window
			vim.api.nvim_set_current_win(code_win)
		end,
	})

	-- F5 Compilation keybinding
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

				vim.cmd("wa") -- Save all files
				local success, _ = pcall(vim.cmd, "silent !" .. cmd)
				if not success then
					vim.notify("Compilation failed!", vim.log.levels.ERROR)
				end
				vim.cmd("e " .. output_path) -- Refresh output
				vim.cmd("wincmd h") -- Return to code window
			end, { buffer = true })
		end,
	})
end

return M
