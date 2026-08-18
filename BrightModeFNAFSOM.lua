--!strict
--// FULL BRIGHT + NOFOG + ANTI LAG + CHAT COMMANDS + CUSTOM GUI
--// LocalScript | Organized | Auto Reapply

local Lighting: Lighting = game:GetService("Lighting")
local Workspace: Workspace = game:GetService("Workspace")
local RunService: RunService = game:GetService("RunService")
local Players: Players = game:GetService("Players")
local TextChatService: TextChatService = game:GetService("TextChatService")

local LocalPlayer: Player = Players.LocalPlayer
local PlayerGui: PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ==================== CONFIGURATION ====================
local CONFIG = {
	ExposureDay = 0.3,
	ExposureNight = 0.6,
	FPSCap = 200,
	RenderDistance = 1000,
	AntiLagInterval = 0.2,
}

local DEFAULT_LIGHTING: {[string]: any} = {}
local isSystemEnabled: boolean = true
local antiLagConnection: thread? = nil
-- ==================== END CONFIGURATION ====================

for _, prop: string in ipairs({
	"GlobalShadows", "Brightness", "Ambient", "OutdoorAmbient",
	"ColorShift_Top", "ColorShift_Bottom", "EnvironmentDiffuseScale",
	"EnvironmentSpecularScale", "Technology", "FogStart", "FogEnd",
	"ExposureCompensation", "ReflectionIntensity", "ShadowSoftness"
}) do
	local success: boolean, val: any = pcall(function(): any
		return Lighting[prop]
	end)
	if success then
		DEFAULT_LIGHTING[prop] = val
	end
end

pcall(function(): ()
	setfpscap(CONFIG.FPSCap)
end)

local function setLightingBase(): ()
	Lighting.GlobalShadows = false
	Lighting.Brightness = 0
	Lighting.Ambient = Color3.fromRGB(255, 255, 255)
	Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
	Lighting.ColorShift_Top = Color3.new(0, 0, 0)
	Lighting.ColorShift_Bottom = Color3.new(0, 0, 0)
	Lighting.EnvironmentDiffuseScale = 0
	Lighting.EnvironmentSpecularScale = 0
	Lighting.Technology = Enum.Technology.Compatibility
end

local function setExposure(): ()
	local clock: number = Lighting.ClockTime
	if clock >= 6 and clock < 18 then
		Lighting.ExposureCompensation = CONFIG.ExposureDay
	else
		Lighting.ExposureCompensation = CONFIG.ExposureNight
	end
end

local function setNoFog(): ()
	Lighting.FogStart = 0
	Lighting.FogEnd = 1e10

	local atmosphere: Atmosphere? = Lighting:FindFirstChildOfClass("Atmosphere")
	if atmosphere then
		atmosphere.Density = 0
		atmosphere.Offset = 0
		atmosphere.Glare = 0
		atmosphere.Haze = 0
	end
end

local function removePostEffects(): ()
	for _, obj: Instance in ipairs(Lighting:GetDescendants()) do
		if obj:IsA("BloomEffect")
			or obj:IsA("BlurEffect")
			or obj:IsA("SunRaysEffect")
			or obj:IsA("ColorCorrectionEffect")
			or obj:IsA("DepthOfFieldEffect") then
			obj:Destroy()
		end
	end
end

local function disableWorldLights(): ()
	for _, obj: Instance in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("PointLight")
			or obj:IsA("SpotLight")
			or obj:IsA("SurfaceLight") then
			obj.Enabled = false
		end
	end
end

local function removeReflections(): ()
	pcall(function(): ()
		Lighting.ReflectionIntensity = 0
		Lighting.ShadowSoftness = 0
	end)
end

local function boostStreaming(): ()
	pcall(function(): ()
		Workspace.StreamingEnabled = true
		Workspace.StreamingTargetRadius = CONFIG.RenderDistance
		Workspace.StreamingMinRadius = math.min(128, CONFIG.RenderDistance)
	end)
end

local function antiLag(): ()
	setLightingBase()
	setExposure()
	setNoFog()
	removePostEffects()
	disableWorldLights()
	removeReflections()
	boostStreaming()
end

local function restoreDefaults(): ()
	for property: string, value: any in pairs(DEFAULT_LIGHTING) do
		pcall(function(): ()
			Lighting[property] = value
		end)
	end

	local atmosphere: Atmosphere? = Lighting:FindFirstChildOfClass("Atmosphere")
	if atmosphere then
		atmosphere.Density = 0
		atmosphere.Offset = 0
		atmosphere.Glare = 0
		atmosphere.Haze = 0
	end
end

local function enableSystem(): ()
	isSystemEnabled = true
	antiLag()

	if not antiLagConnection then
		antiLagConnection = task.spawn(function(): ()
			while isSystemEnabled do
				task.wait(CONFIG.AntiLagInterval)
				if isSystemEnabled then
					antiLag()
				end
			end
		end)
	end
end

local function disableSystem(): ()
	isSystemEnabled = false

	if antiLagConnection then
		task.cancel(antiLagConnection)
		antiLagConnection = nil
	end

	restoreDefaults()
end

-- ==================== CUSTOM CHAT GUI ====================
local function createChatGui(): ()
	local existingGui: ScreenGui? = PlayerGui:FindFirstChild("CustomChatGui") :: ScreenGui?
	if existingGui then
		existingGui.Enabled = not existingGui.Enabled
		return
	end

	local ScreenGui: ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "CustomChatGui"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.Parent = PlayerGui

	local MainFrame: Frame = Instance.new("Frame")
	MainFrame.Name = "MainFrame"
	MainFrame.Size = UDim2.new(0, 400, 0, 500)
	MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
	MainFrame.BackgroundColor3 = Color3.fromRGB(128, 128, 128)
	MainFrame.Parent = ScreenGui

	local UICorner: UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(0, 12)
	UICorner.Parent = MainFrame

	local UIStroke: UIStroke = Instance.new("UIStroke")
	UIStroke.Color = Color3.fromRGB(0, 0, 0)
	UIStroke.Thickness = 2
	UIStroke.Parent = MainFrame

	local CloseButton: TextButton = Instance.new("TextButton")
	CloseButton.Name = "CloseButton"
	CloseButton.Size = UDim2.new(0, 30, 0, 30)
	CloseButton.Position = UDim2.new(1, -35, 0, 5)
	CloseButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	CloseButton.Text = "X"
	CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	CloseButton.TextScaled = true
	CloseButton.Font = Enum.Font.GothamBold
	CloseButton.Parent = MainFrame

	local CloseCorner: UICorner = Instance.new("UICorner")
	CloseCorner.CornerRadius = UDim.new(0, 6)
	CloseCorner.Parent = CloseButton

	local TitleLabel: TextLabel = Instance.new("TextLabel")
	TitleLabel.Name = "TitleLabel"
	TitleLabel.Size = UDim2.new(1, -40, 0, 35)
	TitleLabel.Position = UDim2.new(0, 10, 0, 5)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Text = "Chat Custom"
	TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TitleLabel.TextScaled = true
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.Parent = MainFrame

	local ScrollFrame: ScrollingFrame = Instance.new("ScrollFrame")
	ScrollFrame.Name = "ScrollFrame"
	ScrollFrame.Size = UDim2.new(1, -20, 0, 380)
	ScrollFrame.Position = UDim2.new(0, 10, 0, 45)
	ScrollFrame.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	ScrollFrame.BorderSizePixel = 0
	ScrollFrame.ScrollBarThickness = 8
	ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	ScrollFrame.Parent = MainFrame

	local ScrollCorner: UICorner = Instance.new("UICorner")
	ScrollCorner.CornerRadius = UDim.new(0, 8)
	ScrollCorner.Parent = ScrollFrame

	local UIListLayout: UIListLayout = Instance.new("UIListLayout")
	UIListLayout.Padding = UDim.new(0, 2)
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Parent = ScrollFrame

	local ChatBox: TextBox = Instance.new("TextBox")
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

	local ChatCorner: UICorner = Instance.new("UICorner")
	ChatCorner.CornerRadius = UDim.new(0, 8)
	ChatCorner.Parent = ChatBox

	local SendButton: TextButton = Instance.new("TextButton")
	SendButton.Name = "SendButton"
	SendButton.Size = UDim2.new(0, 70, 0, 40)
	SendButton.Position = UDim2.new(1, -80, 1, -50)
	SendButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	SendButton.Text = "Enviar"
	SendButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	SendButton.TextScaled = true
	SendButton.Font = Enum.Font.GothamBold
	SendButton.Parent = MainFrame

	local SendCorner: UICorner = Instance.new("UICorner")
	SendCorner.CornerRadius = UDim.new(0, 8)
	SendCorner.Parent = SendButton

	local function addMessageToGui(text: string, sender: string): ()
		local MessageLabel: TextLabel = Instance.new("TextLabel")
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

		local MsgCorner: UICorner = Instance.new("UICorner")
		MsgCorner.CornerRadius = UDim.new(0, 4)
		MsgCorner.Parent = MessageLabel

		local MsgPadding: UIPadding = Instance.new("UIPadding")
		MsgPadding.PaddingLeft = UDim.new(0, 5)
		MsgPadding.PaddingRight = UDim.new(0, 5)
		MsgPadding.PaddingTop = UDim.new(0, 3)
		MsgPadding.PaddingBottom = UDim.new(0, 3)
		MsgPadding.Parent = MessageLabel

		task.wait()
		ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
		ScrollFrame.CanvasPosition = Vector2.new(0, UIListLayout.AbsoluteContentSize.Y)
	end

	local function sendMessage(): ()
		local text: string = string.sub(ChatBox.Text, 1, 200)
		if string.len(text) == 0 then return end

		addMessageToGui(text, LocalPlayer.Name)

		local generalChannel: TextChannel? = TextChatService:FindFirstChild("General") :: TextChannel?
		if generalChannel then
			pcall(function(): ()
				generalChannel:SendAsync(text)
			end)
		else
			pcall(function(): ()
				LocalPlayer:Chat(text)
			end)
		end

		ChatBox.Text = ""
	end

	SendButton.MouseButton1Click:Connect(sendMessage)

	ChatBox.FocusLost:Connect(function(enterPressed: boolean): ()
		if enterPressed then
			sendMessage()
		end
	end)

	CloseButton.MouseButton1Click:Connect(function(): ()
		ScreenGui.Enabled = false
	end)

	addMessageToGui("Bem-vindo ao Chat Custom!", "Sistema")
end
-- ==================== END CHAT GUI ====================

-- ==================== CHAT COMMANDS ====================
local function onPlayerChat(message: string): ()
	local lowerMessage: string = string.lower(message)

	if lowerMessage == "/e disable" then
		disableSystem()
	elseif lowerMessage == "/e enable" then
		enableSystem()
	elseif lowerMessage == "/e chat" then
		createChatGui()
	end
end

pcall(function(): ()
	local generalChannel: TextChannel = TextChatService:WaitForChild("General", 5) :: TextChannel
	if generalChannel then
		generalChannel.MessageReceived:Connect(function(msg: TextChatMessage): ()
			if msg.TextSource and msg.TextSource.Player == LocalPlayer then
				onPlayerChat(msg.Text)
			end
		end)
	end
end)

LocalPlayer.Chatted:Connect(function(message: string): ()
	onPlayerChat(message)
end)
-- ==================== END COMMANDS ====================

Lighting.ChildAdded:Connect(function(child: Instance): ()
	if isSystemEnabled then
		task.defer(function(): ()
			if child:IsA("BloomEffect")
				or child:IsA("BlurEffect")
				or child:IsA("SunRaysEffect")
				or child:IsA("ColorCorrectionEffect")
				or child:IsA("DepthOfFieldEffect") then
				child:Destroy()
			elseif child:IsA("Atmosphere") then
				setNoFog()
			end
		end)
	end
end)

RunService.RenderStepped:Connect(function(): ()
	if isSystemEnabled then
		setExposure()
	end
end)

enableSystem()
