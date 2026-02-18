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

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

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
-- FUNGSI DRAGGING UNIVERSAL (Dengan Smart Clamping)
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
			
			-- Konversi skala awal ke pixel absolut untuk hitungan akurat
			local absStartX = (startPos.X.Scale * viewportSize.X) + startPos.X.Offset
			local absStartY = (startPos.Y.Scale * viewportSize.Y) + startPos.Y.Offset
			
			local newAbsX = absStartX + delta.X
			local newAbsY = absStartY + delta.Y
			
			if constrainToScreen then
				-- Batasi supaya ga bisa keluar frame layar
				local maxX = viewportSize.X - targetFrame.AbsoluteSize.X
				local maxY = viewportSize.Y - targetFrame.AbsoluteSize.Y
				newAbsX = math.clamp(newAbsX, 0, maxX)
				newAbsY = math.clamp(newAbsY, 0, maxY)
			end
			
			game:GetService("TweenService"):Create(targetFrame, TweenInfo.new(0.08), {Position = UDim2.new(0, newAbsX, 0, newAbsY)}):Play()
		end
	end)
end

-- FUNGSI PEMBUAT TOMBOL UNIVERSAL
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
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 5)
	corner.Parent = btn
	
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(60, 60, 60)
	stroke.Thickness = 1
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = btn
	
	return btn
end

-- =================================================================
-- MAIN CONTAINER SETUP
-- =================================================================
local container = Instance.new("Frame")
container.Size = UDim2.new(0, 250, 0, 400) -- Agak lebar dikit biar tombol atas muat
container.Position = UDim2.new(0.5, -125, 0.5, -200)
container.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
container.BorderSizePixel = 0
container.ClipsDescendants = true
container.Visible = true
container.Parent = screenGui

local containerCorner = Instance.new("UICorner")
containerCorner.CornerRadius = UDim.new(0, 10)
containerCorner.Parent = container

local containerStroke = Instance.new("UIStroke")
containerStroke.Color = Color3.fromRGB(45, 45, 45)
containerStroke.Thickness = 1.5
containerStroke.Parent = container

-- =================================================================
-- MINIMIZED ICON SETUP ("ZR" Toggle)
-- =================================================================
local minimizedIcon = Instance.new("TextButton")
minimizedIcon.Size = UDim2.new(0, 45, 0, 45)
minimizedIcon.Position = UDim2.new(0, 10, 0.15, 0) -- Update posisi Y ke 0.15
minimizedIcon.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
minimizedIcon.Text = "ZR"
minimizedIcon.Font = Enum.Font.FredokaOne
minimizedIcon.TextSize = 18
minimizedIcon.TextColor3 = Color3.fromRGB(220, 220, 220)
minimizedIcon.AutoButtonColor = false
minimizedIcon.Visible = false
minimizedIcon.Parent = screenGui

local iconCorner = Instance.new("UICorner")
iconCorner.CornerRadius = UDim.new(1, 0)
iconCorner.Parent = minimizedIcon

local iconStroke = Instance.new("UIStroke")
iconStroke.Color = Color3.fromRGB(80, 80, 80)
iconStroke.Thickness = 1.5
iconStroke.Parent = minimizedIcon

local OutIconStroke = Instance.new("UIStroke")
OutIconStroke.Color = Color3.fromRGB(172, 172, 172)
OutIconStroke.Thickness = 2
OutIconStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
OutIconStroke.Parent = minimizedIcon

-- Aktifin dragging untuk icon dengan parameter 'true' agar tidak bisa offscreen
enableDragging(minimizedIcon, minimizedIcon, true)

-- Logika Anti-Sensitif untuk Icon
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

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleBar

local titleFiller = Instance.new("Frame")
titleFiller.Size = UDim2.new(1, 0, 0, 10)
titleFiller.Position = UDim2.new(0, 0, 1, -10)
titleFiller.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
titleFiller.BorderSizePixel = 0
titleFiller.Parent = titleBar

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

-- Container nggak bisa ditarik sampai hilang dari layar
enableDragging(titleBar, container, true)

-- Tombol Close (x)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 1, 0)
closeBtn.Position = UDim2.new(1, -30, 0, 0)
closeBtn.Text = "×"
closeBtn.Font = Enum.Font.FredokaOne
closeBtn.TextSize = 22
closeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
closeBtn.BackgroundTransparency = 1
closeBtn.Parent = titleBar

-- Tombol Minimize (-)
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 30, 1, 0)
minBtn.Position = UDim2.new(1, -60, 0, 0)
minBtn.Text = "-"
minBtn.Font = Enum.Font.FredokaOne
minBtn.TextSize = 20
minBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
minBtn.BackgroundTransparency = 1
minBtn.Parent = titleBar

minBtn.MouseButton1Click:Connect(function()
	container.Visible = false
	minimizedIcon.Visible = true
end)

-- Tombol Tambah Row (+)
local addBtn = Instance.new("TextButton")
addBtn.Size = UDim2.new(0, 30, 1, 0)
addBtn.Position = UDim2.new(1, -90, 0, 0)
addBtn.Text = "+"
addBtn.Font = Enum.Font.FredokaOne
addBtn.TextSize = 18
addBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
addBtn.BackgroundTransparency = 1
addBtn.Parent = titleBar

-- Tombol Loop
local loopBtn = createButton(titleBar, "Loop", Color3.fromRGB(40, 40, 40), UDim2.new(0, 45, 0, 24), UDim2.new(1, -140, 0.5, -12))
loopBtn.Font = Enum.Font.GothamBold
loopBtn.TextSize = 10
loopBtn.UIStroke.Color = Color3.fromRGB(60,60,60)

loopBtn.MouseButton1Click:Connect(function()
	isLooping = not isLooping
	if isLooping then
		loopBtn.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
		loopBtn.UIStroke.Color = Color3.fromRGB(120, 120, 120)
		loopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	else
		loopBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		loopBtn.UIStroke.Color = Color3.fromRGB(60, 60, 60)
		loopBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
	end
end)

-- =================================================================
-- CONTENT AREA 
-- =================================================================
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -16, 1, -135)
scrollFrame.Position = UDim2.new(0, 8, 0, 45)
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.ScrollBarThickness = 3
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.Parent = container

local listLayout = Instance.new("UIListLayout")
listLayout.Parent = scrollFrame
listLayout.Padding = UDim.new(0, 8)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Area Kontrol Play/Pause 
local controlFrame = Instance.new("Frame")
controlFrame.Size = UDim2.new(1, -16, 0, 28)
controlFrame.Position = UDim2.new(0, 8, 1, -85) 
controlFrame.BackgroundTransparency = 1
controlFrame.Parent = container

local btnBaseColor = Color3.fromRGB(35, 35, 35)
local playBtn = createButton(controlFrame, "▶", btnBaseColor, UDim2.new(0.32, 0, 1, 0), UDim2.new(0, 0, 0, 0))
local pauseBtn = createButton(controlFrame, "||", btnBaseColor, UDim2.new(0.32, 0, 1, 0), UDim2.new(0.34, 0, 0, 0))
pauseBtn.Font = Enum.Font.GothamBlack
local stopBtn = createButton(controlFrame, "■", btnBaseColor, UDim2.new(0.32, 0, 1, 0), UDim2.new(0.68, 0, 0, 0))

-- Area Export / Import 
local configFrame = Instance.new("Frame")
configFrame.Size = UDim2.new(1, -16, 0, 28)
configFrame.Position = UDim2.new(0, 8, 1, -50) 
configFrame.BackgroundTransparency = 1
configFrame.Parent = container

local exportBtn = createButton(configFrame, "Export", Color3.fromRGB(35, 35, 35), UDim2.new(0.48, 0, 1, 0), UDim2.new(0, 0, 0, 0))
local importBtn = createButton(configFrame, "Import", Color3.fromRGB(35, 35, 35), UDim2.new(0.48, 0, 1, 0), UDim2.new(0.52, 0, 0, 0))

-- Watermark
local watermark = Instance.new("TextLabel")
watermark.Size = UDim2.new(1, 0, 0, 15)
watermark.Position = UDim2.new(0, 0, 1, -15)
watermark.BackgroundTransparency = 1
watermark.Text = "Made By BhuzelRayhan"
watermark.Font = Enum.Font.GothamMedium
watermark.TextSize = 9
watermark.TextColor3 = Color3.fromRGB(150, 150, 150)
watermark.TextTransparency = 0.5
watermark.Parent = container

-- =================================================================
-- POPUP CONFIRM CLOSE
-- =================================================================
local confirmPopup = Instance.new("Frame")
confirmPopup.Size = UDim2.new(1, 0, 1, 0)
confirmPopup.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
confirmPopup.BackgroundTransparency = 0.2
confirmPopup.ZIndex = 50
confirmPopup.Visible = false
confirmPopup.Parent = container

-- Menyerap klik di background biar ga tembus
confirmPopup.Active = true

local confirmBox = Instance.new("Frame")
confirmBox.Size = UDim2.new(0, 200, 0, 95)
confirmBox.Position = UDim2.new(0.5, -100, 0.5, -47)
confirmBox.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
confirmBox.ZIndex = 51
confirmBox.Parent = confirmPopup

local confirmCorner = Instance.new("UICorner") confirmCorner.CornerRadius = UDim.new(0,8) confirmCorner.Parent = confirmBox
local confirmStroke = Instance.new("UIStroke") confirmStroke.Color = Color3.fromRGB(60,60,60) confirmStroke.Parent = confirmBox

local confirmText = Instance.new("TextLabel")
confirmText.Size = UDim2.new(1, -20, 0, 45)
confirmText.Position = UDim2.new(0, 10, 0, 5)
confirmText.BackgroundTransparency = 1
confirmText.Text = "Close and stop all running processes?"
confirmText.Font = Enum.Font.GothamMedium
confirmText.TextSize = 12
confirmText.TextColor3 = Color3.fromRGB(220, 220, 220)
confirmText.TextWrapped = true
confirmText.ZIndex = 52
confirmText.Parent = confirmBox

local noBtn = createButton(confirmBox, "No", Color3.fromRGB(35, 35, 35), UDim2.new(0.4, 0, 0, 25), UDim2.new(0.08, 0, 1, -33))
noBtn.ZIndex = 52
local yesBtn = createButton(confirmBox, "Yes", Color3.fromRGB(50, 50, 50), UDim2.new(0.4, 0, 0, 25), UDim2.new(0.52, 0, 1, -33))
yesBtn.ZIndex = 52

closeBtn.MouseButton1Click:Connect(function()
	confirmPopup.Visible = true
end)

noBtn.MouseButton1Click:Connect(function()
	confirmPopup.Visible = false
end)

yesBtn.MouseButton1Click:Connect(function()
	-- HENTIKAN SEMUA AKTIVITAS LALU HANCURKAN
	isPlaying = false
	isPaused = false
	if autoThread then 
		task.cancel(autoThread) 
		autoThread = nil 
	end
	rows = {}
	screenGui:Destroy()
end)

-- =================================================================
-- POPUP IMPORT
-- =================================================================
local importPopup = Instance.new("Frame")
importPopup.Size = UDim2.new(1, -16, 1, -135)
importPopup.Position = UDim2.new(0, 8, 0, 45)
importPopup.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
importPopup.Visible = false
importPopup.ZIndex = 10
importPopup.Parent = container

local popupCorner = Instance.new("UICorner") popupCorner.CornerRadius = UDim.new(0, 8) popupCorner.Parent = importPopup
local popupStroke = Instance.new("UIStroke") popupStroke.Color = Color3.fromRGB(50, 50, 50) popupStroke.Parent = importPopup

local importBox = Instance.new("TextBox")
importBox.Size = UDim2.new(1, -16, 1, -50)
importBox.Position = UDim2.new(0, 8, 0, 8)
importBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
importBox.Text = ""
importBox.PlaceholderText = "Paste config JSON di sini..."
importBox.TextWrapped = true
importBox.ClearTextOnFocus = false
importBox.Font = Enum.Font.Gotham
importBox.TextSize = 11
importBox.TextColor3 = Color3.fromRGB(200, 200, 200)
importBox.TextYAlignment = Enum.TextYAlignment.Top
importBox.Parent = importPopup
local importBoxCorner = Instance.new("UICorner") importBoxCorner.CornerRadius = UDim.new(0, 6) importBoxCorner.Parent = importBox

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
	nameBox.Size = UDim2.new(1, -80, 0, 22)
	nameBox.Position = UDim2.new(0, 10, 0, 8)
	nameBox.BackgroundTransparency = 1
	nameBox.Text = loadedName
	nameBox.PlaceholderText = "Label Name..."
	nameBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
	nameBox.Font = Enum.Font.Gotham
	nameBox.TextSize = 12
	nameBox.TextColor3 = Color3.fromRGB(230, 230, 230)
	nameBox.TextXAlignment = Enum.TextXAlignment.Left
	nameBox.Parent = row

	local delayWrapper = Instance.new("Frame")
	delayWrapper.Size = UDim2.new(0, 40, 0, 22)
	delayWrapper.Position = UDim2.new(1, -70, 0, 4)
	delayWrapper.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	delayWrapper.Parent = row
	local dwCorner = Instance.new("UICorner") dwCorner.CornerRadius = UDim.new(0,5) dwCorner.Parent = delayWrapper
	local dwStroke = Instance.new("UIStroke") dwStroke.Color = Color3.fromRGB(50,50,50) dwStroke.Thickness = 1 dwStroke.Parent = delayWrapper

	local delayBox = Instance.new("TextBox")
	delayBox.Size = UDim2.new(1, 0, 1, 0)
	delayBox.BackgroundTransparency = 1
	delayBox.Text = loadedDelay
	delayBox.PlaceholderText = "SEC"
	delayBox.Font = Enum.Font.GothamMedium
	delayBox.TextSize = 11
	delayBox.TextColor3 = Color3.fromRGB(200, 200, 200)
	delayBox.Parent = delayWrapper
	
	local saveBtn = createButton(row, "Save", Color3.fromRGB(40, 40, 45), UDim2.new(0.5, -14, 0, 20), UDim2.new(0, 10, 1, -28))
	local loadBtn = createButton(row, "Teleport", Color3.fromRGB(50, 50, 55), UDim2.new(0.5, -14, 0, 20), UDim2.new(0.5, 4, 1, -28))

	local savedPos = loadData and Vector3.new(loadData.x, loadData.y, loadData.z) or nil

	local rowData = {
		frame = row,
		nameBox = nameBox,
		delayBox = delayBox,
		getPos = function() return savedPos end
	}

	saveBtn.MouseButton1Click:Connect(function()
		local char = player.Character or player.CharacterAdded:Wait()
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp then
			savedPos = hrp.Position
			local origText = saveBtn.Text
			saveBtn.Text = "✓ Saved"
			saveBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70) -- PURE GRAY (Tidak ada hijau lagi)
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
		deleteBtn.Size = UDim2.new(0, 20, 0, 20)
		deleteBtn.Position = UDim2.new(1, -25, 0, 9)
		deleteBtn.Text = "×"
		deleteBtn.Font = Enum.Font.GothamBold
		deleteBtn.TextSize = 16
		deleteBtn.TextColor3 = Color3.fromRGB(120, 120, 120)
		deleteBtn.BackgroundTransparency = 1
		deleteBtn.Parent = row

		deleteBtn.MouseButton1Click:Connect(function()
			for i, r in ipairs(rows) do if r == rowData then table.remove(rows, i) break end end
			row:Destroy()
		end)
	end

	table.insert(rows, rowData)
	row.LayoutOrder = #rows
	return rowData
end
addBtn.MouseButton1Click:Connect(function() createRow(false) end)

-- =================================================================
-- LOGIKA AUTO TELEPORT
-- =================================================================
local function stopAuto()
	isPlaying = false
	isPaused = false
	currentPoint = 1
	playBtn.BackgroundColor3 = btnBaseColor
	playBtn.UIStroke.Color = Color3.fromRGB(60,60,60)
	pauseBtn.BackgroundColor3 = btnBaseColor
	pauseBtn.UIStroke.Color = Color3.fromRGB(60,60,60)
	
	if autoThread then task.cancel(autoThread) autoThread = nil end
end

playBtn.MouseButton1Click:Connect(function()
	if isPlaying and not isPaused then return end
	
	isPlaying = true
	isPaused = false
	
	playBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	playBtn.UIStroke.Color = Color3.fromRGB(120, 120, 120)
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
		pauseBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
		pauseBtn.UIStroke.Color = Color3.fromRGB(120, 120, 120)
		playBtn.BackgroundColor3 = btnBaseColor
	end
end)

stopBtn.MouseButton1Click:Connect(function()
	stopAuto()
	stopBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	task.wait(0.15)
	stopBtn.BackgroundColor3 = btnBaseColor
end)

-- =================================================================
-- LOGIKA EXPORT/IMPORT
-- =================================================================
exportBtn.MouseButton1Click:Connect(function()
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
	local json = (#exportData > 0) and HttpService:JSONEncode(exportData) or ""
	if json ~= "" then
		if setclipboard then setclipboard(json) elseif toclipboard then toclipboard(json) end
		exportBtn.Text = "Copied!" task.wait(1) exportBtn.Text = "Export"
	else
		exportBtn.Text = "Empty!" task.wait(1) exportBtn.Text = "Export"
	end
end)

importBtn.MouseButton1Click:Connect(function()
	importBox.Text = ""
	importPopup.Visible = true
	scrollFrame.Visible = false
	controlFrame.Visible = false
end)

cancelImportBtn.MouseButton1Click:Connect(function()
	importPopup.Visible = false
	scrollFrame.Visible = true
	controlFrame.Visible = true
end)

submitImportBtn.MouseButton1Click:Connect(function()
	local success, decodedData = pcall(function() return HttpService:JSONDecode(importBox.Text) end)
	if success and type(decodedData) == "table" then
		stopAuto()
		for _, r in ipairs(rows) do r.frame:Destroy() end
		rows = {}
		for i, data in ipairs(decodedData) do createRow(i == 1, data) end
		if #rows == 0 then createRow(true) end
		importPopup.Visible = false
		scrollFrame.Visible = true
		controlFrame.Visible = true
		importBtn.Text = "Success!" task.wait(1) importBtn.Text = "Import"
	else
		submitImportBtn.Text = "Invalid!" task.wait(1) submitImportBtn.Text = "Load"
	end
end)

-- Init Row Pertama
createRow(true)
