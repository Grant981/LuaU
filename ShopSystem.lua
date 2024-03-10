--[[

This is a shop system for game titles above the players head, gamepasses and roblox UGC limited items

This runs of table data from modulescripts named accordingly for UGC and gamepass items and for titles it works off of Title objects store in server storage

]]

local UserInputService = game:GetService("UserInputService")
local PlayerService = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataManager = require(game:GetService("ServerScriptService").PlayerScripts.DataManager)

local _ShopData = ServerStorage._ShopData
local _Guis = ServerStorage._Guis
local AssetID = 16365264216

local ShopV2Module = {}

local prompPassed = nil

ShopV2Module.__index = ShopV2Module

local function ConnectClick(button, isMobile : boolean, func)
	if isMobile then
		button.TouchTap:Connect(func)
	else
		button.MouseButton1Click:Connect(func)
	end
end

local function InitalizeShopLocations(plr : Player, shopFrame: Frame)
	for _, v in ipairs(game:GetService("Workspace"):GetDescendants()) do
		if v:HasTag("Shop") and v:IsA("Part") then
			v.Touched:Connect(function(hit)
				local humanoid = hit.Parent:FindFirstChild("Humanoid") 
				if humanoid and PlayerService:GetPlayerFromCharacter(humanoid.Parent).UserId == plr.UserId then
					shopFrame.Visible = true
				end
			end)
		end
	end
	
end

local function abbreviateNumber(num)	
	if num > 1000000000000 then
		return tostring(math.floor(num /  100000000000) / 10).."T"
	elseif num > 1000000000 then
		return tostring(math.floor(num /  100000000) / 10).."B"
	elseif num > 1000000 then
		return tostring(math.floor(num /  100000) / 10).."M"
	elseif num > 1000 then
		return tostring(math.floor(num /  100) / 10).."K"
	else 
		return tostring(num)
	end
end

local function promptGamepassPurchase(player : Player, passID)
	local hasPass = false
	
	local success, message = pcall(function()
		hasPass = MarketplaceService:UserOwnsGamePassAsync(player.UserId, passID)
	end)

	if not success then
		warn("Error while checking if player has pass: " .. tostring(message))
		return
	end

	if hasPass then
		print("Already Owns")
	else
		MarketplaceService:PromptGamePassPurchase(player, passID)
	end
end

function ShopV2Module.new(plr : Player ,shopButton : ImageButton, shopFrame : Frame)
	local self = setmetatable({}, ShopV2Module)
	
	self.Player = plr
	self.currentCategory = nil
	self.IsMobile = not UserInputService.MouseEnabled
	self.shopFrame = shopFrame
	
	self.EquippedTitle = nil
	self.SelectedTitle = nil
	
	self.SelectedItemId = nil
	
	self.SelectedUGC = nil
	
	self.PurchaseDisplay = shopFrame:FindFirstChild("PURCHASE_DISPLAY")
	self.Data = plr:WaitForChild("Data")
	
	ConnectClick(shopButton, self.IsMobile, function()
		shopFrame.Visible = true
	end)
	
	InitalizeShopLocations(plr, shopFrame)

	return self
end

function ShopV2Module:CategoryButton(button : TextButton, CategoryModuleName : string)
	
	ConnectClick(button, self.IsMobile, function()
		
		local dataModule = _ShopData[CategoryModuleName]
		local SCROLLING_FRAME = self.shopFrame.ITEMS_SCROLL_FRAME.SCROLLING_FRAME
		if dataModule or CategoryModuleName == ServerStorage._ShopData.Titles.Name then -- Since the titles purchase system isn't running off of a table from a module script you gotta check for the titles name cuz yeah look lmfao
			
			
			

			if CategoryModuleName == _ShopData.GamepassDataModule.Name then
				self:EnablePurchaseButton()
				self.currentCategory = CategoryModuleName
				local requiredModule = require(dataModule)	
				SCROLLING_FRAME:FindFirstChild("ITEM_LIST"):Destroy()
				local ITEM_LIST = _Guis.ITEM_LIST:Clone()
				ITEM_LIST.Parent = SCROLLING_FRAME
				
				for id,_ in pairs(requiredModule) do
					local ItemTemplate = _Guis.Shop_Item_Template:Clone()
					
					local GamepassInfo = MarketplaceService:GetProductInfo(id, Enum.InfoType.GamePass)
					
					self.PurchaseDisplay.TitleDisplay.Visible = false
					self.PurchaseDisplay.ImageLabel.Visible = true
					self.SelectedItemId = id
					self.PurchaseDisplay.ImageLabel.Image = "rbxassetid://"..GamepassInfo.IconImageAssetId
					self.PurchaseDisplay.Cost.Text = tostring("ROBUX: "..GamepassInfo.PriceInRobux)
					
					ConnectClick(ItemTemplate.ImageButton, self.IsMobile, function() 
						if self.PurchaseDisplay then
							
							self.PurchaseDisplay.TitleDisplay.Visible = false
							self.PurchaseDisplay.ImageLabel.Visible = true
							self.SelectedItemId = id
							self.PurchaseDisplay.ImageLabel.Image = "rbxassetid://"..GamepassInfo.IconImageAssetId
							self.PurchaseDisplay.Cost.Text = tostring("ROBUX: "..GamepassInfo.PriceInRobux)
							
						end
					end)
					
					ItemTemplate.ImageFrame.TextLabel.Visible = false
					ItemTemplate.ImageFrame.ImageLabel.Visible = true 
					ItemTemplate.ImageFrame.ImageLabel.Image = "rbxassetid://"..GamepassInfo.IconImageAssetId
					ItemTemplate.ItemName.Text = GamepassInfo.Name
					ItemTemplate.ItemCost.Text = tostring(GamepassInfo.PriceInRobux)
					ItemTemplate.Parent = ITEM_LIST

				end	

			else if CategoryModuleName == ServerStorage._ShopData.Titles.Name then
					
					self.currentCategory = CategoryModuleName
					SCROLLING_FRAME:FindFirstChild("ITEM_LIST"):Destroy()
					local ITEM_LIST = _Guis.ITEM_LIST:Clone()
					ITEM_LIST.Parent = SCROLLING_FRAME
					
					for _, title in ipairs(_ShopData.Titles:GetChildren()) do -- Loop through all titles listed to display
				
							local ItemTemplate = _Guis.Shop_Item_Template:Clone()
							
							
							ConnectClick(ItemTemplate.ImageButton, self.IsMobile, function() 
								if self.PurchaseDisplay then
									self.SelectedTitle = title
									
									if self.Data.PlayerData.Titles:FindFirstChild(self.SelectedTitle.Name) then
										
										
										if self.EquippedTitle == self.SelectedTitle.Name then
											self:EnableUnequipButton()
										else
											self:EnableEquipButton()	
										end
										
									else
										self:EnablePurchaseButton()	
									end
									
									local titleClone = title.TextLabel:Clone() -- clones the text label with how it looks to display
									self.PurchaseDisplay.TitleDisplay.Visible = true
									self.PurchaseDisplay.ImageLabel.Visible = false
									self.PurchaseDisplay.Cost.Text = tostring("Souls: "..tostring(title:GetAttribute("Cost")))
									
									for _, items in ipairs(self.PurchaseDisplay.TitleDisplay:GetChildren()) do
										items:Destroy()
									end
									
									titleClone.Parent = self.PurchaseDisplay.TitleDisplay
									
								end
							end)

							ItemTemplate.ImageFrame.ImageLabel.Visible = false
							ItemTemplate.ItemName.Text = ""
							ItemTemplate.ImageFrame:FindFirstChild("TextLabel"):Destroy()
							ItemTemplate.ItemCost.Text = tostring(title:GetAttribute("Cost"))
							ItemTemplate.Parent = ITEM_LIST
							
							
							local titleClone = title.TextLabel:Clone() -- clones the text label with how it looks to display
							titleClone.Size = UDim2.fromScale(.8,.5)
							titleClone.Position = UDim2.fromScale(.1,0.25)
							titleClone.Parent = ItemTemplate.ImageFrame
					
					
					
					end
					
				else if CategoryModuleName == ServerStorage._ShopData.UGCDataModule.Name then
						self:EnablePurchaseButton()
						self.currentCategory = CategoryModuleName
						local requiredModule = require(dataModule)	
						SCROLLING_FRAME:FindFirstChild("ITEM_LIST"):Destroy()
						local ITEM_LIST = _Guis.ITEM_LIST:Clone()
						ITEM_LIST.Parent = SCROLLING_FRAME

						for id,_ in pairs(requiredModule) do
							local ItemTemplate = _Guis.Shop_Item_Template:Clone()

							local UGC_INFO = MarketplaceService:GetProductInfo(id, Enum.InfoType.Asset)

							
							self.PurchaseDisplay.TitleDisplay.Visible = false
							self.PurchaseDisplay.ImageLabel.Visible = true
							
							self.PurchaseDisplay.ImageLabel.Image = "rbxassetid://"..UGC_INFO.IconImageAssetId
							self.PurchaseDisplay.Cost.Text = tostring("200k Souls")
							
							ConnectClick(ItemTemplate.ImageButton, self.IsMobile, function() 
								if self.PurchaseDisplay then

									self.PurchaseDisplay.TitleDisplay.Visible = false
									self.PurchaseDisplay.ImageLabel.Visible = true
									self.SelectedUGC = id
									self.PurchaseDisplay.ImageLabel.Image = "rbxassetid://"..UGC_INFO.IconImageAssetId
									self.PurchaseDisplay.Cost.Text = tostring("200k Souls")
									self.PurchaseDisplay.Description.Text = UGC_INFO.Name
								end
							end)
							
							
							ItemTemplate.ImageFrame.TextLabel.Visible = false
							ItemTemplate.ImageFrame.ImageLabel.Visible = true 
							ItemTemplate.ImageFrame.ImageLabel.Image = "rbxassetid://"..UGC_INFO.IconImageAssetId
							ItemTemplate.ItemName.Text = UGC_INFO.Name
							ItemTemplate.ItemCost.Text = "200k Souls"
							ItemTemplate.Parent = ITEM_LIST

						end		
				    end
			    end 
			end
		else
			warn("No shop data assigned to the selected button named " .. button.Name)
			end
		
	end)
end


function ShopV2Module:PurchaseButton(button : TextButton)
	ConnectClick(button, self.IsMobile, function() 
		if self.currentCategory == ServerStorage._ShopData.Titles.Name then
			if (self.Data.PlayerData.Coins.Value - self.SelectedTitle:GetAttribute("Cost")) >= 0 then
				DataManager:SetValue(self.Player,"Coins", self.Data.PlayerData.Coins.Value - self.SelectedTitle:GetAttribute("Cost"))
				DataManager:SaveTitle(self.Player, self.SelectedTitle)
				self:EnableEquipButton()
			end
		else if self.currentCategory == ServerStorage._ShopData.GamepassDataModule.Name then
			promptGamepassPurchase(self.Player, self.SelectedItemId)	
			else if self.currentCategory == ServerStorage._ShopData.UGCDataModule.Name then
					
					if self.SelectedUGC == AssetID then
						if (self.Data.PlayerData.Coins.Value - 200000) >= 0 then
							
							MarketplaceService:PromptPurchase(self.Player, AssetID)
							MarketplaceService.PromptPurchaseFinished:Connect(PPFinished)
							while prompPassed == nil do
								print("ERROR")
								task.wait()
							end
							
							if prompPassed then
								DataManager:SetValue(self.Player,"Coins", self.Data.PlayerData.Coins.Value - 200000)
							end
						else
							print("UR POOOOOORRRRRRR")
						end
					end
				end
			end
		end
		
	end)
end

function PPFinished(User, BuyedAsset, isPurchased) -- Verify Status Of Player Purchase
	if BuyedAsset == AssetID  then
		if isPurchased then -- If Purchase is sucessfull do things
			prompPassed = true
		else -- Same but if NOT sucessfull
			prompPassed = false
		end
	end
end

function ShopV2Module:EquipButton(button : TextButton)
	ConnectClick(button, self.IsMobile, function() 
		for i,v in ipairs(self.Player.Character:FindFirstChild("Head"):GetChildren()) do
			if self.Data.PlayerData.Titles:FindFirstChild(v.Name) then
				v:Destroy()
			end
		end
		
		if self.Data.PlayerData.Titles:FindFirstChild(self.SelectedTitle.Name) then
			self:EnableUnequipButton()
			self.EquippedTitle = self.SelectedTitle.Name
			self.SelectedTitle:Clone().Parent = self.Player.Character:FindFirstChild("Head")	
		end

	end)

end


function ShopV2Module:UnequipButton(button : TextButton)
	ConnectClick(button, self.IsMobile, function() 
			for i,v in ipairs(self.Player.Character:FindFirstChild("Head"):GetChildren()) do
				self:EnableEquipButton()
				if self.Data.PlayerData.Titles:FindFirstChild(v.Name) then
					v:Destroy()
				end
			end
	end)
end

function ShopV2Module:CoinsDisplay(frame : Frame)
	local amount = frame:FindFirstChild("Amount")
	if amount then
		amount.Text = "Souls: "..abbreviateNumber(self.Data.PlayerData.Coins.Value)
		self.Data.PlayerData.Coins:GetPropertyChangedSignal("Value"):Connect(function()
			amount.Text = "Souls: "..abbreviateNumber(self.Data.PlayerData.Coins.Value)
		end)
	end
end

function ShopV2Module:CloseButton(button : TextButton)
	button.MouseButton1Click:Connect(function()
		self.shopFrame.Visible = false
	end)
end

function ShopV2Module:EnablePurchaseButton()
	self.shopFrame.PURCHASE_BUTTON.Visible = true
	self.shopFrame.UNEQUIP_BUTTON.Visible = false
	self.shopFrame.EQUIP_BUTTON.Visible = false
end

function ShopV2Module:EnableEquipButton()
	self.shopFrame.PURCHASE_BUTTON.Visible = false
	self.shopFrame.UNEQUIP_BUTTON.Visible = false
	self.shopFrame.EQUIP_BUTTON.Visible = true
end

function ShopV2Module:EnableUnequipButton()
	self.shopFrame.PURCHASE_BUTTON.Visible = false
	self.shopFrame.UNEQUIP_BUTTON.Visible = true
	self.shopFrame.EQUIP_BUTTON.Visible = false
end






return ShopV2Module



