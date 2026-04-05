if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- =========================
-- ESTADOS
-- =========================
local STATE = {
	FullBright = false,
	RemoveLights = false,
	NoFog = false,
	Exposure = false,
	CleanVisual = false,
	FastLoad = false
}

-- =========================
-- FUNÇÕES
-- =========================
local function applyFullBright()
	Lighting.GlobalShadows = false
	Lighting.Brightness = 0
	Lighting.Ambient = Color3.fromRGB(255,255,255)
	Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
end

local function removeFog()
	Lighting.FogStart = 1e9
	Lighting.FogEnd = 1e9
end

local function removeLights(obj)
	if obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
		obj:Destroy()
	end
end

local function cleanVisual(obj)
	if obj:IsA("BasePart") then
		obj.CastShadow = false
		obj.Reflectance = 0
	end
end

local function fastLoad()
	pcall(function()
		settings().Rendering.QualityLevel = Enum.QualityLevel.Level21
	end)
end

-- =========================
-- EXPOSURE DINÂMICO
-- =========================
local function updateExposure()
	if not STATE.Exposure then return end
	
	local t = Lighting.ClockTime
	
	if t >= 6 and t <= 18 then
		Lighting.ExposureCompensation = 0.10
	else
		Lighting.ExposureCompensation = 0.25
	end
end

RunService.RenderStepped:Connect(updateExposure)

-- =========================
-- LOOP DE ATUALIZAÇÃO
-- =========================
RunService.Heartbeat:Connect(function()
	if STATE.FullBright then
		applyFullBright()
	end
	
	if STATE.NoFog then
		removeFog()
	end
	
	if STATE.FastLoad then
		fastLoad()
	end
end)

Workspace.DescendantAdded:Connect(function(obj)
	if STATE.RemoveLights then removeLights(obj) end
	if STATE.CleanVisual then cleanVisual(obj) end
end)

-- =========================
-- GUI HUB
-- =========================
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "FullBrightHub"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 260, 0, 320)
frame.Position = UDim2.new(0.5, -130, 0.5, -160)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.Active = true
frame.Draggable = true

local function createButton(text, y, callback)
	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(1, -20, 0, 30)
	btn.Position = UDim2.new(0, 10, 0, y)
	btn.Text = text
	btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
	btn.TextColor3 = Color3.new(1,1,1)
	
	btn.MouseButton1Click:Connect(callback)
	return btn
end

-- =========================
-- BOTÕES PRINCIPAIS
-- =========================
createButton("OLD MODE", 20, function()
	STATE.FullBright = true
	STATE.RemoveLights = false
	STATE.NoFog = false
	STATE.Exposure = false
	STATE.CleanVisual = false
	STATE.FastLoad = false
end)

createButton("NEW MODE", 60, function()
	STATE.FullBright = true
	STATE.RemoveLights = true
	STATE.NoFog = true
	STATE.Exposure = true
	STATE.CleanVisual = true
	STATE.FastLoad = true
end)

-- =========================
-- CUSTOM MODE
-- =========================
local y = 120

local function toggle(name)
	STATE[name] = not STATE[name]
end

createButton("Toggle FullBright", y, function() toggle("FullBright") end)
y = y + 35

createButton("Toggle Remove Lights", y, function() toggle("RemoveLights") end)
y = y + 35

createButton("Toggle No Fog", y, function() toggle("NoFog") end)
y = y + 35

createButton("Toggle Exposure", y, function() toggle("Exposure") end)
y = y + 35

createButton("Toggle Clean Visual", y, function() toggle("CleanVisual") end)
y = y + 35

createButton("Toggle Fast Load", y, function() toggle("FastLoad") end)

-- =========================
-- MINIMIZAR
-- =========================
local mini = false

createButton("Minimizar", 280, function()
	mini = not mini
	for _,v in ipairs(frame:GetChildren()) do
		if v:IsA("TextButton") and v.Text ~= "Minimizar" then
			v.Visible = not mini
		end
	end
end)

print("FullBright HUB carregado!")
