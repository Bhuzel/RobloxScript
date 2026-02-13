-- ========================================
-- FLY SCRIPT BY ZELLRAYY  - STRICT MODE
-- ========================================

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local RunService = game:GetService("RunService")

local char = player.Character or player.CharacterAdded:Wait()
local mainPart = nil
local flying = false
local noclip = false
local speed = 50
local bg, bv

local ctrl = {f = 0, b = 0, l = 0, r = 0, u = 0, d = 0}
local lastctrl = {f = 0, b = 0, l = 0, r = 0, u = 0, d = 0}
local maxspeed = 0

local function notify(msg)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = "FLY CONTROL",
            Text = msg,
            Duration = 2
        })
    end)
end

function getMainPart()
    if char:FindFirstChild("HumanoidRootPart") then return char.HumanoidRootPart end
    if char.PrimaryPart then return char.PrimaryPart end
    
    local parts = char:GetDescendants()
    local biggest = nil
    local maxSz = 0
    for _, obj in pairs(parts) do
        if obj:IsA("BasePart") then
            if obj.Size.Magnitude > maxSz then
                maxSz = obj.Size.Magnitude
                biggest = obj
            end
        end
    end
    return biggest
end

RunService.Stepped:Connect(function()
    if flying and noclip and char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

local function startFly()
    mainPart = getMainPart()
    if not mainPart then notify("Character part not found!") return end

    flying = true
    notify("Fly: ON (Speed: "..speed..")")
    
    mainPart.Anchored = false
    
    bg = Instance.new("BodyGyro")
    bg.P = 9e4
    bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.cframe = mainPart.CFrame
    bg.Parent = mainPart
    
    bv = Instance.new("BodyVelocity")
    bv.velocity = Vector3.new(0,0,0)
    bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Parent = mainPart
    
    repeat wait()
        if not flying or not mainPart or not mainPart.Parent then break end
        
        if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 or ctrl.u + ctrl.d ~= 0 then
            maxspeed = speed
        elseif maxspeed ~= 0 then
            maxspeed = 0
        end
        
        local camCF = workspace.CurrentCamera.CoordinateFrame
        
        if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 or (ctrl.u + ctrl.d) ~= 0 then
            bv.velocity = (
                (camCF.lookVector * (ctrl.f + ctrl.b)) + 
                (camCF.rightVector * (ctrl.l + ctrl.r)) + 
                (camCF.upVector * (ctrl.u + ctrl.d))
            ) * maxspeed
            lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r, u = ctrl.u, d = ctrl.d}
        elseif maxspeed ~= 0 then
            bv.velocity = (
                (camCF.lookVector * (lastctrl.f + lastctrl.b)) + 
                (camCF.rightVector * (lastctrl.l + lastctrl.r)) + 
                (camCF.upVector * (lastctrl.u + lastctrl.d))
            ) * maxspeed
        else
            bv.velocity = Vector3.new(0,0,0)
        end
        
        bg.cframe = camCF
    until not flying
    
    ctrl = {f = 0, b = 0, l = 0, r = 0, u = 0, d = 0}
    lastctrl = {f = 0, b = 0, l = 0, r = 0, u = 0, d = 0}
    maxspeed = 0
    
    if bg then bg:Destroy() end
    if bv then bv:Destroy() end
    
    noclip = false 
    notify("Fly: OFF (Noclip Disabled)")
end

mouse.KeyDown:Connect(function(key)
    key = key:lower()

    if key == "t" then
        if flying then
            flying = false
        else
            startFly()
        end
        return 
    end

    if not flying then return end

    if key == "n" then
        noclip = not noclip
        if noclip then notify("Noclip: ON") else notify("Noclip: OFF") end
        
    elseif key == "w" then ctrl.f = 1
    elseif key == "s" then ctrl.b = -1
    elseif key == "a" then ctrl.l = -1
    elseif key == "d" then ctrl.r = 1
    elseif key == "e" then ctrl.u = 1
    elseif key == "q" then ctrl.d = -1
        
    elseif key == "=" or key == "+" then
        speed = speed + 10
        notify("Speed: " .. speed)
    elseif key == "-" then
        speed = speed - 10
        if speed < 10 then speed = 10 end
        notify("Speed: " .. speed)
    end
end)

mouse.KeyUp:Connect(function(key)
    key = key:lower()
    if key == "w" then ctrl.f = 0
    elseif key == "s" then ctrl.b = 0
    elseif key == "a" then ctrl.l = 0
    elseif key == "d" then ctrl.r = 0
    elseif key == "e" then ctrl.u = 0
    elseif key == "q" then ctrl.d = 0
    end
end)

player.CharacterAdded:Connect(function(newChar)
    flying = false
    noclip = false
    char = newChar
end)

notify("Script Fly ZellRayy Loaded! Press T to Start")
