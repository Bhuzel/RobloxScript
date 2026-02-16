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
screenGui.Name = "MultiSaveLoadGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Frame Kontainer
local container = Instance.new("Frame")
container.Size = UDim2.new(0, 340, 0, 400)
container.Position = UDim2.new(0.5, -170, 0.5, -200)
container.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- Hitam pekat
container.BorderSizePixel = 2
container.BorderColor3 = Color3.fromRGB(150, 150, 150) -- Abu-abu terang
container.Parent = screenGui

-- Title Bar (Area untuk memindahkan GUI)
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40) -- Abu-abu gelap
titleBar.BorderSizePixel = 0
titleBar.Parent = container

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -50, 1, 0)
titleText.Position = UDim2.new(0, 15, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "Position Manager"
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 16
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

-- Tombol Tambah Row (+)
local addBtn = Instance.new("TextButton")
addBtn.Size = UDim2.new(0, 30, 0, 30)
addBtn.Position = UDim2.new(1, -35, 0.5, -15)
addBtn.Text = "+"
addBtn.Font = Enum.Font.GothamBold
addBtn.TextSize = 20
addBtn.TextColor3 = Color3.fromRGB(20, 20, 20)
addBtn.BackgroundColor3 = Color3.fromRGB(230, 230, 230) -- Putih/Abu sangat terang
addBtn.BorderSizePixel = 0
addBtn.Parent = titleBar

-- Sistem Dragging yang Halus
local dragging
local dragInput
local dragStart
local startPos

titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = container.Position
		
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
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

-- Area Scroll untuk List Posisi
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 1, -60)
scrollFrame.Position = UDim2.new(0, 10, 0, 50)
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.ScrollBarThickness = 6
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(150, 150, 150)
scrollFrame.BackgroundTransparency = 1
scrollFrame.Parent = container

local listLayout = Instance.new("UIListLayout")
listLayout.Parent = scrollFrame
listLayout.Padding = UDim.new(0, 8)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder

local rows = {}

local function createRow(isRoot)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 45)
	row.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	row.BorderSizePixel = 1
	row.BorderColor3 = Color3.fromRGB(80, 80, 80)
	row.Parent = scrollFrame

	-- TextBox untuk menandai/menamai posisi
	local nameBox = Instance.new("TextBox")
	nameBox.Size = UDim2.new(1, -125, 1, -10)
	nameBox.Position = UDim2.new(0, 5, 0, 5)
	nameBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	nameBox.BorderSizePixel = 1
	nameBox.BorderColor3 = Color3.fromRGB(60, 60, 60)
	nameBox.Text = " Nama Posisi..."
	nameBox.Font = Enum.Font.Gotham
	nameBox.TextSize = 13
	nameBox.TextColor3 = Color3.fromRGB(220, 220, 220)
	nameBox.TextXAlignment = Enum.TextXAlignment.Left
	nameBox.ClearTextOnFocus = false
	nameBox.Parent = row

	local saveBtn = Instance.new("TextButton")
	saveBtn.Size = UDim2.new(0, 55, 1, -10)
	saveBtn.Position = UDim2.new(1, -115, 0, 5)
	saveBtn.Text = "Save"
	saveBtn.Font = Enum.Font.GothamSemibold
	saveBtn.TextSize = 13
	saveBtn.TextColor3 = Color3.fromRGB(20, 20, 20)
	saveBtn.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
	saveBtn.BorderSizePixel = 0
	saveBtn.Parent = row

	local loadBtn = Instance.new("TextButton")
	loadBtn.Size = UDim2.new(0, 55, 1, -10)
	loadBtn.Position = UDim2.new(1, -55, 0, 5)
	loadBtn.Text = "Load"
	loadBtn.Font = Enum.Font.GothamSemibold
	loadBtn.TextSize = 13
	loadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	loadBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	loadBtn.BorderSizePixel = 0
	loadBtn.Parent = row

	local deleteBtn
	if not isRoot then
		-- Sesuaikan ukuran jika ada tombol hapus
		nameBox.Size = UDim2.new(1, -155, 1, -10)
		saveBtn.Position = UDim2.new(1, -145, 0, 5)
		loadBtn.Position = UDim2.new(1, -85, 0, 5)

		deleteBtn = Instance.new("TextButton")
		deleteBtn.Size = UDim2.new(0, 25, 1, -10)
		deleteBtn.Position = UDim2.new(1, -25, 0, 5)
		deleteBtn.Text = "X"
		deleteBtn.Font = Enum.Font.GothamBold
		deleteBtn.TextSize = 14
		deleteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		deleteBtn.BackgroundColor3 = Color3.fromRGB(100, 30, 30) -- Merah gelap agar selaras dengan nuansa gelap
		deleteBtn.BorderSizePixel = 0
		deleteBtn.Parent = row
	end

	local savedPos

	saveBtn.MouseButton1Click:Connect(function()
		local char = player.Character or player.CharacterAdded:Wait()
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp then
			savedPos = hrp.Position
			-- Efek visual kecil saat disimpan
			local originalText = saveBtn.Text
			saveBtn.Text = "Saved!"
			task.wait(0.8)
			saveBtn.Text = originalText
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

	if deleteBtn then
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

-- Buat row pertama
createRow(true)
