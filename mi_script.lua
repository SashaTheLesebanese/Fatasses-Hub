-- ============================================
-- FATASSES HUB - v31 (IA Inteligente)
-- ============================================
print("🚀 Iniciando Fatasses Hub...")

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local PathfindingService = game:GetService("PathfindingService")
local LocalPlayer = Players.LocalPlayer

local NOMBRE_GUI = "TaskGuiMap1"
local NOMBRE_GUI2 = "TaskGuiMap2"
local RADIO = 0.42
local ANGULO_ABAJO = math.pi / 2
local META = 4

-- 🎨 COLORES
local COLOR_BG        = Color3.fromRGB(255, 200, 230)
local COLOR_BG_LIGHT  = Color3.fromRGB(255, 220, 240)
local COLOR_BORDER    = Color3.fromRGB(255, 0, 180)
local COLOR_HEADER    = Color3.fromRGB(255, 40, 200)
local COLOR_TAB       = Color3.fromRGB(255, 180, 220)
local COLOR_TAB_HOVER = Color3.fromRGB(240, 140, 200)
local COLOR_TAB_SEL   = Color3.fromRGB(180, 40, 140)
local COLOR_TEXT      = Color3.fromRGB(180, 0, 120)
local COLOR_CHECKBOX  = Color3.fromRGB(255, 100, 200)

local COLOR_FILL_AZUL = Color3.fromRGB(0,150,255)
local COLOR_OUTLINE_AZUL = Color3.fromRGB(0,200,255)
local COLOR_FILL_VIOLETA = Color3.fromRGB(160,60,255)
local COLOR_OUTLINE_VIOLETA = Color3.fromRGB(210,120,255)
local COLOR_PLAYER_FILL = Color3.fromRGB(255,80,140)
local COLOR_PLAYER_OUTLINE = Color3.fromRGB(255,120,170)
local COLOR_PLAYER_TRANSP = 0.55

local activo, autoGen, antiBroken, espActivo, espPlayersActivo = false, false, false, false, false
local autoPlayIA = false
local pestanaActual = "Esp"

local TODAS_PESTANAS = {"Esp", "Scientist", "Class A", "Class S", "Experiment", "Extra Stuff"}
local COMING_SOON = {
    ["Class A"] = true,
    ["Class S"] = true,
    ["Experiment"] = true,
}

-- ============================================
-- 1. LIMPIAR
-- ============================================
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

-- ============================================
-- 2. FRAME PRINCIPAL
-- ============================================
local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.new(0, 420, 0, 380)
frame.Position = UDim2.new(0.5, -210, 0.5, -190)
frame.BackgroundColor3 = COLOR_BG
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = screenGui

local frameCorner = Instance.new("UICorner"); frameCorner.CornerRadius = UDim.new(0, 12); frameCorner.Parent = frame
local frameStroke = Instance.new("UIStroke"); frameStroke.Color = COLOR_BORDER; frameStroke.Thickness = 4; frameStroke.Parent = frame

-- BARRA SUPERIOR
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, -8, 0, 30)
topBar.Position = UDim2.new(0, 4, 0, 4)
topBar.BackgroundColor3 = COLOR_HEADER
topBar.BorderSizePixel = 0
topBar.Active = true
topBar.ZIndex = 5
topBar.Parent = frame

local tbCorner = Instance.new("UICorner"); tbCorner.CornerRadius = UDim.new(0, 8); tbCorner.Parent = topBar
local tbStroke = Instance.new("UIStroke"); tbStroke.Color = COLOR_BORDER; tbStroke.Thickness = 2; tbStroke.Parent = topBar

local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(1, -8, 1, 0)
titleLbl.Position = UDim2.new(0, 4, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "Fatasses Hub"
titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLbl.TextScaled = true
titleLbl.Font = Enum.Font.GothamBlack
titleLbl.TextStrokeTransparency = 0
titleLbl.TextStrokeColor3 = Color3.fromRGB(180, 0, 120)
titleLbl.ZIndex = 6
titleLbl.Parent = topBar

-- DRAG
local dragging = false
local dragStart, startPos
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

-- SIDEBAR
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 110, 1, -44)
sidebar.Position = UDim2.new(0, 4, 0, 38)
sidebar.BackgroundColor3 = COLOR_BG_LIGHT
sidebar.BorderSizePixel = 0
sidebar.ZIndex = 2
sidebar.Parent = frame

local sbCorner = Instance.new("UICorner"); sbCorner.CornerRadius = UDim.new(0, 10); sbCorner.Parent = sidebar
local sbStroke = Instance.new("UIStroke"); sbStroke.Color = COLOR_BORDER; sbStroke.Thickness = 2; sbStroke.Parent = sidebar

-- PANEL
local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.new(0, 296, 1, -44)
panel.Position = UDim2.new(0, 118, 0, 38)
panel.BackgroundColor3 = COLOR_BG_LIGHT
panel.BorderSizePixel = 0
panel.ZIndex = 2
panel.Parent = frame

local pCorner = Instance.new("UICorner"); pCorner.CornerRadius = UDim.new(0, 10); pCorner.Parent = panel
local pStroke = Instance.new("UIStroke"); pStroke.Color = COLOR_BORDER; pStroke.Thickness = 2; pStroke.Parent = panel

local opcionesContainer = Instance.new("ScrollingFrame")
opcionesContainer.Name = "Opciones"
opcionesContainer.Size = UDim2.new(1, -8, 1, -8)
opcionesContainer.Position = UDim2.new(0, 4, 0, 4)
opcionesContainer.BackgroundTransparency = 1
opcionesContainer.BorderSizePixel = 0
opcionesContainer.ScrollBarThickness = 4
opcionesContainer.ScrollBarImageColor3 = COLOR_BORDER
opcionesContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
opcionesContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
opcionesContainer.ZIndex = 3
opcionesContainer.Parent = panel

local layoutOpc = Instance.new("UIListLayout")
layoutOpc.Padding = UDim.new(0, 8)
layoutOpc.SortOrder = Enum.SortOrder.LayoutOrder
layoutOpc.Parent = opcionesContainer

local padOpc = Instance.new("UIPadding")
padOpc.PaddingTop = UDim.new(0, 8)
padOpc.PaddingBottom = UDim.new(0, 8)
padOpc.PaddingLeft = UDim.new(0, 6)
padOpc.PaddingRight = UDim.new(0, 6)
padOpc.Parent = opcionesContainer

-- ============================================
-- 3. TABS
-- ============================================
local tabsRefs = {}

local function crearTab(nombre, yPos, comingSoon)
    local tab = Instance.new("TextButton")
    tab.Name = "Tab_" .. nombre
    tab.Size = UDim2.new(1, -8, 0, 45)
    tab.Position = UDim2.new(0, 4, 0, yPos)
    tab.BackgroundColor3 = COLOR_TAB
    tab.Text = ""
    tab.BorderSizePixel = 0
    tab.AutoButtonColor = false
    tab.ZIndex = 4
    tab.Parent = sidebar

    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 8); c.Parent = tab
    local s = Instance.new("UIStroke"); s.Color = COLOR_BORDER; s.Thickness = 2; s.Parent = tab

    local lbl = Instance.new("TextLabel")
    if comingSoon then
        lbl.Size = UDim2.new(1, -8, 0, 24); lbl.Position = UDim2.new(0, 4, 0, 2)
    else
        lbl.Size = UDim2.new(1, -8, 1, 0); lbl.Position = UDim2.new(0, 4, 0, 0)
    end
    lbl.BackgroundTransparency = 1
    lbl.Text = nombre
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.TextScaled = true
    lbl.Font = Enum.Font.GothamBlack
    lbl.TextStrokeTransparency = 0
    lbl.TextStrokeColor3 = Color3.fromRGB(180, 0, 120)
    lbl.ZIndex = 5
    lbl.Parent = tab

    if comingSoon then
        local cs = Instance.new("TextLabel")
        cs.Size = UDim2.new(1, -8, 0, 16); cs.Position = UDim2.new(0, 4, 0, 26)
        cs.BackgroundTransparency = 1
        cs.Text = "(Coming Soon)"
        cs.TextColor3 = Color3.fromRGB(200, 0, 0)
        cs.TextScaled = true
        cs.Font = Enum.Font.GothamBold
        cs.TextStrokeTransparency = 0
        cs.TextStrokeColor3 = Color3.fromRGB(255, 200, 200)
        cs.ZIndex = 5
        cs.Parent = tab
    end

    tab.MouseEnter:Connect(function()
        if pestanaActual ~= nombre then tab.BackgroundColor3 = COLOR_TAB_HOVER end
    end)
    tab.MouseLeave:Connect(function()
        if pestanaActual ~= nombre then tab.BackgroundColor3 = COLOR_TAB end
    end)

    tab.MouseButton1Click:Connect(function()
        if comingSoon then return end
        if tabsRefs[pestanaActual] then tabsRefs[pestanaActual].Button.BackgroundColor3 = COLOR_TAB end
        pestanaActual = nombre
        tab.BackgroundColor3 = COLOR_TAB_SEL
        actualizarPanel()
    end)

    tabsRefs[nombre] = {Button = tab, ComingSoon = comingSoon}
end

for i, nombre in ipairs(TODAS_PESTANAS) do
    local y = 4 + (i - 1) * 49
    crearTab(nombre, y, COMING_SOON[nombre])
end

if tabsRefs["Esp"] then tabsRefs["Esp"].Button.BackgroundColor3 = COLOR_TAB_SEL end

-- ============================================
-- 4. OPCIONES CON CHECKBOX
-- ============================================
local function crearOpcion(nombre, callback)
    local opt = Instance.new("Frame")
    opt.Name = "Opt_" .. nombre
    opt.Size = UDim2.new(1, 0, 0, 60)
    opt.BackgroundTransparency = 1
    opt.ZIndex = 3
    opt.Parent = opcionesContainer

    local checkbox = Instance.new("TextButton")
    checkbox.Name = "Checkbox"
    checkbox.Size = UDim2.new(0, 46, 0, 46)
    checkbox.Position = UDim2.new(0, 8, 0, 7)
    checkbox.BackgroundColor3 = COLOR_CHECKBOX
    checkbox.Text = ""
    checkbox.BorderSizePixel = 0
    checkbox.AutoButtonColor = false
    checkbox.ZIndex = 4
    checkbox.Parent = opt

    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 4); c.Parent = checkbox
    local s = Instance.new("UIStroke"); s.Color = COLOR_BORDER; s.Thickness = 3; s.Parent = checkbox

    local checkMark = Instance.new("TextLabel")
    checkMark.Name = "CheckMark"
    checkMark.Size = UDim2.new(1, 0, 1, 0)
    checkMark.BackgroundTransparency = 1
    checkMark.Text = ""
    checkMark.TextColor3 = Color3.fromRGB(255, 255, 255)
    checkMark.TextScaled = true
    checkMark.Font = Enum.Font.GothamBlack
    checkMark.TextStrokeTransparency = 0
    checkMark.TextStrokeColor3 = Color3.fromRGB(150, 0, 100)
    checkMark.ZIndex = 10
    checkMark.Parent = checkbox

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -70, 1, 0)
    label.Position = UDim2.new(0, 62, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = nombre
    label.TextColor3 = COLOR_TEXT
    label.TextScaled = true
    label.Font = Enum.Font.GothamBlack
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 4
    label.Parent = opt

    local function actualizarVisual(act)
        if act then
            checkMark.Text = "✓"
            checkbox.BackgroundColor3 = Color3.fromRGB(255, 60, 200)
            label.TextColor3 = Color3.fromRGB(255, 0, 150)
        else
            checkMark.Text = ""
            checkbox.BackgroundColor3 = COLOR_CHECKBOX
            label.TextColor3 = COLOR_TEXT
        end
    end

    local estado = false
    checkbox.MouseButton1Click:Connect(function()
        estado = not estado
        actualizarVisual(estado)
        if callback then callback(estado) end
    end)
    label.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            estado = not estado
            actualizarVisual(estado)
            if callback then callback(estado) end
        end
    end)
    label.Active = true
end

function actualizarPanel()
    for _, hijo in ipairs(opcionesContainer:GetChildren()) do
        if not hijo:IsA("UIListLayout") and not hijo:IsA("UIPadding") then
            hijo:Destroy()
        end
    end

    if pestanaActual == "Esp" then
        crearOpcion("Esp Tasks", function(v)
            espActivo = v
            if v then iniciarESP() else detenerESP() end
        end)
        crearOpcion("Esp Players (Health)", function(v)
            espPlayersActivo = v
            if v then iniciarESPPlayers() else detenerESPPlayers() end
        end)
    elseif pestanaActual == "Scientist" then
        crearOpcion("Auto Patient", function(v)
            activo = v
            if v then iniciarAutoPatient() else detenerAutoPatient() end
        end)
        crearOpcion("Auto Generators", function(v)
            autoGen = v
            if v then iniciarAutoGenerator() else detenerAutoGenerator() end
        end)
        crearOpcion("Anti Broken pipes", function(v)
            antiBroken = v
            if v then iniciarAntiBroken() else detenerAntiBroken() end
        end)
    elseif pestanaActual == "Extra Stuff" then
        crearOpcion("Scientist AI Auto Play", function(v)
            autoPlayIA = v
            if v then iniciarAutoPlayIA() else detenerAutoPlayIA() end
        end)
    end
end

-- ============================================
-- 5. BOTÓN CIRCULAR "S"
-- ============================================
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleBtn"
toggleBtn.Size = UDim2.new(0, 60, 0, 60)
toggleBtn.Position = UDim2.new(0, 20, 0.6, 0)
toggleBtn.BackgroundColor3 = COLOR_HEADER
toggleBtn.Text = "S"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextScaled = true
toggleBtn.Font = Enum.Font.GothamBlack
toggleBtn.TextStrokeTransparency = 0
toggleBtn.TextStrokeColor3 = Color3.fromRGB(180, 0, 120)
toggleBtn.BorderSizePixel = 0
toggleBtn.AutoButtonColor = false
toggleBtn.Active = true
toggleBtn.Parent = screenGui

local toggleCorner = Instance.new("UICorner"); toggleCorner.CornerRadius = UDim.new(1, 0); toggleCorner.Parent = toggleBtn
local toggleStroke = Instance.new("UIStroke"); toggleStroke.Color = COLOR_BORDER; toggleStroke.Thickness = 3; toggleStroke.Parent = toggleBtn

toggleBtn.MouseEnter:Connect(function() toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 220) end)
toggleBtn.MouseLeave:Connect(function() toggleBtn.BackgroundColor3 = COLOR_HEADER end)
toggleBtn.MouseButton1Click:Connect(function() frame.Visible = not frame.Visible end)

local draggingT = false
local dragStartT, startPosT
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
-- 6. AUTO PATIENT
-- ============================================
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

-- ============================================
-- 7. AUTO GENERATOR (instante)
-- ============================================
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
        local x, y = xyDeOrder(c.LayoutOrder)
        mapa[x] = mapa[x] or {}; mapa[x][y] = c
    end
    local c1 = mapa[0] and mapa[0][0]
    local c25 = mapa[4] and mapa[4][4]
    if not c1 or not c25 then return nil end
    local l1 = ladosAbiertos(c1)
    if #l1 ~= 1 or (l1[1] ~= 1 and l1[1] ~= 2) then return nil end
    local l25 = ladosAbiertos(c25)
    if #l25 ~= 1 or (l25[1] ~= 0 and l25[1] ~= 3) then return nil end

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
            local ls = l1[1]
            local dx, dy = DIRV[ls][1], DIRV[ls][2]
            local nx, ny = x+dx, y+dy
            if nx>=0 and nx<5 and ny>=0 and ny<5 then
                local v = mapa[nx] and mapa[nx][ny]
                if v and not esRota(v) then
                    local lo = OPUESTO[ls+1]
                    camino[order] = 0
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
                            local lo = OPUESTO[ls+1]
                            camino[order] = d
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
    if not camino then print("❌ No se encontró camino"); return false end

    for o = 1, 25 do
        local d = camino[o]
        if d and d > 0 then
            for _, c in ipairs(celdas) do
                if c.LayoutOrder == o then
                    local img = c:FindFirstChildOfClass("ImageButton")
                    if img then
                        local rotActual = img:GetAttribute("TargetRotation") or img.Rotation
                        local nuevaRot = rotActual + d * 90
                        img:SetAttribute("TargetRotation", nuevaRot)
                        img.Rotation = nuevaRot
                    end
                    break
                end
            end
        end
    end

    local triggerCell = nil
    local triggerNeeded = nil
    for o = 2, 24 do
        local d = camino[o] or 0
        for _, c in ipairs(celdas) do
            if c.LayoutOrder == o then
                if d > 0 then triggerCell = c; triggerNeeded = d; break end
                if not triggerCell then triggerCell = c; triggerNeeded = 0 end
                break
            end
        end
        if triggerNeeded and triggerNeeded > 0 then break end
    end

    if triggerCell then
        local img = triggerCell:FindFirstChildOfClass("ImageButton")
        if img then
            local rotActual = img:GetAttribute("TargetRotation") or img.Rotation
            img:SetAttribute("TargetRotation", rotActual - 90)
            img.Rotation = rotActual - 90
            if firesignal then pcall(firesignal, img.MouseButton1Click) end
        end
    end
    print("⚡ Auto Generator: puzzle resuelto")
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
            if h:IsA("Frame") and h:FindFirstChildOfClass("ImageButton") then
                table.insert(celdas, h)
            end
        end
        if #celdas < 25 then return end
        table.sort(celdas, function(a, b) return a.LayoutOrder < b.LayoutOrder end)

        resolviendo = true
        ultimoGrid = gc
        task.spawn(function()
            task.wait(0.3)
            if autoGen then resolverInstantaneo(celdas) end
            resolviendo = false
        end)
    end)
end

function detenerAutoGenerator()
    if conexionGen then conexionGen:Disconnect(); conexionGen = nil end
    resolviendo = false; ultimoGrid = nil
end

-- ============================================
-- 8. ANTI BROKEN PARTS
-- ============================================
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
                local isBroken = celda:FindFirstChild("IsBroken")
                if isBroken then isBroken:Destroy() end
                local overlay = celda:FindFirstChild("BrokenOverlay")
                if overlay then overlay:Destroy() end
            end
        end
    end)
end
function detenerAntiBroken()
    if conexionAntiBroken then conexionAntiBroken:Disconnect(); conexionAntiBroken = nil end
end

-- ============================================
-- 9. ESP OBJETIVES
-- ============================================
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
        hl.Name = "ESP_Obj_HL"
        hl.FillTransparency = 0.5
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Adornee = m; hl.Parent = m
        c = {hl=hl, bb=nil, completo=false}
        cacheObj[m] = c
    end
    if c.completo ~= completo then
        c.completo = completo
        if completo then
            c.hl.FillColor = COLOR_FILL_VIOLETA; c.hl.OutlineColor = COLOR_OUTLINE_VIOLETA
        else
            c.hl.FillColor = COLOR_FILL_AZUL; c.hl.OutlineColor = COLOR_OUTLINE_AZUL
        end
    end
    if completo then
        if not c.bb or not c.bb.Parent then
            local bg = Instance.new("BillboardGui")
            bg.Name = "ESP_Obj_Label"
            bg.Size = UDim2.new(0,120,0,60); bg.StudsOffset = Vector3.new(0,4,0)
            bg.AlwaysOnTop = true; bg.Parent = m
            local l = Instance.new("TextLabel")
            l.Name = "Text"; l.Size = UDim2.new(1,0,1,0)
            l.BackgroundTransparency = 1
            l.TextColor3 = Color3.fromRGB(210,120,255)
            l.TextStrokeTransparency = 0; l.TextStrokeColor3 = Color3.fromRGB(60,0,100)
            l.TextScaled = true; l.Font = Enum.Font.GothamBold
            l.Text = conteo .. "/" .. META; l.Parent = bg
            c.bb = bg
        else
            local lbl = c.bb:FindFirstChild("Text")
            if lbl then
                local nt = conteo .. "/" .. META
                if lbl.Text ~= nt then lbl.Text = nt end
            end
        end
    else
        if c.bb then c.bb:Destroy(); c.bb = nil end
    end
end

local function escanear()
    if escaneando then return end
    escaneando = true
    local cP, cT = 0, 0
    local encontrados = {}
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
        while espActivo do
            task.wait(2)
            if espActivo then escanear() end
        end
    end)
    connAdd = Workspace.DescendantAdded:Connect(function(o)
        if not espActivo then return end
        if o:IsA("Model") and tipoObj(o) then
            task.wait(0.3)
            if espActivo then escanear() end
        end
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
    limpiarObj()
    conexionESP = nil
    if connAdd then connAdd:Disconnect(); connAdd = nil end
    if connRem then connRem:Disconnect(); connRem = nil end
end

-- ============================================
-- 10. ESP PLAYERS
-- ============================================
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
    hl.Name = "ESP_P_HL"
    hl.FillColor = COLOR_PLAYER_FILL; hl.OutlineColor = COLOR_PLAYER_OUTLINE
    hl.FillTransparency = COLOR_PLAYER_TRANSP; hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = ch; hl.Parent = ch
    local bg = Instance.new("BillboardGui")
    bg.Name = "ESP_P_BB"
    bg.Size = UDim2.new(0,160,0,60); bg.StudsOffset = Vector3.new(0,3.5,0)
    bg.AlwaysOnTop = true; bg.Parent = ch
    local n = Instance.new("TextLabel")
    n.Size = UDim2.new(1,0,0.5,0); n.BackgroundTransparency = 1
    n.TextColor3 = Color3.fromRGB(255,255,255)
    n.TextStrokeTransparency = 0; n.TextStrokeColor3 = Color3.fromRGB(0,0,0)
    n.TextScaled = true; n.Font = Enum.Font.GothamBold
    n.Text = p.Name; n.Parent = bg
    local s = Instance.new("TextLabel")
    s.Name = "Salud"; s.Size = UDim2.new(1,0,0.5,0); s.Position = UDim2.new(0,0,0.5,0)
    s.BackgroundTransparency = 1
    s.TextColor3 = Color3.fromRGB(0,255,100)
    s.TextStrokeTransparency = 0; s.TextStrokeColor3 = Color3.fromRGB(0,0,0)
    s.TextScaled = true; s.Font = Enum.Font.GothamBold
    s.Text = "100 / 100"; s.Parent = bg
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
        p.CharacterAdded:Connect(function()
            task.wait(0.3)
            if espPlayersActivo then crearJ(p) end
        end)
    end)
    Players.PlayerRemoving:Connect(quitarJ)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            p.CharacterAdded:Connect(function()
                if not espPlayersActivo then return end
                task.wait(0.3)
                if espPlayersActivo then crearJ(p) end
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
                    if d.char ~= ch or not d.hl or not d.hl.Parent then
                        crearJ(p); d = playersESP[p]
                    end
                    if d and d.lbl then
                        local hum = ch:FindFirstChildOfClass("Humanoid")
                        if hum then
                            local hp = math.floor(hum.Health)
                            local mx = math.floor(hum.MaxHealth)
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

-- ============================================
-- 11. 🤖 SCIENTIST IA AUTO PLAY (Extra Stuff)
-- ============================================
local iaThread = nil
local iaEstado = "IDLE"  -- IDLE, SEARCH, MOVE, INTERACT, FLEE, JUKE, DOOR
local objetivoIA = nil
local ultimoStuck = 0
local ultimaPos = Vector3.new(0,0,0)
local tiempoStuck = 0
local puertasCerradas = {}
local cooldownInteract = 0
local estadosHistorial = {}

-- Configs de distancia
local DIST_CORRER = 75
local DIST_HUIR = 50
local DIST_JUKE = 20
local DIST_STUCK = 3       -- si se mueve menos de 3 studs en 1.5s = stuck

-- Detectar scripts
local function tieneScriptsIA(m)
    if not m then return false end
    for _, h in ipairs(m:GetChildren()) do
        if h:IsA("Script") or h:IsA("LocalScript") then return true end
    end
    return false
end

-- Obtener HRP o PrimaryPart
local function getHRP(obj)
    if not obj then return nil end
    return obj:FindFirstChild("HumanoidRootPart") 
        or obj:FindFirstChild("Head") 
        or obj:FindFirstChild("UpperTorso")
        or obj.PrimaryPart 
        or obj:FindFirstChildWhichIsA("BasePart")
end

-- Distancia
local function getDist(a, b)
    local pa, pb = getHRP(a), getHRP(b)
    if not pa or not pb then return math.huge end
    return (pa.Position - pb.Position).Magnitude
end

-- Encontrar killer (jugador más alto)
local function encontrarKiller()
    local killer, alturaMax = nil, 0
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local ext = p.Character:GetExtentsSize()
                if ext.Y > alturaMax then
                    alturaMax = ext.Y
                    killer = p.Character
                end
            end
        end
    end
    return killer
end

-- Buscar objetivos Patient/Tube con Script + ProximityPrompt
local function buscarObjetivosIA()
    local lista = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and tieneScriptsIA(obj) then
            local n = string.lower(obj.Name)
            if string.find(n, "patient", 1, true) or string.find(n, "tube", 1, true) then
                local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                if prompt and prompt.Enabled then
                    table.insert(lista, {model = obj, prompt = prompt})
                end
            end
        end
    end
    return lista
end

-- Buscar puertas con E to interact
local function buscarPuertasIA()
    local lista = {}
    for _, p in ipairs(Workspace:GetDescendants()) do
        if p:IsA("ProximityPrompt") then
            local at = string.lower(p.ActionText or "")
            local ot = string.lower(p.ObjectText or "")
            if string.find(at, "open") or string.find(at, "close") or string.find(ot, "door") then
                local parte = p.Parent
                if not parte:IsA("BasePart") then
                    parte = p.Parent:FindFirstChildWhichIsA("BasePart", true)
                end
                if parte then
                    table.insert(lista, {prompt = p, parte = parte})
                end
            end
        end
    end
    return lista
end

-- Usar prompt (E)
local function usarPromptIA(prompt)
    if not prompt or not prompt.Enabled then return false end
    local ok = pcall(function()
        prompt:InputHoldBegin()
        task.wait((prompt.HoldDuration or 0) + 0.05)
        prompt:InputHoldEnd()
    end)
    return ok
end

-- Cerrar puertas atrás (durante huida)
local function cerrarPuertasDetrasIA()
    local miChar = LocalPlayer.Character
    if not miChar then return end
    local hrp = getHRP(miChar)
    if not hrp then return end
    for _, info in ipairs(buscarPuertasIA()) do
        if (info.parte.Position - hrp.Position).Magnitude <= 10 then
            -- Evitar spamear la misma puerta
            local key = tostring(info.parte)
            if not puertasCerradas[key] or tick() - puertasCerradas[key] > 3 then
                usarPromptIA(info.prompt)
                puertasCerradas[key] = tick()
            end
        end
    end
end

-- Wall detector: hay pared bloqueando?
local function hayParedAdelante(distCheck)
    local miChar = LocalPlayer.Character
    if not miChar then return false end
    local hrp = getHRP(miChar)
    if not hrp then return false end
    local look = hrp.CFrame.LookVector
    local origen = hrp.Position
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {miChar}
    local ray = Workspace:Raycast(origen, look * (distCheck or 6), params)
    return ray ~= nil
end

-- Caminar con Pathfinding a un punto
local function caminarIA(destino, velocidad, ignorarPuertas)
    local miChar = LocalPlayer.Character
    if not miChar then return end
    local hum = miChar:FindFirstChildOfClass("Humanoid")
    local hrp = getHRP(miChar)
    if not hum or not hrp then return end

    hum.WalkSpeed = velocidad or 16

    -- Pathfinding
    local path = PathfindingService:CreatePath({
        AgentRadius = 2, AgentHeight = 5, AgentCanJump = true, WaypointSpacing = 4,
    })

    local ok = pcall(function() path:ComputeAsync(hrp.Position, destino) end)
    if not ok or path.Status ~= Enum.PathStatus.Success then
        hum:MoveTo(destino)
        return
    end

    for _, wp in ipairs(path:GetWaypoints()) do
        if not autoPlayIA then return end
        if wp.Action == Enum.PathWaypointAction.Jump then hum.Jump = true end
        hum:MoveTo(wp.Position)
        local t = 0
        while t < 1.5 do
            if not autoPlayIA then return end
            -- Revisar killer mientras camina
            local killer = encontrarKiller()
            if killer and getDist(miChar, killer) <= DIST_JUKE then
                return  -- abortar, prioridad = huir
            end
            if (hrp.Position - wp.Position).Magnitude < 3 then break end
            -- Si hay pared, abrir puerta
            if hayParedAdelante(5) then
                local puertas = buscarPuertasIA()
                for _, info in ipairs(puertas) do
                    if (info.parte.Position - hrp.Position).Magnitude < 8 then
                        usarPromptIA(info.prompt)
                        break
                    end
                end
            end
            task.wait(0.08); t = t + 0.08
        end
    end
end

-- Juke (correr perpendicular)
local function hacerJukeIA(killer)
    local miChar = LocalPlayer.Character
    if not miChar then return end
    local hrp = getHRP(miChar)
    local kHRP = getHRP(killer)
    if not hrp or not kHRP then return end

    local dir = (hrp.Position - kHRP.Position)
    dir = Vector3.new(dir.X, 0, dir.Z).Unit
    local perp = Vector3.new(-dir.Z, 0, dir.X)
    if math.random() < 0.5 then perp = -perp end

    -- Raycast para ver si hay pared en dirección del juke
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {miChar}
    local rayDer = Workspace:Raycast(hrp.Position, perp * 20, params)
    local rayIzq = Workspace:Raycast(hrp.Position, -perp * 20, params)
    -- Elegir lado libre
    if rayDer then perp = -perp end
    if rayIzq then perp = -perp end

    local destino = hrp.Position + perp * 30 + dir * 15
    caminarIA(destino, 26)
end

-- Stuck detection
local function detectarStuck(dt)
    local miChar = LocalPlayer.Character
    if not miChar then return false end
    local hrp = getHRP(miChar)
    if not hrp then return false end
    local mov = (hrp.Position - ultimaPos).Magnitude
    ultimaPos = hrp.Position
    if mov < DIST_STUCK * dt then
        tiempoStuck = tiempoStuck + dt
    else
        tiempoStuck = 0
    end
    if tiempoStuck > 1.5 then
        tiempoStuck = 0
        return true
    end
    return false
end

-- Decidir estado según el killer
local function decidirEstado(miChar)
    local killer = encontrarKiller()
    if not killer then return "IDLE", nil, math.huge end
    local dKiller = getDist(miChar, killer)
    if dKiller <= DIST_JUKE then return "JUKE", killer, dKiller end
    if dKiller <= DIST_HUIR then return "FLEE", killer, dKiller end
    return "NORMAL", killer, dKiller
end

-- 🧠 LOOP PRINCIPAL DE LA IA
function iniciarAutoPlayIA()
    if iaThread then return end
    print("🧠 Scientist IA Auto Play ON")

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
            if not hum or hum.Health <= 0 or not hrp then
                task.wait(1); continue
            end

            -- 1) Detectar killer y decidir estado base
            local killer = encontrarKiller()
            local dKiller = killer and getDist(miChar, killer) or math.huge

            -- 2) PRIORIDAD 1: Juke si está muy cerca
            if killer and dKiller <= DIST_JUKE then
                iaEstado = "JUKE"
                hacerJukeIA(killer)
                task.wait(0.1)
                continue
            end

            -- 3) PRIORIDAD 2: Huir si está cerca
            if killer and dKiller <= DIST_HUIR then
                iaEstado = "FLEE"
                local kHRP = getHRP(killer)
                if kHRP then
                    local dir = (hrp.Position - kHRP.Position)
                    dir = Vector3.new(dir.X, 0, dir.Z).Unit
                    local destino = hrp.Position + dir * 40
                    caminarIA(destino, 22)
                end
                cerrarPuertasDetrasIA()
                task.wait(0.15)
                continue
            end

            -- 4) PRIORIDAD 3: Correr pero seguir con objetivos (75 studs)
            local velocidadActual = (killer and dKiller <= DIST_CORRER) and 22 or 16

            -- 5) Stuck detection
            if detectarStuck(dt) then
                -- Está atascado → intentar mover perpendicular
                iaEstado = "UNSTUCK"
                local perp = Vector3.new(-hrp.CFrame.LookVector.Z, 0, hrp.CFrame.LookVector.X)
                local destino = hrp.Position + perp * 15
                hum:MoveTo(destino)
                task.wait(0.4)
                continue
            end

            -- 6) Buscar objetivo actual
            local objetivos = buscarObjetivosIA()
            local mejorObj, mejorDist = nil, math.huge
            for _, o in ipairs(objetivos) do
                local d = getDist(miChar, o.model)
                if d < mejorDist then
                    mejorDist = d
                    mejorObj = o
                end
            end

            if mejorObj then
                iaEstado = "MOVE_OBJ"
                if mejorDist > 6 then
                    local target = getHRP(mejorObj.model)
                    if target then
                        caminarIA(target.Position, velocidadActual)
                    end
                else
                    -- Interactuar
                    iaEstado = "INTERACT"
                    if tick() - cooldownInteract > 0.3 then
                        usarPromptIA(mejorObj.prompt)
                        cooldownInteract = tick()
                        task.wait(0.4)
                    end
                end
            else
                -- No hay objetivos → buscar puertas para explorar
                iaEstado = "SEARCH"
                local puertas = buscarPuertasIA()
                local mejorPuerta, mejorDistP = nil, math.huge
                for _, p in ipairs(puertas) do
                    local d = (p.parte.Position - hrp.Position).Magnitude
                    if d > 3 and d < mejorDistP then
                        mejorDistP = d
                        mejorPuerta = p
                    end
                end
                if mejorPuerta then
                    caminarIA(mejorPuerta.parte.Position, velocidadActual)
                    if mejorDistP < 8 then
                        usarPromptIA(mejorPuerta.prompt)
                    end
                else
                    -- No hay nada → caminar random
                    hum:MoveTo(hrp.Position + Vector3.new(math.random(-30,30), 0, math.random(-30,30)))
                end
            end

            task.wait(0.15)
        end
        print("🛑 IA detenida")
    end)
end

function detenerAutoPlayIA()
    autoPlayIA = false
    iaThread = nil
    local miChar = LocalPlayer.Character
    if miChar then
        local hum = miChar:FindFirstChildOfClass("Humanoid")
        local hrp = getHRP(miChar)
        if hum and hrp then hum:MoveTo(hrp.Position) end
    end
    print("❌ Scientist IA OFF")
end

-- ============================================
-- INICIALIZAR
-- ============================================
actualizarPanel()
print("🎮 Fatasses Hub v31 cargado - IA lista")
