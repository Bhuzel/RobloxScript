pcall(function()
	if setclipboard then
		setclipboard("Made By Bhuzel")
	elseif toclipboard then
		toclipboard("Made By Bhuzel")
	end
end)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser") -- [TAMBAHAN ANTI-AFK]

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- =================================================================
-- ANTI-AFK SYSTEM (Bypass Kick 20 Menit)
-- =================================================================
player.Idled:Connect(function()
	VirtualUser:CaptureController()
	VirtualUser:ClickButton2(Vector2.new())
end)

pcall(function()
	for _, connection in pairs(getconnections(player.Idled)) do
		connection:Disable()
	end
end)
-- =================================================================

-- Cleanup Gui Lama
for _, old in pairs(playerGui:GetChildren()) do
	if old.Name == "ElegantSaveLoadGuiV2" then old:Destroy() end
end

-- Setup GUI Utama
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ElegantSaveLoadGuiV2"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Variable Kontrol Global
local isLooping = false
local isPlaying = false
local isPaused = false
local autoThread = nil
local currentPoint = 1
local rows = {}

-- =================================================================
-- FILE SYSTEM CHECK & SETUP (AUTO LOAD)
-- =================================================================
local fsSupported = (type(writefile) == "function" and type(readfile) == "function" and type(makefolder) == "function" and type(isfolder) == "function")
local FOLDER_NAME = "ZellRayyAutoTeleport"
local SETTINGS_FILE = FOLDER_NAME .. "/Settings.json"
local MAP_FILE = FOLDER_NAME .. "/Place_" .. tostring(game.PlaceId) .. ".json"

local autoLoadEnabled = false

if fsSupported then
	if not isfolder(FOLDER_NAME) then
		makefolder(FOLDER_NAME)
	end
	-- Load Global Settings
	if isfile and isfile(SETTINGS_FILE) then
		local suc, res = pcall(function() return HttpService:JSONDecode(readfile(SETTINGS_FILE)) end)
		if suc and type(res) == "table" then
			autoLoadEnabled = res.autoLoad or false
		end
	end
end

local function saveSettings()
	if not fsSupported then return end
	pcall(function()
		writefile(SETTINGS_FILE, HttpService:JSONEncode({autoLoad = autoLoadEnabled}))
	end)
end

local function saveCurrentMapData()
	if not fsSupported or not autoLoadEnabled then return end
	local exportData = {}
	for _, r in ipairs(rows) do
		local pos = r.getPos()
		if pos then
			table.insert(exportData, {
				nameBhuzelRayhan = r.nameBox.Text,
				delayBhuzelRayhan = tonumber(r.delayBox.Text) or 5,
				x = pos.X, y = pos.Y, z = pos.Z
			})
		end
	end
	pcall(function()
		writefile(MAP_FILE, HttpService:JSONEncode(exportData))
	end)
end

-- =================================================================
-- FUNGSI DRAGGING UNIVERSAL
-- =================================================================
local function enableDragging(dragHandle, targetFrame, constrainToScreen)
	local dragging, dragInput, dragStart, startPos

	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = targetFrame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)

	dragHandle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			local viewportSize = workspace.CurrentCamera.ViewportSize
			
			local absStartX = (startPos.X.Scale * viewportSize.X) + startPos.X.Offset
			local absStartY = (startPos.Y.Scale * viewportSize.Y) + startPos.Y.Offset
			
			local newAbsX = absStartX + delta.X
			local newAbsY = absStartY + delta.Y
			
			if constrainToScreen then
				local maxX = viewportSize.X - targetFrame.AbsoluteSize.X
				local maxY = viewportSize.Y - targetFrame.AbsoluteSize.Y
				newAbsX = math.clamp(newAbsX, 0, maxX)
				newAbsY = math.clamp(newAbsY, 0, maxY)
			end
			
			game:GetService("TweenService"):Create(targetFrame, TweenInfo.new(0.08), {Position = UDim2.new(0, newAbsX, 0, newAbsY)}):Play()
		end
	end)
end

local function createButton(parent, text, color, size, pos)
	local btn = Instance.new("TextButton")
	btn.Size = size
	btn.Position = pos
	btn.Text = text
	btn.Font = Enum.Font.GothamMedium
	btn.TextSize = 11
	btn.TextColor3 = Color3.fromRGB(240, 240, 240)
	btn.BackgroundColor3 = color
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = true
	btn.Parent = parent
	
	local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0, 5) corner.Parent = btn
	local stroke = Instance.new("UIStroke") stroke.Color = Color3.fromRGB(60, 60, 60) stroke.Thickness = 1 stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border stroke.Parent = btn
	return btn
end

-- =================================================================
-- MAIN CONTAINER SETUP
-- =================================================================
local container = Instance.new("Frame")
container.Size = UDim2.new(0, 250, 0, 420) -- Diperpanjang sedikit untuk slot Auto Load
container.Position = UDim2.new(0.5, -125, 0.5, -210)
container.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
container.BorderSizePixel = 0
container.ClipsDescendants = true
container.Visible = true
container.Parent = screenGui

local containerCorner = Instance.new("UICorner") containerCorner.CornerRadius = UDim.new(0, 10) containerCorner.Parent = container
local containerStroke = Instance.new("UIStroke") containerStroke.Color = Color3.fromRGB(45, 45, 45) containerStroke.Thickness = 1.5 containerStroke.Parent = container

-- =================================================================
-- MINIMIZED ICON SETUP
-- =================================================================
local minimizedIcon = Instance.new("TextButton")
minimizedIcon.Size = UDim2.new(0, 45, 0, 45)
minimizedIcon.Position = UDim2.new(0, 10, 0.15, 0)
minimizedIcon.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
minimizedIcon.Text = "ZR"
minimizedIcon.Font = Enum.Font.FredokaOne
minimizedIcon.TextSize = 18
minimizedIcon.TextColor3 = Color3.fromRGB(220, 220, 220)
minimizedIcon.AutoButtonColor = false
minimizedIcon.Visible = false
minimizedIcon.Parent = screenGui

local iconCorner = Instance.new("UICorner") iconCorner.CornerRadius = UDim.new(1, 0) iconCorner.Parent = minimizedIcon
local iconStroke = Instance.new("UIStroke") iconStroke.Color = Color3.fromRGB(80, 80, 80) iconStroke.Thickness = 1.5 iconStroke.Parent = minimizedIcon
local OutIconStroke = Instance.new("UIStroke") OutIconStroke.Color = Color3.fromRGB(172, 172, 172) OutIconStroke.Thickness = 2 OutIconStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border OutIconStroke.Parent = minimizedIcon

enableDragging(minimizedIcon, minimizedIcon, true)

local clickDragStartPos
local isDraggingIcon = false
minimizedIcon.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		clickDragStartPos = input.Position
		isDraggingIcon = false
		minimizedIcon.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	end
end)
minimizedIcon.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		if clickDragStartPos and (input.Position - clickDragStartPos).Magnitude > 5 then
			isDraggingIcon = true 
		end
	end
end)
minimizedIcon.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		minimizedIcon.BackgroundColor3 = Color3.fromRGB(25, 25, 25) 
		if not isDraggingIcon then
			container.Visible = true
			minimizedIcon.Visible = false
		end
		clickDragStartPos = nil
		isDraggingIcon = false
	end
end)

-- =================================================================
-- TITLE BAR & HEADER CONTROLS
-- =================================================================
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
titleBar.BorderSizePixel = 0
titleBar.Parent = container

local titleCorner = Instance.new("UICorner") titleCorner.CornerRadius = UDim.new(0, 10) titleCorner.Parent = titleBar
local titleFiller = Instance.new("Frame") titleFiller.Size = UDim2.new(1, 0, 0, 10) titleFiller.Position = UDim2.new(0, 0, 1, -10) titleFiller.BackgroundColor3 = Color3.fromRGB(28, 28, 28) titleFiller.BorderSizePixel = 0 titleFiller.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(0, 90, 1, 0)
titleText.Position = UDim2.new(0, 12, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "Pos Manager"
titleText.Font = Enum.Font.FredokaOne
titleText.TextSize = 13
titleText.TextColor3 = Color3.fromRGB(220, 220, 220)
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

enableDragging(titleBar, container, true)

local closeBtn = Instance.new("TextButton") closeBtn.Size = UDim2.new(0, 30, 1, 0) closeBtn.Position = UDim2.new(1, -30, 0, 0) closeBtn.Text = "×" closeBtn.Font = Enum.Font.FredokaOne closeBtn.TextSize = 22 closeBtn.TextColor3 = Color3.fromRGB(200, 200, 200) closeBtn.BackgroundTransparency = 1 closeBtn.Parent = titleBar
local minBtn = Instance.new("TextButton") minBtn.Size = UDim2.new(0, 30, 1, 0) minBtn.Position = UDim2.new(1, -60, 0, 0) minBtn.Text = "-" minBtn.Font = Enum.Font.FredokaOne minBtn.TextSize = 20 minBtn.TextColor3 = Color3.fromRGB(200, 200, 200) minBtn.BackgroundTransparency = 1 minBtn.Parent = titleBar

minBtn.MouseButton1Click:Connect(function()
	container.Visible = false
	minimizedIcon.Visible = true
end)

local addBtn = Instance.new("TextButton") addBtn.Size = UDim2.new(0, 30, 1, 0) addBtn.Position = UDim2.new(1, -90, 0, 0) addBtn.Text = "+" addBtn.Font = Enum.Font.FredokaOne addBtn.TextSize = 18 addBtn.TextColor3 = Color3.fromRGB(200, 200, 200) addBtn.BackgroundTransparency = 1 addBtn.Parent = titleBar
local loopBtn = createButton(titleBar, "Loop", Color3.fromRGB(40, 40, 40), UDim2.new(0, 45, 0, 24), UDim2.new(1, -140, 0.5, -12))
loopBtn.Font = Enum.Font.GothamBold loopBtn.TextSize = 10 loopBtn.UIStroke.Color = Color3.fromRGB(60,60,60)

loopBtn.MouseButton1Click:Connect(function()
	isLooping = not isLooping
	if isLooping then
		loopBtn.BackgroundColor3 = Color3.fromRGB(90, 90, 90) loopBtn.UIStroke.Color = Color3.fromRGB(120, 120, 120) loopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	else
		loopBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40) loopBtn.UIStroke.Color = Color3.fromRGB(60, 60, 60) loopBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
	end
end)

-- =================================================================
-- CONTENT AREA 
-- =================================================================
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -16, 1, -155) -- Dikecilkan untuk muat slider Auto Load
scrollFrame.Position = UDim2.new(0, 8, 0, 45)
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.ScrollBarThickness = 3
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.Parent = container

local listLayout = Instance.new("UIListLayout") listLayout.Parent = scrollFrame listLayout.Padding = UDim.new(0, 8) listLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Area Kontrol Play/Pause 
local controlFrame = Instance.new("Frame")
controlFrame.Size = UDim2.new(1, -16, 0, 28)
controlFrame.Position = UDim2.new(0, 8, 1, -105) 
controlFrame.BackgroundTransparency = 1
controlFrame.Parent = container

local btnBaseColor = Color3.fromRGB(35, 35, 35)
local playBtn = createButton(controlFrame, "▶", btnBaseColor, UDim2.new(0.32, 0, 1, 0), UDim2.new(0, 0, 0, 0))
local pauseBtn = createButton(controlFrame, "||", btnBaseColor, UDim2.new(0.32, 0, 1, 0), UDim2.new(0.34, 0, 0, 0)) pauseBtn.Font = Enum.Font.GothamBlack
local stopBtn = createButton(controlFrame, "■", btnBaseColor, UDim2.new(0.32, 0, 1, 0), UDim2.new(0.68, 0, 0, 0))

-- =================================================================
-- AUTO LOAD SLIDER UI
-- =================================================================
local toggleFrame = Instance.new("Frame")
toggleFrame.Size = UDim2.new(1, -16, 0, 20)
toggleFrame.Position = UDim2.new(0, 8, 1, -70)
toggleFrame.BackgroundTransparency = 1
toggleFrame.Parent = container

local toggleText = Instance.new("TextLabel")
toggleText.Size = UDim2.new(0.7, 0, 1, 0)
toggleText.Position = UDim2.new(0, 5, 0, 0)
toggleText.BackgroundTransparency = 1
toggleText.Text = "Auto Save/Load"
toggleText.Font = Enum.Font.GothamMedium
toggleText.TextSize = 11
toggleText.TextColor3 = Color3.fromRGB(180, 180, 180)
toggleText.TextXAlignment = Enum.TextXAlignment.Left
toggleText.Parent = toggleFrame

local sliderBg = Instance.new("TextButton")
sliderBg.Size = UDim2.new(0, 36, 0, 18)
sliderBg.Position = UDim2.new(1, -36, 0.5, -9)
sliderBg.BackgroundColor3 = autoLoadEnabled and Color3.fromRGB(100, 100, 100) or Color3.fromRGB(35, 35, 35)
sliderBg.Text = ""
sliderBg.AutoButtonColor = false
sliderBg.Parent = toggleFrame
local sliderCorner = Instance.new("UICorner") sliderCorner.CornerRadius = UDim.new(1, 0) sliderCorner.Parent = sliderBg
local sliderStroke = Instance.new("UIStroke") sliderStroke.Color = Color3.fromRGB(60, 60, 60) sliderStroke.Parent = sliderBg

local sliderKnob = Instance.new("Frame")
sliderKnob.Size = UDim2.new(0, 14, 0, 14)
sliderKnob.Position = autoLoadEnabled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
sliderKnob.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
sliderKnob.Parent = sliderBg
local knobCorner = Instance.new("UICorner") knobCorner.CornerRadius = UDim.new(1, 0) knobCorner.Parent = sliderKnob

sliderBg.MouseButton1Click:Connect(function()
	if not fsSupported then
		toggleText.Text = "File System Not Supported"
		toggleText.TextColor3 = Color3.fromRGB(150, 60, 60)
		task.wait(2)
		toggleText.Text = "Auto Load Map Data"
		toggleText.TextColor3 = Color3.fromRGB(180, 180, 180)
		return
	end
	
	autoLoadEnabled = not autoLoadEnabled
	saveSettings()
	
	if autoLoadEnabled then
		game:GetService("TweenService"):Create(sliderBg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(100, 100, 100)}):Play()
		game:GetService("TweenService"):Create(sliderKnob, TweenInfo.new(0.2), {Position = UDim2.new(1, -16, 0.5, -7)}):Play()
		saveCurrentMapData() -- Langsung save state saat dinyalakan
	else
		game:GetService("TweenService"):Create(sliderBg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
		game:GetService("TweenService"):Create(sliderKnob, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -7)}):Play()
	end
end)

-- Area Export / Import 
local configFrame = Instance.new("Frame")
configFrame.Size = UDim2.new(1, -16, 0, 24)
configFrame.Position = UDim2.new(0, 8, 1, -45) 
configFrame.BackgroundTransparency = 1
configFrame.Parent = container

local exportBtn = createButton(configFrame, "Export", Color3.fromRGB(35, 35, 35), UDim2.new(0.48, 0, 1, 0), UDim2.new(0, 0, 0, 0))
local importBtn = createButton(configFrame, "Import", Color3.fromRGB(35, 35, 35), UDim2.new(0.48, 0, 1, 0), UDim2.new(0.52, 0, 0, 0))

-- Watermark
local watermark = Instance.new("TextLabel")
watermark.Size = UDim2.new(1, 0, 0, 15)
watermark.Position = UDim2.new(0, 0, 1, -18)
watermark.BackgroundTransparency = 1
watermark.Text = "Made By BhuzelRayhan"
watermark.Font = Enum.Font.GothamMedium
watermark.TextSize = 9
watermark.TextColor3 = Color3.fromRGB(150, 150, 150)
watermark.TextTransparency = 0.5
watermark.Parent = container

-- =================================================================
-- POPUPS (Confirm Close & Import)
-- =================================================================
local confirmPopup = Instance.new("Frame")
confirmPopup.Size = UDim2.new(1, 0, 1, 0)
confirmPopup.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
confirmPopup.BackgroundTransparency = 0.2
confirmPopup.ZIndex = 50
confirmPopup.Visible = false
confirmPopup.Active = true
confirmPopup.Parent = container

local confirmBox = Instance.new("Frame")
confirmBox.Size = UDim2.new(0, 200, 0, 95)
confirmBox.Position = UDim2.new(0.5, -100, 0.5, -47)
confirmBox.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
confirmBox.ZIndex = 51
confirmBox.Parent = confirmPopup
local ccCorner = Instance.new("UICorner") ccCorner.CornerRadius = UDim.new(0,8) ccCorner.Parent = confirmBox
local ccStroke = Instance.new("UIStroke") ccStroke.Color = Color3.fromRGB(60,60,60) ccStroke.Parent = confirmBox

local confirmText = Instance.new("TextLabel")
confirmText.Size = UDim2.new(1, -20, 0, 45) confirmText.Position = UDim2.new(0, 10, 0, 5) confirmText.BackgroundTransparency = 1
confirmText.Text = "Close and stop all running processes?" confirmText.Font = Enum.Font.GothamMedium confirmText.TextSize = 12 confirmText.TextColor3 = Color3.fromRGB(220, 220, 220) confirmText.TextWrapped = true confirmText.ZIndex = 52 confirmText.Parent = confirmBox

local noBtn = createButton(confirmBox, "No", Color3.fromRGB(35, 35, 35), UDim2.new(0.4, 0, 0, 25), UDim2.new(0.08, 0, 1, -33)) noBtn.ZIndex = 52
local yesBtn = createButton(confirmBox, "Yes", Color3.fromRGB(50, 50, 50), UDim2.new(0.4, 0, 0, 25), UDim2.new(0.52, 0, 1, -33)) yesBtn.ZIndex = 52

closeBtn.MouseButton1Click:Connect(function() confirmPopup.Visible = true end)
noBtn.MouseButton1Click:Connect(function() confirmPopup.Visible = false end)
yesBtn.MouseButton1Click:Connect(function()
	isPlaying = false isPaused = false
	if autoThread then task.cancel(autoThread) autoThread = nil end
	rows = {} screenGui:Destroy()
end)

local importPopup = Instance.new("Frame")
importPopup.Size = UDim2.new(1, -16, 1, -155) importPopup.Position = UDim2.new(0, 8, 0, 45) importPopup.BackgroundColor3 = Color3.fromRGB(22, 22, 22) importPopup.Visible = false importPopup.ZIndex = 10 importPopup.Parent = container
local ipCorner = Instance.new("UICorner") ipCorner.CornerRadius = UDim.new(0, 8) ipCorner.Parent = importPopup
local ipStroke = Instance.new("UIStroke") ipStroke.Color = Color3.fromRGB(50, 50, 50) ipStroke.Parent = importPopup

local importBox = Instance.new("TextBox")
importBox.Size = UDim2.new(1, -16, 1, -50) importBox.Position = UDim2.new(0, 8, 0, 8) importBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15) importBox.Text = "" importBox.PlaceholderText = "Paste config JSON di sini..." importBox.TextWrapped = true importBox.ClearTextOnFocus = false importBox.Font = Enum.Font.Gotham importBox.TextSize = 11 importBox.TextColor3 = Color3.fromRGB(200, 200, 200) importBox.TextYAlignment = Enum.TextYAlignment.Top importBox.Parent = importPopup
local ibCorner = Instance.new("UICorner") ibCorner.CornerRadius = UDim.new(0, 6) ibCorner.Parent = importBox

local submitImportBtn = createButton(importPopup, "Load", Color3.fromRGB(50, 50, 50), UDim2.new(0.48, 0, 0, 25), UDim2.new(0, 8, 1, -33))
local cancelImportBtn = createButton(importPopup, "Cancel", Color3.fromRGB(35, 30, 30), UDim2.new(0.48, 0, 0, 25), UDim2.new(0.52, -8, 1, -33))

-- =================================================================
-- LOGIKA ROW (Create, Save, Load)
-- =================================================================
local createRow 
createRow = function(isRoot, loadData)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 60)
	row.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	row.Parent = scrollFrame

	local rowCorner = Instance.new("UICorner") rowCorner.CornerRadius = UDim.new(0, 8) rowCorner.Parent = row
	local rowStroke = Instance.new("UIStroke") rowStroke.Color = Color3.fromRGB(40, 40, 40) rowStroke.Thickness = 1 rowStroke.Parent = row

	local loadedName = ""
	local loadedDelay = "2"
	if loadData then
		loadedName = loadData.nameBhuzelRayhan or loadData.nameZellRayy or loadData.name or ""
		loadedDelay = tostring(loadData.delayBhuzelRayhan or loadData.delay or 5)
	end

	local nameBox = Instance.new("TextBox")
	nameBox.Size = UDim2.new(1, -80, 0, 22) nameBox.Position = UDim2.new(0, 10, 0, 8) nameBox.BackgroundTransparency = 1 nameBox.Text = loadedName nameBox.PlaceholderText = "Label Name..." nameBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100) nameBox.Font = Enum.Font.Gotham nameBox.TextSize = 12 nameBox.TextColor3 = Color3.fromRGB(230, 230, 230) nameBox.TextXAlignment = Enum.TextXAlignment.Left nameBox.Parent = row

	local delayWrapper = Instance.new("Frame")
	delayWrapper.Size = UDim2.new(0, 40, 0, 22) delayWrapper.Position = UDim2.new(1, -70, 0, 4) delayWrapper.BackgroundColor3 = Color3.fromRGB(15, 15, 15) delayWrapper.Parent = row
	local dwCorner = Instance.new("UICorner") dwCorner.CornerRadius = UDim.new(0,5) dwCorner.Parent = delayWrapper
	local dwStroke = Instance.new("UIStroke") dwStroke.Color = Color3.fromRGB(50,50,50) dwStroke.Thickness = 1 dwStroke.Parent = delayWrapper

	local delayBox = Instance.new("TextBox")
	delayBox.Size = UDim2.new(1, 0, 1, 0) delayBox.BackgroundTransparency = 1 delayBox.Text = loadedDelay delayBox.PlaceholderText = "SEC" delayBox.Font = Enum.Font.GothamMedium delayBox.TextSize = 11 delayBox.TextColor3 = Color3.fromRGB(200, 200, 200) delayBox.Parent = delayWrapper
	
	local saveBtn = createButton(row, "Save", Color3.fromRGB(40, 40, 45), UDim2.new(0.5, -14, 0, 20), UDim2.new(0, 10, 1, -28))
	local loadBtn = createButton(row, "Teleport", Color3.fromRGB(50, 50, 55), UDim2.new(0.5, -14, 0, 20), UDim2.new(0.5, 4, 1, -28))

	local savedPos = loadData and Vector3.new(loadData.x, loadData.y, loadData.z) or nil

	local rowData = {
		frame = row,
		nameBox = nameBox,
		delayBox = delayBox,
		getPos = function() return savedPos end
	}

	-- Trigger AutoSave if text changes
	nameBox.FocusLost:Connect(saveCurrentMapData)
	delayBox.FocusLost:Connect(saveCurrentMapData)

	saveBtn.MouseButton1Click:Connect(function()
		local char = player.Character or player.CharacterAdded:Wait()
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp then
			savedPos = hrp.Position
			saveCurrentMapData() -- Auto Save Trigger
			
			local origText = saveBtn.Text
			saveBtn.Text = "✓ Saved"
			saveBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70) 
			task.wait(0.7)
			saveBtn.Text = origText
			saveBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
		end
	end)

	loadBtn.MouseButton1Click:Connect(function()
		if not savedPos then return end
		local char = player.Character or player.CharacterAdded:Wait()
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp then
			local ori = hrp.CFrame - hrp.CFrame.Position
			hrp.CFrame = CFrame.new(savedPos) * ori
		end
	end)

	if not isRoot then
		local deleteBtn = Instance.new("TextButton")
		deleteBtn.Size = UDim2.new(0, 20, 0, 20) deleteBtn.Position = UDim2.new(1, -25, 0, 9) deleteBtn.Text = "×" deleteBtn.Font = Enum.Font.GothamBold deleteBtn.TextSize = 16 deleteBtn.TextColor3 = Color3.fromRGB(120, 120, 120) deleteBtn.BackgroundTransparency = 1 deleteBtn.Parent = row

		deleteBtn.MouseButton1Click:Connect(function()
			for i, r in ipairs(rows) do if r == rowData then table.remove(rows, i) break end end
			row:Destroy()
			saveCurrentMapData() -- Auto Save Trigger
		end)
	end

	table.insert(rows, rowData)
	row.LayoutOrder = #rows
	return rowData
end

addBtn.MouseButton1Click:Connect(function() 
	createRow(false) 
	saveCurrentMapData() 
end)

-- =================================================================
-- LOGIKA AUTO TELEPORT & EXPORT/IMPORT
-- =================================================================
local function stopAuto()
	isPlaying = false isPaused = false currentPoint = 1
	playBtn.BackgroundColor3 = btnBaseColor playBtn.UIStroke.Color = Color3.fromRGB(60,60,60)
	pauseBtn.BackgroundColor3 = btnBaseColor pauseBtn.UIStroke.Color = Color3.fromRGB(60,60,60)
	if autoThread then task.cancel(autoThread) autoThread = nil end
end

playBtn.MouseButton1Click:Connect(function()
	if isPlaying and not isPaused then return end
	isPlaying = true isPaused = false
	playBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70) playBtn.UIStroke.Color = Color3.fromRGB(120, 120, 120)
	pauseBtn.BackgroundColor3 = btnBaseColor 

	if autoThread then task.cancel(autoThread) end

	autoThread = task.spawn(function()
		while isPlaying do
			if #rows == 0 then stopAuto() break end
			if currentPoint > #rows then 
				if isLooping then currentPoint = 1 else stopAuto() break end
			end

			local currentRow = rows[currentPoint]
			local targetPos = currentRow.getPos()

			if targetPos then
				local char = player.Character or player.CharacterAdded:Wait()
				local hrp = char:FindFirstChild("HumanoidRootPart")
				if hrp then
					local ori = hrp.CFrame - hrp.CFrame.Position
					hrp.CFrame = CFrame.new(targetPos) * ori
				end
			end

			local delay = tonumber(currentRow.delayBox.Text) or 0
			local elapsed = 0
			while elapsed < delay do
				task.wait(0.1)
				if not isPlaying then break end
				if not isPaused then elapsed += 0.1 end
			end
			if not isPlaying then break end
			currentPoint += 1
		end
	end)
end)

pauseBtn.MouseButton1Click:Connect(function()
	if isPlaying and not isPaused then
		isPaused = true
		pauseBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70) pauseBtn.UIStroke.Color = Color3.fromRGB(120, 120, 120)
		playBtn.BackgroundColor3 = btnBaseColor
	end
end)

stopBtn.MouseButton1Click:Connect(function() stopAuto() stopBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70) task.wait(0.15) stopBtn.BackgroundColor3 = btnBaseColor end)

exportBtn.MouseButton1Click:Connect(function()
	local exportData = {}
	for _, r in ipairs(rows) do
		local pos = r.getPos()
		if pos then table.insert(exportData, {nameBhuzelRayhan = r.nameBox.Text, delayBhuzelRayhan = tonumber(r.delayBox.Text) or 5, x = pos.X, y = pos.Y, z = pos.Z}) end
	end
	local json = (#exportData > 0) and HttpService:JSONEncode(exportData) or ""
	if json ~= "" then
		if setclipboard then setclipboard(json) elseif toclipboard then toclipboard(json) end
		exportBtn.Text = "Copied!" task.wait(1) exportBtn.Text = "Export"
	else
		exportBtn.Text = "Empty!" task.wait(1) exportBtn.Text = "Export"
	end
end)

importBtn.MouseButton1Click:Connect(function() importBox.Text = "" importPopup.Visible = true scrollFrame.Visible = false controlFrame.Visible = false toggleFrame.Visible = false end)
cancelImportBtn.MouseButton1Click:Connect(function() importPopup.Visible = false scrollFrame.Visible = true controlFrame.Visible = true toggleFrame.Visible = true end)

submitImportBtn.MouseButton1Click:Connect(function()
	local success, decodedData = pcall(function() return HttpService:JSONDecode(importBox.Text) end)
	if success and type(decodedData) == "table" then
		stopAuto()
		for _, r in ipairs(rows) do r.frame:Destroy() end
		rows = {}
		for i, data in ipairs(decodedData) do createRow(i == 1, data) end
		if #rows == 0 then createRow(true) end
		
		saveCurrentMapData() -- Simpan import terbaru kalau auto load nyala
		
		importPopup.Visible = false scrollFrame.Visible = true controlFrame.Visible = true toggleFrame.Visible = true
		importBtn.Text = "Success!" task.wait(1) importBtn.Text = "Import"
	else
		submitImportBtn.Text = "Invalid!" task.wait(1) submitImportBtn.Text = "Load"
	end
end)

-- =================================================================
-- STARTUP LOGIC (Load data if Auto Load is enabled)
-- =================================================================
local loadedFromSave = false

if autoLoadEnabled and fsSupported then
	if isfile(MAP_FILE) then
		local suc, decodedData = pcall(function() return HttpService:JSONDecode(readfile(MAP_FILE)) end)
		if suc and type(decodedData) == "table" and #decodedData > 0 then
			for i, data in ipairs(decodedData) do
				createRow(i == 1, data)
			end
			loadedFromSave = true
		end
	end
end

-- Kalau ngga ada save data, bikin row default kosong
if not loadedFromSave then
	createRow(true)
end
