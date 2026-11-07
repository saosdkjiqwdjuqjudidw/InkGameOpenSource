local Lib = _G.HSXLib

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local function getHiddenParent()
    if gethui then
        local ok, h = pcall(gethui)
        if ok and h then return h end
    end
    local ok = pcall(function() CoreGui.Name = CoreGui.Name end)
    if ok then return CoreGui end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local parent = getHiddenParent()
local guid = HttpService:GenerateGUID(false)
local screen = Instance.new("ScreenGui")
screen.Name = guid
screen.ResetOnSpawn = false
screen.IgnoreGuiInset = true
screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screen.DisplayOrder = 999
screen.Parent = parent

local function rnd()
    return HttpService:GenerateGUID(false)
end

local function new(class, props, par)
    local o = Instance.new(class)
    for k, v in pairs(props) do o[k] = v end
    if par then o.Parent = par end
    return o
end

local ACCENT = Color3.fromRGB(34, 197, 94)
local BG = Color3.fromRGB(10, 10, 10)
local BG2 = Color3.fromRGB(18, 18, 18)
local BORDER = Color3.fromRGB(40, 40, 40)
local TEXT = Color3.fromRGB(230, 230, 230)
local MUTED = Color3.fromRGB(140, 140, 140)
local RED = Color3.fromRGB(239, 68, 68)

local main = new("Frame", {
    Name = rnd(),
    Size = UDim2.fromOffset(350, 320),
    Position = UDim2.new(0, 20, 0, 20),
    BackgroundColor3 = BG,
    BorderSizePixel = 0,
    Active = true,
    ClipsDescendants = true
}, screen)

new("UICorner", { CornerRadius = UDim.new(0, 8) }, main)
new("UIStroke", { Color = BORDER, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, main)

local isMinimized = false
local mainTitle = new("TextButton", {
    Name = rnd(),
    Size = UDim2.new(1, -40, 0, 26),
    Position = UDim2.new(0, 8, 0, 6),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    TextColor3 = TEXT,
    Text = "HSX Safe — Ink Game",
    TextXAlignment = Enum.TextXAlignment.Left,
    AutoButtonColor = false
}, main)

local body = new("Frame", {
    Name = rnd(),
    Size = UDim2.new(1, 0, 1, -34),
    Position = UDim2.new(0, 0, 0, 34),
    BackgroundTransparency = 1
}, main)

new("Frame", {
    Name = rnd(),
    Size = UDim2.new(1, 0, 0, 1),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundColor3 = BORDER,
    BorderSizePixel = 0
}, body)

local closeBtn = new("TextButton", {
    Name = rnd(),
    Size = UDim2.fromOffset(20, 20),
    Position = UDim2.new(1, -26, 0, 9),
    BackgroundColor3 = BG2,
    BorderSizePixel = 0,
    Font = Enum.Font.GothamBold,
    TextSize = 11,
    TextColor3 = MUTED,
    Text = "X",
    AutoButtonColor = false,
    ZIndex = 2
}, main)

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
    screen:Destroy()
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
    Name = rnd(),
    Size = UDim2.new(1, 0, 0, 26),
    Position = UDim2.new(0, 0, 0, 1),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    ScrollBarThickness = 0,
    ScrollingDirection = Enum.ScrollingDirection.X
}, body)

new("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    Padding = UDim.new(0, 4),
    SortOrder = Enum.SortOrder.LayoutOrder,
    VerticalAlignment = Enum.VerticalAlignment.Center
}, tabsRow)

local function createTab(text)
    local btn = new("TextButton", {
        Name = rnd(),
        Size = UDim2.fromOffset(60, 26),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
        TextColor3 = MUTED,
        Text = text,
        AutoButtonColor = false
    }, tabsRow)

    local indicator = new("Frame", {
        Name = rnd(),
        Size = UDim2.new(1, -8, 0, 2),
        Position = UDim2.new(0, 4, 1, -2),
        BackgroundColor3 = BORDER,
        BorderSizePixel = 0
    }, btn)

    new("UICorner", { CornerRadius = UDim.new(1, 0) }, indicator)
    return { btn = btn, indicator = indicator }
end

local tabMisc = createTab("Misc")
local tabDalgona = createTab("Dalgona")
local tabLights = createTab("Lights Out")
local tabPenta = createTab("Pentathlon")
local tabHNS = createTab("HNS")
local tabJump = createTab("Jump Rope")
local tabGlass = createTab("Glass Bridge")
local tabSky = createTab("Sky Squid")
local tabGuns = createTab("Guns")

tabsRow.CanvasSize = UDim2.new(0, 9 * 64, 0, 0)

new("Frame", {
    Name = rnd(),
    Size = UDim2.new(1, 0, 0, 1),
    Position = UDim2.new(0, 0, 0, 27),
    BackgroundColor3 = BORDER,
    BorderSizePixel = 0
}, body)

local contentFrame = new("Frame", {
    Name = rnd(),
    Size = UDim2.new(1, -8, 1, -96),
    Position = UDim2.new(0, 4, 0, 32),
    BackgroundTransparency = 1
}, body)

local function createScrollingContent()
    local sf = new("ScrollingFrame", {
        Name = rnd(),
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 420),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = BORDER,
        ScrollBarImageTransparency = 0.5,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Visible = false
    }, contentFrame)

    new("UIPadding", {
        PaddingLeft = UDim.new(0, 4),
        PaddingRight = UDim.new(0, 4),
        PaddingTop = UDim.new(0, 2),
        PaddingBottom = UDim.new(0, 8)
    }, sf)

    return sf
end

local miscContent = createScrollingContent()
miscContent.Visible = true
local dalgonaContent = createScrollingContent()
local lightsOutContent = createScrollingContent()
local pentathlonContent = createScrollingContent()
local hnsContent = createScrollingContent()
local jumpContent = createScrollingContent()
local glassContent = createScrollingContent()
local skyContent = createScrollingContent()
local gunsContent = createScrollingContent()

local function createCheckbox(parent, text, default, callback)
    local row = new("TextButton", {
        Name = rnd(),
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false
    }, parent)

    local box = new("Frame", {
        Name = rnd(),
        Size = UDim2.fromOffset(16, 16),
        Position = UDim2.new(0, 0, 0.5, -8),
        BackgroundColor3 = BG2,
        BorderSizePixel = 0
    }, row)

    new("UICorner", { CornerRadius = UDim.new(0, 4) }, box)
    new("UIStroke", { Color = BORDER, Thickness = 1 }, box)

    local fill = new("Frame", {
        Name = rnd(),
        Size = UDim2.fromOffset(8, 8),
        Position = UDim2.new(0.5, -4, 0.5, -4),
        BackgroundColor3 = ACCENT,
        BorderSizePixel = 0,
        Visible = default
    }, box)

    new("UICorner", { CornerRadius = UDim.new(0, 2) }, fill)

    new("TextLabel", {
        Name = rnd(),
        Size = UDim2.new(1, -30, 1, 0),
        Position = UDim2.new(0, 26, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
        TextColor3 = TEXT,
        Text = text,
        TextXAlignment = Enum.TextXAlignment.Left
    }, row)

    local checked = default
    local function set(state)
        checked = state
        fill.Visible = state
        if callback then
            callback(state)
        end
    end

    row.MouseButton1Click:Connect(function()
        set(not checked)
    end)

    return { row = row, set = set, get = function() return checked end }
end

local function createActionButton(parent, text, callback)
    local btn = new("TextButton", {
        Name = rnd(),
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundColor3 = BG2,
        BorderSizePixel = 0,
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
        TextColor3 = TEXT,
        Text = text,
        AutoButtonColor = false
    }, parent)

    new("UICorner", { CornerRadius = UDim.new(0, 4) }, btn)
    local stroke = new("UIStroke", { Color = BORDER, Thickness = 1 }, btn)

    btn.MouseEnter:Connect(function()
        TweenService:Create(stroke, TweenInfo.new(0.1), { Color = Color3.fromRGB(80, 80, 80) }):Play()
    end)

    btn.MouseLeave:Connect(function()
        TweenService:Create(stroke, TweenInfo.new(0.1), { Color = BORDER }):Play()
    end)

    btn.MouseButton1Click:Connect(function()
        if callback then
            callback()
        end
    end)

    return btn
end

createCheckbox(miscContent, "Players ESP", false, function(on) Lib.toggleESP(on) end)

local cbHNS = createCheckbox(miscContent, "HNS Mode", true, function(on) Lib.ESPHNSRolesEnabled = on end)
cbHNS.row.Position = UDim2.new(0, 0, 0, 30)

local cbFB = createCheckbox(miscContent, "Fullbright", false, function(on) Lib.toggle_fullbright(on) end)
cbFB.row.Position = UDim2.new(0, 0, 0, 60)

local cbLegitQTE, cbRageQTE
cbLegitQTE = createCheckbox(miscContent, "Legit Auto QTE", false, function(on)
    if on then
        if cbRageQTE and cbRageQTE.get() then
            cbRageQTE.set(false)
        end
        Lib.toggle_auto_qte(true, "Legit")
    else
        Lib.toggle_auto_qte(false)
    end
end)
cbLegitQTE.row.Position = UDim2.new(0, 0, 0, 90)

cbRageQTE = createCheckbox(miscContent, "Rage Auto QTE", false, function(on)
    if on then
        if cbLegitQTE and cbLegitQTE.get() then
            cbLegitQTE.set(false)
        end
        Lib.toggle_auto_qte(true, "Rage")
    else
        Lib.toggle_auto_qte(false)
    end
end)
cbRageQTE.row.Position = UDim2.new(0, 0, 0, 120)

new("TextLabel", {
    Name = rnd(),
    Size = UDim2.new(1, 0, 0, 30),
    Position = UDim2.new(0, 0, 0, 150),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamMedium,
    TextSize = 10,
    TextColor3 = MUTED,
    Text = "note that auto qte was updated and now works normally, recommend using legit auto qte it works on monkey bar minigame",
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    TextWrapped = true
}, miscContent)

new("Frame", {
    Name = rnd(),
    Size = UDim2.new(1, 0, 0, 1),
    Position = UDim2.new(0, 0, 0, 185),
    BackgroundColor3 = BORDER,
    BorderSizePixel = 0
}, miscContent)

local gpY = 195
local function addGPButton(label, toggleFunc)
    local state = false
    local btn = createActionButton(miscContent, label, function()
        state = not state
        toggleFunc(state)
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = state and ACCENT or BG2,
            TextColor3 = state and Color3.fromRGB(255, 255, 255) or TEXT
        }):Play()
    end)
    btn.Position = UDim2.new(0, 0, 0, gpY)
    gpY = gpY + 28
    return btn
end

addGPButton("Permanent Guard", Lib.toggle_permanent_guard)
addGPButton("Glass Vision", Lib.toggle_glass_vision)
addGPButton("Emote Pages", Lib.toggle_emote_pages)
addGPButton("Custom Player Tag", Lib.toggle_custom_player_tag)
addGPButton("Private Server Plus", Lib.toggle_private_server_plus)
addGPButton("Lighter", Lib.toggle_lighter)

local vipBtn = createActionButton(miscContent, "Unlock VIP", function()
    Lib.unlock_vip()
    vipBtn.Text = "VIP Unlocked"
    TweenService:Create(vipBtn, TweenInfo.new(0.15), { BackgroundColor3 = ACCENT, TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
end)
vipBtn.Position = UDim2.new(0, 0, 0, gpY)
gpY = gpY + 28

new("TextLabel", {
    Name = rnd(),
    Size = UDim2.new(1, 0, 0, 20),
    Position = UDim2.new(0, 0, 0, gpY),
    BackgroundTransparency = 1,
    Font = Enum.Font.Gotham,
    TextSize = 10,
    TextColor3 = MUTED,
    Text = "▼ Scroll down for more ▼",
    TextXAlignment = Enum.TextXAlignment.Center
}, miscContent)

createCheckbox(dalgonaContent, "Anti-Crack", false, function(on) Lib.toggle_anti_crack(on) end)
local cbRelax = createCheckbox(dalgonaContent, "Auto Relax", false, function(on) Lib.toggle_dalgona_auto_relax(on) end)
cbRelax.row.Position = UDim2.new(0, 0, 0, 30)

local autoDalgonaBtn = createActionButton(dalgonaContent, "Auto Dalgona", function()
    local success = Lib.AutoDalgona()
    if success then
        autoDalgonaBtn.Text = "Applied!"
        TweenService:Create(autoDalgonaBtn, TweenInfo.new(0.15), { BackgroundColor3 = ACCENT, TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
        task.delay(2, function()
            if autoDalgonaBtn and autoDalgonaBtn.Parent then
                autoDalgonaBtn.Text = "Auto Dalgona"
                TweenService:Create(autoDalgonaBtn, TweenInfo.new(0.15), { BackgroundColor3 = BG2, TextColor3 = TEXT }):Play()
            end
        end)
    else
        autoDalgonaBtn.Text = "Not Found"
        TweenService:Create(autoDalgonaBtn, TweenInfo.new(0.15), { BackgroundColor3 = RED, TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
        task.delay(2, function()
            if autoDalgonaBtn and autoDalgonaBtn.Parent then
                autoDalgonaBtn.Text = "Auto Dalgona"
                TweenService:Create(autoDalgonaBtn, TweenInfo.new(0.15), { BackgroundColor3 = BG2, TextColor3 = TEXT }):Play()
            end
        end)
    end
end)
autoDalgonaBtn.Position = UDim2.new(0, 0, 0, 60)

local freeLighterBtn = createActionButton(dalgonaContent, "Free Lighter", function()
    LocalPlayer:SetAttribute("HasLighter", true)
    freeLighterBtn.Text = "Lighter Given"
    TweenService:Create(freeLighterBtn, TweenInfo.new(0.15), { BackgroundColor3 = ACCENT, TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
end)
freeLighterBtn.Position = UDim2.new(0, 0, 0, 90)

createCheckbox(lightsOutContent, "Teleport to safezone & return", false, function(on) Lib.toggle_lights_out_safezone(on) end)

createCheckbox(pentathlonContent, "Auto Ddakji", false, function(on) Lib.toggle_auto_ddakji(on) end)
local p1 = createCheckbox(pentathlonContent, "Auto Flying Stone", false, function(on) Lib.toggle_auto_flying_stone(on) end)
p1.row.Position = UDim2.new(0, 0, 0, 30)
local p2 = createCheckbox(pentathlonContent, "Auto Gonggi", false, function(on) Lib.toggle_auto_gonggi(on) end)
p2.row.Position = UDim2.new(0, 0, 0, 60)
local p3 = createCheckbox(pentathlonContent, "Auto Spinning Top", false, function(on) Lib.toggle_auto_spinning_top(on) end)
p3.row.Position = UDim2.new(0, 0, 0, 90)
local p4 = createCheckbox(pentathlonContent, "Auto Jegi", false, function(on) Lib.toggle_auto_jegi(on) end)
p4.row.Position = UDim2.new(0, 0, 0, 120)

createCheckbox(hnsContent, "Exit Doors ESP", false, function(on) Lib.toggle_exit_door_esp(on) end)
local h1 = createCheckbox(hnsContent, "Keys ESP", false, function(on) Lib.toggle_key_esp(on) end)
h1.row.Position = UDim2.new(0, 0, 0, 30)
local h2 = createCheckbox(hnsContent, "Faster Sprint", false, function(on) Lib.toggle_faster_sprint(on) end)
h2.row.Position = UDim2.new(0, 0, 0, 60)
local h3 = createCheckbox(hnsContent, "Infinite Stamina", false, function(on) Lib.toggle_infinite_stamina(on) end)
h3.row.Position = UDim2.new(0, 0, 0, 90)

local hBtn1 = createActionButton(hnsContent, "Teleport to Hider", function() Lib.teleport_to_hider() end)
hBtn1.Position = UDim2.new(0, 0, 0, 125)
local hBtn2 = createActionButton(hnsContent, "Teleport to Seeker", function() Lib.teleport_to_seeker() end)
hBtn2.Position = UDim2.new(0, 0, 0, 155)
local hBtn3 = createActionButton(hnsContent, "Teleport to Spawn", function() Lib.teleport_to_spawn() end)
hBtn3.Position = UDim2.new(0, 0, 0, 185)
local hBtn4 = createActionButton(hnsContent, "Teleport Random Exit", function() Lib.teleport_random_exit() end)
hBtn4.Position = UDim2.new(0, 0, 0, 215)

createCheckbox(jumpContent, "Jump Rope Antihit (new)", false, function(on) Lib.toggle_jumprope_antihit(on) end)
local j1 = createActionButton(jumpContent, "Delete Rope", function() Lib.remove_rope() end)
j1.Position = UDim2.new(0, 0, 0, 35)
local j2 = createActionButton(jumpContent, "Teleport to Start", function() Lib.teleport_jumprope_start() end)
j2.Position = UDim2.new(0, 0, 0, 65)
local j3 = createActionButton(jumpContent, "Teleport to End", function() Lib.teleport_jumprope_end() end)
j3.Position = UDim2.new(0, 0, 0, 95)

createCheckbox(glassContent, "Glass ESP", false, function(on) Lib.toggle_glass_esp(on) end)
local gl1 = createActionButton(glassContent, "Teleport to End", function() Lib.gb_tp_end() end)
gl1.Position = UDim2.new(0, 0, 0, 35)

createCheckbox(skyContent, "Anti Fall", false, function(on) Lib.toggle_sky_squid_anti_fall(on) end)
local s1 = createCheckbox(skyContent, "Infinite Stamina", false, function(on) Lib.toggle_sky_squid_stamina(on) end)
s1.row.Position = UDim2.new(0, 0, 0, 30)

local gunY = 0
local function addGunToggle(label, callback)
    local cb = createCheckbox(gunsContent, label, false, callback)
    cb.row.Position = UDim2.new(0, 0, 0, gunY)
    gunY = gunY + 30
    return cb
end
addGunToggle("Silent Aim", function(on) Lib.SilentAimEnabled = on; if on then Lib.install_gun_functions_hooks() end end)
addGunToggle("Rebel Silent Aim", function(on) Lib.RebelGuardSilentEnabled = on; if on then Lib.install_gun_functions_hooks() end end)
addGunToggle("Peabert Silent Aim", function(on) Lib.PeabertSilentEnabled = on; if on then Lib.install_gun_functions_hooks() end end)
addGunToggle("Infinite Ammo", function(on) Lib.toggle_infinite_ammo(on) end)
addGunToggle("Rapid Fire", function(on) Lib.toggle_rapid_fire(on) end)
addGunToggle("No Recoil & Spread", function(on) Lib.toggle_no_recoil(on) end)

local allTabs = {
    { tab = tabMisc, content = miscContent },
    { tab = tabDalgona, content = dalgonaContent },
    { tab = tabLights, content = lightsOutContent },
    { tab = tabPenta, content = pentathlonContent },
    { tab = tabHNS, content = hnsContent },
    { tab = tabJump, content = jumpContent },
    { tab = tabGlass, content = glassContent },
    { tab = tabSky, content = skyContent },
    { tab = tabGuns, content = gunsContent },
}

local function switchTab(activeIndex)
    for i, data in ipairs(allTabs) do
        if i == activeIndex then
            data.tab.indicator.BackgroundColor3 = ACCENT
            data.tab.btn.TextColor3 = TEXT
            data.content.Visible = true
        else
            data.tab.indicator.BackgroundColor3 = BORDER
            data.tab.btn.TextColor3 = MUTED
            data.content.Visible = false
        end
    end
end

tabMisc.btn.MouseButton1Click:Connect(function() switchTab(1) end)
tabDalgona.btn.MouseButton1Click:Connect(function() switchTab(2) end)
tabLights.btn.MouseButton1Click:Connect(function() switchTab(3) end)
tabPenta.btn.MouseButton1Click:Connect(function() switchTab(4) end)
tabHNS.btn.MouseButton1Click:Connect(function() switchTab(5) end)
tabJump.btn.MouseButton1Click:Connect(function() switchTab(6) end)
tabGlass.btn.MouseButton1Click:Connect(function() switchTab(7) end)
tabSky.btn.MouseButton1Click:Connect(function() switchTab(8) end)
tabGuns.btn.MouseButton1Click:Connect(function() switchTab(9) end)
switchTab(1)

new("TextLabel", {
    Name = rnd(),
    Size = UDim2.new(1, -16, 0, 16),
    Position = UDim2.new(0, 8, 1, -58),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamMedium,
    TextSize = 10,
    TextColor3 = TEXT,
    Text = "Hide UI - Z",
    TextXAlignment = Enum.TextXAlignment.Left
}, body)

new("TextLabel", {
    Name = rnd(),
    Size = UDim2.new(1, -16, 0, 36),
    Position = UDim2.new(0, 8, 1, -40),
    BackgroundTransparency = 1,
    Font = Enum.Font.Gotham,
    TextSize = 10,
    TextColor3 = MUTED,
    Text = "Ink Games rewrite is releasing soon — join discord.gg/hsx",
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    TextWrapped = true
}, body)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Z then
        main.Visible = not main.Visible
    end
end)

local dragging, dragStart, startPos
main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)
