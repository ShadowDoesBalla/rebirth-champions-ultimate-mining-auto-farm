local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit.KnitClient)

local player = Players.LocalPlayer
local OreService = Knit.GetService("OreService")
local damageRemote = OreService.damage._re

local oreNames = {
    "ironOre",
    "golfOre",
    "diamondOre",
    "rubyOre",
    "emeraldOre",
    "cobaltOre",
    "sapphireOre",
    "titaniumOre",
    "uraniumOre",
    "platinumOre",
    "sunstoneOre"
}

local enabledOres = {}
for _, ore in ipairs(oreNames) do
    enabledOres[ore] = true
end

local autofarmEnabled = false
local toggleKey = Enum.KeyCode.T
local killswitch = false

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "OreFarmUI"
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 520)
frame.Position = UDim2.new(0, 50, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(40,40,40)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1,0,0,30)
titleBar.Position = UDim2.new(0,0,0,0)
titleBar.BackgroundColor3 = Color3.fromRGB(30,30,30)
titleBar.Parent = frame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0.7,0,1,0)
titleLabel.Position = UDim2.new(0,5,0,0)
titleLabel.Text = "Ore Autofarm"
titleLabel.TextColor3 = Color3.new(1,1,1)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 18
titleLabel.Parent = titleBar

local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -10,0,25)
statusLabel.Position = UDim2.new(0,5,0,35)
statusLabel.Text = "Status: OFF"
statusLabel.TextColor3 = Color3.new(1,1,1)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.SourceSans
statusLabel.TextSize = 18
statusLabel.Parent = frame

local startY = 70
local oreButtons = {}
for i, ore in ipairs(oreNames) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20,0,25)
    btn.Position = UDim2.new(0,10,0,startY + (i-1)*30)
    btn.Text = ore..": ON"
    btn.TextColor3 = Color3.new(1,1,1)
    btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 18
    btn.Parent = frame
    oreButtons[ore] = btn

    btn.MouseButton1Click:Connect(function()
        enabledOres[ore] = not enabledOres[ore]
        btn.Text = ore..": "..(enabledOres[ore] and "ON" or "OFF")
    end)
end

local keyLabel = Instance.new("TextLabel")
keyLabel.Size = UDim2.new(1, -20,0,25)
keyLabel.Position = UDim2.new(0,10,0,startY + #oreNames*30 + 10)
keyLabel.Text = "Toggle Key: "..toggleKey.Name
keyLabel.TextColor3 = Color3.new(1,1,1)
keyLabel.BackgroundTransparency = 1
keyLabel.Font = Enum.Font.SourceSans
keyLabel.TextSize = 18
keyLabel.Parent = frame

local changeKeyBtn = Instance.new("TextButton")
changeKeyBtn.Size = UDim2.new(1, -20,0,25)
changeKeyBtn.Position = UDim2.new(0,10,0,startY + #oreNames*30 + 40)
changeKeyBtn.Text = "Change Keybind"
changeKeyBtn.TextColor3 = Color3.new(1,1,1)
changeKeyBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
changeKeyBtn.Font = Enum.Font.SourceSans
changeKeyBtn.TextSize = 18
changeKeyBtn.Parent = frame

local waitingForKey = false
changeKeyBtn.MouseButton1Click:Connect(function()
    waitingForKey = true
    changeKeyBtn.Text = "Press any key..."
end)

local killBtn = Instance.new("TextButton")
killBtn.Size = UDim2.new(1, -20,0,25)
killBtn.Position = UDim2.new(0,10,0,startY + #oreNames*30 + 70)
killBtn.Text = "Killswitch"
killBtn.TextColor3 = Color3.new(1,1,1)
killBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
killBtn.Font = Enum.Font.SourceSans
killBtn.TextSize = 18
killBtn.Parent = frame

killBtn.MouseButton1Click:Connect(function()
    killswitch = true
    autofarmEnabled = false
    screenGui:Destroy()
end)

local credits = Instance.new("TextLabel")
credits.Size = UDim2.new(1, -10,0,25)
credits.Position = UDim2.new(0,10,0,startY + #oreNames*30 + 100)
credits.Text = "Made by Shadow"
credits.TextColor3 = Color3.new(1,1,1)
credits.BackgroundTransparency = 1
credits.Font = Enum.Font.SourceSansItalic
credits.TextSize = 16
credits.Parent = frame

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == toggleKey then
        autofarmEnabled = not autofarmEnabled
        statusLabel.Text = "Status: "..(autofarmEnabled and "ON" or "OFF")
    end
    if waitingForKey and input.UserInputType == Enum.UserInputType.Keyboard then
        toggleKey = input.KeyCode
        keyLabel.Text = "Toggle Key: "..toggleKey.Name
        changeKeyBtn.Text = "Change Keybind"
        waitingForKey = false
    end
end)

local function getEnabledOres()
    local debris = workspace:FindFirstChild("Debris")
    if not debris then return {} end
    local ores = {}
    for _, oreName in ipairs(oreNames) do
        if enabledOres[oreName] then
            local ore = debris:FindFirstChild(oreName)
            if ore then table.insert(ores, ore) end
        end
    end
    return ores
end

spawn(function()
    while true do
        if killswitch then break end
        if autofarmEnabled then
            local ores = getEnabledOres()
            for _, ore in ipairs(ores) do
                if killswitch then break end
                if ore and ore.Parent then
                    local oreId = ore:GetAttribute("id")
                    local roomId = ore:GetAttribute("roomId")
                    if oreId and roomId then
                        while ore and ore.Parent and autofarmEnabled and not killswitch do
                            damageRemote:FireServer(roomId, oreId)
                            task.wait(0.1)
                        end
                    end
                end
            end
        end
        task.wait(0.2)
    end
end)