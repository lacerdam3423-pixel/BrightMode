--// FULL BRIGHT + NOFOG + ANTI LAG + CHAT COMMANDS + CUSTOM GUI
--// LocalScript | Funcional | Com Confirmação

local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

print("✅ Script carregado com sucesso!")

-- ==================== CONFIGURAÇÃO ====================
local CONFIG = {
	ExposureDay = 0.3,
	ExposureNight = 0.6,
	FPSCap = 200,
	RenderDistance = 1000,
	AntiLagInterval = 0.2,
}

local DEFAULT_LIGHTING = {}
local isSystemEnabled = true
local antiLagRunning = false
-- ==================== FIM CONFIG ====================

-- Salvar valores padrão
for _, prop in ipairs({
	"GlobalShadows", "Brightness", "Ambient", "OutdoorAmbient",
	"ColorShift_Top", "ColorShift_Bottom", "EnvironmentDiffuseScale",
	"EnvironmentSpecularScale", "Technology", "FogStart", "FogEnd",
	"ExposureCompensation"
}) do
	local success, val = pcall(function()
		return Lighting[prop]
	end)
	if success then
		DEFAULT_LIGHTING[prop] = val
	end
end

-- FPS Cap
pcall(function()
	if setfpscap then
		setfpscap(CONFIG.FPSCap)
		print("✅ FPS Cap definido para: " .. CONFIG.FPSCap)
	end
end)

local function setLightingBase()
	pcall(function() Lighting.GlobalShadows = false end)
	pcall(function() Lighting.Brightness = 0 end)
	pcall(function() Lighting.Ambient = Color3.fromRGB(200, 200, 200) end)
	pcall(function() Lighting.OutdoorAmbient = Color3.fromRGB(100, 100, 100) end)
	pcall(function() Lighting.ColorShift_Top = Color3.new(0, 0, 0) end)
	pcall(function() Lighting.ColorShift_Bottom = Color3.new(0, 0, 0) end)
	pcall(function() Lighting.EnvironmentDiffuseScale = 0 end)
	pcall(function() Lighting.EnvironmentSpecularScale = 0 end)
	pcall(function() Lighting.Technology = Enum.Technology.Unified end)
end

local function setExposure()
	local clock = Lighting.ClockTime
	if clock >= 6 and clock < 18 then
		pcall(function() Lighting.ExposureCompensation = CONFIG.ExposureDay end)
	else
		pcall(function() Lighting.ExposureCompensation = CONFIG.ExposureNight end)
	end
end

local function setNoFog()
	pcall(function() Lighting.FogStart = 0 end)
	pcall(function() Lighting.FogEnd = math.huge end)

	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
	if atmosphere then
		pcall(function() atmosphere.Density = 0 end)
		pcall(function() atmosphere.Offset = 0 end)
		pcall(function() atmosphere.Glare = 0 end)
		pcall(function() atmosphere.Haze = 0 end)
	end
end

local function removePostEffects()
	for _, obj in ipairs(Lighting:GetDescendants()) do
		if obj:IsA("BloomEffect")
			or obj:IsA("BlurEffect")
			or obj:IsA("SunRaysEffect")
			or obj:IsA("ColorCorrectionEffect")
			or obj:IsA("DepthOfFieldEffect") then
			pcall(function() obj:Destroy() end)
		end
	end
end

local function disableWorldLights()
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("PointLight")
			or obj:IsA("SpotLight")
			or obj:IsA("SurfaceLight") then
			pcall(function() obj.Enabled = false end)
		end
	end
end

local function removeReflections()
	pcall(function() Lighting.ReflectionIntensity = 0 end)
	pcall(function() Lighting.ShadowSoftness = 0 end)
end

local function boostStreaming()
	pcall(function()
		Workspace.StreamingEnabled = true
		Workspace.StreamingTargetRadius = CONFIG.RenderDistance
		Workspace.StreamingMinRadius = math.min(128, CONFIG.RenderDistance)
	end)
end

local function antiLag()
	setLightingBase()
	setExposure()
	setNoFog()
	removePostEffects()
	disableWorldLights()
	removeReflections()
	boostStreaming()
end

local function restoreDefaults()
	for property, value in pairs(DEFAULT_LIGHTING) do
		pcall(function() Lighting[property] = value end)
	end

	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
	if atmosphere then
		pcall(function() atmosphere.Density = 0.415 end)
		pcall(function() atmosphere.Offset = 0.225 end)
		pcall(function() atmosphere.Glare = 0 end)
		pcall(function() atmosphere.Haze = 0 end)
	end
end

local function sendSystemMessage(text)
	pcall(function()
		game.StarterGui:SetCore("ChatMakeSystemMessage", {
			Text = "[SYSTEM] " .. text,
			Color = Color3.fromRGB(0, 255, 128),
			Font = Enum.Font.SourceSansBold,
			TextSize = 18,
		})
	end)
	print("📢 " .. text)
end

local function enableSystem()
	isSystemEnabled = true
	antiLag()
	sendSystemMessage("✅ Sistema ATIVADO - Full Bright + No Fog + Anti Lag")

	if not antiLagRunning then
		antiLagRunning = true
		task.spawn(function()
			while antiLagRunning and isSystemEnabled do
				task.wait(CONFIG.AntiLagInterval)
				if isSystemEnabled then
					antiLag()
				end
			end
			antiLagRunning = false
		end)
	end
end

local function disableSystem()
	isSystemEnabled = false
	antiLagRunning = false
	restoreDefaults()
	sendSystemMessage("❌ Sistema DESATIVADO - Valores restaurados")
end

-- ==================== GUI DE CHAT ====================
local function createChatGui()
	local existingGui = PlayerGui:FindFirstChild("CustomChatGui")
	if existingGui then
		existingGui.Enabled = not existingGui.Enabled
		sendSystemMessage("💬 Chat GUI: " .. (existingGui.Enabled and "ABERTO" or "FECHADO"))
		return
	end

	sendSystemMessage("💬 Criando GUI de Chat Custom...")

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "CustomChatGui"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.Parent = PlayerGui

	local MainFrame = Instance.new("Frame")
	MainFrame.Name = "MainFrame"
	MainFrame.Size = UDim2.new(0, 400, 0, 500)
	MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
	MainFrame.BackgroundColor3 = Color3.fromRGB(128, 128, 128)
	MainFrame.Parent = ScreenGui

	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(0, 12)
	UICorner.Parent = MainFrame

	local UIStroke = Instance.new("UIStroke")
	UIStroke.Color = Color3.fromRGB(0, 0, 0)
	UIStroke.Thickness = 2
	UIStroke.Parent = MainFrame

	local CloseButton = Instance.new("TextButton")
	CloseButton.Name = "CloseButton"
	CloseButton.Size = UDim2.new(0, 30, 0, 30)
	CloseButton.Position = UDim2.new(1, -35, 0, 5)
	CloseButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	CloseButton.Text = "X"
	CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	CloseButton.TextScaled = true
	CloseButton.Font = Enum.Font.GothamBold
	CloseButton.Parent = MainFrame

	local CloseCorner = Instance.new("UICorner")
	CloseCorner.CornerRadius = UDim.new(0, 6)
	CloseCorner.Parent = CloseButton

	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Name = "TitleLabel"
	TitleLabel.Size = UDim2.new(1, -40, 0, 35)
	TitleLabel.Position = UDim2.new(0, 10, 0, 5)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Text = "Chat Custom"
	TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TitleLabel.TextScaled = true
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.Parent = MainFrame

	local ScrollFrame = Instance.new("ScrollingFrame")
	ScrollFrame.Name = "ScrollFrame"
	ScrollFrame.Size = UDim2.new(1, -20, 0, 380)
	ScrollFrame.Position = UDim2.new(0, 10, 0, 45)
	ScrollFrame.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	ScrollFrame.BorderSizePixel = 0
	ScrollFrame.ScrollBarThickness = 8
	ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	ScrollFrame.Parent = MainFrame

	local ScrollCorner = Instance.new("UICorner")
	ScrollCorner.CornerRadius = UDim.new(0, 8)
	ScrollCorner.Parent = ScrollFrame

	local UIListLayout = Instance.new("UIListLayout")
	UIListLayout.Padding = UDim.new(0, 2)
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Parent = ScrollFrame

	local ChatBox = Instance.new("TextBox")
	ChatBox.Name = "ChatBox"
	ChatBox.Size = UDim2.new(1, -90, 0, 40)
	ChatBox.Position = UDim2.new(0, 10, 1, -50)
	ChatBox.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
	ChatBox.Text = ""
	ChatBox.PlaceholderText = "Digite sua mensagem..."
	ChatBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	ChatBox.PlaceholderColor3 = Color3.fromRGB(200, 200, 200)
	ChatBox.TextSize = 14
	ChatBox.Font = Enum.Font.Gotham
	ChatBox.ClearTextOnFocus = false
	ChatBox.Parent = MainFrame

	local ChatCorner = Instance.new("UICorner")
	ChatCorner.CornerRadius = UDim.new(0, 8)
	ChatCorner.Parent = ChatBox

	local SendButton = Instance.new("TextButton")
	SendButton.Name = "SendButton"
	SendButton.Size = UDim2.new(0, 70, 0, 40)
	SendButton.Position = UDim2.new(1, -80, 1, -50)
	SendButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	SendButton.Text = "Enviar"
	SendButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	SendButton.TextScaled = true
	SendButton.Font = Enum.Font.GothamBold
	SendButton.Parent = MainFrame

	local SendCorner = Instance.new("UICorner")
	SendCorner.CornerRadius = UDim.new(0, 8)
	SendCorner.Parent = SendButton

	local function addMessageToGui(text, sender)
		local MessageLabel = Instance.new("TextLabel")
		MessageLabel.Name = "Message_" .. tostring(os.time())
		MessageLabel.Size = UDim2.new(1, -10, 0, 0)
		MessageLabel.AutomaticSize = Enum.AutomaticSize.Y
		MessageLabel.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
		MessageLabel.Text = "[" .. sender .. "]: " .. text
		MessageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		MessageLabel.TextWrapped = true
		MessageLabel.TextXAlignment = Enum.TextXAlignment.Left
		MessageLabel.TextSize = 14
		MessageLabel.Font = Enum.Font.Gotham
		MessageLabel.Parent = ScrollFrame

		local MsgCorner = Instance.new("UICorner")
		MsgCorner.CornerRadius = UDim.new(0, 4)
		MsgCorner.Parent = MessageLabel

		local MsgPadding = Instance.new("UIPadding")
		MsgPadding.PaddingLeft = UDim.new(0, 5)
		MsgPadding.PaddingRight = UDim.new(0, 5)
		MsgPadding.PaddingTop = UDim.new(0, 3)
		MsgPadding.PaddingBottom = UDim.new(0, 3)
		MsgPadding.Parent = MessageLabel

		task.wait()
		ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
		ScrollFrame.CanvasPosition = Vector2.new(0, UIListLayout.AbsoluteContentSize.Y)
	end

	local function sendMessage()
		local text = string.sub(ChatBox.Text, 1, 200)
		if string.len(text) == 0 then return end

		addMessageToGui(text, LocalPlayer.Name)

		local generalChannel = TextChatService:FindFirstChild("General")
		if generalChannel then
			pcall(function() generalChannel:SendAsync(text) end)
		else
			pcall(function() LocalPlayer:Chat(text) end)
		end

		ChatBox.Text = ""
	end

	SendButton.MouseButton1Click:Connect(sendMessage)

	ChatBox.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			sendMessage()
		end
	end)

	CloseButton.MouseButton1Click:Connect(function()
		ScreenGui.Enabled = false
	end)

	addMessageToGui("Bem-vindo ao Chat Custom!", "Sistema")
	sendSystemMessage("✅ GUI de Chat criada com sucesso!")
end
-- ==================== FIM GUI ====================

-- ==================== COMANDOS DE CHAT ====================
local function onPlayerChat(message)
	local lowerMessage = string.lower(message)
	print("⌨️ Comando recebido: " .. message)

	if lowerMessage == "/e disable" then
		disableSystem()
	elseif lowerMessage == "/e enable" then
		enableSystem()
	elseif lowerMessage == "/e chat" then
		createChatGui()
	end
end

pcall(function()
	local generalChannel = TextChatService:WaitForChild("General", 5)
	if generalChannel then
		generalChannel.MessageReceived:Connect(function(msg)
			if msg.TextSource and msg.TextSource.Player == LocalPlayer then
				onPlayerChat(msg.Text)
			end
		end)
	end
end)

LocalPlayer.Chatted:Connect(function(message)
	onPlayerChat(message)
end)
-- ==================== FIM COMANDOS ====================

Lighting.ChildAdded:Connect(function(child)
	if isSystemEnabled then
		task.defer(function()
			if child:IsA("BloomEffect")
				or child:IsA("BlurEffect")
				or child:IsA("SunRaysEffect")
				or child:IsA("ColorCorrectionEffect")
				or child:IsA("DepthOfFieldEffect") then
				pcall(function() child:Destroy() end)
			elseif child:IsA("Atmosphere") then
				setNoFog()
			end
		end)
	end
end)

RunService.RenderStepped:Connect(function()
	if isSystemEnabled then
		setExposure()
	end
end)

-- Iniciar sistema
task.wait(1)
enableSystem()
