local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local PlayerData = DataStoreService:GetDataStore("PlayerData")
local SessionData = require(game.ServerScriptService.RAM)

--when you come back, create a system of damage output, multiplier variables and etc.., and make them change accordingly with what the player is equipping and etc..

local DefaultData = {
	
	DataCorrupted = false,
	running = false,
	DataVersion = 0,
	defaultloaded = false,
	loaded = false,
	InBattle = false,
	MenuOpen = false,
	AttackSpeed = 1,
	BaseDamage = 5,
	DamageOutput = 0,
	lastattack = 0,
	startbattle = 0,
	Cash = 0,
	Prestige = 0,
	Health = 100,
	MaxHealth = 100,
	Stamina = 250,
	MaxStamina = 250,
	Level = 1,
	MaxLevel = 25,
	Exp = 0,
	MaxExp = 100,
	Souls = 0,
	MaxPets = 3,
	PetsEquipped = 0,
	
	Inventory = {
		
		Weapons = {},
		Helmet = {},
		Chestplate = {},
		Leggings = {},
		Potions = {
			["1032303"] = {
				
				Equipped = false,
				ItemId = "3",   --template for potions
				Quantity = 1,
				Timer = 0,
			},
			["3040204"] = {
				Equipped = false,
				ItemId = "4",   --template for potions
				Quantity = 1,
				Timer = 0,
			},
		},
		Pets = {
			
			["540303"] = {   --item frame template, will make the system of getting such numbers later. (maybe math.random could just be enough?)
				Equipped = false,
				ItemId = "1",
				
			},
			["530234"] = {
				
				Equipped = false,
				ItemId = "2",	
			
			},
			
			
			
			
		},
		Blessing = {}

	},
	CurrentEquipped = {
		
		Weapon = "None",
		Helmet = "None",
		Chestplate = "None",
		Leggings = "None",
		Potions = {
			
		},
		Blessing = "None",
		Weapon2 = "None",
		Pets = {
			
			
		}
		
	}
	
}

-- when players enter, it creates a save for them
local function DeepCopy(original)
	local copy = {}
	
	
	for key, value in pairs(original)do
		
		if type(value)== "table" then
			copy[key] = DeepCopy(value)
		else
			copy[key] = value
		end
	end


 return copy
end


local function SaveUpdate(t1,t2)

	local copy = {}
	--t1 is the table you want to update, t2 is the table you want to update to but also keeping the original values from t1 intact

	-- 1️⃣ Copy all existing player data first
	for key, value in pairs(t1) do

		if type(value) == "table" then
			copy[key] = DeepCopy(value)
			if t2[key] == nil then
				print("key not found in new data, removing from save")
				copy[key] = nil
			end
		else
			copy[key] = value
			if t2[key] == nil then
				print("key not found in new data, removing from save")
				copy[key] = nil
			end
		end

		
	end

	-- 2️⃣ Add ONLY missing keys from the new update
	for key, value in pairs(t2) do
		if copy[key] == nil then
			if type(value) == "table" then
				copy[key] = DeepCopy(value)
			else
				copy[key] = value
			end
		end
		
		
	end
	
	

	for key, value in pairs(copy) do

		if type(value) == "table" then

			print("table detected, update starting")
			copy[key] = SaveUpdate(copy[key],t2[key])

		end
	end

	return copy

end

local function DataVersionChecker(old,key)
	if old.DataVersion ~= SessionData[key].DataVersion then
		return nil -- data is not safe to ovwrite
	end

	SessionData[key].DataVersion += 1
	return DeepCopy(SessionData[key])
	
end

game.Players.PlayerAdded:Connect(function(player)
	print(player.Name.."has been added")
	local key = tostring(player.UserId)
	local success, data = pcall(function()
		print("is this working 1")
		return PlayerData:GetAsync(key)
		
	end)
	--reset to standard in case of balance issues
	
	if success then
		if data ~= nil then
			print(player.Name.."already has a save")
			
			SessionData[key] = DeepCopy(data)
			SessionData[key].loaded = true
			--[[
			for i, v in pairs(SessionData[key])do
				if SessionData[key][i] ~= DefaultData[i] then
					print(SessionData[key][i], DefaultData[i])
					print("data is outdated, updating it !!")
					if type(DefaultData[i]) == "table"then
						table.insert(SessionData[key], DeepCopy(DefaultData[i]))
					else
						table.insert(SessionData[key], DefaultData[i])
					end
				else
					print("data is up to date")
				end
			end
			--]]
		else
			print(player.Name.."does not have a save")
			
			local savesuccess, err = pcall(function()
				 PlayerData:SetAsync(key, DeepCopy(DefaultData))
			end)
			
			if savesuccess then
				SessionData[key] = DeepCopy(DefaultData)
				SessionData[key].loaded = true
				
			else
				local attempts = 0
				local saved = false
				while attempts < 3 and saved == false do
					local success, err = pcall(function()
						 PlayerData:SetAsync(key, DeepCopy(DefaultData))
					end)
					if success then
						saved = true
						print(player.Name.."save created")
						SessionData[key].loaded = true
					else
						attempts += 1
						warn("Couldnt create save")
						SessionData[key].defaultloaded = true
					end
				task.wait(0.5)
				end
				SessionData[key] = DeepCopy(DefaultData)

			end
			
			
		end
	else
		warn("Couldnt load data")
		SessionData[key] = DeepCopy(DefaultData)
		SessionData[key].defaultloaded = true
	end
	print(player.Name.." data loaded or default has been loaded")
	--saved/load data complete
	
	if SessionData[key].DataCorrupted == true then
		warn("your last session was not able to properly save, sorry for the incovenience")
		SessionData[key].DataCorrupted = false
	end

	for i,v in pairs(SessionData[key]) do
		
		if SessionData[key][i] ~= DefaultData[i] then
			SessionData[key] = SaveUpdate(SessionData[key],DefaultData)
			
			local success, err = pcall(function()
				PlayerData:UpdateAsync(key, function(old)
					return DeepCopy(SessionData[key])
				end)
			end)
		end
	end
	SessionData[key].MaxExp = DefaultData.MaxExp
	SessionData[key].MaxStamina = DefaultData.MaxStamina
	SessionData[key].MaxHealth = DefaultData.MaxHealth
	SessionData[key].Stamina = SessionData[key].MaxStamina
	SessionData[key].Exp = 0
	SessionData[key].Level = 1


	SessionData[key].lastattack = 0
	SessionData[key].InBattle = false
	SessionData[key].startbattle = 0

end)
--[[
-when you come back make sure to only change the loaded to true, whenever the game is able to successfully load the data of the player
-and also make sure to not save player data whenever data is not loaded in, to prevent data loss, the loaded bool should handle that
-on player removing make sure to put some error handlers just in case of a failure, also make sure you put a retry save also add bind to close 
-search the difference between set async to update async

--]]


game.Players.PlayerRemoving:Connect(function(player)
	local key = tostring(player.UserId)
	--check if data was loaded
	
	
	local savesuccess, err = pcall(function()
		if SessionData[key].loaded == true and SessionData[key].DataCorrupted == false then
			PlayerData:UpdateAsync(key, function(old)
				return DataVersionChecker(old, key)
			end)
		else
			warn("player data wasnt properly loaded, current session will not be saved")
			
		end
	end)
	
	if savesuccess then 
		print(player.Name.." data saved")
		
	else
		local attempts = 0
		local saved = false
		while attempts < 3 and saved == false do
			local success,err = pcall(function()
				PlayerData:UpdateAsync(key, function(old)
					return DataVersionChecker(old, key)
				end)
			end)
			task.wait(0.5)
			if success then
				saved = true
				print(player.Name.." data saved")
				SessionData[key].DataCorrupted = false
			else
				attempts += 1
				warn("Couldnt save data")
				SessionData[key].DataCorrupted = true
			end
		end
	end
	SessionData[key] = nil
	print(player.Name.." data on RAM removed from session")
end)

game:BindToClose(function()
	
	for i, player in pairs(game.Players:GetPlayers()) do
		local key = tostring(player.UserId)
		local savesuccess, err = pcall(function()
			PlayerData:UpdateAsync(key, function(old)
				 --im not really sure about this one, I will research  a bit deeper
				return DataVersionChecker(old,key)
			end)
		end)
		if savesuccess then 
			print(player.Name.." data saved")
		else
			local attempts = 0
			local saved = false
			
			while attempts < 3 and saved == false do
				local success, err = pcall(function()
					PlayerData:UpdateAsync(key, function(old)
						--im not really sure about this one, I will research  a bit deeper
						return DataVersionChecker(old,key)
					end)
				end)
				
				task.wait(0.5)
				if success then
					saved = true
					SessionData[key].DataCorrupted = false
				else
					warn("Couldnt save data")
					attempts += 1
					SessionData[key].DataCorrupted = true
				end
				
			end
		end
	end
	
	
end)

--when you come back again from leaving work, make sure to change from setasync to update async in some places - finished






--[[task.spawn(function()
	
	while true do
		task.wait(2)
		
		print(SessionData)
		print(DefaultData)
	end
end)
--]]

local GetSessionData = game.ReplicatedStorage.RemoteFunctions.GetSessionData

GetSessionData.OnServerInvoke = function(player)
	
	return SessionData:Get(player)
	
end

local EquipItem = game.ReplicatedStorage.RemoteFunctions.EquipItem

EquipItem.OnServerInvoke = function(player, itemref, Action)
	print("hello")
	local ItemData = require(game.ReplicatedStorage.ItemData)
	
	local key = tostring(player.UserId)
	local ItemReference = ItemData[itemref]
	local alreadyequipped = false
	

	
	if Action == "Pets" then --this function will equip or unequip the item whenever necessary, it will also check if the player has the item equipped, put the item on the currentinventory if necessary, and give the item to player
	print("hello")
		if itemref ~= nil then
			print("this is itemref: ",itemref)
			print(itemref)
			print(SessionData[key].CurrentEquipped.Pets)
			print("LOOP IS ABOUT TO START")
			for i,v in pairs(SessionData[key].CurrentEquipped.Pets) do
				warn(i)
				if tostring(i) == tostring(itemref) then
					
					alreadyequipped = true
					break
				else
					
					alreadyequipped = false
					
					
				end
			end
			print("LOOP FINISHED")
			print("its working till this part")
			print(alreadyequipped)
			if alreadyequipped == false then
				print("its not already equipped")
				if #SessionData[key].CurrentEquipped.Pets < SessionData[key].MaxPets then
					print("THIS IS THE MOST IMPORANT PART OF THE CODE")
					print(itemref)
					print(Action)
					print(player)
					print(SessionData[key].Inventory.Pets)
					 for i,v in pairs(SessionData[key].Inventory.Pets) do
							if tostring(i)== tostring(itemref) then
								print("success")
								SessionData[key].CurrentEquipped.Pets[itemref] = SessionData[key].Inventory.Pets[itemref]
							end
					 end
					 print(SessionData[key].CurrentEquipped.Pets)
				end
				print(SessionData[key])
				return "Equipped"
			elseif alreadyequipped == true then
				
				if SessionData[key].CurrentEquipped.Pets[itemref] then
					for i,v in pairs(SessionData[key].CurrentEquipped.Pets) do
						if i == itemref then
							print("removed")
							SessionData[key].CurrentEquipped.Pets[itemref] = nil
							print(SessionData[key].CurrentEquipped.Pets)
						end 
					end
				end
				return "Unequipped" 
			end
			
		end
		
	
	end
	
	if Action == "Potions" then
		print("potion equip process on")
		local item = ItemData[SessionData[key].Inventory.Potions[itemref].ItemId]
		local PotionsInv = SessionData[key].Inventory.Potions
		local PotionsUsed = SessionData[key].CurrentEquipped.Potions
		local PotionUseTemplate = {
			Duration = 0,
			Attack = 1,
			AttackSpeed = 1,
			Critical = 1,
			Paused = false,
		}
		print(itemref)
		print(itemref.ItemId,SessionData[key].Inventory.Potions[itemref].ItemId )
		print(SessionData[key].Inventory.Potions[itemref])
		print(SessionData[key].Inventory.Potions[itemref] ~= nil)
		if SessionData[key].Inventory.Potions[itemref] == nil then
			print("itemref mismatch")
			return nil
		end
		
			print("this is itemref: ",itemref)
			item = SessionData[key].Inventory.Potions[itemref]
			local potion = ItemData[itemref.ItemId]
			print(ItemData)
			print(SessionData[key].Inventory.Potions[tostring(itemref)])
			--learn how to make an update event happen only on one client
			if SessionData[key].Inventory.Potions[itemref].Quantity > 0 then
				item.Quantity -= 1
				
				if SessionData[key].CurrentEquipped.Potions[potion.Name] == nil then
					SessionData[key].CurrentEquipped.Potions[potion.Name].Stats = PotionUseTemplate
					local PotionStats = SessionData[key].CurrentEquipped.Potions[potion.Name].Stats
					PotionStats.Duration = potion.Duration
					PotionStats.Attack = potion.Attack
					PotionStats.AttackSpeed = potion.AttackSpeed
					PotionStats.Critical = potion.Critical
					PotionStats.Paused = false
				end
				print(SessionData[key].CurrentEquipped.Potions)
				if itemref.Quantity == 0 then
					SessionData[key].Inventory.Potions[itemref] = nil
				end
			end
			
			
		
	end
end

--make another function, for the timer  and stuff for the player, right here or in another dedicated script