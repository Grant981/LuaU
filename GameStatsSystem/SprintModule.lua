local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")
local RunService = 	game:GetService("RunService")

local BindableEvent = game:GetService("ServerStorage").BindableEvents
local SprintRemote = ReplicatedStorage.RemoteFolder:WaitForChild("Sprint")

local SprintModule = {}

SprintModule.__index = SprintModule

function SprintModule.new(player) 
	local self = setmetatable({}, SprintModule)

	self.Player = player
	self.Character = player.Character
	self.PlayerGui = player.PlayerGui

	self.StaminaBar = player.PlayerGui.Stats.Stamina.StaminaDecrease
	self.StaminaBarSize = player.PlayerGui.Stats.Stamina.StaminaDecrease.Size.X.Scale
	self.StaminaBarPosition = player.PlayerGui.Stats.Stamina.StaminaDecrease.Position.X.Scale

	self.SPRINT_SPEED = 27
	self.WALK_SPEED = 13
	self.STAMINA = 0 -- 0 Means that the player is at full stamina
	self.MAX_STAMINA = 3000

	self.IsSprinting = false
	self.IsJumping = false
	self.JustLanded = false
	self.IsInAir = false
	
	self.LandedDebounce = false
	self.JumpDebounce = false
	
	self.PlayerIsDead = false
	
	self.LandedDebounceLoop = nil
	SprintRemote.OnServerEvent:Connect(function(plr, isSprinting)
		if self.PlayerIsDead then return end
		
		if isSprinting then		
			self.Character.Humanoid.WalkSpeed  = self.SPRINT_SPEED		
			
		else			
			self.Character.Humanoid.WalkSpeed = self.WALK_SPEED
		end
	
		self.IsSprinting = isSprinting
	end)
	
	
	
	BindableEvent.ResetStats.Event:Connect(function()
	
		self.STAMINA = 0
		self.IsSprinting = false
		self.IsJumping = false
		self.JustLanded = false
		self.IsInAir = false
		self.LandedDebounce = false
		self.JumpDebounce = false
		self.StaminaBarSize = 0
		self.StaminaBarPosition = 1
		self.JustLandedWaited = false
		self.JustLandedDeb = false
		self.LandedDebounceLoop:Disconnect()
		self.Character.Humanoid.WalkSpeed = self.WALK_SPEED
		self:ReturnDead()
		self:JumpAdjust()
		self.PlayerIsDead  = false
	end)
	
	self:ReturnDead()
	self:JumpAdjust()
	self:StaminaAdjust()
	self:JustLandedWait()

	return self
end

function SprintModule:ReturnDead()
	self.Character.Humanoid.Died:Connect(function()

		self.PlayerIsDead = true
		print("Player is dead "..tostring(self.PlayerIsDead))
	end)
end

function SprintModule:TweenCommand()
	local tweenInfo = TweenInfo.new(.1, Enum.EasingStyle.Linear,  Enum.EasingDirection.Out,0,false)
	local tweenData = {
		Position = UDim2.new(self.StaminaBarPosition, 0, 0, 0),
		Size = UDim2.new(self.StaminaBarSize, 0, 1, 0)
	} 
	TweenService:Create(self.StaminaBar, tweenInfo, tweenData):Play()
end

function SprintModule:JustLandedWait() --this is required because if you put it in the RunService loops with a normal wait it will call multiple waits

	self.JustLandedDeb = false
	RunService.Heartbeat:Connect(function()
		if self.JustLandedDeb or self.PlayerIsDead then return false end
		if not self.IsJumping and self.JustLandedWaited then
			self.JustLanded = false
			self.JustLandedWaited = false
		else
			self.JustLandedDeb = true
			wait(2)
			self.JustLandedWaited = true
			self.JustLandedDeb = false
		end
	end)
end

function SprintModule:JumpAdjust()

	local STAMINA_JUMP_DECREASE = 50

	
	self.Character:WaitForChild('Humanoid'):GetPropertyChangedSignal("Jump"):Connect(function()
		

		if self.JumpDebounce or self.IsInAir or self.PlayerIsDead then return end
		self.JumpDebounce = true
		self.IsJumping = true
		if self.STAMINA + STAMINA_JUMP_DECREASE > self.MAX_STAMINA then
			-- If the player jumps and the jump will use up all the stamina set all the values to how the StaminaDecrease would when the Stamina is used up.
			--KEEP it that way with this if statement until the stamina regenerates.
			self.STAMINA = self.MAX_STAMINA
			self.StaminaBarSize = 1
			self.StaminaBarPosition = 0
		else
			--print("firedd")
			self.STAMINA +=STAMINA_JUMP_DECREASE
			self.StaminaBarSize = self.STAMINA/self.MAX_STAMINA
			self.StaminaBarPosition = 1-(self.STAMINA/self.MAX_STAMINA)
		end

		self:TweenCommand()

		wait(.2) -- Wait this ammount because I just entered it and it waits long enough for it to not detect twice. 
		self.JumpDebounce = false

	end)

	
	self.LandedDebounceLoop = RunService.Heartbeat:Connect(function(dt)
		
		if self.LandedDebounce then return end
		if self.Character.Torso.Velocity.Y > 10 then -- Are they in the air?
			self.IsInAir = true
			self.LandedDebounce = true
			repeat RunService.Heartbeat:Wait() until self.Character.Torso.Velocity.Y <= 0 -- When do they land?
			self.IsInAir = false

			self.IsJumping = false
			self.JustLanded = true

			
			wait(.1)
			self.LandedDebounce = false
		end
	end)
	
	
end


function SprintModule:StaminaAdjust()
	RunService.Heartbeat:Connect(function()
		if self.Player.Character == nil then return end --There is an error when quitting the game, this prevents that.
		if self.Player.Character:FindFirstChild("Humanoid") == nil then return end
		if self.StaminaBarSize >= 1 then
			self.Player.Character.Humanoid.WalkSpeed = self.WALK_SPEED
		end

		local currentState = self.Player.Character.Humanoid:GetState()
		local moveDirMag = self.Player.Character.Humanoid.MoveDirection.Magnitude

		local running = Enum.HumanoidStateType.Running
		local jumping = Enum.HumanoidStateType.Jumping
		local runningNoPhysics = Enum.HumanoidStateType.RunningNoPhysics


		if self.IsSprinting and self.STAMINA < self.MAX_STAMINA and (currentState == running or currentState == runningNoPhysics) and moveDirMag > 0 then
			--print("Decrease Stamina")
			self.STAMINA +=1
			self.StaminaBarSize = self.STAMINA/self.MAX_STAMINA
			self.StaminaBarPosition = 1-(self.STAMINA/self.MAX_STAMINA)  
			-- ^^ The Const is needed as the scale value of a GUI is 0-1 and 1 being the largest possible relative to the constraints given to it. 1-(percent of stamina used)

		end

		if (((currentState == running or currentState == runningNoPhysics) and moveDirMag <= 0 and self.STAMINA > 0 and not self.IsJumping) or (not self.IsSprinting and self.STAMINA > 0 and not self.IsJumping)) and not self.JustLanded then

			self.STAMINA -=1
			self.StaminaBarSize = self.STAMINA/self.MAX_STAMINA
			self.StaminaBarPosition = 1-(self.STAMINA/self.MAX_STAMINA)

		end	

		self:TweenCommand()
	end)
end



return SprintModule


