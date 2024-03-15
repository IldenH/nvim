local map = vim.keymap.set

local function opts(description)
	return { desc = description, noremap = true, silent = true }
end

local ls = require("luasnip")
local undo_snippet = function()
	local buf = vim.api.nvim_get_current_buf()
	local snip = ls.session.current_nodes[buf].parent.snippet
	local trig = snip.trigger
	local reg = snip:get_buf_position()
	vim.api.nvim_buf_set_text(
		buf,
		reg.from_position[1], reg.from_position[2],
		reg.to_position[1], reg.to_position[2],
		trig
	)
end

local paste_img = function()
	vim.ui.input({ prompt = "Image name (saved to ./images/): " }, function(input) vim.fn.system({ "pngpaste", "./images/" .. input .. ".png" }) end)
end

local wk = require("which-key")
wk.register({
	e = {
		name = "Explorer",
		e = { "<cmd>Telescope file_browser<cr>", "Telescope file browser (?)" },
		f = { "<cmd>NvimTreeFocus<cr>", "Focus Nvim Tree" },
		t = { "<cmd>NvimTreeToggle<cr>", "Toggle Nvim Tree" },
	},
	t = {
		name = "Telescope",
		t = { "<cmd>Telescope find_files<cr>", "Find files in cwd" }, -- Most used
		r = { "<cmd>Telescope oldfiles<cr>", "Find recent files" },
		s = { "<cmd>Telescope live_grep<cr>", "Find string in cwd" },
		c = { "<cmd>Telescope grep_string<cr>", "Find string under cursor in cwd" },
		n = { function() require("telescope").extensions.notify.notify() end, "Show notifications" },
		u = { function() require("telescope").extensions.undo.undo() end, "Show undo tree" },
	},
	s = {
		name = "Sessions",
		o = { "<cmd>SessionManager load_session<cr>", "Open session" },
		l = { "<cmd>SessionManager load_last_session<cr>", "Load last session" },
		c = { "<cmd>SessionManager load_current_dir_session<cr>", "Load session in cwd" },
		d = { "<cmd>SessionManager delete_session<cr>", "Delete sessions" },
		s = { "<cmd>SessionManager save_current_session<cr>", "Save session" },
	},
	m = {
		name = "Misc",
		u = { undo_snippet, "Undo snippet completion" },
		p = { paste_img, "Paste image from clipboard" },
		l = { "<cmd>Lazy<cr>", "Open lazy" },
		m = { "<cmd>Mason<cr>", "Open mason" },
		s = { function() require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/LuaSnip/" }) end, "Reload snippets" },
		a = { "<cmd>Alpha<cr>", "Open dashboard" },
	},
	k = {
		name = "LaTeX", -- TODO: Make this only work for .tex buffers
		c = { "<cmd>VimtexCompile<cr>", "Toggle compiling" },
		v = { "<cmd>VimtexView<cr>", "View output" },
		s = { "<cmd>VimtexStop<cr>", "Stop compiling" },
		e = { "<cmd>VimtexErrors<cr>", "Show errors" },
		S = { "<cmd>VimtexStatus<cr>", "Show status" },
		i = { "<cmd>VimtexInfo<cr>", "Show info" },
		C = { "<cmd>VimtexClean<cr>", "Clean files" },
		o = { "<cmd>VimtexCompileSS<cr>", "Compile once" },
	},
	h = {
		name = "Hop", --BC, AC, CurrentLine suffixes
		h = { "<cmd>HopWord<cr>", "Word" },
		c = { "<cmd>HopCamelCase<cr>", "CamelCase" },
		C = { "<cmd>HopChar1<cr>", "Character" },
		l = { "<cmd>HopLine<cr>", "Line" },
		L = { "<cmd>HopLineStart<cr>", "Line start" },
		a = { "<cmd>HopAnywhere<cr>", "Anywhere" },
	}
}, { prefix = "<leader>" })

-- File
map({ "n", "i" }, "<C-s>", "<cmd>w<cr>", opts("Save file"))
map({ "n", "i" }, "<C-z>", "<cmd>undo<cr>", opts("Undo"))
map({ "n", "i" }, "<C-y>", "<cmd>redo<cr>", opts("Redo"))
map({ "n", "i" }, "<CS-z>", "<cmd>redo<cr>", opts("redo"))

-- Move.nvim
vim.keymap.set("n", "<A-j>", ":MoveLine(1)<CR>", opts("Move line down"))
vim.keymap.set("n", "<A-k>", ":MoveLine(-1)<CR>", opts("Move line up"))
vim.keymap.set("n", "<A-h>", ":MoveHChar(-1)<CR>", opts("Move Char Left"))
vim.keymap.set("n", "<A-l>", ":MoveHChar(1)<CR>", opts("Move char right"))
vim.keymap.set("n", "<leader>wf", ":MoveWord(1)<CR>", opts("Move word right"))
vim.keymap.set("n", "<leader>wb", ":MoveWord(-1)<CR>", opts("Move word left"))

vim.keymap.set("v", "<A-j>", ":MoveBlock(1)<CR>", opts("Move block down"))
vim.keymap.set("v", "<A-k>", ":MoveBlock(-1)<CR>", opts("Move block up"))
vim.keymap.set("v", "<A-h>", ":MoveHBlock(-1)<CR>", opts("Move block left"))
vim.keymap.set("v", "<A-l>", ":MoveHBlock(1)<CR>", opts("Move block right"))

-- Luasnip is configured in lua/plugins/lsp/cmp.lua

-- Buffers Barbar
map("n", "<M-c>", "<cmd>BufferClose<cr>", opts("Close buffer"))
map("n", "<M-p>", "<cmd>BufferPin<cr>", opts("Pin buffer"))
map("n", "<C-p>", "<cmd>BufferPick<cr>", opts("Pick buffer"))
map("n", "<M-,>", "<cmd>BufferPrevious<cr>", opts("Go to previous buffer"))
map("n", "<M-.>", "<cmd>BufferNext<cr>", opts("Go to next buffer"))
map("n", "<C-,>", "<cmd>BufferMovePrevious<cr>", opts("Move buffer right"))
map("n", "<C-.>", "<cmd>BufferMoveNext<cr>", opts("Move buffer left"))
