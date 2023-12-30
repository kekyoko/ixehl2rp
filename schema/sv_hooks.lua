function Schema:GetPlayerDeathSound(client)
	local char = client:GetCharacter()

	if not ( char ) then
		return
	end

	if ( Schema:IsCP(client) ) then
		return "npc/metropolice/die" .. math.random(1, 4) .. ".wav"
	elseif ( Schema:IsOTA(client) ) then
		return "npc/combine_soldier/die" .. math.random(1, 3) .. ".wav"
	end
end

function Schema:GetPlayerPainSound(client)
	local char = client:GetCharacter()

	if not ( char ) then
		return
	end

	if ( Schema:IsCP(client) ) then
		return "npc/metropolice/pain" .. math.random(1, 4) .. ".wav"
	elseif ( Schema:IsOTA(client) ) then
		return "npc/combine_soldier/pain" .. math.random(1, 3) .. ".wav"
	end
end

function Schema:PlayerSpray(ply)
	return true
end

function Schema:DoPlayerDeath(ply, attacker, damageInfo)
	local char = ply:GetCharacter()

    if not ( char ) then
        return
    end

    // ix.cmbSystems:SetBOLStatus(ply, false) -- It works, enable if you want.
	
	local maxDeathItems = ix.config.Get("maxItemDrops", 3)

	if ( maxDeathItems > 0 ) then
		local inventory = char:GetInventory()

		if ( inventory ) then
			local items = {}

			for _, v in pairs(inventory:GetItems()) do
				if ( hook.Run("CanPlayerDropItemOnDeath", ply, v) == false ) then
					continue
				end

				table.insert(items, v)
			end

			if ( #items > 0 ) then
				for i = 1, math.random(1, #items) do
					local item = items[math.random(1, #items)]

					if ( item ) then
						item:Transfer(nil, nil, nil, ply:GetPos() + Vector(0, 0, 16))
					end
				end
			end
		end
	end
end

function Schema:SaveData()
	local data = {}

	for _, v in ipairs(ents.FindByClass("ix_cmb_terminal")) do
		data[#data + 1] = {v:GetPos(), v:GetAngles()}
	end

	ix.data.Set("cmbTerminals", data)

	data = {}

	for _, v in ipairs(ents.FindByClass("ix_citizen_terminal")) do
		data[#data + 1] = {v:GetPos(), v:GetAngles()}
	end

	ix.data.Set("citizenTerminals", data)

	data = {}

	for _, v in ipairs(ents.FindByClass("ix_vendingmachine")) do
		data[#data + 1] = {v:GetPos(), v:GetAngles(), v:GetAllStock()}
	end
end

function Schema:LoadData()
	local data = ix.data.Get("cmbTerminals", {})

	for _, v in ipairs(data) do
		local terminal = ents.Create("ix_cmb_terminal")
		terminal:SetPos(v[1])
		terminal:SetAngles(v[2])
		terminal:Spawn()
		terminal:Activate()
	end

	data = ix.data.Get("citizenTerminals", {})
	for _, v in ipairs(data) do
		local CitTerminal = ents.Create("ix_citizen_terminal")
		CitTerminal:SetPos(v[1])
		CitTerminal:SetAngles(v[2])
		CitTerminal:Spawn()
		CitTerminal:Activate()
	end

	data = ix.data.Get("vendingMachines", {})
	for _, v in ipairs(data) do
		local vm = ents.Create("ix_vendingmachine")
		vm:SetPos(v[1])
		vm:SetAngles(v[2])
		vm:SetStock(v[3])
		vm:Spawn()
		vm:Activate()
	end
end

function Schema:PlayerJoinedClass(ply, class, oldClass)
	local char = ply:GetCharacter()

	if not ( char ) then
		return
	end

	char:SetData("permaClass", class)
	hook.Run("PlayerSetHandsModel", ply, ply:GetHands())
end

function Schema:PlayerJoinedRank(ply, rank, oldRank)
	local char = ply:GetCharacter()

	if not ( char ) then
		return
	end

	char:SetData("permaRank", rank)
	hook.Run("PlayerSetHandsModel", ply, ply:GetHands())
end

function Schema:PlayerLoadedCharacter(ply, newChar, oldChar)
	if not ( newChar ) then
		return
	end

	local permaClass = newChar:GetData("permaClass")
	local permaClassData = ix.class.list[permaClass]

	local permaRank = newChar:GetData("permaRank")
	local permaRankData = ix.rank.list[permaRank]

	timer.Simple(0.1, function()
		if ( permaClass and permaClassData ) then
			local oldClass = newChar:GetClass()
			newChar:SetClass(permaClass)
			
			hook.Run("PlayerJoinedClass", ply, permaClass, oldClass)
		end

		if ( permaRank and permaRankData ) then
			local oldRank = newChar:GetRank()
			newChar:SetRank(permaRank)
			
			hook.Run("PlayerJoinedRank", ply, permaRank, oldRank)
		end

		hook.Run("PlayerSetHandsModel", ply, ply:GetHands())
	end)
end

function Schema:PlayerSetHandsModel(ply, ent)
	timer.Simple(0.1, function()
		if not ( IsValid(ent) ) then
			return
		end

		if ( self:IsOTA(ply) ) then
			if ( self:IsOTAElite(ply) ) then
				ply:SetPlayerColor(Vector(1, 0, 0))
				
				ent:SetModel("models/weapons/c_arms_combine_elite/c_arms_combine_elite_color.mdl")
				ent:SetSkin(0)
				ent:SetBodyGroups("000000")
			end
			
			if ( self:IsOTASoldier(ply) or self:IsOTAShotgunner(ply) ) then
				local skin = 0

				if ( self:IsOTAShotgunner(ply) ) then
					skin = 1
				end

				ent:SetModel("models/weapons/c_arms_combine_default/c_arms_combine_regular.mdl")
				ent:SetSkin(skin)
				ent:SetBodyGroups("000000")
			end
		elseif ( self:IsCP(ply) ) then
			ent:SetModel("models/cfe_pm/cfe_hands/cfe_hands.mdl")
			ent:SetSkin(1)
			ent:SetBodyGroups("000000")
		end
	end)
end