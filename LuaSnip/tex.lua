-- https://www.ejmastnak.com/tutorials/vim-latex/luasnip/

local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local d = ls.dynamic_node
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep
local ms = ls.multi_snippet

local helpers = require('core.luasnip-helper-funcs')
local get_visual = helpers.get_visual
local nl_whitespace = helpers.nl_whitespace
local line_begin = require("luasnip.extras.expand_conditions").line_begin

local tex_utils = {} -- Has to be loaded after lervag/vimtex
tex_utils.in_mathzone = function()  -- math context detection
  return vim.fn["vimtex#syntax#in_mathzone"]() == 1
end
tex_utils.in_text = function()
  return not tex_utils.in_mathzone()
end
tex_utils.in_comment = function()  -- comment detection
  return vim.fn["vimtex#syntax#in_comment"]() == 1
end
tex_utils.in_env = function(name)  -- generic environment detection
    local is_inside = vim.fn["vimtex#env#is_inside"](name)
    return (is_inside[1] > 0 and is_inside[2] > 0)
end
-------------------------
tex_utils.in_equation = function()  -- equation environment detection
    return tex_utils.in_env("equation")
end
tex_utils.in_bmatrix = function()
    return tex_utils.in_env("bmatrix") and tex_utils.in_mathzone
end
tex_utils.in_itemize = function()  -- itemize environment detection
    return tex_utils.in_env("itemize")
end
tex_utils.in_tikz = function()  -- TikZ picture environment detection
    return tex_utils.in_env("tikzpicture")
end
tex_utils.in_list = function()
	return tex_utils.in_env("enumerate")
end
-------------------------
tex_utils.in_text_wsnl = function(a, b, c) -- wsnl stands for whitespace / newline
	return tex_utils.in_text() and nl_whitespace(a, b, c)
end
tex_utils.in_text_lnstart = function(a, b, c)
	return tex_utils.in_text() and line_begin(a, b, c)
end
tex_utils.in_list_lnstart = function(a, b, c)
	return tex_utils.in_list() and line_begin(a, b, c)
end
tex_utils.in_tikz_lnstart = function(a, b, c)
	return tex_utils.in_tikz() and line_begin(a, b, c)
end
tex_utils.in_tikz_nlnstart = function(a, b, c) -- Also has to be whitespace in front
	return tex_utils.in_tikz() and not line_begin(a, b, c) and not not string.match(a, "%s" .. b .. "$")
end
tex_utils.in_list_nlnstart = function(a, b, c)
	return tex_utils.in_list() and not line_begin(a, b, c)
end
tex_utils.in_list_nlnstart_math = function()
	return tex_utils.in_list_nlnstart and tex_utils.in_mathzone()
end
tex_utils.in_flalign = function(a, b, c)
	return tex_utils.in_env("flalign*") and not tex_utils.in_list() and not line_begin(a, b, c)
end
tex_utils.not_in_flalign = function()
	return not tex_utils.in_env("flalign*")
end
tex_utils.not_in_flalign_nl = function(a, b, c)
	return tex_utils.not_in_flalign and not line_begin(a, b, c)
end

return {
	s({ trig = "doc", descr = "LaTeX document boilerplate" },
		fmta(
			[[
				%! TEX program = pdf_escaped
				\documentclass[11pt, preview, border=1in]{standalone}
				\usepackage{mathtools, amssymb, amsthm, graphicx, enumitem, titlesec, tikz, minted, xparse, tcolorbox}
				\usepackage[a4paper, margin=1in]{geometry}
				\mathtoolsset{showonlyrefs}
				\graphicspath{ {./images/} }
				\usepackage[parfill]{parskip}
				\setlength{\parindent}{0pt}
				\usepackage[T1]{fontenc}
				\usepackage{lmodern}
				\usepackage{polynom}
				\newcommand{\polynomdiv}[2]{\par\polylongdiv[style=C,div=:]{#1}{#2}\par}

				\title{\vspace{-2cm}<>}
				\date{<>}
				\author{<>}

				\renewcommand{\labelenumi}{\alph{enumi})}
				\titleformat*{\section}{\fontsize{14}{18}\selectfont}
				\titleformat*{\subsection}{\fontsize{10}{12}\selectfont}
				\pagestyle{empty}
				\pagenumbering{gobble}

				\begin{document}

				\definecolor{bg}{HTML}{282828}
				\usemintedstyle{native}
				\setminted{bgcolor=bg}

				\newtcolorbox{mintedbox}{
					arc=5mm,
					colframe = bg,
					colback = bg,
				}

				\maketitle

				<>

				\end{document}
			]],
			{ i(1, "Title"), i(2, "Date"), i(3, "Author"), i(4) }
		), { condition = line_begin }),
	-------------------
	-- Math Snippets --
	-------------------
	s({ trig = "mm", descr = "Inline Math", snippetType = "autosnippet", wordTrig = true },
		fmta(
			[[<>$ <> $]],
			{ f( function(_, snip) return snip.captures[1] end ), i(1) }
		), { condition = tex_utils.in_text_wsnl }),
	s({ trig = "ml", descr = "Multiline Math", snippetType = "autosnippet", wordTrig = true },
		fmta(
			[[
				\begin{flalign*}
					& <> & <>
				\end{flalign*}
			]],
			{ i(1), i(0) }
		), { condition = tex_utils.in_text_lnstart }),
	s({ trig = "(%s)ll", descr = "Left-aligned newline", snippetType = "autosnippet", wordTrig = true, regTrig = true },
		fmta(
			[[
				<> \\[5pt]
				& <> &
			]],
			{ f( function(_, snip) return snip.captures[1] end ), i(1) }
		), { condition = tex_utils.in_flalign }),
	---------------------
	s({ trig = "pp", descr = "Parenthesis", snippetType = "autosnippet", wordTrig = false },
		fmta(
			[[\left(<>\right)]],
			{ i(1) }
		), { condition = tex_utils.in_mathzone }),
	s({ trig = "ff", descr = "Fraction", snippetType = "autosnippet", wordTrig = true },
		fmta(
			[[\frac{<>}{<>}]],
			{ i(1), i(2) }
		), { condition = tex_utils.in_mathzone }),
	s({ trig = "([%s])aa", descr = "Answer (Double underline)", snippetType = "autosnippet", wordTrig = true, regTrig = true },
		fmta(
			[[
				<>\underline{\underline{<>}}
			]],
			{ f( function(_, snip) return snip.captures[1] end ), d(1, get_visual) }
		)),
	s({ trig = "und", descr = "Underset text (below other text)", wordTrig = true },
		fmta(
			[[\underset{<>}{<>}]],
			{ i(1, "Under"), d(2, get_visual) }
		), { condition = tex_utils.in_mathzone }),
	s({ trig = "ss", descr = "Square root", wordTrig = true, snippetType="autosnippet" },
		fmta(
			[[\sqrt{<>}]],
			{ i(1) }
		), { condition = tex_utils.in_mathzone }),
	s({ trig = "rr", descr = "Nth root", wordTrig = true, snippetType="autosnippet" },
		fmta(
			[[\sqrt[<>]{<>}]],
			{ i(1), i(2) }
		), { condition = tex_utils.in_mathzone }),
	s({ trig = "^", descr = "Exponent", snippetType = "autosnippet", wordTrig = false},
    fmta(
      [[^{<>}]],
      { i(1)}
    ), { condition = tex_utils.in_mathzone }),
	s({ trig = "ar", descr ="Equation system", snippetType = "autosnippet", wordTrig = true},
		fmta(
			[[
				\begin{bmatrix}
				<> &=& <>	\\[5pt]
				<> &=& <>
				\end{bmatrix}
			]],
			{ i(1), i(2), i(3), i(4) }
		), { condition = tex_utils.in_mathzone }),
	s({ trig = "abc", descr = "ABC-formula", wordTrig = true },
		fmta([[x=\frac{-<>\pm\sqrt{<>^{2}-4*<>*<>}}{2*<>}]],
			{ i(2), rep(2), i(1), i(3), rep(1) }
		), { condition = tex_utils.in_mathzone }),
	s({ trig = "poldiv", descr = "Polynomdivision", wordTrig = true, snippetType="autosnippet" },
		fmta(
			[[\polynomdiv{<>}{<>}]],
			{ i(1), i(2) }
		), { condition = tex_utils.in_text_lnstart }),
	----------
	-- Text --
	----------
	s({ trig = "(%s)ll", deescr = "Newline with spacing", snippetType = "autosnippet", regTrig = true, wordTrig = true },
		fmta(
			"<>\\\\[5pt]",
			{ f( function(_, snip) return snip.captures[1] end ) }
		), { condition = tex_utils.in_text }),
	s({ trig = "text", descr = "Text", wordTrig = true },
		fmta(
			[[\text{<>}]],
			{ i(1) }
		)),
	-- uses *, not shown in \tableofcontents
	s({ trig = "sec", descr = "Section", wordTrig = true, snippetType = "autosnippet" },
		fmta(
			[[\section*{<>}]],
			{ i(1, "Section") }
		), { condition = tex_utils.in_text_lnstart }),
	----------
	-- List --
	----------
	s({ trig = "ls", descr = "List a) b) c)", wordTrig = true, snippetType = "autosnippet" },
		fmta(
			[[
				\begin{enumerate}
					<>
				\end{enumerate}
			]],
			{ i(1) }
		), { condition = tex_utils.in_text_lnstart }),
	s({ trig = "lr", descr = "Resume list", wordTrig = true, snippetType = "autosnippet" },
		fmta(
			[[
				\begin{enumerate}[resume]
					<>
				\end{enumerate}
			]],
			{ i(1) }
		), { condition = tex_utils.in_text_lnstart }),
	s({ trig = "li", descr = "List item", snippetType = "autosnippet", wordTrig = true },
		fmta(
			[[<>\item <>]],
			{ f( function(_, snip) return snip.captures[1] end ), i(1) }
		), { condition = tex_utils.in_list_lnstart }),
	s({ trig = "(%s)lm", descr = "List multiline math", snippetType = "autosnippet", wordTrig = false, regTrig = true },
		fmta(
			[[
				<>
					\begin{flalign*}
						& <> & <>
					\end{flalign*}
			]],
			{ f( function(_, snip) return snip.captures[1] end ), i(1), i(2) }
		), { condition = tex_utils.in_list_nlnstart }),
	s({ trig = "(%s)ll", descr = "List math line", snippetType = "autosnippet", wordTrig = true, regTrig = true },
		fmta(
			[[
				<>\\[5pt]
				& <> &
			]],
			{ f( function(_, snip) return snip.captures[1] end ), i(1) }
		), { condition = tex_utils.in_list_nlnstart_math }),
	-----------
	-- Other --
	-----------
	s({ trig = "img", descr = "Image", regTrig = true, wordTrig = true },
		fmta(
			[[<>\includegraphics[width=<>\textwidth]{<>}]],
			{ f( function(_, snip) return snip.captures[1] end ), i(1, "0.9"), i(2) }
		), { condition = tex_utils.in_text }),
	s({ trig = "new", descr = "Generic environment", wordTrig = true },
		fmta(
			[[
				\begin{<>}
					<>
				\end{<>}
			]],
			{ i(1), i(2), rep(1) }
		), { condition = tex_utils.in_text_lnstart }),
}
