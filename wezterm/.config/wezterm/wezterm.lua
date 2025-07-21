local wezterm = require("wezterm")
local act = wezterm.action

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

local function mkey(keys, actions)
	return { key = keys, action = actions }
end

local function ckey(keys, mods, non_editor_action)
	return conflicting_nvim_keys(keys, mods, { SendKey = { key = keys, mods = mods } }, non_editor_action)
end

wezterm.on("update-right-status", function(window, pane)
	local name = window:active_key_table()
	if name then
		name = name
	end
	window:set_right_status(name or "")
end)

return {
	-- Wezterm does not start with current hyprland wl protocol
	enable_wayland = false,
	front_end = "OpenGL",
	disable_default_key_bindings = true,
	scrollback_lines = 5000,
	font = wezterm.font("JetBrainsMono Nerd Font Mono", { weight = "Regular" }),
	adjust_window_size_when_changing_font_size = false,
	window_background_opacity = 0.6,
	-- window_background_opacity = 0.93,
	window_padding = { left = 0, right = 0, top = 0, bottom = 0 },
use_fancy_tab_bar = false,
	max_fps = 144,
	hide_tab_bar_if_only_one_tab = true,
	colors = {

		tab_bar = { background = "rgba(0,0,0,0.6)" },
		compose_cursor = "orange",
	},

	leader = { key = "Space", mods = "SHIFT" },

	keys = {
		key("t", "LEADER", act.ActivateKeyTable({ name = "tab_mode", one_shot = true })),
		key("w", "LEADER", act.ActivateKeyTable({ name = "pane_mode", one_shot = true })),
		key("r", "LEADER", act.ActivateKeyTable({ name = "size_mode", one_shot = false })),

		-- Tab
		key("]", "ALT", act.ActivateTabRelative(1)),
		key("[", "ALT", act.ActivateTabRelative(-1)),
		key("Tab", "ALT", act.ActivateTabRelative(1)),
		key("Tab", "ALT|SHIFT", act.ActivateTabRelative(-1)),

		-- Pane
		-- key("Enter", "ALT", act.TogglePaneZoomState),

		key("h", "ALT", act.ActivatePaneDirection("Left")),
		key("j", "ALT", act.ActivatePaneDirection("Down")),
		key("k", "ALT", act.ActivatePaneDirection("Up")),
		key("l", "ALT", act.ActivatePaneDirection("Right")),

		-- Copy/Paste
		key("V", "CTRL", act.PasteFrom("Clipboard")),
		key("C", "CTRL", act.CopyTo("Clipboard")),

		-- Search Mode
		ckey("/", "ALT", act.Search({ CaseInSensitiveString = "" })),

		-- Scrolling
		ckey("u", "ALT", act.ScrollByPage(-1)),
		ckey("d", "ALT", act.ScrollByPage(1)),
		ckey("U", "ALT", act.ScrollByLine(-5)),
		ckey("J", "ALT", act.ScrollByLine(5)),

		-- Command Pallette
		key("P", "CTRL", act.ActivateCommandPalette),
	},

	key_tables = {
		size_mode = {
			mkey("Escape", "PopKeyTable"),
			mkey("h", act.AdjustPaneSize({ "Left", 1 })),
			mkey("j", act.AdjustPaneSize({ "Down", 1 })),
			mkey("k", act.AdjustPaneSize({ "Up", 1 })),
			mkey("l", act.AdjustPaneSize({ "Right", 1 })),
			mkey("=", act.IncreaseFontSize),
			mkey("-", act.DecreaseFontSize),
			mkey("0", act.ResetFontSize),
		},

		tab_mode = {
			mkey("t", act.SpawnTab("DefaultDomain")),
			mkey("c", act.CloseCurrentTab({ confirm = false })),
		},

		pane_mode = {
			mkey("h", act.SplitPane({ direction = "Left", size = { Percent = 50 } })),
			mkey("j", act.SplitPane({ direction = "Down", size = { Percent = 7 } })),
			mkey("k", act.SplitPane({ direction = "Up", size = { Percent = 7 } })),
			mkey("l", act.SplitPane({ direction = "Right", size = { Percent = 50 } })),
			mkey("c", act.CloseCurrentPane({ confirm = false })),
		},

		search_mode = {
			key("Escape", "NONE", act.CopyMode("Close")),
			key("j", "ALT", act.CopyMode("NextMatch")),
			key("k", "ALT", act.CopyMode("PriorMatch")),
			key("J", "ALT", act.CopyMode("NextMatchPage")),
			key("K", "ALT", act.CopyMode("PriorMatchPage")),
			key("t", "CTRL", act.CopyMode("CycleMatchType")),
			key("d", "CTRL", act.CopyMode("ClearPattern")),
		},
	},
}
