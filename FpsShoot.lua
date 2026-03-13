-- [[ GÜVENLİK KONTROLÜ ]]
if not getgenv then return end

-- [[ AYARLAR - TÜM ÖZELLİKLER + HITBOX BÜYÜTME + GÖSTERGE ]]
local Settings = {
    -- AIMBOT (orijinal - dokunulmadı)
    Aimbot = true,
    AutoShoot = true,
    WallCheck = true,
    
    -- HITBOX BÜYÜTME VE GÖSTERGE
    HitboxExpender = false,
    HitboxSize = 2.0,
    
    -- MOVEMENT
    Mevlana = true,
    SpinSpeed = 100,
    BHop = false,
    InfJump = false,
    NoClip = false,
    SpeedBoost = 1,
    
    -- VISUALS
    ESP = true,
    ESPBox = true,
    ESPName = true,
    ESPHealth = true,
    ESPDistance = true,
    ESPTracer = false,
    Chams = true,
    ChamsTransparency = 0.5,
    RainbowHand = true,
    ThirdPerson = true,
    CameraDistance = 8,
    FullBright = false,
    
    -- EXPLOITS
    TeleportKill = false,
    TPAuraDist = 100,
    ClickTP = true,
    Fly = false,
    FlySpeed = 20,
    NoFallDamage = false,
    GodMode = false,
    InfiniteAmmo = false,
    NoRecoil = false,
    NoSpread = false,
    
    -- MISC
    MasterToggle = false,
    MaxTeleportDist = 1000,
    Watermark = true,
    FPSBoost = false,
    AntiAim = false,
    MenuOpen = true
}

-- [[ DEĞİŞKENLER ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local mouseAngleX, mouseAngleY, fakeSpinAngle = 0, 0, 0
local hue = 0
local flyConnection = nil
local selectedTab = "AIMBOT"
local originalPartSizes = {} -- Orijinal hitbox boyutlarını saklamak için

-- [[ CS TARZI MENÜ ]]
local MenuGUI = Instance.new("ScreenGui")
MenuGUI.Name = "CSGOMenu"
MenuGUI.Parent = game:GetService("CoreGui")
MenuGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
MenuGUI.ResetOnSpawn = false

-- Ana çerçeve
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = MenuGUI
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 700, 0, 500)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = Settings.MenuOpen

-- Başlık çubuğu
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Parent = MainFrame
TitleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
TitleBar.BorderSizePixel = 0
TitleBar.Size = UDim2.new(1, 0, 0, 30)

local TitleText = Instance.new("TextLabel")
TitleText.Parent = TitleBar
TitleText.BackgroundTransparency = 1
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.Size = UDim2.new(0, 400, 1, 0)
TitleText.Font = Enum.Font.GothamBold
TitleText.Text = "CS:GO RAGE V12 | GERÇEK HITBOX BÜYÜTME | Sağ Shift"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 14
TitleText.TextXAlignment = Enum.TextXAlignment.Left

local CloseButton = Instance.new("TextButton")
CloseButton.Parent = TitleBar
CloseButton.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
CloseButton.Position = UDim2.new(1, -25, 0, 5)
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 14
CloseButton.MouseButton1Click:Connect(function()
    Settings.MenuOpen = false
    MainFrame.Visible = false
end)

-- Sol panel (sekmeler)
local TabPanel = Instance.new("ScrollingFrame")
TabPanel.Name = "TabPanel"
TabPanel.Parent = MainFrame
TabPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
TabPanel.BorderSizePixel = 0
TabPanel.Position = UDim2.new(0, 0, 0, 30)
TabPanel.Size = UDim2.new(0, 150, 1, -30)
TabPanel.CanvasSize = UDim2.new(0, 0, 0, 250)
TabPanel.ScrollBarThickness = 5

local TabButtons = {}
local Tabs = {"AIMBOT", "VISUALS", "MOVEMENT", "EXPLOITS", "MISC"}
local TabColors = {
    AIMBOT = Color3.fromRGB(200, 50, 50),
    VISUALS = Color3.fromRGB(50, 150, 200),
    MOVEMENT = Color3.fromRGB(50, 200, 50),
    EXPLOITS = Color3.fromRGB(200, 150, 50),
    MISC = Color3.fromRGB(150, 100, 200)
}

for i, tabName in ipairs(Tabs) do
    local TabButton = Instance.new("TextButton")
    TabButton.Parent = TabPanel
    TabButton.BackgroundColor3 = (tabName == selectedTab) and TabColors[tabName] or Color3.fromRGB(35, 35, 40)
    TabButton.BorderSizePixel = 0
    TabButton.Position = UDim2.new(0, 5, 0, 5 + (i-1) * 35)
    TabButton.Size = UDim2.new(1, -10, 0, 30)
    TabButton.Font = Enum.Font.GothamBold
    TabButton.Text = tabName
    TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabButton.TextSize = 13
    
    TabButton.MouseButton1Click:Connect(function()
        selectedTab = tabName
        for _, btn in pairs(TabButtons) do
            btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        end
        TabButton.BackgroundColor3 = TabColors[tabName]
        UpdateContent()
    end)
    
    table.insert(TabButtons, TabButton)
end

-- İçerik paneli
local ContentPanel = Instance.new("ScrollingFrame")
ContentPanel.Name = "ContentPanel"
ContentPanel.Parent = MainFrame
ContentPanel.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
ContentPanel.BorderSizePixel = 0
ContentPanel.Position = UDim2.new(0, 150, 0, 30)
ContentPanel.Size = UDim2.new(1, -150, 1, -30)
ContentPanel.CanvasSize = UDim2.new(0, 0, 0, 1000)
ContentPanel.ScrollBarThickness = 8
ContentPanel.ScrollingEnabled = true

local ContentList = Instance.new("UIListLayout")
ContentList.Parent = ContentPanel
ContentList.Padding = UDim.new(0, 5)
ContentList.SortOrder = Enum.SortOrder.LayoutOrder

local ContentPadding = Instance.new("UIPadding")
ContentPadding.Parent = ContentPanel
ContentPadding.PaddingLeft = UDim.new(0, 10)
ContentPadding.PaddingRight = UDim.new(0, 10)
ContentPadding.PaddingTop = UDim.new(0, 10)
ContentPadding.PaddingBottom = UDim.new(0, 10)

-- [[ YARDIMCI FONKSİYONLAR ]]
function CreateSection(title)
    local SectionLabel = Instance.new("TextLabel")
    SectionLabel.Parent = ContentPanel
    SectionLabel.BackgroundTransparency = 1
    SectionLabel.Size = UDim2.new(1, 0, 0, 25)
    SectionLabel.Font = Enum.Font.GothamBold
    SectionLabel.Text = title
    SectionLabel.TextColor3 = Color3.fromRGB(150, 150, 255)
    SectionLabel.TextSize = 14
    SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
end

function CreateToggle(name, setting, defaultValue)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Parent = ContentPanel
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Size = UDim2.new(1, 0, 0, 30)
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Parent = ToggleFrame
    ToggleButton.BackgroundColor3 = Settings[setting] and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(70, 70, 75)
    ToggleButton.Position = UDim2.new(1, -25, 0, 5)
    ToggleButton.Size = UDim2.new(0, 20, 0, 20)
    ToggleButton.Font = Enum.Font.Gotham
    ToggleButton.Text = ""
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Parent = ToggleFrame
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
    ToggleLabel.Size = UDim2.new(1, -40, 1, 0)
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.Text = name
    ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleLabel.TextSize = 13
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    ToggleButton.MouseButton1Click:Connect(function()
        Settings[setting] = not Settings[setting]
        ToggleButton.BackgroundColor3 = Settings[setting] and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(70, 70, 75)
    end)
end

function CreateSlider(name, setting, min, max, defaultValue, increment)
    increment = increment or 1
    
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Parent = ContentPanel
    SliderFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    SliderFrame.BorderSizePixel = 0
    SliderFrame.Size = UDim2.new(1, 0, 0, 45)
    
    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Parent = SliderFrame
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Position = UDim2.new(0, 10, 0, 5)
    SliderLabel.Size = UDim2.new(1, -20, 0, 15)
    SliderLabel.Font = Enum.Font.Gotham
    SliderLabel.Text = name .. ": " .. defaultValue
    SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    SliderLabel.TextSize = 13
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local SliderBar = Instance.new("Frame")
    SliderBar.Parent = SliderFrame
    SliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    SliderBar.BorderSizePixel = 0
    SliderBar.Position = UDim2.new(0, 10, 0, 25)
    SliderBar.Size = UDim2.new(1, -20, 0, 10)
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Parent = SliderBar
    SliderFill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    SliderFill.BorderSizePixel = 0
    SliderFill.Size = UDim2.new((defaultValue - min) / (max - min), 0, 1, 0)
    
    local dragging = false
    
    local function updateSlider(input)
        local pos = input.Position.X - SliderBar.AbsolutePosition.X
        local percent = math.clamp(pos / SliderBar.AbsoluteSize.X, 0, 1)
        local value = min + (max - min) * percent
        value = math.floor(value / increment + 0.5) * increment
        value = math.clamp(value, min, max)
        
        Settings[setting] = value
        SliderFill.Size = UDim2.new(percent, 0, 1, 0)
        SliderLabel.Text = name .. ": " .. string.format("%.1f", value)
    end
    
    SliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateSlider(input)
        end
    end)
    
    SliderBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
end

function CreateDropdown(name, setting, options, default)
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Parent = ContentPanel
    DropdownFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    DropdownFrame.BorderSizePixel = 0
    DropdownFrame.Size = UDim2.new(1, 0, 0, 60)
    
    local DropdownLabel = Instance.new("TextLabel")
    DropdownLabel.Parent = DropdownFrame
    DropdownLabel.BackgroundTransparency = 1
    DropdownLabel.Position = UDim2.new(0, 10, 0, 5)
    DropdownLabel.Size = UDim2.new(1, -20, 0, 15)
    DropdownLabel.Font = Enum.Font.Gotham
    DropdownLabel.Text = name
    DropdownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownLabel.TextSize = 13
    DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local DropdownButton = Instance.new("TextButton")
    DropdownButton.Parent = DropdownFrame
    DropdownButton.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    DropdownButton.BorderSizePixel = 0
    DropdownButton.Position = UDim2.new(0, 10, 0, 25)
    DropdownButton.Size = UDim2.new(1, -20, 0, 25)
    DropdownButton.Font = Enum.Font.Gotham
    DropdownButton.Text = default
    DropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownButton.TextSize = 13
    
    local dropdownOpen = false
    local dropdownList = nil
    
    DropdownButton.MouseButton1Click:Connect(function()
        dropdownOpen = not dropdownOpen
        
        if dropdownList then
            dropdownList:Destroy()
            dropdownList = nil
        end
        
        if dropdownOpen then
            dropdownList = Instance.new("Frame")
            dropdownList.Parent = DropdownFrame
            dropdownList.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
            dropdownList.BorderSizePixel = 0
            dropdownList.Position = UDim2.new(0, 10, 0, 52)
            dropdownList.Size = UDim2.new(1, -20, 0, #options * 25)
            dropdownList.ZIndex = 10
            
            for i, option in ipairs(options) do
                local OptionButton = Instance.new("TextButton")
                OptionButton.Parent = dropdownList
                OptionButton.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
                OptionButton.BorderSizePixel = 0
                OptionButton.Position = UDim2.new(0, 0, 0, (i-1) * 25)
                OptionButton.Size = UDim2.new(1, 0, 0, 25)
                OptionButton.Font = Enum.Font.Gotham
                OptionButton.Text = option
                OptionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                OptionButton.TextSize = 13
                OptionButton.ZIndex = 11
                
                OptionButton.MouseButton1Click:Connect(function()
                    Settings[setting] = option
                    DropdownButton.Text = option
                    dropdownOpen = false
                    dropdownList:Destroy()
                    dropdownList = nil
                end)
            end
        end
    end)
end

-- [[ İÇERİK GÜNCELLEME - TÜM ÖZELLİKLER ]]
function UpdateContent()
    -- Mevcut içeriği temizle
    for _, child in pairs(ContentPanel:GetChildren()) do
        if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
            child:Destroy()
        end
    end
    
    if selectedTab == "AIMBOT" then
        CreateSection("Aimbot Settings (Orijinal)")
        CreateToggle("Aimbot", "Aimbot", true)
        CreateToggle("Auto Shoot", "AutoShoot", true)
        CreateToggle("Wall Check", "WallCheck", true)
        CreateSlider("TP Distance", "MaxTeleportDist", 100, 2000, 1000, 50)
        
        CreateSection("GERÇEK HITBOX BÜYÜTME")
        CreateToggle("Hitbox Expander (Büyütme)", "HitboxExpender", false)
        CreateSlider("Hitbox Boyut (1x-20x)", "HitboxSize", 1.0, 20.0, 2.0, 0.5)
        
    elseif selectedTab == "VISUALS" then
        CreateSection("ESP Settings (Tümü)")
        CreateToggle("ESP", "ESP", true)
        CreateToggle("Box ESP", "ESPBox", true)
        CreateToggle("Name ESP", "ESPName", true)
        CreateToggle("Health ESP", "ESPHealth", true)
        CreateToggle("Distance ESP", "ESPDistance", true)
        CreateToggle("Tracer Lines", "ESPTracer", false)
        
        CreateSection("Chams & Effects")
        CreateToggle("Chams", "Chams", true)
        CreateSlider("Chams Transparency", "ChamsTransparency", 0, 1, 0.5, 0.1)
        CreateToggle("Rainbow Hand", "RainbowHand", true)
        CreateToggle("Full Bright", "FullBright", false)
        
        CreateSection("Camera")
        CreateToggle("3rd Person", "ThirdPerson", true)
        CreateSlider("Camera Distance", "CameraDistance", 2, 20, 8, 1)
        
    elseif selectedTab == "MOVEMENT" then
        CreateSection("Movement Hacks (Tümü)")
        CreateToggle("Master Toggle (F2)", "MasterToggle", false)
        CreateToggle("Mevlana (Spinbot)", "Mevlana", true)
        CreateSlider("Spin Speed", "SpinSpeed", 10, 500, 100, 10)
        CreateToggle("Bunny Hop", "BHop", false)
        CreateToggle("Infinite Jump", "InfJump", false)
        CreateToggle("No Clip", "NoClip", false)
        CreateSlider("Speed Boost", "SpeedBoost", 1, 5, 1, 0.5)
        
    elseif selectedTab == "EXPLOITS" then
        CreateSection("Exploits (Tümü)")
        CreateToggle("TP Aura (F6)", "TeleportKill", false)
        CreateSlider("TP Aura Distance", "TPAuraDist", 5, 800, 100, 5)
        CreateToggle("Click TP", "ClickTP", true)
        CreateToggle("Fly", "Fly", false)
        CreateSlider("Fly Speed", "FlySpeed", 5, 50, 20, 5)
        CreateToggle("No Fall Damage", "NoFallDamage", false)
        CreateToggle("God Mode", "GodMode", false)
        CreateToggle("Infinite Ammo", "InfiniteAmmo", false)
        CreateToggle("No Recoil", "NoRecoil", false)
        CreateToggle("No Spread", "NoSpread", false)
        
    elseif selectedTab == "MISC" then
        CreateSection("Misc Settings")
        CreateToggle("Watermark", "Watermark", true)
        CreateToggle("FPS Boost", "FPSBoost", false)
        CreateToggle("Anti Aim", "AntiAim", false)
        
        CreateSection("Information")
        local InfoLabel = Instance.new("TextLabel")
        InfoLabel.Parent = ContentPanel
        InfoLabel.BackgroundTransparency = 1
        InfoLabel.Size = UDim2.new(1, 0, 0, 30)
        InfoLabel.Font = Enum.Font.Gotham
        InfoLabel.Text = "CS:GO RAGE V12 | GERÇEK HITBOX BÜYÜTME"
        InfoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        InfoLabel.TextSize = 14
        
        local InfoLabel2 = Instance.new("TextLabel")
        InfoLabel2.Parent = ContentPanel
        InfoLabel2.BackgroundTransparency = 1
        InfoLabel2.Size = UDim2.new(1, 0, 0, 30)
        InfoLabel2.Font = Enum.Font.Gotham
        InfoLabel2.Text = "Powered by İbosaid"
        InfoLabel2.TextColor3 = Color3.fromRGB(200, 200, 200)
        InfoLabel2.TextSize = 14
        
        CreateSection("Controls")
        local ControlsLabel = Instance.new("TextLabel")
        ControlsLabel.Parent = ContentPanel
        ControlsLabel.BackgroundTransparency = 1
        ControlsLabel.Size = UDim2.new(1, 0, 0, 20)
        ControlsLabel.Font = Enum.Font.Gotham
        ControlsLabel.Text = "Sağ Shift: Menü aç/kapa"
        ControlsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        ControlsLabel.TextSize = 13
        ControlsLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local ControlsLabel2 = Instance.new("TextLabel")
        ControlsLabel2.Parent = ContentPanel
        ControlsLabel2.BackgroundTransparency = 1
        ControlsLabel2.Size = UDim2.new(1, 0, 0, 20)
        ControlsLabel2.Font = Enum.Font.Gotham
        ControlsLabel2.Text = "F2: Master Toggle"
        ControlsLabel2.TextColor3 = Color3.fromRGB(255, 255, 255)
        ControlsLabel2.TextSize = 13
        ControlsLabel2.TextXAlignment = Enum.TextXAlignment.Left
        
        local ControlsLabel3 = Instance.new("TextLabel")
        ControlsLabel3.Parent = ContentPanel
        ControlsLabel3.BackgroundTransparency = 1
        ControlsLabel3.Size = UDim2.new(1, 0, 0, 20)
        ControlsLabel3.Font = Enum.Font.Gotham
        ControlsLabel3.Text = "F6: TP Aura"
        ControlsLabel3.TextColor3 = Color3.fromRGB(255, 255, 255)
        ControlsLabel3.TextSize = 13
        ControlsLabel3.TextXAlignment = Enum.TextXAlignment.Left
        
        local ControlsLabel4 = Instance.new("TextLabel")
        ControlsLabel4.Parent = ContentPanel
        ControlsLabel4.BackgroundTransparency = 1
        ControlsLabel4.Size = UDim2.new(1, 0, 0, 20)
        ControlsLabel4.Font = Enum.Font.Gotham
        ControlsLabel4.Text = "Sağ Tık: Click TP"
        ControlsLabel4.TextColor3 = Color3.fromRGB(255, 255, 255)
        ControlsLabel4.TextSize = 13
        ControlsLabel4.TextXAlignment = Enum.TextXAlignment.Left
        
        CreateSection("Hitbox Info")
        local HitboxInfo = Instance.new("TextLabel")
        HitboxInfo.Parent = ContentPanel
        HitboxInfo.BackgroundTransparency = 1
        HitboxInfo.Size = UDim2.new(1, 0, 0, 60)
        HitboxInfo.Font = Enum.Font.Gotham
        HitboxInfo.Text = "GERÇEK HITBOX BÜYÜTME: Düşmanların vurulma alanlarını\nfiziksel olarak büyütür. Kırmızı kutu büyüyen alanı gösterir.\nBoyut arttıkça vurmak kolaylaşır! (1x-20x)"
        HitboxInfo.TextColor3 = Color3.fromRGB(255, 200, 100)
        HitboxInfo.TextSize = 12
        HitboxInfo.TextXAlignment = Enum.TextXAlignment.Left
        HitboxInfo.TextWrapped = true
    end
    
    -- CanvasSize'i güncelle
    task.wait()
    ContentPanel.CanvasSize = UDim2.new(0, 0, 0, ContentList.AbsoluteContentSize.Y + 20)
end

-- [[ GÖRÜNÜRLÜK FONKSİYONU (orijinal) ]]
local function IsVisible(TargetPart)
    if not Settings.WallCheck then return true end
    local Character = LocalPlayer.Character
    if not Character then return false end
    local Origin = Camera.CFrame.Position
    local Destination = TargetPart.Position
    local Direction = Destination - Origin
    local Params = RaycastParams.new()
    Params.FilterType = Enum.RaycastFilterType.Exclude
    Params.FilterDescendantsInstances = {Character, game:GetService("CoreGui")}
    local Result = workspace:Raycast(Origin, Direction, Params)
    return not Result or Result.Instance:IsDescendantOf(TargetPart.Parent)
end

-- [[ CLICK TP (orijinal) ]]
local function DoClickTP()
    local MouseLocation = UserInputService:GetMouseLocation()
    local Ray = Camera:ViewportPointToRay(MouseLocation.X, MouseLocation.Y)
    local RaycastResult = workspace:Raycast(Ray.Origin, Ray.Direction * 1000)
    if RaycastResult and LocalPlayer.Character then
        local TargetPos = RaycastResult.Position + Vector3.new(0, 3, 0)
        LocalPlayer.Character:SetPrimaryPartCFrame(CFrame.new(TargetPos))
    end
end

-- [[ CHAMS (orijinal) ]]
local function ApplyHacks(Player)
    local function CreateHighlight()
        if Player.Character then
            local H = Player.Character:FindFirstChild("RageHighlight") or Instance.new("Highlight")
            H.Name = "RageHighlight"
            H.Parent = Player.Character
            H.FillColor = Color3.fromRGB(0, 170, 255)
            H.OutlineColor = Color3.fromRGB(255, 255, 255)
            
            task.spawn(function()
                while H and H.Parent do
                    H.Enabled = Settings.ESP
                    H.FillAlpha = Settings.ChamsTransparency
                    task.wait(0.1)
                end
            end)
        end
    end
    Player.CharacterAdded:Connect(function() task.wait(0.5); CreateHighlight() end)
    if Player.Character then CreateHighlight() end
end

for _, v in pairs(Players:GetPlayers()) do if v ~= LocalPlayer then ApplyHacks(v) end end
Players.PlayerAdded:Connect(function(v) if v ~= LocalPlayer then ApplyHacks(v) end end)

-- [[ RAINBOW HAND ]]
local function ApplyRainbowHand()
    local Character = LocalPlayer.Character
    if not Character then return end
    
    local leftHand = Character:FindFirstChild("LeftHand") or Character:FindFirstChild("Left Arm")
    local rightHand = Character:FindFirstChild("RightHand") or Character:FindFirstChild("Right Arm")
    
    local function applyRainbowToParts(part)
        if part and part:IsA("BasePart") then
            hue = (hue + 0.01) % 1
            local rainbowColor = Color3.fromHSV(hue, 1, 1)
            part.BrickColor = BrickColor.new(rainbowColor)
            part.Material = Enum.Material.Neon
        end
    end
    
    applyRainbowToParts(leftHand)
    applyRainbowToParts(rightHand)
end

-- [[ ESP ÇİZİMİ ]]
local ESPObjects = {}

local function createESP(player)
    if player == LocalPlayer then return end
    
    local esp = {}
    esp.box = Drawing.new("Square")
    esp.box.Visible = false
    esp.box.Thickness = 2
    esp.box.Color = Color3.new(1, 0, 0)
    esp.box.Filled = false
    
    esp.name = Drawing.new("Text")
    esp.name.Visible = false
    esp.name.Size = 16
    esp.name.Center = true
    esp.name.Outline = true
    esp.name.Color = Color3.new(1, 1, 1)
    
    esp.health = Drawing.new("Text")
    esp.health.Visible = false
    esp.health.Size = 14
    esp.health.Color = Color3.new(0, 1, 0)
    
    esp.distance = Drawing.new("Text")
    esp.distance.Visible = false
    esp.distance.Size = 12
    esp.distance.Color = Color3.new(1, 1, 0)
    
    esp.tracer = Drawing.new("Line")
    esp.tracer.Visible = false
    esp.tracer.Thickness = 1
    esp.tracer.Color = Color3.new(1, 1, 1)
    
    ESPObjects[player] = esp
end

for _, player in pairs(Players:GetPlayers()) do
    createESP(player)
end

Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(function(player)
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do
            obj:Remove()
        end
        ESPObjects[player] = nil
    end
end)

-- [[ GERÇEK HITBOX BÜYÜTME FONKSİYONU ]]
local function ApplyHitboxExpender()
    if not Settings.HitboxExpender then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                -- Tüm önemli parçaları büyüt
                local parts = {
                    player.Character:FindFirstChild("Head"),
                    player.Character:FindFirstChild("Torso"),
                    player.Character:FindFirstChild("HumanoidRootPart"),
                    player.Character:FindFirstChild("Left Arm"),
                    player.Character:FindFirstChild("Right Arm"),
                    player.Character:FindFirstChild("Left Leg"),
                    player.Character:FindFirstChild("Right Leg")
                }
                
                for _, part in ipairs(parts) do
                    if part and part:IsA("BasePart") then
                        -- Orijinal boyutu kaydet (ilk seferde)
                        if not originalPartSizes[part] then
                            originalPartSizes[part] = part.Size
                        end
                        
                        -- Boyutu büyüt (her eksende aynı oranda)
                        local newSize = originalPartSizes[part] * Settings.HitboxSize
                        part.Size = newSize
                    end
                end
            end
        end
    end
end

-- [[ HITBOX BOYUTLARINI SIFIRLA ]]
local function ResetHitboxes()
    for part, originalSize in pairs(originalPartSizes) do
        if part and part.Parent then
            part.Size = originalSize
        end
    end
    -- Tabloyu temizle (ama aynı referansları koru)
    for part, _ in pairs(originalPartSizes) do
        originalPartSizes[part] = nil
    end
end

-- [[ HITBOX GÖSTERGE FONKSİYONU (Transparan Kutu) ]]
local HitboxIndicators = {}

local function CreateHitboxIndicator(player)
    if player == LocalPlayer then return end
    
    -- Her oyuncu için bir kutu oluştur
    local box = Instance.new("BoxHandleAdornment")
    box.Name = "HitboxIndicator"
    box.Adornee = nil
    box.ZIndex = 10
    box.AlwaysOnTop = true
    box.Transparency = 0.7
    box.Color3 = Color3.fromRGB(255, 50, 50)
    box.Size = Vector3.new(4, 6, 4)
    box.Visible = false
    
    -- Karakter oluştuğunda parent'ı ayarla
    local function onCharacterAdded(character)
        box.Parent = character
    end
    
    if player.Character then
        onCharacterAdded(player.Character)
    end
    player.CharacterAdded:Connect(onCharacterAdded)
    
    HitboxIndicators[player] = box
end

local function UpdateHitboxIndicators()
    if not Settings.HitboxExpender then
        for _, box in pairs(HitboxIndicators) do
            if box then box.Visible = false end
        end
        return
    end
    
    for player, box in pairs(HitboxIndicators) do
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and box then
            local root = player.Character.HumanoidRootPart
            box.Adornee = root
            -- Gösterge kutusu da aynı oranda büyüsün
            local baseSize = Vector3.new(4, 5, 4) -- Normal karakter için yaklaşık
            local multiplier = Settings.HitboxSize
            box.Size = baseSize * multiplier
            -- Rengi boyuta göre ayarla (büyüdükçe kırmızılaşsın)
            local intensity = math.min(1, multiplier / 10)
            box.Color3 = Color3.fromRGB(255, 100 + (155 * intensity), 100)
            box.Visible = true
        else
            if box then box.Visible = false end
        end
    end
end

-- Yeni oyuncular için indicator oluştur
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        CreateHitboxIndicator(player)
    end
end)

-- Mevcut oyuncular için indicator oluştur
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateHitboxIndicator(player)
    end
end

-- [[ FLY FONKSİYONU ]]
local function startFly()
    if flyConnection then flyConnection:Disconnect() end
    flyConnection = RunService.RenderStepped:Connect(function()
        if not Settings.Fly or not LocalPlayer.Character then return end
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if root and hum then
            hum.PlatformStand = true
            local moveDir = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDir = moveDir + Camera.CFrame.LookVector * Settings.FlySpeed
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDir = moveDir - Camera.CFrame.LookVector * Settings.FlySpeed
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDir = moveDir - Camera.CFrame.RightVector * Settings.FlySpeed
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDir = moveDir + Camera.CFrame.RightVector * Settings.FlySpeed
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveDir = moveDir + Vector3.new(0, Settings.FlySpeed, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                moveDir = moveDir - Vector3.new(0, Settings.FlySpeed, 0)
            end
            root.Velocity = moveDir
        end
    end)
end

local function stopFly()
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then
            hum.PlatformStand = false
        end
    end
end

-- [[ BUNNY HOP ]]
local function bhop()
    if not Settings.BHop then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if hum and hum.FloorMaterial ~= Enum.Material.Air then
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            hum.Jump = true
        end
    end
end

-- [[ INFINITE JUMP ]]
UserInputService.JumpRequest:Connect(function()
    if Settings.InfJump and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- [[ TUŞ KONTROLLERİ ]]
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp then
        -- Sağ Shift ile menü aç/kapa
        if input.KeyCode == Enum.KeyCode.RightShift then
            Settings.MenuOpen = not Settings.MenuOpen
            MainFrame.Visible = Settings.MenuOpen
        elseif input.KeyCode == Enum.KeyCode.F2 then
            Settings.MasterToggle = not Settings.MasterToggle
        elseif input.KeyCode == Enum.KeyCode.F6 then
            Settings.TeleportKill = not Settings.TeleportKill
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 and Settings.ClickTP and Settings.MasterToggle then
            DoClickTP()
        end
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if Settings.MasterToggle and input.UserInputType == Enum.UserInputType.MouseMovement then
        mouseAngleX = mouseAngleX - input.Delta.X * 0.4
        mouseAngleY = math.clamp(mouseAngleY - input.Delta.Y * 0.4, -75, 75)
    end
end)

-- [[ ANA DÖNGÜ - TÜM ÖZELLİKLER AKTİF ]]
RunService.RenderStepped:Connect(function()
    local Char = LocalPlayer.Character
    if not Char or not Char:FindFirstChild("HumanoidRootPart") then return end
    local Root, Hum = Char.HumanoidRootPart, Char.Humanoid

    -- Fly kontrolü
    if Settings.Fly and not flyConnection then
        startFly()
    elseif not Settings.Fly and flyConnection then
        stopFly()
    end

    -- FPS Boost
    if Settings.FPSBoost then
        settings().Rendering.QualityLevel = 1
    else
        settings().Rendering.QualityLevel = 10
    end

    -- Full Bright
    if Settings.FullBright then
        game:GetService("Lighting").Brightness = 2
        game:GetService("Lighting").GlobalShadows = false
    else
        game:GetService("Lighting").Brightness = 1
        game:GetService("Lighting").GlobalShadows = true
    end

    -- GERÇEK HITBOX BÜYÜTME (her kare uygula)
    if Settings.HitboxExpender then
        ApplyHitboxExpender()
    else
        ResetHitboxes()
    end

    -- Hitbox göstergelerini güncelle
    UpdateHitboxIndicators()

    -- ESP Güncelleme
    for player, esp in pairs(ESPObjects) do
        if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local head = player.Character:FindFirstChild("Head")
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if head and rootPart then
                local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                local rootPos, _ = Camera:WorldToViewportPoint(rootPart.Position)
                
                if onScreen then
                    local distance = (Camera.CFrame.Position - rootPart.Position).Magnitude
                    local scale = 600 / distance
                    local boxHeight = math.clamp(scale * 5, 20, 100)
                    local boxWidth = boxHeight * 0.6
                    
                    if Settings.ESP and Settings.ESPBox then
                        esp.box.Visible = true
                        esp.box.Position = Vector2.new(rootPos.X - boxWidth/2, rootPos.Y - boxHeight/2)
                        esp.box.Size = Vector2.new(boxWidth, boxHeight)
                        esp.box.Color = player.TeamColor.Color or Color3.new(1, 0, 0)
                    else
                        esp.box.Visible = false
                    end
                    
                    if Settings.ESP and Settings.ESPName then
                        esp.name.Visible = true
                        esp.name.Position = Vector2.new(rootPos.X, rootPos.Y - boxHeight/2 - 20)
                        esp.name.Text = player.Name
                    else
                        esp.name.Visible = false
                    end
                    
                    if Settings.ESP and Settings.ESPHealth then
                        esp.health.Visible = true
                        esp.health.Position = Vector2.new(rootPos.X + boxWidth/2 + 10, rootPos.Y - boxHeight/2)
                        local health = player.Character.Humanoid.Health
                        local maxHealth = player.Character.Humanoid.MaxHealth
                        esp.health.Text = string.format("%.0f/%.0f", health, maxHealth)
                        esp.health.Color = Color3.new(1 - health/maxHealth, health/maxHealth, 0)
                    else
                        esp.health.Visible = false
                    end
                    
                    if Settings.ESP and Settings.ESPDistance then
                        esp.distance.Visible = true
                        esp.distance.Position = Vector2.new(rootPos.X, rootPos.Y + boxHeight/2 + 5)
                        esp.distance.Text = string.format("%.0fm", distance)
                    else
                        esp.distance.Visible = false
                    end
                    
                    if Settings.ESP and Settings.ESPTracer then
                        esp.tracer.Visible = true
                        esp.tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                        esp.tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                    else
                        esp.tracer.Visible = false
                    end
                else
                    esp.box.Visible = false
                    esp.name.Visible = false
                    esp.health.Visible = false
                    esp.distance.Visible = false
                    esp.tracer.Visible = false
                end
            end
        else
            esp.box.Visible = false
            esp.name.Visible = false
            esp.health.Visible = false
            esp.distance.Visible = false
            esp.tracer.Visible = false
        end
    end

    -- No Fall Damage
    if Settings.NoFallDamage and Hum then
        Hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        Hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
    end

    -- God Mode
    if Settings.GodMode and Hum then
        Hum.MaxHealth = math.huge
        Hum.Health = math.huge
    end

    -- Speed Boost
    if Settings.SpeedBoost > 1 and Hum then
        Hum.WalkSpeed = 16 * Settings.SpeedBoost
    else
        Hum.WalkSpeed = 16
    end

    -- Infinite Ammo
    if Settings.InfiniteAmmo then
        for _, tool in pairs(Char:GetChildren()) do
            if tool:IsA("Tool") then
                local ammo = tool:FindFirstChild("Ammo")
                if ammo then
                    ammo.Value = 999
                end
            end
        end
    end

    -- No Clip
    if Settings.NoClip and Hum then
        for _, part in pairs(Char:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    else
        for _, part in pairs(Char:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = true
            end
        end
    end

    -- Ana hile döngüsü (orijinal aimbot ile)
    if Settings.MasterToggle then
        -- 3. Şahıs kamera
        if Settings.ThirdPerson then
            Camera.CameraType = Enum.CameraType.Scriptable
            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
            
            if Settings.Mevlana then
                fakeSpinAngle = (fakeSpinAngle + Settings.SpinSpeed) % 360
                Hum.AutoRotate = false
                Root.CFrame = CFrame.new(Root.Position) * CFrame.Angles(0, math.rad(fakeSpinAngle), 0)
            else
                Hum.AutoRotate = true
            end

            -- Kamera hesaplama
            local camRot = CFrame.Angles(0, math.rad(mouseAngleX), 0) * CFrame.Angles(math.rad(mouseAngleY), 0, 0)
            local offset = Vector3.new(0, 2.5, Settings.CameraDistance)
            Camera.CFrame = CFrame.new(Root.Position) * camRot * CFrame.new(offset)

            -- ORİJİNAL AİMBOT (dokunulmadı)
            local Target = nil
            local MinDist = Settings.MaxTeleportDist

            for _, v in pairs(Players:GetPlayers()) do
                if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") and v.Character.Humanoid.Health > 0 then
                    local dist = (Root.Position - v.Character.Head.Position).Magnitude
                    
                    -- TP Aura
                    if Settings.TeleportKill and dist <= Settings.TPAuraDist then
                        Root.CFrame = v.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                    end

                    -- Aimbot Target (orijinal)
                    if IsVisible(v.Character.Head) and dist < MinDist then
                        MinDist = dist
                        Target = v
                    end
                end
            end

            if Target and Settings.Aimbot then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, Target.Character.Head.Position)
                if Settings.AutoShoot then 
                    mouse1press(); task.wait(0.01); mouse1release()
                end
            end
        else
            -- 1. Şahıs kamera
            Camera.CameraType = Enum.CameraType.Custom
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            Hum.AutoRotate = true
        end
    else
        Camera.CameraType = Enum.CameraType.Custom
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        Hum.AutoRotate = true
    end
    
    -- Rainbow Hand
    if Settings.RainbowHand and LocalPlayer.Character then
        ApplyRainbowHand()
    end
    
    -- Bunny Hop
    bhop()
end)

-- Menüyü başlat
UpdateContent()
