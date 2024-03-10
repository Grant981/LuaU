local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")
local RunService = 	game:GetService("RunService")

local BindableEvent = game:GetService("ServerStorage").BindableEvents
local HealthModule = {}

HealthModule.__index = HealthModule

function HealthModule.new(player) 
	local self = setmetatable({}, HealthModule)
	
	self.Player = player
	self.Character = player.Character
	self.PlayerGui = player.PlayerGui

	self.HealthBar = player.PlayerGui.Stats.Health.HealthDecrease
	self.HealthBarSize = self.HealthBar.Size.X.Scale
	self.HealthBarPosition = self.HealthBar.Position.X.Scale

	self.MAX_HEALTH = 100
	
	BindableEvent.ResetStats.Event:Connect(function()
		self.HealthBarSize =  0
		self.HealthBarPosition =  1
		self:TweenHealth()
		self:HealthChange()
	end)
	
	self:HealthChange()
	
	return self
end



function HealthModule:TweenHealth()
	local TI = TweenInfo.new(.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false)
	local TD = {
		Position = UDim2.new(self.HealthBarPosition,0,0,0),
		Size = UDim2.new(self.HealthBarSize,0,1,0)
	}
	
	TweenService:Create(self.HealthBar,TI, TD):Play()

end

function HealthModule:GetDecimals(num) -- gets the length of health like if 100000 and gets the decimals needed to covert on a 0-1 scale
	
	return math.pow(0.1,string.len(tostring(num)-1))
end

function HealthModule:HealthChange()
	
	self.Character:WaitForChild("Humanoid"):GetPropertyChangedSignal("Health"):Connect(function(h)
	
		local CURRENT_HEALTH = self.Player.Character:FindFirstChild("Humanoid").Health
		local CONST = HealthModule:GetDecimals(self.MAX_HEALTH)
		self.HealthBarSize = (self.MAX_HEALTH - (CURRENT_HEALTH)) *  CONST--when self.MAX_HEALTH - (CURRENT_HEALTH) = 0 that means health is at max 
		self.HealthBarPosition = 1-(self.MAX_HEALTH - (CURRENT_HEALTH)) * CONST
		self:TweenHealth()
	end)

end








return HealthModule
