local SprintModule = require(script.SprintModule)
local HealthModule = require(script.HealthModule)

local BindableEvent = game:GetService("ServerStorage"):WaitForChild("BindableEvents")
local StatsModule = {}

StatsModule.__index = StatsModule

function StatsModule.new(player)
	local self = setmetatable({}, StatsModule) -- when a a humanoid dies that players character needs to be updated for any function like self.Character:WaitForChild('Humanoid'):GetPropertyChangedSignal("Jump"):Connect(function()
	
	self.HealModule = HealthModule.new(player)
	self.SprintModule = SprintModule.new(player)
	
	return self
end

function StatsModule:Reset(newCharacter)
	self.HealModule.Character = newCharacter
	self.SprintModule.Character = newCharacter
	BindableEvent.ResetStats:Fire()
end


return StatsModule
