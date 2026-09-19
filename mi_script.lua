-- ============================================
-- FATASSES HUB - v40 (ANIMACIONES ULTRA COOL)
-- ============================================
print("✨ Iniciando Fatasses Hub ULTRA...")

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local PathfindingService = game:GetService("PathfindingService")
local SoundService = game:GetService("SoundService")
local LocalPlayer = Players.LocalPlayer

local NOMBRE_GUI = "TaskGuiMap1"
local NOMBRE_GUI2 = "TaskGuiMap2"
local RADIO = 0.42
local ANGULO_ABAJO = math.pi / 2
local META = 4

local C = {
    bg_dark      = Color3.fromRGB(45, 25, 40),
    bg_panel     = Color3.fromRGB(60, 35, 55),
    bg_card      = Color3.fromRGB(85, 50, 75),
    bg_card_hl   = Color3.fromRGB(115, 70, 105),
    accent       = Color3.fromRGB(255, 175, 215),
    accent2      = Color3.fromRGB(255, 130, 190),
    accent3      = Color3.fromRGB(255, 210, 235),
    accent4      = Color3.fromRGB(200, 130, 220),
    accent5      = Color3.fromRGB(255, 90, 180),
    text         = Color3.fromRGB(255, 240, 250),
    text_dim     = Color3.fromRGB(200, 170, 195),
    text_sub     = Color3.fromRGB(140, 110, 135),
    success      = Color3.fromRGB(255, 140, 200),
    success_dark = Color3.fromRGB(100, 40, 80),
    danger       = Color3.fromRGB(255, 120, 150),
    warn         = Color3.fromRGB(255, 190, 140),
    border       = Color3.fromRGB(110, 70, 105),
    border_hl    = Color3.fromRGB(255, 160, 210),
}

local activo, autoGen, antiBroken, espActivo, espPlayersActivo = false, false, false, false, false
local autoPlayIA = false
local pestanaActual = "Esp"
local TODAS_PESTANAS = {"Esp", "Scientist", "Class A", "Class S", "Experiment", "Extra Stuff"}
local COMING_SOON = {["Class A"]=true, ["Experiment"]=true}

pcall(function()
    for _, n in ipairs({"AutoPatientGui","AutoPatientGui2","InfStaminaGui","FatassesHub"}) do
        local v = CoreGui:FindFirstChild(n); if v then v:Destroy() end
        local v2 = LocalPlayer.PlayerGui:FindFirstChild(n); if v2 then v2:Destroy() end
    end
end)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FatassesHub"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 999
screenGui.Parent = CoreGui

-- SONIDOS
local SONIDOS = {
    hover       = "rbxassetid://10066931761",
    click       = "rbxassetid://876939830",
    toggle_on   = "rbxassetid://9119717523",
    toggle_off  = "rbxassetid://103866342467024",
    tab_switch  = "rbxassetid://14133663945",
    locked      = "rbxassetid://2323663829",
    close       = "rbxassetid://166084059",
    toggle_gui  = "rbxassetid://1952587204",
}

local VOLUMENES = {
    hover       = 0.6,
    click       = 0.6,
    locked      = 1.0,
    toggle_on   = 3.0,
    toggle_off  = 3.0,
    tab_switch  = 2.5,
    close       = 3.0,
    toggle_gui  = 2.8,
}

local function reproducirSonido(nombre, volumenCustom, pitch)
    local id = SONIDOS[nombre]
    if not id then return end
    local vol = volumenCustom or VOLUMENES[nombre] or 0.5
    local sound = Instance.new("Sound")
    sound.SoundId = id
    sound.Volume = vol
    sound.PlaybackSpeed = pitch or 1
    sound.Parent = SoundService
    sound:Play()
    sound.Ended:Connect(function() sound:Destroy() end)
    task.delay(3, function() if sound and sound.Parent then sound:Destroy() end end)
end

-- ============================================
-- FRAME PRINCIPAL
-- ============================================
local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.new(0, 0, 0, 0)
frame.Position = UDim2.new(0.5, -250, 0.5, -210)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = C.bg_panel
frame.BackgroundTransparency = 0.08
frame.BorderSizePixel = 0
frame.Active = true
frame.ClipsDescendants = true
frame.Parent = screenGui

local frameCorner = Instance.new("UICorner"); frameCorner.CornerRadius = UDim.new(0, 22); frameCorner.Parent = frame

local frameGrad = Instance.new("UIGradient")
frameGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, C.bg_panel),
    ColorSequenceKeypoint.new(0.5, C.bg_dark),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(75, 40, 65)),
})
frameGrad.Rotation = 135
frameGrad.Parent = frame

-- Rotación animada del gradiente
task.spawn(function()
    while frame.Parent do
        TweenService:Create(frameGrad, TweenInfo.new(8, Enum.EasingStyle.Linear), { Rotation = 135 + 360 }):Play()
        task.wait(8)
        frameGrad.Rotation = 135
    end
end)

local strokeGlow = Instance.new("UIStroke")
strokeGlow.Color = C.accent
strokeGlow.Thickness = 5
strokeGlow.Transparency = 0.7
strokeGlow.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = C.accent2
stroke.Color = C.accent2
stroke.Thickness = 1.5
stroke.Transparency = 0.3
stroke.Parent = frame

-- Pulso del borde
task.spawn(function()
    while frame.Parent do
        TweenService:Create(strokeGlow, TweenInfo.new(1.5, Enum.EasingStyle.Sine), { Transparency = 0.4, Thickness = 6 }):Play()
        task.wait(1.5)
        TweenService:Create(strokeGlow, TweenInfo.new(1.5, Enum.EasingStyle.Sine), { Transparency = 0.75, Thickness = 5 }):Play()
        task.wait(1.5)
    end
end)

-- Open animation
frame.Size = UDim2.new(0, 500, 0, 420)
local openTween = TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 500, 0, 420),
})
frame.Size = UDim2.new(0, 0, 0, 0)
openTween:Play()

-- Partículas flotantes (Sparkles rosas)
task.spawn(function()
    while frame.Parent do
        for _ = 1, 6 do
            local sparkle = Instance.new("TextLabel")
            sparkle.Size = UDim2.new(0, 16, 0, 16)
            sparkle.Position = UDim2.new(math.random(), 0, 1, 0)
            sparkle.BackgroundTransparency = 1
            sparkle.Text = ({"✦", "✧", "★", "☆", "❀", "♥"})[math.random(6)]
            sparkle.TextColor3 = C.accent3
            sparkle.TextScaled = true
            sparkle.TextTransparency = 0
            sparkle.Rotation = math.random(0, 360)
            sparkle.ZIndex = 10
            sparkle.Parent = frame

            local tween = TweenService:Create(sparkle, TweenInfo.new(4, Enum.EasingStyle.Linear), {
                Position = UDim2.new(math.random(), 0, -0.1, 0),
                TextTransparency = 1,
                Rotation = math.random(360, 720),
            })
            tween:Play()
            task.delay(4, function() sparkle:Destroy() end)
            task.wait(0.4)
        end
        task.wait(1.5)
    end
end)

-- ============================================
-- TOP BAR con efecto shimmer
-- ============================================
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 52)
topBar.BackgroundColor3 = C.bg_dark
topBar.BackgroundTransparency = 0.4
topBar.BorderSizePixel = 0
topBar.Active = true
topBar.ClipsDescendants = true
topBar.Parent = frame
local tbCorner = Instance.new("UICorner"); tbCorner.CornerRadius = UDim.new(0, 22); tbCorner.Parent = topBar

local tbLine = Instance.new("Frame")
tbLine.Size = UDim2.new(1, 0, 0, 2)
tbLine.Position = UDim2.new(0, 0, 1, -2)
tbLine.BackgroundColor3 = C.accent2
tbLine.BackgroundTransparency = 0.4
tbLine.BorderSizePixel = 0
tbLine.Parent = topBar
local tbLineGrad = Instance.new("UIGradient")
tbLineGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, C.accent3),
    ColorSequenceKeypoint.new(0.5, C.accent),
    ColorSequenceKeypoint.new(1, C.accent4),
})
tbLineGrad.Parent = tbLine

-- Shimmer en el top bar
task.spawn(function()
    while topBar.Parent do
        local shimmer = Instance.new("Frame")
        shimmer.Size = UDim2.new(0, 100, 1, 0)
        shimmer.Position = UDim2.new(-0.3, 0, 0, 0)
        shimmer.BackgroundColor3 = C.accent3
        shimmer.BackgroundTransparency = 0.9
        shimmer.BorderSizePixel = 0
        shimmer.ZIndex = 2
        shimmer.Parent = topBar
        local shimmerGrad = Instance.new("UIGradient")
        shimmerGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, C.accent3),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, C.accent3),
        })
        shimmerGrad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.5, 0.5),
            NumberSequenceKeypoint.new(1, 1),
        })
        shimmerGrad.Parent = shimmer

        TweenService:Create(shimmer, TweenInfo.new(2, Enum.EasingStyle.Linear), {
            Position = UDim2.new(1.3, 0, 0, 0),
        }):Play()
        task.delay(2, function() shimmer:Destroy() end)
        task.wait(4)
    end
end)

-- LED de estado con pulso
local statusDot = Instance.new("Frame")
statusDot.Size = UDim2.new(0, 14, 0, 14)
statusDot.Position = UDim2.new(0, 22, 0.5, -7)
statusDot.BackgroundColor3 = C.success
statusDot.BorderSizePixel = 0
statusDot.Parent = topBar
local dotCorner = Instance.new("UICorner"); dotCorner.CornerRadius = UDim.new(1, 0); dotCorner.Parent = statusDot
local dotGlow = Instance.new("UIStroke"); dotGlow.Color = C.accent2; dotGlow.Thickness = 4; dotGlow.Transparency = 0.3; dotGlow.Parent = statusDot

task.spawn(function()
    while statusDot.Parent do
        TweenService:Create(dotGlow, TweenInfo.new(0.8, Enum.EasingStyle.Sine), { Transparency = 0.9, Thickness = 8 }):Play()
        task.wait(0.8)
        TweenService:Create(dotGlow, TweenInfo.new(0.8, Enum.EasingStyle.Sine), { Transparency = 0.3, Thickness = 4 }):Play()
        task.wait(0.8)
    end
end)

-- Título con gradiente animado + typing effect
local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(1, -120, 1, 0)
titleLbl.Position = UDim2.new(0, 46, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = ""
titleLbl.TextColor3 = C.text
titleLbl.TextScaled = true
titleLbl.Font = Enum.Font.GothamBlack
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.Parent = topBar
local titleGrad = Instance.new("UIGradient")
titleGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, C.accent3),
    ColorSequenceKeypoint.new(0.5, C.accent),
    ColorSequenceKeypoint.new(1, C.accent2),
})
titleGrad.Parent = titleLbl

-- Rotación del gradiente del título
task.spawn(function()
    while titleLbl.Parent do
        TweenService:Create(titleGrad, TweenInfo.new(3, Enum.EasingStyle.Linear), { Rotation = 360 }):Play()
        task.wait(3)
        titleGrad.Rotation = 0
    end
end)

-- Typing effect para el título
task.spawn(function()
    task.wait(0.3)
    local texto = "FATASSES HUB"
    for i = 1, #texto do
        if not titleLbl.Parent then break end
        titleLbl.Text = string.sub(texto, 1, i)
        task.wait(0.05)
    end
end)

local subLbl = Instance.new("TextLabel")
subLbl.Size = UDim2.new(0, 44, 1, 0)
subLbl.Position = UDim2.new(1, -84, 0, 0)
subLbl.BackgroundTransparency = 1
subLbl.Text = "v40"
subLbl.TextColor3 = C.text_sub
subLbl.TextScaled = true
subLbl.Font = Enum.Font.GothamBold
subLbl.TextXAlignment = Enum.TextXAlignment.Right
subLbl.Parent = topBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -42, 0.5, -15)
closeBtn.BackgroundColor3 = C.bg_card
closeBtn.Text = "✕"
closeBtn.TextColor3 = C.text_dim
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.AutoButtonColor = false
closeBtn.Parent = topBar
local closeCorner = Instance.new("UICorner"); closeCorner.CornerRadius = UDim.new(1, 0); closeCorner.Parent = closeBtn

closeBtn.MouseEnter:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.2), { BackgroundColor3 = C.danger, TextColor3 = C.text, Rotation = 90 }):Play()
    reproducirSonido("hover", 0.6, 1.1)
end)
closeBtn.MouseLeave:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.2), { BackgroundColor3 = C.bg_card, TextColor3 = C.text_dim, Rotation = 0 }):Play()
end)
closeBtn.MouseButton1Click:Connect(function()
    reproducirSonido("close", 3.0, 1)
    local t = TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        Rotation = 180,
    })
    t:Play()
    t.Completed:Connect(function() frame.Visible = false; frame.Rotation = 0 end)
end)

local dragging, dragStart, startPos = false, nil, nil
topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = frame.Position
    end
end)
topBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ============================================
-- SIDEBAR
-- ============================================
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 130, 1, -70)
sidebar.Position = UDim2.new(0, 10, 0, 60)
sidebar.BackgroundColor3 = C.bg_dark
sidebar.BackgroundTransparency = 0.4
sidebar.BorderSizePixel = 0
sidebar.Parent = frame
local sbCorner = Instance.new("UICorner"); sbCorner.CornerRadius = UDim.new(0, 16); sbCorner.Parent = sidebar
local sbStroke = Instance.new("UIStroke"); sbStroke.Color = C.accent2; sbStroke.Thickness = 1; sbStroke.Transparency = 0.6; sbStroke.Parent = sidebar

-- ============================================
-- PANEL
-- ============================================
local panel = Instance.new("Frame")
panel.Size = UDim2.new(1, -160, 1, -70)
panel.Position = UDim2.new(0, 150, 0, 60)
panel.BackgroundColor3 = C.bg_dark
panel.BackgroundTransparency = 0.4
panel.BorderSizePixel = 0
panel.Parent = frame
local pCorner = Instance.new("UICorner"); pCorner.CornerRadius = UDim.new(0, 16); pCorner.Parent = panel
local pStroke = Instance.new("UIStroke"); pStroke.Color = C.accent2; pStroke.Thickness = 1; pStroke.Transparency = 0.6; pStroke.Parent = panel

local opcionesContainer = Instance.new("ScrollingFrame")
opcionesContainer.Size = UDim2.new(1, -16, 1, -16)
opcionesContainer.Position = UDim2.new(0, 8, 0, 8)
opcionesContainer.BackgroundTransparency = 1
opcionesContainer.BorderSizePixel = 0
opcionesContainer.ScrollBarThickness = 4
opcionesContainer.ScrollBarImageColor3 = C.accent
opcionesContainer.ScrollBarImageTransparency = 0.3
opcionesContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
opcionesContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
opcionesContainer.Parent = panel

local layoutOpc = Instance.new("UIListLayout")
layoutOpc.Padding = UDim.new(0, 10)
layoutOpc.SortOrder = Enum.SortOrder.LayoutOrder
layoutOpc.Parent = opcionesContainer

-- ============================================
-- VARIABLES AIMLOCK/SILENT AIM
-- ============================================
local aimlockOnAim = false
local silentAimActivo = false
local NOMBRE_TARGET_ACTUAL = ""
local jugadorTarget = nil
local characterTarget = nil
local aimlockThread = nil
local gunGui, aimButton, triggerButton, gunEvent

-- ============================================
-- TABS CON ANIMACIONES ULTRA COOL
-- ============================================
local tabsRefs = {}

local function crearTab(nombre, yPos, comingSoon, index)
    local tabWrapper = Instance.new("Frame")
    tabWrapper.Name = "TabWrap_" .. nombre
    tabWrapper.Size = UDim2.new(1, -12, 0, 52)
    tabWrapper.Position = UDim2.new(0, 6, 0, yPos)
    tabWrapper.BackgroundTransparency = 1
    tabWrapper.ClipsDescendants = false
    tabWrapper.Parent = sidebar

    local tab = Instance.new("TextButton")
    tab.Name = "Tab_" .. nombre
    tab.Size = UDim2.new(1, 0, 1, 0)
    tab.Position = UDim2.new(0, 0, 0, 0)
    tab.BackgroundColor3 = C.bg_card
    tab.BackgroundTransparency = 0.15
    tab.Text = ""
    tab.BorderSizePixel = 0
    tab.AutoButtonColor = false
    tab.ClipsDescendants = true
    tab.Parent = tabWrapper

    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 12); c.Parent = tab
    local s = Instance.new("UIStroke"); s.Color = C.border; s.Thickness = 1; s.Transparency = 0.5; s.Parent = tab

    -- Indicador lateral
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 4, 0, 0)
    indicator.Position = UDim2.new(0, 0, 0.5, 0)
    indicator.AnchorPoint = Vector2.new(0, 0.5)
    indicator.BackgroundColor3 = C.accent
    indicator.BorderSizePixel = 0
    indicator.Parent = tab
    local indCorner = Instance.new("UICorner"); indCorner.CornerRadius = UDim.new(1, 0); indCorner.Parent = indicator
    local indGrad = Instance.new("UIGradient")
    indGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, C.accent3),
        ColorSequenceKeypoint.new(1, C.accent5),
    })
    indGrad.Rotation = 90
    indGrad.Parent = indicator

    -- Icono con rotación al hover
    local iconMap = {Esp = "👁", Scientist = "🧪", ["Class A"] = "🔒", ["Class S"] = "🎯", Experiment = "🔒", ["Extra Stuff"] = "⚡"}

    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 24, 0, 24)
    icon.Position = UDim2.new(0, 12, 0.5, -12)
    icon.BackgroundTransparency = 1
    icon.Text = iconMap[nombre] or "•"
    icon.TextColor3 = comingSoon and C.text_sub or C.text
    icon.TextScaled = true
    icon.Font = Enum.Font.GothamBold
    icon.Parent = tab

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -48, 1, 0)
    lbl.Position = UDim2.new(0, 42, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = nombre
    lbl.TextColor3 = comingSoon and C.text_sub or C.text
    lbl.TextScaled = true
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextWrapped = false
    lbl.TextTruncate = Enum.TextTruncate.AtEnd
    lbl.Parent = tab

    if comingSoon then
        local lock = Instance.new("TextLabel")
        lock.Size = UDim2.new(0, 12, 0, 12)
        lock.Position = UDim2.new(1, -18, 0, 6)
        lock.BackgroundTransparency = 1
        lock.Text = "🔒"
        lock.TextColor3 = C.text_sub
        lock.TextScaled = true
        lock.Parent = tab
    end

    local shakeActivo = false
    local clickeando = false

    -- 🔥 RIPPLE EFFECT
    local function crearRipple(x, y)
        local ripple = Instance.new("Frame")
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.Position = UDim2.new(0, x, 0, y)
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        ripple.BackgroundColor3 = C.accent3
        ripple.BackgroundTransparency = 0.5
        ripple.BorderSizePixel = 0
        ripple.ZIndex = 0
        ripple.Parent = tab
        local rCorner = Instance.new("UICorner"); rCorner.CornerRadius = UDim.new(1, 0); rCorner.Parent = ripple

        TweenService:Create(ripple, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 200, 0, 200),
            BackgroundTransparency = 1,
        }):Play()
        task.delay(0.6, function() ripple:Destroy() end)
    end

    local function setState(state)
        if state == "hover" and pestanaActual ~= nombre then
            TweenService:Create(tab, TweenInfo.new(0.2), { BackgroundColor3 = C.bg_card_hl, BackgroundTransparency = 0 }):Play()
            TweenService:Create(s, TweenInfo.new(0.2), { Color = C.border_hl, Transparency = 0.3, Thickness = 2 }):Play()
            TweenService:Create(icon, TweenInfo.new(0.2, Enum.EasingStyle.Back), { Rotation = 15, Size = UDim2.new(0, 28, 0, 28) }):Play()
        elseif state == "leave" and pestanaActual ~= nombre then
            TweenService:Create(tab, TweenInfo.new(0.2), { BackgroundColor3 = C.bg_card, BackgroundTransparency = 0.15 }):Play()
            TweenService:Create(s, TweenInfo.new(0.2), { Color = C.border, Transparency = 0.5, Thickness = 1 }):Play()
            TweenService:Create(icon, TweenInfo.new(0.2, Enum.EasingStyle.Back), { Rotation = 0, Size = UDim2.new(0, 24, 0, 24) }):Play()
        elseif state == "selected" then
            TweenService:Create(tab, TweenInfo.new(0.3), { BackgroundColor3 = C.bg_card_hl, BackgroundTransparency = 0 }):Play()
            TweenService:Create(s, TweenInfo.new(0.3), { Color = C.accent2, Transparency = 0.2, Thickness = 2 }):Play()
            TweenService:Create(indicator, TweenInfo.new(0.4, Enum.EasingStyle.Back), { Size = UDim2.new(0, 4, 0.7, 0) }):Play()
            TweenService:Create(icon, TweenInfo.new(0.3), { Rotation = 360, Size = UDim2.new(0, 26, 0, 26) }):Play()
        elseif state == "deselected" then
            TweenService:Create(tab, TweenInfo.new(0.3), { BackgroundColor3 = C.bg_card, BackgroundTransparency = 0.15 }):Play()
            TweenService:Create(s, TweenInfo.new(0.3), { Color = C.border, Transparency = 0.5, Thickness = 1 }):Play()
            TweenService:Create(indicator, TweenInfo.new(0.2), { Size = UDim2.new(0, 4, 0, 0) }):Play()
        end
    end

    tab.MouseEnter:Connect(function()
        setState("hover")
        reproducirSonido("hover", 0.6, 1.2)
    end)
    tab.MouseLeave:Connect(function() setState("leave") end)

    tab.MouseButton1Click:Connect(function()
        if clickeando then return end
        local mousePos = UserInputService:GetMouseLocation()
        local relX = mousePos.X - tab.AbsolutePosition.X
        local relY = mousePos.Y - tab.AbsolutePosition.Y
        crearRipple(relX, relY)

        if comingSoon then
            if shakeActivo then return end
            shakeActivo = true
            reproducirSonido("locked", 1.0, 1)
            task.spawn(function()
                local offsetX = 6
                for i = 1, 5 do
                    local target = (i % 2 == 1) and UDim2.new(0, offsetX, 0, 0) or UDim2.new(0, -offsetX, 0, 0)
                    local t = TweenService:Create(tab, TweenInfo.new(0.04), { Position = target })
                    t:Play()
                    t.Completed:Wait()
                    offsetX = offsetX - 1
                    if offsetX < 2 then offsetX = 2 end
                end
                local tFinal = TweenService:Create(tab, TweenInfo.new(0.05), { Position = UDim2.new(0, 0, 0, 0) })
                tFinal:Play()
                tFinal.Completed:Wait()
                tab.Position = UDim2.new(0, 0, 0, 0)
                shakeActivo = false
            end)
            return
        end

        if pestanaActual == nombre then return end

        clickeando = true
        reproducirSonido("tab_switch", 2.5, 1)
        if tabsRefs[pestanaActual] then tabsRefs[pestanaActual].SetState("deselected") end
        pestanaActual = nombre
        setState("selected")
        actualizarPanel()
        task.wait(0.4)
        clickeando = false
    end)

    tabsRefs[nombre] = {Button = tab, SetState = setState, ComingSoon = comingSoon, Indicator = indicator, Wrapper = tabWrapper}
end

for i, nombre in ipairs(TODAS_PESTANAS) do
    crearTab(nombre, 8 + (i - 1) * 58, COMING_SOON[nombre], i)
end
if tabsRefs["Esp"] then tabsRefs["Esp"].SetState("selected") end

-- ============================================
-- OPCIONES CON ANIMACIONES
-- ============================================
local estadosOpciones = {}

local function crearOpcion(nombre, callback)
    local opt = Instance.new("Frame")
    opt.Name = "Opt_" .. nombre
    opt.Size = UDim2.new(1, 0, 0, 60)
    opt.BackgroundColor3 = C.bg_card
    opt.BackgroundTransparency = 0.15
    opt.BorderSizePixel = 0
    opt.ClipsDescendants = true
    opt.Parent = opcionesContainer
    local oc = Instance.new("UICorner"); oc.CornerRadius = UDim.new(0, 12); oc.Parent = opt
    local os = Instance.new("UIStroke"); os.Color = C.border; os.Thickness = 1; os.Transparency = 0.5; os.Parent = opt

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -90, 1, 0)
    label.Position = UDim2.new(0, 18, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = nombre
    label.TextColor3 = C.text
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextWrapped = true
    label.Parent = opt

    local toggleBg = Instance.new("TextButton")
    toggleBg.Size = UDim2.new(0, 56, 0, 30)
    toggleBg.Position = UDim2.new(1, -72, 0.5, -15)
    toggleBg.BackgroundColor3 = Color3.fromRGB(50, 30, 45)
    toggleBg.Text = ""
    toggleBg.BorderSizePixel = 0
    toggleBg.AutoButtonColor = false
    toggleBg.Parent = opt
    local tc = Instance.new("UICorner"); tc.CornerRadius = UDim.new(1, 0); tc.Parent = toggleBg
    local ts = Instance.new("UIStroke"); ts.Color = C.border; ts.Thickness = 1; ts.Transparency = 0.4; ts.Parent = toggleBg

    local ball = Instance.new("Frame")
    ball.Size = UDim2.new(0, 24, 0, 24)
    ball.Position = UDim2.new(0, 3, 0.5, -12)
    ball.BackgroundColor3 = Color3.fromRGB(130, 90, 120)
    ball.BorderSizePixel = 0
    ball.Parent = toggleBg
    local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(1, 0); bc.Parent = ball

    if estadosOpciones[nombre] == nil then estadosOpciones[nombre] = false end
    local estado = estadosOpciones[nombre]

    local function setEstadoVisual(act, animar)
        if act then
            TweenService:Create(ball, TweenInfo.new(animar and 0.3 or 0, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, 29, 0.5, -12),
                BackgroundColor3 = C.accent2,
                Size = UDim2.new(0, 26, 0, 26),
            }):Play()
            TweenService:Create(toggleBg, TweenInfo.new(animar and 0.3 or 0), { BackgroundColor3 = C.success_dark }):Play()
            TweenService:Create(ts, TweenInfo.new(animar and 0.3 or 0), { Color = C.accent2, Transparency = 0.1 }):Play()
        else
            TweenService:Create(ball, TweenInfo.new(animar and 0.3 or 0, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, 3, 0.5, -12),
                BackgroundColor3 = Color3.fromRGB(130, 90, 120),
                Size = UDim2.new(0, 24, 0, 24),
            }):Play()
            TweenService:Create(toggleBg, TweenInfo.new(animar and 0.3 or 0), { BackgroundColor3 = Color3.fromRGB(50, 30, 45) }):Play()
            TweenService:Create(ts, TweenInfo.new(animar and 0.3 or 0), { Color = C.border, Transparency = 0.4 }):Play()
        end
    end

    setEstadoVisual(estado, false)

    -- Pulso al activar
    local function pulseEffect()
        local pulse = Instance.new("Frame")
        pulse.Size = UDim2.new(1, 0, 1, 0)
        pulse.Position = UDim2.new(0, 0, 0, 0)
        pulse.BackgroundColor3 = C.accent
        pulse.BackgroundTransparency = 0.7
        pulse.BorderSizePixel = 0
        pulse.ZIndex = 0
        pulse.Parent = opt
        local pc = Instance.new("UICorner"); pc.CornerRadius = UDim.new(0, 12); pc.Parent = pulse
        TweenService:Create(pulse, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()
        task.delay(0.5, function() pulse:Destroy() end)
    end

    local function toggle()
        estado = not estado
        estadosOpciones[nombre] = estado
        setEstadoVisual(estado, true)
        pulseEffect()
        if estado then
            reproducirSonido("toggle_on", 3.0, 1)
        else
            reproducirSonido("toggle_off", 3.0, 1)
        end
        if callback then callback(estado) end
    end

    toggleBg.MouseButton1Click:Connect(toggle)
    label.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            toggle()
        end
    end)
    label.Active = true

    opt.MouseEnter:Connect(function()
        TweenService:Create(opt, TweenInfo.new(0.2), { BackgroundColor3 = C.bg_card_hl, BackgroundTransparency = 0, Size = UDim2.new(1, 0, 0, 62) }):Play()
        TweenService:Create(os, TweenInfo.new(0.2), { Color = C.accent, Transparency = 0.3, Thickness = 2 }):Play()
        reproducirSonido("hover", 0.6, 1.3)
    end)
    opt.MouseLeave:Connect(function()
        TweenService:Create(opt, TweenInfo.new(0.2), { BackgroundColor3 = C.bg_card, BackgroundTransparency = 0.15, Size = UDim2.new(1, 0, 0, 60) }):Play()
        TweenService:Create(os, TweenInfo.new(0.2), { Color = C.border, Transparency = 0.5, Thickness = 1 }):Play()
    end)
end

-- SISTEMA AIMLOCK + SILENT AIM
local function buscarGunGui()
    local gui = LocalPlayer.PlayerGui:FindFirstChild("GunGui")
    if not gui then return false end
    gunGui = gui
    aimButton = gui:FindFirstChild("AimButton")
    triggerButton = gui:FindFirstChild("TriggerButton")
    return aimButton ~= nil
end

local function buscarGunEvent()
    gunEvent = ReplicatedStorage:FindFirstChild("GunEvent")
    if not gunEvent then
        for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") and string.find(string.lower(obj.Name), "gun") then
                gunEvent = obj
                return true
            end
        end
    end
    return gunEvent ~= nil
end

local function buscarTargetPorNombre(nombreBuscado)
    if not nombreBuscado or nombreBuscado == "" then return nil, nil end
    local nombreLower = string.lower(nombreBuscado)
    local playerEncontrado = nil
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            if string.lower(p.Name) == nombreLower or string.find(string.lower(p.Name), nombreLower, 1, true) then
                playerEncontrado = p
                break
            end
        end
    end
    if not playerEncontrado then return nil, nil end
    local characterEncontrado = playerEncontrado.Character
    local enWorkspace = Workspace:FindFirstChild(playerEncontrado.Name)
    if enWorkspace and enWorkspace:IsA("Model") then
        characterEncontrado = enWorkspace
    end
    if not characterEncontrado then return playerEncontrado, nil end
    return playerEncontrado, characterEncontrado
end

local function getTargetHead(char)
    if not char then return nil end
    return char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
end

function iniciarAimlock()
    if aimlockThread then return end
    if not gunGui then buscarGunGui() end
    aimlockThread = task.spawn(function()
        while aimlockOnAim do
            if jugadorTarget and jugadorTarget.Parent then
                characterTarget = jugadorTarget.Character
            end
            if not jugadorTarget or not jugadorTarget.Parent or not characterTarget then
                jugadorTarget, characterTarget = buscarTargetPorNombre(NOMBRE_TARGET_ACTUAL)
            end
            if characterTarget then
                local head = getTargetHead(characterTarget)
                if head then
                    local cam = workspace.CurrentCamera
                    cam.CFrame = CFrame.lookAt(cam.CFrame.Position, head.Position)
                end
            end
            RunService.RenderStepped:Wait()
        end
    end)
end

function detenerAimlock()
    aimlockThread = nil
end

local botonesConectados = false
local function conectarBotonesGun()
    if botonesConectados then return end
    if not gunGui then buscarGunGui() end
    if not aimButton or not triggerButton then return end
    botonesConectados = true
    aimButton.MouseButton1Click:Connect(function()
        if not aimlockOnAim then return end
        if characterTarget then
            characterTarget = nil; jugadorTarget = nil
            print("🎯 Aimlock OFF (toggle)")
        else
            jugadorTarget, characterTarget = buscarTargetPorNombre(NOMBRE_TARGET_ACTUAL)
            if jugadorTarget then print("🎯 Aimlock ON:", jugadorTarget.Name) end
        end
    end)
    triggerButton.MouseButton1Click:Connect(function()
        if not aimlockOnAim then return end
        characterTarget = nil; jugadorTarget = nil
        print("🎯 Aimlock OFF (trigger)")
    end)
end

local function instalarSilentAim()
    if not hookmetamethod or not getnamecallmethod or not getrawmetatable then return end
    if not gunEvent then buscarGunEvent() end
    if not gunEvent then return end
    pcall(function()
        local mt = getrawmetatable(game)
        local oldNamecall = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method == "FireServer" and self == gunEvent and silentAimActivo then
                local args = {...}
                if args[1] == "Shoot" and characterTarget then
                    local head = getTargetHead(characterTarget)
                    if head then
                        return oldNamecall(self, "Shoot", head.Position)
                    end
                end
            end
            return oldNamecall(self, ...)
        end)
        setreadonly(mt, true)
        print("✅ Silent Aim instalado")
    end)
end

-- INPUT TARGET
local function crearInputTarget()
    if panel:FindFirstChild("TargetInput") then return end
    local inputFrame = Instance.new("Frame")
    inputFrame.Name = "TargetInput"
    inputFrame.Size = UDim2.new(1, -16, 0, 72)
    inputFrame.Position = UDim2.new(0, 8, 1, -82)
    inputFrame.BackgroundColor3 = C.bg_card
    inputFrame.BackgroundTransparency = 0.1
    inputFrame.BorderSizePixel = 0
    inputFrame.Parent = panel
    local ic = Instance.new("UICorner"); ic.CornerRadius = UDim.new(0, 12); ic.Parent = inputFrame
    local is_ = Instance.new("UIStroke"); is_.Color = C.accent2; is_.Thickness = 1; is_.Transparency = 0.4; is_.Parent = inputFrame

    local textBox = Instance.new("TextBox")
    textBox.Name = "TextBox"
    textBox.Size = UDim2.new(1, -16, 0, 30)
    textBox.Position = UDim2.new(0, 8, 0, 6)
    textBox.BackgroundColor3 = Color3.fromRGB(50, 30, 45)
    textBox.TextColor3 = C.text
    textBox.PlaceholderText = "Nombre del target..."
    textBox.PlaceholderColor3 = C.text_sub
    textBox.Text = NOMBRE_TARGET_ACTUAL
    textBox.TextScaled = true
    textBox.Font = Enum.Font.GothamBold
    textBox.BorderSizePixel = 0
    textBox.ClearTextOnFocus = false
    textBox.Parent = inputFrame
    local tc = Instance.new("UICorner"); tc.CornerRadius = UDim.new(0, 8); tc.Parent = textBox

    local selectBtn = Instance.new("TextButton")
    selectBtn.Size = UDim2.new(1, -16, 0, 26)
    selectBtn.Position = UDim2.new(0, 8, 0, 42)
    selectBtn.BackgroundColor3 = C.accent2
    selectBtn.Text = "SELECT"
    selectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    selectBtn.TextScaled = true
    selectBtn.Font = Enum.Font.GothamBold
    selectBtn.BorderSizePixel = 0
    selectBtn.AutoButtonColor = false
    selectBtn.Parent = inputFrame
    local sc = Instance.new("UICorner"); sc.CornerRadius = UDim.new(0, 8); sc.Parent = selectBtn

    selectBtn.MouseButton1Click:Connect(function()
        reproducirSonido("toggle_on", 3.0, 1)
        NOMBRE_TARGET_ACTUAL = textBox.Text
        local p, c = buscarTargetPorNombre(NOMBRE_TARGET_ACTUAL)
        if p then
            jugadorTarget = p
            characterTarget = c
            selectBtn.Text = "✅ " .. p.Name
            task.delay(1.5, function()
                if selectBtn.Parent then selectBtn.Text = "SELECT" end
            end)
        else
            jugadorTarget = nil
            characterTarget = nil
            selectBtn.Text = "❌ No encontrado"
            task.delay(1.5, function()
                if selectBtn.Parent then selectBtn.Text = "SELECT" end
            end)
        end
    end)
end

-- ============================================
-- ACTUALIZAR PANEL CON TRANSICIONES
-- ============================================
local actualizandoPanel = false
local panelIdActual = 0

function actualizarPanel()
    if actualizandoPanel then return end
    actualizandoPanel = true
    panelIdActual = panelIdActual + 1
    local miPanelId = panelIdActual

    for _, hijo in ipairs(opcionesContainer:GetChildren()) do
        if not hijo:IsA("UIListLayout") and not hijo:IsA("UIPadding") then
            TweenService:Create(hijo, TweenInfo.new(0.15), { BackgroundTransparency = 1, Position = hijo.Position + UDim2.new(-0.2, 0, 0, 0) }):Play()
        end
    end
    task.wait(0.16)
    for _, hijo in ipairs(opcionesContainer:GetChildren()) do
        if not hijo:IsA("UIListLayout") and not hijo:IsA("UIPadding") then
            hijo:Destroy()
        end
    end
    local ti = panel:FindFirstChild("TargetInput")
    if ti then ti:Destroy() end

    if pestanaActual == "Esp" then
        crearOpcion("ESP Tasks", function(v) espActivo = v; if v then iniciarESP() else detenerESP() end end)
        crearOpcion("ESP Players (Health)", function(v) espPlayersActivo = v; if v then iniciarESPPlayers() else detenerESPPlayers() end end)
    elseif pestanaActual == "Scientist" then
        crearOpcion("Auto Patient", function(v) activo = v; if v then iniciarAutoPatient() else detenerAutoPatient() end end)
        crearOpcion("Auto Generator", function(v) autoGen = v; if v then iniciarAutoGenerator() else detenerAutoGenerator() end end)
        crearOpcion("Anti Broken Pipes", function(v) antiBroken = v; if v then iniciarAntiBroken() else detenerAntiBroken() end end)
    elseif pestanaActual == "Class S" then
        crearOpcion("Aimlock on Aim", function(v) aimlockOnAim = v; if v then iniciarAimlock() else detenerAimlock() end end)
        crearOpcion("Silent Aim", function(v) silentAimActivo = v end)
        task.wait(0.05)
        crearInputTarget()
    elseif pestanaActual == "Extra Stuff" then
        crearOpcion("Scientist AI Auto Play", function(v) autoPlayIA = v; if v then iniciarIA() else detenerIA() end end)
    end

    task.wait(0.05)
    for i, hijo in ipairs(opcionesContainer:GetChildren()) do
        if hijo:IsA("Frame") and miPanelId == panelIdActual then
            local origPos = hijo.Position
            hijo.Position = origPos + UDim2.new(0.3, 0, 0, 0)
            hijo.BackgroundTransparency = 1
            TweenService:Create(hijo, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Position = origPos,
                BackgroundTransparency = 0.15,
            }):Play()
            task.wait(0.05)
        end
    end

    task.wait(0.4)
    actualizandoPanel = false
end

-- INICIALIZAR GUN
task.spawn(function()
    task.wait(1)
    buscarGunGui()
    buscarGunEvent()
    instalarSilentAim()
    conectarBotonesGun()
end)

task.spawn(function()
    while true do
        task.wait(2)
        if not gunGui or not gunGui.Parent then
            botonesConectados = false
            buscarGunGui()
            conectarBotonesGun()
        end
    end
end)

-- ============================================
-- BOTÓN "S" ULTRA COOL
-- ============================================
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleBtn"
toggleBtn.Size = UDim2.new(0, 70, 0, 70)
toggleBtn.Position = UDim2.new(0, 24, 0.7, 0)
toggleBtn.BackgroundColor3 = C.accent2
toggleBtn.Text = "S"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextScaled = true
toggleBtn.Font = Enum.Font.GothamBlack
toggleBtn.TextStrokeTransparency = 0
toggleBtn.TextStrokeColor3 = C.accent5
toggleBtn.BorderSizePixel = 0
toggleBtn.AutoButtonColor = false
toggleBtn.Active = true
toggleBtn.Parent = screenGui
local toggleCorner = Instance.new("UICorner"); toggleCorner.CornerRadius = UDim.new(1, 0); toggleCorner.Parent = toggleBtn
local toggleStroke = Instance.new("UIStroke"); toggleStroke.Color = C.accent3; toggleStroke.Thickness = 3; toggleStroke.Transparency = 0.2; toggleStroke.Parent = toggleBtn

local btnGrad = Instance.new("UIGradient")
btnGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, C.accent3),
    ColorSequenceKeypoint.new(0.5, C.accent2),
    ColorSequenceKeypoint.new(1, C.accent4),
})
btnGrad.Rotation = 45
btnGrad.Parent = toggleBtn

-- Rotación continua del gradiente del botón
task.spawn(function()
    while toggleBtn.Parent do
        TweenService:Create(btnGrad, TweenInfo.new(3, Enum.EasingStyle.Linear), { Rotation = 45 + 360 }):Play()
        task.wait(3)
        btnGrad.Rotation = 45
    end
end)

-- Múltiples anillos de glow
local glowRing1 = Instance.new("Frame")
glowRing1.Size = UDim2.new(1, 12, 1, 12)
glowRing1.Position = UDim2.new(0.5, 0, 0.5, 0)
glowRing1.AnchorPoint = Vector2.new(0.5, 0.5)
glowRing1.BackgroundColor3 = C.accent
glowRing1.BackgroundTransparency = 0.85
glowRing1.BorderSizePixel = 0
glowRing1.ZIndex = 0
glowRing1.Parent = toggleBtn
local grCorner1 = Instance.new("UICorner"); grCorner1.CornerRadius = UDim.new(1, 0); grCorner1.Parent = glowRing1

local glowRing2 = Instance.new("Frame")
glowRing2.Size = UDim2.new(1, 12, 1, 12)
glowRing2.Position = UDim2.new(0.5, 0, 0.5, 0)
glowRing2.AnchorPoint = Vector2.new(0.5, 0.5)
glowRing2.BackgroundColor3 = C.accent3
glowRing2.BackgroundTransparency = 0.85
glowRing2.BorderSizePixel = 0
glowRing2.ZIndex = 0
glowRing2.Parent = toggleBtn
local grCorner2 = Instance.new("UICorner"); grCorner2.CornerRadius = UDim.new(1, 0); grCorner2.Parent = glowRing2

task.spawn(function()
    while toggleBtn.Parent do
        TweenService:Create(glowRing1, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {
            Size = UDim2.new(1, 30, 1, 30),
            BackgroundTransparency = 0.95,
        }):Play()
        task.wait(0.75)
        TweenService:Create(glowRing2, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {
            Size = UDim2.new(1, 26, 1, 26),
            BackgroundTransparency = 0.95,
        }):Play()
        task.wait(0.75)
        glowRing1.Size = UDim2.new(1, 12, 1, 12)
        glowRing1.BackgroundTransparency = 0.85
        glowRing2.Size = UDim2.new(1, 12, 1, 12)
        glowRing2.BackgroundTransparency = 0.85
    end
end)

toggleBtn.MouseEnter:Connect(function()
    TweenService:Create(toggleBtn, TweenInfo.new(0.25, Enum.EasingStyle.Back), { Size = UDim2.new(0, 78, 0, 78) }):Play()
    reproducirSonido("hover", 0.6, 1.2)
end)
toggleBtn.MouseLeave:Connect(function()
    TweenService:Create(toggleBtn, TweenInfo.new(0.25, Enum.EasingStyle.Back), { Size = UDim2.new(0, 70, 0, 70) }):Play()
end)

toggleBtn.MouseButton1Click:Connect(function()
    reproducirSonido("toggle_gui", 2.8, 1)
    if frame.Visible then
        local t = TweenService:Create(frame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Rotation = 45,
        })
        t:Play()
        t.Completed:Connect(function() frame.Visible = false; frame.Rotation = 0 end)
    else
        frame.Visible = true
        frame.Size = UDim2.new(0, 0, 0, 0)
        frame.Rotation = -45
        local t = TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 500, 0, 420),
            Rotation = 0,
        })
        t:Play()
    end
end)

local draggingT, dragStartT, startPosT = false, nil, nil
toggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingT = true; dragStartT = input.Position; startPosT = toggleBtn.Position
    end
end)
toggleBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingT = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingT and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStartT
        toggleBtn.Position = UDim2.new(startPosT.X.Scale, startPosT.X.Offset + delta.X, startPosT.Y.Scale, startPosT.Y.Offset + delta.Y)
    end
end)

-- ============================================
-- FUNCIONES DE JUEGO
-- ============================================

-- AUTO PATIENT
local conexion = nil
function iniciarAutoPatient()
    if conexion then return end
    conexion = RunService.Heartbeat:Connect(function()
        if not activo then return end
        local gui = LocalPlayer.PlayerGui:FindFirstChild(NOMBRE_GUI)
        if not gui or not gui.Enabled then return end
        local fm = gui:FindFirstChild("Frame")
        if not fm or not fm.Visible then return end
        local catcher = fm:FindFirstChild("Catcher")
        if not catcher then return end
        for _, h in ipairs(fm:GetChildren()) do
            if h.Name == "Note" and h:IsA("Frame") then
                local a = h:GetAttribute("Angle")
                if a then
                    local d = math.abs(a - ANGULO_ABAJO)
                    if d > math.pi then d = 2*math.pi - d end
                    if d > 0.3 then h:SetAttribute("Angle", ANGULO_ABAJO) end
                end
            end
        end
        local ac = ANGULO_ABAJO + math.pi/2
        catcher.Position = UDim2.new(math.cos(ac)*RADIO+0.5, 0, math.sin(ac)*RADIO+0.5, 0)
        catcher.Rotation = math.deg(ac)+90
        catcher.BackgroundColor3 = Color3.fromRGB(0,255,157)
    end)
end
function detenerAutoPatient() if conexion then conexion:Disconnect(); conexion = nil end end

-- AUTO GENERATOR
local SIDES = {["Straight"]={0,2},["Corner"]={1,2},["Endpoint"]={2},["TPipe"]={1,2,3}}
local OPUESTO = {2,3,0,1}
local DIRV = {[0]={0,-1},[1]={1,0},[2]={0,1},[3]={-1,0}}
local function rotCelda(c)
    local img = c:FindFirstChildOfClass("ImageButton")
    if not img then return 0 end
    return math.round((img:GetAttribute("TargetRotation") or img.Rotation)/90)%4
end
local function esRota(c) return c:FindFirstChild("IsBroken") ~= nil end
local function xyDeOrder(o) return (o-1)%5, math.floor((o-1)/5) end
local function orderDeXY(x,y) return y*5+x+1 end
local function ladosAbiertos(c)
    local pt = c:FindFirstChild("PipeType"); if not pt then return {} end
    local bs = SIDES[pt.Value]; if not bs then return {} end
    local ra = rotCelda(c); local l = {}
    for _, lb in ipairs(bs) do table.insert(l, (lb+ra)%4) end
    return l
end
local function puedeAbrirDos(c, l1, l2)
    local pt = c:FindFirstChild("PipeType"); if not pt then return nil end
    local bs = SIDES[pt.Value]; if not bs then return nil end
    local ra = rotCelda(c)
    for d = 0, 3 do
        local rp = (ra+d)%4; local a1, a2 = false, false
        for _, lb in ipairs(bs) do
            local l = (lb+rp)%4
            if l == l1 then a1 = true end
            if l == l2 then a2 = true end
        end
        if a1 and a2 then return d end
    end
    return nil
end
local function encontrarCamino(celdas)
    local mapa = {}
    for _, c in ipairs(celdas) do
        local x, y = xyDeOrder(c.LayoutOrder); mapa[x] = mapa[x] or {}; mapa[x][y] = c
    end
    local c1 = mapa[0] and mapa[0][0]; local c25 = mapa[4] and mapa[4][4]
    if not c1 or not c25 then return nil end
    local l1 = ladosAbiertos(c1); if #l1 ~= 1 or (l1[1] ~= 1 and l1[1] ~= 2) then return nil end
    local l25 = ladosAbiertos(c25); if #l25 ~= 1 or (l25[1] ~= 0 and l25[1] ~= 3) then return nil end
    local camino = {}
    local function dfs(x, y, ladoEntrada)
        local celda = mapa[x] and mapa[x][y]
        if not celda or esRota(celda) then return false end
        local order = orderDeXY(x, y)
        if camino[order] ~= nil then return false end
        if order == 25 then
            if ladoEntrada == l25[1] then camino[order] = 0; return true end
            return false
        end
        if order == 1 then
            local ls = l1[1]; local dx, dy = DIRV[ls][1], DIRV[ls][2]
            local nx, ny = x+dx, y+dy
            if nx>=0 and nx<5 and ny>=0 and ny<5 then
                local v = mapa[nx] and mapa[nx][ny]
                if v and not esRota(v) then
                    local lo = OPUESTO[ls+1]; camino[order] = 0
                    if dfs(nx, ny, lo) then return true end
                    camino[order] = nil
                end
            end
            return false
        end
        for ls = 0, 3 do
            if ls ~= ladoEntrada then
                local dx, dy = DIRV[ls][1], DIRV[ls][2]
                local nx, ny = x+dx, y+dy
                if nx>=0 and nx<5 and ny>=0 and ny<5 then
                    local nO = orderDeXY(nx, ny)
                    local v = mapa[nx] and mapa[nx][ny]
                    if v and not esRota(v) and camino[nO] == nil then
                        local d = puedeAbrirDos(celda, ladoEntrada, ls)
                        if d ~= nil then
                            local lo = OPUESTO[ls+1]; camino[order] = d
                            if dfs(nx, ny, lo) then return true end
                            camino[order] = nil
                        end
                    end
                end
            end
        end
        return false
    end
    if dfs(0, 0, nil) then return camino end
    return nil
end
local function resolverInstantaneo(celdas)
    local camino = encontrarCamino(celdas)
    if not camino then return false end
    for o = 1, 25 do
        local d = camino[o]
        if d and d > 0 then
            for _, c in ipairs(celdas) do
                if c.LayoutOrder == o then
                    local img = c:FindFirstChildOfClass("ImageButton")
                    if img then
                        local rotActual = img:GetAttribute("TargetRotation") or img.Rotation
                        local nuevaRot = rotActual + d * 90
                        img:SetAttribute("TargetRotation", nuevaRot); img.Rotation = nuevaRot
                    end
                    break
                end
            end
        end
    end
    local triggerCell = nil
    for o = 2, 24 do
        local d = camino[o] or 0
        if d > 0 then
            for _, c in ipairs(celdas) do
                if c.LayoutOrder == o then triggerCell = c; break end
            end
            break
        end
    end
    if triggerCell then
        local img = triggerCell:FindFirstChildOfClass("ImageButton")
        if img then
            local rotActual = img:GetAttribute("TargetRotation") or img.Rotation
            img:SetAttribute("TargetRotation", rotActual - 90); img.Rotation = rotActual - 90
            if firesignal then pcall(firesignal, img.MouseButton1Click) end
        end
    end
    return true
end
local conexionGen = nil
local ultimoGrid = nil
local resolviendo = false
function iniciarAutoGenerator()
    if conexionGen then return end
    conexionGen = RunService.Heartbeat:Connect(function()
        if not autoGen then return end
        local gui = LocalPlayer.PlayerGui:FindFirstChild(NOMBRE_GUI2)
        if not gui or not gui.Enabled then ultimoGrid = nil; return end
        local gc = gui:FindFirstChild("GridContainer")
        if not gc or not gc.Visible then ultimoGrid = nil; return end
        if ultimoGrid == gc then return end
        if resolviendo then return end
        local celdas = {}
        for _, h in ipairs(gc:GetChildren()) do
            if h:IsA("Frame") and h:FindFirstChildOfClass("ImageButton") then table.insert(celdas, h) end
        end
        if #celdas < 25 then return end
        table.sort(celdas, function(a, b) return a.LayoutOrder < b.LayoutOrder end)
        resolviendo = true; ultimoGrid = gc
        task.spawn(function()
            task.wait(0.3)
            if autoGen then resolverInstantaneo(celdas) end
            resolviendo = false
        end)
    end)
end
function detenerAutoGenerator() if conexionGen then conexionGen:Disconnect(); conexionGen = nil end; resolviendo = false; ultimoGrid = nil end

-- ANTI BROKEN
local conexionAntiBroken = nil
function iniciarAntiBroken()
    if conexionAntiBroken then return end
    conexionAntiBroken = RunService.Heartbeat:Connect(function()
        if not antiBroken then return end
        local gui = LocalPlayer.PlayerGui:FindFirstChild(NOMBRE_GUI2)
        if not gui or not gui.Enabled then return end
        local gc = gui:FindFirstChild("GridContainer")
        if not gc then return end
        for _, celda in ipairs(gc:GetChildren()) do
            if celda:IsA("Frame") then
                local ib = celda:FindFirstChild("IsBroken"); if ib then ib:Destroy() end
                local ov = celda:FindFirstChild("BrokenOverlay"); if ov then ov:Destroy() end
            end
        end
    end)
end
function detenerAntiBroken() if conexionAntiBroken then conexionAntiBroken:Disconnect(); conexionAntiBroken = nil end end

-- ESP OBJETIVES
local cacheObj = {}
local escaneando = false
local function tipoObj(m)
    if not m or not m.Name then return nil end
    local n = string.lower(m.Name)
    if string.find(n, "patient", 1, true) then return "patient" end
    if string.find(n, "tube", 1, true) then return "tube" end
    return nil
end
local function procesar(m, conteo, completo)
    if not m or not m.Parent then return end
    local c = cacheObj[m]
    if not c then
        local hl = Instance.new("Highlight")
        hl.Name = "ESP_Obj_HL"; hl.FillTransparency = 0.5; hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; hl.Adornee = m; hl.Parent = m
        c = {hl=hl, bb=nil, completo=false}; cacheObj[m] = c
    end
    if c.completo ~= completo then
        c.completo = completo
        if completo then
            c.hl.FillColor = Color3.fromRGB(255,130,200); c.hl.OutlineColor = Color3.fromRGB(255,180,220)
        else
            c.hl.FillColor = Color3.fromRGB(0,150,255); c.hl.OutlineColor = Color3.fromRGB(0,200,255)
        end
    end
    if completo then
        if not c.bb or not c.bb.Parent then
            local bg = Instance.new("BillboardGui")
            bg.Name = "ESP_Obj_Label"; bg.Size = UDim2.new(0,120,0,60)
            bg.StudsOffset = Vector3.new(0,4,0); bg.AlwaysOnTop = true; bg.Parent = m
            local l = Instance.new("TextLabel")
            l.Name = "Text"; l.Size = UDim2.new(1,0,1,0); l.BackgroundTransparency = 1
            l.TextColor3 = Color3.fromRGB(255,130,200); l.TextStrokeTransparency = 0
            l.TextStrokeColor3 = Color3.fromRGB(80,20,60); l.TextScaled = true
            l.Font = Enum.Font.GothamBold; l.Text = conteo .. "/" .. META; l.Parent = bg
            c.bb = bg
        else
            local lbl = c.bb:FindFirstChild("Text")
            if lbl then local nt = conteo .. "/" .. META; if lbl.Text ~= nt then lbl.Text = nt end end
        end
    else
        if c.bb then c.bb:Destroy(); c.bb = nil end
    end
end
local function escanear()
    if escaneando then return end
    escaneando = true
    local cP, cT = 0, 0; local encontrados = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local t = tipoObj(obj)
            if t then
                encontrados[obj] = t
                if t == "patient" then cP = cP + 1 else cT = cT + 1 end
            end
        end
    end
    local pC = cP >= META; local tC = cT >= META
    for m, t in pairs(encontrados) do
        local cnt = (t == "patient") and cP or cT
        local comp = (t == "patient") and pC or tC
        procesar(m, cnt, comp)
    end
    for m, c in pairs(cacheObj) do
        if not encontrados[m] or not m.Parent then
            if c.hl then c.hl:Destroy() end
            if c.bb then c.bb:Destroy() end
            cacheObj[m] = nil
        end
    end
    escaneando = false
end
local conexionESP = nil
local connAdd, connRem = nil, nil
function iniciarESP()
    if conexionESP then return end
    escanear()
    conexionESP = task.spawn(function()
        while espActivo do task.wait(2); if espActivo then escanear() end end
    end)
    connAdd = Workspace.DescendantAdded:Connect(function(o)
        if not espActivo then return end
        if o:IsA("Model") and tipoObj(o) then task.wait(0.3); if espActivo then escanear() end end
    end)
    connRem = Workspace.DescendantRemoving:Connect(function(o)
        if not espActivo then return end
        local c = cacheObj[o]
        if c then
            if c.hl then c.hl:Destroy() end
            if c.bb then c.bb:Destroy() end
            cacheObj[o] = nil
        end
    end)
end
local function limpiarObj()
    for m, c in pairs(cacheObj) do
        if c.hl then c.hl:Destroy() end
        if c.bb then c.bb:Destroy() end
    end
    cacheObj = {}
end
function detenerESP()
    limpiarObj(); conexionESP = nil
    if connAdd then connAdd:Disconnect(); connAdd = nil end
    if connRem then connRem:Disconnect(); connRem = nil end
end

-- ESP PLAYERS
local playersESP = {}
local function crearJ(p)
    local ch = p.Character
    if not ch or p == LocalPlayer then return end
    if playersESP[p] then
        pcall(function()
            if playersESP[p].hl then playersESP[p].hl:Destroy() end
            if playersESP[p].bb then playersESP[p].bb:Destroy() end
        end)
        playersESP[p] = nil
    end
    local hl = Instance.new("Highlight")
    hl.Name = "ESP_P_HL"; hl.FillColor = Color3.fromRGB(255,130,180); hl.OutlineColor = Color3.fromRGB(255,170,210)
    hl.FillTransparency = 0.55; hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; hl.Adornee = ch; hl.Parent = ch
    local bg = Instance.new("BillboardGui")
    bg.Name = "ESP_P_BB"; bg.Size = UDim2.new(0,160,0,60)
    bg.StudsOffset = Vector3.new(0,3.5,0); bg.AlwaysOnTop = true; bg.Parent = ch
    local n = Instance.new("TextLabel")
    n.Size = UDim2.new(1,0,0.5,0); n.BackgroundTransparency = 1
    n.TextColor3 = Color3.fromRGB(255,255,255); n.TextStrokeTransparency = 0
    n.TextStrokeColor3 = Color3.fromRGB(0,0,0); n.TextScaled = true
    n.Font = Enum.Font.GothamBold; n.Text = p.Name; n.Parent = bg
    local s = Instance.new("TextLabel")
    s.Name = "Salud"; s.Size = UDim2.new(1,0,0.5,0); s.Position = UDim2.new(0,0,0.5,0)
    s.BackgroundTransparency = 1; s.TextColor3 = Color3.fromRGB(0,255,100)
    s.TextStrokeTransparency = 0; s.TextStrokeColor3 = Color3.fromRGB(0,0,0)
    s.TextScaled = true; s.Font = Enum.Font.GothamBold; s.Text = "100 / 100"; s.Parent = bg
    playersESP[p] = {hl=hl, bb=bg, lbl=s, uHp=-1, uMx=-1, char=ch}
end
local function quitarJ(p)
    local d = playersESP[p]; if not d then return end
    pcall(function()
        if d.hl then d.hl:Destroy() end
        if d.bb then d.bb:Destroy() end
    end)
    playersESP[p] = nil
end
local conexionP = nil
function iniciarESPPlayers()
    if conexionP then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then crearJ(p) end
    end
    Players.PlayerAdded:Connect(function(p)
        if not espPlayersActivo then return end
        p.CharacterAdded:Connect(function() task.wait(0.3); if espPlayersActivo then crearJ(p) end end)
    end)
    Players.PlayerRemoving:Connect(quitarJ)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            p.CharacterAdded:Connect(function()
                if not espPlayersActivo then return end
                task.wait(0.3); if espPlayersActivo then crearJ(p) end
            end)
        end
    end
    local acum = 0
    conexionP = RunService.Heartbeat:Connect(function(dt)
        if not espPlayersActivo then return end
        acum = acum + dt
        if acum < 0.3 then return end
        acum = 0
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local ch = p.Character
                local d = playersESP[p]
                if ch and not d then crearJ(p)
                elseif ch and d then
                    if d.char ~= ch or not d.hl or not d.hl.Parent then crearJ(p); d = playersESP[p] end
                    if d and d.lbl then
                        local hum = ch:FindFirstChildOfClass("Humanoid")
                        if hum then
                            local hp = math.floor(hum.Health); local mx = math.floor(hum.MaxHealth)
                            if hp ~= d.uHp or mx ~= d.uMx then
                                d.uHp = hp; d.uMx = mx
                                d.lbl.Text = hp .. " / " .. mx
                                local r = hp/math.max(1,mx)
                                if r > 0.6 then d.lbl.TextColor3 = Color3.fromRGB(0,255,100)
                                elseif r > 0.3 then d.lbl.TextColor3 = Color3.fromRGB(255,200,0)
                                else d.lbl.TextColor3 = Color3.fromRGB(255,60,60) end
                            end
                        end
                    end
                elseif not ch and d then quitarJ(p) end
            end
        end
    end)
end
function detenerESPPlayers()
    if conexionP then conexionP:Disconnect(); conexionP = nil end
    for p in pairs(playersESP) do quitarJ(p) end
    playersESP = {}
end

-- IA COMPLETA
local iaThread = nil
local iaEstado = "IDLE"
local DIST_HUIR = 45
local DIST_JUKE = 18
local VEL_NORMAL = 16
local VEL_HUIR = 24
local destinoActual = nil
local ultimoDestinoCambio = 0
local targetObjActual = nil
local ultimoLog = 0

local function getHRP(obj)
    if not obj then return nil end
    return obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head") 
        or obj:FindFirstChild("UpperTorso") or obj.PrimaryPart 
        or obj:FindFirstChildWhichIsA("BasePart")
end
local function getDist(a, b)
    local pa, pb = getHRP(a), getHRP(b)
    if not pa or not pb then return math.huge end
    return (pa.Position - pb.Position).Magnitude
end
local function encontrarKiller()
    local killer, alturaMax = nil, 0
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local ext = p.Character:GetExtentsSize()
                if ext.Y > alturaMax then alturaMax = ext.Y; killer = p.Character end
            end
        end
    end
    return killer
end
local function buscarObjetivos()
    local lista = {}
    local miChar = LocalPlayer.Character
    if not miChar then return lista end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local n = string.lower(obj.Name)
            if string.find(n, "patient", 1, true) or string.find(n, "tube", 1, true) then
                local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                if prompt and prompt.Enabled then
                    table.insert(lista, {model = obj, prompt = prompt, dist = getDist(miChar, obj)})
                end
            end
        end
    end
    table.sort(lista, function(a, b) return a.dist < b.dist end)
    return lista
end
local function hayPuertaCerca(radio)
    local miChar = LocalPlayer.Character
    if not miChar then return nil end
    local hrp = getHRP(miChar)
    if not hrp then return nil end
    radio = radio or 10
    local mejor, mejorDist = nil, math.huge
    for _, p in ipairs(Workspace:GetDescendants()) do
        if p:IsA("ProximityPrompt") then
            local at = string.lower(p.ActionText or "")
            if string.find(at, "open") or string.find(at, "close") then
                local parent = p.Parent
                local parte = parent:IsA("BasePart") and parent or parent:FindFirstChildWhichIsA("BasePart", true)
                if parte then
                    local d = (parte.Position - hrp.Position).Magnitude
                    if d <= radio and d < mejorDist then mejorDist = d; mejor = {prompt = p, parte = parte} end
                end
            end
        end
    end
    return mejor
end
local function usarPrompt(prompt)
    if not prompt or not prompt.Enabled then return false end
    pcall(function()
        prompt:InputHoldBegin()
        task.wait((prompt.HoldDuration or 0) + 0.05)
        prompt:InputHoldEnd()
    end)
    return true
end
local function moverHacia(pos, velocidad)
    local miChar = LocalPlayer.Character
    if not miChar then return end
    local hum = miChar:FindFirstChildOfClass("Humanoid")
    local hrp = getHRP(miChar)
    if not hum or not hrp then return end
    hum.WalkSpeed = velocidad or VEL_NORMAL
    local cambio = not destinoActual or (destinoActual - pos).Magnitude > 3
    local timeout = tick() - ultimoDestinoCambio > 0.8
    if cambio or timeout then
        destinoActual = pos; ultimoDestinoCambio = tick(); hum:MoveTo(pos)
    end
end
local function usarPathfinding(destino, velocidad)
    local miChar = LocalPlayer.Character
    if not miChar then return end
    local hum = miChar:FindFirstChildOfClass("Humanoid")
    local hrp = getHRP(miChar)
    if not hum or not hrp then return end
    hum.WalkSpeed = velocidad or VEL_NORMAL
    local path = PathfindingService:CreatePath({AgentRadius = 2, AgentHeight = 5, AgentCanJump = true, WaypointSpacing = 4})
    local ok = pcall(function() path:ComputeAsync(hrp.Position, destino) end)
    if not ok or path.Status ~= Enum.PathStatus.Success then hum:MoveTo(destino); return end
    local waypoints = path:GetWaypoints()
    for i = 2, #waypoints do
        if not autoPlayIA then return end
        local wp = waypoints[i]
        if wp.Action == Enum.PathWaypointAction.Jump then hum.Jump = true end
        hum:MoveTo(wp.Position)
        local t = 0
        while t < 3 do
            if not autoPlayIA then return end
            if (hrp.Position - wp.Position).Magnitude < 3 then break end
            local puerta = hayPuertaCerca(6)
            if puerta then usarPrompt(puerta.prompt) end
            task.wait(0.1); t = t + 0.1
        end
    end
end
local function hacerJuke(killer)
    local miChar = LocalPlayer.Character
    if not miChar then return end
    local hrp = getHRP(miChar)
    local kHRP = getHRP(killer)
    if not hrp or not kHRP then return end
    local dir = (hrp.Position - kHRP.Position); dir = Vector3.new(dir.X, 0, dir.Z).Unit
    local perp = Vector3.new(-dir.Z, 0, dir.X)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {miChar}
    local rayA = Workspace:Raycast(hrp.Position, perp * 20, params)
    local rayB = Workspace:Raycast(hrp.Position, -perp * 20, params)
    if rayA and not rayB then perp = -perp elseif rayA and rayB then perp = -dir end
    usarPathfinding(hrp.Position + perp * 35 + dir * 10, VEL_HUIR)
end
local ultimaPosStuck = Vector3.new(0,0,0)
local tiempoStuck = 0
local function checkStuck(dt)
    local miChar = LocalPlayer.Character
    if not miChar then return false end
    local hrp = getHRP(miChar)
    if not hrp then return false end
    local mov = (hrp.Position - ultimaPosStuck).Magnitude
    ultimaPosStuck = hrp.Position
    if mov < 1.5 * dt then tiempoStuck = tiempoStuck + dt else tiempoStuck = 0 end
    if tiempoStuck > 2 then tiempoStuck = 0; return true end
    return false
end
function iniciarIA()
    if iaThread then return end
    iaThread = task.spawn(function()
        local ultimoFrame = tick()
        while autoPlayIA do
            local ahora = tick()
            local dt = ahora - ultimoFrame
            ultimoFrame = ahora
            local miChar = LocalPlayer.Character
            if not miChar then task.wait(0.5); continue end
            local hum = miChar:FindFirstChildOfClass("Humanoid")
            local hrp = getHRP(miChar)
            if not hum or hum.Health <= 0 or not hrp then task.wait(1); continue end
            local killer = encontrarKiller()
            local dKiller = killer and getDist(miChar, killer) or math.huge
            if killer and dKiller <= DIST_JUKE then
                iaEstado = "JUKE"; hacerJuke(killer); task.wait(0.1); continue
            end
            if killer and dKiller <= DIST_HUIR then
                iaEstado = "FLEE"
                local kHRP = getHRP(killer)
                if kHRP then
                    local dir = (hrp.Position - kHRP.Position); dir = Vector3.new(dir.X, 0, dir.Z).Unit
                    moverHacia(hrp.Position + dir * 40, VEL_HUIR)
                end
                local puerta = hayPuertaCerca(10)
                if puerta and tick() - ultimoDestinoCambio > 1 then task.wait(0.1); usarPrompt(puerta.prompt) end
                task.wait(0.15); continue
            end
            if checkStuck(dt) then
                iaEstado = "UNSTUCK"
                local perp = Vector3.new(-hrp.CFrame.LookVector.Z, 0, hrp.CFrame.LookVector.X)
                hum:MoveTo(hrp.Position + perp * 15)
                task.wait(0.5); continue
            end
            local objetivos = buscarObjetivos()
            if #objetivos > 0 then
                local obj = objetivos[1]
                local objHRP = getHRP(obj.model)
                if objHRP then
                    if obj.dist <= 8 then
                        iaEstado = "INTERACT"
                        hum.WalkSpeed = 0; hum:MoveTo(hrp.Position)
                        usarPrompt(obj.prompt); task.wait(0.4)
                    else
                        iaEstado = "MOVE_OBJ"
                        if targetObjActual ~= obj.model then
                            targetObjActual = obj.model
                            usarPathfinding(objHRP.Position, VEL_NORMAL)
                        else
                            moverHacia(objHRP.Position, VEL_NORMAL)
                        end
                        task.wait(0.05)
                    end
                end
            else
                iaEstado = "IDLE"; targetObjActual = nil
                hum.WalkSpeed = VEL_NORMAL; task.wait(0.3)
            end
            if ahora - ultimoLog > 3 then
                ultimoLog = ahora
                print("🧠 Estado:", iaEstado, "| Objs:", #objetivos, "| Killer:", math.floor(dKiller))
            end
        end
    end)
end
function detenerIA()
    autoPlayIA = false; iaThread = nil
    destinoActual = nil; targetObjActual = nil
    local miChar = LocalPlayer.Character
    if miChar then
        local hum = miChar:FindFirstChildOfClass("Humanoid")
        local hrp = getHRP(miChar)
        if hum and hrp then hum:MoveTo(hrp.Position) end
    end
end

actualizarPanel()
print("✨ Fatasses Hub v40 cargado - ULTRA COOL")
