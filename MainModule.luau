local Library = {}
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

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

function Library:CreateWindow(titleText)
    local parent = getHiddenParent()
    local guid = HttpService:GenerateGUID(false)
    
    local screen = new("ScreenGui", {
        Name = guid,
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999,
        Parent = parent
    })

    local main = new("Frame", {
        Size = UDim2.fromOffset(350, 320),
        Position = UDim2.new(0, 20, 0, 20),
        BackgroundColor3 = BG,
        BorderSizePixel = 0,
        Active = true,
        ClipsDescendants = true,
        Parent = screen
    })
    new("UICorner", { CornerRadius = UDim.new(0, 8) }, main)
    new("UIStroke", { Color = BORDER, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, main)

    local isMinimized = false
    local mainTitle = new("TextButton", {
        Size = UDim2.new(1, -40, 0, 26),
        Position = UDim2.new(0, 8, 0, 6),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = TEXT,
        Text = titleText,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false,
        Parent = main
    })

    local body = new("Frame", {
        Size = UDim2.new(1, 0, 1, -34),
        Position = UDim2.new(0, 0, 0, 34),
        BackgroundTransparency = 1,
        Parent = main
    })
    new("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 0, 0), BackgroundColor3 = BORDER, BorderSizePixel = 0, Parent = body })

    local closeBtn = new("TextButton", {
        Size = UDim2.fromOffset(20, 20),
        Position = UDim2.new(1, -26, 0, 9),
        BackgroundColor3 = BG2,
        BorderSizePixel = 0,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = MUTED,
        Text = "X",
        AutoButtonColor = false,
        ZIndex = 2,
        Parent = main
    })
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, closeBtn)
    local closeStroke = new("UIStroke", { Color = BORDER, Thickness = 1 }, closeBtn)

    closeBtn.MouseEnter:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(30, 12, 12), TextColor3 = RED }):Play()
        TweenService:Create(closeStroke, TweenInfo.new(0.12), { Color = RED }):Play()
    end)
    closeBtn.MouseLeave:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.12), { BackgroundColor3 = BG2, TextColor3 = MUTED }):Play()
        TweenService:Create(closeStroke, TweenInfo.new(0.12), { Color = BORDER }):Play()
    end)
    closeBtn.MouseButton1Click:Connect(function()
        TweenService:Create(main, TweenInfo.new(0.15), { Size = UDim2.fromOffset(0, 0) }):Play()
        task.wait(0.15)
        screen:Destroy()
    end)

    local dragging, dragStart, startPos
    local function startDrag(input)
        dragging = true
        dragStart = input.Position
        startPos = main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end

    main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            startDrag(input)
        end
    end)

    mainTitle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            startDrag(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)

    mainTitle.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            body.Visible = false
            TweenService:Create(main, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { Size = UDim2.fromOffset(350, 34) }):Play()
        else
            TweenService:Create(main, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { Size = UDim2.fromOffset(350, 320) }):Play()
            body.Visible = true
        end
    end)

    local tabsRow = new("ScrollingFrame", {
        Size = UDim2.new(1, 0, 0, 26),
        Position = UDim2.new(0, 0, 0, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.X,
        Parent = body
    })
    new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center }, tabsRow)
    new("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 0, 27), BackgroundColor3 = BORDER, BorderSizePixel = 0, Parent = body })

    local contentFrame = new("Frame", {
        Size = UDim2.new(1, -8, 1, -96),
        Position = UDim2.new(0, 4, 0, 32),
        BackgroundTransparency = 1,
        Parent = body
    })

    local function updateCanvas()
        tabsRow.CanvasSize = UDim2.new(0, #tabsRow:GetChildren() * 64, 0, 0)
    end

    local tabs = {}
    local allTabs = {}

    local Window = {}
    
    function Window:CreateTab(text)
        local btn = new("TextButton", {
            Size = UDim2.fromOffset(60, 26),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamMedium,
            TextSize = 11,
            TextColor3 = MUTED,
            Text = text,
            AutoButtonColor = false,
            Parent = tabsRow
        })
        local indicator = new("Frame", { Size = UDim2.new(1, -8, 0, 2), Position = UDim2.new(0, 4, 1, -2), BackgroundColor3 = BORDER, BorderSizePixel = 0 }, btn)
        new("UICorner", { CornerRadius = UDim.new(1, 0) }, indicator)

        local content = new("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = BORDER,
            ScrollBarImageTransparency = 0.5,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            Visible = false,
            Position = UDim2.new(0, 5, 0, 0),
            Parent = contentFrame
        })
        new("UIPadding", { PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4), PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 8) }, content)

        table.insert(allTabs, { btn = btn, indicator = indicator, content = content })
        updateCanvas()

        local Tab = {}
        local currentY = 0

        function Tab:CreateToggle(text, default, callback)
            local row = new("TextButton", {
                Size = UDim2.new(1, 0, 0, 26),
                Position = UDim2.new(0, 0, 0, currentY),
                BackgroundTransparency = 1,
                Text = "",
                AutoButtonColor = false,
                Parent = content
            })
            currentY = currentY + 30

            local box = new("Frame", { Size = UDim2.fromOffset(16, 16), Position = UDim2.new(0, 0, 0.5, -8), BackgroundColor3 = BG2, BorderSizePixel = 0 }, row)
            new("UICorner", { CornerRadius = UDim.new(0, 4) }, box)
            new("UIStroke", { Color = BORDER, Thickness = 1 }, box)

            local fill = new("Frame", { Size = UDim2.fromOffset(8, 8), Position = UDim2.new(0.5, -4, 0.5, -4), BackgroundColor3 = ACCENT, BorderSizePixel = 0, Visible = default }, box)
            new("UICorner", { CornerRadius = UDim.new(0, 2) }, fill)

            new("TextLabel", {
                Size = UDim2.new(1, -30, 1, 0),
                Position = UDim2.new(0, 26, 0, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamMedium,
                TextSize = 11,
                TextColor3 = TEXT,
                Text = text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = row
            })

            local checked = default
            local function set(state)
                checked = state
                fill.Visible = state
                if callback then callback(state) end
            end

            row.MouseButton1Click:Connect(function() set(not checked) end)
            return { set = set, get = function() return checked end }
        end

        function Tab:CreateButton(text, callback)
            local btn = new("TextButton", {
                Size = UDim2.new(1, 0, 0, 24),
                Position = UDim2.new(0, 0, 0, currentY),
                BackgroundColor3 = BG2,
                BorderSizePixel = 0,
                Font = Enum.Font.GothamMedium,
                TextSize = 11,
                TextColor3 = TEXT,
                Text = text,
                AutoButtonColor = false,
                Parent = content
            })
            currentY = currentY + 28

            new("UICorner", { CornerRadius = UDim.new(0, 4) }, btn)
            local stroke = new("UIStroke", { Color = BORDER, Thickness = 1 }, btn)

            btn.MouseEnter:Connect(function()
                TweenService:Create(stroke, TweenInfo.new(0.1), { Color = Color3.fromRGB(80, 80, 80) }):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenService:Create(stroke, TweenInfo.new(0.1), { Color = BORDER }):Play()
            end)
            btn.MouseButton1Click:Connect(function() if callback then callback() end end)

            return btn
        end

        function Tab:CreateSlider(text, min, max, default, callback)
            local row = new("Frame", {
                Size = UDim2.new(1, 0, 0, 40),
                Position = UDim2.new(0, 0, 0, currentY),
                BackgroundTransparency = 1,
                Parent = content
            })
            currentY = currentY + 45

            local label = new("TextLabel", {
                Size = UDim2.new(1, 0, 0, 15),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamMedium,
                TextSize = 11,
                TextColor3 = TEXT,
                Text = text .. ": " .. default,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = row
            })

            local bar = new("TextButton", {
                Size = UDim2.new(1, 0, 0, 16),
                Position = UDim2.new(0, 0, 0, 20),
                BackgroundColor3 = BG2,
                BorderSizePixel = 0,
                Text = "",
                AutoButtonColor = false,
                Parent = row
            })
            new("UICorner", { CornerRadius = UDim.new(0, 4) }, bar)
            new("UIStroke", { Color = BORDER, Thickness = 1 }, bar)

            local fill = new("Frame", {
                Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                BackgroundColor3 = ACCENT,
                BorderSizePixel = 0,
                Parent = bar
            })
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

            bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    update(input)
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    update(input)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)

            return { Set = function(val) update({Position = Vector2.new(bar.AbsolutePosition.X + (val - min) / (max - min) * bar.AbsoluteSize.X, 0)}) end }
        end

        function Tab:CreateLabel(text, isWarning)
            local label = new("TextLabel", {
                Size = UDim2.new(1, 0, 0, 30),
                Position = UDim2.new(0, 0, 0, currentY),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamMedium,
                TextSize = 10,
                TextColor3 = isWarning and RED or MUTED,
                Text = text,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                TextWrapped = true,
                Parent = content
            })
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
local old; old = hookfunction(game.FindService, newcclosure(function(self, service) 
         if not checkcaller() then 
             if self == game and (service == "VirtualInputManager" or service == "VirtualUser") then 
                 return nil 
             end 
         end 
 
         return old(self, service) 
     end)) 
local anticheatneededchecksandthings = {
    BLACKLISTED_GUI = true,
    HOLLY_PARTS = true,
    HOLLY_SOUNDS = true,
    BlockedStrings = true,
    BLACKLISTED_PLACES = true,
    BLACKLISTED_OUTPUTS = true,
    CHEAT_MARKERS = true,
    IN_CHARACTER_IGNORE = true,
    DetectionMessage = true,
    DetectionText1 = true,
    DetectionText2 = true,
    ["fly-hack A"] = true,
    ["fly-hack B"] = true,
    ["fly-hack C"] = true,
    ["fling A"] = true,
    ["speed-hack A"] = true,
    ["modified character A"] = true,
    VoidKillAntiFall = true,
    SpikesPlatformTeleport = true,
    JumpRopeAntiFall = true,
    GlassSafetyPlatform = true,
    MingleSafetyPlatform = true,
    SkySquidAntiFall = true,
    ESPCham = true,
    HNSEHitbox = true,
    HitboxOutline = true,
    LIMB_NAMES = true,
    RotVelocity = true,
    RootRotVelocityChanged = true,
    AssemblyLinearVelocity = true,
    AssemblyLinearVelocityChanged = true,
    RootCFrameChanged = true,
    HeadCFrameChanged = true,
    LogServiceMessageOut = true,
    VirtualInputManager = true,
    VirtualUser = true,
    CHARACTERS = true,
    SERVICE_NAMES = true,
    RENDERSTEPS = true,
    Unsafe = true,
    Name = true,
    IgnoreFunc = true,
}

local targets = {
    HOLLY_PARTS = true,
    HOLLY_SOUNDS = true,
    BLACKLISTED_GUI = true,
}

local anticheatthings = {
    VoidKillAntiFall = true,
    SpikesPlatformTeleport = true,
    JumpRopeAntiFall = true,
    GlassSafetyPlatform = true,
    MingleSafetyPlatform = true,
    SkySquidAntiFall = true,
    ESPCham = true,
    HNSEHitbox = true,
    HitboxOutline = true,
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
    if type(t) ~= "table" then
        return false
    end
    local hasTarget = false
    for k in pairs(t) do
        if targets[k] then
            hasTarget = true
            break
        end
    end
    if not hasTarget then
        return false
    end
    for _, v in pairs(t) do
        if type(v) == "table" then
            for kk in pairs(v) do
                if anticheatthings[kk] then
                    return true
                end
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
    if found then
        break
    end
end

if not found then
    print("xup was here?")
else
    task.spawn(function()
        while true do
            for name in pairs(anticheatneededchecksandthings) do
                local t = found[name]
                if type(t) == "table" then
                    pcall(function()
                        table.clear(t)
                    end)
                end
            end
            task.wait(60)
        end
    end)
    print("x_up was here?")
        })
    end
end
local anticheatKeys = {
    DetectionMessage = true, DetectionText1 = true, DetectionText2 = true,
    ["fly-hack A"] = true, ["fly-hack B"] = true, ["fly-hack C"] = true,
    ["fling A"] = true, ["speed-hack A"] = true,
    ["modified character A"] = true,
    VoidKillAntiFall = true, SpikesPlatformTeleport = true,
    JumpRopeAntiFall = true, GlassSafetyPlatform = true,
    MingleSafetyPlatform = true, SkySquidAntiFall = true,
    ESPCham = true, HNSEHitbox = true, HitboxOutline = true,
    BlockedStrings = true, BLACKLISTED_OUTPUTS = true, BLACKLISTED_PLACES = true,
    BLACKLISTED_GUI = true, CHEAT_MARKERS = true, IN_CHARACTER_IGNORE = true,
    HOLLY_PARTS = true, HOLLY_SOUNDS = true,
    LIMB_NAMES = true,
    RotVelocity = true, RootRotVelocityChanged = true,
    AssemblyLinearVelocity = true, AssemblyLinearVelocityChanged = true,
    RootCFrameChanged = true, HeadCFrameChanged = true,
    LogServiceMessageOut = true,
    VirtualInputManager = true, VirtualUser = true,
    CHARACTERS = true, SERVICE_NAMES = true, RENDERSTEPS = true,
    Unsafe = true, Name = true, IgnoreFunc = true,
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
local BUMP_TO = 9999999999
local numericKeys = {
    MAX_SPRINT_BOOST = true, MAX_ALIGNPOSITION_FORCE = true,
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


