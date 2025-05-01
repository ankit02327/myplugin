local M = {}

function M.setup()
	vim.api.nvim_create_autocmd("BufReadPost", {
		pattern = "*.cpp",
		callback = function()
			-- Get the current buffer name
			local current_buf = vim.api.nvim_get_current_buf()

			-- Open input.txt and output.txt in vertical splits
			vim.cmd("vsplit input.txt")
			vim.cmd("wincmd l")
			vim.cmd("vsplit output.txt")

			-- Resize windows
			vim.cmd("wincmd h")
			vim.cmd("resize 25") -- main code area taller
			vim.cmd("wincmd l")
			vim.cmd("vertical resize 40") -- input.txt
			vim.cmd("wincmd l")
			vim.cmd("vertical resize 40") -- output.txt

			-- Go back to code window
			vim.cmd("wincmd h")
		end,
	})
end

return M
