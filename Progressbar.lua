--[[
Developed by @Grant981
This bar is a progress bar for an obby based on a checkpoint system starting at part named START then going from 1-n amount of parts.

This script if implimented inside roblox studio needs to have folders for a player progress bar and a player icon for the bar.
ProgressBarModule is to be called on a playeradded server event
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local PlayerService = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local function playerLeaveEvent(plr : Player)
	for _, plr in ipairs(PlayerService:GetPlayers()) do
		local progBarTemplate = plr.PlayerGui:FindFirstChild("ProgressBarTemplate")
		if progBarTemplate then
			local plrIcon = progBarTemplate.Bar:FindFirstChild(tostring(plr.UserId))
			if plrIcon ~= nil then
				plrIcon:Destroy()
			end
		end
	end
end

local ProgressBarModule = {}

ProgressBarModule.__index = ProgressBarModule

function ProgressBarModule.new(plr : Player)
	
	local self = setmetatable({}, ProgressBarModule)
	
	self.ProgressBar = nil
	self.PlayerId = plr.UserId
	
	self.CurrentProgressLocation = 0
	self.MaxLocationNumber = nil
	
	self:InitalizeProgressBar(plr)
	
	return self
	
end

function ProgressBarModule:InitalizeProgressBar(modulesPlayer : Player)
	
	local progTemplate = ServerStorage._Guis.ProgressBarTemplate:Clone()
	self.ProgressBar = progTemplate
	progTemplate.Parent = modulesPlayer.PlayerGui
	
	for _, plr in ipairs(PlayerService:GetPlayers()) do --We want to interate through all the players including the modulesPlayer to add everyone to the bar.
		
		self:AddPlayerIcon(plr).Parent = progTemplate.Bar
		
	end
	
	PlayerService.PlayerRemoving:Connect(playerLeaveEvent)
	
	PlayerService.PlayerAdded:Connect(function(plr)
		self:AddPlayerIcon(plr).Parent = progTemplate.Bar
	end)
	
end

function ProgressBarModule:TweenPlayerProgress(plr : Player, progBar : ScreenGui)
	
	if self.MaxLocationNumber == nil then return end
	if self.CurrentProgressLocation == 0 then print("CurrentProgresssLocation is zero.") end
	
	local bar = progBar.Bar
	local playerTemplate = progBar.Bar:FindFirstChild(tostring(plr.UserId))
	local barToPlayerTemplateDistance = ServerStorage._Guis.ReferenceProgBar.Bar.PlayerTemplate.Position.Y.Scale --Const Distance
	local growthConstant = (1)/(self.MaxLocationNumber)
	
	local goals = {
		Position = UDim2.new(playerTemplate.Position.X.Scale,0,(barToPlayerTemplateDistance)-(growthConstant*self.CurrentProgressLocation),0)
	}

	local tweenInfo = TweenInfo.new(.4, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0,false,0)

	local newTween = TweenService:Create(playerTemplate, tweenInfo, goals)
	newTween:Play()
	
end

function ProgressBarModule:MovePlayerOnAllClients(plrToUpdate : Player)

	for _, plr in ipairs(PlayerService:GetPlayers()) do
		local progBarTemplate = plr.PlayerGui:FindFirstChild("ProgressBarTemplate")
		if progBarTemplate then
			self:TweenPlayerProgress(plrToUpdate, progBarTemplate)
		end
	end
	
end

function ProgressBarModule:AddPlayerIcon(plr : Player)
	local playerTemplate = ServerStorage._Guis.PlayerTemplate:Clone()
	local userId = plr.UserId
	local thumbType = Enum.ThumbnailType.HeadShot
	local thumbSize = Enum.ThumbnailSize.Size420x420
	local content, isReady = PlayerService:GetUserThumbnailAsync(userId, thumbType, thumbSize)

	if isReady then
		playerTemplate.Image = content
	else 
		warn("Icon can't load!")
	end

	playerTemplate.Name = tostring(userId)

	return playerTemplate
end

function ProgressBarModule:ResetPlayerIcon(plr : Player)

	self:SetLocationValue(0)
	self:MovePlayerOnAllClients(plr)

end


function ProgressBarModule:Disable()
	
	if self.ProgressBar ~= nil then
		self.ProgressBar.Enabled  = false
	else
		warn("Progress bar called to be disabled but no bar was detected.")
	end
	
end


function ProgressBarModule:Enable()

	if self.ProgressBar ~= nil then
		self.ProgressBar.Enabled  = true
	else
		warn("Progress bar called to be enabled but no bar was detected.")
	end
	
end

function ProgressBarModule:SetLocationValue(num : number)

	self.CurrentProgressLocation = num
	
end

return ProgressBarModule



