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

-- Setup GUI Utama
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ElegantSaveLoadGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Frame Kontainer Utama
local container = Instance.new("Frame")
container.Size = UDim2.new(0, 220, 0, 360)
container.Position = UDim2.new(0.5, -110, 0.5, -180)
container.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
container.BorderSizePixel = 0
container.ClipsDescendants = true
container.Parent = screenGui

local containerCorner = Instance.new("UICorner")
containerCorner.CornerRadius = UDim.new(0, 8)
containerCorner.Parent = container

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
titleBar.BorderSizePixel = 0
titleBar.Parent = container

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleBar

local titleFiller = Instance.new("Frame")
titleFiller.Size = UDim2.new(1, 0, 0, 8)
titleFiller.Position = UDim2.new(0, 0, 1, -8)
titleFiller.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
titleFiller.BorderSizePixel = 0
titleFiller.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -70, 1, 0)
titleText.Position = UDim2.new(0, 12, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "Pos Manager"
titleText.Font = Enum.Font.FredokaOne
titleText.TextSize = 13
titleText.TextColor3 = Color3.fromRGB(200, 200, 200)
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

-- Tombol Minimize (-)
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 25, 0, 25)
minBtn.Position = UDim2.new(1, -60, 0.5, -12.5)
minBtn.Text = "-"
minBtn.Font = Enum.Font.FredokaOne
minBtn.TextSize = 16
minBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
minBtn.BackgroundTransparency = 1
minBtn.Parent = titleBar

-- Tombol Tambah Row (+)
local addBtn = Instance.new("TextButton")
addBtn.Size = UDim2.new(0, 25, 0, 25)
addBtn.Position = UDim2.new(1, -30, 0.5, -12.5)
addBtn.Text = "+"
addBtn.Font = Enum.Font.FredokaOne
addBtn.TextSize = 16
addBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
addBtn.BackgroundTransparency = 1
addBtn.Parent = titleBar

-- Sistem Dragging
local dragging, dragInput, dragStart, startPos
titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = container.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)
titleBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		container.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- Area Scroll
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -16, 1, -85)
scrollFrame.Position = UDim2.new(0, 8, 0, 40)
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.ScrollBarThickness = 2
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.Parent = container

local listLayout = Instance.new("UIListLayout")
listLayout.Parent = scrollFrame
listLayout.Padding = UDim.new(0, 8)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Fungsi Pembuat Tombol Universal
local function createButton(parent, text, color)
	local btn = Instance.new("TextButton")
	btn.Text = text
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 11
	btn.TextColor3 = Color3.fromRGB(240, 240, 240)
	btn.BackgroundColor3 = color
	btn.BorderSizePixel = 0
	btn.Parent = parent
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = btn
	return btn
end

-- Area Export / Import di Bawah
local configFrame = Instance.new("Frame")
configFrame.Size = UDim2.new(1, -16, 0, 24)
configFrame.Position = UDim2.new(0, 8, 1, -40)
configFrame.BackgroundTransparency = 1
configFrame.Parent = container

local exportBtn = createButton(configFrame, "Export", Color3.fromRGB(40, 40, 40))
exportBtn.Size = UDim2.new(0.5, -4, 1, 0)
exportBtn.Position = UDim2.new(0, 0, 0, 0)

local importBtn = createButton(configFrame, "Import", Color3.fromRGB(40, 40, 40))
importBtn.Size = UDim2.new(0.5, -4, 1, 0)
importBtn.Position = UDim2.new(0.5, 4, 0, 0)

-- Panel Popup Import
local importPopup = Instance.new("Frame")
importPopup.Size = UDim2.new(1, -16, 1, -85)
importPopup.Position = UDim2.new(0, 8, 0, 40)
importPopup.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
importPopup.BorderSizePixel = 0
importPopup.Visible = false
importPopup.ZIndex = 5
importPopup.Parent = container

local popupCorner = Instance.new("UICorner")
popupCorner.CornerRadius = UDim.new(0, 6)
popupCorner.Parent = importPopup

local importBox = Instance.new("TextBox")
importBox.Size = UDim2.new(1, -16, 1, -40)
importBox.Position = UDim2.new(0, 8, 0, 8)
importBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
importBox.Text = ""
importBox.PlaceholderText = "Paste config JSON di sini..."
importBox.TextWrapped = true
importBox.ClearTextOnFocus = false
importBox.Font = Enum.Font.Gotham
importBox.TextSize = 10
importBox.TextColor3 = Color3.fromRGB(200, 200, 200)
importBox.TextYAlignment = Enum.TextYAlignment.Top
importBox.ZIndex = 6
importBox.Parent = importPopup

local importBoxCorner = Instance.new("UICorner")
importBoxCorner.CornerRadius = UDim.new(0, 4)
importBoxCorner.Parent = importBox

local submitImportBtn = createButton(importPopup, "Load Config", Color3.fromRGB(60, 60, 60))
submitImportBtn.Size = UDim2.new(0.5, -4, 0, 22)
submitImportBtn.Position = UDim2.new(0, 8, 1, -28)
submitImportBtn.ZIndex = 6

local cancelImportBtn = createButton(importPopup, "Cancel", Color3.fromRGB(80, 40, 40))
cancelImportBtn.Size = UDim2.new(0.5, -4, 0, 22)
cancelImportBtn.Position = UDim2.new(0.5, 4, 1, -28)
cancelImportBtn.ZIndex = 6

-- Watermark
local watermark = Instance.new("TextLabel")
watermark.Size = UDim2.new(1, 0, 0, 15)
watermark.Position = UDim2.new(0, 0, 1, -15)
watermark.BackgroundTransparency = 1
watermark.Text = "Made By BhuzelRayhan"
watermark.Font = Enum.Font.Gotham
watermark.TextSize = 9
watermark.TextColor3 = Color3.fromRGB(200, 200, 200)
watermark.TextTransparency = 0.6
watermark.Parent = container

-- Fungsi Minimize
local isMinimized = false
minBtn.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	if isMinimized then
		container.Size = UDim2.new(0, 220, 0, 35)
		scrollFrame.Visible = false
		configFrame.Visible = false
		watermark.Visible = false
		importPopup.Visible = false
	else
		container.Size = UDim2.new(0, 220, 0, 360)
		scrollFrame.Visible = true
		configFrame.Visible = true
		watermark.Visible = true
	end
end)

local rows = {}
local createRow 

createRow = function(isRoot, loadData)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 60)
	row.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	row.BorderSizePixel = 0
	row.Parent = scrollFrame

	local rowCorner = Instance.new("UICorner")
	rowCorner.CornerRadius = UDim.new(0, 6)
	rowCorner.Parent = row

	-- UPDATE: Mendukung pengambilan nama dari "nameBhuzelRayhan", "nameZellRayy", atau fallback ke format lama "name"
	local loadedName = ""
	if loadData then
		loadedName = loadData.nameBhuzelRayhan or loadData.nameZellRayy or loadData.name or ""
	end

	local nameBox = Instance.new("TextBox")
	nameBox.Size = UDim2.new(1, -30, 0, 20)
	nameBox.Position = UDim2.new(0, 8, 0, 6)
	nameBox.BackgroundTransparency = 1
	nameBox.Text = loadedName
	nameBox.PlaceholderText = "Label posisi..."
	nameBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
	nameBox.Font = Enum.Font.Gotham
	nameBox.TextSize = 12
	nameBox.TextColor3 = Color3.fromRGB(220, 220, 220)
	nameBox.TextXAlignment = Enum.TextXAlignment.Left
	nameBox.Parent = row

	local saveBtn = createButton(row, "Save", Color3.fromRGB(45, 45, 45))
	saveBtn.Size = UDim2.new(0.5, -12, 0, 22)
	saveBtn.Position = UDim2.new(0, 8, 1, -28)
	
	local loadBtn = createButton(row, "Load", Color3.fromRGB(60, 60, 60))
	loadBtn.Size = UDim2.new(0.5, -12, 0, 22)
	loadBtn.Position = UDim2.new(0.5, 4, 1, -28)

	local savedPos = loadData and Vector3.new(loadData.x, loadData.y, loadData.z) or nil

	local rowData = {
		frame = row,
		nameBox = nameBox,
		getPos = function() return savedPos end
	}

	saveBtn.MouseButton1Click:Connect(function()
		local char = player.Character or player.CharacterAdded:Wait()
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp then
			savedPos = hrp.Position
			local origText = saveBtn.Text
			saveBtn.Text = "Saved"
			task.wait(0.5)
			saveBtn.Text = origText
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
		deleteBtn.Position = UDim2.new(1, -24, 0, 6)
		deleteBtn.Text = "×"
		deleteBtn.Font = Enum.Font.FredokaOne
		deleteBtn.TextSize = 14
		deleteBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
		deleteBtn.BackgroundTransparency = 1
		deleteBtn.Parent = row

		deleteBtn.MouseButton1Click:Connect(function()
			for i, r in ipairs(rows) do
				if r == rowData then
					table.remove(rows, i)
					break
				end
			end
			row:Destroy()
		end)
	end

	table.insert(rows, rowData)
	row.LayoutOrder = #rows
	return rowData
end

addBtn.MouseButton1Click:Connect(function() createRow(false) end)

-- LOGIKA EXPORT DENGAN BRANDING
exportBtn.MouseButton1Click:Connect(function()
	local exportData = {}
	for _, r in ipairs(rows) do
		local pos = r.getPos()
		if pos then
			-- UPDATE: Menyimpan data label dengan key khusus
			table.insert(exportData, {
				nameBhuzelRayhan = r.nameBox.Text,
				x = pos.X, y = pos.Y, z = pos.Z
			})
		end
	end
	
	if #exportData > 0 then
		local json = HttpService:JSONEncode(exportData)
		if setclipboard then setclipboard(json) elseif toclipboard then toclipboard(json) end
		
		local origText = exportBtn.Text
		exportBtn.Text = "Copied!"
		task.wait(1)
		exportBtn.Text = origText
	else
		local origText = exportBtn.Text
		exportBtn.Text = "Empty!"
		task.wait(1)
		exportBtn.Text = origText
	end
end)

-- LOGIKA IMPORT
importBtn.MouseButton1Click:Connect(function()
	importBox.Text = ""
	importPopup.Visible = true
	scrollFrame.Visible = false
end)

cancelImportBtn.MouseButton1Click:Connect(function()
	importPopup.Visible = false
	scrollFrame.Visible = true
end)

submitImportBtn.MouseButton1Click:Connect(function()
	local jsonText = importBox.Text
	local success, decodedData = pcall(function()
		return HttpService:JSONDecode(jsonText)
	end)
	
	if success and type(decodedData) == "table" then
		for _, r in ipairs(rows) do
			r.frame:Destroy()
		end
		rows = {}
		
		for i, data in ipairs(decodedData) do
			createRow(i == 1, data)
		end
		
		if #rows == 0 then createRow(true) end
		
		importPopup.Visible = false
		scrollFrame.Visible = true
		
		local origText = importBtn.Text
		importBtn.Text = "Success!"
		task.wait(1)
		importBtn.Text = origText
	else
		local origText = submitImportBtn.Text
		submitImportBtn.Text = "Invalid JSON!"
		task.wait(1)
		submitImportBtn.Text = origText
	end
end)

createRow(true)
