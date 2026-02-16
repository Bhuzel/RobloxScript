pcall(function()
	if setclipboard then
		setclipboard("Made by SmileX")
	elseif toclipboard then
		toclipboard("Made by SmileX")
	end
end)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Setup GUI Utama
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ElegantSaveLoadGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Frame Kontainer Utama
local container = Instance.new("Frame")
container.Size = UDim2.new(0, 220, 0, 320)
container.Position = UDim2.new(0.5, -110, 0.5, -160)
container.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
container.BorderSizePixel = 0
container.ClipsDescendants = true
container.Parent = screenGui

local containerCorner = Instance.new("UICorner")
containerCorner.CornerRadius = UDim.new(0, 8)
containerCorner.Parent = container

-- Title Bar (Area Dragging)
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
titleBar.BorderSizePixel = 0
titleBar.Parent = container

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleBar

-- Fix untuk menutupi sudut bawah title bar agar menyatu dengan container
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
titleText.Font = Enum.Font.GothamMedium
titleText.TextSize = 13
titleText.TextColor3 = Color3.fromRGB(200, 200, 200)
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

-- Tombol Minimize (-)
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 25, 0, 25)
minBtn.Position = UDim2.new(1, -60, 0.5, -12.5)
minBtn.Text = "-"
minBtn.Font = Enum.Font.GothamMedium
minBtn.TextSize = 16
minBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
minBtn.BackgroundTransparency = 1
minBtn.Parent = titleBar

-- Tombol Tambah Row (+)
local addBtn = Instance.new("TextButton")
addBtn.Size = UDim2.new(0, 25, 0, 25)
addBtn.Position = UDim2.new(1, -30, 0.5, -12.5)
addBtn.Text = "+"
addBtn.Font = Enum.Font.GothamMedium
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
scrollFrame.Size = UDim2.new(1, -16, 1, -45)
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

-- Fungsi Minimize
local isMinimized = false
minBtn.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	if isMinimized then
		container.Size = UDim2.new(0, 220, 0, 35)
		scrollFrame.Visible = false
	else
		container.Size = UDim2.new(0, 220, 0, 320)
		scrollFrame.Visible = true
	end
end)

local rows = {}

local function createButton(parent, text, xPos, color)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.5, -4, 0, 22)
	btn.Position = UDim2.new(xPos, 0, 1, -28)
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

local function createRow(isRoot)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 60)
	row.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	row.BorderSizePixel = 0
	row.Parent = scrollFrame

	local rowCorner = Instance.new("UICorner")
	rowCorner.CornerRadius = UDim.new(0, 6)
	rowCorner.Parent = row

	-- TextBox (Teks Kosong, Placeholder Saja)
	local nameBox = Instance.new("TextBox")
	nameBox.Size = UDim2.new(1, -30, 0, 20)
	nameBox.Position = UDim2.new(0, 8, 0, 6)
	nameBox.BackgroundTransparency = 1
	nameBox.Text = ""
	nameBox.PlaceholderText = "Label posisi..."
	nameBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
	nameBox.Font = Enum.Font.Gotham
	nameBox.TextSize = 12
	nameBox.TextColor3 = Color3.fromRGB(220, 220, 220)
	nameBox.TextXAlignment = Enum.TextXAlignment.Left
	nameBox.Parent = row

	-- Tombol Save & Load di bawah
	local saveBtn = createButton(row, "Save", 0, Color3.fromRGB(45, 45, 45))
	saveBtn.Position = UDim2.new(0, 8, 1, -28)
	
	local loadBtn = createButton(row, "Load", 0, Color3.fromRGB(60, 60, 60))
	loadBtn.Position = UDim2.new(0.5, 4, 1, -28)
	loadBtn.Size = UDim2.new(0.5, -12, 0, 22)

	local savedPos

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
		deleteBtn.Font = Enum.Font.GothamMedium
		deleteBtn.TextSize = 14
		deleteBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
		deleteBtn.BackgroundTransparency = 1
		deleteBtn.Parent = row

		deleteBtn.MouseButton1Click:Connect(function()
			for i, r in ipairs(rows) do
				if r == row then
					table.remove(rows, i)
					break
				end
			end
			row:Destroy()
		end)
	end

	table.insert(rows, row)
	row.LayoutOrder = #rows
	return row
end

addBtn.MouseButton1Click:Connect(function()
	createRow(false)
end)

-- Buat row default pertama
createRow(true)
