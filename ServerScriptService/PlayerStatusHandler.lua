local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Run = game.ReplicatedStorage.RemoteEvents:WaitForChild("Run")
local RunService = game:GetService("RunService")
local SessionData = require(game.ServerScriptService.RAM)



local StaminaUpdate = game.ReplicatedStorage.RemoteEvents.StaminaUpdate

StaminaUpdate.OnServerEvent:Connect(function(player)
	local key = tostring(player.UserId)

	if SessionData[key].Stamina < SessionData[key].MaxStamina and SessionData[key].running == false then --later on make it a cooldown thing, where it waits before it gives stamina

		SessionData[key].Stamina += 10 
		if SessionData[key].Stamina > SessionData[key].MaxStamina then
			SessionData[key].Stamina = SessionData[key].MaxStamina

		end
		task.wait(1)
	end

end)

task.spawn(function() --In Battle Checker
	
	while true do
		
		for i, player in pairs(game.Players:GetPlayers()) do
			
			local key = tostring(player.UserId)
			repeat task.wait() until SessionData[key] ~= nil
			
			if SessionData[key].InBattle == false and player.Character ~= nil then
				player.Character:WaitForChild("Health").Enabled = true
				
			elseif SessionData[key].InBattle == true and player.Character ~= nil then
				player.Character:WaitForChild("Health").Enabled = false
				
			end
			
			if time() - SessionData[key].startbattle >= 2  then
			
				SessionData[key].InBattle = false
				
				
			else
			
				SessionData[key].InBattle = true
			end
			
		end
		
		task.wait(0.5)
	end
end)

Run.OnServerEvent:Connect(function(player)
	local key = tostring(player.UserId)
	print("running executed")
	local character = player.Character
	SessionData[key].running = true
	
	
	task.spawn(function()
		
		while SessionData[key].running do
			
			if SessionData[key].running == true and SessionData[key].Stamina > 1 then
				character.Humanoid.WalkSpeed = 30
				SessionData[key].Stamina -= 1
			else
				character.Humanoid.WalkSpeed = 16
			end
			
			
			
			task.wait(0.1)
		end
		
		
	end)
	
	
end)
local StopRun = game.ReplicatedStorage.RemoteEvents.StopRun

StopRun.OnServerEvent:Connect(function(player)
	local key = tostring(player.UserId)
	local character = player.Character
	

		
		SessionData[key].running = false
		
	character.Humanoid.WalkSpeed = 16
end)

local ExpUpdate = game.ReplicatedStorage.RemoteEvents.ExpUpdate
ExpUpdate.OnServerEvent:Connect(function(player)
	local key = tostring(player.UserId)
	
	
	if SessionData[key].Exp >= SessionData[key].MaxExp and SessionData[key].Level < SessionData[key].MaxLevel then
		
		
		
		SessionData[key].Exp = 0
		SessionData[key].MaxExp *= 1.5
		SessionData[key].MaxStamina = (SessionData[key].MaxStamina^(1+(SessionData[key].Level*0.15)))
		SessionData[key].Stamina = SessionData[key].MaxStamina                  --balance this out later.... too strongggg
		SessionData[key].MaxHealth = (SessionData[key].MaxHealth^(1+(SessionData[key].Level*0.1)))
		SessionData[key].Health = SessionData[key].MaxHealth
		player.Character.Humanoid.MaxHealth = SessionData[key].MaxHealth
		player.Character.Humanoid.Health = SessionData[key].Health --unnecesaray but too lazy to change it
		SessionData[key].Level += 1
		print("Level up")
		print("New level: "..SessionData[key].Level)
		task.wait(0.5)
		
	end
	
	
end)
