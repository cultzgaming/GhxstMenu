-- ╔══════════════════════════════════════════════════════════╗
-- ║          GHXST MENU v4 — Lumber Tycoon 2               ║
-- ║  LocalScript → StarterPlayer > StarterPlayerScripts     ║
-- ║                                                          ║
-- ║  FIXES v4:                                               ║
-- ║  • Complete UI redesign (dark slate + cyan accent)       ║
-- ║  • GUI rendered at CoreGui level — never hidden by HUD   ║
-- ║  • All LT2 coordinates verified                          ║
-- ║  • World/Lighting overrides locked so game can't revert  ║
-- ║  • Notification appears centre-screen above all UI       ║
-- ║  • Waypoint system                                       ║
-- ║  • Tree Radar                                            ║
-- ║  • Anti-AFK, Ghost Trail, Crosshair                      ║
-- ║  • Respawn persistence for all toggles                   ║
-- ╚══════════════════════════════════════════════════════════╝

-- ── Services ──────────────────────────────────────────────────
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Lighting         = game:GetService("Lighting")
local CoreGui          = game:GetService("CoreGui")
local SoundService     = game:GetService("SoundService")

-- ╔══════════════════════════════════════════════════════════╗
-- ║  CONFIG — edit here                                      ║
-- ╚══════════════════════════════════════════════════════════╝

local ADMIN_IDS  = { 10920590462, 10886500275 }
local TOGGLE_KEY = Enum.KeyCode.RightShift  -- Changed to RightShift (F9 conflicts with Roblox)

-- ╔══════════════════════════════════════════════════════════╗
-- ║  VERIFIED LT2 COORDINATES                               ║
-- ║  Source: community-verified LT2 maps & Kron script      ║
-- ╚══════════════════════════════════════════════════════════╝

local LOCATIONS = {
    {
        section = "🏠  SPAWN & SHOPS",
        places = {
            { name = "Spawn / Lumber Yard",    sub = "Main spawn area",                  pos = Vector3.new(215,   3,  -25) },
            { name = "Wood Sell Dock",          sub = "💰 Sell your planks here",          pos = Vector3.new(317,   3,   52) },
            { name = "Tool Shop",               sub = "🪓 Axes & basic tools",             pos = Vector3.new(290,   5,  -68) },
            { name = "Wood R Us",               sub = "🛒 Rare wood shop",                 pos = Vector3.new(314,   5, -114) },
            { name = "Link's Logic",            sub = "⚡ Electronics store",              pos = Vector3.new(274,   5,  -44) },
            { name = "Safari Shop",             sub = "🗺️ Vehicles & sawmills",            pos = Vector3.new(246,   5,  -96) },
            { name = "Land Store",              sub = "🏠 Buy land plots",                 pos = Vector3.new(268,   5,   40) },
            { name = "Boat Dock",               sub = "⛵ Water & boat access",            pos = Vector3.new(360,   4,   82) },
        },
    },
    {
        section = "🌲  BIOMES",
        places = {
            { name = "Plains / Oak Forest",     sub = "Oak · Elm · Cherry Blossom",       pos = Vector3.new(215,   3,  -25) },
            { name = "Elm & Cherry Forest",     sub = "Elm · Cherry · Oak",               pos = Vector3.new(352,   5,  280) },
            { name = "Swamp",                   sub = "Swamp · Mangrove",                 pos = Vector3.new(-862,  3,  192) },
            { name = "Taiga",                   sub = "Fir · Pine · Snowglow",            pos = Vector3.new(-556,  8, -752) },
            { name = "Tropics",                 sub = "Palm · Mangrove",                  pos = Vector3.new(1338,  5, -822) },
            { name = "Mushroom Biome",          sub = "Mushroom · Spooky",                pos = Vector3.new(388,   5,-1568) },
            { name = "Fantasy / Sinister",      sub = "Phantasm · Sinister · Koa",        pos = Vector3.new(556,   5,-1646) },
        },
    },
    {
        section = "⛰️  MOUNTAIN",
        places = {
            { name = "Mountain Base",           sub = "Start climbing here",              pos = Vector3.new(-278,  18, -276) },
            { name = "Mountain Ridge",          sub = "Frost · Fir · Pine",               pos = Vector3.new(-426,  78, -428) },
            { name = "Alpine Zone",             sub = "Snowglow · Frost",                 pos = Vector3.new(-448, 148, -598) },
            { name = "Snowglow Peak",           sub = "Best Snowglow spawns",             pos = Vector3.new(-458, 218, -708) },
        },
    },
    {
        section = "🌋  VOLCANO ISLAND",
        places = {
            { name = "Volcano Shore",           sub = "Island landing zone",              pos = Vector3.new(1178,  5,-1018) },
            { name = "Volcano Base",            sub = "Volcano & Lava trees",             pos = Vector3.new(1284, 20,-1058) },
            { name = "Volcano Mid",             sub = "Lava wood mid-slope",              pos = Vector3.new(1294, 68,-1053) },
            { name = "Volcano Peak",            sub = "Lava wood near top",               pos = Vector3.new(1298,113,-1048) },
        },
    },
    {
        section = "🕳️  UNDERGROUND",
        places = {
            { name = "Cave Entrance",           sub = "Drop point into caverns",          pos = Vector3.new(-234,  -3, -268) },
            { name = "Cavern Floor",            sub = "⚠️ Use Fly first! Cavecrawler",   pos = Vector3.new(-252, -26, -293) },
        },
    },
    {
        section = "🌊  WATER",
        places = {
            { name = "Open Ocean",              sub = "Deep water area",                  pos = Vector3.new( 698,   2, -398) },
            { name = "Swamp Waterway",          sub = "Swamp water access",               pos = Vector3.new(-778,  3,  148) },
        },
    },
}

-- ╔══════════════════════════════════════════════════════════╗
-- ║  ADMIN CHECK                                             ║
-- ╚══════════════════════════════════════════════════════════╝

local LP = Players.LocalPlayer

local function isAdmin()
    for _, id in ipairs(ADMIN_IDS) do
        if LP.UserId == id then return true end
    end
    return false
end

if not isAdmin() then
    warn("[GhxstMenu v4] Access denied — UserId: " .. LP.UserId)
    return
end

-- ╔══════════════════════════════════════════════════════════╗
-- ║  STATE                                                   ║
-- ╚══════════════════════════════════════════════════════════╝

local S = {
    -- toggles
    fly          = false,
    god          = false,
    noclip       = false,
    infJump      = false,
    autoChop     = false,
    esp          = false,
    crosshair    = false,
    trail        = false,
    antiAfk      = false,
    soundMuted   = false,
    lightLocked  = false,
    open         = false,

    -- values
    flySpeed     = 60,
    walkSpeed    = 16,
    jumpPower    = 50,
    tab          = "home",

    -- connections
    flyConn      = nil,
    noclipConn   = nil,
    chopConn     = nil,
    jumpConn     = nil,
    trailConn    = nil,
    lightConn    = nil,

    -- instances
    bv           = nil,
    bg           = nil,
    noclipParts  = {},
    espTags      = {},
    waypoints    = {},
    sessionStart = tick(),

    -- locked lighting values
    lockedTime   = 14,
    lockedBright = 2,
    lockedFog    = 100000,
}

-- ╔══════════════════════════════════════════════════════════╗
-- ║  PALETTE                                                 ║
-- ╚══════════════════════════════════════════════════════════╝

local P = {
    bg0      = Color3.fromRGB(13,  17,  23),   -- deepest bg
    bg1      = Color3.fromRGB(18,  24,  32),   -- panel bg
    bg2      = Color3.fromRGB(24,  32,  44),   -- card bg
    bg3      = Color3.fromRGB(32,  42,  58),   -- card hover
    sidebar  = Color3.fromRGB(10,  14,  20),   -- sidebar
    accent   = Color3.fromRGB(0,  188, 212),   -- cyan
    accentD  = Color3.fromRGB(0,  120, 140),   -- cyan dark
    accentDim= Color3.fromRGB(0,   40,  50),   -- cyan very dim
    gold     = Color3.fromRGB(255, 196,  0),   -- gold for LT2 items
    white    = Color3.fromRGB(220, 228, 240),
    muted    = Color3.fromRGB(100, 120, 150),
    dim      = Color3.fromRGB(50,  65,  85),
    divider  = Color3.fromRGB(28,  38,  52),
    red      = Color3.fromRGB(220,  60,  60),
    green    = Color3.fromRGB(50,  200, 100),
    orange   = Color3.fromRGB(255, 140,  40),
}

-- ╔══════════════════════════════════════════════════════════╗
-- ║  GUI ROOT — CoreGui so it's NEVER hidden by Roblox UI   ║
-- ╚══════════════════════════════════════════════════════════╝

-- Clean up old instance
pcall(function()
    if CoreGui:FindFirstChild("GhxstV4") then
        CoreGui.GhxstV4:Destroy()
    end
end)

local gui = Instance.new("ScreenGui")
gui.Name            = "GhxstV4"
gui.ResetOnSpawn    = false
gui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset  = true
gui.DisplayOrder    = 999   -- render on top of everything
pcall(function() gui.Parent = CoreGui end)  -- CoreGui = above all Roblox UI
if not gui.Parent then gui.Parent = LP.PlayerGui end  -- fallback

-- ╔══════════════════════════════════════════════════════════╗
-- ║  NOTIFICATION SYSTEM — centre screen, above all         ║
-- ╚══════════════════════════════════════════════════════════╝

local notifFrame = Instance.new("Frame", gui)
notifFrame.Name              = "NotifHolder"
notifFrame.Size              = UDim2.new(0, 360, 0, 48)
notifFrame.Position          = UDim2.new(0.5, -180, 0, 24)  -- top-centre
notifFrame.BackgroundColor3  = P.bg2
notifFrame.BorderSizePixel   = 0
notifFrame.BackgroundTransparency = 1
notifFrame.ZIndex            = 100
Instance.new("UICorner", notifFrame).CornerRadius = UDim.new(0, 10)
local notifStroke = Instance.new("UIStroke", notifFrame)
notifStroke.Color = P.accent; notifStroke.Thickness = 1.5; notifStroke.Transparency = 1

local notifIcon = Instance.new("TextLabel", notifFrame)
notifIcon.Size                  = UDim2.new(0, 36, 1, 0)
notifIcon.BackgroundTransparency = 1
notifIcon.Text                  = "👻"
notifIcon.TextSize              = 18
notifIcon.Font                  = Enum.Font.Gotham
notifIcon.ZIndex                = 101

local notifLine = Instance.new("Frame", notifFrame)
notifLine.Size              = UDim2.new(0, 1, 0, 28)
notifLine.Position          = UDim2.new(0, 36, 0.5, -14)
notifLine.BackgroundColor3  = P.dim
notifLine.BorderSizePixel   = 0
notifLine.ZIndex            = 101

local notifText = Instance.new("TextLabel", notifFrame)
notifText.Size               = UDim2.new(1, -48, 1, 0)
notifText.Position           = UDim2.new(0, 44, 0, 0)
notifText.BackgroundTransparency = 1
notifText.Text               = ""
notifText.TextColor3         = P.white
notifText.Font               = Enum.Font.GothamSemibold
notifText.TextSize           = 13
notifText.TextXAlignment     = Enum.TextXAlignment.Left
notifText.TextTruncate       = Enum.TextTruncate.AtEnd
notifText.ZIndex             = 101

local notifTween
local function notify(msg, icon)
    notifIcon.Text = icon or "✅"
    notifText.Text = msg
    notifFrame.BackgroundTransparency = 0
    notifStroke.Transparency = 0

    -- slide in from top
    notifFrame.Position = UDim2.new(0.5, -180, 0, -60)
    TweenService:Create(notifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        { Position = UDim2.new(0.5, -180, 0, 24) }):Play()

    if notifTween then notifTween:Cancel() end
    notifTween = TweenService:Create(notifFrame,
        TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 2.5),
        { BackgroundTransparency = 1 })
    notifTween:Play()
    notifTween.Completed:Connect(function()
        notifStroke.Transparency = 1
        notifText.Text = ""
    end)
end

-- ╔══════════════════════════════════════════════════════════╗
-- ║  CROSSHAIR                                               ║
-- ╚══════════════════════════════════════════════════════════╝

local xhair = Instance.new("Frame", gui)
xhair.Name = "Crosshair"; xhair.Visible = false; xhair.ZIndex = 50
xhair.Size = UDim2.new(0,1,0,1); xhair.Position = UDim2.new(0.5,0,0.5,0)
xhair.BackgroundTransparency = 1; xhair.BorderSizePixel = 0

local function xLine(w,h,ox,oy)
    local f = Instance.new("Frame", xhair)
    f.Size = UDim2.new(0,w,0,h)
    f.Position = UDim2.new(0,-w/2+ox, 0,-h/2+oy)
    f.BackgroundColor3 = P.accent; f.BorderSizePixel = 0; f.ZIndex = 51
    Instance.new("UICorner", f).CornerRadius = UDim.new(1,0)
end
xLine(18, 2,  0, 0)
xLine(2, 18,  0, 0)
xLine(6,  1,  0,-10)
xLine(6,  1,  0, 10)
xLine(1,  6,-10,  0)
xLine(1,  6, 10,  0)

-- ╔══════════════════════════════════════════════════════════╗
-- ║  TOGGLE PILL                                             ║
-- ╚══════════════════════════════════════════════════════════╝

local pill = Instance.new("TextButton", gui)
pill.Size             = UDim2.new(0, 130, 0, 32)
pill.Position         = UDim2.new(0, 12, 0, 12)
pill.BackgroundColor3 = P.bg1
pill.TextColor3       = P.accent
pill.Font             = Enum.Font.GothamBold
pill.TextSize         = 12
pill.Text             = "👻  GHXST  [RShift]"
pill.BorderSizePixel  = 0
pill.ZIndex           = 10
pill.Parent           = gui
Instance.new("UICorner", pill).CornerRadius = UDim.new(0, 8)
local pillStroke = Instance.new("UIStroke", pill)
pillStroke.Color = P.accentD; pillStroke.Thickness = 1

-- ╔══════════════════════════════════════════════════════════╗
-- ║  MAIN WINDOW                                             ║
-- ╚══════════════════════════════════════════════════════════╝

local WIN_W, WIN_H = 680, 460
local win = Instance.new("Frame", gui)
win.Name             = "Win"
win.Size             = UDim2.new(0, WIN_W, 0, WIN_H)
win.Position         = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2)
win.BackgroundColor3 = P.bg0
win.BorderSizePixel  = 0
win.Visible          = false
win.ZIndex           = 20
Instance.new("UICorner", win).CornerRadius = UDim.new(0, 12)
local winStroke = Instance.new("UIStroke", win)
winStroke.Color = P.accentD; winStroke.Thickness = 1

-- ── Title bar ─────────────────────────────────────────────────
local titleBar = Instance.new("Frame", win)
titleBar.Size             = UDim2.new(1, 0, 0, 44)
titleBar.BackgroundColor3 = P.bg1
titleBar.BorderSizePixel  = 0
titleBar.ZIndex           = 21
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)
-- fill bottom corners of titlebar
local tbFix = Instance.new("Frame", titleBar)
tbFix.Size = UDim2.new(1,0,0,12); tbFix.Position = UDim2.new(0,0,1,-12)
tbFix.BackgroundColor3 = P.bg1; tbFix.BorderSizePixel = 0; tbFix.ZIndex = 21

-- Accent left stripe
local titleAccent = Instance.new("Frame", titleBar)
titleAccent.Size = UDim2.new(0,3,0,22); titleAccent.Position = UDim2.new(0,12,0.5,-11)
titleAccent.BackgroundColor3 = P.accent; titleAccent.BorderSizePixel = 0; titleAccent.ZIndex = 22
Instance.new("UICorner", titleAccent).CornerRadius = UDim.new(1,0)

-- Rainbow letters "GHXST"
local LETTERS = "GHXST"
local ghxStrokes = {}
for i = 1, #LETTERS do
    local lbl = Instance.new("TextLabel", titleBar)
    lbl.Size = UDim2.new(0,16,0,28); lbl.Position = UDim2.new(0, 22+(i-1)*16, 0.5, -14)
    lbl.BackgroundTransparency = 1; lbl.Text = LETTERS:sub(i,i)
    lbl.TextColor3 = P.white; lbl.Font = Enum.Font.GothamBlack; lbl.TextSize = 16; lbl.ZIndex = 23
    local st = Instance.new("UIStroke", lbl)
    st.Color = Color3.fromRGB(0,200,255); st.Thickness = 1.5
    st.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    ghxStrokes[i] = st
end

local titleSub = Instance.new("TextLabel", titleBar)
titleSub.Size = UDim2.new(0,200,0,18); titleSub.Position = UDim2.new(0,106,0.5,-9)
titleSub.BackgroundTransparency = 1; titleSub.Text = "v4  ·  LT2 Admin"
titleSub.TextColor3 = P.muted; titleSub.Font = Enum.Font.Gotham; titleSub.TextSize = 11
titleSub.TextXAlignment = Enum.TextXAlignment.Left; titleSub.ZIndex = 22

-- Window controls (macOS-style)
local function makeDot(xOff, col, hov)
    local b = Instance.new("TextButton", titleBar)
    b.Size = UDim2.new(0,12,0,12); b.Position = UDim2.new(1,xOff,0.5,-6)
    b.BackgroundColor3 = col; b.Text = ""; b.BorderSizePixel = 0; b.ZIndex = 22
    Instance.new("UICorner", b).CornerRadius = UDim.new(1,0)
    b.MouseEnter:Connect(function() b.BackgroundColor3 = hov end)
    b.MouseLeave:Connect(function() b.BackgroundColor3 = col end)
    return b
end
local closeBtn = makeDot(-24, Color3.fromRGB(255,96,92),  Color3.fromRGB(255,140,136))
local minBtn   = makeDot(-42, Color3.fromRGB(255,189,68), Color3.fromRGB(255,210,120))

-- Divider below titlebar
local titleDiv = Instance.new("Frame", win)
titleDiv.Size = UDim2.new(1,0,0,1); titleDiv.Position = UDim2.new(0,0,0,44)
titleDiv.BackgroundColor3 = P.divider; titleDiv.BorderSizePixel = 0; titleDiv.ZIndex = 21

-- Rainbow animation
local rbTime = 0
RunService.Heartbeat:Connect(function(dt)
    if not S.open then return end
    rbTime = (rbTime + dt * 0.6) % 1
    for i, st in ipairs(ghxStrokes) do
        st.Color = Color3.fromHSV((rbTime + (i-1)*0.18) % 1, 0.9, 1)
    end
end)

-- ── Sidebar ───────────────────────────────────────────────────
local SIDEBAR_W = 158
local sidebar = Instance.new("Frame", win)
sidebar.Size             = UDim2.new(0, SIDEBAR_W, 1, -45)
sidebar.Position         = UDim2.new(0, 0, 0, 45)
sidebar.BackgroundColor3 = P.sidebar
sidebar.BorderSizePixel  = 0
sidebar.ZIndex           = 21
-- fill right-side corners
local sbFill = Instance.new("Frame", sidebar)
sbFill.Size = UDim2.new(0,12,1,0); sbFill.Position = UDim2.new(1,-12,0,0)
sbFill.BackgroundColor3 = P.sidebar; sbFill.BorderSizePixel = 0; sbFill.ZIndex = 21
-- bottom-left corner fill
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0,12)
local sbBottomFill = Instance.new("Frame", sidebar)
sbBottomFill.Size = UDim2.new(1,0,0,12); sbBottomFill.Position = UDim2.new(0,0,1,-12)
sbBottomFill.BackgroundColor3 = P.sidebar; sbBottomFill.BorderSizePixel = 0; sbBottomFill.ZIndex = 21

local sbDivider = Instance.new("Frame", sidebar)
sbDivider.Size = UDim2.new(0,1,1,0); sbDivider.Position = UDim2.new(1,-1,0,0)
sbDivider.BackgroundColor3 = P.divider; sbDivider.BorderSizePixel = 0; sbDivider.ZIndex = 22

-- Nav items
local navList = Instance.new("Frame", sidebar)
navList.Size = UDim2.new(1,0,1,0)
navList.BackgroundTransparency = 1; navList.BorderSizePixel = 0; navList.ZIndex = 22
local navLayout = Instance.new("UIListLayout", navList)
navLayout.Padding = UDim.new(0,4)
navLayout.FillDirection = Enum.FillDirection.Vertical
navLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
local navPad = Instance.new("UIPadding", navList)
navPad.PaddingTop = UDim.new(0,10)
navPad.PaddingLeft = UDim.new(0,8); navPad.PaddingRight = UDim.new(0,8)

-- ── Content area ──────────────────────────────────────────────
local content = Instance.new("Frame", win)
content.Size = UDim2.new(1, -SIDEBAR_W, 1, -45)
content.Position = UDim2.new(0, SIDEBAR_W, 0, 45)
content.BackgroundColor3 = P.bg1
content.BorderSizePixel = 0
content.ClipsDescendants = true
content.ZIndex = 21
-- fill left side corners
local cFill = Instance.new("Frame", content)
cFill.Size = UDim2.new(0,12,1,0); cFill.BackgroundColor3 = P.bg1; cFill.BorderSizePixel = 0; cFill.ZIndex = 21
-- bottom-right corner
Instance.new("UICorner", content).CornerRadius = UDim.new(0,12)
local cBottomFill = Instance.new("Frame", content)
cBottomFill.Size = UDim2.new(1,0,0,12); cBottomFill.Position = UDim2.new(0,0,1,-12)
cBottomFill.BackgroundColor3 = P.bg1; cBottomFill.BorderSizePixel = 0; cBottomFill.ZIndex = 21

-- ╔══════════════════════════════════════════════════════════╗
-- ║  TAB SYSTEM                                              ║
-- ╚══════════════════════════════════════════════════════════╝

local TABS = {
    { id="home",      icon="⌂",  label="Home"      },
    { id="player",    icon="⚙",  label="Player"    },
    { id="teleport",  icon="◎",  label="Teleport"  },
    { id="waypoints", icon="⚑",  label="Waypoints" },
    { id="radar",     icon="⊙",  label="Radar"     },
    { id="world",     icon="☀",  label="World"     },
    { id="esp",       icon="◉",  label="ESP"       },
    { id="settings",  icon="≡",  label="Settings"  },
}

local tabBtns  = {}
local tabPages = {}

local function switchTab(id)
    S.tab = id
    for tid, pg in pairs(tabPages)  do pg.Visible = (tid == id) end
    for tid, btn in pairs(tabBtns) do
        local bg  = btn:FindFirstChild("BG")
        local lbl = btn:FindFirstChild("Lbl")
        local ico = btn:FindFirstChild("Ico")
        local bar = btn:FindFirstChild("Bar")
        if tid == id then
            if bg  then bg.BackgroundTransparency  = 0    end
            if lbl then lbl.TextColor3 = P.white          end
            if ico then ico.TextColor3 = P.accent         end
            if bar then bar.Visible    = true              end
        else
            if bg  then bg.BackgroundTransparency  = 1    end
            if lbl then lbl.TextColor3 = P.muted          end
            if ico then ico.TextColor3 = P.muted          end
            if bar then bar.Visible    = false             end
        end
    end
end

local function makeNavBtn(td)
    local btn = Instance.new("TextButton", navList)
    btn.Size = UDim2.new(1,0,0,38); btn.BackgroundTransparency = 1
    btn.BorderSizePixel = 0; btn.Text = ""; btn.ZIndex = 23
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

    local bg = Instance.new("Frame", btn); bg.Name = "BG"
    bg.Size = UDim2.new(1,0,1,0); bg.BackgroundColor3 = P.accentDim
    bg.BorderSizePixel = 0; bg.ZIndex = 23; bg.BackgroundTransparency = 1
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0,8)

    local bar = Instance.new("Frame", btn); bar.Name = "Bar"
    bar.Size = UDim2.new(0,3,0,20); bar.Position = UDim2.new(0,0,0.5,-10)
    bar.BackgroundColor3 = P.accent; bar.BorderSizePixel = 0; bar.Visible = false; bar.ZIndex = 24
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1,0)

    local ico = Instance.new("TextLabel", btn); ico.Name = "Ico"
    ico.Size = UDim2.new(0,26,1,0); ico.Position = UDim2.new(0,8,0,0)
    ico.BackgroundTransparency = 1; ico.Text = td.icon
    ico.TextSize = 14; ico.Font = Enum.Font.GothamBold
    ico.TextColor3 = P.muted; ico.TextXAlignment = Enum.TextXAlignment.Center; ico.ZIndex = 24

    local lbl = Instance.new("TextLabel", btn); lbl.Name = "Lbl"
    lbl.Size = UDim2.new(1,-38,1,0); lbl.Position = UDim2.new(0,36,0,0)
    lbl.BackgroundTransparency = 1; lbl.Text = td.label
    lbl.TextColor3 = P.muted; lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 12; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 24

    local tw = TweenInfo.new(0.12)
    btn.MouseEnter:Connect(function()
        if S.tab ~= td.id then
            TweenService:Create(bg,  tw, {BackgroundTransparency=0.7}):Play()
            TweenService:Create(lbl, tw, {TextColor3=P.white}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if S.tab ~= td.id then
            TweenService:Create(bg,  tw, {BackgroundTransparency=1}):Play()
            TweenService:Create(lbl, tw, {TextColor3=P.muted}):Play()
        end
    end)
    btn.MouseButton1Click:Connect(function() switchTab(td.id) end)
    tabBtns[td.id] = btn
end

for _, t in ipairs(TABS) do makeNavBtn(t) end

-- ╔══════════════════════════════════════════════════════════╗
-- ║  PAGE / WIDGET HELPERS                                   ║
-- ╚══════════════════════════════════════════════════════════╝

local function makePage(id)
    local pg = Instance.new("ScrollingFrame", content)
    pg.Name = id
    pg.Size = UDim2.new(1,0,1,0)
    pg.BackgroundTransparency = 1; pg.BorderSizePixel = 0
    pg.ScrollBarThickness = 3; pg.ScrollBarImageColor3 = P.accentD
    pg.CanvasSize = UDim2.new(0,0,0,0)
    pg.AutomaticCanvasSize = Enum.AutomaticSize.Y
    pg.Visible = false; pg.ZIndex = 22
    local lay = Instance.new("UIListLayout", pg)
    lay.Padding = UDim.new(0,6); lay.FillDirection = Enum.FillDirection.Vertical
    lay.HorizontalAlignment = Enum.HorizontalAlignment.Center
    local pad = Instance.new("UIPadding", pg)
    pad.PaddingTop = UDim.new(0,12); pad.PaddingBottom = UDim.new(0,14)
    pad.PaddingLeft = UDim.new(0,12); pad.PaddingRight = UDim.new(0,12)
    tabPages[id] = pg
    return pg
end

local function secLabel(parent, txt)
    local l = Instance.new("TextLabel", parent)
    l.Size = UDim2.new(1,0,0,20); l.BackgroundTransparency = 1
    l.Text = txt:upper(); l.TextColor3 = P.accentD
    l.Font = Enum.Font.GothamBold; l.TextSize = 9
    l.TextXAlignment = Enum.TextXAlignment.Left; l.ZIndex = 23
    return l
end

-- Row button (action)
local function rowBtn(parent, label, sub, cb)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1,0,0, sub and 50 or 38)
    btn.BackgroundColor3 = P.bg2; btn.BorderSizePixel = 0; btn.Text = ""; btn.ZIndex = 23
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

    local nameL = Instance.new("TextLabel", btn)
    nameL.Size = UDim2.new(1,-36,0,20)
    nameL.Position = UDim2.new(0,12,0, sub and 7 or 9)
    nameL.BackgroundTransparency = 1; nameL.Text = label
    nameL.TextColor3 = P.white; nameL.Font = Enum.Font.GothamSemibold
    nameL.TextSize = 12; nameL.TextXAlignment = Enum.TextXAlignment.Left; nameL.ZIndex = 24

    if sub then
        local subL = Instance.new("TextLabel", btn)
        subL.Size = UDim2.new(1,-36,0,14); subL.Position = UDim2.new(0,12,0,26)
        subL.BackgroundTransparency = 1; subL.Text = sub
        subL.TextColor3 = P.muted; subL.Font = Enum.Font.Gotham
        subL.TextSize = 10; subL.TextXAlignment = Enum.TextXAlignment.Left; subL.ZIndex = 24
    end

    local arr = Instance.new("TextLabel", btn)
    arr.Size = UDim2.new(0,18,1,0); arr.Position = UDim2.new(1,-22,0,0)
    arr.BackgroundTransparency = 1; arr.Text = "›"
    arr.TextColor3 = P.dim; arr.Font = Enum.Font.GothamBold; arr.TextSize = 18; arr.ZIndex = 24

    local tw = TweenInfo.new(0.1)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, tw, {BackgroundColor3=P.bg3}):Play()
        TweenService:Create(arr, tw, {TextColor3=P.accent}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, tw, {BackgroundColor3=P.bg2}):Play()
        TweenService:Create(arr, tw, {TextColor3=P.dim}):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.06), {BackgroundColor3=P.accentDim}):Play()
        task.delay(0.12, function()
            TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3=P.bg2}):Play()
        end)
        if cb then task.spawn(cb) end
    end)
    return btn, arr
end

-- Toggle row
local function togRow(parent, label, sub, cb)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1,0,0, sub and 50 or 38)
    row.BackgroundColor3 = P.bg2; row.BorderSizePixel = 0; row.ZIndex = 23
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,8)

    local nameL = Instance.new("TextLabel", row)
    nameL.Size = UDim2.new(1,-60,0,20)
    nameL.Position = UDim2.new(0,12,0, sub and 7 or 9)
    nameL.BackgroundTransparency = 1; nameL.Text = label
    nameL.TextColor3 = P.white; nameL.Font = Enum.Font.GothamSemibold
    nameL.TextSize = 12; nameL.TextXAlignment = Enum.TextXAlignment.Left; nameL.ZIndex = 24

    if sub then
        local subL = Instance.new("TextLabel", row)
        subL.Size = UDim2.new(1,-60,0,14); subL.Position = UDim2.new(0,12,0,26)
        subL.BackgroundTransparency = 1; subL.Text = sub
        subL.TextColor3 = P.muted; subL.Font = Enum.Font.Gotham
        subL.TextSize = 10; subL.TextXAlignment = Enum.TextXAlignment.Left; subL.ZIndex = 24
    end

    -- Toggle pill
    local pilBg = Instance.new("Frame", row)
    pilBg.Size = UDim2.new(0,40,0,20); pilBg.Position = UDim2.new(1,-52,0.5,-10)
    pilBg.BackgroundColor3 = P.dim; pilBg.BorderSizePixel = 0; pilBg.ZIndex = 24
    Instance.new("UICorner", pilBg).CornerRadius = UDim.new(1,0)

    local knob = Instance.new("Frame", pilBg)
    knob.Size = UDim2.new(0,14,0,14); knob.Position = UDim2.new(0,3,0.5,-7)
    knob.BackgroundColor3 = P.white; knob.BorderSizePixel = 0; knob.ZIndex = 25
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

    local isOn = false
    local tw = TweenInfo.new(0.15, Enum.EasingStyle.Quad)
    local function setVis(state)
        isOn = state
        if state then
            TweenService:Create(pilBg, tw, {BackgroundColor3=P.accent}):Play()
            TweenService:Create(knob,  tw, {Position=UDim2.new(0,23,0.5,-7)}):Play()
        else
            TweenService:Create(pilBg, tw, {BackgroundColor3=P.dim}):Play()
            TweenService:Create(knob,  tw, {Position=UDim2.new(0,3,0.5,-7)}):Play()
        end
    end

    local hit = Instance.new("TextButton", row)
    hit.Size = UDim2.new(1,0,1,0); hit.BackgroundTransparency = 1; hit.Text = ""; hit.ZIndex = 25
    hit.MouseButton1Click:Connect(function()
        setVis(not isOn); cb(isOn)
    end)
    return row, setVis
end

-- Slider
local function slider(parent, label, minV, maxV, default, cb)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1,0,0,52); frame.BackgroundColor3 = P.bg2
    frame.BorderSizePixel = 0; frame.ZIndex = 23
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,8)
    local pad = Instance.new("UIPadding", frame)
    pad.PaddingLeft = UDim.new(0,12); pad.PaddingRight = UDim.new(0,12); pad.PaddingTop = UDim.new(0,8)

    local nameL = Instance.new("TextLabel", frame)
    nameL.Size = UDim2.new(0.7,0,0,18); nameL.BackgroundTransparency = 1
    nameL.Text = label; nameL.TextColor3 = P.white
    nameL.Font = Enum.Font.GothamSemibold; nameL.TextSize = 12
    nameL.TextXAlignment = Enum.TextXAlignment.Left; nameL.ZIndex = 24

    local valL = Instance.new("TextLabel", frame)
    valL.Size = UDim2.new(0.3,0,0,18); valL.Position = UDim2.new(0.7,0,0,0)
    valL.BackgroundTransparency = 1; valL.Text = tostring(default)
    valL.TextColor3 = P.accent; valL.Font = Enum.Font.GothamBold
    valL.TextSize = 12; valL.TextXAlignment = Enum.TextXAlignment.Right; valL.ZIndex = 24

    local track = Instance.new("Frame", frame)
    track.Size = UDim2.new(1,0,0,4); track.Position = UDim2.new(0,0,0,30)
    track.BackgroundColor3 = P.dim; track.BorderSizePixel = 0; track.ZIndex = 24
    Instance.new("UICorner", track).CornerRadius = UDim.new(1,0)

    local r0 = (default - minV) / (maxV - minV)
    local fill = Instance.new("Frame", track)
    fill.Size = UDim2.new(r0,0,1,0); fill.BackgroundColor3 = P.accent
    fill.BorderSizePixel = 0; fill.ZIndex = 25
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)

    local knob = Instance.new("TextButton", track)
    knob.Size = UDim2.new(0,14,0,14); knob.Position = UDim2.new(r0,-7,0.5,-7)
    knob.BackgroundColor3 = P.accent; knob.Text = ""; knob.BorderSizePixel = 0; knob.ZIndex = 26
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

    local dragging = false
    local mc, ec
    knob.MouseButton1Down:Connect(function()
        dragging = true
        mc = UserInputService.InputChanged:Connect(function(inp)
            if not dragging or inp.UserInputType ~= Enum.UserInputType.MouseMovement then return end
            local r = math.clamp((inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local v = math.floor(minV + r*(maxV-minV))
            fill.Size = UDim2.new(r,0,1,0); knob.Position = UDim2.new(r,-7,0.5,-7)
            valL.Text = tostring(v); cb(v)
        end)
        ec = UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
                if mc then mc:Disconnect(); mc = nil end
                if ec then ec:Disconnect(); ec = nil end
            end
        end)
    end)
end

-- Info card (coloured banner)
local function infoCard(parent, txt, col)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1,0,0,36); f.BackgroundColor3 = col or P.accentDim
    f.BorderSizePixel = 0; f.ZIndex = 23
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,8)
    local stroke = Instance.new("UIStroke", f)
    stroke.Color = col and col or P.accentD; stroke.Thickness = 1
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1,-16,1,0); l.Position = UDim2.new(0,8,0,0)
    l.BackgroundTransparency = 1; l.Text = txt; l.TextWrapped = true
    l.TextColor3 = col and P.white or P.accent
    l.Font = Enum.Font.Gotham; l.TextSize = 10
    l.TextXAlignment = Enum.TextXAlignment.Left; l.ZIndex = 24
    return f
end

-- ╔══════════════════════════════════════════════════════════╗
-- ║  CORE FEATURE FUNCTIONS                                  ║
-- ╚══════════════════════════════════════════════════════════╝

-- ── Teleport ──────────────────────────────────────────────────
local function tpTo(pos, name)
    local char = LP.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(pos + Vector3.new(0,4,0))
        notify("Teleported → " .. name, "📍")
    else
        notify("No character found", "❌")
    end
end

-- ── Fly ───────────────────────────────────────────────────────
local function enableFly()
    local char = LP.Character; if not char then return end
    local hrp  = char:FindFirstChild("HumanoidRootPart")
    local hum  = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    hum.PlatformStand = true

    S.bv = Instance.new("BodyVelocity", hrp)
    S.bv.Velocity  = Vector3.zero
    S.bv.MaxForce  = Vector3.new(1e5,1e5,1e5)

    S.bg = Instance.new("BodyGyro", hrp)
    S.bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
    S.bg.D = 100; S.bg.CFrame = hrp.CFrame

    S.flyConn = RunService.Heartbeat:Connect(function()
        if not S.fly then return end
        local cam = workspace.CurrentCamera
        local dir = Vector3.zero
        local UIS = UserInputService
        if UIS:IsKeyDown(Enum.KeyCode.W)         then dir += cam.CFrame.LookVector  end
        if UIS:IsKeyDown(Enum.KeyCode.S)         then dir -= cam.CFrame.LookVector  end
        if UIS:IsKeyDown(Enum.KeyCode.A)         then dir -= cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D)         then dir += cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space)     then dir += Vector3.yAxis          end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.yAxis          end
        if dir.Magnitude > 0 then dir = dir.Unit end
        S.bv.Velocity = dir * S.flySpeed
        local look = cam.CFrame.LookVector
        local flat = Vector3.new(look.X,0,look.Z)
        if flat.Magnitude > 0 then
            S.bg.CFrame = CFrame.new(Vector3.zero, flat)
        end
    end)
    notify("Fly enabled — WASD + Space/Shift", "✈️")
end

local function disableFly()
    local char = LP.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = false end
    if S.flyConn then S.flyConn:Disconnect(); S.flyConn = nil end
    if S.bv then S.bv:Destroy(); S.bv = nil end
    if S.bg then S.bg:Destroy(); S.bg = nil end
    notify("Fly disabled", "✈️")
end

-- ── God ───────────────────────────────────────────────────────
local godConn
local function enableGod()
    local char = LP.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    hum.MaxHealth = 1e6; hum.Health = 1e6
    godConn = hum.HealthChanged:Connect(function(h)
        if S.god and h < 1e6 then hum.Health = 1e6 end
    end)
    notify("God Mode ON — 1M HP", "🛡️")
end

local function disableGod()
    local char = LP.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.MaxHealth = 100; hum.Health = 100 end
    if godConn then godConn:Disconnect(); godConn = nil end
    notify("God Mode OFF", "🛡️")
end

-- ── NoClip ────────────────────────────────────────────────────
local function buildNoclipCache()
    local char = LP.Character; if not char then return end
    S.noclipParts = {}
    for _, d in ipairs(char:GetDescendants()) do
        if d:IsA("BasePart") then table.insert(S.noclipParts, d) end
    end
    char.DescendantAdded:Connect(function(d)
        if d:IsA("BasePart") then table.insert(S.noclipParts, d) end
    end)
end

local function enableNoclip()
    buildNoclipCache()
    S.noclipConn = RunService.Stepped:Connect(function()
        for _, p in ipairs(S.noclipParts) do
            if p and p.Parent then p.CanCollide = false end
        end
    end)
    notify("NoClip ON", "👻")
end

local function disableNoclip()
    if S.noclipConn then S.noclipConn:Disconnect(); S.noclipConn = nil end
    for _, p in ipairs(S.noclipParts) do
        if p and p.Parent then p.CanCollide = true end
    end
    S.noclipParts = {}
    notify("NoClip OFF", "👻")
end

-- ── Infinite Jump ─────────────────────────────────────────────
local function enableInfJump()
    S.jumpConn = UserInputService.JumpRequest:Connect(function()
        local char = LP.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
    notify("Infinite Jump ON", "🐇")
end

local function disableInfJump()
    if S.jumpConn then S.jumpConn:Disconnect(); S.jumpConn = nil end
    notify("Infinite Jump OFF", "🐇")
end

-- ── Auto-Chop ────────────────────────────────────────────────
local function enableAutoChop()
    S.chopConn = RunService.Heartbeat:Connect(function()
        local char = LP.Character; if not char then return end
        local tool = char:FindFirstChildOfClass("Tool"); if not tool then return end
        local re = tool:FindFirstChild("Chop", true) or tool:FindFirstChildOfClass("RemoteEvent")
        if re then pcall(function() re:FireServer() end) end
    end)
    notify("Auto-Chop ON", "🪓")
end

local function disableAutoChop()
    if S.chopConn then S.chopConn:Disconnect(); S.chopConn = nil end
    notify("Auto-Chop OFF", "🪓")
end

-- ── Anti-AFK ──────────────────────────────────────────────────
local function enableAntiAfk()
    task.spawn(function()
        while S.antiAfk do
            task.wait(55)
            if not S.antiAfk then break end
            local char = LP.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local orig = hrp.CFrame
                hrp.CFrame = orig * CFrame.new(0,0,0.1)
                task.wait(0.1)
                hrp.CFrame = orig
            end
        end
    end)
    notify("Anti-AFK ON — nudges every 55s", "💤")
end

-- ── Ghost Trail ───────────────────────────────────────────────
local function enableTrail()
    S.trailConn = RunService.Heartbeat:Connect(function()
        if not S.trail then return end
        local char = LP.Character; if not char then return end
        local hrp  = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        local g = Instance.new("Part", workspace)
        g.Size = Vector3.new(2,2,1); g.CFrame = hrp.CFrame
        g.Anchored = true; g.CanCollide = false
        g.Material = Enum.Material.Neon; g.Color = P.accent
        g.Transparency = 0.2; g.CastShadow = false
        TweenService:Create(g, TweenInfo.new(0.5, Enum.EasingStyle.Linear),
            {Transparency=1, Size=Vector3.new(2.6,2.6,1.4)}):Play()
        game:GetService("Debris"):AddItem(g, 0.55)
    end)
    notify("Ghost Trail ON", "✨")
end

local function disableTrail()
    if S.trailConn then S.trailConn:Disconnect(); S.trailConn = nil end
    notify("Ghost Trail OFF", "✨")
end

-- ── Lighting lock (prevents LT2 reverting changes) ───────────
--  LT2 runs a day/night cycle via server scripts.
--  We override every Heartbeat to keep our chosen values.
local function enableLightLock(time, bright, fog)
    S.lockedTime   = time   or S.lockedTime
    S.lockedBright = bright or S.lockedBright
    S.lockedFog    = fog    or S.lockedFog
    if S.lightConn then S.lightConn:Disconnect() end
    S.lightLocked = true
    S.lightConn = RunService.Heartbeat:Connect(function()
        if not S.lightLocked then return end
        Lighting.ClockTime  = S.lockedTime
        Lighting.Brightness = S.lockedBright
        Lighting.FogEnd     = S.lockedFog
    end)
end

local function disableLightLock()
    S.lightLocked = false
    if S.lightConn then S.lightConn:Disconnect(); S.lightConn = nil end
end

-- ── ESP ───────────────────────────────────────────────────────
local function removeESP(pl)
    if S.espTags[pl] then S.espTags[pl]:Destroy(); S.espTags[pl] = nil end
end

local function addESP(pl)
    if pl == LP or S.espTags[pl] then return end
    local function attach(char)
        local hrp = char and char:WaitForChild("HumanoidRootPart", 5)
        if not hrp then return end
        local bb = Instance.new("BillboardGui", hrp)
        bb.Name = "GESP"; bb.Size = UDim2.new(0,140,0,38)
        bb.StudsOffset = Vector3.new(0,4,0); bb.AlwaysOnTop = true; bb.Adornee = hrp

        local bg = Instance.new("Frame", bb)
        bg.Size = UDim2.new(1,0,1,0); bg.BackgroundColor3 = P.bg0
        bg.BackgroundTransparency = 0.3; bg.BorderSizePixel = 0
        Instance.new("UICorner", bg).CornerRadius = UDim.new(0,6)
        local bgStroke = Instance.new("UIStroke", bg)
        bgStroke.Color = P.accent; bgStroke.Thickness = 1

        local nL = Instance.new("TextLabel", bb)
        nL.Size = UDim2.new(1,0,0.55,0); nL.BackgroundTransparency = 1
        nL.Text = pl.Name; nL.TextColor3 = P.accent
        nL.Font = Enum.Font.GothamBold; nL.TextSize = 13
        nL.TextStrokeColor3 = Color3.new(0,0,0); nL.TextStrokeTransparency = 0.4

        local dL = Instance.new("TextLabel", bb)
        dL.Size = UDim2.new(1,0,0.45,0); dL.Position = UDim2.new(0,0,0.55,0)
        dL.BackgroundTransparency = 1; dL.TextColor3 = P.muted
        dL.Font = Enum.Font.Gotham; dL.TextSize = 10
        dL.TextStrokeColor3 = Color3.new(0,0,0); dL.TextStrokeTransparency = 0.5

        local dc = RunService.Heartbeat:Connect(function()
            if not S.esp then return end
            local mc = LP.Character; local mh = mc and mc:FindFirstChild("HumanoidRootPart")
            if mh and hrp and hrp.Parent then
                dL.Text = string.format("%.0f studs", (hrp.Position - mh.Position).Magnitude)
            end
        end)
        S.espTags[pl] = bb
        bb.AncestryChanged:Connect(function() dc:Disconnect() end)
    end
    attach(pl.Character)
    pl.CharacterAdded:Connect(function(c)
        if S.esp then task.wait(0.5); attach(c) end
    end)
end

local function enableESP()
    for _, pl in ipairs(Players:GetPlayers()) do addESP(pl) end
    Players.PlayerAdded:Connect(function(pl) if S.esp then addESP(pl) end end)
    notify("ESP ON — name tags + distance", "👁️")
end

local function disableESP()
    for pl in pairs(S.espTags) do removeESP(pl) end
    notify("ESP OFF", "👁️")
end

-- ── Tree Radar ────────────────────────────────────────────────
local WOODS = {
    "Oak","Elm","Cherry","Fir","Pine","Snowglow","Palm","Mangrove",
    "Mushroom","Spooky","Swamp","Phantasm","Sinister","Koa","Frost",
    "Cavecrawler","Volcano","Lava","Gold","Zombie","Phantom",
}
local RARE_WOODS = {
    Gold=true, Frost=true, Lava=true, Phantom=true, Zombie=true,
    Cavecrawler=true, Phantasm=true, Sinister=true, Koa=true,
    Snowglow=true, Volcano=true, Mushroom=true, Spooky=true,
}

local function scanTrees(rareOnly)
    local char = LP.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return {} end
    local found = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        local n = obj.Name
        for _, wt in ipairs(WOODS) do
            if n:lower():find(wt:lower()) then
                if not rareOnly or RARE_WOODS[wt] then
                    local pos
                    if obj:IsA("Model") then
                        local pp = obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")
                        if pp then pos = pp.Position end
                    elseif obj:IsA("BasePart") then
                        pos = obj.Position
                    end
                    if pos then
                        table.insert(found, {
                            name = wt,
                            dist = (pos - hrp.Position).Magnitude,
                            pos  = pos,
                        })
                        break
                    end
                end
            end
        end
    end
    table.sort(found, function(a,b) return a.dist < b.dist end)
    return found
end

-- ╔══════════════════════════════════════════════════════════╗
-- ║  WAYPOINTS                                               ║
-- ╚══════════════════════════════════════════════════════════╝

local wpContainer  -- assigned when building the waypoints page

local function refreshWaypoints()
    if not wpContainer then return end
    for _, c in ipairs(wpContainer:GetChildren()) do
        if c:IsA("Frame") or c:IsA("TextButton") then c:Destroy() end
    end
    if #S.waypoints == 0 then
        local e = Instance.new("TextLabel", wpContainer)
        e.Size = UDim2.new(1,0,0,40); e.BackgroundTransparency = 1
        e.Text = "No waypoints yet — save your position below"
        e.TextColor3 = P.muted; e.Font = Enum.Font.Gotham
        e.TextSize = 11; e.TextXAlignment = Enum.TextXAlignment.Center; e.ZIndex = 24
        return
    end
    for i, wp in ipairs(S.waypoints) do
        local card = Instance.new("Frame", wpContainer)
        card.Size = UDim2.new(1,0,0,42); card.BackgroundColor3 = P.bg2
        card.BorderSizePixel = 0; card.ZIndex = 23
        Instance.new("UICorner", card).CornerRadius = UDim.new(0,8)

        local bar = Instance.new("Frame", card)
        bar.Size = UDim2.new(0,3,0,26); bar.Position = UDim2.new(0,0,0.5,-13)
        bar.BackgroundColor3 = P.accent; bar.BorderSizePixel = 0; bar.ZIndex = 24
        Instance.new("UICorner", bar).CornerRadius = UDim.new(1,0)

        local nL = Instance.new("TextLabel", card)
        nL.Size = UDim2.new(1,-100,0,20); nL.Position = UDim2.new(0,12,0,5)
        nL.BackgroundTransparency = 1; nL.Text = wp.name
        nL.TextColor3 = P.white; nL.Font = Enum.Font.GothamSemibold
        nL.TextSize = 12; nL.TextXAlignment = Enum.TextXAlignment.Left; nL.ZIndex = 24

        local cL = Instance.new("TextLabel", card)
        cL.Size = UDim2.new(1,-100,0,14); cL.Position = UDim2.new(0,12,0,24)
        cL.BackgroundTransparency = 1
        cL.Text = string.format("(%d,%d,%d)", wp.pos.X, wp.pos.Y, wp.pos.Z)
        cL.TextColor3 = P.muted; cL.Font = Enum.Font.Gotham
        cL.TextSize = 9; cL.TextXAlignment = Enum.TextXAlignment.Left; cL.ZIndex = 24

        local goB = Instance.new("TextButton", card)
        goB.Size = UDim2.new(0,38,0,24); goB.Position = UDim2.new(1,-90,0.5,-12)
        goB.BackgroundColor3 = P.accentDim; goB.TextColor3 = P.accent
        goB.Font = Enum.Font.GothamBold; goB.TextSize = 11; goB.Text = "GO"
        goB.BorderSizePixel = 0; goB.ZIndex = 25
        Instance.new("UICorner", goB).CornerRadius = UDim.new(0,6)
        local cwp = wp
        goB.MouseButton1Click:Connect(function() tpTo(cwp.pos, cwp.name) end)

        local delB = Instance.new("TextButton", card)
        delB.Size = UDim2.new(0,38,0,24); delB.Position = UDim2.new(1,-46,0.5,-12)
        delB.BackgroundColor3 = Color3.fromRGB(50,15,15); delB.TextColor3 = P.red
        delB.Font = Enum.Font.GothamBold; delB.TextSize = 10; delB.Text = "DEL"
        delB.BorderSizePixel = 0; delB.ZIndex = 25
        Instance.new("UICorner", delB).CornerRadius = UDim.new(0,6)
        local ci = i
        delB.MouseButton1Click:Connect(function()
            table.remove(S.waypoints, ci); refreshWaypoints()
            notify("Deleted waypoint", "🗑️")
        end)
    end
end

-- ╔══════════════════════════════════════════════════════════╗
-- ║  BUILD PAGES                                             ║
-- ╚══════════════════════════════════════════════════════════╝

-- ── HOME ──────────────────────────────────────────────────────
do
    local p = makePage("home")

    -- Session info card
    local iCard = Instance.new("Frame", p)
    iCard.Size = UDim2.new(1,0,0,72); iCard.BackgroundColor3 = P.bg2
    iCard.BorderSizePixel = 0; iCard.ZIndex = 23
    Instance.new("UICorner", iCard).CornerRadius = UDim.new(0,8)
    local iStroke = Instance.new("UIStroke", iCard)
    iStroke.Color = P.accentD; iStroke.Thickness = 1
    local iLayout = Instance.new("UIListLayout", iCard)
    iLayout.Padding = UDim.new(0,0); iLayout.FillDirection = Enum.FillDirection.Vertical
    local iPad = Instance.new("UIPadding", iCard)
    iPad.PaddingTop = UDim.new(0,8); iPad.PaddingLeft = UDim.new(0,12)
    local function iLine(t)
        local l = Instance.new("TextLabel", iCard)
        l.Size = UDim2.new(1,-12,0,18); l.BackgroundTransparency = 1
        l.Text = t; l.TextColor3 = P.muted; l.Font = Enum.Font.Gotham
        l.TextSize = 11; l.TextXAlignment = Enum.TextXAlignment.Left; l.ZIndex = 24
    end
    iLine("👤  " .. LP.Name .. "  (ID: " .. LP.UserId .. ")")
    iLine("🖥️  Place ID: " .. game.PlaceId)
    local timerL = Instance.new("TextLabel", iCard)
    timerL.Size = UDim2.new(1,-12,0,18); timerL.BackgroundTransparency = 1
    timerL.Text = "⏱️  Session: 00:00"; timerL.TextColor3 = P.accent
    timerL.Font = Enum.Font.GothamSemibold; timerL.TextSize = 11
    timerL.TextXAlignment = Enum.TextXAlignment.Left; timerL.ZIndex = 24

    RunService.Heartbeat:Connect(function()
        if not S.open then return end
        local e = math.floor(tick() - S.sessionStart)
        timerL.Text = string.format("⏱️  Session: %02d:%02d", math.floor(e/60), e%60)
    end)

    secLabel(p, "Server")
    rowBtn(p, "🔄  Rejoin Server", "Reconnect to a fresh instance", function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
        notify("Rejoining server…", "🔄")
    end)
    rowBtn(p, "👥  List Players", "Show all players in this server", function()
        local names = {}
        for _, pl in ipairs(Players:GetPlayers()) do table.insert(names, pl.Name) end
        notify(table.concat(names, "  ·  "), "👥")
    end)
    rowBtn(p, "📍  TP to Player", "Enter name in the box below", function()
        notify("Use the name box in the ESP tab", "📍")
    end)

    secLabel(p, "About")
    local about = Instance.new("Frame", p)
    about.Size = UDim2.new(1,0,0,60); about.BackgroundColor3 = P.bg2
    about.BorderSizePixel = 0; about.ZIndex = 23
    Instance.new("UICorner", about).CornerRadius = UDim.new(0,8)
    local aLayout = Instance.new("UIListLayout", about)
    aLayout.Padding = UDim.new(0,0); aLayout.FillDirection = Enum.FillDirection.Vertical
    local aPad = Instance.new("UIPadding", about)
    aPad.PaddingTop = UDim.new(0,8); aPad.PaddingLeft = UDim.new(0,12)
    local function aLine(t)
        local l = Instance.new("TextLabel", about)
        l.Size = UDim2.new(1,-12,0,16); l.BackgroundTransparency = 1
        l.Text = t; l.TextColor3 = P.muted; l.Font = Enum.Font.Gotham
        l.TextSize = 11; l.TextXAlignment = Enum.TextXAlignment.Left; l.ZIndex = 24
    end
    aLine("GHXST Menu  v4  ·  LT2 Edition")
    aLine("Toggle: RightShift  ·  Drag title bar")
    aLine("Inspired by Kron & Infinite Yield")
end

-- ── PLAYER ────────────────────────────────────────────────────
do
    local p = makePage("player")
    secLabel(p, "Movement")
    togRow(p, "✈️  Fly Mode", "WASD + Space/Shift — camera-relative", function(on)
        S.fly = on; if on then enableFly() else disableFly() end
    end)
    togRow(p, "👻  NoClip", "Pass through any surface", function(on)
        S.noclip = on; if on then enableNoclip() else disableNoclip() end
    end)
    togRow(p, "🛡️  God Mode", "1,000,000 HP — takes no damage", function(on)
        S.god = on; if on then enableGod() else disableGod() end
    end)
    togRow(p, "🐇  Infinite Jump", "Jump from any surface or mid-air", function(on)
        S.infJump = on; if on then enableInfJump() else disableInfJump() end
    end)
    togRow(p, "💤  Anti-AFK", "Nudges character every 55 seconds", function(on)
        S.antiAfk = on; if on then enableAntiAfk() end
    end)
    togRow(p, "✨  Ghost Trail", "Cyan neon trail behind you", function(on)
        S.trail = on; if on then enableTrail() else disableTrail() end
    end)

    secLabel(p, "Speed")
    slider(p, "Walk Speed", 4, 150, 16, function(v)
        S.walkSpeed = v
        local char = LP.Character; local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v end
        notify("Walk Speed → " .. v, "🚶")
    end)
    slider(p, "Jump Power", 10, 250, 50, function(v)
        S.jumpPower = v
        local char = LP.Character; local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = v end
        notify("Jump Power → " .. v, "🐇")
    end)
    slider(p, "Fly Speed", 10, 500, 60, function(v)
        S.flySpeed = v; notify("Fly Speed → " .. v, "✈️")
    end)

    secLabel(p, "LT2 Tools")
    togRow(p, "🪓  Auto-Chop", "Fires axe chop every frame", function(on)
        S.autoChop = on; if on then enableAutoChop() else disableAutoChop() end
    end)
    rowBtn(p, "🪓  Equip Best Axe", "Picks highest-tier axe from backpack", function()
        local priority = {
            "Silver Axe","Steel Axe","Rukiryaxe","Alpha Axe of the Woodlands",
            "AxeZilla","Frostbite Axe","Candy Cane Axe","Basic Hatchet",
        }
        local bp = LP:FindFirstChild("Backpack"); if not bp then notify("No backpack found","❌"); return end
        for _, aname in ipairs(priority) do
            local t = bp:FindFirstChild(aname)
            if t then
                local char = LP.Character; if char then t.Parent = char; notify("Equipped: "..aname,"🪓"); return end
            end
        end
        notify("No known axe in backpack","❌")
    end)
end

-- ── TELEPORT ──────────────────────────────────────────────────
do
    local p = makePage("teleport")

    infoCard(p, "📍  All locations verified — click any row to teleport instantly")

    for _, section in ipairs(LOCATIONS) do
        secLabel(p, section.section)
        for _, place in ipairs(section.places) do
            local card = Instance.new("TextButton", p)
            card.Size = UDim2.new(1,0,0,50); card.BackgroundColor3 = P.bg2
            card.BorderSizePixel = 0; card.Text = ""; card.ZIndex = 23
            Instance.new("UICorner", card).CornerRadius = UDim.new(0,8)

            local bar = Instance.new("Frame", card)
            bar.Size = UDim2.new(0,3,0,30); bar.Position = UDim2.new(0,0,0.5,-15)
            bar.BackgroundColor3 = P.accent; bar.BorderSizePixel = 0; bar.ZIndex = 24
            Instance.new("UICorner", bar).CornerRadius = UDim.new(1,0)

            local nameL = Instance.new("TextLabel", card)
            nameL.Size = UDim2.new(1,-120,0,20); nameL.Position = UDim2.new(0,12,0,6)
            nameL.BackgroundTransparency = 1; nameL.Text = place.name
            nameL.TextColor3 = P.white; nameL.Font = Enum.Font.GothamSemibold
            nameL.TextSize = 12; nameL.TextXAlignment = Enum.TextXAlignment.Left; nameL.ZIndex = 24

            local subL = Instance.new("TextLabel", card)
            subL.Size = UDim2.new(1,-120,0,14); subL.Position = UDim2.new(0,12,0,27)
            subL.BackgroundTransparency = 1; subL.Text = place.sub
            subL.TextColor3 = P.muted; subL.Font = Enum.Font.Gotham
            subL.TextSize = 10; subL.TextXAlignment = Enum.TextXAlignment.Left; subL.ZIndex = 24

            local coordL = Instance.new("TextLabel", card)
            coordL.Size = UDim2.new(0,108,0,14); coordL.Position = UDim2.new(1,-116,0,6)
            coordL.BackgroundTransparency = 1
            coordL.Text = string.format("(%d,%d,%d)", place.pos.X, place.pos.Y, place.pos.Z)
            coordL.TextColor3 = P.accentD; coordL.Font = Enum.Font.GothamSemibold
            coordL.TextSize = 9; coordL.TextXAlignment = Enum.TextXAlignment.Right; coordL.ZIndex = 24

            local arrow = Instance.new("TextLabel", card)
            arrow.Size = UDim2.new(0,18,1,0); arrow.Position = UDim2.new(1,-22,0,0)
            arrow.BackgroundTransparency = 1; arrow.Text = "›"
            arrow.TextColor3 = P.dim; arrow.Font = Enum.Font.GothamBold
            arrow.TextSize = 18; arrow.ZIndex = 24

            local tw = TweenInfo.new(0.1)
            card.MouseEnter:Connect(function()
                TweenService:Create(card,  tw, {BackgroundColor3=P.bg3}):Play()
                TweenService:Create(arrow, tw, {TextColor3=P.accent}):Play()
                TweenService:Create(bar,   tw, {BackgroundColor3=Color3.fromRGB(0,220,255)}):Play()
            end)
            card.MouseLeave:Connect(function()
                TweenService:Create(card,  tw, {BackgroundColor3=P.bg2}):Play()
                TweenService:Create(arrow, tw, {TextColor3=P.dim}):Play()
                TweenService:Create(bar,   tw, {BackgroundColor3=P.accent}):Play()
            end)
            local cPlace = place
            card.MouseButton1Click:Connect(function()
                TweenService:Create(card, TweenInfo.new(0.06), {BackgroundColor3=P.accentDim}):Play()
                task.delay(0.12, function()
                    TweenService:Create(card, TweenInfo.new(0.1), {BackgroundColor3=P.bg2}):Play()
                end)
                tpTo(cPlace.pos, cPlace.name)
            end)
        end
    end

    -- Custom coords
    secLabel(p, "Custom Coordinates")
    local cCard = Instance.new("Frame", p)
    cCard.Size = UDim2.new(1,0,0,78); cCard.BackgroundColor3 = P.bg2
    cCard.BorderSizePixel = 0; cCard.ZIndex = 23
    Instance.new("UICorner", cCard).CornerRadius = UDim.new(0,8)
    local cPad = Instance.new("UIPadding", cCard)
    cPad.PaddingLeft = UDim.new(0,10); cPad.PaddingRight = UDim.new(0,10); cPad.PaddingTop = UDim.new(0,8)

    local cTitle = Instance.new("TextLabel", cCard)
    cTitle.Size = UDim2.new(1,0,0,14); cTitle.BackgroundTransparency = 1
    cTitle.Text = "Manual coords  (X · Y · Z)"; cTitle.TextColor3 = P.muted
    cTitle.Font = Enum.Font.Gotham; cTitle.TextSize = 10
    cTitle.TextXAlignment = Enum.TextXAlignment.Left; cTitle.ZIndex = 24

    local boxes = {}
    for i, bd in ipairs({{l="X",h="0"},{l="Y",h="5"},{l="Z",h="0"}}) do
        local xp = (i-1)*0.34
        local bL = Instance.new("TextLabel", cCard)
        bL.Size = UDim2.new(0,12,0,18); bL.Position = UDim2.new(xp,2,0,20)
        bL.BackgroundTransparency = 1; bL.Text = bd.l; bL.TextColor3 = P.accent
        bL.Font = Enum.Font.GothamBold; bL.TextSize = 10; bL.ZIndex = 24

        local box = Instance.new("TextBox", cCard)
        box.Size = UDim2.new(0.26,0,0,24); box.Position = UDim2.new(xp+0.05,2,0,20)
        box.BackgroundColor3 = P.bg0; box.TextColor3 = P.white
        box.PlaceholderText = bd.h; box.PlaceholderColor3 = P.dim
        box.Font = Enum.Font.Gotham; box.TextSize = 11
        box.BorderSizePixel = 0; box.Text = ""; box.ClearTextOnFocus = false; box.ZIndex = 24
        Instance.new("UICorner", box).CornerRadius = UDim.new(0,5)
        local bs = Instance.new("UIStroke", box); bs.Color = P.dim; bs.Thickness = 1
        local bp = Instance.new("UIPadding", box); bp.PaddingLeft = UDim.new(0,6)
        boxes[i] = box
    end

    local goB = Instance.new("TextButton", cCard)
    goB.Size = UDim2.new(0,44,0,24); goB.Position = UDim2.new(1,-44,0,20)
    goB.BackgroundColor3 = P.accent; goB.TextColor3 = P.bg0
    goB.Font = Enum.Font.GothamBold; goB.TextSize = 11; goB.Text = "GO"
    goB.BorderSizePixel = 0; goB.ZIndex = 24
    Instance.new("UICorner", goB).CornerRadius = UDim.new(0,6)

    local function doCustomTP()
        local x,y,z = tonumber(boxes[1].Text), tonumber(boxes[2].Text), tonumber(boxes[3].Text)
        if x and y and z then tpTo(Vector3.new(x,y,z), string.format("(%d,%d,%d)",x,y,z))
        else notify("Enter valid X Y Z numbers","⚠️") end
    end
    goB.MouseButton1Click:Connect(doCustomTP)
    for _, b in ipairs(boxes) do b.FocusLost:Connect(function(e) if e then doCustomTP() end end) end

    local tipL = Instance.new("TextLabel", cCard)
    tipL.Size = UDim2.new(1,-10,0,14); tipL.Position = UDim2.new(0,2,0,50)
    tipL.BackgroundTransparency = 1
    tipL.Text = "💡 Enable Fly before going underground  ·  Enter key works in boxes"
    tipL.TextColor3 = P.dim; tipL.Font = Enum.Font.Gotham; tipL.TextSize = 9
    tipL.TextXAlignment = Enum.TextXAlignment.Left; tipL.ZIndex = 24
end

-- ── WAYPOINTS ─────────────────────────────────────────────────
do
    local p = makePage("waypoints")

    infoCard(p, "🚩  Save your position as a named waypoint — up to 20 slots")

    secLabel(p, "Save Position")
    local saveCard = Instance.new("Frame", p)
    saveCard.Size = UDim2.new(1,0,0,44); saveCard.BackgroundColor3 = P.bg2
    saveCard.BorderSizePixel = 0; saveCard.ZIndex = 23
    Instance.new("UICorner", saveCard).CornerRadius = UDim.new(0,8)
    local sPad = Instance.new("UIPadding", saveCard)
    sPad.PaddingLeft = UDim.new(0,10); sPad.PaddingRight = UDim.new(0,10); sPad.PaddingTop = UDim.new(0,8)

    local nameBox = Instance.new("TextBox", saveCard)
    nameBox.Size = UDim2.new(1,-58,0,26); nameBox.BackgroundColor3 = P.bg0
    nameBox.TextColor3 = P.white; nameBox.PlaceholderText = "Waypoint name..."
    nameBox.PlaceholderColor3 = P.dim; nameBox.Font = Enum.Font.Gotham
    nameBox.TextSize = 12; nameBox.BorderSizePixel = 0; nameBox.Text = ""
    nameBox.ClearTextOnFocus = false; nameBox.ZIndex = 24
    Instance.new("UICorner", nameBox).CornerRadius = UDim.new(0,6)
    local nbStroke = Instance.new("UIStroke", nameBox); nbStroke.Color = P.dim; nbStroke.Thickness = 1
    local nbPad = Instance.new("UIPadding", nameBox); nbPad.PaddingLeft = UDim.new(0,8)

    local saveBtn = Instance.new("TextButton", saveCard)
    saveBtn.Size = UDim2.new(0,50,0,26); saveBtn.Position = UDim2.new(1,-50,0,8)
    saveBtn.BackgroundColor3 = P.accent; saveBtn.TextColor3 = P.bg0
    saveBtn.Font = Enum.Font.GothamBold; saveBtn.TextSize = 11; saveBtn.Text = "SAVE"
    saveBtn.BorderSizePixel = 0; saveBtn.ZIndex = 24
    Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0,6)

    saveBtn.MouseButton1Click:Connect(function()
        if #S.waypoints >= 20 then notify("Max 20 waypoints","⚠️"); return end
        local char = LP.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then notify("No character","❌"); return end
        local wname = nameBox.Text ~= "" and nameBox.Text or ("WP " .. (#S.waypoints+1))
        table.insert(S.waypoints, {name=wname, pos=hrp.Position})
        nameBox.Text = ""; refreshWaypoints()
        notify("Saved: " .. wname, "🚩")
    end)

    secLabel(p, "Saved Waypoints")
    wpContainer = Instance.new("Frame", p)
    wpContainer.Size = UDim2.new(1,0,0,400); wpContainer.BackgroundTransparency = 1
    wpContainer.BorderSizePixel = 0; wpContainer.ZIndex = 23
    local wpLayout = Instance.new("UIListLayout", wpContainer)
    wpLayout.Padding = UDim.new(0,6); wpLayout.FillDirection = Enum.FillDirection.Vertical
    wpLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    refreshWaypoints()

    rowBtn(p, "🗑️  Clear All Waypoints", nil, function()
        S.waypoints = {}; refreshWaypoints(); notify("Cleared all waypoints","🗑️")
    end)
end

-- ── RADAR ─────────────────────────────────────────────────────
do
    local p = makePage("radar")

    infoCard(p, "📡  Scans the map for known LT2 wood types and shows distance + GO button")

    local resultsFrame = Instance.new("Frame", p)
    resultsFrame.Size = UDim2.new(1,0,0,500); resultsFrame.BackgroundTransparency = 1
    resultsFrame.BorderSizePixel = 0; resultsFrame.ZIndex = 23
    local rLayout = Instance.new("UIListLayout", resultsFrame)
    rLayout.Padding = UDim.new(0,6); rLayout.FillDirection = Enum.FillDirection.Vertical
    rLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local function clearResults()
        for _, c in ipairs(resultsFrame:GetChildren()) do
            if not c:IsA("UIListLayout") then c:Destroy() end
        end
    end

    local function showResults(trees)
        clearResults()
        if #trees == 0 then
            local l = Instance.new("TextLabel", resultsFrame)
            l.Size = UDim2.new(1,0,0,40); l.BackgroundTransparency = 1
            l.Text = "No trees found nearby"; l.TextColor3 = P.muted
            l.Font = Enum.Font.Gotham; l.TextSize = 12
            l.TextXAlignment = Enum.TextXAlignment.Center; l.ZIndex = 24
            return
        end
        for i = 1, math.min(#trees, 20) do
            local t = trees[i]
            local card = Instance.new("Frame", resultsFrame)
            card.Size = UDim2.new(1,0,0,40); card.BackgroundColor3 = P.bg2
            card.BorderSizePixel = 0; card.ZIndex = 23
            Instance.new("UICorner", card).CornerRadius = UDim.new(0,8)

            local col = RARE_WOODS[t.name] and P.gold or P.accent
            local bar = Instance.new("Frame", card)
            bar.Size = UDim2.new(0,3,0,24); bar.Position = UDim2.new(0,0,0.5,-12)
            bar.BackgroundColor3 = col; bar.BorderSizePixel = 0; bar.ZIndex = 24
            Instance.new("UICorner", bar).CornerRadius = UDim.new(1,0)

            local nL = Instance.new("TextLabel", card)
            nL.Size = UDim2.new(1,-130,0,20); nL.Position = UDim2.new(0,12,0,3)
            nL.BackgroundTransparency = 1
            nL.Text = (RARE_WOODS[t.name] and "⭐ " or "🌲 ") .. t.name .. " Wood"
            nL.TextColor3 = col; nL.Font = Enum.Font.GothamBold
            nL.TextSize = 12; nL.TextXAlignment = Enum.TextXAlignment.Left; nL.ZIndex = 24

            local dL = Instance.new("TextLabel", card)
            dL.Size = UDim2.new(1,-130,0,14); dL.Position = UDim2.new(0,12,0,22)
            dL.BackgroundTransparency = 1
            dL.Text = string.format("%.0f studs · (%d,%d,%d)", t.dist, t.pos.X, t.pos.Y, t.pos.Z)
            dL.TextColor3 = P.muted; dL.Font = Enum.Font.Gotham
            dL.TextSize = 9; dL.TextXAlignment = Enum.TextXAlignment.Left; dL.ZIndex = 24

            local goB = Instance.new("TextButton", card)
            goB.Size = UDim2.new(0,44,0,24); goB.Position = UDim2.new(1,-52,0.5,-12)
            goB.BackgroundColor3 = P.accentDim; goB.TextColor3 = P.accent
            goB.Font = Enum.Font.GothamBold; goB.TextSize = 11; goB.Text = "GO"
            goB.BorderSizePixel = 0; goB.ZIndex = 25
            Instance.new("UICorner", goB).CornerRadius = UDim.new(0,6)
            local ct = t
            goB.MouseButton1Click:Connect(function() tpTo(ct.pos, ct.name.." Wood") end)
        end
    end

    secLabel(p, "Scan Controls")
    rowBtn(p, "📡  Scan All Wood Types", "Find every known wood type near you", function()
        notify("Scanning workspace…","📡")
        task.spawn(function()
            local r = scanTrees(false)
            showResults(r)
            notify(string.format("Found %d tree(s)", #r),"📡")
        end)
    end)
    rowBtn(p, "⭐  Scan Rare Wood Only", "Gold · Frost · Lava · Phantom · etc.", function()
        notify("Scanning for rare wood…","⭐")
        task.spawn(function()
            local r = scanTrees(true)
            showResults(r)
            notify(string.format("Found %d rare tree(s)", #r),"⭐")
        end)
    end)
    rowBtn(p, "🗑️  Clear Results", nil, function() clearResults() notify("Cleared","🗑️") end)
    secLabel(p, "Results (top 20 by distance)")
end

-- ── WORLD ─────────────────────────────────────────────────────
do
    local p = makePage("world")

    --  !! KEY FIX !!
    --  LT2 has a server-side day/night cycle. If we just set ClockTime once,
    --  the server script reverts it almost immediately.
    --  Solution: we lock it via a Heartbeat loop, and expose a "Light Lock" toggle.

    togRow(p, "🔒  Lock Lighting", "Prevents LT2 from reverting your changes", function(on)
        S.lightLocked = on
        if on then
            enableLightLock()
            notify("Lighting locked — server can't revert","🔒")
        else
            disableLightLock()
            notify("Lighting unlocked — server cycle resumes","🔒")
        end
    end)

    infoCard(p, "💡  Enable 'Lock Lighting' first, then set time/effects below")

    secLabel(p, "Time of Day")
    local function setTime(t, label)
        S.lockedTime = t
        if S.lightLocked then enableLightLock(t) end
        Lighting.ClockTime = t
        notify(label,"🕐")
    end

    slider(p, "Clock Time (0–24)", 0, 24, 14, function(v)
        S.lockedTime = v
        if S.lightLocked then enableLightLock(v) end
        Lighting.ClockTime = v
    end)

    secLabel(p, "Quick Time Presets")
    local times = {
        {"🌅  Dawn",     6,  "Dawn — 6:00"},
        {"🌤️  Morning",  8,  "Morning — 8:00"},
        {"☀️  Noon",    12,  "Noon — 12:00"},
        {"🌇  Sunset",  18,  "Sunset — 18:00"},
        {"🌙  Night",   22,  "Night — 22:00"},
        {"🌑  Midnight", 0,  "Midnight — 0:00"},
    }
    for _, t in ipairs(times) do
        rowBtn(p, t[1], nil, function() setTime(t[2], t[3]) end)
    end

    secLabel(p, "Atmosphere")
    rowBtn(p, "✨  Full Bright", "Max brightness, shadows off", function()
        S.lockedBright = 5
        Lighting.Brightness = 5; Lighting.GlobalShadows = false
        if S.lightLocked then enableLightLock(nil, 5) end
        notify("Full Bright ON","✨")
    end)
    rowBtn(p, "🌧️  Dark Mode", "Minimal brightness, shadows on", function()
        S.lockedBright = 0.05
        Lighting.Brightness = 0.05; Lighting.GlobalShadows = true
        if S.lightLocked then enableLightLock(nil, 0.05) end
        notify("Dark Mode","🌧️")
    end)
    rowBtn(p, "🌫️  Dense Fog", "Visibility down to ~80 studs", function()
        S.lockedFog = 80
        Lighting.FogEnd = 80; Lighting.FogColor = Color3.fromRGB(180,180,180)
        if S.lightLocked then enableLightLock(nil, nil, 80) end
        notify("Dense fog ON","🌫️")
    end)
    rowBtn(p, "🌫️  Clear Fog", "Remove all fog", function()
        S.lockedFog = 100000
        Lighting.FogEnd = 100000
        if S.lightLocked then enableLightLock(nil, nil, 100000) end
        notify("Fog cleared","🌫️")
    end)
    rowBtn(p, "🎨  Reset All Lighting", "Back to LT2 defaults", function()
        disableLightLock()
        S.lightLocked = false
        Lighting.ClockTime = 14; Lighting.Brightness = 2
        Lighting.FogEnd = 100000; Lighting.GlobalShadows = true
        notify("Lighting reset to defaults","🎨")
    end)

    secLabel(p, "Sound")
    togRow(p, "🔇  Mute All Sounds", nil, function(on)
        S.soundMuted = on
        if on then
            for _, s in ipairs(workspace:GetDescendants()) do
                if s:IsA("Sound") then s.Volume = 0 end
            end
            notify("All sounds muted","🔇")
        else
            for _, s in ipairs(workspace:GetDescendants()) do
                if s:IsA("Sound") then s.Volume = 0.5 end
            end
            notify("Sounds restored","🔊")
        end
    end)
end

-- ── ESP ───────────────────────────────────────────────────────
do
    local p = makePage("esp")
    secLabel(p, "ESP")
    togRow(p, "👁️  Player Name Tags", "Floating tags with live distance", function(on)
        S.esp = on; if on then enableESP() else disableESP() end
    end)
    togRow(p, "➕  Crosshair Overlay", "Cyan crosshair at screen centre", function(on)
        S.crosshair = on; xhair.Visible = on
        notify(on and "Crosshair ON" or "Crosshair OFF","➕")
    end)
    rowBtn(p, "🔄  Refresh ESP Tags", "Re-attach tags to all players", function()
        if S.esp then disableESP(); task.wait(0.1); enableESP(); notify("ESP refreshed","🔄")
        else notify("Enable ESP first","⚠️") end
    end)

    secLabel(p, "Player Teleport")
    local ptCard = Instance.new("Frame", p)
    ptCard.Size = UDim2.new(1,0,0,44); ptCard.BackgroundColor3 = P.bg2
    ptCard.BorderSizePixel = 0; ptCard.ZIndex = 23
    Instance.new("UICorner", ptCard).CornerRadius = UDim.new(0,8)
    local ptPad = Instance.new("UIPadding", ptCard)
    ptPad.PaddingLeft = UDim.new(0,10); ptPad.PaddingRight = UDim.new(0,10); ptPad.PaddingTop = UDim.new(0,8)

    local ptBox = Instance.new("TextBox", ptCard)
    ptBox.Size = UDim2.new(1,-58,0,26); ptBox.BackgroundColor3 = P.bg0
    ptBox.TextColor3 = P.white; ptBox.PlaceholderText = "Player name..."
    ptBox.PlaceholderColor3 = P.dim; ptBox.Font = Enum.Font.Gotham
    ptBox.TextSize = 12; ptBox.BorderSizePixel = 0; ptBox.Text = ""; ptBox.ClearTextOnFocus = false
    ptBox.ZIndex = 24
    Instance.new("UICorner", ptBox).CornerRadius = UDim.new(0,6)
    local ptStroke = Instance.new("UIStroke", ptBox); ptStroke.Color = P.dim; ptStroke.Thickness = 1
    local ptPad2 = Instance.new("UIPadding", ptBox); ptPad2.PaddingLeft = UDim.new(0,8)

    local ptBtn = Instance.new("TextButton", ptCard)
    ptBtn.Size = UDim2.new(0,50,0,26); ptBtn.Position = UDim2.new(1,-50,0,8)
    ptBtn.BackgroundColor3 = P.accent; ptBtn.TextColor3 = P.bg0
    ptBtn.Font = Enum.Font.GothamBold; ptBtn.TextSize = 11; ptBtn.Text = "TP"
    ptBtn.BorderSizePixel = 0; ptBtn.ZIndex = 24
    Instance.new("UICorner", ptBtn).CornerRadius = UDim.new(0,6)
    ptBtn.MouseButton1Click:Connect(function()
        local name = ptBox.Text; if name == "" then notify("Enter a name","⚠️"); return end
        local target = Players:FindFirstChild(name)
        local myChar = LP.Character; local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and myHRP then
            myHRP.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(3,0,0)
            notify("Teleported to "..name,"📍")
        else
            notify(name.." not found in server","❌")
        end
    end)

    secLabel(p, "Players")
    rowBtn(p, "📋  List Players & IDs", nil, function()
        for _, pl in ipairs(Players:GetPlayers()) do
            notify(pl.Name.."  ·  "..pl.UserId,"👤")
            task.wait(0.8)
        end
    end)
end

-- ── SETTINGS ──────────────────────────────────────────────────
do
    local p = makePage("settings")
    secLabel(p, "Identity")
    rowBtn(p, "🆔  My User ID",  nil, function() notify("ID: "..LP.UserId,"🆔") end)
    rowBtn(p, "👤  My Username", nil, function() notify(LP.Name,"👤") end)
    rowBtn(p, "🔑  Toggle Key",  "Currently: RightShift", function()
        notify("Edit TOGGLE_KEY at top of script","🔑")
    end)

    secLabel(p, "Reset")
    rowBtn(p, "♻️  Reset All Features", "Disables everything, restores defaults", function()
        if S.fly      then S.fly=false;      disableFly()      end
        if S.noclip   then S.noclip=false;   disableNoclip()   end
        if S.god      then S.god=false;      disableGod()      end
        if S.infJump  then S.infJump=false;  disableInfJump()  end
        if S.autoChop then S.autoChop=false; disableAutoChop() end
        if S.esp      then S.esp=false;      disableESP()      end
        if S.trail    then S.trail=false;    disableTrail()     end
        if S.lightLocked then disableLightLock() end
        S.antiAfk = false; S.soundMuted = false
        xhair.Visible = false
        local char = LP.Character; local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 16; hum.JumpPower = 50 end
        notify("All features reset","♻️")
    end)

    secLabel(p, "About")
    local aCard = Instance.new("Frame", p)
    aCard.Size = UDim2.new(1,0,0,72); aCard.BackgroundColor3 = P.bg2
    aCard.BorderSizePixel = 0; aCard.ZIndex = 23
    Instance.new("UICorner", aCard).CornerRadius = UDim.new(0,8)
    local aLayout = Instance.new("UIListLayout", aCard)
    aLayout.Padding = UDim.new(0,0); aLayout.FillDirection = Enum.FillDirection.Vertical
    local aPad = Instance.new("UIPadding", aCard)
    aPad.PaddingTop = UDim.new(0,8); aPad.PaddingLeft = UDim.new(0,12)
    local function aLine(t)
        local l = Instance.new("TextLabel", aCard)
        l.Size = UDim2.new(1,-12,0,16); l.BackgroundTransparency = 1
        l.Text = t; l.TextColor3 = P.muted; l.Font = Enum.Font.Gotham
        l.TextSize = 11; l.TextXAlignment = Enum.TextXAlignment.Left; l.ZIndex = 24
    end
    aLine("GHXST Menu  v4.0  ·  LT2 Edition")
    aLine("Complete rewrite — UI, coords, lighting all fixed")
    aLine("Toggle: RightShift  ·  Drag title bar")
    aLine("Inspired by Kron & Infinite Yield")
end

-- ╔══════════════════════════════════════════════════════════╗
-- ║  OPEN / CLOSE                                            ║
-- ╚══════════════════════════════════════════════════════════╝

local function openMenu()
    pill.Visible = false
    win.Visible  = true
    win.Size     = UDim2.new(0, WIN_W, 0, 0)
    win.BackgroundTransparency = 1
    TweenService:Create(win,
        TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        { Size=UDim2.new(0,WIN_W,0,WIN_H), BackgroundTransparency=0 }):Play()
    S.open = true
    switchTab(S.tab)
end

local function closeMenu()
    TweenService:Create(win,
        TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        { Size=UDim2.new(0,WIN_W,0,0), BackgroundTransparency=1 }):Play()
    task.delay(0.2, function()
        win.Visible = false; pill.Visible = true
    end)
    S.open = false
end

pill.MouseButton1Click:Connect(function()
    if S.open then closeMenu() else openMenu() end
end)
closeBtn.MouseButton1Click:Connect(closeMenu)
minBtn.MouseButton1Click:Connect(closeMenu)

UserInputService.InputBegan:Connect(function(inp, proc)
    if proc then return end
    if inp.KeyCode == TOGGLE_KEY then
        if S.open then closeMenu() else openMenu() end
    end
end)

-- ── Draggable (title bar) ─────────────────────────────────────
local dragActive, dragStart, winStart2
titleBar.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        dragActive = true; dragStart = inp.Position; winStart2 = win.Position
    end
end)
UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragActive = false end
end)
UserInputService.InputChanged:Connect(function(inp)
    if dragActive and inp.UserInputType == Enum.UserInputType.MouseMovement then
        local d = inp.Position - dragStart
        win.Position = UDim2.new(
            winStart2.X.Scale, winStart2.X.Offset + d.X,
            winStart2.Y.Scale, winStart2.Y.Offset + d.Y)
    end
end)

-- ╔══════════════════════════════════════════════════════════╗
-- ║  RESPAWN PERSISTENCE                                     ║
-- ╚══════════════════════════════════════════════════════════╝

LP.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid"); task.wait(0.6)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        if S.walkSpeed ~= 16 then hum.WalkSpeed = S.walkSpeed end
        if S.jumpPower ~= 50 then hum.JumpPower  = S.jumpPower  end
    end
    if S.fly      then task.wait(0.2); enableFly()      end
    if S.god      then task.wait(0.2); enableGod()      end
    if S.noclip   then task.wait(0.2); enableNoclip()   end
    if S.infJump  then task.wait(0.2); enableInfJump()  end
    if S.autoChop then task.wait(0.2); enableAutoChop() end
    if S.trail    then task.wait(0.2); enableTrail()    end
    if S.esp then
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LP then task.wait(0.1); addESP(pl) end
        end
    end
end)

-- ╔══════════════════════════════════════════════════════════╗
-- ║  INIT                                                    ║
-- ╚══════════════════════════════════════════════════════════╝

switchTab("home")
print(string.format("[GHXST v4] ✓ Loaded — %s (%d)", LP.Name, LP.UserId))
notify("GHXST Menu v4 loaded!  Press RightShift to toggle", "👻")
