-- plugins/theme.lua — active colorscheme
--
-- Omarchy switches themes by rewriting the state file below; this module
-- follows it when present so theme changes hot-reload, and falls back to
-- the default spec on machines without Omarchy.

local state_file = vim.fn.expand("~/.local/state/omarchy/current/theme/neovim.lua")

local fallback = {
	{
		"folke/tokyonight.nvim",
		priority = 1000,
	},
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "tokyonight-night",
		},
	},
}

if vim.fn.filereadable(state_file) == 1 then
	local ok, spec = pcall(dofile, state_file)
	if ok and type(spec) == "table" then
		return spec
	end
end

return fallback
