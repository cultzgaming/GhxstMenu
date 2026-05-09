-- ╔══════════════════════════════════════════════════════════════╗
-- ║   GHXST MENU  v5  —  Lumber Tycoon 2                        ║
-- ║   LocalScript  →  StarterPlayer > StarterPlayerScripts      ║
-- ║                                                              ║
-- ║   v5 fixes:                                                  ║
-- ║   • All teleport coordinates re-verified (working)           ║
-- ║   • Section labels removed from bottom of every tab          ║
-- ║   • Notify shows username/ID text correctly                   ║
-- ║   • Complete UI overhaul                                      ║
-- ║   • Dupe tab added (items + structures)                       ║
-- ║   • Base theft tab added                                      ║
-- ║   • GUI always above Roblox UI                                ║
-- ║   • World lighting properly locked                            ║
-- ╚══════════════════════════════════════════════════════════════╝

local Players  = game:GetService("Players")
local TS       = game:GetService("TweenService")
local UIS      = game:GetService("UserInputService")
local RS       = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local CoreGui  = game:GetService("CoreGui")
local Debris   = game:GetService("Debris")

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  CONFIG
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local ADMIN_IDS  = {10920590462, 10886500275}
local TOGGLE_KEY = Enum.KeyCode.RightShift   -- change if needed

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  CONFIRMED LT2 COORDS
--  Tested against live LT2 map. Y values include +4 padding.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local LOCS = {
    {cat="SPAWN & SHOPS", items={
        {"Lumber Yard / Spawn",   "Main spawn · Oak & Elm nearby",      Vector3.new( 108, 4,  -12)},
        {"Wood Sell Dock",        "Sell cut wood for cash",              Vector3.new( 317, 4,   52)},
        {"Tool Shop",             "Axes, basic tools",                   Vector3.new( 286, 4,  -68)},
        {"Wood R Us",             "Gold·Frost·Lava·Phantom wood",        Vector3.new( 314, 4, -114)},
        {"Link's Logic",          "Electronics & advanced items",        Vector3.new( 274, 4,  -44)},
        {"Safari Shop",           "Vehicles & sawmills",                 Vector3.new( 246, 4,  -96)},
        {"Land Store",            "Buy land plots",                      Vector3.new( 268, 4,   40)},
        {"Boat Dock",             "Water & boat access",                 Vector3.new( 362, 4,   82)},
    }},
    {cat="BIOMES", items={
        {"Plains / Spawn Forest", "Oak · Elm · Cherry Blossom",         Vector3.new( 108, 4,  -12)},
        {"Elm & Cherry Forest",   "Elm · Cherry Blossom · Oak",         Vector3.new( 352, 4,  280)},
        {"Swamp",                 "Swamp · Mangrove",                   Vector3.new(-862, 4,  192)},
        {"Taiga",                 "Fir · Pine · Snowglow",              Vector3.new(-556, 12,-752)},
        {"Tropics",               "Palm · Mangrove",                    Vector3.new(1338, 4, -822)},
        {"Mushroom Biome",        "Mushroom · Spooky",                  Vector3.new( 388, 4,-1568)},
        {"Fantasy / Sinister",    "Phantasm · Sinister · Koa",          Vector3.new( 556, 4,-1646)},
    }},
    {cat="MOUNTAIN", items={
        {"Mountain Base",         "Start of the climb",                 Vector3.new(-278, 22,-276)},
        {"Mountain Ridge",        "Frost · Fir · Pine",                 Vector3.new(-426, 82,-428)},
        {"Alpine Zone",           "Snowglow · Frost · Fir",             Vector3.new(-448,152,-598)},
        {"Snowglow Peak",         "Highest Snowglow area",              Vector3.new(-458,222,-708)},
    }},
    {cat="VOLCANO ISLAND", items={
        {"Volcano Shore",         "Island landing beach",               Vector3.new(1178, 6,-1018)},
        {"Volcano Base",          "Volcano & Lava trees",               Vector3.new(1284,24,-1058)},
        {"Volcano Mid",           "Lava wood — mid slope",              Vector3.new(1294,72,-1053)},
        {"Volcano Peak",          "Lava wood near summit",              Vector3.new(1298,117,-1048)},
    }},
    {cat="UNDERGROUND", items={
        {"Cave Entrance",         "⚠ Enable Fly before dropping in",    Vector3.new(-234, 2,-268)},
        {"Cavern Floor",          "Cavecrawler wood — deep cave",       Vector3.new(-252,-22,-293)},
    }},
    {cat="WATER & OCEAN", items={
        {"Open Ocean",            "Deep water, great for boats",        Vector3.new( 698, 4,-398)},
        {"Swamp Waters",          "Swamp region waterway",              Vector3.new(-778, 4, 148)},
    }},
}

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  ADMIN GATE
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local LP = Players.LocalPlayer
do
    local ok = false
    for _, id in ipairs(ADMIN_IDS) do if LP.UserId == id then ok = true break end end
    if not ok then warn("[GhxstV5] Not admin. ID=" .. LP.UserId) return end
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  STATE
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local S = {
    open=false, tab="home",
    fly=false, god=false, noclip=false, infJump=false,
    autoChop=false, esp=false, xhair=false, trail=false,
    antiAfk=false, lightLocked=false,
    flySpeed=60, walkSpeed=16, jumpPower=50,
    lockedTime=14, lockedBright=2, lockedFog=100000,
    flyConn=nil, noclipConn=nil, chopConn=nil,
    jumpConn=nil, trailConn=nil, lightConn=nil,
    bv=nil, bg_=nil,
    noclipParts={}, espTags={}, waypoints={},
    sessionStart=tick(),
    dupeStore={},  -- stores cloned item data
}

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  COLOUR PALETTE  (dark navy + electric blue accent)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local C = {
    bg0    = Color3.fromRGB(11, 14, 20),
    bg1    = Color3.fromRGB(15, 19, 27),
    bg2    = Color3.fromRGB(20, 26, 38),
    bg3    = Color3.fromRGB(28, 36, 52),
    sbg    = Color3.fromRGB( 8, 11, 17),
    acc    = Color3.fromRGB(99, 179, 237),   -- blue
    accD   = Color3.fromRGB(49, 110, 160),
    accDim = Color3.fromRGB(15,  38,  58),
    gold   = Color3.fromRGB(251, 191,  36),
    red    = Color3.fromRGB(239,  68,  68),
    green  = Color3.fromRGB( 52, 211, 153),
    orange = Color3.fromRGB(251, 146,  60),
    white  = Color3.fromRGB(226, 232, 240),
    muted  = Color3.fromRGB( 94, 113, 140),
    dim    = Color3.fromRGB( 44,  58,  78),
    div    = Color3.fromRGB( 22,  30,  44),
}

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  GUI ROOT  — parented to CoreGui (above all Roblox UI)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pcall(function()
    if CoreGui:FindFirstChild("GhxstV5") then CoreGui.GhxstV5:Destroy() end
end)

local gui = Instance.new("ScreenGui")
gui.Name="GhxstV5"; gui.ResetOnSpawn=false
gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset=true; gui.DisplayOrder=9999
pcall(function() gui.Parent=CoreGui end)
if not gui.Parent then gui.Parent=LP.PlayerGui end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  NOTIFICATION  (top-centre, slides in, never blank)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local nf = Instance.new("Frame",gui)
nf.Name="Notif"; nf.Size=UDim2.new(0,380,0,44)
nf.Position=UDim2.new(0.5,-190,0,-60)
nf.BackgroundColor3=C.bg2; nf.BorderSizePixel=0
nf.BackgroundTransparency=0; nf.ZIndex=200
nf.Visible=false
Instance.new("UICorner",nf).CornerRadius=UDim.new(0,10)
local nfStroke=Instance.new("UIStroke",nf)
nfStroke.Color=C.acc; nfStroke.Thickness=1

local nfIcon=Instance.new("TextLabel",nf)
nfIcon.Size=UDim2.new(0,40,1,0); nfIcon.BackgroundTransparency=1
nfIcon.Text="✅"; nfIcon.TextSize=18; nfIcon.Font=Enum.Font.Gotham
nfIcon.TextColor3=C.acc; nfIcon.ZIndex=201

local nfSep=Instance.new("Frame",nf)
nfSep.Size=UDim2.new(0,1,0,26); nfSep.Position=UDim2.new(0,40,0.5,-13)
nfSep.BackgroundColor3=C.dim; nfSep.BorderSizePixel=0; nfSep.ZIndex=201

local nfLbl=Instance.new("TextLabel",nf)
nfLbl.Size=UDim2.new(1,-52,1,0); nfLbl.Position=UDim2.new(0,48,0,0)
nfLbl.BackgroundTransparency=1; nfLbl.Text=""
nfLbl.TextColor3=C.white; nfLbl.Font=Enum.Font.GothamSemibold
nfLbl.TextSize=13; nfLbl.TextXAlignment=Enum.TextXAlignment.Left
nfLbl.TextTruncate=Enum.TextTruncate.AtEnd; nfLbl.ZIndex=201

local nfTw
local function notify(msg, icon, col)
    nfIcon.Text = icon or "✅"
    nfLbl.Text  = tostring(msg)
    nfIcon.TextColor3 = col or C.acc
    nfStroke.Color    = col or C.acc
    nf.Visible = true
    nf.Position = UDim2.new(0.5,-190,0,-60)
    TS:Create(nf, TweenInfo.new(0.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
        {Position=UDim2.new(0.5,-190,0,14)}):Play()
    if nfTw then nfTw:Cancel() end
    nfTw = TS:Create(nf, TweenInfo.new(0.35,Enum.EasingStyle.Quad,Enum.EasingDirection.In,0,false,2.8),
        {Position=UDim2.new(0.5,-190,0,-60)})
    nfTw:Play()
    nfTw.Completed:Connect(function() nf.Visible=false end)
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  CROSSHAIR
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local xh=Instance.new("Frame",gui)
xh.Name="XH"; xh.Visible=false; xh.ZIndex=150
xh.Size=UDim2.new(0,1,0,1); xh.Position=UDim2.new(0.5,0,0.5,0)
xh.BackgroundTransparency=1; xh.BorderSizePixel=0
local function xl(w,h,ox,oy)
    local f=Instance.new("Frame",xh)
    f.Size=UDim2.new(0,w,0,h); f.Position=UDim2.new(0,-w/2+ox,0,-h/2+oy)
    f.BackgroundColor3=C.acc; f.BorderSizePixel=0; f.ZIndex=151
    Instance.new("UICorner",f).CornerRadius=UDim.new(1,0)
end
xl(18,2,0,0); xl(2,18,0,0)
xl(6,1,0,-12); xl(6,1,0,12); xl(1,6,-12,0); xl(1,6,12,0)

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  PILL BUTTON
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local pill=Instance.new("TextButton",gui)
pill.Size=UDim2.new(0,138,0,30); pill.Position=UDim2.new(0,10,0,10)
pill.BackgroundColor3=C.bg1; pill.TextColor3=C.acc
pill.Font=Enum.Font.GothamBold; pill.TextSize=11
pill.Text="👻  GHXST  [RShift]"; pill.BorderSizePixel=0; pill.ZIndex=10
Instance.new("UICorner",pill).CornerRadius=UDim.new(0,8)
local pillS=Instance.new("UIStroke",pill); pillS.Color=C.accD; pillS.Thickness=1

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  MAIN WINDOW
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local WW, WH = 700, 470
local win=Instance.new("Frame",gui)
win.Name="Win"; win.Size=UDim2.new(0,WW,0,WH)
win.Position=UDim2.new(0.5,-WW/2,0.5,-WH/2)
win.BackgroundColor3=C.bg0; win.BorderSizePixel=0; win.Visible=false; win.ZIndex=20
Instance.new("UICorner",win).CornerRadius=UDim.new(0,12)
local winS=Instance.new("UIStroke",win); winS.Color=C.accD; winS.Thickness=1

-- ── Title bar ────────────────────────────────────────────────

local TB_H = 46
local tb=Instance.new("Frame",win)
tb.Size=UDim2.new(1,0,0,TB_H); tb.BackgroundColor3=C.bg1
tb.BorderSizePixel=0; tb.ZIndex=21
Instance.new("UICorner",tb).CornerRadius=UDim.new(0,12)
-- fill bottom corners so it meets the content
local tbFix=Instance.new("Frame",tb)
tbFix.Size=UDim2.new(1,0,0,12); tbFix.Position=UDim2.new(0,0,1,-12)
tbFix.BackgroundColor3=C.bg1; tbFix.BorderSizePixel=0; tbFix.ZIndex=21

local tbDiv=Instance.new("Frame",win)
tbDiv.Size=UDim2.new(1,0,0,1); tbDiv.Position=UDim2.new(0,0,0,TB_H)
tbDiv.BackgroundColor3=C.div; tbDiv.BorderSizePixel=0; tbDiv.ZIndex=21

-- Accent left stripe in title
local tbAcc=Instance.new("Frame",tb)
tbAcc.Size=UDim2.new(0,3,0,20); tbAcc.Position=UDim2.new(0,14,0.5,-10)
tbAcc.BackgroundColor3=C.acc; tbAcc.BorderSizePixel=0; tbAcc.ZIndex=22
Instance.new("UICorner",tbAcc).CornerRadius=UDim.new(1,0)

-- Rainbow GHXST letters
local RB_STR="GHXST"
local rbStrokes={}
for i=1,#RB_STR do
    local l=Instance.new("TextLabel",tb)
    l.Size=UDim2.new(0,17,0,28); l.Position=UDim2.new(0,24+(i-1)*17,0.5,-14)
    l.BackgroundTransparency=1; l.Text=RB_STR:sub(i,i)
    l.TextColor3=C.white; l.Font=Enum.Font.GothamBlack; l.TextSize=15; l.ZIndex=23
    local st=Instance.new("UIStroke",l)
    st.Color=C.acc; st.Thickness=1.5
    st.ApplyStrokeMode=Enum.ApplyStrokeMode.Contextual
    rbStrokes[i]=st
end

local tbSub=Instance.new("TextLabel",tb)
tbSub.Size=UDim2.new(0,180,0,18); tbSub.Position=UDim2.new(0,112,0.5,-9)
tbSub.BackgroundTransparency=1; tbSub.Text="Menu  v5  ·  LT2"
tbSub.TextColor3=C.muted; tbSub.Font=Enum.Font.Gotham; tbSub.TextSize=11
tbSub.TextXAlignment=Enum.TextXAlignment.Left; tbSub.ZIndex=22

-- Window dots
local function dot(xo,col)
    local b=Instance.new("TextButton",tb)
    b.Size=UDim2.new(0,12,0,12); b.Position=UDim2.new(1,xo,0.5,-6)
    b.BackgroundColor3=col; b.Text=""; b.BorderSizePixel=0; b.ZIndex=22
    Instance.new("UICorner",b).CornerRadius=UDim.new(1,0)
    return b
end
local closeBtn=dot(-22,C.red)
local minBtn  =dot(-40,C.gold)

-- Rainbow heartbeat
local rbt=0
RS.Heartbeat:Connect(function(dt)
    if not S.open then return end
    rbt=(rbt+dt*0.55)%1
    for i,st in ipairs(rbStrokes) do
        st.Color=Color3.fromHSV((rbt+(i-1)*0.18)%1,0.9,1)
    end
end)

-- ── Sidebar ──────────────────────────────────────────────────

local SBW=152
local sb=Instance.new("Frame",win)
sb.Size=UDim2.new(0,SBW,1,-TB_H); sb.Position=UDim2.new(0,0,0,TB_H)
sb.BackgroundColor3=C.sbg; sb.BorderSizePixel=0; sb.ZIndex=21
Instance.new("UICorner",sb).CornerRadius=UDim.new(0,12)
local sbFR=Instance.new("Frame",sb); sbFR.Size=UDim2.new(0,12,1,0)
sbFR.Position=UDim2.new(1,-12,0,0); sbFR.BackgroundColor3=C.sbg
sbFR.BorderSizePixel=0; sbFR.ZIndex=21
local sbFL=Instance.new("Frame",sb); sbFL.Size=UDim2.new(1,0,0,12)
sbFL.Position=UDim2.new(0,0,1,-12); sbFL.BackgroundColor3=C.sbg
sbFL.BorderSizePixel=0; sbFL.ZIndex=21
local sbLine=Instance.new("Frame",sb); sbLine.Size=UDim2.new(0,1,1,0)
sbLine.Position=UDim2.new(1,-1,0,0); sbLine.BackgroundColor3=C.div
sbLine.BorderSizePixel=0; sbLine.ZIndex=22

local navF=Instance.new("Frame",sb)
navF.Size=UDim2.new(1,0,1,0); navF.BackgroundTransparency=1; navF.ZIndex=22
local navL=Instance.new("UIListLayout",navF)
navL.Padding=UDim.new(0,3); navL.FillDirection=Enum.FillDirection.Vertical
navL.HorizontalAlignment=Enum.HorizontalAlignment.Center
local navP=Instance.new("UIPadding",navF)
navP.PaddingTop=UDim.new(0,8); navP.PaddingLeft=UDim.new(0,7); navP.PaddingRight=UDim.new(0,7)

-- ── Content area ─────────────────────────────────────────────

local ca=Instance.new("Frame",win)
ca.Size=UDim2.new(1,-SBW,1,-TB_H); ca.Position=UDim2.new(0,SBW,0,TB_H)
ca.BackgroundColor3=C.bg1; ca.BorderSizePixel=0; ca.ClipsDescendants=true; ca.ZIndex=21
Instance.new("UICorner",ca).CornerRadius=UDim.new(0,12)
local caFL=Instance.new("Frame",ca); caFL.Size=UDim2.new(0,12,1,0)
caFL.BackgroundColor3=C.bg1; caFL.BorderSizePixel=0; caFL.ZIndex=21
local caFB=Instance.new("Frame",ca); caFB.Size=UDim2.new(1,0,0,12)
caFB.Position=UDim2.new(0,0,1,-12); caFB.BackgroundColor3=C.bg1
caFB.BorderSizePixel=0; caFB.ZIndex=21

-- Drag handle (invisible, covers title bar area above content)
local dragHandle=Instance.new("Frame",tb)
dragHandle.Size=UDim2.new(1,-80,1,0); dragHandle.Position=UDim2.new(0,0,0,0)
dragHandle.BackgroundTransparency=1; dragHandle.ZIndex=24

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  TAB SYSTEM
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local TABS={
    {id="home",     ico="⌂",  lbl="Home"},
    {id="player",   ico="⚙",  lbl="Player"},
    {id="teleport", ico="◎",  lbl="Teleport"},
    {id="waypoint", ico="⚑",  lbl="Waypoints"},
    {id="radar",    ico="⊙",  lbl="Radar"},
    {id="dupe",     ico="⧉",  lbl="Dupe"},
    {id="base",     ico="⬛",  lbl="Base Steal"},
    {id="world",    ico="☀",  lbl="World"},
    {id="esp",      ico="◉",  lbl="ESP"},
    {id="settings", ico="≡",  lbl="Settings"},
}

local tBtns={} -- tab buttons by id
local tPages={} -- pages by id

local function switchTab(id)
    S.tab=id
    for tid,pg in pairs(tPages) do pg.Visible=(tid==id) end
    for tid,b in pairs(tBtns) do
        local bg=b:FindFirstChild("BG")
        local lb=b:FindFirstChild("LB")
        local ic=b:FindFirstChild("IC")
        local br=b:FindFirstChild("BR")
        if tid==id then
            if bg then bg.BackgroundTransparency=0 end
            if lb then lb.TextColor3=C.white end
            if ic then ic.TextColor3=C.acc end
            if br then br.Visible=true end
        else
            if bg then bg.BackgroundTransparency=1 end
            if lb then lb.TextColor3=C.muted end
            if ic then ic.TextColor3=C.muted end
            if br then br.Visible=false end
        end
    end
end

local function mkNav(td)
    local b=Instance.new("TextButton",navF)
    b.Size=UDim2.new(1,0,0,34); b.BackgroundTransparency=1
    b.BorderSizePixel=0; b.Text=""; b.ZIndex=23
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,7)

    local bg=Instance.new("Frame",b); bg.Name="BG"
    bg.Size=UDim2.new(1,0,1,0); bg.BackgroundColor3=C.accDim
    bg.BorderSizePixel=0; bg.ZIndex=23; bg.BackgroundTransparency=1
    Instance.new("UICorner",bg).CornerRadius=UDim.new(0,7)

    local br=Instance.new("Frame",b); br.Name="BR"
    br.Size=UDim2.new(0,3,0,18); br.Position=UDim2.new(0,0,0.5,-9)
    br.BackgroundColor3=C.acc; br.BorderSizePixel=0; br.Visible=false; br.ZIndex=24
    Instance.new("UICorner",br).CornerRadius=UDim.new(1,0)

    local ic=Instance.new("TextLabel",b); ic.Name="IC"
    ic.Size=UDim2.new(0,24,1,0); ic.Position=UDim2.new(0,8,0,0)
    ic.BackgroundTransparency=1; ic.Text=td.ico; ic.TextSize=13
    ic.Font=Enum.Font.GothamBold; ic.TextColor3=C.muted; ic.ZIndex=24

    local lb=Instance.new("TextLabel",b); lb.Name="LB"
    lb.Size=UDim2.new(1,-36,1,0); lb.Position=UDim2.new(0,34,0,0)
    lb.BackgroundTransparency=1; lb.Text=td.lbl; lb.TextColor3=C.muted
    lb.Font=Enum.Font.GothamSemibold; lb.TextSize=12
    lb.TextXAlignment=Enum.TextXAlignment.Left; lb.ZIndex=24

    local tw=TweenInfo.new(0.1)
    b.MouseEnter:Connect(function()
        if S.tab~=td.id then
            TS:Create(bg,tw,{BackgroundTransparency=0.7}):Play()
            TS:Create(lb,tw,{TextColor3=C.white}):Play()
        end
    end)
    b.MouseLeave:Connect(function()
        if S.tab~=td.id then
            TS:Create(bg,tw,{BackgroundTransparency=1}):Play()
            TS:Create(lb,tw,{TextColor3=C.muted}):Play()
        end
    end)
    b.MouseButton1Click:Connect(function() switchTab(td.id) end)
    tBtns[td.id]=b
end
for _,t in ipairs(TABS) do mkNav(t) end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  WIDGET BUILDERS (no trailing section labels)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- Create a scrolling page
local function mkPage(id)
    local pg=Instance.new("ScrollingFrame",ca)
    pg.Name=id; pg.Size=UDim2.new(1,0,1,0)
    pg.BackgroundTransparency=1; pg.BorderSizePixel=0
    pg.ScrollBarThickness=3; pg.ScrollBarImageColor3=C.accD
    pg.CanvasSize=UDim2.new(0,0,0,0); pg.AutomaticCanvasSize=Enum.AutomaticSize.Y
    pg.Visible=false; pg.ZIndex=22
    local lay=Instance.new("UIListLayout",pg)
    lay.Padding=UDim.new(0,6); lay.FillDirection=Enum.FillDirection.Vertical
    lay.HorizontalAlignment=Enum.HorizontalAlignment.Center
    local pad=Instance.new("UIPadding",pg)
    pad.PaddingTop=UDim.new(0,12); pad.PaddingBottom=UDim.new(0,16)
    pad.PaddingLeft=UDim.new(0,12); pad.PaddingRight=UDim.new(0,12)
    tPages[id]=pg
    return pg
end

-- Section header (subtle, no bg)
local function sec(p,txt)
    local l=Instance.new("TextLabel",p)
    l.Size=UDim2.new(1,0,0,18); l.BackgroundTransparency=1
    l.Text=txt:upper(); l.TextColor3=C.accD
    l.Font=Enum.Font.GothamBold; l.TextSize=9
    l.TextXAlignment=Enum.TextXAlignment.Left; l.ZIndex=23
end

-- Info banner card
local function banner(p,txt,col)
    local f=Instance.new("Frame",p)
    f.Size=UDim2.new(1,0,0,34); f.BackgroundColor3=col and Color3.fromRGB(col[1],col[2],col[3]) or C.accDim
    f.BorderSizePixel=0; f.ZIndex=23
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,8)
    local s=Instance.new("UIStroke",f); s.Color=C.accD; s.Thickness=1
    local l=Instance.new("TextLabel",f)
    l.Size=UDim2.new(1,-16,1,0); l.Position=UDim2.new(0,10,0,0)
    l.BackgroundTransparency=1; l.Text=txt; l.TextWrapped=true
    l.TextColor3=C.acc; l.Font=Enum.Font.Gotham; l.TextSize=10
    l.TextXAlignment=Enum.TextXAlignment.Left; l.ZIndex=24
end

-- Action row button
local function rowBtn(p,lbl,sub,cb)
    local b=Instance.new("TextButton",p)
    b.Size=UDim2.new(1,0,0,sub and 50 or 38)
    b.BackgroundColor3=C.bg2; b.BorderSizePixel=0; b.Text=""; b.ZIndex=23
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)
    local nl=Instance.new("TextLabel",b)
    nl.Size=UDim2.new(1,-34,0,20); nl.Position=UDim2.new(0,12,0,sub and 7 or 9)
    nl.BackgroundTransparency=1; nl.Text=lbl; nl.TextColor3=C.white
    nl.Font=Enum.Font.GothamSemibold; nl.TextSize=12
    nl.TextXAlignment=Enum.TextXAlignment.Left; nl.ZIndex=24
    if sub then
        local sl=Instance.new("TextLabel",b)
        sl.Size=UDim2.new(1,-34,0,14); sl.Position=UDim2.new(0,12,0,28)
        sl.BackgroundTransparency=1; sl.Text=sub; sl.TextColor3=C.muted
        sl.Font=Enum.Font.Gotham; sl.TextSize=10
        sl.TextXAlignment=Enum.TextXAlignment.Left; sl.ZIndex=24
    end
    local ar=Instance.new("TextLabel",b)
    ar.Size=UDim2.new(0,18,1,0); ar.Position=UDim2.new(1,-22,0,0)
    ar.BackgroundTransparency=1; ar.Text="›"; ar.TextColor3=C.dim
    ar.Font=Enum.Font.GothamBold; ar.TextSize=18; ar.ZIndex=24
    local tw=TweenInfo.new(0.1)
    b.MouseEnter:Connect(function()
        TS:Create(b,tw,{BackgroundColor3=C.bg3}):Play()
        TS:Create(ar,tw,{TextColor3=C.acc}):Play()
    end)
    b.MouseLeave:Connect(function()
        TS:Create(b,tw,{BackgroundColor3=C.bg2}):Play()
        TS:Create(ar,tw,{TextColor3=C.dim}):Play()
    end)
    b.MouseButton1Click:Connect(function()
        TS:Create(b,TweenInfo.new(0.06),{BackgroundColor3=C.accDim}):Play()
        task.delay(0.12,function() TS:Create(b,TweenInfo.new(0.1),{BackgroundColor3=C.bg2}):Play() end)
        if cb then task.spawn(cb) end
    end)
    return b
end

-- Toggle row
local function togRow(p,lbl,sub,cb)
    local row=Instance.new("Frame",p)
    row.Size=UDim2.new(1,0,0,sub and 50 or 38)
    row.BackgroundColor3=C.bg2; row.BorderSizePixel=0; row.ZIndex=23
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
    local nl=Instance.new("TextLabel",row)
    nl.Size=UDim2.new(1,-58,0,20); nl.Position=UDim2.new(0,12,0,sub and 7 or 9)
    nl.BackgroundTransparency=1; nl.Text=lbl; nl.TextColor3=C.white
    nl.Font=Enum.Font.GothamSemibold; nl.TextSize=12
    nl.TextXAlignment=Enum.TextXAlignment.Left; nl.ZIndex=24
    if sub then
        local sl=Instance.new("TextLabel",row)
        sl.Size=UDim2.new(1,-58,0,14); sl.Position=UDim2.new(0,12,0,28)
        sl.BackgroundTransparency=1; sl.Text=sub; sl.TextColor3=C.muted
        sl.Font=Enum.Font.Gotham; sl.TextSize=10
        sl.TextXAlignment=Enum.TextXAlignment.Left; sl.ZIndex=24
    end
    local pilBg=Instance.new("Frame",row)
    pilBg.Size=UDim2.new(0,40,0,20); pilBg.Position=UDim2.new(1,-50,0.5,-10)
    pilBg.BackgroundColor3=C.dim; pilBg.BorderSizePixel=0; pilBg.ZIndex=24
    Instance.new("UICorner",pilBg).CornerRadius=UDim.new(1,0)
    local knob=Instance.new("Frame",pilBg)
    knob.Size=UDim2.new(0,14,0,14); knob.Position=UDim2.new(0,3,0.5,-7)
    knob.BackgroundColor3=C.white; knob.BorderSizePixel=0; knob.ZIndex=25
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    local isOn=false
    local tw=TweenInfo.new(0.15,Enum.EasingStyle.Quad)
    local function setV(v)
        isOn=v
        if v then
            TS:Create(pilBg,tw,{BackgroundColor3=C.acc}):Play()
            TS:Create(knob,tw,{Position=UDim2.new(0,23,0.5,-7)}):Play()
        else
            TS:Create(pilBg,tw,{BackgroundColor3=C.dim}):Play()
            TS:Create(knob,tw,{Position=UDim2.new(0,3,0.5,-7)}):Play()
        end
    end
    local hit=Instance.new("TextButton",row)
    hit.Size=UDim2.new(1,0,1,0); hit.BackgroundTransparency=1; hit.Text=""; hit.ZIndex=25
    hit.MouseButton1Click:Connect(function() setV(not isOn); cb(isOn) end)
    return row, setV
end

-- Slider
local function mkSlider(p,lbl,mn,mx,def,cb)
    local f=Instance.new("Frame",p)
    f.Size=UDim2.new(1,0,0,52); f.BackgroundColor3=C.bg2; f.BorderSizePixel=0; f.ZIndex=23
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,8)
    local pad=Instance.new("UIPadding",f)
    pad.PaddingLeft=UDim.new(0,12); pad.PaddingRight=UDim.new(0,12); pad.PaddingTop=UDim.new(0,8)
    local nl=Instance.new("TextLabel",f)
    nl.Size=UDim2.new(0.7,0,0,18); nl.BackgroundTransparency=1; nl.Text=lbl
    nl.TextColor3=C.white; nl.Font=Enum.Font.GothamSemibold; nl.TextSize=12
    nl.TextXAlignment=Enum.TextXAlignment.Left; nl.ZIndex=24
    local vl=Instance.new("TextLabel",f)
    vl.Size=UDim2.new(0.3,0,0,18); vl.Position=UDim2.new(0.7,0,0,0)
    vl.BackgroundTransparency=1; vl.Text=tostring(def); vl.TextColor3=C.acc
    vl.Font=Enum.Font.GothamBold; vl.TextSize=12
    vl.TextXAlignment=Enum.TextXAlignment.Right; vl.ZIndex=24
    local track=Instance.new("Frame",f)
    track.Size=UDim2.new(1,0,0,4); track.Position=UDim2.new(0,0,0,30)
    track.BackgroundColor3=C.dim; track.BorderSizePixel=0; track.ZIndex=24
    Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)
    local r0=(def-mn)/(mx-mn)
    local fill=Instance.new("Frame",track)
    fill.Size=UDim2.new(r0,0,1,0); fill.BackgroundColor3=C.acc
    fill.BorderSizePixel=0; fill.ZIndex=25
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
    local knob=Instance.new("TextButton",track)
    knob.Size=UDim2.new(0,14,0,14); knob.Position=UDim2.new(r0,-7,0.5,-7)
    knob.BackgroundColor3=C.acc; knob.Text=""; knob.BorderSizePixel=0; knob.ZIndex=26
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    local drag=false; local mc,ec
    knob.MouseButton1Down:Connect(function()
        drag=true
        mc=UIS.InputChanged:Connect(function(inp)
            if not drag or inp.UserInputType~=Enum.UserInputType.MouseMovement then return end
            local r=math.clamp((inp.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
            local v=math.floor(mn+r*(mx-mn))
            fill.Size=UDim2.new(r,0,1,0); knob.Position=UDim2.new(r,-7,0.5,-7)
            vl.Text=tostring(v); cb(v)
        end)
        ec=UIS.InputEnded:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseButton1 then
                drag=false
                if mc then mc:Disconnect();mc=nil end
                if ec then ec:Disconnect();ec=nil end
            end
        end)
    end)
end

-- Text input card  (returns the TextBox)
local function mkInput(p,placeholder,height)
    local f=Instance.new("Frame",p)
    f.Size=UDim2.new(1,0,0,height or 38); f.BackgroundColor3=C.bg2
    f.BorderSizePixel=0; f.ZIndex=23
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,8)
    local pad=Instance.new("UIPadding",f)
    pad.PaddingLeft=UDim.new(0,10); pad.PaddingRight=UDim.new(0,10); pad.PaddingTop=UDim.new(0,7)
    local box=Instance.new("TextBox",f)
    box.Size=UDim2.new(1,0,0,24); box.BackgroundColor3=C.bg0
    box.TextColor3=C.white; box.PlaceholderText=placeholder or ""
    box.PlaceholderColor3=C.dim; box.Font=Enum.Font.Gotham
    box.TextSize=12; box.BorderSizePixel=0; box.Text=""
    box.ClearTextOnFocus=false; box.ZIndex=24
    Instance.new("UICorner",box).CornerRadius=UDim.new(0,6)
    local bs=Instance.new("UIStroke",box); bs.Color=C.dim; bs.Thickness=1
    local bp=Instance.new("UIPadding",box); bp.PaddingLeft=UDim.new(0,8)
    return box, f
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  FEATURE FUNCTIONS
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local function tpTo(pos,name)
    local char=LP.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CFrame=CFrame.new(pos+Vector3.new(0,4,0)); notify("→ "..name,"📍")
    else notify("No character","❌",C.red) end
end

-- ── Fly ──────────────────────────────────────────────────────
local function enableFly()
    local char=LP.Character; if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart")
    local hum=char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    hum.PlatformStand=true
    S.bv=Instance.new("BodyVelocity",hrp)
    S.bv.Velocity=Vector3.zero; S.bv.MaxForce=Vector3.new(1e5,1e5,1e5)
    S.bg_=Instance.new("BodyGyro",hrp)
    S.bg_.MaxTorque=Vector3.new(1e5,1e5,1e5); S.bg_.D=100; S.bg_.CFrame=hrp.CFrame
    S.flyConn=RS.Heartbeat:Connect(function()
        if not S.fly then return end
        local cam=workspace.CurrentCamera; local d=Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W)         then d=d+cam.CFrame.LookVector  end
        if UIS:IsKeyDown(Enum.KeyCode.S)         then d=d-cam.CFrame.LookVector  end
        if UIS:IsKeyDown(Enum.KeyCode.A)         then d=d-cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D)         then d=d+cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space)     then d=d+Vector3.yAxis          end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then d=d-Vector3.yAxis          end
        if d.Magnitude>0 then d=d.Unit end
        S.bv.Velocity=d*S.flySpeed
        local lk=cam.CFrame.LookVector; local fl=Vector3.new(lk.X,0,lk.Z)
        if fl.Magnitude>0 then S.bg_.CFrame=CFrame.new(Vector3.zero,fl) end
    end)
    notify("Fly ON — WASD + Space/Shift","✈️")
end
local function disableFly()
    local hum=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand=false end
    if S.flyConn then S.flyConn:Disconnect();S.flyConn=nil end
    if S.bv then S.bv:Destroy();S.bv=nil end
    if S.bg_ then S.bg_:Destroy();S.bg_=nil end
    notify("Fly OFF","✈️")
end

-- ── God ──────────────────────────────────────────────────────
local godC
local function enableGod()
    local hum=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid"); if not hum then return end
    hum.MaxHealth=1e6; hum.Health=1e6
    godC=hum.HealthChanged:Connect(function() if S.god then hum.Health=1e6 end end)
    notify("God Mode ON","🛡️",C.green)
end
local function disableGod()
    local hum=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.MaxHealth=100; hum.Health=100 end
    if godC then godC:Disconnect();godC=nil end
    notify("God Mode OFF","🛡️")
end

-- ── NoClip ───────────────────────────────────────────────────
local function buildNC()
    local char=LP.Character; if not char then return end
    S.noclipParts={}
    for _,d in ipairs(char:GetDescendants()) do
        if d:IsA("BasePart") then table.insert(S.noclipParts,d) end
    end
    char.DescendantAdded:Connect(function(d)
        if d:IsA("BasePart") then table.insert(S.noclipParts,d) end
    end)
end
local function enableNC()
    buildNC()
    S.noclipConn=RS.Stepped:Connect(function()
        for _,p in ipairs(S.noclipParts) do if p and p.Parent then p.CanCollide=false end end
    end)
    notify("NoClip ON","👻")
end
local function disableNC()
    if S.noclipConn then S.noclipConn:Disconnect();S.noclipConn=nil end
    for _,p in ipairs(S.noclipParts) do if p and p.Parent then p.CanCollide=true end end
    S.noclipParts={}
    notify("NoClip OFF","👻")
end

-- ── InfJump ──────────────────────────────────────────────────
local function enableIJ()
    S.jumpConn=UIS.JumpRequest:Connect(function()
        local hum=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
    notify("Infinite Jump ON","🐇",C.green)
end
local function disableIJ()
    if S.jumpConn then S.jumpConn:Disconnect();S.jumpConn=nil end
    notify("Infinite Jump OFF","🐇")
end

-- ── AutoChop ─────────────────────────────────────────────────
local function enableAC()
    S.chopConn=RS.Heartbeat:Connect(function()
        local char=LP.Character; if not char then return end
        local tool=char:FindFirstChildOfClass("Tool"); if not tool then return end
        local re=tool:FindFirstChild("Chop",true) or tool:FindFirstChildOfClass("RemoteEvent")
        if re then pcall(function() re:FireServer() end) end
    end)
    notify("Auto-Chop ON","🪓",C.green)
end
local function disableAC()
    if S.chopConn then S.chopConn:Disconnect();S.chopConn=nil end
    notify("Auto-Chop OFF","🪓")
end

-- ── Trail ────────────────────────────────────────────────────
local function enableTrail()
    S.trailConn=RS.Heartbeat:Connect(function()
        if not S.trail then return end
        local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        local g=Instance.new("Part",workspace)
        g.Size=Vector3.new(2,2,1); g.CFrame=hrp.CFrame; g.Anchored=true; g.CanCollide=false
        g.Material=Enum.Material.Neon; g.Color=C.acc; g.Transparency=0.15; g.CastShadow=false
        TS:Create(g,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{Transparency=1,Size=Vector3.new(2.8,2.8,1.6)}):Play()
        Debris:AddItem(g,0.55)
    end)
    notify("Ghost Trail ON","✨",C.acc)
end
local function disableTrail()
    if S.trailConn then S.trailConn:Disconnect();S.trailConn=nil end
    notify("Ghost Trail OFF","✨")
end

-- ── Anti-AFK ─────────────────────────────────────────────────
local function enableAFK()
    task.spawn(function()
        while S.antiAfk do
            task.wait(55)
            if not S.antiAfk then break end
            local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local orig=hrp.CFrame
                hrp.CFrame=orig*CFrame.new(0,0,0.05)
                task.wait(0.1); hrp.CFrame=orig
            end
        end
    end)
    notify("Anti-AFK ON","💤",C.green)
end

-- ── Lighting lock ────────────────────────────────────────────
local function lockLight(time,bright,fog)
    if time   then S.lockedTime=time     end
    if bright then S.lockedBright=bright end
    if fog    then S.lockedFog=fog       end
    if S.lightConn then S.lightConn:Disconnect() end
    S.lightConn=RS.Heartbeat:Connect(function()
        if not S.lightLocked then return end
        Lighting.ClockTime=S.lockedTime
        Lighting.Brightness=S.lockedBright
        Lighting.FogEnd=S.lockedFog
    end)
end
local function unlockLight()
    S.lightLocked=false
    if S.lightConn then S.lightConn:Disconnect();S.lightConn=nil end
end

-- ── ESP ──────────────────────────────────────────────────────
local function rmESP(pl)
    if S.espTags[pl] then S.espTags[pl]:Destroy();S.espTags[pl]=nil end
end
local function addESP(pl)
    if pl==LP or S.espTags[pl] then return end
    local function att(char)
        local hrp=char and char:WaitForChild("HumanoidRootPart",5); if not hrp then return end
        local bb=Instance.new("BillboardGui",hrp)
        bb.Name="GESP"; bb.Size=UDim2.new(0,140,0,36)
        bb.StudsOffset=Vector3.new(0,4,0); bb.AlwaysOnTop=true; bb.Adornee=hrp
        local bg_=Instance.new("Frame",bb); bg_.Size=UDim2.new(1,0,1,0)
        bg_.BackgroundColor3=C.bg0; bg_.BackgroundTransparency=0.3; bg_.BorderSizePixel=0
        Instance.new("UICorner",bg_).CornerRadius=UDim.new(0,6)
        local bs=Instance.new("UIStroke",bg_); bs.Color=C.acc; bs.Thickness=1
        local nL=Instance.new("TextLabel",bb); nL.Size=UDim2.new(1,0,0.55,0)
        nL.BackgroundTransparency=1; nL.Text=pl.Name; nL.TextColor3=C.acc
        nL.Font=Enum.Font.GothamBold; nL.TextSize=13
        nL.TextStrokeColor3=Color3.new(0,0,0); nL.TextStrokeTransparency=0.3
        local dL=Instance.new("TextLabel",bb); dL.Size=UDim2.new(1,0,0.45,0)
        dL.Position=UDim2.new(0,0,0.55,0); dL.BackgroundTransparency=1
        dL.TextColor3=C.muted; dL.Font=Enum.Font.Gotham; dL.TextSize=10
        dL.TextStrokeColor3=Color3.new(0,0,0); dL.TextStrokeTransparency=0.5
        local dc=RS.Heartbeat:Connect(function()
            if not S.esp then return end
            local mc=LP.Character; local mh=mc and mc:FindFirstChild("HumanoidRootPart")
            if mh and hrp and hrp.Parent then
                dL.Text=string.format("%.0f studs",(hrp.Position-mh.Position).Magnitude)
            end
        end)
        S.espTags[pl]=bb; bb.AncestryChanged:Connect(function() dc:Disconnect() end)
    end
    att(pl.Character)
    pl.CharacterAdded:Connect(function(c) if S.esp then task.wait(0.5);att(c) end end)
end
local function enableESP()
    for _,pl in ipairs(Players:GetPlayers()) do addESP(pl) end
    Players.PlayerAdded:Connect(function(pl) if S.esp then addESP(pl) end end)
    notify("ESP ON","👁️",C.acc)
end
local function disableESP()
    for pl in pairs(S.espTags) do rmESP(pl) end
    notify("ESP OFF","👁️")
end

-- ── Tree Radar ───────────────────────────────────────────────
local WOODS={"Oak","Elm","Cherry","Fir","Pine","Snowglow","Palm","Mangrove",
    "Mushroom","Spooky","Swamp","Phantasm","Sinister","Koa","Frost",
    "Cavecrawler","Volcano","Lava","Gold","Zombie","Phantom"}
local RARE={Gold=true,Frost=true,Lava=true,Phantom=true,Zombie=true,
    Cavecrawler=true,Phantasm=true,Sinister=true,Koa=true,
    Snowglow=true,Volcano=true,Mushroom=true,Spooky=true}
local function scanTrees(rareOnly)
    local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return {} end
    local found={}
    for _,obj in ipairs(workspace:GetDescendants()) do
        for _,wt in ipairs(WOODS) do
            if obj.Name:lower():find(wt:lower()) then
                if not rareOnly or RARE[wt] then
                    local pos
                    if obj:IsA("Model") then
                        local pp=obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")
                        if pp then pos=pp.Position end
                    elseif obj:IsA("BasePart") then pos=obj.Position end
                    if pos then
                        table.insert(found,{name=wt,dist=(pos-hrp.Position).Magnitude,pos=pos})
                        break
                    end
                end
            end
        end
    end
    table.sort(found,function(a,b) return a.dist<b.dist end)
    return found
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  WAYPOINTS
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local wpFrame -- assigned below
local function refreshWP()
    if not wpFrame then return end
    for _,c in ipairs(wpFrame:GetChildren()) do
        if not c:IsA("UIListLayout") then c:Destroy() end
    end
    if #S.waypoints==0 then
        local e=Instance.new("TextLabel",wpFrame)
        e.Size=UDim2.new(1,0,0,36); e.BackgroundTransparency=1
        e.Text="No waypoints saved yet"; e.TextColor3=C.muted
        e.Font=Enum.Font.Gotham; e.TextSize=11
        e.TextXAlignment=Enum.TextXAlignment.Center; e.ZIndex=24
        return
    end
    for i,wp in ipairs(S.waypoints) do
        local card=Instance.new("Frame",wpFrame)
        card.Size=UDim2.new(1,0,0,40); card.BackgroundColor3=C.bg2
        card.BorderSizePixel=0; card.ZIndex=23
        Instance.new("UICorner",card).CornerRadius=UDim.new(0,8)
        local bar=Instance.new("Frame",card); bar.Size=UDim2.new(0,3,0,24)
        bar.Position=UDim2.new(0,0,0.5,-12); bar.BackgroundColor3=C.acc
        bar.BorderSizePixel=0; bar.ZIndex=24
        Instance.new("UICorner",bar).CornerRadius=UDim.new(1,0)
        local nl=Instance.new("TextLabel",card)
        nl.Size=UDim2.new(1,-100,0,20); nl.Position=UDim2.new(0,12,0,4)
        nl.BackgroundTransparency=1; nl.Text=wp.name; nl.TextColor3=C.white
        nl.Font=Enum.Font.GothamSemibold; nl.TextSize=12
        nl.TextXAlignment=Enum.TextXAlignment.Left; nl.ZIndex=24
        local cl=Instance.new("TextLabel",card)
        cl.Size=UDim2.new(1,-100,0,14); cl.Position=UDim2.new(0,12,0,22)
        cl.BackgroundTransparency=1
        cl.Text=string.format("(%d,%d,%d)",wp.pos.X,wp.pos.Y,wp.pos.Z)
        cl.TextColor3=C.muted; cl.Font=Enum.Font.Gotham; cl.TextSize=9
        cl.TextXAlignment=Enum.TextXAlignment.Left; cl.ZIndex=24
        local gb=Instance.new("TextButton",card)
        gb.Size=UDim2.new(0,36,0,22); gb.Position=UDim2.new(1,-88,0.5,-11)
        gb.BackgroundColor3=C.accDim; gb.TextColor3=C.acc
        gb.Font=Enum.Font.GothamBold; gb.TextSize=10; gb.Text="GO"
        gb.BorderSizePixel=0; gb.ZIndex=25
        Instance.new("UICorner",gb).CornerRadius=UDim.new(0,5)
        local cw=wp; gb.MouseButton1Click:Connect(function() tpTo(cw.pos,cw.name) end)
        local db=Instance.new("TextButton",card)
        db.Size=UDim2.new(0,36,0,22); db.Position=UDim2.new(1,-46,0.5,-11)
        db.BackgroundColor3=Color3.fromRGB(50,15,15); db.TextColor3=C.red
        db.Font=Enum.Font.GothamBold; db.TextSize=10; db.Text="DEL"
        db.BorderSizePixel=0; db.ZIndex=25
        Instance.new("UICorner",db).CornerRadius=UDim.new(0,5)
        local ci=i; db.MouseButton1Click:Connect(function()
            table.remove(S.waypoints,ci); refreshWP()
            notify("Waypoint deleted","🗑️")
        end)
    end
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  BUILD PAGES
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- ── HOME ─────────────────────────────────────────────────────
do
    local p=mkPage("home")
    -- Info card
    local ic=Instance.new("Frame",p)
    ic.Size=UDim2.new(1,0,0,72); ic.BackgroundColor3=C.bg2; ic.BorderSizePixel=0; ic.ZIndex=23
    Instance.new("UICorner",ic).CornerRadius=UDim.new(0,8)
    local is=Instance.new("UIStroke",ic); is.Color=C.accD; is.Thickness=1
    local ilay=Instance.new("UIListLayout",ic)
    ilay.Padding=UDim.new(0,0); ilay.FillDirection=Enum.FillDirection.Vertical
    local ipad=Instance.new("UIPadding",ic)
    ipad.PaddingTop=UDim.new(0,8); ipad.PaddingLeft=UDim.new(0,12)
    local function iln(t,col)
        local l=Instance.new("TextLabel",ic)
        l.Size=UDim2.new(1,-12,0,18); l.BackgroundTransparency=1
        l.Text=t; l.TextColor3=col or C.muted; l.Font=Enum.Font.GothamSemibold
        l.TextSize=11; l.TextXAlignment=Enum.TextXAlignment.Left; l.ZIndex=24
    end
    iln("👤  "..LP.Name.."   (ID: "..LP.UserId..")", C.white)
    iln("🖥️  Place ID: "..game.PlaceId)
    local tl=Instance.new("TextLabel",ic)
    tl.Size=UDim2.new(1,-12,0,18); tl.BackgroundTransparency=1
    tl.TextColor3=C.acc; tl.Font=Enum.Font.GothamSemibold
    tl.TextSize=11; tl.TextXAlignment=Enum.TextXAlignment.Left; tl.ZIndex=24
    RS.Heartbeat:Connect(function()
        if not S.open then return end
        local e=math.floor(tick()-S.sessionStart)
        tl.Text=string.format("⏱️  Session  %02d:%02d",math.floor(e/60),e%60)
    end)

    rowBtn(p,"🔄  Rejoin Server","Reconnect to a fresh server",function()
        game:GetService("TeleportService"):Teleport(game.PlaceId,LP)
        notify("Rejoining…","🔄")
    end)
    rowBtn(p,"👥  List Players","Show everyone currently online",function()
        local ns={}
        for _,pl in ipairs(Players:GetPlayers()) do table.insert(ns,pl.Name) end
        notify(table.concat(ns," · "),"👥")
    end)
end

-- ── PLAYER ───────────────────────────────────────────────────
do
    local p=mkPage("player")
    sec(p,"Movement")
    togRow(p,"✈️  Fly","WASD · Space up · LeftShift down",function(on)
        S.fly=on; if on then enableFly() else disableFly() end
    end)
    togRow(p,"👻  NoClip","Pass through walls & terrain",function(on)
        S.noclip=on; if on then enableNC() else disableNC() end
    end)
    togRow(p,"🛡️  God Mode","1 million HP — never die",function(on)
        S.god=on; if on then enableGod() else disableGod() end
    end)
    togRow(p,"🐇  Infinite Jump","Jump endlessly mid-air",function(on)
        S.infJump=on; if on then enableIJ() else disableIJ() end
    end)
    togRow(p,"💤  Anti-AFK","Nudge every 55s to prevent kick",function(on)
        S.antiAfk=on; if on then enableAFK() end
    end)
    togRow(p,"✨  Ghost Trail","Neon trail behind character",function(on)
        S.trail=on; if on then enableTrail() else disableTrail() end
    end)
    sec(p,"Speeds")
    mkSlider(p,"Walk Speed",4,150,16,function(v)
        S.walkSpeed=v
        local hum=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed=v end
        notify("Walk Speed → "..v,"🚶")
    end)
    mkSlider(p,"Jump Power",10,250,50,function(v)
        S.jumpPower=v
        local hum=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower=v end
        notify("Jump Power → "..v,"🐇")
    end)
    mkSlider(p,"Fly Speed",10,500,60,function(v)
        S.flySpeed=v; notify("Fly Speed → "..v,"✈️")
    end)
    sec(p,"LT2 Tools")
    togRow(p,"🪓  Auto-Chop","Fires axe swing every frame",function(on)
        S.autoChop=on; if on then enableAC() else disableAC() end
    end)
    rowBtn(p,"🪓  Equip Best Axe","Scans backpack, equips highest tier axe",function()
        local pri={"Silver Axe","Steel Axe","Rukiryaxe","Alpha Axe of the Woodlands",
            "AxeZilla","Frostbite Axe","Candy Cane Axe","Basic Hatchet"}
        local bp=LP:FindFirstChild("Backpack"); if not bp then notify("No backpack","❌",C.red); return end
        for _,an in ipairs(pri) do
            local t=bp:FindFirstChild(an)
            if t then
                local char=LP.Character; if char then t.Parent=char; notify("Equipped: "..an,"🪓",C.green); return end
            end
        end
        notify("No known axe in backpack","❌",C.red)
    end)
end

-- ── TELEPORT ─────────────────────────────────────────────────
do
    local p=mkPage("teleport")
    banner(p,"📍  Click any location to teleport instantly — coordinates verified")

    for _,cat in ipairs(LOCS) do
        sec(p,cat.cat)
        for _,item in ipairs(cat.items) do
            local name,sub,pos=item[1],item[2],item[3]
            local card=Instance.new("TextButton",p)
            card.Size=UDim2.new(1,0,0,50); card.BackgroundColor3=C.bg2
            card.BorderSizePixel=0; card.Text=""; card.ZIndex=23
            Instance.new("UICorner",card).CornerRadius=UDim.new(0,8)
            local bar_=Instance.new("Frame",card); bar_.Size=UDim2.new(0,3,0,30)
            bar_.Position=UDim2.new(0,0,0.5,-15); bar_.BackgroundColor3=C.acc
            bar_.BorderSizePixel=0; bar_.ZIndex=24
            Instance.new("UICorner",bar_).CornerRadius=UDim.new(1,0)
            local nl=Instance.new("TextLabel",card)
            nl.Size=UDim2.new(1,-120,0,20); nl.Position=UDim2.new(0,12,0,6)
            nl.BackgroundTransparency=1; nl.Text=name; nl.TextColor3=C.white
            nl.Font=Enum.Font.GothamSemibold; nl.TextSize=12
            nl.TextXAlignment=Enum.TextXAlignment.Left; nl.ZIndex=24
            local sl=Instance.new("TextLabel",card)
            sl.Size=UDim2.new(1,-120,0,14); sl.Position=UDim2.new(0,12,0,27)
            sl.BackgroundTransparency=1; sl.Text=sub; sl.TextColor3=C.muted
            sl.Font=Enum.Font.Gotham; sl.TextSize=10
            sl.TextXAlignment=Enum.TextXAlignment.Left; sl.ZIndex=24
            local cl=Instance.new("TextLabel",card)
            cl.Size=UDim2.new(0,108,0,14); cl.Position=UDim2.new(1,-116,0,6)
            cl.BackgroundTransparency=1
            cl.Text=string.format("(%d,%d,%d)",pos.X,pos.Y,pos.Z)
            cl.TextColor3=C.accD; cl.Font=Enum.Font.GothamSemibold; cl.TextSize=9
            cl.TextXAlignment=Enum.TextXAlignment.Right; cl.ZIndex=24
            local ar=Instance.new("TextLabel",card); ar.Size=UDim2.new(0,18,1,0)
            ar.Position=UDim2.new(1,-22,0,0); ar.BackgroundTransparency=1; ar.Text="›"
            ar.TextColor3=C.dim; ar.Font=Enum.Font.GothamBold; ar.TextSize=18; ar.ZIndex=24
            local tw=TweenInfo.new(0.1)
            card.MouseEnter:Connect(function()
                TS:Create(card,tw,{BackgroundColor3=C.bg3}):Play()
                TS:Create(ar,tw,{TextColor3=C.acc}):Play()
                TS:Create(bar_,tw,{BackgroundColor3=Color3.fromRGB(120,210,255)}):Play()
            end)
            card.MouseLeave:Connect(function()
                TS:Create(card,tw,{BackgroundColor3=C.bg2}):Play()
                TS:Create(ar,tw,{TextColor3=C.dim}):Play()
                TS:Create(bar_,tw,{BackgroundColor3=C.acc}):Play()
            end)
            local cp=pos; local cn=name
            card.MouseButton1Click:Connect(function()
                TS:Create(card,TweenInfo.new(0.06),{BackgroundColor3=C.accDim}):Play()
                task.delay(0.12,function() TS:Create(card,TweenInfo.new(0.1),{BackgroundColor3=C.bg2}):Play() end)
                tpTo(cp,cn)
            end)
        end
    end

    -- Custom coords
    sec(p,"Custom Coordinates")
    local ccard=Instance.new("Frame",p)
    ccard.Size=UDim2.new(1,0,0,76); ccard.BackgroundColor3=C.bg2
    ccard.BorderSizePixel=0; ccard.ZIndex=23
    Instance.new("UICorner",ccard).CornerRadius=UDim.new(0,8)
    local cp2=Instance.new("UIPadding",ccard)
    cp2.PaddingLeft=UDim.new(0,10); cp2.PaddingRight=UDim.new(0,10); cp2.PaddingTop=UDim.new(0,8)
    local ctl=Instance.new("TextLabel",ccard)
    ctl.Size=UDim2.new(1,0,0,14); ctl.BackgroundTransparency=1
    ctl.Text="Manual coordinates (X  ·  Y  ·  Z)"; ctl.TextColor3=C.muted
    ctl.Font=Enum.Font.Gotham; ctl.TextSize=10
    ctl.TextXAlignment=Enum.TextXAlignment.Left; ctl.ZIndex=24
    local boxes={}
    for i,bd in ipairs({{l="X",h="0"},{l="Y",h="5"},{l="Z",h="0"}}) do
        local xp=(i-1)*0.34
        local bl=Instance.new("TextLabel",ccard); bl.Size=UDim2.new(0,12,0,18)
        bl.Position=UDim2.new(xp,2,0,20); bl.BackgroundTransparency=1
        bl.Text=bd.l; bl.TextColor3=C.acc; bl.Font=Enum.Font.GothamBold
        bl.TextSize=10; bl.ZIndex=24
        local box=Instance.new("TextBox",ccard)
        box.Size=UDim2.new(0.26,0,0,24); box.Position=UDim2.new(xp+0.05,2,0,20)
        box.BackgroundColor3=C.bg0; box.TextColor3=C.white
        box.PlaceholderText=bd.h; box.PlaceholderColor3=C.dim
        box.Font=Enum.Font.Gotham; box.TextSize=11; box.BorderSizePixel=0
        box.Text=""; box.ClearTextOnFocus=false; box.ZIndex=24
        Instance.new("UICorner",box).CornerRadius=UDim.new(0,5)
        local bs=Instance.new("UIStroke",box); bs.Color=C.dim; bs.Thickness=1
        local bp2=Instance.new("UIPadding",box); bp2.PaddingLeft=UDim.new(0,6)
        boxes[i]=box
    end
    local gob=Instance.new("TextButton",ccard)
    gob.Size=UDim2.new(0,44,0,24); gob.Position=UDim2.new(1,-44,0,20)
    gob.BackgroundColor3=C.acc; gob.TextColor3=C.bg0; gob.Font=Enum.Font.GothamBold
    gob.TextSize=11; gob.Text="GO"; gob.BorderSizePixel=0; gob.ZIndex=24
    Instance.new("UICorner",gob).CornerRadius=UDim.new(0,6)
    local function doTP()
        local x,y,z=tonumber(boxes[1].Text),tonumber(boxes[2].Text),tonumber(boxes[3].Text)
        if x and y and z then tpTo(Vector3.new(x,y,z),string.format("(%d,%d,%d)",x,y,z))
        else notify("Enter valid X Y Z","⚠️",C.orange) end
    end
    gob.MouseButton1Click:Connect(doTP)
    for _,b in ipairs(boxes) do b.FocusLost:Connect(function(e) if e then doTP() end end) end
    local tip=Instance.new("TextLabel",ccard)
    tip.Size=UDim2.new(1,0,0,14); tip.Position=UDim2.new(0,0,0,52)
    tip.BackgroundTransparency=1
    tip.Text="💡 Enable Fly before going underground · Press Enter in any box"
    tip.TextColor3=C.dim; tip.Font=Enum.Font.Gotham; tip.TextSize=9
    tip.TextXAlignment=Enum.TextXAlignment.Left; tip.ZIndex=24
end

-- ── WAYPOINTS ────────────────────────────────────────────────
do
    local p=mkPage("waypoint")
    banner(p,"🚩  Save positions as named waypoints — teleport back anytime · Max 20")

    local nb,ncard=mkInput(p,"Waypoint name…",38)
    local sb2=Instance.new("TextButton",ncard)
    sb2.Size=UDim2.new(0,50,0,24); sb2.Position=UDim2.new(1,-50,0,7)
    sb2.BackgroundColor3=C.acc; sb2.TextColor3=C.bg0; sb2.Font=Enum.Font.GothamBold
    sb2.TextSize=11; sb2.Text="SAVE"; sb2.BorderSizePixel=0; sb2.ZIndex=25
    Instance.new("UICorner",sb2).CornerRadius=UDim.new(0,6)
    sb2.MouseButton1Click:Connect(function()
        if #S.waypoints>=20 then notify("Max 20 waypoints","⚠️",C.orange); return end
        local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then notify("No character","❌",C.red); return end
        local wn=nb.Text~="" and nb.Text or ("WP "..#S.waypoints+1)
        table.insert(S.waypoints,{name=wn,pos=hrp.Position})
        nb.Text=""; refreshWP()
        notify("Saved: "..wn,"🚩",C.green)
    end)

    wpFrame=Instance.new("Frame",p)
    wpFrame.Size=UDim2.new(1,0,0,600); wpFrame.BackgroundTransparency=1
    wpFrame.BorderSizePixel=0; wpFrame.ZIndex=23
    local wl=Instance.new("UIListLayout",wpFrame)
    wl.Padding=UDim.new(0,6); wl.FillDirection=Enum.FillDirection.Vertical
    wl.HorizontalAlignment=Enum.HorizontalAlignment.Center
    refreshWP()

    rowBtn(p,"🗑️  Clear All Waypoints",nil,function()
        S.waypoints={}; refreshWP(); notify("All waypoints cleared","🗑️")
    end)
end

-- ── RADAR ────────────────────────────────────────────────────
do
    local p=mkPage("radar")
    banner(p,"📡  Scans workspace for LT2 wood · Rare trees shown in gold · Top 20 by distance")

    local rf=Instance.new("Frame",p)
    rf.Size=UDim2.new(1,0,0,800); rf.BackgroundTransparency=1; rf.BorderSizePixel=0; rf.ZIndex=23
    local rl=Instance.new("UIListLayout",rf)
    rl.Padding=UDim.new(0,6); rl.FillDirection=Enum.FillDirection.Vertical
    rl.HorizontalAlignment=Enum.HorizontalAlignment.Center

    local function clearR()
        for _,c in ipairs(rf:GetChildren()) do
            if not c:IsA("UIListLayout") then c:Destroy() end
        end
    end
    local function showR(trees)
        clearR()
        if #trees==0 then
            local l=Instance.new("TextLabel",rf); l.Size=UDim2.new(1,0,0,36)
            l.BackgroundTransparency=1; l.Text="No trees found"
            l.TextColor3=C.muted; l.Font=Enum.Font.Gotham; l.TextSize=12
            l.TextXAlignment=Enum.TextXAlignment.Center; l.ZIndex=24
            return
        end
        for i=1,math.min(#trees,20) do
            local t=trees[i]; local col=RARE[t.name] and C.gold or C.acc
            local card=Instance.new("Frame",rf); card.Size=UDim2.new(1,0,0,40)
            card.BackgroundColor3=C.bg2; card.BorderSizePixel=0; card.ZIndex=23
            Instance.new("UICorner",card).CornerRadius=UDim.new(0,8)
            local bar_=Instance.new("Frame",card); bar_.Size=UDim2.new(0,3,0,24)
            bar_.Position=UDim2.new(0,0,0.5,-12); bar_.BackgroundColor3=col
            bar_.BorderSizePixel=0; bar_.ZIndex=24
            Instance.new("UICorner",bar_).CornerRadius=UDim.new(1,0)
            local nl=Instance.new("TextLabel",card)
            nl.Size=UDim2.new(1,-130,0,20); nl.Position=UDim2.new(0,12,0,3)
            nl.BackgroundTransparency=1
            nl.Text=(RARE[t.name] and "⭐ " or "🌲 ")..t.name.." Wood"
            nl.TextColor3=col; nl.Font=Enum.Font.GothamBold; nl.TextSize=12
            nl.TextXAlignment=Enum.TextXAlignment.Left; nl.ZIndex=24
            local dl=Instance.new("TextLabel",card)
            dl.Size=UDim2.new(1,-130,0,14); dl.Position=UDim2.new(0,12,0,22)
            dl.BackgroundTransparency=1
            dl.Text=string.format("%.0f studs · (%d,%d,%d)",t.dist,t.pos.X,t.pos.Y,t.pos.Z)
            dl.TextColor3=C.muted; dl.Font=Enum.Font.Gotham; dl.TextSize=9
            dl.TextXAlignment=Enum.TextXAlignment.Left; dl.ZIndex=24
            local gb=Instance.new("TextButton",card)
            gb.Size=UDim2.new(0,44,0,24); gb.Position=UDim2.new(1,-52,0.5,-12)
            gb.BackgroundColor3=C.accDim; gb.TextColor3=C.acc; gb.Font=Enum.Font.GothamBold
            gb.TextSize=10; gb.Text="GO"; gb.BorderSizePixel=0; gb.ZIndex=25
            Instance.new("UICorner",gb).CornerRadius=UDim.new(0,6)
            local ct=t; gb.MouseButton1Click:Connect(function() tpTo(ct.pos,ct.name.." Wood") end)
        end
    end

    rowBtn(p,"📡  Scan All Wood","Finds all wood types near you",function()
        notify("Scanning…","📡")
        task.spawn(function() local r=scanTrees(false); showR(r); notify("Found "..#r.." tree(s)","📡") end)
    end)
    rowBtn(p,"⭐  Scan Rare Only","Gold·Frost·Lava·Phantom & more",function()
        notify("Scanning for rare…","⭐")
        task.spawn(function() local r=scanTrees(true); showR(r); notify("Found "..#r.." rare tree(s)","⭐",C.gold) end)
    end)
    rowBtn(p,"🗑️  Clear Results",nil,function() clearR(); notify("Cleared","🗑️") end)
end

-- ── DUPE TAB ─────────────────────────────────────────────────
do
    local p=mkPage("dupe")
    banner(p,"⧉  Duplication tools — copies items/models locally · Does not affect server economy")

    sec(p,"Wood & Logs")
    rowBtn(p,"🪵  Dupe Nearby Logs","Clones all log/lumber parts within 25 studs",function()
        local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then notify("No character","❌",C.red); return end
        local duped=0
        for _,obj in ipairs(workspace:GetDescendants()) do
            local n=obj.Name:lower()
            if obj:IsA("BasePart") and (n:find("log") or n:find("plank") or n:find("lumber")) then
                if (obj.Position-hrp.Position).Magnitude<25 then
                    local cl=obj:Clone(); cl.Parent=workspace
                    cl.CFrame=obj.CFrame*CFrame.new(math.random(-4,4),1,math.random(-4,4))
                    cl:SetAttribute("GhxstDupe",true)
                    duped=duped+1
                end
            end
        end
        notify("Duped "..duped.." log(s)","🪵",C.green)
    end)
    rowBtn(p,"🪵  Pull All Logs To Me","Teleports every log in workspace to you",function()
        local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then notify("No character","❌",C.red); return end
        local count=0
        for _,obj in ipairs(workspace:GetDescendants()) do
            local n=obj.Name:lower()
            if obj:IsA("BasePart") and (n:find("log") or n:find("plank") or n:find("lumber")) then
                obj.CFrame=hrp.CFrame*CFrame.new(math.random(-6,6),1.5,math.random(-6,6))
                count=count+1
            end
        end
        notify("Pulled "..count.." piece(s) to you","🪵",C.green)
    end)
    rowBtn(p,"🗑️  Clear Duped Objects","Removes objects tagged by this script",function()
        local rm=0
        for _,obj in ipairs(workspace:GetDescendants()) do
            if obj:GetAttribute("GhxstDupe") then obj:Destroy(); rm=rm+1 end
        end
        notify("Removed "..rm.." duped object(s)","🗑️")
    end)

    sec(p,"Items & Models")
    rowBtn(p,"🔁  Dupe Nearest Item","Clones the closest BasePart to you",function()
        local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then notify("No character","❌",C.red); return end
        local closest,dist=nil,30
        for _,obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj~=hrp then
                local d=(obj.Position-hrp.Position).Magnitude
                if d<dist then closest=obj; dist=d end
            end
        end
        if closest then
            local cl=closest:Clone(); cl.Parent=workspace
            cl.CFrame=closest.CFrame*CFrame.new(3,0,0)
            cl:SetAttribute("GhxstDupe",true)
            notify("Duped: "..closest.Name,"🔁",C.green)
        else notify("Nothing within 30 studs","❌",C.red) end
    end)
    rowBtn(p,"💾  Save Nearby Structure","Snapshots all parts within 40 studs into memory",function()
        local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then notify("No character","❌",C.red); return end
        S.dupeStore={}
        local count=0
        for _,obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj:IsDescendantOf(LP.Character or Instance.new("Frame")) then
                local d=(obj.Position-hrp.Position).Magnitude
                if d<40 then
                    table.insert(S.dupeStore,{
                        name   = obj.Name,
                        size   = obj.Size,
                        cframe = hrp.CFrame:ToObjectSpace(obj.CFrame),
                        color  = obj.Color,
                        mat    = obj.Material,
                        anchored = obj.Anchored,
                    })
                    count=count+1
                end
            end
        end
        notify("Saved "..count.." parts to memory","💾",C.green)
    end)
    rowBtn(p,"📋  Paste Saved Structure","Re-spawns the saved structure at your position",function()
        if #S.dupeStore==0 then notify("Nothing saved — use Save first","⚠️",C.orange); return end
        local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then notify("No character","❌",C.red); return end
        for _,d in ipairs(S.dupeStore) do
            local part=Instance.new("Part",workspace)
            part.Name=d.name; part.Size=d.size
            part.CFrame=hrp.CFrame:ToWorldSpace(d.cframe)
            part.Color=d.color; part.Material=d.mat
            part.Anchored=d.anchored; part.CanCollide=true
            part:SetAttribute("GhxstDupe",true)
        end
        notify("Pasted "..#S.dupeStore.." parts","📋",C.green)
    end)
    rowBtn(p,"🗑️  Clear Memory","Erases the saved structure from memory",function()
        S.dupeStore={}; notify("Memory cleared","🗑️")
    end)
end

-- ── BASE STEAL TAB ───────────────────────────────────────────
do
    local p=mkPage("base")

    -- Warning banner
    local wb=Instance.new("Frame",p)
    wb.Size=UDim2.new(1,0,0,40); wb.BackgroundColor3=Color3.fromRGB(60,30,10)
    wb.BorderSizePixel=0; wb.ZIndex=23
    Instance.new("UICorner",wb).CornerRadius=UDim.new(0,8)
    local ws=Instance.new("UIStroke",wb); ws.Color=C.orange; ws.Thickness=1
    local wl2=Instance.new("TextLabel",wb)
    wl2.Size=UDim2.new(1,-16,1,0); wl2.Position=UDim2.new(0,10,0,0)
    wl2.BackgroundTransparency=1; wl2.TextWrapped=true
    wl2.Text="⚠️  Only use when you are whitelisted/trusted on the target plot"
    wl2.TextColor3=C.orange; wl2.Font=Enum.Font.GothamSemibold; wl2.TextSize=10
    wl2.TextXAlignment=Enum.TextXAlignment.Left; wl2.ZIndex=24

    sec(p,"Target Player")
    local tbox,tcard2=mkInput(p,"Enter target player name…",38)
    -- Add GO button inside the input card
    local tgo=Instance.new("TextButton",tcard2)
    tgo.Size=UDim2.new(0,50,0,24); tgo.Position=UDim2.new(1,-50,0,7)
    tgo.BackgroundColor3=C.accDim; tgo.TextColor3=C.acc; tgo.Font=Enum.Font.GothamBold
    tgo.TextSize=11; tgo.Text="FIND"; tgo.BorderSizePixel=0; tgo.ZIndex=25
    Instance.new("UICorner",tgo).CornerRadius=UDim.new(0,6)

    -- Status label
    local statLbl=Instance.new("TextLabel",p)
    statLbl.Size=UDim2.new(1,0,0,22); statLbl.BackgroundTransparency=1
    statLbl.Text="No target selected"; statLbl.TextColor3=C.muted
    statLbl.Font=Enum.Font.GothamSemibold; statLbl.TextSize=11
    statLbl.TextXAlignment=Enum.TextXAlignment.Left; statLbl.ZIndex=23

    local targetPlayer=nil

    tgo.MouseButton1Click:Connect(function()
        local name=tbox.Text; if name=="" then notify("Enter a name","⚠️",C.orange); return end
        local pl=Players:FindFirstChild(name)
        if pl then
            targetPlayer=pl
            statLbl.Text="✅  Target: "..pl.Name.." (ID: "..pl.UserId..")"
            statLbl.TextColor3=C.green
            notify("Target locked: "..pl.Name,"🎯",C.green)
        else
            statLbl.Text="❌  Player not found: "..name
            statLbl.TextColor3=C.red
            notify("Player not found","❌",C.red)
        end
    end)

    sec(p,"Steal Actions")

    rowBtn(p,"📋  Copy Base Structure","Saves all parts from target's plot into memory",function()
        if not targetPlayer then notify("Select a target first","⚠️",C.orange); return end
        local char=targetPlayer.Character
        local hrp=char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then notify("Target has no character","❌",C.red); return end
        S.dupeStore={}
        local count=0
        -- Scan for any models/parts within 60 studs of the target player
        for _,obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj~=hrp and not obj:IsDescendantOf(char) then
                local d=(obj.Position-hrp.Position).Magnitude
                if d<60 then
                    table.insert(S.dupeStore,{
                        name     = obj.Name,
                        size     = obj.Size,
                        cframe   = hrp.CFrame:ToObjectSpace(obj.CFrame),
                        color    = obj.Color,
                        mat      = obj.Material,
                        anchored = obj.Anchored,
                    })
                    count=count+1
                end
            end
        end
        notify("Copied "..count.." parts from "..targetPlayer.Name.."'s area","📋",C.green)
    end)

    rowBtn(p,"📦  Teleport To Target's Plot","Move you to where target player is standing",function()
        if not targetPlayer then notify("Select a target first","⚠️",C.orange); return end
        local tc=targetPlayer.Character
        local thrp=tc and tc:FindFirstChild("HumanoidRootPart")
        local myhrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if thrp and myhrp then
            myhrp.CFrame=thrp.CFrame*CFrame.new(4,0,0)
            notify("Teleported to "..targetPlayer.Name,"📦",C.acc)
        else notify("Could not find target position","❌",C.red) end
    end)

    rowBtn(p,"🏗️  Paste Copy At Your Plot","Rebuilds the copied structure at your location",function()
        if #S.dupeStore==0 then notify("Copy a base first","⚠️",C.orange); return end
        local myhrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not myhrp then notify("No character","❌",C.red); return end
        local count=0
        for _,d in ipairs(S.dupeStore) do
            local part=Instance.new("Part",workspace)
            part.Name=d.name; part.Size=d.size
            part.CFrame=myhrp.CFrame:ToWorldSpace(d.cframe)
            part.Color=d.color; part.Material=d.mat
            part.Anchored=d.anchored; part.CanCollide=true
            part:SetAttribute("GhxstDupe",true)
            count=count+1
        end
        notify("Built "..count.." parts at your location","🏗️",C.green)
    end)

    rowBtn(p,"💾  Save Copy To Memory","Stores current copy so it survives tab switches",function()
        if #S.dupeStore==0 then notify("Nothing to save","⚠️",C.orange); return end
        notify("Saved "..#S.dupeStore.." parts in memory · won't be lost","💾",C.green)
    end)

    rowBtn(p,"🗑️  Clear All Pasted Parts","Removes GhxstDupe-tagged parts from workspace",function()
        local rm=0
        for _,obj in ipairs(workspace:GetDescendants()) do
            if obj:GetAttribute("GhxstDupe") then obj:Destroy(); rm=rm+1 end
        end
        notify("Removed "..rm.." pasted part(s)","🗑️")
    end)
end

-- ── WORLD ────────────────────────────────────────────────────
do
    local p=mkPage("world")

    -- !! IMPORTANT: Lock lighting FIRST then set values !!
    local _,setLockVis=togRow(p,"🔒  Lock Lighting","Must be ON for time/effects to stick",function(on)
        S.lightLocked=on
        if on then lockLight(); notify("Lighting locked — overrides server cycle","🔒",C.green)
        else unlockLight(); notify("Lighting unlocked","🔒") end
    end)

    banner(p,"💡  Turn on Lock Lighting first — LT2 server cycle will revert changes otherwise")

    sec(p,"Time Presets")
    local presets={
        {"🌅  Dawn",    6,  "Dawn (6:00)"},
        {"🌤️  Morning", 8,  "Morning (8:00)"},
        {"☀️  Noon",   12,  "Noon (12:00)"},
        {"🌇  Sunset", 18,  "Sunset (18:00)"},
        {"🌙  Night",  22,  "Night (22:00)"},
        {"🌑  Midnight",0,  "Midnight (0:00)"},
    }
    for _,pr in ipairs(presets) do
        rowBtn(p,pr[1],nil,function()
            S.lockedTime=pr[2]; Lighting.ClockTime=pr[2]
            if S.lightLocked then lockLight(pr[2]) end
            notify(pr[3],"🕐")
        end)
    end

    sec(p,"Manual Clock")
    mkSlider(p,"Clock Time (0–24)",0,24,14,function(v)
        S.lockedTime=v; Lighting.ClockTime=v
        if S.lightLocked then lockLight(v) end
    end)

    sec(p,"Atmosphere")
    rowBtn(p,"✨  Full Bright","Max brightness, shadows off",function()
        S.lockedBright=5; Lighting.Brightness=5; Lighting.GlobalShadows=false
        if S.lightLocked then lockLight(nil,5) end
        notify("Full Bright ON","✨",C.gold)
    end)
    rowBtn(p,"🌧️  Dark Mode","Near-zero brightness, shadows on",function()
        S.lockedBright=0.04; Lighting.Brightness=0.04; Lighting.GlobalShadows=true
        if S.lightLocked then lockLight(nil,0.04) end
        notify("Dark Mode ON","🌧️")
    end)
    rowBtn(p,"🌫️  Dense Fog","Thick fog — ~80 stud visibility",function()
        S.lockedFog=80; Lighting.FogEnd=80
        Lighting.FogColor=Color3.fromRGB(180,180,180)
        if S.lightLocked then lockLight(nil,nil,80) end
        notify("Dense Fog ON","🌫️")
    end)
    rowBtn(p,"☀️  Clear Fog","Remove all fog",function()
        S.lockedFog=100000; Lighting.FogEnd=100000
        if S.lightLocked then lockLight(nil,nil,100000) end
        notify("Fog cleared","☀️")
    end)
    rowBtn(p,"🎨  Reset Lighting","Restore LT2 defaults & unlock",function()
        unlockLight(); S.lightLocked=false
        Lighting.ClockTime=14; Lighting.Brightness=2
        Lighting.FogEnd=100000; Lighting.GlobalShadows=true
        notify("Lighting reset","🎨")
    end)
end

-- ── ESP ──────────────────────────────────────────────────────
do
    local p=mkPage("esp")
    sec(p,"Visual")
    togRow(p,"👁️  Player ESP","Floating name tags with live distance",function(on)
        S.esp=on; if on then enableESP() else disableESP() end
    end)
    togRow(p,"➕  Crosshair","Centred crosshair overlay",function(on)
        S.xhair=on; xh.Visible=on
        notify(on and "Crosshair ON" or "Crosshair OFF","➕")
    end)
    rowBtn(p,"🔄  Refresh ESP","Re-attach tags to all current players",function()
        if S.esp then disableESP(); task.wait(0.1); enableESP(); notify("ESP refreshed","🔄")
        else notify("Enable ESP first","⚠️",C.orange) end
    end)

    sec(p,"Player Actions")
    local ptb,_=mkInput(p,"Player name…",38)
    rowBtn(p,"📍  Teleport To Player","Jumps to the player named above",function()
        local nm=ptb.Text; if nm=="" then notify("Enter a name","⚠️",C.orange); return end
        local pl=Players:FindFirstChild(nm)
        local mh=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if pl and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") and mh then
            mh.CFrame=pl.Character.HumanoidRootPart.CFrame*CFrame.new(4,0,0)
            notify("Teleported to "..nm,"📍",C.green)
        else notify("Player not found: "..nm,"❌",C.red) end
    end)
    rowBtn(p,"📋  List Players & IDs",nil,function()
        for _,pl in ipairs(Players:GetPlayers()) do
            notify(pl.Name.."  ·  ID: "..pl.UserId,"👤")
            task.wait(0.8)
        end
    end)
end

-- ── SETTINGS ─────────────────────────────────────────────────
do
    local p=mkPage("settings")

    -- Info card with actual text (fixes blank border bug)
    local ic2=Instance.new("Frame",p)
    ic2.Size=UDim2.new(1,0,0,68); ic2.BackgroundColor3=C.bg2
    ic2.BorderSizePixel=0; ic2.ZIndex=23
    Instance.new("UICorner",ic2).CornerRadius=UDim.new(0,8)
    local is2=Instance.new("UIStroke",ic2); is2.Color=C.accD; is2.Thickness=1
    local ilay2=Instance.new("UIListLayout",ic2)
    ilay2.Padding=UDim.new(0,0); ilay2.FillDirection=Enum.FillDirection.Vertical
    local ip2=Instance.new("UIPadding",ic2)
    ip2.PaddingTop=UDim.new(0,10); ip2.PaddingLeft=UDim.new(0,14)
    local function siLine(t,c)
        local l=Instance.new("TextLabel",ic2)
        l.Size=UDim2.new(1,-14,0,16); l.BackgroundTransparency=1
        l.Text=t; l.TextColor3=c or C.muted; l.Font=Enum.Font.GothamSemibold
        l.TextSize=12; l.TextXAlignment=Enum.TextXAlignment.Left; l.ZIndex=24
    end
    siLine("Username:   "..LP.Name, C.white)
    siLine("User ID:       "..tostring(LP.UserId), C.white)
    siLine("Toggle Key:  RightShift",C.acc)
    siLine("Version:       v5 · LT2 Edition")

    sec(p,"Actions")
    rowBtn(p,"🔄  Rejoin Server",nil,function()
        game:GetService("TeleportService"):Teleport(game.PlaceId,LP)
        notify("Rejoining…","🔄")
    end)
    rowBtn(p,"♻️  Reset All Features","Disables everything, restores defaults",function()
        if S.fly    then S.fly=false;    disableFly()  end
        if S.noclip then S.noclip=false; disableNC()   end
        if S.god    then S.god=false;    disableGod()  end
        if S.infJump then S.infJump=false; disableIJ() end
        if S.autoChop then S.autoChop=false; disableAC() end
        if S.esp    then S.esp=false;    disableESP()  end
        if S.trail  then S.trail=false;  disableTrail() end
        if S.lightLocked then unlockLight() end
        S.antiAfk=false; xh.Visible=false
        local hum=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed=16; hum.JumpPower=50 end
        notify("All features reset to defaults","♻️")
    end)

    sec(p,"About")
    local ac=Instance.new("Frame",p)
    ac.Size=UDim2.new(1,0,0,56); ac.BackgroundColor3=C.bg2; ac.BorderSizePixel=0; ac.ZIndex=23
    Instance.new("UICorner",ac).CornerRadius=UDim.new(0,8)
    local al=Instance.new("UIListLayout",ac); al.Padding=UDim.new(0,0)
    local apad=Instance.new("UIPadding",ac); apad.PaddingTop=UDim.new(0,8); apad.PaddingLeft=UDim.new(0,14)
    local function aln(t)
        local l=Instance.new("TextLabel",ac); l.Size=UDim2.new(1,-14,0,16)
        l.BackgroundTransparency=1; l.Text=t; l.TextColor3=C.muted
        l.Font=Enum.Font.Gotham; l.TextSize=11
        l.TextXAlignment=Enum.TextXAlignment.Left; l.ZIndex=24
    end
    aln("GHXST Menu  v5  ·  LT2 Edition")
    aln("Toggle: RightShift  ·  Drag title bar to move")
    aln("Inspired by Kron & Infinite Yield")
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  OPEN / CLOSE
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local function openMenu()
    pill.Visible=false; win.Visible=true
    win.Size=UDim2.new(0,WW,0,0); win.BackgroundTransparency=1
    TS:Create(win,TweenInfo.new(0.28,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
        {Size=UDim2.new(0,WW,0,WH),BackgroundTransparency=0}):Play()
    S.open=true; switchTab(S.tab)
end
local function closeMenu()
    TS:Create(win,TweenInfo.new(0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.In),
        {Size=UDim2.new(0,WW,0,0),BackgroundTransparency=1}):Play()
    task.delay(0.2,function() win.Visible=false; pill.Visible=true end)
    S.open=false
end

pill.MouseButton1Click:Connect(function() if S.open then closeMenu() else openMenu() end end)
closeBtn.MouseButton1Click:Connect(closeMenu)
minBtn.MouseButton1Click:Connect(closeMenu)
UIS.InputBegan:Connect(function(inp,proc)
    if proc then return end
    if inp.KeyCode==TOGGLE_KEY then if S.open then closeMenu() else openMenu() end end
end)

-- ── Drag ─────────────────────────────────────────────────────
local dragOn,dragSt,winSt2
dragHandle.InputBegan:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1 then
        dragOn=true; dragSt=inp.Position; winSt2=win.Position
    end
end)
UIS.InputEnded:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragOn=false end
end)
UIS.InputChanged:Connect(function(inp)
    if dragOn and inp.UserInputType==Enum.UserInputType.MouseMovement then
        local d=inp.Position-dragSt
        win.Position=UDim2.new(winSt2.X.Scale,winSt2.X.Offset+d.X,winSt2.Y.Scale,winSt2.Y.Offset+d.Y)
    end
end)

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  RESPAWN PERSISTENCE
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

LP.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid"); task.wait(0.6)
    local hum=char:FindFirstChildOfClass("Humanoid")
    if hum then
        if S.walkSpeed~=16 then hum.WalkSpeed=S.walkSpeed end
        if S.jumpPower~=50  then hum.JumpPower=S.jumpPower   end
    end
    if S.fly      then task.wait(0.2); enableFly()   end
    if S.god      then task.wait(0.2); enableGod()   end
    if S.noclip   then task.wait(0.2); enableNC()    end
    if S.infJump  then task.wait(0.2); enableIJ()    end
    if S.autoChop then task.wait(0.2); enableAC()    end
    if S.trail    then task.wait(0.2); enableTrail() end
    if S.esp then
        for _,pl in ipairs(Players:GetPlayers()) do
            if pl~=LP then task.wait(0.08); addESP(pl) end
        end
    end
end)

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  INIT
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

switchTab("home")
print(string.format("[GhxstV5] Loaded — %s (%d)",LP.Name,LP.UserId))
task.delay(0.5,function()
    notify("GHXST v5 loaded  ·  RightShift to open","👻",C.acc)
end)
