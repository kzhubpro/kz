-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- Utility functions
local function getTime() return os.clock() end

local function waitForChild(parent, childName, timeout)
    timeout = timeout or 10
    local startTime = getTime()
    while getTime() - startTime < timeout do
        local child = parent and parent:FindFirstChild(childName)
        if child then return child end
        task.wait(0.1)
    end
    return nil
end

local function waitForFunction(func, timeout, interval)
    timeout = timeout or 10
    interval = interval or 0.1
    local startTime = getTime()
    while getTime() - startTime < timeout do
        local success, result = pcall(func)
        if success and result then return true end
        task.wait(interval)
    end
    return false
end

local function measureFPS(targetFPS, holdTime, maxTime, callback)
    targetFPS = targetFPS or 10
    holdTime = holdTime or 1.0
    maxTime = maxTime or 30
    
    local startTime = getTime()
    local fpsStart = nil
    local avgFPS = 60
    local smoothFactor = 0.15
    local lastCallback = getTime()
    
    local heartbeatConnection
    heartbeatConnection = RunService.Heartbeat:Connect(function(deltaTime)
        if deltaTime > 0 then
            local instantFPS = 1 / deltaTime
            avgFPS = avgFPS + (instantFPS - avgFPS) * smoothFactor
        end
    end)
    
    while getTime() - startTime < maxTime do
        if callback and getTime() - lastCallback >= 0.2 then
            lastCallback = getTime()
            callback(math.floor(avgFPS + 0.5))
        end
        
        if avgFPS >= targetFPS then
            if not fpsStart then fpsStart = getTime() end
            if getTime() - fpsStart >= holdTime then
                if heartbeatConnection then heartbeatConnection:Disconnect() end
                return true, avgFPS
            end
        else
            fpsStart = nil
        end
        task.wait(0.1)
    end
    
    if heartbeatConnection then heartbeatConnection:Disconnect() end
    return false, avgFPS
end

-- Intro screen if wrong game
local function showWrongGameScreen(playerGui)
    local screenGui = Instance.new("ScreenGui")
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    
    local bgFade = Instance.new("Frame")
    bgFade.Size = UDim2.new(1, 0, 1, 0)
    bgFade.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bgFade.BackgroundTransparency = 1
    bgFade.Parent = screenGui
    
    local textFrame = Instance.new("Frame")
    textFrame.Size = UDim2.new(1, 0, 1, 0)
    textFrame.BackgroundTransparency = 1
    textFrame.Parent = screenGui
    
    local vietText = Instance.new("TextLabel")
    vietText.Size = UDim2.new(1, 0, 0.1, 0)
    vietText.Position = UDim2.new(0, 0, 0.4, 0)
    vietText.Text = "Vào game để bật script"
    vietText.TextColor3 = Color3.fromRGB(255, 255, 255)
    vietText.TextSize = 40
    vietText.Font = Enum.Font.GothamBold
    vietText.BackgroundTransparency = 1
    vietText.TextTransparency = 1
    vietText.Parent = textFrame
    
    local engText = Instance.new("TextLabel")
    engText.Size = UDim2.new(1, 0, 0.1, 0)
    engText.Position = UDim2.new(0, 0, 0.5, 0)
    engText.Text = "Join the game to enable the script"
    engText.TextColor3 = Color3.fromRGB(255, 255, 255)
    engText.TextSize = 40
    engText.Font = Enum.Font.GothamBold
    engText.BackgroundTransparency = 1
    engText.TextTransparency = 1
    engText.Parent = textFrame
    
    local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
    
    TweenService:Create(bgFade, tweenInfo, {BackgroundTransparency = 0.3}):Play()
    task.wait(1.5)
    TweenService:Create(vietText, tweenInfo, {TextTransparency = 0}):Play()
    TweenService:Create(engText, tweenInfo, {TextTransparency = 0}):Play()
    task.wait(4)
    TweenService:Create(bgFade, tweenInfo, {BackgroundTransparency = 1}):Play()
    TweenService:Create(vietText, tweenInfo, {TextTransparency = 1}):Play()
    TweenService:Create(engText, tweenInfo, {TextTransparency = 1}):Play()
    task.wait(1.5)
    screenGui:Destroy()
end

-- Main loading GUI
local function createLoadingGui(playerGui, playerName, userId)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "IntroGui"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = playerGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    mainFrame.Position = UDim2.new(0.5, 0, 0.1, 0)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.LineJoinMode = Enum.LineJoinMode.Round
    stroke.Parent = mainFrame
    
    -- Rainbow border animation
    task.spawn(function()
        local hue = 0
        while screenGui.Parent do
            hue = (hue + 1) % 360
            stroke.Color = Color3.fromHSV(hue / 360, 1, 1)
            task.wait(0.03)
        end
    end)
    
    local avatar = Instance.new("ImageLabel")
    avatar.Size = UDim2.new(0, 50, 0, 50)
    avatar.Position = UDim2.new(0, 20, 0, 20)
    avatar.BackgroundTransparency = 1
    avatar.Image = ("https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=420&height=420&format=png"):format(userId)
    avatar.Parent = mainFrame
    
    local avatarStroke = Instance.new("UIStroke")
    avatarStroke.Thickness = 3
    avatarStroke.Color = Color3.fromRGB(255, 255, 255)
    avatarStroke.Parent = avatar
    
    local greeting = Instance.new("TextLabel")
    greeting.Size = UDim2.new(1, -90, 0, 20)
    greeting.Position = UDim2.new(0, 80, 0, 15)
    greeting.BackgroundTransparency = 1
    greeting.Text = "Chào bro nhaa: " .. playerName
    greeting.TextColor3 = Color3.fromRGB(255, 255, 255)
    greeting.TextXAlignment = Enum.TextXAlignment.Left
    greeting.Font = Enum.Font.GothamMedium
    greeting.TextSize = 16
    greeting.Parent = mainFrame
    
    local tiktokLabel = Instance.new("TextLabel")
    tiktokLabel.Size = UDim2.new(1, -20, 0, 20)
    tiktokLabel.Position = UDim2.new(0, 20, 0, 80)
    tiktokLabel.BackgroundTransparency = 1
    tiktokLabel.Text = "Tiktok : @nguyndiz"
    tiktokLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    tiktokLabel.Font = Enum.Font.GothamBold
    tiktokLabel.TextSize = 15
    tiktokLabel.TextXAlignment = Enum.TextXAlignment.Left
    tiktokLabel.Parent = mainFrame
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -20, 0, 20)
    statusLabel.Position = UDim2.new(0, 20, 0, 100)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Đang check..."
    statusLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
    statusLabel.Font = Enum.Font.GothamBlack
    statusLabel.TextSize = 15
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = mainFrame
    
    local progressBarBg = Instance.new("Frame")
    progressBarBg.Size = UDim2.new(1, -90, 0, 15)
    progressBarBg.Position = UDim2.new(0, 80, 0, 45)
    progressBarBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    progressBarBg.BorderSizePixel = 0
    progressBarBg.Parent = mainFrame
    Instance.new("UICorner", progressBarBg).CornerRadius = UDim.new(0, 6)
    
    local progressBar = Instance.new("Frame")
    progressBar.Size = UDim2.new(0, 0, 1, 0)
    progressBar.BackgroundColor3 = Color3.fromRGB(0, 175, 255)
    progressBar.BorderSizePixel = 0
    progressBar.Parent = progressBarBg
    Instance.new("UICorner", progressBar).CornerRadius = UDim.new(0, 6)
    
    -- Animate in
    local showTween = TweenService:Create(mainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 440, 0, 130),
        Position = UDim2.new(0.5, -220, 0.1, 0)
    })
    showTween:Play()
    showTween.Completed:Wait()
    
    local gui = {}
    
    function gui:SetStatus(text)
        statusLabel.Text = text or statusLabel.Text
    end
    
    function gui:SetProgress(value)
        value = math.clamp(value or 0, 0, 1)
        progressBar.Size = UDim2.new(value, 0, 1, 0)
    end
    
    function gui:Close()
        local closeTween = TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.1, 0)
        })
        print("Thank For Intro By Rez")
        closeTween:Play()
        closeTween.Completed:Wait()
        screenGui:Destroy()
    end
    
    function gui:Destroy()
        if screenGui then screenGui:Destroy() end
    end
    
    return gui
end

-- Main initialization
local function initialize()
    local playerGui = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then 
        playerGui = waitForChild(LocalPlayer, "PlayerGui", 15)
    end
    if not playerGui then return end
    
    -- Show specific game check
    if game.PlaceId == 79546208627805 then 
        showWrongGameScreen(playerGui)
        return 
    end
    
    local loadingGui = createLoadingGui(playerGui, LocalPlayer.Name, LocalPlayer.UserId)
    loadingGui:SetProgress(0.02)
    loadingGui:SetStatus("Đang check game load...")
    
    -- Wait for game to load
    local gameLoaded = waitForFunction(function() return game:IsLoaded() end, 25, 0.1)
    if not gameLoaded then
        loadingGui:SetStatus("Load game quá lâu, thử lại...")
        task.wait(2)
        loadingGui:Close()
        return
    end
    
    loadingGui:SetProgress(0.15)
    loadingGui:SetStatus("Đang check FPS...")
    
    -- FPS check
    local currentFPS = 0
    local fpsOK = measureFPS(10, 1.0, 40, function(fps)
        if fps ~= currentFPS then
            currentFPS = fps
            if fps < 10 then
                loadingGui:SetStatus(string.format("FPS thấp (%d) - đang đợi...", fps))
            else
                loadingGui:SetStatus(string.format("FPS OK (%d) - tiếp tục...", fps))
            end
        end
    end)
    
    if not fpsOK then
        loadingGui:SetStatus(string.format("FPS vẫn thấp (~%d) - bỏ qua check...", currentFPS))
        task.wait(0.8)
    end
    
    loadingGui:SetProgress(0.35)
    loadingGui:SetStatus("Đang check nhân vật...")
    
    -- Wait for character
    if not LocalPlayer.Character then 
        LocalPlayer.CharacterAdded:Wait() 
    end
    
    local character, humanoid, rootPart
    local function checkCharacter()
        character = LocalPlayer.Character
        if not (character and character.Parent) then return false end
        
        humanoid = character:FindFirstChildOfClass("Humanoid")
        rootPart = character:FindFirstChild("HumanoidRootPart")
        
        if not humanoid then return false end
        if not rootPart then return false end
        if humanoid.Health <= 0 then return false end
        return true
    end
    
    local charOK = waitForFunction(checkCharacter, 25, 0.1)
    if not charOK then
        loadingGui:SetStatus("Không lấy được Humanoid/HRP, đợi respawn...")
        local respawnOK = waitForFunction(function()
            if not LocalPlayer.Character then return false end
            return checkCharacter()
        end, 20, 0.1)
        if not respawnOK then
            loadingGui:SetStatus("Lỗi nhân vật, dừng.")
            task.wait(2)
            loadingGui:Close()
            return
        end
    end
    
    loadingGui:SetProgress(0.65)
    loadingGui:SetStatus("Humanoid/HRP OK")
    
    loadingGui:SetStatus("Đang check camera...")
    waitForFunction(function() return workspace.CurrentCamera ~= nil end, 8, 0.1)
    
    loadingGui:SetProgress(0.80)
    loadingGui:SetStatus("Đang check services...")
    waitForFunction(function() return game:GetService("ReplicatedStorage") ~= nil end, 8, 0.1)
    
    loadingGui:SetProgress(0.92)
    loadingGui:SetStatus("Xong!")
    loadingGui:SetProgress(1)
    task.wait(0.6)
    loadingGui:Close()
end

initialize()
