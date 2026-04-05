local SessionData = {}



function SessionData:Get(player)
	return self[tostring(player.UserId)]
end


function CheckItem(player, item)
	
	local key = tostring(player.UserId)
	
	local itemtable = {}
	
	
	
end


return SessionData
