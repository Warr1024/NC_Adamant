-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local function tile(n)
	return modname .. "_annealed.png^[mask:" .. modname .. "_shelf_" .. n .. ".png"
end

local function cbox(s) return nodecore.fixedbox(-s, -s, -s, s, s, s) end
minetest.register_node(modname .. ":shelf", {
		description = "Adamant Crate",
		collision_box = cbox(0.5),
		selection_box = cbox(0.5),
		tiles = {tile("side"), tile("base"), tile("side")},
		groups = {
			cracky = 3,
			visinv = 1,
			storebox = 2,
			totable = 1,
			scaling_time = 50
		},
		paramtype = "light",
		sunlight_propagates = true,
		sounds = nodecore.sounds("nc_lode_annealed"),
		storebox_access = function(pt) return pt.above.y >= pt.under.y end
	})

nodecore.register_craft({
		label = "assemble adamant shelf",
		norotate = true,
		action = "pummel",
		toolgroups = {thumpy = 5},
		nodes = {
			{match = modname .. ":prill_hot", replace = "air"},
			{x = -1, z = -1, match = modname .. ":rod_annealed", replace = modname .. ":shelf"},
			{x = 1, z = -1, match = modname .. ":rod_annealed", replace = modname .. ":shelf"},
			{x = -1, z = 1, match = modname .. ":rod_annealed", replace = modname .. ":shelf"},
			{x = 1, z = 1, match = modname .. ":rod_annealed", replace = modname .. ":shelf"},
		},
		items = {
			modname .. ":prill_annealed"
		}
	})

nodecore.register_craft({
		label = "assemble adamant shelf",
		norotate = true,
		action = "pummel",
		toolgroups = {thumpy = 5},
		nodes = {
			{match = modname .. ":prill_hot", replace = "air"},
			{x = -1, z = 0, match = modname .. ":rod_annealed", replace = modname .. ":shelf"},
			{x = 1, z = 0, match = modname .. ":rod_annealed", replace = modname .. ":shelf"},
			{x = 0, z = -1, match = modname .. ":rod_annealed", replace = modname .. ":shelf"},
			{x = 0, z = 1, match = modname .. ":rod_annealed", replace = modname .. ":shelf"},
		},
		items = {
			modname .. ":prill_annealed"
		}
	})

nodecore.register_craft({
		label = "break apart adamant shelf",
		norotate = true,
		action = "pummel",
		toolgroups = {choppy = 5},
		check = function(pos) return nodecore.stack_get(pos):is_empty() end,
		nodes = {
			{match = modname .. ":shelf", replace = "air"},
		},
		items = {
			{name = modname .. ":bar_annealed 2", scatter = 0.001}
		}
	})
