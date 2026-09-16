-- ============================================
-- BROKEN HARMONY - v17
-- Auto Patient + Auto Gen + ESP
-- ============================================
print("🚀 Iniciando...")

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local NOMBRE_GUI = "TaskGuiMap1"
local NOMBRE_GUI2 = "TaskGuiMap2"
local RADIO = 0.42
local ANGULO_ABAJO = math.pi / 2
local META = 4

local COLOR_FILL_AZUL = Color3.fromRGB(0,150,255)
local COLOR_OUTLINE_AZUL = Color3.fromRGB(0,200,255)
local COLOR_FILL_VIOLETA = Color3.fromRGB(160,60,255)
local COLOR_OUTLINE_VIOLETA = Color3.fromRGB(210,120,255)
local COLOR_PLAYER_FILL = Color3.fromRGB(255,80,140)
local COLOR_PLAYER_OUTLINE = Color3.fromRGB(255,120,170)
local COLOR_PLAYER_TRANSP = 0.55

local activo, autoGen, espActivo, espPlayersActivo = false, false, false, false

-- ============================================
-- 1. GUI
-- ============================================
pcall(function()
    for _, n in ipairs({"AutoPatientGui","AutoPatientGui2","InfStaminaGui"}) do
        local v = CoreGui:FindFirstChild(n); if v then v:Destroy() end
        local v2 = LocalPlayer.PlayerGui:FindFirstChild(n); if v2 then v2:Destroy() end
    end
end)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoPatientGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 999
screenGui.Parent = CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 260, 0, 210)
frame.Position = UDim2.new(0, 20, 0.35, 0)
frame.BackgroundColor3 = Color3.fromRGB(30,30,40)
frame.BackgroundTransparency = 0.05
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0,10); corner.Parent = frame
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255,100,100); stroke.Thickness = 2; stroke.Transparency = 0.3; stroke.Parent = frame

local titulo = Instance.new("TextLabel")
titulo.Size = UDim2.new(1,-10,0,25); titulo.Position = UDim2.new(0,5,0,5)
titulo.BackgroundTransparency = 1; titulo.Text = "Broken Harmony"
titulo.TextColor3 = Color3.fromRGB(255,255,255); titulo.TextScaled = true
titulo.Font = Enum.Font.GothamBold; titulo.Parent = frame

local function crearBtn(y, txt, colorBase)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,-20,0,30); b.Position = UDim2.new(0,10,0,y)
    b.BackgroundColor3 = colorBase or Color3.fromRGB(200,50,50); b.Text = txt
    b.TextColor3 = Color3.fromRGB(255,255,255); b.TextScaled = true
    b.Font = Enum.Font.GothamBold; b.BorderSizePixel = 0; b.Parent = frame
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,6); c.Parent = b
    return b
end

local boton = crearBtn(35, "Auto Patient: OFF")
local botonGen = crearBtn(72, "Auto Generator: OFF")
local botonESP = crearBtn(109, "ESP Objetives: OFF")
local botonPlayers = crearBtn(146, "ESP Players: OFF")

local info = Instance.new("TextLabel")
info.Size = UDim2.new(1,-10,0,15)
info.Position = UDim2.new(0,5,0,188)
info.BackgroundTransparency = 1
info.Text = "v17.0"
info.TextColor3 = Color3.fromRGB(150,150,150)
info.TextScaled = true
info.Font = Enum.Font.Gotham
info.Parent = frame

print("✅ GUI creada")

-- ============================================
-- 2. AUTO PATIENT
-- ============================================
local conexion = nil
local function iniciarAutoPatient()
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
local function detenerAutoPatient() if conexion then conexion:Disconnect(); conexion = nil end end

-- ============================================
-- 3. AUTO GENERATOR
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

local function rotarCelda(c, v)
    local img = c:FindFirstChildOfClass("ImageButton"); if not img then return end
    for _ = 1, (v or 1) do
        if firesignal then pcall(firesignal, img.MouseButton1Click) end
        task.wait(0.15)
    end
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

local conexionGen = nil
local resolviendo = false
local ultimaRes = 0

local function iniciarAutoGenerator()
    if conexionGen then return end
    conexionGen = RunService.Heartbeat:Connect(function()
        if not autoGen or resolviendo then return end
        local gui = LocalPlayer.PlayerGui:FindFirstChild(NOMBRE_GUI2)
        if not gui or not gui.Enabled then return end
        local gc = gui:FindFirstChild("GridContainer")
        if not gc or not gc.Visible then return end
        local celdas = {}
        for _, h in ipairs(gc:GetChildren()) do
            if h:IsA("Frame") and h:FindFirstChildOfClass("ImageButton") then
                table.insert(celdas, h)
            end
        end
        if #celdas < 25 then return end
        if tick() - ultimaRes < 0.5 then return end
        ultimaRes = tick()
        resolviendo = true
        task.spawn(function()
            local c = encontrarCamino(celdas)
            if c then
                for o = 1, 25 do
                    if not autoGen then break end
                    local d = c[o]
                    if d and d > 0 then
                        for _, cc in ipairs(celdas) do
                            if cc.LayoutOrder == o then rotarCelda(cc, d); break end
                        end
                    end
                    if not gc or not gc.Parent or not gc.Visible then break end
                end
            end
            resolviendo = false
        end)
    end)
end
local function detenerAutoGenerator()
    if conexionGen then conexionGen:Disconnect(); conexionGen = nil end
    resolviendo = false
end

-- ============================================
-- 4. ESP OBJETIVES
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
            c.hl.FillColor = COLOR_FILL_VIOLETA
            c.hl.OutlineColor = COLOR_OUTLINE_VIOLETA
        else
            c.hl.FillColor = COLOR_FILL_AZUL
            c.hl.OutlineColor = COLOR_OUTLINE_AZUL
        end
    end
    if completo then
        if not c.bb or not c.bb.Parent then
            local bg = Instance.new("BillboardGui")
            bg.Name = "ESP_Obj_Label"
            bg.Size = UDim2.new(0,120,0,60)
            bg.StudsOffset = Vector3.new(0,4,0)
            bg.AlwaysOnTop = true; bg.Parent = m
            local l = Instance.new("TextLabel")
            l.Name = "Text"; l.Size = UDim2.new(1,0,1,0)
            l.BackgroundTransparency = 1
            l.TextColor3 = Color3.fromRGB(210,120,255)
            l.TextStrokeTransparency = 0
            l.TextStrokeColor3 = Color3.fromRGB(60,0,100)
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
                if t == "patient" then cP = cP + 1
                else cT = cT + 1 end
            end
        end
    end
    local pC = cP >= META
    local tC = cT >= META
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

local function iniciarESP()
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

local function detenerESP()
    limpiarObj()
    conexionESP = nil
    if connAdd then connAdd:Disconnect(); connAdd = nil end
    if connRem then connRem:Disconnect(); connRem = nil end
end

-- ============================================
-- 5. ESP PLAYERS
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
    hl.FillColor = COLOR_PLAYER_FILL
    hl.OutlineColor = COLOR_PLAYER_OUTLINE
    hl.FillTransparency = COLOR_PLAYER_TRANSP
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = ch; hl.Parent = ch
    local bg = Instance.new("BillboardGui")
    bg.Name = "ESP_P_BB"
    bg.Size = UDim2.new(0,160,0,60)
    bg.StudsOffset = Vector3.new(0,3.5,0)
    bg.AlwaysOnTop = true; bg.Parent = ch
    local n = Instance.new("TextLabel")
    n.Size = UDim2.new(1,0,0.5,0); n.BackgroundTransparency = 1
    n.TextColor3 = Color3.fromRGB(255,255,255)
    n.TextStrokeTransparency = 0; n.TextStrokeColor3 = Color3.fromRGB(0,0,0)
    n.TextScaled = true; n.Font = Enum.Font.GothamBold
    n.Text = p.Name; n.Parent = bg
    local s = Instance.new("TextLabel")
    s.Name = "Salud"
    s.Size = UDim2.new(1,0,0.5,0); s.Position = UDim2.new(0,0,0.5,0)
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

local function iniciarESPPlayers()
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

local function detenerESPPlayers()
    if conexionP then conexionP:Disconnect(); conexionP = nil end
    for p in pairs(playersESP) do quitarJ(p) end
    playersESP = {}
end

-- ============================================
-- 6. TOGGLES
-- ============================================
boton.MouseButton1Click:Connect(function()
    activo = not activo
    boton.Text = activo and "Auto Patient: ON" or "Auto Patient: OFF"
    boton.BackgroundColor3 = activo and Color3.fromRGB(0,200,100) or Color3.fromRGB(200,50,50)
    if activo then iniciarAutoPatient() else detenerAutoPatient() end
end)

botonGen.MouseButton1Click:Connect(function()
    autoGen = not autoGen
    botonGen.Text = autoGen and "Auto Generator: ON" or "Auto Generator: OFF"
    botonGen.BackgroundColor3 = autoGen and Color3.fromRGB(0,200,100) or Color3.fromRGB(200,50,50)
    if autoGen then iniciarAutoGenerator() else detenerAutoGenerator() end
end)

botonESP.MouseButton1Click:Connect(function()
    espActivo = not espActivo
    botonESP.Text = espActivo and "ESP Objetives: ON" or "ESP Objetives: OFF"
    botonESP.BackgroundColor3 = espActivo and Color3.fromRGB(0,150,255) or Color3.fromRGB(200,50,50)
    if espActivo then iniciarESP() else detenerESP() end
end)

botonPlayers.MouseButton1Click:Connect(function()
    espPlayersActivo = not espPlayersActivo
    botonPlayers.Text = espPlayersActivo and "ESP Players: ON" or "ESP Players: OFF"
    botonPlayers.BackgroundColor3 = espPlayersActivo and Color3.fromRGB(255,80,140) or Color3.fromRGB(200,50,50)
    if espPlayersActivo then iniciarESPPlayers() else detenerESPPlayers() end
end)

print("🎮 Cargado v17.0 - Todo listo")
