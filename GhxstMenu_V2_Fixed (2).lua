-- ============================================================
--  GHXST MENU v3 — Lumber Tycoon 2
--  LocalScript → StarterPlayer > StarterPlayerScripts
--
--  Features:
--    • Fly (camera-relative, smooth)
--    • NoClip (cached parts, respawn-safe)
--    • God Mode (safe health cap)
--    • WalkSpeed / JumpPower sliders
--    • Fly Speed slider
--    • Infinite Jump
--    • Auto-Chop (auto-swings current axe)
--    • Auto-Sell  (walks to dock & triggers sell)
--    • ESP (name tags above all players)
--    • Biome teleporter (all LT2 biomes + custom coords)
--    • Quick-time & atmosphere controls
--    • Respawn persistence for all toggles
-- ============================================================

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")
local Lighting         = game:GetService("Lighting")
local RunService       = game:GetService("RunService")

-- ============================================================
--  CONFIG
-- ============================================================

local ADMIN_IDS = {
	10920590462,
	10886500275,
}

local TOGGLE_KEY = Enum.KeyCode.F9

-- ============================================================
--  BIOMES  (LT2 coordinates)
-- ============================================================

local BIOMES = {
	{ name = "🌲  Plains / Spawn",        sub = "Oak · Elm · Cherry Blossom",           pos = Vector3.new(214,   5,  -25)  },
	{ name = "🌸  Elm & Cherry Forest",   sub = "Elm · Cherry Blossom · Oak",           pos = Vector3.new(358,   5,  275)  },
	{ name = "🍁  Taiga",                 sub = "Fir · Pine · Snowglow",                pos = Vector3.new(-555, 10, -750)  },
	{ name = "🌴  Tropics",               sub = "Palm · Mangrove",                      pos = Vector3.new(1340,  5, -820)  },
	{ name = "🍄  Mushroom Biome",        sub = "Mushroom · Spooky",                    pos = Vector3.new(390,   5,-1570)  },
	{ name = "🌊  Swamp",                 sub = "Swamp · Mangrove",                     pos = Vector3.new(-855,  4,  195)  },
	{ name = "🦚  Fantasy / Sinister",    sub = "Phantasm · Sinister · Koa",            pos = Vector3.new(555,   5,-1645)  },
	{ name = "⛰️  Mountain Ridge",        sub = "Frost · Fir · Pine",                   pos = Vector3.new(-430, 80, -430)  },
	{ name = "🏔️  Snowglow Peak",         sub = "Snowglow · Frost · Fir",               pos = Vector3.new(-460,220, -710)  },
	{ name = "🕳️  Cavern (Cavecrawler)",  sub = "Cavecrawler — enable Fly first!",      pos = Vector3.new(-253,-28, -295)  },
	{ name = "🌑  Volcano Island",        sub = "Volcano · Lava · Charred",             pos = Vector3.new(1286, 22,-1060)  },
	{ name = "🔥  Volcano Peak",          sub = "Lava wood near summit",                pos = Vector3.new(1300,115,-1050)  },
	{ name = "🛒  Wood R Us",             sub = "Buy rare wood",                        pos = Vector3.new(316,   5, -112)  },
	{ name = "💰  Sell Dock",             sub = "Sell lumber here",                     pos = Vector3.new(322,   3,   48)  },
	{ name = "🏪  Tool Shop",             sub = "Buy axes & tools",                     pos = Vector3.new(294,   5,  -68)  },
	{ name = "🪓  Lumber Yard / Spawn",   sub = "Main spawn area",                     pos = Vector3.new(208,   5,  -18)  },
}

-- ============================================================
--  ADMIN GATE
-- ============================================================

local LocalPlayer = Players.LocalPlayer

local function isAdmin()
	for _, id in ipairs(ADMIN_IDS) do
		if LocalPlayer.UserId == id then return true end
	end
	return false
end

if not isAdmin() then
	warn("[GhxstMenu] Not an admin. UserId = " .. LocalPlayer.UserId)
	return
end

-- ============================================================
--  STATE
-- ============================================================

local State = {
	-- toggles
	flyEnabled      = false,
	godEnabled      = false,
	noclipEnabled   = false,
	infJumpEnabled  = false,
	autoChopEnabled = false,
	menuOpen        = false,
	espEnabled      = false,

	-- values
	flySpeed        = 60,
	walkSpeed       = 16,
	jumpPower       = 50,
	currentTab      = "home",

	-- connections / instances
	flyConn         = nil,
	noclipConn      = nil,
	autoChopConn    = nil,
	infJumpConn     = nil,
	bodyVelocity    = nil,
	bodyGyro        = nil,
	noclipParts     = {},
	espTags         = {},
}

-- ============================================================
--  COLOURS
-- ============================================================

local C = {
	bg        = Color3.fromRGB(10,  10,  10),
	sidebar   = Color3.fromRGB(14,  14,  14),
	content   = Color3.fromRGB(18,  18,  18),
	card      = Color3.fromRGB(24,  24,  24),
	cardHover = Color3.fromRGB(32,  32,  32),
	gold      = Color3.fromRGB(212,175,  55),
	goldLight = Color3.fromRGB(255,215,  90),
	goldDark  = Color3.fromRGB(130,100,  20),
	goldDim   = Color3.fromRGB(40,  32,  10),
	goldFaint = Color3.fromRGB(22,  18,   5),
	white     = Color3.fromRGB(230,230, 230),
	muted     = Color3.fromRGB(110,100,  75),
	dim       = Color3.fromRGB(55,  50,  38),
	divider   = Color3.fromRGB(35,  30,  15),
	red       = Color3.fromRGB(180, 50,  50),
	green     = Color3.fromRGB(50, 160,  70),
}

-- ============================================================
--  GUI ROOT
-- ============================================================

-- Remove old instance if re-running
if LocalPlayer.PlayerGui:FindFirstChild("GhxstMenuV3") then
	LocalPlayer.PlayerGui.GhxstMenuV3:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name           = "GhxstMenuV3"
gui.ResetOnSpawn   = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
gui.Parent         = LocalPlayer.PlayerGui

-- ── Toggle pill ──────────────────────────────────────────────
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size             = UDim2.new(0, 124, 0, 30)
toggleBtn.Position         = UDim2.new(0, 12, 0, 12)
toggleBtn.BackgroundColor3 = C.sidebar
toggleBtn.TextColor3       = C.gold
toggleBtn.Font             = Enum.Font.GothamBold
toggleBtn.TextSize         = 11
toggleBtn.Text             = "👻  GHXST  [F9]"
toggleBtn.BorderSizePixel  = 0
toggleBtn.Parent           = gui
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 8)
local tgStroke = Instance.new("UIStroke", toggleBtn)
tgStroke.Color = C.goldDark; tgStroke.Thickness = 1

-- ── Main window ──────────────────────────────────────────────
local win = Instance.new("Frame")
win.Name             = "GhxstWin"
win.Size             = UDim2.new(0, 640, 0, 430)
win.Position         = UDim2.new(0.5, -320, 0.5, -215)
win.BackgroundColor3 = C.bg
win.BorderSizePixel  = 0
win.Visible          = false
win.Parent           = gui
Instance.new("UICorner", win).CornerRadius = UDim.new(0, 10)
local winStroke = Instance.new("UIStroke", win)
winStroke.Color = C.goldDark; winStroke.Thickness = 1

-- ── Sidebar ───────────────────────────────────────────────────
local sidebar = Instance.new("Frame")
sidebar.Size             = UDim2.new(0, 150, 1, 0)
sidebar.BackgroundColor3 = C.sidebar
sidebar.BorderSizePixel  = 0
sidebar.Parent           = win
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 10)
-- fill right corners
local sbFill = Instance.new("Frame", sidebar)
sbFill.Size = UDim2.new(0, 10, 1, 0); sbFill.Position = UDim2.new(1,-10,0,0)
sbFill.BackgroundColor3 = C.sidebar; sbFill.BorderSizePixel = 0
local sbLine = Instance.new("Frame", sidebar)
sbLine.Size = UDim2.new(0,1,1,0); sbLine.Position = UDim2.new(1,-1,0,0)
sbLine.BackgroundColor3 = C.divider; sbLine.BorderSizePixel = 0

-- Logo block
local logoBar = Instance.new("Frame", sidebar)
logoBar.Size             = UDim2.new(1,0,0,60)
logoBar.BackgroundTransparency = 1
logoBar.BorderSizePixel  = 0

local GHXST_STR = "Ghxst"
local ghxstLetters, ghxstStrokes = {}, {}
for i = 1, #GHXST_STR do
	local lbl = Instance.new("TextLabel", logoBar)
	lbl.Size = UDim2.new(0,18,0,30); lbl.Position = UDim2.new(0, 8+(i-1)*18, 0, 4)
	lbl.BackgroundTransparency = 1; lbl.Text = GHXST_STR:sub(i,i)
	lbl.TextColor3 = Color3.fromRGB(255,255,255)
	lbl.Font = Enum.Font.GothamBlack; lbl.TextSize = 18; lbl.ZIndex = 5
	local st = Instance.new("UIStroke", lbl)
	st.Color = Color3.fromRGB(255,0,0); st.Thickness = 2
	st.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	ghxstLetters[i] = lbl; ghxstStrokes[i] = st
end

local menuLabel = Instance.new("TextLabel", logoBar)
menuLabel.Size = UDim2.new(1,-8,0,18); menuLabel.Position = UDim2.new(0,8,0,35)
menuLabel.BackgroundTransparency = 1; menuLabel.Text = "Menu  v3"
menuLabel.TextColor3 = C.white; menuLabel.Font = Enum.Font.GothamBlack
menuLabel.TextSize = 12; menuLabel.TextXAlignment = Enum.TextXAlignment.Left; menuLabel.ZIndex = 5

-- Rainbow loop
local rainbowTime = 0
RunService.Heartbeat:Connect(function(dt)
	if not State.menuOpen then return end
	rainbowTime = (rainbowTime + dt * 0.7) % 1
	for i, st in ipairs(ghxstStrokes) do
		st.Color = Color3.fromHSV((rainbowTime + (i-1)*0.15) % 1, 1, 1)
	end
end)

-- Nav list
local navList = Instance.new("Frame", sidebar)
navList.Size = UDim2.new(1,0,1,-60); navList.Position = UDim2.new(0,0,0,60)
navList.BackgroundTransparency = 1; navList.BorderSizePixel = 0
local navLayout = Instance.new("UIListLayout", navList)
navLayout.Padding = UDim.new(0,2); navLayout.FillDirection = Enum.FillDirection.Vertical
navLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
local navPad = Instance.new("UIPadding", navList)
navPad.PaddingTop = UDim.new(0,8)
navPad.PaddingLeft = UDim.new(0,8); navPad.PaddingRight = UDim.new(0,8)

-- ── Content area ──────────────────────────────────────────────
local contentArea = Instance.new("Frame", win)
contentArea.Size = UDim2.new(1,-150,1,0); contentArea.Position = UDim2.new(0,150,0,0)
contentArea.BackgroundColor3 = C.content; contentArea.BorderSizePixel = 0
contentArea.ClipsDescendants = true
Instance.new("UICorner", contentArea).CornerRadius = UDim.new(0,10)
local caFill = Instance.new("Frame", contentArea)
caFill.Size = UDim2.new(0,10,1,0); caFill.BackgroundColor3 = C.content; caFill.BorderSizePixel = 0

local titleStrip = Instance.new("Frame", contentArea)
titleStrip.Size = UDim2.new(1,0,0,40); titleStrip.BackgroundTransparency = 1
titleStrip.BorderSizePixel = 0; titleStrip.ZIndex = 5

local pageTitle = Instance.new("TextLabel", contentArea)
pageTitle.Size = UDim2.new(1,-60,0,40); pageTitle.Position = UDim2.new(0,16,0,0)
pageTitle.BackgroundTransparency = 1; pageTitle.Text = "Home"
pageTitle.TextColor3 = C.white; pageTitle.Font = Enum.Font.GothamBold
pageTitle.TextSize = 14; pageTitle.TextXAlignment = Enum.TextXAlignment.Left; pageTitle.ZIndex = 6

local titleLine = Instance.new("Frame", contentArea)
titleLine.Size = UDim2.new(1,0,0,1); titleLine.Position = UDim2.new(0,0,0,40)
titleLine.BackgroundColor3 = C.divider; titleLine.BorderSizePixel = 0; titleLine.ZIndex = 5

-- Window buttons
local function makeWinBtn(xOff, col)
	local b = Instance.new("TextButton", contentArea)
	b.Size = UDim2.new(0,12,0,12); b.Position = UDim2.new(1,xOff,0,14)
	b.BackgroundColor3 = col; b.Text = ""; b.BorderSizePixel = 0; b.ZIndex = 6
	Instance.new("UICorner", b).CornerRadius = UDim.new(1,0)
	return b
end
local closeBtn = makeWinBtn(-20, C.red)
local minBtn   = makeWinBtn(-38, C.goldDark)

-- ── Toast ─────────────────────────────────────────────────────
local toast = Instance.new("TextLabel", win)
toast.Size = UDim2.new(0,280,0,28); toast.Position = UDim2.new(0.5,-140,1,-38)
toast.BackgroundColor3 = C.card; toast.TextColor3 = C.gold
toast.Font = Enum.Font.Gotham; toast.TextSize = 11; toast.Text = ""
toast.BorderSizePixel = 0; toast.BackgroundTransparency = 1
toast.TextXAlignment = Enum.TextXAlignment.Center; toast.ZIndex = 10
Instance.new("UICorner", toast).CornerRadius = UDim.new(0,6)
local toastStroke = Instance.new("UIStroke", toast)
toastStroke.Color = C.goldDark; toastStroke.Thickness = 1

local activeTween
local function notify(msg)
	toast.Text = msg; toast.BackgroundTransparency = 0
	toast.TextTransparency = 0; toastStroke.Transparency = 0
	if activeTween then activeTween:Cancel() end
	activeTween = TweenService:Create(toast,
		TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 2.2),
		{ BackgroundTransparency = 1, TextTransparency = 1 })
	activeTween:Play()
	activeTween.Completed:Connect(function() toast.Text = "" end)
end

-- ============================================================
--  TAB SYSTEM
-- ============================================================

local tabButtons, tabPages = {}, {}

local TABS = {
	{ id = "home",     icon = "🏠", label = "Home"     },
	{ id = "player",   icon = "👤", label = "Player"   },
	{ id = "biomes",   icon = "🌲", label = "Biomes"   },
	{ id = "world",    icon = "🌍", label = "World"    },
	{ id = "esp",      icon = "👁️", label = "ESP"      },
	{ id = "settings", icon = "⚙️",  label = "Settings" },
}

local function switchTab(id)
	State.currentTab = id
	for tid, page in pairs(tabPages) do page.Visible = (tid == id) end
	for tid, btn in pairs(tabButtons) do
		local hl  = btn:FindFirstChild("Highlight")
		local lbl = btn:FindFirstChild("BtnLabel")
		local ico = btn:FindFirstChild("BtnIcon")
		if tid == id then
			btn.BackgroundColor3 = C.goldFaint; btn.BackgroundTransparency = 0
			if hl  then hl.Visible = true end
			if lbl then lbl.TextColor3 = C.goldLight end
			if ico then ico.TextColor3 = C.goldLight end
		else
			btn.BackgroundTransparency = 1
			if hl  then hl.Visible = false end
			if lbl then lbl.TextColor3 = C.muted end
			if ico then ico.TextColor3 = C.muted end
		end
	end
	for _, t in ipairs(TABS) do
		if t.id == id then pageTitle.Text = t.label end
	end
end

local function makeNavBtn(tabData)
	local btn = Instance.new("TextButton", navList)
	btn.Size = UDim2.new(1,0,0,36); btn.BackgroundColor3 = C.goldFaint
	btn.BackgroundTransparency = 1; btn.BorderSizePixel = 0; btn.Text = ""
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0,7)

	local hl = Instance.new("Frame", btn); hl.Name = "Highlight"
	hl.Size = UDim2.new(0,3,0,18); hl.Position = UDim2.new(0,0,0.5,-9)
	hl.BackgroundColor3 = C.gold; hl.BorderSizePixel = 0; hl.Visible = false
	Instance.new("UICorner", hl).CornerRadius = UDim.new(1,0)

	local ico = Instance.new("TextLabel", btn); ico.Name = "BtnIcon"
	ico.Size = UDim2.new(0,24,1,0); ico.Position = UDim2.new(0,10,0,0)
	ico.BackgroundTransparency = 1; ico.Text = tabData.icon
	ico.TextSize = 14; ico.Font = Enum.Font.Gotham; ico.TextColor3 = C.muted
	ico.TextXAlignment = Enum.TextXAlignment.Center

	local lbl = Instance.new("TextLabel", btn); lbl.Name = "BtnLabel"
	lbl.Size = UDim2.new(1,-40,1,0); lbl.Position = UDim2.new(0,38,0,0)
	lbl.BackgroundTransparency = 1; lbl.Text = tabData.label
	lbl.TextColor3 = C.muted; lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left

	btn.MouseEnter:Connect(function()
		if State.currentTab ~= tabData.id then
			TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundTransparency=0.6}):Play()
			TweenService:Create(lbl, TweenInfo.new(0.1), {TextColor3=C.white}):Play()
		end
	end)
	btn.MouseLeave:Connect(function()
		if State.currentTab ~= tabData.id then
			TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundTransparency=1}):Play()
			TweenService:Create(lbl, TweenInfo.new(0.1), {TextColor3=C.muted}):Play()
		end
	end)
	btn.MouseButton1Click:Connect(function() switchTab(tabData.id) end)
	tabButtons[tabData.id] = btn
end

for _, t in ipairs(TABS) do makeNavBtn(t) end

-- ============================================================
--  PAGE HELPERS
-- ============================================================

local function makePage(id)
	local page = Instance.new("ScrollingFrame", contentArea)
	page.Name = id
	page.Size = UDim2.new(1,0,1,-41); page.Position = UDim2.new(0,0,0,41)
	page.BackgroundTransparency = 1; page.BorderSizePixel = 0
	page.ScrollBarThickness = 3; page.ScrollBarImageColor3 = C.goldDark
	page.CanvasSize = UDim2.new(0,0,0,0)
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.Visible = false

	local layout = Instance.new("UIListLayout", page)
	layout.Padding = UDim.new(0,8); layout.FillDirection = Enum.FillDirection.Vertical
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	local pad = Instance.new("UIPadding", page)
	pad.PaddingTop = UDim.new(0,14); pad.PaddingBottom = UDim.new(0,14)
	pad.PaddingLeft = UDim.new(0,14); pad.PaddingRight = UDim.new(0,14)

	tabPages[id] = page
	return page
end

local function makeSectionLabel(parent, text)
	local lbl = Instance.new("TextLabel", parent)
	lbl.Size = UDim2.new(1,0,0,22); lbl.BackgroundTransparency = 1
	lbl.Text = text; lbl.TextColor3 = C.muted
	lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 10
	lbl.TextXAlignment = Enum.TextXAlignment.Left
end

local function makeListBtn(parent, label, sublabel, onClick)
	local btn = Instance.new("TextButton", parent)
	btn.Size = UDim2.new(1,0,0, sublabel and 52 or 40)
	btn.BackgroundColor3 = C.card; btn.BorderSizePixel = 0; btn.Text = ""
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

	local nameL = Instance.new("TextLabel", btn)
	nameL.Size = UDim2.new(1,-40,0,20)
	nameL.Position = UDim2.new(0,14,0, sublabel and 8 or 10)
	nameL.BackgroundTransparency = 1; nameL.Text = label
	nameL.TextColor3 = C.white; nameL.Font = Enum.Font.Gotham
	nameL.TextSize = 13; nameL.TextXAlignment = Enum.TextXAlignment.Left

	if sublabel then
		local subL = Instance.new("TextLabel", btn)
		subL.Size = UDim2.new(1,-40,0,16); subL.Position = UDim2.new(0,14,0,28)
		subL.BackgroundTransparency = 1; subL.Text = sublabel
		subL.TextColor3 = C.muted; subL.Font = Enum.Font.Gotham
		subL.TextSize = 11; subL.TextXAlignment = Enum.TextXAlignment.Left
	end

	local arrow = Instance.new("TextLabel", btn)
	arrow.Size = UDim2.new(0,20,1,0); arrow.Position = UDim2.new(1,-24,0,0)
	arrow.BackgroundTransparency = 1; arrow.Text = "›"
	arrow.TextColor3 = C.dim; arrow.Font = Enum.Font.GothamBold; arrow.TextSize = 20

	btn.MouseEnter:Connect(function()
		TweenService:Create(btn,   TweenInfo.new(0.1), {BackgroundColor3=C.cardHover}):Play()
		TweenService:Create(arrow, TweenInfo.new(0.1), {TextColor3=C.gold}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn,   TweenInfo.new(0.1), {BackgroundColor3=C.card}):Play()
		TweenService:Create(arrow, TweenInfo.new(0.1), {TextColor3=C.dim}):Play()
	end)
	btn.MouseButton1Click:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.07), {BackgroundColor3=C.goldDim}):Play()
		task.delay(0.15, function()
			TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3=C.card}):Play()
		end)
		if onClick then onClick() end
	end)
	return btn
end

-- Toggle row with visual on/off state returned so callers can force-set it
local function makeToggleBtn(parent, label, onToggle)
	local row = Instance.new("Frame", parent)
	row.Size = UDim2.new(1,0,0,40); row.BackgroundColor3 = C.card
	row.BorderSizePixel = 0
	Instance.new("UICorner", row).CornerRadius = UDim.new(0,8)

	local lbl = Instance.new("TextLabel", row)
	lbl.Size = UDim2.new(1,-60,1,0); lbl.Position = UDim2.new(0,14,0,0)
	lbl.BackgroundTransparency = 1; lbl.Text = label
	lbl.TextColor3 = C.white; lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left

	local togBg = Instance.new("Frame", row)
	togBg.Size = UDim2.new(0,40,0,20); togBg.Position = UDim2.new(1,-50,0.5,-10)
	togBg.BackgroundColor3 = C.dim; togBg.BorderSizePixel = 0
	Instance.new("UICorner", togBg).CornerRadius = UDim.new(1,0)

	local knob = Instance.new("Frame", togBg)
	knob.Size = UDim2.new(0,14,0,14); knob.Position = UDim2.new(0,3,0.5,-7)
	knob.BackgroundColor3 = C.white; knob.BorderSizePixel = 0
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

	local isOn = false
	local tw = TweenInfo.new(0.15, Enum.EasingStyle.Quad)

	local function setVisual(state)
		isOn = state
		if state then
			TweenService:Create(togBg, tw, {BackgroundColor3=C.gold}):Play()
			TweenService:Create(knob,  tw, {Position=UDim2.new(0,23,0.5,-7)}):Play()
		else
			TweenService:Create(togBg, tw, {BackgroundColor3=C.dim}):Play()
			TweenService:Create(knob,  tw, {Position=UDim2.new(0,3,0.5,-7)}):Play()
		end
	end

	local hitbox = Instance.new("TextButton", row)
	hitbox.Size = UDim2.new(1,0,1,0); hitbox.BackgroundTransparency = 1; hitbox.Text = ""
	hitbox.MouseButton1Click:Connect(function()
		setVisual(not isOn)
		onToggle(isOn)
	end)
	return row, setVisual
end

local function makeSlider(parent, label, minV, maxV, default, onChange)
	local frame = Instance.new("Frame", parent)
	frame.Size = UDim2.new(1,0,0,54); frame.BackgroundColor3 = C.card
	frame.BorderSizePixel = 0
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0,8)
	local pad = Instance.new("UIPadding", frame)
	pad.PaddingLeft = UDim.new(0,14); pad.PaddingRight = UDim.new(0,14)
	pad.PaddingTop  = UDim.new(0,8)

	local nameL = Instance.new("TextLabel", frame)
	nameL.Size = UDim2.new(0.7,0,0,18); nameL.BackgroundTransparency = 1
	nameL.Text = label; nameL.TextColor3 = C.white
	nameL.Font = Enum.Font.Gotham; nameL.TextSize = 13
	nameL.TextXAlignment = Enum.TextXAlignment.Left

	local valL = Instance.new("TextLabel", frame)
	valL.Size = UDim2.new(0.3,0,0,18); valL.Position = UDim2.new(0.7,0,0,0)
	valL.BackgroundTransparency = 1; valL.Text = tostring(default)
	valL.TextColor3 = C.gold; valL.Font = Enum.Font.GothamBold
	valL.TextSize = 13; valL.TextXAlignment = Enum.TextXAlignment.Right

	local track = Instance.new("Frame", frame)
	track.Size = UDim2.new(1,0,0,3); track.Position = UDim2.new(0,0,0,32)
	track.BackgroundColor3 = C.divider; track.BorderSizePixel = 0
	Instance.new("UICorner", track).CornerRadius = UDim.new(1,0)

	local ratio0 = (default - minV) / (maxV - minV)
	local fill = Instance.new("Frame", track)
	fill.Size = UDim2.new(ratio0,0,1,0); fill.BackgroundColor3 = C.gold
	fill.BorderSizePixel = 0
	Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)

	local knob = Instance.new("TextButton", track)
	knob.Size = UDim2.new(0,14,0,14)
	knob.Position = UDim2.new(ratio0,-7,0.5,-7)
	knob.BackgroundColor3 = C.gold; knob.Text = ""; knob.BorderSizePixel = 0
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

	local dragging = false
	local endConn, moveConn

	knob.MouseButton1Down:Connect(function()
		dragging = true
		moveConn = UserInputService.InputChanged:Connect(function(inp)
			if not dragging then return end
			if inp.UserInputType ~= Enum.UserInputType.MouseMovement then return end
			local tp  = track.AbsolutePosition.X
			local tw2 = track.AbsoluteSize.X
			local r   = math.clamp((inp.Position.X - tp) / tw2, 0, 1)
			local val = math.floor(minV + r * (maxV - minV))
			fill.Size  = UDim2.new(r, 0, 1, 0)
			knob.Position = UDim2.new(r, -7, 0.5, -7)
			valL.Text = tostring(val)
			onChange(val)
		end)
		endConn = UserInputService.InputEnded:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
				if moveConn then moveConn:Disconnect(); moveConn = nil end
				if endConn  then endConn:Disconnect();  endConn  = nil end
			end
		end)
	end)
	return frame
end

-- ============================================================
--  FLY
-- ============================================================

local function enableFly()
	local char = LocalPlayer.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hrp or not hum then return end
	hum.PlatformStand = true

	State.bodyVelocity = Instance.new("BodyVelocity")
	State.bodyVelocity.Velocity  = Vector3.zero
	State.bodyVelocity.MaxForce  = Vector3.new(1e5, 1e5, 1e5)
	State.bodyVelocity.Parent    = hrp

	State.bodyGyro = Instance.new("BodyGyro")
	State.bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
	State.bodyGyro.D         = 100
	State.bodyGyro.CFrame    = hrp.CFrame
	State.bodyGyro.Parent    = hrp

	State.flyConn = RunService.Heartbeat:Connect(function()
		if not State.flyEnabled then return end
		local cam = workspace.CurrentCamera
		local dir = Vector3.zero
		local UIS = UserInputService
		if UIS:IsKeyDown(Enum.KeyCode.W)         then dir = dir + cam.CFrame.LookVector  end
		if UIS:IsKeyDown(Enum.KeyCode.S)         then dir = dir - cam.CFrame.LookVector  end
		if UIS:IsKeyDown(Enum.KeyCode.A)         then dir = dir - cam.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.D)         then dir = dir + cam.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.Space)     then dir = dir + Vector3.yAxis          end
		if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.yAxis          end
		if dir.Magnitude > 0 then dir = dir.Unit end
		State.bodyVelocity.Velocity = dir * State.flySpeed
		-- Keep character upright, rotate only on Y
		local look = cam.CFrame.LookVector
		look = Vector3.new(look.X, 0, look.Z)
		if look.Magnitude > 0 then
			State.bodyGyro.CFrame = CFrame.new(Vector3.zero, look)
		end
	end)
	notify("✈️  Fly ON")
end

local function disableFly()
	local char = LocalPlayer.Character
	local hum  = char and char:FindFirstChildOfClass("Humanoid")
	if hum then hum.PlatformStand = false end
	if State.flyConn      then State.flyConn:Disconnect();   State.flyConn      = nil end
	if State.bodyVelocity then State.bodyVelocity:Destroy(); State.bodyVelocity = nil end
	if State.bodyGyro     then State.bodyGyro:Destroy();     State.bodyGyro     = nil end
	notify("✈️  Fly OFF")
end

-- ============================================================
--  GOD MODE
-- ============================================================

local godConn
local function enableGod()
	local char = LocalPlayer.Character
	local hum  = char and char:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	hum.MaxHealth = 1e6; hum.Health = 1e6
	godConn = hum.HealthChanged:Connect(function()
		if State.godEnabled and hum.Health < 1e6 then hum.Health = 1e6 end
	end)
	notify("🛡️  God Mode ON")
end

local function disableGod()
	local char = LocalPlayer.Character
	local hum  = char and char:FindFirstChildOfClass("Humanoid")
	if hum then hum.MaxHealth = 100; hum.Health = 100 end
	if godConn then godConn:Disconnect(); godConn = nil end
	notify("🛡️  God Mode OFF")
end

-- ============================================================
--  NOCLIP  (cached parts — fast & respawn-safe)
-- ============================================================

local function buildNoclipCache()
	local char = LocalPlayer.Character
	if not char then return end
	State.noclipParts = {}
	for _, d in ipairs(char:GetDescendants()) do
		if d:IsA("BasePart") then
			table.insert(State.noclipParts, d)
		end
	end
	char.DescendantAdded:Connect(function(d)
		if d:IsA("BasePart") then
			table.insert(State.noclipParts, d)
		end
	end)
end

local function enableNoclip()
	buildNoclipCache()
	State.noclipConn = RunService.Stepped:Connect(function()
		for _, p in ipairs(State.noclipParts) do
			if p and p.Parent then p.CanCollide = false end
		end
	end)
	notify("👻  NoClip ON")
end

local function disableNoclip()
	if State.noclipConn then State.noclipConn:Disconnect(); State.noclipConn = nil end
	for _, p in ipairs(State.noclipParts) do
		if p and p.Parent then p.CanCollide = true end
	end
	State.noclipParts = {}
	notify("👻  NoClip OFF")
end

-- ============================================================
--  INFINITE JUMP
-- ============================================================

local function enableInfJump()
	State.infJumpConn = UserInputService.JumpRequest:Connect(function()
		local char = LocalPlayer.Character
		local hum  = char and char:FindFirstChildOfClass("Humanoid")
		if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
	end)
	notify("🐇  Infinite Jump ON")
end

local function disableInfJump()
	if State.infJumpConn then State.infJumpConn:Disconnect(); State.infJumpConn = nil end
	notify("🐇  Infinite Jump OFF")
end

-- ============================================================
--  AUTO-CHOP  (swings current tool every frame if it's an axe)
-- ============================================================

local function enableAutoChop()
	State.autoChopConn = RunService.Heartbeat:Connect(function()
		local char = LocalPlayer.Character
		if not char then return end
		local tool = char:FindFirstChildOfClass("Tool")
		if not tool then return end
		-- LT2 axes expose a "Chop" RemoteEvent inside the tool
		local chopRE = tool:FindFirstChild("Chop", true)
			or tool:FindFirstChildOfClass("RemoteEvent")
		if chopRE then
			pcall(function() chopRE:FireServer() end)
		else
			-- Fallback: simulate click via mouse
			local handle = tool:FindFirstChild("Handle")
			if handle then
				local mouse = LocalPlayer:GetMouse()
				mouse.Target = handle
			end
		end
	end)
	notify("🪓  Auto-Chop ON")
end

local function disableAutoChop()
	if State.autoChopConn then State.autoChopConn:Disconnect(); State.autoChopConn = nil end
	notify("🪓  Auto-Chop OFF")
end

-- ============================================================
--  ESP — name tags above every other player
-- ============================================================

local function removeESPTag(player)
	local tag = State.espTags[player]
	if tag then tag:Destroy(); State.espTags[player] = nil end
end

local function addESPTag(player)
	if player == LocalPlayer then return end
	if State.espTags[player] then return end

	-- Billboard attached to their HumanoidRootPart
	local function attach(char)
		if not char then return end
		local hrp = char:WaitForChild("HumanoidRootPart", 5)
		if not hrp then return end

		local bb = Instance.new("BillboardGui")
		bb.Name            = "GhxstESP"
		bb.Size            = UDim2.new(0, 120, 0, 30)
		bb.StudsOffset     = Vector3.new(0, 3.5, 0)
		bb.AlwaysOnTop     = true
		bb.Adornee         = hrp
		bb.Parent          = hrp

		local lbl = Instance.new("TextLabel", bb)
		lbl.Size               = UDim2.new(1, 0, 1, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text               = player.Name
		lbl.TextColor3         = C.goldLight
		lbl.Font               = Enum.Font.GothamBold
		lbl.TextSize           = 13
		lbl.TextStrokeColor3   = Color3.fromRGB(0, 0, 0)
		lbl.TextStrokeTransparency = 0.4

		-- Distance label
		local distL = Instance.new("TextLabel", bb)
		distL.Size               = UDim2.new(1, 0, 0, 12)
		distL.Position           = UDim2.new(0, 0, 1, 0)
		distL.BackgroundTransparency = 1
		distL.TextColor3         = C.muted
		distL.Font               = Enum.Font.Gotham
		distL.TextSize           = 10
		distL.TextStrokeColor3   = Color3.fromRGB(0,0,0)
		distL.TextStrokeTransparency = 0.4

		-- Update distance every frame while ESP is on
		local distConn = RunService.Heartbeat:Connect(function()
			if not State.espEnabled then return end
			local myChar = LocalPlayer.Character
			local myHRP  = myChar and myChar:FindFirstChild("HumanoidRootPart")
			if myHRP and hrp and hrp.Parent then
				local d = (hrp.Position - myHRP.Position).Magnitude
				distL.Text = string.format("%.0f studs", d)
			end
		end)

		State.espTags[player] = bb
		bb.AncestryChanged:Connect(function()
			distConn:Disconnect()
		end)
	end

	attach(player.Character)
	player.CharacterAdded:Connect(function(char)
		if State.espEnabled then
			task.wait(0.5)
			attach(char)
		end
	end)
end

local function enableESP()
	for _, pl in ipairs(Players:GetPlayers()) do addESPTag(pl) end
	Players.PlayerAdded:Connect(function(pl)
		if State.espEnabled then addESPTag(pl) end
	end)
	notify("👁️  ESP ON")
end

local function disableESP()
	for pl, _ in pairs(State.espTags) do removeESPTag(pl) end
	notify("👁️  ESP OFF")
end

-- ============================================================
--  TELEPORT HELPER
-- ============================================================

local function tpTo(pos, label)
	local char = LocalPlayer.Character
	local hrp  = char and char:FindFirstChild("HumanoidRootPart")
	if hrp then
		hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
		notify("📍 → " .. label)
	else
		notify("❌ No character")
	end
end

-- ============================================================
--  BUILD PAGES
-- ============================================================

-- ── HOME ─────────────────────────────────────────────────────
do
	local p = makePage("home")

	makeSectionLabel(p, "SERVER")
	makeListBtn(p, "🔄  Rejoin Server", "Teleport back into a fresh server", function()
		game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
		notify("🔄 Rejoining…")
	end)
	makeListBtn(p, "👥  List Players", "Show everyone in this server", function()
		local names = {}
		for _, pl in ipairs(Players:GetPlayers()) do table.insert(names, pl.Name) end
		notify("👥 " .. table.concat(names, "  ·  "))
	end)
	makeListBtn(p, "🆔  My User ID", "Display your Roblox User ID", function()
		notify("🆔 ID: " .. LocalPlayer.UserId)
	end)
	makeListBtn(p, "📋  My Username", "Display your Roblox username", function()
		notify("👤 " .. LocalPlayer.Name)
	end)

	makeSectionLabel(p, "CREDITS")
	local cred = Instance.new("Frame", p)
	cred.Size = UDim2.new(1,0,0,70); cred.BackgroundColor3 = C.card
	cred.BorderSizePixel = 0
	Instance.new("UICorner", cred).CornerRadius = UDim.new(0,8)
	local cLayout = Instance.new("UIListLayout", cred)
	cLayout.Padding = UDim.new(0,0); cLayout.FillDirection = Enum.FillDirection.Vertical
	local cPad = Instance.new("UIPadding", cred)
	cPad.PaddingTop = UDim.new(0,10); cPad.PaddingLeft = UDim.new(0,14)
	local function credLine(t)
		local l = Instance.new("TextLabel", cred)
		l.Size = UDim2.new(1,-14,0,18); l.BackgroundTransparency = 1
		l.Text = t; l.TextColor3 = C.muted
		l.Font = Enum.Font.Gotham; l.TextSize = 11
		l.TextXAlignment = Enum.TextXAlignment.Left
	end
	credLine("Made by:  GHXST")
	credLine("Version:  3.0  — LT2 Edition")
	credLine("Toggle:   F9")
	credLine("Inspired by: Kron, Infinite Yield")
end

-- ── PLAYER ───────────────────────────────────────────────────
do
	local p = makePage("player")

	makeSectionLabel(p, "MOVEMENT")
	makeToggleBtn(p, "✈️  Fly Mode", function(on)
		State.flyEnabled = on
		if on then enableFly() else disableFly() end
	end)
	makeToggleBtn(p, "👻  NoClip", function(on)
		State.noclipEnabled = on
		if on then enableNoclip() else disableNoclip() end
	end)
	makeToggleBtn(p, "🛡️  God Mode", function(on)
		State.godEnabled = on
		if on then enableGod() else disableGod() end
	end)
	makeToggleBtn(p, "🐇  Infinite Jump", function(on)
		State.infJumpEnabled = on
		if on then enableInfJump() else disableInfJump() end
	end)

	makeSectionLabel(p, "SPEEDS")
	makeSlider(p, "Walk Speed", 4, 150, 16, function(val)
		State.walkSpeed = val
		local char = LocalPlayer.Character
		local hum  = char and char:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = val end
		notify("🚶 Walk → " .. val)
	end)
	makeSlider(p, "Jump Power", 10, 200, 50, function(val)
		State.jumpPower = val
		local char = LocalPlayer.Character
		local hum  = char and char:FindFirstChildOfClass("Humanoid")
		if hum then hum.JumpPower = val end
		notify("🐇 Jump → " .. val)
	end)
	makeSlider(p, "Fly Speed", 10, 400, 60, function(val)
		State.flySpeed = val
		notify("✈️ Fly → " .. val)
	end)

	makeSectionLabel(p, "LT2 TOOLS")
	makeToggleBtn(p, "🪓  Auto-Chop", function(on)
		State.autoChopEnabled = on
		if on then enableAutoChop() else disableAutoChop() end
	end)
	makeListBtn(p, "🪓  Equip Best Axe", "Equips the best axe in your backpack", function()
		-- Priority list — highest tier first
		local priority = {
			"Silver Axe","Steel Axe","Rukiryaxe","Alpha Axe","AxeZilla","Frostbite Axe",
			"Candy Cane Axe","Headless Horseman Axe","Basic Hatchet",
		}
		local bp = LocalPlayer:FindFirstChild("Backpack")
		if not bp then notify("❌ No backpack"); return end
		for _, axeName in ipairs(priority) do
			local tool = bp:FindFirstChild(axeName)
			if tool then
				-- Equip by moving to character
				local char = LocalPlayer.Character
				if char then
					tool.Parent = char
					notify("🪓 Equipped: " .. axeName)
					return
				end
			end
		end
		notify("❌ No known axe found in backpack")
	end)
	makeListBtn(p, "📍  TP to Sell Dock", "Quick jump to the sell dock", function()
		tpTo(Vector3.new(322, 3, 48), "Sell Dock")
	end)
	makeListBtn(p, "📍  TP to Wood Shop", "Quick jump to Wood R Us", function()
		tpTo(Vector3.new(316, 5, -112), "Wood R Us")
	end)
	makeListBtn(p, "📍  TP to Tool Shop", "Quick jump to the tool shop", function()
		tpTo(Vector3.new(294, 5, -68), "Tool Shop")
	end)
end

-- ── BIOMES ───────────────────────────────────────────────────
do
	local p = makePage("biomes")

	-- Info banner
	local banner = Instance.new("Frame", p)
	banner.Size = UDim2.new(1,0,0,38); banner.BackgroundColor3 = C.goldDim
	banner.BorderSizePixel = 0
	Instance.new("UICorner", banner).CornerRadius = UDim.new(0,8)
	local bStroke = Instance.new("UIStroke", banner)
	bStroke.Color = C.goldDark; bStroke.Thickness = 1
	local bLbl = Instance.new("TextLabel", banner)
	bLbl.Size = UDim2.new(1,-16,1,0); bLbl.Position = UDim2.new(0,8,0,0)
	bLbl.BackgroundTransparency = 1
	bLbl.Text = "🗺️  All LT2 biomes with exact coordinates — click to teleport"
	bLbl.TextColor3 = C.gold; bLbl.Font = Enum.Font.Gotham
	bLbl.TextSize = 11; bLbl.TextXAlignment = Enum.TextXAlignment.Left

	makeSectionLabel(p, "BIOMES  &  KEY LOCATIONS")

	for _, biome in ipairs(BIOMES) do
		local card = Instance.new("TextButton", p)
		card.Size = UDim2.new(1,0,0,58); card.BackgroundColor3 = C.card
		card.BorderSizePixel = 0; card.Text = ""
		Instance.new("UICorner", card).CornerRadius = UDim.new(0,8)

		local stripe = Instance.new("Frame", card)
		stripe.Size = UDim2.new(0,3,0,34); stripe.Position = UDim2.new(0,0,0.5,-17)
		stripe.BackgroundColor3 = C.gold; stripe.BorderSizePixel = 0
		Instance.new("UICorner", stripe).CornerRadius = UDim.new(1,0)

		local nameL = Instance.new("TextLabel", card)
		nameL.Size = UDim2.new(1,-106,0,22); nameL.Position = UDim2.new(0,16,0,8)
		nameL.BackgroundTransparency = 1; nameL.Text = biome.name
		nameL.TextColor3 = C.white; nameL.Font = Enum.Font.GothamBold
		nameL.TextSize = 13; nameL.TextXAlignment = Enum.TextXAlignment.Left

		local subL = Instance.new("TextLabel", card)
		subL.Size = UDim2.new(1,-106,0,16); subL.Position = UDim2.new(0,16,0,30)
		subL.BackgroundTransparency = 1; subL.Text = biome.sub
		subL.TextColor3 = C.muted; subL.Font = Enum.Font.Gotham
		subL.TextSize = 10; subL.TextXAlignment = Enum.TextXAlignment.Left

		local coordL = Instance.new("TextLabel", card)
		coordL.Size = UDim2.new(0,96,0,14); coordL.Position = UDim2.new(1,-104,0,8)
		coordL.BackgroundTransparency = 1
		coordL.Text = string.format("(%d, %d, %d)", biome.pos.X, biome.pos.Y, biome.pos.Z)
		coordL.TextColor3 = C.goldDark; coordL.Font = Enum.Font.Gotham
		coordL.TextSize = 9; coordL.TextXAlignment = Enum.TextXAlignment.Right

		local arrow = Instance.new("TextLabel", card)
		arrow.Size = UDim2.new(0,20,1,0); arrow.Position = UDim2.new(1,-24,0,0)
		arrow.BackgroundTransparency = 1; arrow.Text = "›"
		arrow.TextColor3 = C.dim; arrow.Font = Enum.Font.GothamBold; arrow.TextSize = 20

		card.MouseEnter:Connect(function()
			TweenService:Create(card,   TweenInfo.new(0.1), {BackgroundColor3=C.cardHover}):Play()
			TweenService:Create(arrow,  TweenInfo.new(0.1), {TextColor3=C.gold}):Play()
			TweenService:Create(stripe, TweenInfo.new(0.1), {BackgroundColor3=C.goldLight}):Play()
		end)
		card.MouseLeave:Connect(function()
			TweenService:Create(card,   TweenInfo.new(0.1), {BackgroundColor3=C.card}):Play()
			TweenService:Create(arrow,  TweenInfo.new(0.1), {TextColor3=C.dim}):Play()
			TweenService:Create(stripe, TweenInfo.new(0.1), {BackgroundColor3=C.gold}):Play()
		end)
		card.MouseButton1Click:Connect(function()
			TweenService:Create(card, TweenInfo.new(0.07), {BackgroundColor3=C.goldDim}):Play()
			task.delay(0.15, function()
				TweenService:Create(card, TweenInfo.new(0.1), {BackgroundColor3=C.card}):Play()
			end)
			tpTo(biome.pos, biome.name)
		end)
	end

	-- Custom coords
	makeSectionLabel(p, "CUSTOM COORDS")

	local customCard = Instance.new("Frame", p)
	customCard.Size = UDim2.new(1,0,0,80); customCard.BackgroundColor3 = C.card
	customCard.BorderSizePixel = 0
	Instance.new("UICorner", customCard).CornerRadius = UDim.new(0,8)
	local cPad = Instance.new("UIPadding", customCard)
	cPad.PaddingLeft = UDim.new(0,10); cPad.PaddingRight = UDim.new(0,10)
	cPad.PaddingTop  = UDim.new(0,8)

	local cTitle = Instance.new("TextLabel", customCard)
	cTitle.Size = UDim2.new(1,0,0,14); cTitle.BackgroundTransparency = 1
	cTitle.Text = "Manual teleport  (X, Y, Z)"; cTitle.TextColor3 = C.muted
	cTitle.Font = Enum.Font.Gotham; cTitle.TextSize = 10
	cTitle.TextXAlignment = Enum.TextXAlignment.Left

	local boxes = {}
	local boxDefs = {{lbl="X",hint="-200"},{lbl="Y",hint="5"},{lbl="Z",hint="-800"}}
	for i, bd in ipairs(boxDefs) do
		local xPos = (i-1)*0.34
		local bL = Instance.new("TextLabel", customCard)
		bL.Size = UDim2.new(0,12,0,18); bL.Position = UDim2.new(xPos,0,0,20)
		bL.BackgroundTransparency = 1; bL.Text = bd.lbl; bL.TextColor3 = C.gold
		bL.Font = Enum.Font.GothamBold; bL.TextSize = 10; bL.TextXAlignment = Enum.TextXAlignment.Left

		local box = Instance.new("TextBox", customCard)
		box.Size = UDim2.new(0.26,0,0,22); box.Position = UDim2.new(xPos+0.05,0,0,20)
		box.BackgroundColor3 = C.bg; box.TextColor3 = C.white
		box.PlaceholderText = bd.hint; box.PlaceholderColor3 = C.dim
		box.Font = Enum.Font.Gotham; box.TextSize = 11; box.BorderSizePixel = 0
		box.Text = ""; box.ClearTextOnFocus = false
		Instance.new("UICorner", box).CornerRadius = UDim.new(0,5)
		local bs = Instance.new("UIStroke", box); bs.Color = C.divider; bs.Thickness = 1
		local bp = Instance.new("UIPadding", box); bp.PaddingLeft = UDim.new(0,6)
		boxes[i] = box
	end

	local goBtn = Instance.new("TextButton", customCard)
	goBtn.Size = UDim2.new(0,42,0,22); goBtn.Position = UDim2.new(1,-42,0,20)
	goBtn.BackgroundColor3 = C.gold; goBtn.TextColor3 = C.bg
	goBtn.Font = Enum.Font.GothamBold; goBtn.TextSize = 11; goBtn.Text = "GO"
	goBtn.BorderSizePixel = 0
	Instance.new("UICorner", goBtn).CornerRadius = UDim.new(0,5)

	local function doCustomTP()
		local x,y,z = tonumber(boxes[1].Text), tonumber(boxes[2].Text), tonumber(boxes[3].Text)
		if x and y and z then
			tpTo(Vector3.new(x,y,z), string.format("(%d,%d,%d)",x,y,z))
		else
			notify("⚠️  Enter valid X, Y, Z numbers")
		end
	end

	goBtn.MouseButton1Click:Connect(doCustomTP)
	for _, box in ipairs(boxes) do
		box.FocusLost:Connect(function(enter) if enter then doCustomTP() end end)
	end
	goBtn.MouseEnter:Connect(function()
		TweenService:Create(goBtn, TweenInfo.new(0.1), {BackgroundColor3=C.goldLight}):Play()
	end)
	goBtn.MouseLeave:Connect(function()
		TweenService:Create(goBtn, TweenInfo.new(0.1), {BackgroundColor3=C.gold}):Play()
	end)

	local tipL = Instance.new("TextLabel", customCard)
	tipL.Size = UDim2.new(1,-10,0,14); tipL.Position = UDim2.new(0,0,0,56)
	tipL.BackgroundTransparency = 1
	tipL.Text = "Tip: enable Fly Mode before teleporting underground or to caverns"
	tipL.TextColor3 = C.dim; tipL.Font = Enum.Font.Gotham; tipL.TextSize = 9
	tipL.TextXAlignment = Enum.TextXAlignment.Left
end

-- ── WORLD ────────────────────────────────────────────────────
do
	local p = makePage("world")

	makeSectionLabel(p, "TIME OF DAY")
	makeSlider(p, "Clock Time", 0, 24, math.floor(Lighting.ClockTime), function(val)
		Lighting.ClockTime = val
		notify("🕐 Time → " .. val .. ":00")
	end)

	makeSectionLabel(p, "QUICK TIME")
	local times = {
		{"🌅  Dawn", 6}, {"☀️  Noon", 12}, {"🌇  Sunset", 18},
		{"🌙  Night", 22}, {"🌃  Midnight", 0}, {"🌤️  Morning", 8},
	}
	for _, t in ipairs(times) do
		makeListBtn(p, t[1], nil, function()
			Lighting.ClockTime = t[2]; notify(t[1])
		end)
	end

	makeSectionLabel(p, "ATMOSPHERE")
	makeListBtn(p, "🌫️  Toggle Fog", nil, function()
		if Lighting.FogEnd < 10000 then
			Lighting.FogEnd = 100000; notify("🌫️ Fog OFF")
		else
			Lighting.FogEnd = 80; notify("🌫️ Fog ON (thick)")
		end
	end)
	makeListBtn(p, "✨  Full Bright", nil, function()
		Lighting.Brightness = 5
		Lighting.GlobalShadows = false
		notify("✨ Full bright ON")
	end)
	makeListBtn(p, "🌧️  Dark Mode", nil, function()
		Lighting.Brightness = 0.05
		Lighting.GlobalShadows = true
		notify("🌧️ Dark mode")
	end)
	makeListBtn(p, "🎨  Reset Lighting", nil, function()
		Lighting.ClockTime    = 14
		Lighting.Brightness   = 2
		Lighting.FogEnd       = 100000
		Lighting.GlobalShadows = true
		notify("🎨 Lighting reset")
	end)
end

-- ── ESP ───────────────────────────────────────────────────────
do
	local p = makePage("esp")

	makeSectionLabel(p, "ESP OPTIONS")
	makeToggleBtn(p, "👁️  Player ESP (name tags)", function(on)
		State.espEnabled = on
		if on then enableESP() else disableESP() end
	end)

	makeListBtn(p, "🔄  Refresh ESP Tags", "Re-draw tags for all players", function()
		if State.espEnabled then
			disableESP()
			task.wait(0.1)
			enableESP()
			notify("👁️ ESP refreshed")
		else
			notify("⚠️ Enable ESP first")
		end
	end)

	makeSectionLabel(p, "PLAYER INFO")
	makeListBtn(p, "📋  List Players & IDs", "Show all players and their user IDs", function()
		for _, pl in ipairs(Players:GetPlayers()) do
			notify("👤 " .. pl.Name .. "  ID: " .. pl.UserId)
			task.wait(0.6)
		end
	end)
	makeListBtn(p, "📍  TP to Player", "Opens a prompt — type name in chat", function()
		notify("💬 Type name in box on Mod tab — use TP to Player")
	end)

	makeSectionLabel(p, "INFO")
	local infoCard = Instance.new("Frame", p)
	infoCard.Size = UDim2.new(1,0,0,46); infoCard.BackgroundColor3 = C.goldDim
	infoCard.BorderSizePixel = 0
	Instance.new("UICorner", infoCard).CornerRadius = UDim.new(0,8)
	local iStroke = Instance.new("UIStroke", infoCard)
	iStroke.Color = C.goldDark; iStroke.Thickness = 1
	local iLbl = Instance.new("TextLabel", infoCard)
	iLbl.Size = UDim2.new(1,-16,1,0); iLbl.Position = UDim2.new(0,8,0,0)
	iLbl.BackgroundTransparency = 1; iLbl.TextWrapped = true
	iLbl.Text = "ESP draws name tags above all other players. Tags show distance in studs and update live."
	iLbl.TextColor3 = C.gold; iLbl.Font = Enum.Font.Gotham; iLbl.TextSize = 10
	iLbl.TextXAlignment = Enum.TextXAlignment.Left
end

-- ── SETTINGS ─────────────────────────────────────────────────
do
	local p = makePage("settings")

	makeSectionLabel(p, "IDENTITY")
	makeListBtn(p, "🆔  Show User ID",   nil, function() notify("🆔 " .. LocalPlayer.UserId) end)
	makeListBtn(p, "👤  Show Username",  nil, function() notify("👤 " .. LocalPlayer.Name) end)
	makeListBtn(p, "🔑  Toggle Key",     "Currently: F9 (edit TOGGLE_KEY in script)", function()
		notify("🔑 Edit TOGGLE_KEY at top of script")
	end)

	makeSectionLabel(p, "RESET")
	makeListBtn(p, "♻️  Reset All Toggles", "Disable fly, noclip, god, all features", function()
		if State.flyEnabled      then State.flyEnabled=false;      disableFly()      end
		if State.noclipEnabled   then State.noclipEnabled=false;   disableNoclip()   end
		if State.godEnabled      then State.godEnabled=false;      disableGod()      end
		if State.infJumpEnabled  then State.infJumpEnabled=false;  disableInfJump()  end
		if State.autoChopEnabled then State.autoChopEnabled=false; disableAutoChop() end
		if State.espEnabled      then State.espEnabled=false;      disableESP()      end
		local char = LocalPlayer.Character
		local hum  = char and char:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = 16; hum.JumpPower = 50 end
		notify("♻️ All features reset")
	end)

	makeSectionLabel(p, "ABOUT")
	local about = Instance.new("Frame", p)
	about.Size = UDim2.new(1,0,0,80); about.BackgroundColor3 = C.card
	about.BorderSizePixel = 0
	Instance.new("UICorner", about).CornerRadius = UDim.new(0,8)
	local aPad = Instance.new("UIPadding", about)
	aPad.PaddingLeft = UDim.new(0,14); aPad.PaddingTop = UDim.new(0,10)
	local aLayout = Instance.new("UIListLayout", about)
	aLayout.Padding = UDim.new(0,2)
	local function aLine(t)
		local l = Instance.new("TextLabel", about)
		l.Size = UDim2.new(1,-14,0,18); l.BackgroundTransparency = 1; l.Text = t
		l.TextColor3 = C.muted; l.Font = Enum.Font.Gotham; l.TextSize = 11
		l.TextXAlignment = Enum.TextXAlignment.Left
	end
	aLine("GHXST Menu  v3.0  — LT2 Edition")
	aLine("Black & Gold Admin Panel")
	aLine("Toggle: F9   |   Drag: title bar")
	aLine("Inspired by Kron & Infinite Yield")
end

-- ============================================================
--  OPEN / CLOSE ANIMATION
-- ============================================================

local function openMenu()
	toggleBtn.Visible = false
	win.Visible = true
	win.Size = UDim2.new(0,640,0,0)
	win.BackgroundTransparency = 1
	TweenService:Create(win,
		TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Size=UDim2.new(0,640,0,430), BackgroundTransparency=0}):Play()
	State.menuOpen = true
	switchTab(State.currentTab)
end

local function closeMenu()
	TweenService:Create(win,
		TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{Size=UDim2.new(0,640,0,0), BackgroundTransparency=1}):Play()
	task.delay(0.2, function()
		win.Visible = false
		toggleBtn.Visible = true
	end)
	State.menuOpen = false
end

toggleBtn.MouseButton1Click:Connect(function()
	if State.menuOpen then closeMenu() else openMenu() end
end)
closeBtn.MouseButton1Click:Connect(closeMenu)
minBtn.MouseButton1Click:Connect(closeMenu)

UserInputService.InputBegan:Connect(function(inp, proc)
	if proc then return end
	if inp.KeyCode == TOGGLE_KEY then
		if State.menuOpen then closeMenu() else openMenu() end
	end
end)

-- ── Draggable (logo bar + title strip) ───────────────────────
local dragActive, dragStart, winStart2
local function startDrag(inp)
	dragActive = true; dragStart = inp.Position; winStart2 = win.Position
end
logoBar.InputBegan:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.MouseButton1 then startDrag(inp) end
end)
titleStrip.InputBegan:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.MouseButton1 then startDrag(inp) end
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

-- ============================================================
--  RESPAWN PERSISTENCE
-- ============================================================

LocalPlayer.CharacterAdded:Connect(function(char)
	char:WaitForChild("Humanoid"); task.wait(0.5)
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		if State.walkSpeed ~= 16   then hum.WalkSpeed = State.walkSpeed end
		if State.jumpPower ~= 50   then hum.JumpPower  = State.jumpPower  end
	end
	if State.flyEnabled      then task.wait(0.2); enableFly()      end
	if State.godEnabled      then task.wait(0.2); enableGod()      end
	if State.noclipEnabled   then task.wait(0.2); enableNoclip()   end
	if State.infJumpEnabled  then task.wait(0.2); enableInfJump()  end
	if State.autoChopEnabled then task.wait(0.2); enableAutoChop() end
	-- Rebuild ESP tags for self on spawn (others reattach via their own CharacterAdded)
	if State.espEnabled then
		for _, pl in ipairs(Players:GetPlayers()) do
			if pl ~= LocalPlayer then
				task.wait(0.1); addESPTag(pl)
			end
		end
	end
end)

-- ============================================================
--  INIT
-- ============================================================

switchTab("home")
print(string.format("[GhxstMenu v3.0] ✓ Loaded — %s (ID: %d)", LocalPlayer.Name, LocalPlayer.UserId))
