-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, type
    = minetest, nodecore, pairs, type
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local tempers = {
	{
		name = "hot",
		desc = "Glowing",
		sound = "annealed",
		glow = true
	},
	{
		name = "annealed",
		desc = "Annealed",
		sound = "annealed"
	},
	{
		name = "tempered",
		desc = "Tempered",
		sound = "tempered"
	}
}

function nodecore.register_adamant(shape, rawdef)
	rawdef.groups = rawdef.groups or {}
	for _, temper in pairs(tempers) do
		local def = nodecore.underride({}, rawdef)
		def.groups = nodecore.underride({}, def.groups)
		def = nodecore.underride(def, {
				description = temper.desc .. " Adamant " .. shape,
				name = (shape .. "_" .. temper.name):lower():gsub(" ", "_"),
				groups = {
					cracky = 4,
					metallic = 1,
					falling_node = temper.name == "hot" and 1 or nil,
					["metal_temper_" .. temper.name] = 1
				},
				["metal_temper_" .. temper.name] = true,
				metal_alt_hot = modname .. ":" .. shape:lower() .. "_hot",
				metal_alt_annealed = modname .. ":" .. shape:lower() .. "_annealed",
				metal_alt_tempered = modname .. ":" .. shape:lower() .. "_tempered",
				sounds = nodecore.sounds("nc_lode_" .. temper.sound)
			})
		def.metal_temper_cool = (not def.metal_temper_hot) or nil
		if not temper.glow then
			def.light_source = nil
		else
			def.groups.falling_node = 1
			def.groups.damage_touch = 1
			def.groups.damage_radiant = 1
		end

		if def.tiles then
			local t = {}
			for k, v in pairs(def.tiles) do
				t[k] = v:gsub("#", temper.name)
			end
			def.tiles = t
		end
		for k, v in pairs(def) do
			if type(v) == "string" then
				def[k] = v:gsub("##", temper.desc):gsub("#", temper.name)
			end
		end

		if def.bytemper then def.bytemper(temper, def) end

		if not def.skip_register then
			local fullname = modname .. ":" .. def.name
			minetest.register_item(fullname, def)
			if def.type == "node" then
				nodecore.register_cook_abm({
						nodenames = {fullname},
						neighbors = (not temper.glow) and {"group:flame"} or nil
					})
			end
		end
	end
end

nodecore.register_adamant("Block", {
		type = "node",
		description = "## Adamant",
		tiles = {modname .. "_#.png"},
		groups = {metal_cube = 1},
		light_source = 8,
		crush_damage = 4
	})

nodecore.register_adamant("Prill", {
		type = "craft",
		groups = {metal_prill = 1},
		light_source = 1,
		inventory_image = modname .. "_#.png^[mask:" .. modname .. "_mask_prill.png",
	})

-- Because of how massive they are, forging a block is a hot-working process.
nodecore.register_craft({
		label = "forge adamant block",
		action = "pummel",
		toolgroups = {thumpy = 4},
		indexkeys = {modname .. ":prill_hot"},
		nodes = {
			{
				match = {name = modname .. ":prill_hot", count = 8},
				replace = "air"
			}
		},
		items = {
			modname .. ":block_hot"
		}
	})

-- Blocks can be chopped back into prills using only hardened tools.
nodecore.register_craft({
		label = "break apart adamant block",
		action = "pummel",
		toolgroups = {choppy = 5},
		indexkeys = {modname .. ":block_hot"},
		nodes = {
			{
				match = modname .. ":block_hot",
				replace = "air"
			}
		},
		items = {
			{name = modname .. ":prill_hot 2", count = 4, scatter = 5}
		}
	})
