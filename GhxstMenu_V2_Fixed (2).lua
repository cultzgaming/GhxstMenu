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
	4430510222, -- ← Replace with your actual Roblox User ID
}

local TOGGLE_KEY = Enum.KeyCode.F9

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
-- "Ghxst" on top line — white text with animated rainbow UIStroke outline
-- "Menu"  below      — bubble/bold white text, no outline
local GHXST_STR    = "Ghxst"
local LETTER_W     = 18   -- px per character slot for "Ghxst"
local TITLE_START_X = 8
local ghxstLetters = {}   -- main white labels
local ghxstStrokes = {}   -- UIStroke per letter (rainbow outline)

for i = 1, #GHXST_STR do
	local ch = GHXST_STR:sub(i, i)

	-- White letter (foreground)
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

	-- Rainbow UIStroke outline on each letter
	local stroke = Instance.new("UIStroke", lbl)
	stroke.Color     = Color3.fromRGB(255, 0, 0)
	stroke.Thickness = 2
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual

	ghxstLetters[i] = lbl
	ghxstStrokes[i] = stroke
end

-- "Menu" below in bubble writing (large bold, white, no outline)
local menuLabel = Instance.new("TextLabel")
menuLabel.Size                   = UDim2.new(1, -8, 0, 20)
menuLabel.Position               = UDim2.new(0, TITLE_START_X, 0, 34)
menuLabel.BackgroundTransparency = 1
menuLabel.Text                   = "Menu"
menuLabel.TextColor3             = Color3.fromRGB(230, 230, 230)
menuLabel.Font                   = Enum.Font.GothamBlack  -- bold bubble look
menuLabel.TextSize               = 14
menuLabel.TextXAlignment         = Enum.TextXAlignment.Left
menuLabel.ZIndex                 = 5
menuLabel.Parent                 = logoBar

-- Subtle drop-shadow copy behind "Menu" for bubble depth
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

-- Rainbow cycle — animates the UIStroke outline colour on each "Ghxst" letter
local rainbowTime = 0
RunService.Heartbeat:Connect(function(dt)
	rainbowTime = rainbowTime + dt * 0.7  -- outline rainbow speed
	for i, stroke in ipairs(ghxstStrokes) do
		local hue = (rainbowTime + (i - 1) * 0.15) % 1
		stroke.Color = Color3.fromHSV(hue, 1, 1)
	end
end)

-- ── Sidebar ───────────────────────────────────────────────────
local sidebar = Instance.new("Frame")
sidebar.Name             = "S
