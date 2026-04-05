if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer

-- =========================
-- SAVE SYSTEM (JSON)
-- =========================
local FILE = "fullbright_configs.json"

local function loadConfigs()
	if isfile and isfile(FILE) then
		return HttpService:JSONDecode(readfile(FILE))
	end
	return {}
end

local function saveConfigs(tbl)
	if writefile then
		writefile(FILE, HttpService:JSONEncode(tbl))
	end
end

local configs = loadConfigs()

-- =========================
-- FUNÇÕES BASE
-- =========================
local function removeFog()
	Lighting.FogStart = 0
	Lighting.FogEnd = 999999
end

local function removeLights(obj)
	if obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
		obj:Destroy()
	end
end

local function applyFullBrightBasic()
	Lighting.Brightness = 0
	Lighting.GlobalShadows = false
	Lighting.Ambient = Color3.new(1,1,1)
	Lighting.OutdoorAmbient = Color3.new(1,1,1)
end

local function applyExposure(dayExp, nightExp)
	RunService.RenderStepped:Connect(function()
		local t = Lighting.ClockTime
		if t >= 6 and t <= 18 then
			Lighting.ExposureCompensation = dayExp
		else
			Lighting.ExposureCompensation = nightExp
		end
	end)
end

local function cleanMap()
	for _,v in ipairs(workspace:GetDescendants()) do
		removeLights(v)
		if v:IsA("BasePart") then
			v.CastShadow = false
		end
	end
	
	workspace.DescendantAdded:Connect(removeLights)
end

-- =========================
-- MODES
-- =========================
local function modeOld()
	removeFog()
	applyFullBrightBasic()
	cleanMap()
end

local function modeNew()
	removeFog()
	applyFullBrightBasic()
	cleanMap()
	
	applyExposure(0.10, 0.25)
	
	Lighting.Technology = Enum.Technology.Compatibility
	Lighting.ShadowSoftness = 0
end

-- =========================
-- GUI
-- =========================
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "FullBrightHub"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,300,0,300)
frame.Position = UDim2.new(0.5,-150,0.5,-150)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)

local function createButton(text, y, callback)
	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(1,-20,0,40)
	btn.Position = UDim2.new(0,10,0,y)
	btn.Text = text
	btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
	btn.TextColor3 = Color3.new(1,1,1)
	
	btn.MouseButton1Click:Connect(callback)
end

-- =========================
-- BOTÕES PRINCIPAIS
-- =========================
createButton("OLD (FullBright simples)", 20, function()
	modeOld()
end)

createButton("NEW (Full completo)", 70, function()
	modeNew()
end)

-- =========================
-- CUSTOM CREATOR
-- =========================
createButton("CUSTOM CREATOR", 120, function()
	frame:ClearAllChildren()
	
	local toggles = {
		Fog = true,
		Lights = true,
		Shadows = true
	}
	
	local y = 10
	
	for name,_ in pairs(toggles) do
		local btn = Instance.new("TextButton", frame)
		btn.Size = UDim2.new(1,-20,0,30)
		btn.Position = UDim2.new(0,10,0,y)
		btn.Text = name..": ON"
		btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
		
		btn.MouseButton1Click:Connect(function()
			toggles[name] = not toggles[name]
			btn.Text = name..": "..(toggles[name] and "ON" or "OFF")
		end)
		
		y = y + 35
	end
	
	-- SALVAR
	local saveBtn = Instance.new("TextButton", frame)
	saveBtn.Size = UDim2.new(1,-20,0,40)
	saveBtn.Position = UDim2.new(0,10,0,y)
	saveBtn.Text = "SALVAR CONFIG"
	
	saveBtn.MouseButton1Click:Connect(function()
		local name = "Config_"..os.time()
		
		configs[name] = {
			toggles = toggles,
			time = os.date("%H:%M:%S")
		}
		
		saveConfigs(configs)
	end)
	
	y = y + 50
	
	-- LOAD SAVES
	for name,data in pairs(configs) do
		local btn = Instance.new("TextButton", frame)
		btn.Size = UDim2.new(1,-20,0,30)
		btn.Position = UDim2.new(0,10,0,y)
		btn.Text = name.." ["..data.time.."]"
		
		btn.MouseButton1Click:Connect(function()
			if data.toggles.Fog then removeFog() end
			if data.toggles.Lights then cleanMap() end
			if data.toggles.Shadows then
				Lighting.GlobalShadows = false
			end
		end)
		
		y = y + 35
	end
end)

-- =========================
-- RENOMEAR CONFIG (extra)
-- =========================
createButton("RENOMEAR CONFIG", 170, function()
	for name,_ in pairs(configs) do
		local newName = name.."_edit"
		configs[newName] = configs[name]
		configs[name] = nil
	end
	saveConfigs(configs)
end)

print("FullBright Hub carregado!")
