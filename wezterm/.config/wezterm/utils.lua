local wt = require("wezterm")

local M = {}

M.key = function(keys, mods, actions)
	return { key = keys, mods = mods, action = actions }
end

M.is_pane_running_neovim = function(pane)
	local info = pane:get_foreground_process_info()
	if info and info.name == "nvim" then
		return true
	end
	return false
end

M.update_right_status = function(window, pane, global_key_bindings, conflicting_key_bindings)
	window:set_config_overrides({
		keys = M.is_pane_running_neovim(pane) and global_key_bindings
			or vim.tbl_extend("force", global_key_bindings, conflicting_key_bindings),
	})
end

return M
