local Library = {}
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Workspace = workspace
local LocalPlayer = Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")

local ACCENT = Color3.fromRGB(34, 197, 94)
local BG = Color3.fromRGB(10, 10, 10)
local BG2 = Color3.fromRGB(18, 18, 18)
local BORDER = Color3.fromRGB(40, 40, 40)
local TEXT = Color3.fromRGB(230, 230, 230)
local MUTED = Color3.fromRGB(140, 140, 140)
local RED = Color3.fromRGB(239, 68, 68)

local function getHiddenParent()
    if gethui then
        local ok, h = pcall(gethui)
        if ok and h then return h end
    end
    local ok = pcall(function() CoreGui.Name = CoreGui.Name end)
    if ok then return CoreGui end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local function new(class, props, par)
    local o = Instance.new(class)
    for k, v in pairs(props) do o[k] = v end
    if par then o.Parent = par end
    return o
end

local ESP = { Enabled = false, Pool = {}, RenderName = nil }

local function HSX_DrawingAvailable()
    local D = nil
    pcall(function() D = Drawing end)
    if D == nil and typeof(getgenv) == "function" then
        pcall(function() D = getgenv().Drawing end)
    end
    return D ~= nil and typeof(D.new) == "function", D
end

local function HSX_ESP_NewDrawings(color)
    local has, D = HSX_DrawingAvailable()
    if not has then return nil end
    local function NL(c, th, z)
        local L = D.new("Line")
        L.Visible = false
        L.Color = c
        L.Thickness = th
        L.ZIndex = z or 1
        return L
    end
    local function NT(c, sz, z)
        local T = D.new("Text")
        T.Visible = false
        T.Color = c
        T.Size = sz
        T.Center = true
        T.Outline = true
        T.Font = 2
        T.ZIndex = z or 4
        return T
    end
    local function NS(c, a, z)
        local S = D.new("Square")
        S.Visible = false
        S.Color = c
        S.Filled = false
        S.Transparency = 1 - a
        S.Thickness = 1
        S.ZIndex = z or 1
        return S
    end
    local box = {
        Fill = NS(color, 0.88, 1),
        Outline = { Top = NL(Color3.new(0, 0, 0), 3, 2), Bottom = NL(Color3.new(0, 0, 0), 3, 2), Left = NL(Color3.new(0, 0, 0), 3, 2), Right = NL(Color3.new(0, 0, 0), 3, 2) },
        Box = { Top = NL(color, 1, 3), Bottom = NL(color, 1, 3), Left = NL(color, 1, 3), Right = NL(color, 1, 3) },
        Name = NT(color, 14, 6),
        Distance = NT(Color3.new(1, 1, 1), 12, 5),
        HealthBg = NL(Color3.fromRGB(20, 20, 20), 6, 4),
        HealthFill = NL(Color3.fromRGB(0, 255, 0), 4, 4),
        Shown = false,
    }
    box.All = { box.Fill, box.Name, box.Distance, box.HealthBg, box.HealthFill }
    for _, v in pairs(box.Outline) do table.insert(box.All, v) end
    for _, v in pairs(box.Box) do table.insert(box.All, v) end
    return box
end

local function HSX_ESP_Hide(box)
    if not box or not box.Shown then return end
    box.Shown = false
    for _, d in ipairs(box.All) do d.Visible = false end
end

local function HSX_ESP_Destroy(box)
    if not box then return end
    for _, d in ipairs(box.All or {}) do pcall(function() d:Remove() end) end
end

local function HSX_ESP_UpdateBox(box, cf, size, color, name, dist, hp, maxHp)
    local cam = Workspace.CurrentCamera
    if not cam then HSX_ESP_Hide(box); return end
    local corners = {
        Vector3.new(size.X / 2, size.Y / 2, size.Z / 2), Vector3.new(-size.X / 2, size.Y / 2, size.Z / 2),
        Vector3.new(size.X / 2, -size.Y / 2, size.Z / 2), Vector3.new(-size.X / 2, -size.Y / 2, size.Z / 2),
        Vector3.new(size.X / 2, size.Y / 2, -size.Z / 2), Vector3.new(-size.X / 2, size.Y / 2, -size.Z / 2),
        Vector3.new(size.X / 2, -size.Y / 2, -size.Z / 2), Vector3.new(-size.X / 2, -size.Y / 2, -size.Z / 2),
    }
    local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
    local any = false
    for _, off in ipairs(corners) do
        local wp = cf:PointToWorldSpace(off)
        local sp, onScreen = cam:WorldToViewportPoint(wp)
        if onScreen and sp.Z > 0 then
            any = true
            if sp.X < minX then minX = sp.X end
            if sp.Y < minY then minY = sp.Y end
            if sp.X > maxX then maxX = sp.X end
            if sp.Y > maxY then maxY = sp.Y end
        end
    end
    if not any then HSX_ESP_Hide(box); return end
    box.Shown = true
    local function setLine(L, a, b)
        L.From = Vector2.new(a.X, a.Y)
        L.To = Vector2.new(b.X, b.Y)
        L.Visible = true
        L.Color = color
    end
    local tl, tr, bl, br = Vector2.new(minX, minY), Vector2.new(maxX, minY), Vector2.new(minX, maxY), Vector2.new(maxX, maxY)
    setLine(box.Box.Top, tl, tr)
    setLine(box.Box.Bottom, bl, br)
    setLine(box.Box.Left, tl, bl)
    setLine(box.Box.Right, tr, br)
    setLine(box.Outline.Top, tl, tr)
    setLine(box.Outline.Bottom, bl, br)
    setLine(box.Outline.Left, tl, bl)
    setLine(box.Outline.Right, tr, br)
    box.Name.Text = tostring(name or "")
    box.Name.Position = Vector2.new((minX + maxX) / 2, minY - 16)
    box.Name.Visible = true
    box.Name.Color = color
    box.Distance.Text = string.format("%dm", math.floor(dist or 0))
    box.Distance.Position = Vector2.new((minX + maxX) / 2, maxY + 2)
    box.Distance.Visible = true
    local ratio = 1
    if maxHp and maxHp > 0 and hp then ratio = math.clamp(hp / maxHp, 0, 1) end
    local hx = minX - 6
    box.HealthBg.From = Vector2.new(hx, minY)
    box.HealthBg.To = Vector2.new(hx, maxY)
    box.HealthBg.Visible = true
    box.HealthFill.From = Vector2.new(hx, maxY - (maxY - minY) * ratio)
    box.HealthFill.To = Vector2.new(hx, maxY)
    box.HealthFill.Visible = true
    box.HealthFill.Color = Color3.fromRGB(255 * (1 - ratio), 255 * ratio, 0)
end

function Library:ToggleESP(enabled, hnsMode)
    ESP.Enabled = enabled
    local pool = ESP.Pool
    if not enabled then
        if ESP.RenderName then
            pcall(function() RunService:UnbindFromRenderStep(ESP.RenderName) end)
            ESP.RenderName = nil
        end
        for key, box in pairs(pool) do
            HSX_ESP_Destroy(box)
            pool[key] = nil
        end
        return
    end
    local has, D = HSX_DrawingAvailable()
    if not has then return end
    local rname = "HSX_DrawingESP_" .. tostring(math.random(100000, 999999))
    ESP.RenderName = rname
    RunService:BindToRenderStep(rname, Enum.RenderPriority.Camera.Value + 1, function()
        if not ESP.Enabled then return end
        local cam = Workspace.CurrentCamera
        if not cam then return end
        local seen = {}
        local function processModel(model, color, label)
            if not model then return end
            local hum = model:FindFirstChildOfClass("Humanoid")
            local hrp = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head")
            if not hum or not hrp or hum.Health <= 0 then return end
            local key = tostring(model)
            seen[key] = true
            local box = pool[key]
            if not box then
                box = HSX_ESP_NewDrawings(color)
                pool[key] = box
            end
            if not box then return end
            local dist = (hrp.Position - cam.CFrame.Position).Magnitude
            local size = Vector3.new(4, 6, 2)
            local head = model:FindFirstChild("Head")
            if head and hrp then
                size = Vector3.new(3, math.max(1, (hrp.Position.Y - head.Position.Y) + 3), 2)
            end
            HSX_ESP_UpdateBox(box, hrp.CFrame, size, color, label or model.Name, dist, hum.Health, hum.MaxHealth)
        end
        local targets = { Players = true, NpcGuards = true, PlayableGuards = true }
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= Players.LocalPlayer and plr.Character then
                local isG = false
                pcall(function()
                    local a = plr:GetAttribute("IsGuard") or plr:GetAttribute("isGuard") or plr:GetAttribute("Isguard")
                    isG = a == true or a == 1 or a == "true"
                end)
                if isG then
                    if targets.PlayableGuards then
                        processModel(plr.Character, Color3.fromRGB(255, 40, 120), plr.Name)
                    end
                elseif targets.Players then
                    local col = Color3.fromRGB(0, 200, 255)
                    if hnsMode then
                        local ch = plr.Character
                        local hunter, hider = false, false
                        pcall(function()
                            hunter = plr:GetAttribute("Hunter") == true or plr:GetAttribute("IsHunter") == true or plr:GetAttribute("Role") == "Hunter" or plr:GetAttribute("Role") == "hunter" or (ch and (ch:GetAttribute("Hunter") == true or ch:GetAttribute("IsHunter") == true or ch:GetAttribute("Role") == "Hunter" or ch:GetAttribute("Role") == "hunter"))
                            hider = plr:GetAttribute("Hider") == true or plr:GetAttribute("IsHider") == true or plr:GetAttribute("Role") == "Hider" or plr:GetAttribute("Role") == "hider" or (ch and (ch:GetAttribute("Hider") == true or ch:GetAttribute("IsHider") == true or ch:GetAttribute("Role") == "Hider" or ch:GetAttribute("Role") == "hider"))
                        end)
                        if hunter then
                            col = Color3.fromRGB(255, 60, 60)
                        elseif hider then
                            col = Color3.fromRGB(60, 180, 255)
                        end
                    end
                    processModel(plr.Character, col, plr.Name)
                end
            end
        end
        local live = Workspace:FindFirstChild("Live")
        if live then
            for _, child in ipairs(live:GetChildren()) do
                if child.Name ~= Players.LocalPlayer.Name then
                    local isPeabert = string.find(string.lower(child.Name), "peabert")
                    if isPeabert then
                        processModel(child, Color3.fromRGB(255, 100, 255), child.Name)
                    elseif targets.NpcGuards then
                        local isNpc = child:FindFirstChild("TypeOfGuard") or child:FindFirstChild("Enemy") or child.Name:match("Guard")
                        if isNpc and not Players:GetPlayerFromCharacter(child) then
                            processModel(child, Color3.fromRGB(255, 40, 40), "npc guard")
                        end
                    end
                end
            end
        end
        for key, box in pairs(pool) do
            if not seen[key] then
                HSX_ESP_Hide(box)
            end
        end
    end)
end

local TugOfWar = { AutoPull = false, AutoPullConn = nil, WasInZone = false, ZoneEnterTime = 0, PressDelay = 0.01 }

local function findTugOfWarCircle()
    local player = game:GetService("Players").LocalPlayer
    local playerGui = player:FindFirstChild("PlayerGui")
    local function recursiveSearch(parent, depth)
        if depth > 8 then return nil end
        local circleBase = parent:FindFirstChild("CircleBase")
        if circleBase then return circleBase, parent end
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA("ScreenGui") or child:IsA("Frame") or child:IsA("ImageLabel") then
                local found, foundParent = recursiveSearch(child, depth + 1)
                if found then return found, foundParent end
            end
        end
        return nil
    end
    local circleBase, parent = recursiveSearch(playerGui, 0)
    if circleBase then
        local arrow = circleBase:FindFirstChild("Arrow")
        local medium = circleBase:FindFirstChild("Medium")
        if arrow and medium then
            return { circleBase = circleBase, arrow = arrow, medium = medium }
        end
    end
    return nil
end

local function PressSpace()
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    end)
end

local function GetHitZone()
    local player = game:GetService("Players").LocalPlayer
    local strategy = player:GetAttribute("TugOfWarStrategy") or "Standard"
    local hitZone = 26
    if strategy == "Stall" then
        hitZone = math.floor(26 * 0.8)
    end
    return hitZone
end

local function CheckAndPress()
    if not TugOfWar.AutoPull then return end
    local gui = findTugOfWarCircle()
    if not gui then return end
    if not gui.circleBase.Visible then
        TugOfWar.WasInZone = false
        TugOfWar.ZoneEnterTime = 0
        return
    end
    local now = tick()
    local arrowRot = gui.arrow.Rotation
    local mediumRot = gui.medium.Rotation
    local diff = math.abs((mediumRot - arrowRot + 180) % 360 - 180)
    local hitZone = GetHitZone()
    local inZone = diff <= hitZone
    if inZone and not TugOfWar.WasInZone then
        TugOfWar.WasInZone = true
        TugOfWar.ZoneEnterTime = now
    end
    if not inZone and TugOfWar.WasInZone then
        TugOfWar.WasInZone = false
        TugOfWar.ZoneEnterTime = 0
    end
    if TugOfWar.WasInZone then
        local timeInZone = now - TugOfWar.ZoneEnterTime
        if timeInZone >= TugOfWar.PressDelay then
            PressSpace()
            TugOfWar.WasInZone = false
            TugOfWar.ZoneEnterTime = 0
        end
    end
end

function Library:ToggleTugOfWar(enabled)
    TugOfWar.AutoPull = enabled
    if TugOfWar.AutoPullConn then
        TugOfWar.AutoPullConn:Disconnect()
        TugOfWar.AutoPullConn = nil
    end
    if enabled then
        TugOfWar.AutoPullConn = RunService.Heartbeat:Connect(function()
            CheckAndPress()
        end)
    end
end

function Library:CreateWindow(titleText)
    local parent = getHiddenParent()
    local guid = HttpService:GenerateGUID(false)
    local screen = new("ScreenGui", { Name = guid, ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999, Parent = parent })
    local main = new("Frame", { Size = UDim2.fromOffset(350, 320), Position = UDim2.new(0, 20, 0, 20), BackgroundColor3 = BG, BorderSizePixel = 0, Active = true, ClipsDescendants = true, Parent = screen })
    new("UICorner", { CornerRadius = UDim.new(0, 8) }, main)
    new("UIStroke", { Color = BORDER, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, main)
    local isMinimized = false
    local mainTitle = new("TextButton", { Size = UDim2.new(1, -40, 0, 26), Position = UDim2.new(0, 8, 0, 6), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = TEXT, Text = titleText, TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false, Parent = main })
    local body = new("Frame", { Size = UDim2.new(1, 0, 1, -34), Position = UDim2.new(0, 0, 0, 34), BackgroundTransparency = 1, Parent = main })
    new("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 0, 0), BackgroundColor3 = BORDER, BorderSizePixel = 0, Parent = body })
    local closeBtn = new("TextButton", { Size = UDim2.fromOffset(20, 20), Position = UDim2.new(1, -26, 0, 9), BackgroundColor3 = BG2, BorderSizePixel = 0, Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = MUTED, Text = "X", AutoButtonColor = false, ZIndex = 2, Parent = main })
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, closeBtn)
    local closeStroke = new("UIStroke", { Color = BORDER, Thickness = 1 }, closeBtn)
    closeBtn.MouseEnter:Connect(function() TweenService:Create(closeBtn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(30, 12, 12), TextColor3 = RED }):Play(); TweenService:Create(closeStroke, TweenInfo.new(0.12), { Color = RED }):Play() end)
    closeBtn.MouseLeave:Connect(function() TweenService:Create(closeBtn, TweenInfo.new(0.12), { BackgroundColor3 = BG2, TextColor3 = MUTED }):Play(); TweenService:Create(closeStroke, TweenInfo.new(0.12), { Color = BORDER }):Play() end)
    closeBtn.MouseButton1Click:Connect(function() TweenService:Create(main, TweenInfo.new(0.15), { Size = UDim2.fromOffset(0, 0) }):Play(); task.wait(0.15); screen:Destroy() end)
    local dragging, dragStart, startPos
    local function startDrag(input) dragging = true; dragStart = input.Position; startPos = main.Position; input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end) end
    main.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then startDrag(input) end end)
    mainTitle.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then startDrag(input) end end)
    UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then local d = input.Position - dragStart; main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y) end end)
    mainTitle.MouseButton1Click:Connect(function() isMinimized = not isMinimized; if isMinimized then body.Visible = false; TweenService:Create(main, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { Size = UDim2.fromOffset(350, 34) }):Play() else TweenService:Create(main, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { Size = UDim2.fromOffset(350, 320) }):Play(); body.Visible = true end end)
    local tabsRow = new("ScrollingFrame", { Size = UDim2.new(1, 0, 0, 26), Position = UDim2.new(0, 0, 0, 1), BackgroundTransparency = 1, BorderSizePixel = 0, CanvasSize = UDim2.new(0, 0, 0, 0), ScrollBarThickness = 0, ScrollingDirection = Enum.ScrollingDirection.X, Parent = body })
    new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center }, tabsRow)
    new("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 0, 27), BackgroundColor3 = BORDER, BorderSizePixel = 0, Parent = body })
    local contentFrame = new("Frame", { Size = UDim2.new(1, -8, 1, -96), Position = UDim2.new(0, 4, 0, 32), BackgroundTransparency = 1, Parent = body })
    local function updateCanvas() tabsRow.CanvasSize = UDim2.new(0, #tabsRow:GetChildren() * 64, 0, 0) end
    local tabs = {}
    local allTabs = {}
    local Window = {}
    function Window:CreateTab(text)
        local btn = new("TextButton", { Size = UDim2.fromOffset(60, 26), BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = MUTED, Text = text, AutoButtonColor = false, Parent = tabsRow })
        local indicator = new("Frame", { Size = UDim2.new(1, -8, 0, 2), Position = UDim2.new(0, 4, 1, -2), BackgroundColor3 = BORDER, BorderSizePixel = 0 }, btn)
        new("UICorner", { CornerRadius = UDim.new(1, 0) }, indicator)
        local content = new("ScrollingFrame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 2, ScrollBarImageColor3 = BORDER, ScrollBarImageTransparency = 0.5, ScrollingDirection = Enum.ScrollingDirection.Y, Visible = false, Position = UDim2.new(0, 5, 0, 0), Parent = contentFrame })
        new("UIPadding", { PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4), PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 8) }, content)
        table.insert(allTabs, { btn = btn, indicator = indicator, content = content })
        updateCanvas()
        local Tab = {}
        local currentY = 0
        function Tab:CreateToggle(text, default, callback)
            local row = new("TextButton", { Size = UDim2.new(1, 0, 0, 26), Position = UDim2.new(0, 0, 0, currentY), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, Parent = content })
            currentY = currentY + 30
            local box = new("Frame", { Size = UDim2.fromOffset(16, 16), Position = UDim2.new(0, 0, 0.5, -8), BackgroundColor3 = BG2, BorderSizePixel = 0 }, row)
            new("UICorner", { CornerRadius = UDim.new(0, 4) }, box)
            new("UIStroke", { Color = BORDER, Thickness = 1 }, box)
            local fill = new("Frame", { Size = UDim2.fromOffset(8, 8), Position = UDim2.new(0.5, -4, 0.5, -4), BackgroundColor3 = ACCENT, BorderSizePixel = 0, Visible = default }, box)
            new("UICorner", { CornerRadius = UDim.new(0, 2) }, fill)
            new("TextLabel", { Size = UDim2.new(1, -30, 1, 0), Position = UDim2.new(0, 26, 0, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = TEXT, Text = text, TextXAlignment = Enum.TextXAlignment.Left, Parent = row })
            local checked = default
            local function set(state) checked = state; fill.Visible = state; if callback then callback(state) end end
            row.MouseButton1Click:Connect(function() set(not checked) end)
            return { set = set, get = function() return checked end }
        end
        function Tab:CreateButton(text, callback)
            local btn = new("TextButton", { Size = UDim2.new(1, 0, 0, 24), Position = UDim2.new(0, 0, 0, currentY), BackgroundColor3 = BG2, BorderSizePixel = 0, Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = TEXT, Text = text, AutoButtonColor = false, Parent = content })
            currentY = currentY + 28
            new("UICorner", { CornerRadius = UDim.new(0, 4) }, btn)
            local stroke = new("UIStroke", { Color = BORDER, Thickness = 1 }, btn)
            btn.MouseEnter:Connect(function() TweenService:Create(stroke, TweenInfo.new(0.1), { Color = Color3.fromRGB(80, 80, 80) }):Play() end)
            btn.MouseLeave:Connect(function() TweenService:Create(stroke, TweenInfo.new(0.1), { Color = BORDER }):Play() end)
            btn.MouseButton1Click:Connect(function() if callback then callback() end end)
            return btn
        end
        function Tab:CreateSlider(text, min, max, default, callback)
            local row = new("Frame", { Size = UDim2.new(1, 0, 0, 40), Position = UDim2.new(0, 0, 0, currentY), BackgroundTransparency = 1, Parent = content })
            currentY = currentY + 45
            local label = new("TextLabel", { Size = UDim2.new(1, 0, 0, 15), BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = TEXT, Text = text .. ": " .. default, TextXAlignment = Enum.TextXAlignment.Left, Parent = row })
            local bar = new("TextButton", { Size = UDim2.new(1, 0, 0, 16), Position = UDim2.new(0, 0, 0, 20), BackgroundColor3 = BG2, BorderSizePixel = 0, Text = "", AutoButtonColor = false, Parent = row })
            new("UICorner", { CornerRadius = UDim.new(0, 4) }, bar)
            new("UIStroke", { Color = BORDER, Thickness = 1 }, bar)
            local fill = new("Frame", { Size = UDim2.new((default - min) / (max - min), 0, 1, 0), BackgroundColor3 = ACCENT, BorderSizePixel = 0, Parent = bar })
            new("UICorner", { CornerRadius = UDim.new(0, 4) }, fill)
            local value = default
            local dragging = false
            local function update(input)
                local relX = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                value = math.floor(min + (max - min) * relX)
                fill.Size = UDim2.new(relX, 0, 1, 0)
                label.Text = text .. ": " .. value
                if callback then callback(value) end
            end
            bar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; update(input) end end)
            UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then update(input) end end)
            UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
            return { Set = function(val) update({Position = Vector2.new(bar.AbsolutePosition.X + (val - min) / (max - min) * bar.AbsoluteSize.X, 0)}) end }
        end
        function Tab:CreateLabel(text, isWarning)
            local label = new("TextLabel", { Size = UDim2.new(1, 0, 0, 30), Position = UDim2.new(0, 0, 0, currentY), BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, TextSize = 10, TextColor3 = isWarning and RED or MUTED, Text = text, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true, Parent = content })
            currentY = currentY + 34
            return label
        end
        function Tab:CreateDivider()
            local div = new("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 0, currentY), BackgroundColor3 = BORDER, BorderSizePixel = 0, Parent = content })
            currentY = currentY + 12
            return div
        end
        table.insert(tabs, { btn = btn, indicator = indicator, content = content })
        btn.MouseButton1Click:Connect(function()
            for _, t in ipairs(tabs) do
                t.indicator.BackgroundColor3 = BORDER
                t.btn.TextColor3 = MUTED
                t.content.Visible = false
            end
            indicator.BackgroundColor3 = ACCENT
            btn.TextColor3 = TEXT
            content.Visible = true
            content.Position = UDim2.new(0, 5, 0, 0)
            TweenService:Create(content, TweenInfo.new(0.15, Enum.EasingStyle.Quad), { Position = UDim2.new(0, 0, 0, 0) }):Play()
        end)
        if #tabs == 1 then
            indicator.BackgroundColor3 = ACCENT
            btn.TextColor3 = TEXT
            content.Visible = true
            content.Position = UDim2.new(0, 0, 0, 0)
        end
        return Tab
    end
    Window.ScreenGui = screen
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.Z then
            main.Visible = not main.Visible
        end
    end)
    return Window
end

getgenv().HSXLib = Library
local old
old = hookfunction(game.FindService, newcclosure(function(self, service) 
    if not checkcaller() then 
        if self == game and (service == "VirtualInputManager" or service == "VirtualUser") then 
            return nil 
        end 
    end 
    return old(self, service) 
end))

local anticheatneededchecksandthings = {
    BLACKLISTED_GUI = true, HOLLY_PARTS = true, HOLLY_SOUNDS = true, BlockedStrings = true,
    BLACKLISTED_PLACES = true, BLACKLISTED_OUTPUTS = true, CHEAT_MARKERS = true, IN_CHARACTER_IGNORE = true,
    DetectionMessage = true, DetectionText1 = true, DetectionText2 = true,
    ["fly-hack A"] = true, ["fly-hack B"] = true, ["fly-hack C"] = true, ["fling A"] = true,
    ["speed-hack A"] = true, ["modified character A"] = true,
    VoidKillAntiFall = true, SpikesPlatformTeleport = true, JumpRopeAntiFall = true, GlassSafetyPlatform = true,
    MingleSafetyPlatform = true, SkySquidAntiFall = true, ESPCham = true, HNSEHitbox = true, HitboxOutline = true,
    LIMB_NAMES = true, RotVelocity = true, RootRotVelocityChanged = true, AssemblyLinearVelocity = true,
    AssemblyLinearVelocityChanged = true, RootCFrameChanged = true, HeadCFrameChanged = true,
    LogServiceMessageOut = true, VirtualInputManager = true, VirtualUser = true,
    CHARACTERS = true, SERVICE_NAMES = true, RENDERSTEPS = true, Unsafe = true, Name = true, IgnoreFunc = true,
}

local targets = {
    HOLLY_PARTS = true, HOLLY_SOUNDS = true, BLACKLISTED_GUI = true,
}

local anticheatthings = {
    VoidKillAntiFall = true, SpikesPlatformTeleport = true, JumpRopeAntiFall = true, GlassSafetyPlatform = true,
    MingleSafetyPlatform = true, SkySquidAntiFall = true, ESPCham = true, HNSEHitbox = true, HitboxOutline = true,
}

local function getRegistry()
    local ok, r = pcall(getreg)
    return ok and r or {}
end

local function isLClosure(fn)
    local ok, r = pcall(islclosure, fn)
    return ok and r == true
end

local function checkifanticheatthing(t)
    if type(t) ~= "table" then return false end
    local hasTarget = false
    for k in pairs(t) do
        if targets[k] then hasTarget = true; break end
    end
    if not hasTarget then return false end
    for _, v in pairs(t) do
        if type(v) == "table" then
            for kk in pairs(v) do
                if anticheatthings[kk] then return true end
            end
        end
    end
    return false
end

local found = nil
for _, v in ipairs(getRegistry()) do
    if typeof(v) == "function" and isLClosure(v) then
        local ok, ups = pcall(debug.getupvalues, v)
        if ok and type(ups) == "table" then
            for _, up in pairs(ups) do
                if checkifanticheatthing(up) then
                    found = up
                    break
                end
            end
        end
    end
    if found then break end
end

if not found then
    print("xup was here?")
else
    task.spawn(function()
        while true do
            for name in pairs(anticheatneededchecksandthings) do
                local t = found[name]
                if type(t) == "table" then
                    pcall(function() table.clear(t) end)
                end
            end
            task.wait(60)
        end
    end)
    print("x_up was here?")
end

local anticheatKeys = {
    DetectionMessage = true, DetectionText1 = true, DetectionText2 = true,
    ["fly-hack A"] = true, ["fly-hack B"] = true, ["fly-hack C"] = true,
    ["fling A"] = true, ["speed-hack A"] = true, ["modified character A"] = true,
    VoidKillAntiFall = true, SpikesPlatformTeleport = true, JumpRopeAntiFall = true, GlassSafetyPlatform = true,
    MingleSafetyPlatform = true, SkySquidAntiFall = true, ESPCham = true, HNSEHitbox = true, HitboxOutline = true,
    BlockedStrings = true, BLACKLISTED_OUTPUTS = true, BLACKLISTED_PLACES = true, BLACKLISTED_GUI = true,
    CHEAT_MARKERS = true, IN_CHARACTER_IGNORE = true, HOLLY_PARTS = true, HOLLY_SOUNDS = true, LIMB_NAMES = true,
    RotVelocity = true, RootRotVelocityChanged = true, AssemblyLinearVelocity = true, AssemblyLinearVelocityChanged = true,
    RootCFrameChanged = true, HeadCFrameChanged = true, LogServiceMessageOut = true, VirtualInputManager = true,
    VirtualUser = true, CHARACTERS = true, SERVICE_NAMES = true, RENDERSTEPS = true, Unsafe = true, Name = true, IgnoreFunc = true,
}

local function nukeTable(t)
    if type(t) ~= "table" then return end
    local hits = 0
    for k, v in pairs(t) do
        if anticheatKeys[k] then t[k] = nil; hits += 1
        elseif type(v) == "table" then hits += nukeTable(v) end
    end
    return hits
end

local seenTables = setmetatable({}, { __mode = "k" })
local seenCount = 0

local function antiCheatNuke()
    local ok, gc = pcall(getgc, true)
    if not ok or not gc then return end
    for _, v in ipairs(gc) do
        if type(v) == "table" and not seenTables[v] then
            seenTables[v] = true
            seenCount += 1
            for k in pairs(v) do
                if anticheatKeys[k] then
                    nukeTable(v)
                    break
                end
            end
        end
    end
    if seenCount > 200000 then
        seenTables = setmetatable({}, { __mode = "k" })
        seenCount = 0
    end
end

antiCheatNuke()
task.spawn(function()
    while true do
        task.wait(30)
        pcall(antiCheatNuke)
    end
end)

local BUMP_TO = 99999999999999999999
local numericKeys = {
    MAX_SPRINT_BOOST = true, MAX_LINE_FORCE = true, MAX_ANGULAR_TORQUE = true, MAX_TORQUE = true, BODY_GYRO = true, BodyGyro = true, bodygyro = true, BODY_GYRO = true, MAX_VELOCITY_TORQUE = true, MAX_ALIGNPOSITION_FORCE = true,
    MAX_VECTORFORCE = true, MAX_ROOT_SIZE = true,
    MAX_FORCE = true, MAX_ANGULARVELOCITY_TORQUE = true,
    MOUSE_ENABLED_LIMIT = true,
}

local function bumpTables()
    local ok, gc = pcall(getgc, true)
    if not ok or not gc then return end
    for _, v in ipairs(gc) do
        if type(v) == "table" then
            for key in pairs(numericKeys) do
                local val = rawget(v, key)
                if type(val) == "number" then
                    rawset(v, key, BUMP_TO)
                end
            end
        end
    end
end

bumpTables()
return Library

