-- LUALOCALS < ---------------------------------------------------------
local ItemStack, minetest, nodecore, pairs, type
    = ItemStack, minetest, nodecore, pairs, type
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

function nodecore.register_lode(shape, rawdef)
	for _, temper in pairs(tempers) do
		local def = nodecore.underride({}, rawdef)
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
			def.groups = def.groups or {}
			def.groups.falling_node = 1
			def.damage_per_second = 1
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
				nodecore.register_cook_abm({nodenames = {fullname}})
			end
		end
	end
end

nodecore.register_lode("Block", {
		type = "node",
		description = "## Adamant",
		tiles = {modname .. "_#.png"},
		groups = {metal_block = 1},
		light_source = 8,
		crush_damage = 4
	})

nodecore.register_lode("Prill", {
		type = "craft",
		groups = {metal_prill = 1},
		inventory_image = modname .. "_#.png^[mask:" .. modname .. "_mask_prill.png",
	})

local function replacestack(pos, alt)
	local stack = nodecore.stack_get(pos)
	if stack:is_empty() then stack = nil end
	local node = minetest.get_node(pos)
	local name = stack and stack:get_name() or node.name
	local def = minetest.registered_items[name] or {}
	alt = def["metal_alt_" .. alt]
	if not alt then return nodecore.remove_node(pos) end
	if stack then
		local repl = ItemStack(alt)
		local qty = stack:get_count()
		if qty == 0 then qty = 1 end
		repl:set_count(qty * repl:get_count())
		nodecore.remove_node(pos)
		return nodecore.item_eject(pos, repl)
	else
		nodecore.set_node(pos, {name = alt})
		nodecore.fallcheck(pos)
	end
end

nodecore.register_craft({
		label = "adamant stack heating",
		action = "cook",
		touchgroups = {flame = 3},
		duration = 45,
		cookfx = true,
		nodes = {{match = {metal_temper_cool = true, count = false}}},
		after = function(pos) return replacestack(pos, "hot") end
	})

nodecore.register_craft({
		label = "adamant stack annealing",
		action = "cook",
		touchgroups = {flame = 0},
		duration = 150,
		priority = -1,
		cookfx = {smoke = true, hiss = true},
		nodes = {{match = {metal_temper_hot = true, count = false}}},
		after = function(pos) return replacestack(pos, "annealed") end
	})

nodecore.register_craft({
		label = "adamant stack quenching",
		action = "cook",
		touchgroups = {flame = 0},
		check = function(pos)
			return nodecore.quenched(pos)
		end,
		cookfx = true,
		nodes = {{match = {metal_temper_hot = true, count = false}}},
		after = function(pos) return replacestack(pos, "tempered") end
	})

-- Because of how massive they are, forging a block is a hot-working process.
nodecore.register_craft({
		label = "forge adamant block",
		action = "pummel",
		toolgroups = {thumpy = 5},
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

-- Blocks can be chopped back into prills using only hardened lode tools or better.
nodecore.register_craft({
		label = "break apart adamant block",
		action = "pummel",
		toolgroups = {choppy = 5},
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
