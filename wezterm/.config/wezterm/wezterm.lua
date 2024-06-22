local wezterm = require("wezterm")
local a = wezterm.action

local function is_an_editor(name)
	return name:find("nvim")
end

local function conflicting_nvim_keys(key, mods, editor_action, non_editor_action)
	return {
		key = key,
		mods = mods,
		action = wezterm.action_callback(function(win, pane)
			local proc_name = pane:get_foreground_process_name()
			if is_an_editor(proc_name) then
				win:perform_action(editor_action, pane)
			else
				win:perform_action(non_editor_action, pane)
			end
		end),
	}
end

local function key(keys, mods, actions)
	return { key = keys, mods = mods, action = actions }
end

local function ckey(keys, mods, non_editor_action)
	return conflicting_nvim_keys(keys, mods, { SendKey = { key = keys, mods = mods } }, non_editor_action)
end

return {
	disable_default_key_bindings = true,

	scrollback_lines = 10000,

	font = wezterm.font("JetBrainsMono Nerd Font Mono", { weight = "Light" }),
	-- font = wezterm.font("Ubuntu", { weight = "Light" }),
	-- font_size = 11.5,

	adjust_window_size_when_changing_font_size = false,

	window_background_opacity = 0.6,

	window_padding = { left = 0, right = 0, top = 0, bottom = 0 },

	use_fancy_tab_bar = true,

	max_fps = 144,

	hide_tab_bar_if_only_one_tab = true,

	keys = {

		--
		--
		--
		--
		-- -- Tabs
		--
		--
		-- -- Scrolling
		-- key("p", A, a.ScrollByLine(-1)),
		-- key("n", A, a.ScrollByLine(1)),
		-- key("g", A, a.ScrollToTop),
		-- key("G", A, a.ScrollToBottom),
		--
		--
		--
		-- ---------------------

		-- key("P", C, a.ActivateCommandPalette),		-- Panes

		--
		-- Global keys
		--

		-- Panes
		key("f", "ALT|SHIFT", a.SplitPane({ direction = "Right", size = { Percent = 50 } })),
		key("a", "ALT|SHIFT", a.SplitPane({ direction = "Left", size = { Percent = 50 } })),
		key("s", "ALT|SHIFT", a.SplitPane({ direction = "Down", size = { Cells = 7 } })),
		key("d", "ALT|SHIFT", a.SplitPane({ direction = "Up", size = { Cells = 7 } })),

		key("f", "ALT", a.ActivatePaneDirection("Right")),
		key("a", "ALT", a.ActivatePaneDirection("Left")),
		key("s", "ALT", a.ActivatePaneDirection("Down")),
		key("d", "ALT", a.ActivatePaneDirection("Up")),

		key("f", "ALT|CTRL", a.AdjustPaneSize({ "Right", 1 })),
		key("a", "ALT|CTRL", a.AdjustPaneSize({ "Left", 1 })),
		key("s", "ALT|CTRL", a.AdjustPaneSize({ "Up", 1 })),
		key("d", "ALT|CTRL", a.AdjustPaneSize({ "Down", 1 })),

		key("Enter", "ALT", a.TogglePaneZoomState),

		-- Tabs
		key("T", "ALT", a.SpawnTab("DefaultDomain")),
		key("]", "ALT", a.ActivateTabRelative(1)),
		key("[", "ALT", a.ActivateTabRelative(-1)),

		--
		-- Conflicting keys with neovim
		--

		-- Font size
		key("=", "CTRL|ALT", a.IncreaseFontSize),
		key("-", "CTRL|ALT", a.DecreaseFontSize),
		key("0", "CTRL|ALT", a.ResetFontSize),

		ckey("k", "CTRL", a({ SendString = "teeest" })),

		-- Copy/Paste
		ckey("v", "CTRL|SHIFT", a.PasteFrom("Clipboard")),
		ckey("c", "CTRL|SHIFT", a.CopyTo("Clipboard")),

		-- Scrolling
		ckey("u", "CTRL", a.ScrollByPage(-1)),
		ckey("d", "CTRL", a.ScrollByPage(1)),

		-- Tabs/Panes
		ckey("w", "ALT", a.CloseCurrentPane({ confirm = true })),
		ckey("w", "ALT|SHIFT", a.CloseCurrentTab({ confirm = true })),

		-- Seaarching.......................................................
	},
}
