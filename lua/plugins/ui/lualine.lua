return {
	{
		"nvim-lualine/lualine.nvim",
		config = function()
			require("lualine").setup({
				options = {
					-- section_separators = { right = "", left = " " },
					section_separators = { right = "", left = "" },
					component_separators = { right = "", left = "" }
				},
				sections = {
					lualine_a = { { 'mode', fmt = function(str) return str:sub(1,1):upper()..str:sub(2):lower() end } }
				},
				extensions = {
					"nvim-tree"
				},
			})
		end,
	}
}
