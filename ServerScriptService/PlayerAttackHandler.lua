local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local PlayerAttack = ReplicatedStorage.RemoteEvents:WaitForChild("PlayerAttack")
local SessionData = require(game.ServerScriptService.RAM)

PlayerAttack.OnServerEvent:Connect(function(player)
	local key = tostring(player.UserId)
	local now = os.clock()
	print(now - SessionData[key].lastattack >= SessionData[key].AttackSpeed)
	print(now - SessionData[key].lastattack)
	print(now)
	print(SessionData[key].lastattack)
	
	print(now - SessionData[key].lastattack >= SessionData[key].AttackSpeed)
	if now - SessionData[key].lastattack >= SessionData[key].AttackSpeed then
		SessionData[key].lastattack = now
		print("ATTACKKKKKKKKKKKKKKKKKKKKKKKKK")
		
			local hitbox = Instance.new("Part")
			hitbox.Parent = workspace
			hitbox.Anchored = true
			hitbox.CanCollide = false
			hitbox.Transparency = 1
			hitbox.Color = Color3.new(1, 0, 0)
			hitbox.Material = Enum.Material.SmoothPlastic
			hitbox.Size = Vector3.new(5,5,5)
			hitbox.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-6)
			local hitonce = false
			
			local connection = hitbox.Touched:Connect(function(hit)
				if hitonce then return end
				local target = hit.Parent
				if not target then return end
				

				print(target)
				if target:FindFirstChild("Humanoid")  then -- change the hitted and put  the hitted on the AI metatable

					print("is this working")

					if target ~= player.Character then 
						local AIDataTable = require(target:FindFirstChild("AIDataTable"))
						table.insert(AIDataTable.membersattacking, 1 , player)
						print(target.Humanoid.Health)
						hitonce = true
						target.Humanoid.Health = target.Humanoid.Health - 50
						SessionData[key].startbattle = time()
						SessionData[key].attackcooldown = true
					end

				end

			end)
			task.delay(0.5, function()
				if connection then connection:Disconnect() end
			hitbox:Destroy()
			end)
			
			
			
			SessionData[key].attackcooldown = false
		
		
	else
		return
	end
	
	
end)