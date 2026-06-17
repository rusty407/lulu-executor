-- NEON EXECUTOR - Roblox Edition
-- Paste into StarterGui > LocalScript

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NeonExecutor"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "Main"
mainFrame.Size = UDim2.new(0, 920, 0, 620)
mainFrame.Position = UDim2.new(0.5, -460, 0.5, -310)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 12)
uiCorner.Parent = mainFrame

local uiStroke = Instance.new("UIStroke")
uiStroke.Color = Color3.fromRGB(0, 255, 200)
uiStroke.Thickness = 1.5
uiStroke.Transparency = 0.7
uiStroke.Parent = mainFrame

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 50)
titleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.4, 0, 1, 0)
title.BackgroundTransparency = 1
title.Text = "NEON EXECUTOR"
title.TextColor3 = Color3.fromRGB(0, 255, 200)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = titleBar

-- Buttons
local function createButton(text, pos, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 110, 0, 32)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    btn.Text = text
    btn.TextColor3 = color
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.Parent = titleBar

    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = color
    stroke.Transparency = 0.6

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 55)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(20, 20, 30)}):Play()
    end)

    return btn
end

local executeBtn = createButton("▶ EXECUTE", UDim2.new(1, -280, 0.5, -16), Color3.fromRGB(0, 255, 140))
local injectBtn = createButton("⚡ INJECT", UDim2.new(1, -160, 0.5, -16), Color3.fromRGB(255, 100, 50))

-- Code Editor
local editorFrame = Instance.new("Frame")
editorFrame.Size = UDim2.new(1, -20, 0.65, -70)
editorFrame.Position = UDim2.new(0, 10, 0, 60)
editorFrame.BackgroundColor3 = Color3.fromRGB(13, 13, 20)
editorFrame.Parent = mainFrame

Instance.new("UICorner", editorFrame).CornerRadius = UDim.new(0, 10)

local codeBox = Instance.new("TextBox")
codeBox.Size = UDim2.new(1, -60, 1, -10)
codeBox.Position = UDim2.new(0, 55, 0, 5)
codeBox.BackgroundTransparency = 1
codeBox.Text = '-- Welcome to NEON EXECUTOR\nprint("Hello from Neon!")'
codeBox.TextColor3 = Color3.fromRGB(220, 220, 230)
codeBox.TextXAlignment = Enum.TextXAlignment.Left
codeBox.TextYAlignment = Enum.TextYAlignment.Top
codeBox.TextWrapped = true
codeBox.ClearTextOnFocus = false
codeBox.MultiLine = true
codeBox.Font = Enum.Font.Code
codeBox.TextSize = 15
codeBox.Parent = editorFrame

-- Line Numbers
local lineNumbers = Instance.new("TextLabel")
lineNumbers.Size = UDim2.new(0, 45, 1, -10)
lineNumbers.Position = UDim2.new(0, 8, 0, 5)
lineNumbers.BackgroundTransparency = 1
lineNumbers.Text = "1\n2\n3"
lineNumbers.TextColor3 = Color3.fromRGB(100, 100, 120)
lineNumbers.TextYAlignment = Enum.TextYAlignment.Top
lineNumbers.TextXAlignment = Enum.TextXAlignment.Right
lineNumbers.Font = Enum.Font.Code
lineNumbers.TextSize = 15
lineNumbers.Parent = editorFrame

-- Console
local consoleFrame = Instance.new("Frame")
consoleFrame.Size = UDim2.new(1, -20, 0.28, -10)
consoleFrame.Position = UDim2.new(0, 10, 0.72, 0)
consoleFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
consoleFrame.Parent = mainFrame

Instance.new("UICorner", consoleFrame).CornerRadius = UDim.new(0, 10)

local consoleLog = Instance.new("ScrollingFrame")
consoleLog.Size = UDim2.new(1, -10, 1, -10)
consoleLog.Position = UDim2.new(0, 5, 0, 5)
consoleLog.BackgroundTransparency = 1
consoleLog.ScrollBarThickness = 6
consoleLog.Parent = consoleFrame

local consoleLayout = Instance.new("UIListLayout", consoleLog)
consoleLayout.SortOrder = Enum.SortOrder.LayoutOrder
consoleLayout.Padding = UDim.new(0, 2)

local function log(text, color)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color or Color3.fromRGB(180, 180, 190)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Code
    label.TextSize = 14
    label.TextWrapped = true
    label.Parent = consoleLog
    consoleLog.CanvasPosition = Vector2.new(0, consoleLog.AbsoluteCanvasSize.Y)
end

log("NEON EXECUTOR initialized.", Color3.fromRGB(0, 255, 200))
log("Ready. Press Execute or Ctrl+Enter.", Color3.fromRGB(100, 200, 255))

-- Execute Function
local function executeCode()
    local code = codeBox.Text
    log("Executing script...", Color3.fromRGB(0, 255, 140))

    local success, err = pcall(function()
        loadstring(code)()
    end)

    if success then
        log("Executed successfully.", Color3.fromRGB(0, 255, 140))
    else
        log("[ERROR] " .. tostring(err), Color3.fromRGB(255, 80, 80))
    end
end

executeBtn.MouseButton1Click:Connect(executeCode)
injectBtn.MouseButton1Click:Connect(function()
    log("Inject simulated (Roblox executor style)", Color3.fromRGB(255, 160, 50))
end)

-- Ctrl + Enter support
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Return and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        executeCode()
    end
end)

-- Auto update line numbers
codeBox:GetPropertyChangedSignal("Text"):Connect(function()
    local lines = #codeBox.Text:split("\n")
    local numText = ""
    for i = 1, lines do
        numText = numText .. i .. "\n"
    end
    lineNumbers.Text = numText
end)

-- Draggable
local dragging, dragInput, dragStart, startPos
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

print("NEON EXECUTOR loaded successfully!")
