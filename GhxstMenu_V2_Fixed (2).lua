-- ============================================================
--  GHXST MENU v2 — Clean Black & Gold Admin Panel
--  LocalScript in StarterPlayer > StarterPlayerScripts
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
	10920590462, -- ← Replace with your actual Roblox User ID
}

local TOGGLE_KEY = Enum.KeyCode.F9
local FLY_KEY    = Enum.KeyCode.Q  -- ← Press Q to toggle fly instantly

local TELEPORT_LOCATIONS = {
	{ name = "Spawn",     pos = Vector3.new(0,   5,   0)   },
	{ name = "Sawmill",   pos = Vector3.new(100, 5,   0)   },
	{ name = "Wood Shop", pos = Vector3.new(0,   5,   100) },
	{ name = "Mountain",  pos = Vector3.new(-80, 60, -80)  },
}

-- ============================================================
--  ADMIN CHECK
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
	flyEnabled    = false,
	godEnabled    = false,
	noclipEnabled = false,
	menuOpen      = false,
	flySpeed      = 50,
	walkSpeed     = 16,
	currentTab    = "home",
	flyConn       = nil,
	noclipConn    = nil,
	bodyVelocity  = nil,
	bodyGyro      = nil,
}

-- ============================================================
--  COLOURS
-- ============================================================

local C = {
	bg         = Color3.fromRGB(10,  10,  10),
	sidebar    = Color3.fromRGB(14,  14,  14),
	content    = Color3.fromRGB(18,  18,  18),
	card       = Color3.fromRGB(24,  24,  24),
	cardHover  = Color3.fromRGB(32,  32,  32),
	gold       = Color3.fromRGB(212, 175, 55),
	goldLight  = Color3.fromRGB(255, 215, 90),
	goldDark   = Color3.fromRGB(130, 100, 20),
	goldDim    = Color3.fromRGB(40,  32,  10),
	goldFaint  = Color3.fromRGB(22,  18,  5),
	white      = Color3.fromRGB(230, 230, 230),
	muted      = Color3.fromRGB(110, 100, 75),
	dim        = Color3.fromRGB(55,  50,  38),
	divider    = Color3.fromRGB(35,  30,  15),
	red        = Color3.fromRGB(180, 50,  50),
	green      = Color3.fromRGB(50,  160, 70),
}

-- ============================================================
--  GUI ROOT
-- ============================================================

local gui = Instance.new("ScreenGui")
gui.Name           = "GhxstMenuV2"
gui.ResetOnSpawn   = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
gui.Parent         = LocalPlayer.PlayerGui

-- ── Toggle pill ──────────────────────────────────────────────
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size             = UDim2.new(0, 120, 0, 30)
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
win.Size             = UDim2.new(0, 620, 0, 420)
win.Position         = UDim2.new(0.5, -310, 0.5, -210)
win.BackgroundColor3 = C.bg
win.BorderSizePixel  = 0
win.Visible          = false
win.Parent           = gui
Instance.new("UICorner", win).CornerRadius = UDim.new(0, 10)
local winStroke = Instance.new("UIStroke", win)
winStroke.Color = C.goldDark; winStroke.Thickness = 1

-- ── Logo bar (top of sidebar) ─────────────────────────────────
local logoBar = Instance.new("Frame")
logoBar.Size             = UDim2.new(0, 150, 0, 60)
logoBar.Position         = UDim2.new(0, 0, 0, 0)
logoBar.BackgroundColor3 = C.sidebar
logoBar.BorderSizePixel  = 0
logoBar.ZIndex           = 3
logoBar.Parent           = win
Instance.new("UICorner", logoBar).CornerRadius = UDim.new(0, 10)
-- square off right + bottom corners
local logoFix1 = Instance.new("Frame", logoBar)
logoFix1.Size = UDim2.new(0, 10, 1, 0); logoFix1.Position = UDim2.new(1, -10, 0, 0)
logoFix1.BackgroundColor3 = C.sidebar; logoFix1.BorderSizePixel = 0
local logoFix2 = Instance.new("Frame", logoBar)
logoFix2.Size = UDim2.new(1, 0, 0, 10); logoFix2.Position = UDim2.new(0, 0, 1, -10)
logoFix2.BackgroundColor3 = C.sidebar; logoFix2.BorderSizePixel = 0

-- ── Rainbow outline title ─────────────────────────────────────
local GHXST_STR    = "Ghxst"
local LETTER_W     = 18
local TITLE_START_X = 8
local ghxstLetters = {}
local ghxstStrokes = {}

for i = 1, #GHXST_STR do
	local ch = GHXST_STR:sub(i, i)

	local lbl = Instance.new("TextLabel")
	lbl.Size                   = UDim2.new(0, LETTER_W, 0, 30)
	lbl.Position               = UDim2.new(0, TITLE_START_X + (i - 1) * LETTER_W, 0, 4)
	lbl.BackgroundTransparency = 1
	lbl.Text                   = ch
	lbl.TextColor3             = Color3.fromRGB(255, 255, 255)
	lbl.Font                   = Enum.Font.GothamBlack
	lbl.TextSize               = 18
	lbl.TextXAlignment         = Enum.TextXAlignment.Center
	lbl.ZIndex                 = 5
	lbl.Parent                 = logoBar

	local stroke = Instance.new("UIStroke", lbl)
	stroke.Color     = Color3.fromRGB(255, 0, 0)
	stroke.Thickness = 2
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual

	ghxstLetters[i] = lbl
	ghxstStrokes[i] = stroke
end

-- "Menu" below in bubble writing
local menuLabel = Instance.new("TextLabel")
menuLabel.Size                   = UDim2.new(1, -8, 0, 20)
menuLabel.Position               = UDim2.new(0, TITLE_START_X, 0, 34)
menuLabel.BackgroundTransparency = 1
menuLabel.Text                   = "Menu"
menuLabel.TextColor3             = Color3.fromRGB(230, 230, 230)
menuLabel.Font                   = Enum.Font.GothamBlack
menuLabel.TextSize               = 14
menuLabel.TextXAlignment         = Enum.TextXAlignment.Left
menuLabel.ZIndex                 = 5
menuLabel.Parent                 = logoBar

local menuShadow = Instance.new("TextLabel")
menuShadow.Size                   = UDim2.new(1, -8, 0, 20)
menuShadow.Position               = UDim2.new(0, TITLE_START_X + 1, 0, 36)
menuShadow.BackgroundTransparency = 1
menuShadow.Text                   = "Menu"
menuShadow.TextColor3             = Color3.fromRGB(0, 0, 0)
menuShadow.TextTransparency       = 0.55
menuShadow.Font                   = Enum.Font.GothamBlack
menuShadow.TextSize               = 14
menuShadow.TextXAlignment         = Enum.TextXAlignment.Left
menuShadow.ZIndex                 = 4
menuShadow.Parent                 = logoBar

-- Rainbow cycle
local rainbowTime = 0
RunService.Heartbeat:Connect(function(dt)
	rainbowTime = rainbowTime + dt * 0.7
	for i, stroke in ipairs(ghxstStrokes) do
		local hue = (rainbowTime + (i - 1) * 0.15) % 1
		stroke.Color = Color3.fromHSV(hue, 1, 1)
	end
end)

-- ── Sidebar ───────────────────────────────────────────────────
local sidebar = Instance.new("Frame")
sidebar.Name             = "Sidebar"
sidebar.Size             = UDim2.new(0, 150, 1, 0)
sidebar.Position         = UDim2.new(0, 0, 0, 0)
sidebar.BackgroundColor3 = C.sidebar
sidebar.BorderSizePixel  = 0
sidebar.Parent           = win
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 10)
local sbFix = Instance.new("Frame", sidebar)
sbFix.Size = UDim2.new(0, 10, 1, 0); sbFix.Position = UDim2.new(1, -10, 0, 0)
sbFix.BackgroundColor3 = C.sidebar; sbFix.BorderSizePixel = 0

local sbLine = Instance.new("Frame", sidebar)
sbLine.Size = UDim2.new(0, 1, 1, 0); sbLine.Position = UDim2.new(1, -1, 0, 0)
sbLine.BackgroundColor3 = C.divider; sbLine.BorderSizePixel = 0

local navList = Instance.new("Frame")
navList.Size             = UDim2.new(1, 0, 1, -60)
navList.Position         = UDim2.new(0, 0, 0, 60)
navList.BackgroundTransparency = 1
navList.BorderSizePixel  = 0
navList.Parent           = sidebar

local navLayout = Instance.new("UIListLayout", navList)
navLayout.Padding = UDim.new(0, 2)
navLayout.FillDirection = Enum.FillDirection.Vertical
navLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local navPad = Instance.new("UIPadding", navList)
navPad.PaddingTop = UDim.new(0, 8)
navPad.PaddingLeft = UDim.new(0, 8)
navPad.PaddingRight = UDim.new(0, 8)

-- ── Content area ──────────────────────────────────────────────
local contentArea = Instance.new("Frame")
contentArea.Size             = UDim2.new(1, -150, 1, 0)
contentArea.Position         = UDim2.new(0, 150, 0, 0)
contentArea.BackgroundColor3 = C.content
contentArea.BorderSizePixel  = 0
contentArea.ClipsDescendants = true
contentArea.Parent           = win
Instance.new("UICorner", contentArea).CornerRadius = UDim.new(0, 10)
local caFix = Instance.new("Frame", contentArea)
caFix.Size = UDim2.new(0, 10, 1, 0); caFix.Position = UDim2.new(0, 0, 0, 0)
caFix.BackgroundColor3 = C.content; caFix.BorderSizePixel = 0

local titleStrip = Instance.new("Frame")
titleStrip.Size             = UDim2.new(1, 0, 0, 40)
titleStrip.BackgroundTransparency = 1
titleStrip.BorderSizePixel  = 0
titleStrip.ZIndex           = 5
titleStrip.Parent           = contentArea

local function makeWinBtn(xOff, col)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, 12, 0, 12)
	b.Position = UDim2.new(1, xOff, 0, 14)
	b.BackgroundColor3 = col
	b.Text = ""; b.BorderSizePixel = 0
	b.ZIndex = 6
	b.Parent = contentArea
	Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
	return b
end
local closeBtn = makeWinBtn(-20, C.red)
local minBtn   = makeWinBtn(-38, C.goldDark)

local pageTitle = Instance.new("TextLabel")
pageTitle.Size                   = UDim2.new(1, -60, 0, 40)
pageTitle.Position               = UDim2.new(0, 16, 0, 0)
pageTitle.BackgroundTransparency = 1
pageTitle.Text                   = "Home"
pageTitle.TextColor3             = C.white
pageTitle.Font                   = Enum.Font.GothamBold
pageTitle.TextSize               = 14
pageTitle.TextXAlignment         = Enum.TextXAlignment.Left
pageTitle.ZIndex                 = 6
pageTitle.Parent                 = contentArea

local titleLine = Instance.new("Frame", contentArea)
titleLine.Size = UDim2.new(1, 0, 0, 1)
titleLine.Position = UDim2.new(0, 0, 0, 40)
titleLine.BackgroundColor3 = C.divider
titleLine.BorderSizePixel = 0; titleLine.ZIndex = 5

-- ============================================================
--  TAB SYSTEM
-- ============================================================

local tabButtons = {}
local tabPages   = {}

local TABS = {
	{ id = "home",     icon = "🏠", label = "Home"      },
	{ id = "player",   icon = "👤", label = "Player"    },
	{ id = "world",    icon = "🌍", label = "World"     },
	{ id = "dupe",     icon = "📋", label = "Dupe"      },
	{ id = "mod",      icon = "⚔️",  label = "Mod"       },
	{ id = "settings", icon = "⚙️",  label = "Settings"  },
}

local function switchTab(id)
	State.currentTab = id
	for tid, page in pairs(tabPages) do
		page.Visible = (tid == id)
	end
	for tid, btn in pairs(tabButtons) do
		local highlight = btn:FindFirstChild("Highlight")
		local lbl       = btn:FindFirstChild("BtnLabel")
		local ico       = btn:FindFirstChild("BtnIcon")
		if tid == id then
			btn.BackgroundColor3       = C.goldFaint
			btn.BackgroundTransparency = 0
			if highlight then highlight.Visible = true end
			if lbl then lbl.TextColor3 = C.goldLight end
			if ico then ico.TextColor3 = C.goldLight end
		else
			btn.BackgroundTransparency = 1
			if highlight then highlight.Visible = false end
			if lbl then lbl.TextColor3 = C.muted end
			if ico then ico.TextColor3 = C.muted end
		end
	end
	for _, t in ipairs(TABS) do
		if t.id == id then pageTitle.Text = t.label end
	end
end

local function makeNavBtn(tabData)
	local btn = Instance.new("TextButton")
	btn.Size                   = UDim2.new(1, 0, 0, 36)
	btn.BackgroundColor3       = C.goldFaint
	btn.BackgroundTransparency = 1
	btn.BorderSizePixel        = 0
	btn.Text                   = ""
	btn.Parent                 = navList
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)

	local highlight = Instance.new("Frame", btn)
	highlight.Name             = "Highlight"
	highlight.Size             = UDim2.new(0, 3, 0, 18)
	highlight.Position         = UDim2.new(0, 0, 0.5, -9)
	highlight.BackgroundColor3 = C.gold
	highlight.BorderSizePixel  = 0
	highlight.Visible          = false
	Instance.new("UICorner", highlight).CornerRadius = UDim.new(1, 0)

	local icon = Instance.new("TextLabel", btn)
	icon.Name                   = "BtnIcon"
	icon.Size                   = UDim2.new(0, 24, 1, 0)
	icon.Position               = UDim2.new(0, 10, 0, 0)
	icon.BackgroundTransparency = 1
	icon.Text                   = tabData.icon
	icon.TextSize               = 14
	icon.Font                   = Enum.Font.Gotham
	icon.TextColor3             = C.muted
	icon.TextXAlignment         = Enum.TextXAlignment.Center

	local lbl = Instance.new("TextLabel", btn)
	lbl.Name                   = "BtnLabel"
	lbl.Size                   = UDim2.new(1, -40, 1, 0)
	lbl.Position               = UDim2.new(0, 38, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text                   = tabData.label
	lbl.TextColor3             = C.muted
	lbl.Font                   = Enum.Font.Gotham
	lbl.TextSize               = 13
	lbl.TextXAlignment         = Enum.TextXAlignment.Left

	btn.MouseEnter:Connect(function()
		if State.currentTab ~= tabData.id then
			TweenService:Create(btn, TweenInfo.new(0.1), { BackgroundTransparency = 0.6 }):Play()
			TweenService:Create(lbl, TweenInfo.new(0.1), { TextColor3 = C.white }):Play()
		end
	end)
	btn.MouseLeave:Connect(function()
		if State.currentTab ~= tabData.id then
			TweenService:Create(btn, TweenInfo.new(0.1), { BackgroundTransparency = 1 }):Play()
			TweenService:Create(lbl, TweenInfo.new(0.1), { TextColor3 = C.muted }):Play()
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
	local page = Instance.new("ScrollingFrame")
	page.Name                = id
	page.Size                = UDim2.new(1, 0, 1, -41)
	page.Position            = UDim2.new(0, 0, 0, 41)
	page.BackgroundTransparency = 1
	page.BorderSizePixel     = 0
	page.ScrollBarThickness  = 3
	page.ScrollBarImageColor3 = C.goldDark
	page.CanvasSize          = UDim2.new(0, 0, 0, 0)
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.Visible             = false
	page.Parent              = contentArea

	local layout = Instance.new("UIListLayout", page)
	layout.Padding = UDim.new(0, 8)
	layout.FillDirection = Enum.FillDirection.Vertical
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	local pad = Instance.new("UIPadding", page)
	pad.PaddingTop = UDim.new(0, 14)
	pad.PaddingBottom = UDim.new(0, 14)
	pad.PaddingLeft = UDim.new(0, 14)
	pad.PaddingRight = UDim.new(0, 14)

	tabPages[id] = page
	return page
end

local function makeSectionLabel(parent, text)
	local lbl = Instance.new("TextLabel")
	lbl.Size                   = UDim2.new(1, 0, 0, 22)
	lbl.BackgroundTransparency = 1
	lbl.Text                   = text
	lbl.TextColor3             = C.muted
	lbl.Font                   = Enum.Font.GothamBold
	lbl.TextSize               = 10
	lbl.TextXAlignment         = Enum.TextXAlignment.Left
	lbl.Parent                 = parent
	return lbl
end

local function makeListBtn(parent, label, sublabel, onClick)
	local btn = Instance.new("TextButton")
	btn.Size             = UDim2.new(1, 0, 0, sublabel and 52 or 40)
	btn.BackgroundColor3 = C.card
	btn.BorderSizePixel  = 0
	btn.Text             = ""
	btn.Parent           = parent
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

	local nameL = Instance.new("TextLabel", btn)
	nameL.Size                   = UDim2.new(1, -40, 0, 20)
	nameL.Position               = UDim2.new(0, 14, 0, sublabel and 8 or 10)
	nameL.BackgroundTransparency = 1
	nameL.Text                   = label
	nameL.TextColor3             = C.white
	nameL.Font                   = Enum.Font.Gotham
	nameL.TextSize               = 13
	nameL.TextXAlignment         = Enum.TextXAlignment.Left

	if sublabel then
		local subL = Instance.new("TextLabel", btn)
		subL.Size                   = UDim2.new(1, -40, 0, 16)
		subL.Position               = UDim2.new(0, 14, 0, 28)
		subL.BackgroundTransparency = 1
		subL.Text                   = sublabel
		subL.TextColor3             = C.muted
		subL.Font                   = Enum.Font.Gotham
		subL.TextSize               = 11
		subL.TextXAlignment         = Enum.TextXAlignment.Left
	end

	local arrow = Instance.new("TextLabel", btn)
	arrow.Size                   = UDim2.new(0, 20, 1, 0)
	arrow.Position               = UDim2.new(1, -24, 0, 0)
	arrow.BackgroundTransparency = 1
	arrow.Text                   = "›"
	arrow.TextColor3             = C.dim
	arrow.Font                   = Enum.Font.GothamBold
	arrow.TextSize               = 20

	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.1), { BackgroundColor3 = C.cardHover }):Play()
		TweenService:Create(arrow, TweenInfo.new(0.1), { TextColor3 = C.gold }):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.1), { BackgroundColor3 = C.card }):Play()
		TweenService:Create(arrow, TweenInfo.new(0.1), { TextColor3 = C.dim }):Play()
	end)
	btn.MouseButton1Click:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.07), { BackgroundColor3 = C.goldDim }):Play()
		task.delay(0.15, function()
			TweenService:Create(btn, TweenInfo.new(0.1), { BackgroundColor3 = C.card }):Play()
		end)
		if onClick then onClick() end
	end)
	return btn
end

local function makeToggleBtn(parent, label, onToggle)
	local btn = Instance.new("Frame")
	btn.Size             = UDim2.new(1, 0, 0, 40)
	btn.BackgroundColor3 = C.card
	btn.BorderSizePixel  = 0
	btn.Parent           = parent
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

	local lbl = Instance.new("TextLabel", btn)
	lbl.Size                   = UDim2.new(1, -60, 1, 0)
	lbl.Position               = UDim2.new(0, 14, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text                   = label
	lbl.TextColor3             = C.white
	lbl.Font                   = Enum.Font.Gotham
	lbl.TextSize               = 13
	lbl.TextXAlignment         = Enum.TextXAlignment.Left

	local togBg = Instance.new("Frame", btn)
	togBg.Size = UDim2.new(0, 40, 0, 20)
	togBg.Position = UDim2.new(1, -50, 0.5, -10)
	togBg.BackgroundColor3 = C.dim
	togBg.BorderSizePixel = 0
	Instance.new("UICorner", togBg).CornerRadius = UDim.new(1, 0)

	local knob = Instance.new("Frame", togBg)
	knob.Size = UDim2.new(0, 14, 0, 14)
	knob.Position = UDim2.new(0, 3, 0.5, -7)
	knob.BackgroundColor3 = C.white
	knob.BorderSizePixel = 0
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

	local isOn = false
	local hitbox = Instance.new("TextButton", btn)
	hitbox.Size = UDim2.new(1, 0, 1, 0)
	hitbox.BackgroundTransparency = 1
	hitbox.Text = ""

	-- Exposed so Q key can sync the toggle visually
	local function setToggle(value)
		isOn = value
		local tw = TweenInfo.new(0.15, Enum.EasingStyle.Quad)
		if isOn then
			TweenService:Create(togBg, tw, { BackgroundColor3 = C.gold }):Play()
			TweenService:Create(knob, tw, { Position = UDim2.new(0, 23, 0.5, -7) }):Play()
		else
			TweenService:Create(togBg, tw, { BackgroundColor3 = C.dim }):Play()
			TweenService:Create(knob, tw, { Position = UDim2.new(0, 3, 0.5, -7) }):Play()
		end
		onToggle(isOn)
	end

	hitbox.MouseButton1Click:Connect(function()
		setToggle(not isOn)
	end)

	-- Return setToggle so fly toggle UI can be synced from Q key
	return btn, setToggle
end

local function makeSlider(parent, label, min, max, default, onChange)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 54)
	frame.BackgroundColor3 = C.card
	frame.BorderSizePixel = 0
	frame.Parent = parent
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

	local pad = Instance.new("UIPadding", frame)
	pad.PaddingLeft = UDim.new(0, 14); pad.PaddingRight = UDim.new(0, 14)
	pad.PaddingTop = UDim.new(0, 8)

	local nameL = Instance.new("TextLabel", frame)
	nameL.Size = UDim2.new(0.7, 0, 0, 18)
	nameL.BackgroundTransparency = 1
	nameL.Text = label
	nameL.TextColor3 = C.white
	nameL.Font = Enum.Font.Gotham
	nameL.TextSize = 13
	nameL.TextXAlignment = Enum.TextXAlignment.Left

	local valL = Instance.new("TextLabel", frame)
	valL.Size = UDim2.new(0.3, 0, 0, 18)
	valL.Position = UDim2.new(0.7, 0, 0, 0)
	valL.BackgroundTransparency = 1
	valL.Text = tostring(default)
	valL.TextColor3 = C.gold
	valL.Font = Enum.Font.GothamBold
	valL.TextSize = 13
	valL.TextXAlignment = Enum.TextXAlignment.Right

	local track = Instance.new("Frame", frame)
	track.Size = UDim2.new(1, 0, 0, 3)
	track.Position = UDim2.new(0, 0, 0, 32)
	track.BackgroundColor3 = C.divider
	track.BorderSizePixel = 0
	Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

	local fill = Instance.new("Frame", track)
	fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
	fill.BackgroundColor3 = C.gold
	fill.BorderSizePixel = 0
	Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

	local knob = Instance.new("TextButton", track)
	knob.Size = UDim2.new(0, 14, 0, 14)
	knob.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
	knob.BackgroundColor3 = C.gold
	knob.Text = ""; knob.BorderSizePixel = 0
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

	local dragging = false
	knob.MouseButton1Down:Connect(function() dragging = true end)
	UserInputService.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end)
	UserInputService.InputChanged:Connect(function(inp)
		if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
			local tp = track.AbsolutePosition.X
			local tw = track.AbsoluteSize.X
			local ratio = math.clamp((inp.Position.X - tp) / tw, 0, 1)
			local val = math.floor(min + ratio * (max - min))
			fill.Size = UDim2.new(ratio, 0, 1, 0)
			knob.Position = UDim2.new(ratio, -7, 0.5, -7)
			valL.Text = tostring(val)
			onChange(val)
		end
	end)
	return frame
end

-- ── Toast notification ────────────────────────────────────────
local toast = Instance.new("TextLabel")
toast.Size = UDim2.new(0, 260, 0, 28)
toast.Position = UDim2.new(0.5, -130, 1, -38)
toast.BackgroundColor3 = C.card
toast.TextColor3 = C.gold
toast.Font = Enum.Font.Gotham
toast.TextSize = 11
toast.Text = ""
toast.BorderSizePixel = 0
toast.BackgroundTransparency = 1
toast.TextXAlignment = Enum.TextXAlignment.Center
toast.ZIndex = 10
toast.Parent = win
Instance.new("UICorner", toast).CornerRadius = UDim.new(0, 6)
local toastStroke = Instance.new("UIStroke", toast)
toastStroke.Color = C.goldDark; toastStroke.Thickness = 1

local toastTween
local function notify(msg)
	toast.Text = msg
	toast.BackgroundTransparency = 0
	toast.TextTransparency = 0
	toastStroke.Transparency = 0
	if toastTween then toastTween:Cancel() end
	toastTween = TweenService:Create(toast,
		TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 2),
		{ BackgroundTransparency = 1, TextTransparency = 1 })
	toastTween:Play()
	toastTween.Completed:Connect(function()
		toast.Text = ""
		toast.TextTransparency = 0
	end)
end

-- ============================================================
--  FLY / GOD / NOCLIP
-- ============================================================

local function enableFly()
	local char = LocalPlayer.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hrp or not hum then return end
	hum.AutoRotate = false  -- prevents snapping to walk direction, no freeze
	State.bodyVelocity = Instance.new("BodyVelocity")
	State.bodyVelocity.Velocity = Vector3.zero
	State.bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
	State.bodyVelocity.Parent = hrp
	State.bodyGyro = Instance.new("BodyGyro")
	State.bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
	State.bodyGyro.D = 100
	State.bodyGyro.CFrame = hrp.CFrame
	State.bodyGyro.Parent = hrp
	State.flyConn = RunService.Heartbeat:Connect(function()
		if not State.flyEnabled then return end
		local cam = workspace.CurrentCamera
		local dir = Vector3.zero
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space)     then dir += Vector3.yAxis end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.yAxis end
		if dir.Magnitude > 0 then dir = dir.Unit end
		State.bodyVelocity.Velocity = dir * State.flySpeed
		State.bodyGyro.CFrame = cam.CFrame
	end)
	notify("✈️  Fly ON  [Q to toggle]")
end

local function disableFly()
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then hum.AutoRotate = true end  -- restore normal rotation
	if State.flyConn      then State.flyConn:Disconnect();   State.flyConn      = nil end
	if State.bodyVelocity then State.bodyVelocity:Destroy(); State.bodyVelocity = nil end
	if State.bodyGyro     then State.bodyGyro:Destroy();     State.bodyGyro     = nil end
	notify("✈️  Fly OFF")
end

local godConn
local function enableGod()
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	hum.MaxHealth = math.huge; hum.Health = math.huge
	godConn = hum.HealthChanged:Connect(function()
		if State.godEnabled then hum.Health = math.huge end
	end)
	notify("🛡️  God Mode ON")
end

local function disableGod()
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then hum.MaxHealth = 100; hum.Health = 100 end
	if godConn then godConn:Disconnect(); godConn = nil end
	notify("🛡️  God Mode OFF")
end

local function enableNoclip()
	State.noclipConn = RunService.Stepped:Connect(function()
		local char = LocalPlayer.Character
		if not char then return end
		for _, p in ipairs(char:GetDescendants()) do
			if p:IsA("BasePart") then p.CanCollide = false end
		end
	end)
	notify("👻  NoClip ON")
end

local function disableNoclip()
	if State.noclipConn then State.noclipConn:Disconnect(); State.noclipConn = nil end
	local char = LocalPlayer.Character
	if char then
		for _, p in ipairs(char:GetDescendants()) do
			if p:IsA("BasePart") then p.CanCollide = true end
		end
	end
	notify("👻  NoClip OFF")
end

-- ============================================================
--  BUILD PAGES
-- ============================================================

--- HOME ---
do
	local p = makePage("home")
	makeSectionLabel(p, "SERVER OPTIONS")
	makeListBtn(p, "Rejoin Server", "Teleport back to this place", function()
		game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
		notify("🔄 Rejoining...")
	end)
	makeListBtn(p, "Copy Place ID", "Copy this game's Place ID", function()
		notify("📋 Place ID: " .. game.PlaceId)
	end)
	makeListBtn(p, "List Players", "Show all players in server", function()
		local list = ""
		for _, pl in ipairs(Players:GetPlayers()) do list = list .. pl.Name .. "  " end
		notify("👥 " .. list)
	end)

	makeSectionLabel(p, "CREDITS")
	local credCard = Instance.new("Frame", p)
	credCard.Size = UDim2.new(1, 0, 0, 90)
	credCard.BackgroundColor3 = C.card
	credCard.BorderSizePixel = 0
	Instance.new("UICorner", credCard).CornerRadius = UDim.new(0, 8)
	local credLayout = Instance.new("UIListLayout", credCard)
	credLayout.Padding = UDim.new(0, 0)
	credLayout.FillDirection = Enum.FillDirection.Vertical
	local credPad = Instance.new("UIPadding", credCard)
	credPad.PaddingTop = UDim.new(0, 10); credPad.PaddingLeft = UDim.new(0, 14)
	local function credLine(txt)
		local l = Instance.new("TextLabel", credCard)
		l.Size = UDim2.new(1, -14, 0, 20)
		l.BackgroundTransparency = 1
		l.Text = txt; l.TextColor3 = C.muted
		l.Font = Enum.Font.Gotham; l.TextSize = 11
		l.TextXAlignment = Enum.TextXAlignment.Left
	end
	credLine("Made by:  GHXST")
	credLine("Version:  2.0")
	credLine("Key:  GHXST_ADMIN")
end

--- PLAYER ---
-- We hold a reference to the fly setToggle so Q key can sync the UI
local flySetToggle = nil

do
	local p = makePage("player")

	makeSectionLabel(p, "MOVEMENT")

	-- Fly toggle — capture setToggle for Q key sync
	local _, flySync = makeToggleBtn(p, "✈️  Fly Mode  [Q]", function(on)
		State.flyEnabled = on
		if on then enableFly() else disableFly() end
	end)
	flySetToggle = flySync

	makeToggleBtn(p, "👻  NoClip", function(on)
		State.noclipEnabled = on
		if on then enableNoclip() else disableNoclip() end
	end)
	makeToggleBtn(p, "🛡️  God Mode", function(on)
		State.godEnabled = on
		if on then enableGod() else disableGod() end
	end)

	makeSectionLabel(p, "SPEED")
	makeSlider(p, "Walk Speed", 4, 100, 16, function(val)
		State.walkSpeed = val
		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = val end
		notify("Walk speed → " .. val)
	end)
	makeSlider(p, "Fly Speed", 10, 300, 50, function(val)
		State.flySpeed = val
		notify("Fly speed → " .. val)
	end)

	makeSectionLabel(p, "TELEPORT")
	for _, loc in ipairs(TELEPORT_LOCATIONS) do
		makeListBtn(p, "📍  " .. loc.name, "Teleport to " .. loc.name, function()
			local char = LocalPlayer.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			if hrp then hrp.CFrame = CFrame.new(loc.pos); notify("📍 → " .. loc.name) end
		end)
	end
end

--- WORLD ---
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
		Lighting.FogEnd = Lighting.FogEnd < 500 and 100000 or 100
		notify("🌫️ Fog " .. (Lighting.FogEnd < 500 and "ON" or "OFF"))
	end)
	makeListBtn(p, "✨  Bright", nil, function() Lighting.Brightness = 5; notify("✨ Bright") end)
	makeListBtn(p, "🌧️  Dark", nil, function() Lighting.Brightness = 0.1; notify("🌧️ Dark") end)
	makeListBtn(p, "🎨  Reset Lighting", nil, function()
		Lighting.ClockTime = 14; Lighting.Brightness = 2; Lighting.FogEnd = 100000
		notify("🎨 Lighting reset")
	end)
end

--- DUPE ---
do
	local p = makePage("dupe")

	makeSectionLabel(p, "WOOD")
	makeListBtn(p, "🪵  Dupe Nearby Wood", "Duplicates wood within 20 studs", function()
		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hrp then notify("❌ No character"); return end
		local duped = 0
		for _, obj in ipairs(workspace:GetDescendants()) do
			local n = obj.Name:lower()
			if obj:IsA("BasePart") and (n:find("log") or n:find("wood") or n:find("lumber")) then
				if (obj.Position - hrp.Position).Magnitude < 20 then
					local clone = obj:Clone()
					clone.Parent = workspace
					clone.CFrame = obj.CFrame * CFrame.new(2, 0, 0)
					duped += 1
				end
			end
		end
		notify("📋 Duped " .. duped .. " piece(s)")
	end)
	makeListBtn(p, "📥  Pull Wood To Me", "Teleports nearby wood to you", function()
		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hrp then notify("❌ No character"); return end
		local count = 0
		for _, obj in ipairs(workspace:GetDescendants()) do
			local n = obj.Name:lower()
			if obj:IsA("BasePart") and (n:find("log") or n:find("wood") or n:find("lumber")) then
				obj.CFrame = hrp.CFrame + Vector3.new(math.random(-6,6), 2, math.random(-6,6))
				count += 1
			end
		end
		notify("🪵 Pulled " .. count .. " piece(s)")
	end)
	makeListBtn(p, "🗑️  Clear Duped Wood", "Removes cloned objects", function()
		local removed = 0
		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj:IsA("BasePart") and obj.Name:lower():find("clone") then
				obj:Destroy(); removed += 1
			end
		end
		notify("🗑️ Cleared " .. removed .. " dupe(s)")
	end)

	makeSectionLabel(p, "ITEMS")
	makeListBtn(p, "🔁  Dupe Nearest Item", "Clones the closest BasePart", function()
		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hrp then notify("❌ No character"); return end
		local closest, dist = nil, 30
		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj:IsA("BasePart") and obj ~= hrp then
				local d = (obj.Position - hrp.Position).Magnitude
				if d < dist then closest = obj; dist = d end
			end
		end
		if closest then
			local clone = closest:Clone()
			clone.Parent = workspace
			clone.CFrame = closest.CFrame * CFrame.new(3, 0, 0)
			notify("🔁 Duped: " .. closest.Name)
		else
			notify("❌ Nothing in range")
		end
	end)
end

--- MOD ---
do
	local p = makePage("mod")

	makeSectionLabel(p, "PLAYER SEARCH")
	local searchCard = Instance.new("Frame", p)
	searchCard.Size = UDim2.new(1, 0, 0, 44)
	searchCard.BackgroundColor3 = C.card
	searchCard.BorderSizePixel = 0
	Instance.new("UICorner", searchCard).CornerRadius = UDim.new(0, 8)
	local sPad = Instance.new("UIPadding", searchCard)
	sPad.PaddingLeft = UDim.new(0, 10); sPad.PaddingRight = UDim.new(0, 10)
	sPad.PaddingTop = UDim.new(0, 8)

	local inputBox = Instance.new("TextBox", searchCard)
	inputBox.Size = UDim2.new(1, 0, 0, 28)
	inputBox.BackgroundColor3 = C.bg
	inputBox.TextColor3 = C.white
	inputBox.PlaceholderText = "Enter player name..."
	inputBox.PlaceholderColor3 = C.dim
	inputBox.Font = Enum.Font.Gotham
	inputBox.TextSize = 12
	inputBox.BorderSizePixel = 0
	inputBox.Text = ""; inputBox.ClearTextOnFocus = false
	Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 6)
	local iBorder = Instance.new("UIStroke", inputBox)
	iBorder.Color = C.divider; iBorder.Thickness = 1
	local iPad = Instance.new("UIPadding", inputBox)
	iPad.PaddingLeft = UDim.new(0, 8)

	makeSectionLabel(p, "ACTIONS")
	makeListBtn(p, "🥾  Kick Player", nil, function()
		local name = inputBox.Text
		if name == "" then notify("⚠️ Enter a name"); return end
		local re = game:GetService("ReplicatedStorage"):FindFirstChild("AdminKick")
		if re then re:FireServer(name); notify("🥾 Kicked: " .. name)
		else notify("❌ AdminKick event missing") end
	end)
	makeListBtn(p, "🚫  Ban Player", nil, function()
		local name = inputBox.Text
		if name == "" then notify("⚠️ Enter a name"); return end
		local re = game:GetService("ReplicatedStorage"):FindFirstChild("AdminBan")
		if re then re:FireServer(name); notify("🚫 Banned: " .. name)
		else notify("❌ AdminBan event missing") end
	end)
	makeListBtn(p, "📍  Teleport To Player", nil, function()
		local name = inputBox.Text
		if name == "" then notify("⚠️ Enter a name"); return end
		local target = Players:FindFirstChild(name)
		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and hrp then
			hrp.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(3, 0, 0)
			notify("📍 TP → " .. name)
		else notify("❌ Not found: " .. name) end
	end)
	makeListBtn(p, "📲  Pull Player To Me", nil, function()
		local name = inputBox.Text
		if name == "" then notify("⚠️ Enter a name"); return end
		local re = game:GetService("ReplicatedStorage"):FindFirstChild("AdminTeleportHere")
		if re then re:FireServer(name); notify("📲 Pulling: " .. name)
		else notify("❌ AdminTeleportHere missing") end
	end)
	makeListBtn(p, "👑  Promote Player", nil, function()
		local name = inputBox.Text
		if name ~= "" then notify("👑 Promote needs server script")
		else notify("⚠️ Enter a name") end
	end)
end

--- SETTINGS ---
do
	local p = makePage("settings")
	makeSectionLabel(p, "MENU")
	makeListBtn(p, "🔑  Change Toggle Key", "Currently: F9", function()
		notify("🔑 Edit TOGGLE_KEY in script")
	end)
	makeListBtn(p, "✈️  Change Fly Key", "Currently: Q", function()
		notify("✈️ Edit FLY_KEY in script")
	end)
	makeListBtn(p, "🆔  Show User ID", "Display your Roblox User ID", function()
		notify("🆔 ID: " .. LocalPlayer.UserId)
	end)
	makeListBtn(p, "📋  Copy Username", nil, function()
		notify("👤 " .. LocalPlayer.Name)
	end)
	makeSectionLabel(p, "ABOUT")
	local aboutCard = Instance.new("Frame", p)
	aboutCard.Size = UDim2.new(1, 0, 0, 70)
	aboutCard.BackgroundColor3 = C.card
	aboutCard.BorderSizePixel = 0
	Instance.new("UICorner", aboutCard).CornerRadius = UDim.new(0, 8)
	local aPad = Instance.new("UIPadding", aboutCard)
	aPad.PaddingLeft = UDim.new(0, 14); aPad.PaddingTop = UDim.new(0, 10)
	local aLayout = Instance.new("UIListLayout", aboutCard)
	aLayout.Padding = UDim.new(0, 2)
	local function aLine(txt)
		local l = Instance.new("TextLabel", aboutCard)
		l.Size = UDim2.new(1, -14, 0, 18)
		l.BackgroundTransparency = 1; l.Text = txt
		l.TextColor3 = C.muted; l.Font = Enum.Font.Gotham
		l.TextSize = 11; l.TextXAlignment = Enum.TextXAlignment.Left
	end
	aLine("GHXST Menu  v2.0")
	aLine("Black & Gold Admin Panel")
	aLine("Toggle: F9  |  Fly: Q")
end

-- ============================================================
--  OPEN / CLOSE
-- ============================================================

local function openMenu()
	win.Visible = true
	win.Size = UDim2.new(0, 620, 0, 0)
	win.BackgroundTransparency = 1
	TweenService:Create(win, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 620, 0, 420),
		BackgroundTransparency = 0,
	}):Play()
	State.menuOpen = true
	switchTab(State.currentTab)
end

local function closeMenu()
	TweenService:Create(win, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Size = UDim2.new(0, 620, 0, 0),
		BackgroundTransparency = 1,
	}):Play()
	task.delay(0.18, function() win.Visible = false end)
	State.menuOpen = false
end

toggleBtn.MouseButton1Click:Connect(function()
	if State.menuOpen then closeMenu() else openMenu() end
end)
closeBtn.MouseButton1Click:Connect(closeMenu)
minBtn.MouseButton1Click:Connect(closeMenu)

-- ── Keyboard input (F9 menu toggle + Q fly toggle) ────────────
UserInputService.InputBegan:Connect(function(inp, proc)
	if proc then return end
	if inp.KeyCode == TOGGLE_KEY then
		if State.menuOpen then closeMenu() else openMenu() end
	end
	if inp.KeyCode == FLY_KEY then
		State.flyEnabled = not State.flyEnabled
		if State.flyEnabled then enableFly() else disableFly() end
		-- Sync the toggle UI in the Player tab
		if flySetToggle then flySetToggle(State.flyEnabled) end
	end
end)

-- ── Draggable via logo bar ────────────────────────────────────
local dragging, dragStart, winStart
logoBar.InputBegan:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true; dragStart = inp.Position; winStart = win.Position
	end
end)
titleStrip.InputBegan:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true; dragStart = inp.Position; winStart = win.Position
	end
end)
UserInputService.InputEnded:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
UserInputService.InputChanged:Connect(function(inp)
	if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
		local d = inp.Position - dragStart
		win.Position = UDim2.new(winStart.X.Scale, winStart.X.Offset + d.X,
			winStart.Y.Scale, winStart.Y.Offset + d.Y)
	end
end)

-- ── Respawn persistence ───────────────────────────────────────
LocalPlayer.CharacterAdded:Connect(function(char)
	char:WaitForChild("Humanoid"); task.wait(0.5)
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum and State.walkSpeed ~= 16 then hum.WalkSpeed = State.walkSpeed end
	if State.flyEnabled then task.wait(0.2); enableFly() end
	if State.godEnabled then task.wait(0.2); enableGod() end
end)

-- Init
switchTab("home")
print("[GhxstMenu v2] ✓ Loaded — " .. LocalPlayer.Name .. " (ID: " .. LocalPlayer.UserId .. ")")
print("[GhxstMenu v2] ✈️  Press Q to toggle fly at any time")
