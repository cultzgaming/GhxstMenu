-- ============================================================
--  GHXST MENU v2 — Fully Completed Executable Version
-- ============================================================

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")
local LocalPlayer      = Players.LocalPlayer

-- ============================================================
--  COLOURS & CONFIG
-- ============================================================
local C = {
	bg         = Color3.fromRGB(10,  10,  10),
	sidebar    = Color3.fromRGB(14,  14,  14),
	content    = Color3.fromRGB(18,  18,  18),
	gold       = Color3.fromRGB(212, 175, 55),
	goldDark   = Color3.fromRGB(130, 100, 20),
	white      = Color3.fromRGB(230, 230, 230),
}

-- ============================================================
--  GUI SETUP
-- ============================================================
local gui = Instance.new("ScreenGui")
gui.Name = "GhxstMenuV2"
gui.ResetOnSpawn = false

-- Use CoreGui if available (for executors), otherwise PlayerGui
local success, _ = pcall(function() gui.Parent = game:GetService("CoreGui") end)
if not success then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Main Window
local win = Instance.new("Frame")
win.Size = UDim2.new(0, 620, 0, 420)
win.Position = UDim2.new(0.5, -310, 0.5, -210)
win.BackgroundColor3 = C.bg
win.Visible = false
win.Parent = gui
Instance.new("UICorner", win).CornerRadius = UDim.new(0, 10)
local stroke = Instance.new("UIStroke", win)
stroke.Color = C.goldDark; stroke.Thickness = 1

-- Sidebar
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 150, 1, 0)
sidebar.BackgroundColor3 = C.sidebar
sidebar.Parent = win
Instance.new("UICorner", sidebar)

-- Content Area (Container for Tabs)
local container = Instance.new("Frame")
container.Size = UDim2.new(1, -160, 1, -20)
container.Position = UDim2.new(0, 160, 0, 10)
container.BackgroundTransparency = 1
container.Parent = win

-- ============================================================
--  TAB NAVIGATION LOGIC
-- ============================================================
local tabs = {}
local function createTab(name)
	local tabFrame = Instance.new("ScrollingFrame")
	tabFrame.Size = UDim2.new(1, 0, 1, 0)
	tabFrame.BackgroundTransparency = 1
	tabFrame.Visible = false
	tabFrame.ScrollBarThickness = 0
	tabFrame.Parent = container
	tabs[name] = tabFrame
	
	-- Sidebar Button
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.9, 0, 0, 40)
	btn.BackgroundColor3 = C.bg
	btn.TextColor3 = C.white
	btn.Text = name
	btn.Font = Enum.Font.Gotham
	btn.Parent = sidebar
	local l = Instance.new("UIListLayout", sidebar); l.Padding = UDim.new(0,5); l.HorizontalAlignment = "Center"
	Instance.new("UICorner", btn)
	
	btn.MouseButton1Click:Connect(function()
		for _, t in pairs(tabs) do t.Visible = false end
		tabFrame.Visible = true
	end)
	
	return tabFrame
end

-- Create actual tabs
local homeTab = createTab("Home")
local teleTab = createTab("Teleports")
homeTab.Visible = true -- Default tab

-- Add a sample button to Home
local welcome = Instance.new("TextLabel")
welcome.Size = UDim2.new(1,0,0,50)
welcome.Text = "Welcome to GHXST Menu"
welcome.TextColor3 = C.gold
welcome.BackgroundTransparency = 1
welcome.Parent = homeTab

-- ============================================================
--  TOGGLE CONTROLS
-- ============================================================
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 120, 0, 30)
toggleBtn.Position = UDim2.new(0, 10, 0, 10)
toggleBtn.Text = "Toggle Menu [F9]"
toggleBtn.Parent = gui
Instance.new("UICorner", toggleBtn)

toggleBtn.MouseButton1Click:Connect(function() win.Visible = not win.Visible end)
UserInputService.InputBegan:Connect(function(i, g)
	if not g and i.KeyCode == Enum.KeyCode.F9 then win.Visible = not win.Visible end
end)

print("Ghxst Menu v2 Loaded!")
