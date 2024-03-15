--[[
This module manages the amount of time a player can spend underwater before they start to lose health, based on the position of the head on the water terrain in Roblox. The heads detection position is two studs above the actual head position to account for the player swimming on the surface.
Made by @Grant 2022 
]]


local constant = 20

local TankTypes = {

	["SingleSteel"] = 50,
	["DualSteel"] = 100,
	["SingleNitrox"] = 300,
	["DualNitrox"] = 600

}

local Lighting = game:GetService( 'Lighting' )
local TweenService = game:GetService( 'TweenService' )

local OxygenManager = {}

OxygenManager.__index = OxygenManager

function OxygenManager.new(player)
	local self = setmetatable({}, OxygenManager)
	self.AirTime = constant
	self.MaxAirTime = constant
	self.Character = player
	self.isTank = false
	self.SwitchTrigger = true
	self.Trigger2 = true
	return self
end

function OxygenManager:Init()
	self.Character.ChildAdded:Connect(function(child)
		self:addTank(child)
	end)
	self.Character.ChildRemoved:Connect(function(child)
		if child:GetAttribute("isTank") then
			self.isTank = false
		end
	end)
	
	coroutine.wrap(function()
		while wait() do
			
			if self:underWater()  and self.Trigger2 then
				
			
				self.Trigger2 = false
			else if not self:underWater() and not self.Trigger2 then

					self.Trigger2 = true
				end
			end
			self:StatusUpdater(self:underWater(),self.isTank)
		end
	end)()
end

function OxygenManager:underWater()
	local region = Region3.new(self.Character.Head.Position+Vector3.new(0,2,0),self.Character.Head.Position+Vector3.new(0,2,0))
	region = region:ExpandToGrid(4) 
	local material, occupancies = game.Workspace.Terrain:ReadVoxels(region, 4)
	local size = material.Size
	for x = 1, size.X do
		for y = 1, size.Y do
			for z = 1, size.Z do
				
				if material[x][y][z] == Enum.Material.Water then
					return true
				else
					return false
				end

			end
		end
	end    
end

function OxygenManager:addTank(child)
	if TankTypes[child.Name] then	
		self.isTank = true
		self.AirTime = TankTypes[child.Name]
		self.MaxAirTime = TankTypes[child.Name]
		print(self.MaxAirTime)
		print(self.AirTime)
	end
end

function OxygenManager:StatusUpdater(status, isTank)
	if self.AirTime <= 0 and status then
		self.Character.Humanoid.Health -= 10 
		wait(.5)
	else if self.AirTime > 0 and status then
			self.AirTime -= 1 print(self.AirTime)	
			wait(1)

		else if (not isTank) and self.AirTime < self.MaxAirTime and (not status) then
				self.AirTime += 1 print(self.AirTime)
		wait(1)
			end
		end
	end
end

return OxygenManager
