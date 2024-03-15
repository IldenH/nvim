return {
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		config = function()
			require("ibl").setup({
				indent = {
					char = "▍",
					smart_indent_cap = true,
				},
				scope = {
					enabled = true,
					show_start = false,
					show_end = false,
				}
			})
		end,
	},
}
