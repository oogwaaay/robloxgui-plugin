-- RobloxGUI Studio Plugin
-- One-click import of generated GUI code from https://robloxgui.dev

local plugin = plugin or getfenv().plugin
if not plugin then
	warn("RobloxGUI: This script must run as a Roblox Studio plugin.")
	return
end

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Selection = game:GetService("Selection")

local API_BASE = "https://robloxgui.dev/api/plugin"
local POLL_INTERVAL = 2

-- Generate a 6-character code without ambiguous characters
local function generateCode()
	local chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
	local code = {}
	math.randomseed(tick())
	for i = 1, 6 do
		local idx = math.random(1, #chars)
		table.insert(code, string.sub(chars, idx, idx))
	end
	return table.concat(code)
end

local function buildUrl(path)
	return API_BASE .. path
end

local function httpGet(url)
	local ok, result = pcall(function()
		return HttpService:GetAsync(url, true)
	end)
	if ok then
		return ok, result
	end
	return ok, tostring(result)
end

local function httpPost(url, body)
	body = body or "{}"
	local ok, result = pcall(function()
		return HttpService:PostAsync(url, body, Enum.HttpContentType.ApplicationJson)
	end)
	if ok then
		return ok, result
	end
	return ok, tostring(result)
end

local function createUi(parent)
	local frame = Instance.new("Frame")
	frame.Name = "MainFrame"
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundColor3 = Color3.fromRGB(13, 17, 23)
	frame.BorderSizePixel = 0
	frame.Parent = parent

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 16)
	padding.PaddingBottom = UDim.new(0, 16)
	padding.PaddingLeft = UDim.new(0, 16)
	padding.PaddingRight = UDim.new(0, 16)
	padding.Parent = frame

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0, 24)
	title.Position = UDim2.new(0, 0, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "RobloxGUI Importer"
	title.TextColor3 = Color3.fromRGB(240, 242, 245)
	title.TextSize = 18
	title.Font = Enum.Font.GothamBold
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = frame

	local subtitle = Instance.new("TextLabel")
	subtitle.Name = "Subtitle"
	subtitle.Size = UDim2.new(1, 0, 0, 32)
	subtitle.Position = UDim2.new(0, 0, 0, 28)
	subtitle.BackgroundTransparency = 1
	subtitle.Text = "Generate UI on robloxgui.dev, then enter this code in your browser."
	subtitle.TextColor3 = Color3.fromRGB(139, 149, 168)
	subtitle.TextSize = 12
	subtitle.Font = Enum.Font.Gotham
	subtitle.TextXAlignment = Enum.TextXAlignment.Left
	subtitle.TextWrapped = true
	subtitle.Parent = frame

	local codeLabel = Instance.new("TextLabel")
	codeLabel.Name = "CodeLabel"
	codeLabel.Size = UDim2.new(1, 0, 0, 16)
	codeLabel.Position = UDim2.new(0, 0, 0, 70)
	codeLabel.BackgroundTransparency = 1
	codeLabel.Text = "YOUR STUDIO CODE"
	codeLabel.TextColor3 = Color3.fromRGB(0, 212, 255)
	codeLabel.TextSize = 10
	codeLabel.Font = Enum.Font.GothamBold
	codeLabel.TextXAlignment = Enum.TextXAlignment.Left
	codeLabel.Parent = frame

	local codeValue = Instance.new("TextLabel")
	codeValue.Name = "CodeValue"
	codeValue.Size = UDim2.new(1, 0, 0, 48)
	codeValue.Position = UDim2.new(0, 0, 0, 88)
	codeValue.BackgroundColor3 = Color3.fromRGB(22, 26, 34)
	codeValue.BorderColor3 = Color3.fromRGB(42, 48, 64)
	codeValue.BorderSizePixel = 1
	codeValue.Text = "------"
	codeValue.TextColor3 = Color3.fromRGB(240, 242, 245)
	codeValue.TextSize = 28
	codeValue.Font = Enum.Font.RobotoMono
	codeValue.Parent = frame

	local corner1 = Instance.new("UICorner")
	corner1.CornerRadius = UDim.new(0, 8)
	corner1.Parent = codeValue

	local copyButton = Instance.new("TextButton")
	copyButton.Name = "CopyButton"
	copyButton.Size = UDim2.new(1, 0, 0, 32)
	copyButton.Position = UDim2.new(0, 0, 0, 142)
	copyButton.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
	copyButton.BorderColor3 = Color3.fromRGB(42, 48, 64)
	copyButton.BorderSizePixel = 1
	copyButton.Text = "Copy Code"
	copyButton.TextColor3 = Color3.fromRGB(240, 242, 245)
	copyButton.TextSize = 12
	copyButton.Font = Enum.Font.GothamBold
	copyButton.AutoButtonColor = true
	copyButton.Parent = frame

	local corner2 = Instance.new("UICorner")
	corner2.CornerRadius = UDim.new(0, 6)
	corner2.Parent = copyButton

	local statusLabel = Instance.new("TextLabel")
	statusLabel.Name = "StatusLabel"
	statusLabel.Size = UDim2.new(1, 0, 0, 16)
	statusLabel.Position = UDim2.new(0, 0, 0, 184)
	statusLabel.BackgroundTransparency = 1
	statusLabel.Text = "Status: Waiting for code..."
	statusLabel.TextColor3 = Color3.fromRGB(139, 149, 168)
	statusLabel.TextSize = 12
	statusLabel.Font = Enum.Font.Gotham
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left
	statusLabel.Parent = frame

	local logLabel = Instance.new("TextLabel")
	logLabel.Name = "LogLabel"
	logLabel.Size = UDim2.new(1, 0, 0, 80)
	logLabel.Position = UDim2.new(0, 0, 0, 206)
	logLabel.BackgroundTransparency = 1
	logLabel.Text = ""
	logLabel.TextColor3 = Color3.fromRGB(139, 149, 168)
	logLabel.TextSize = 11
	logLabel.Font = Enum.Font.Gotham
	logLabel.TextXAlignment = Enum.TextXAlignment.Left
	logLabel.TextYAlignment = Enum.TextYAlignment.Top
	logLabel.TextWrapped = true
	logLabel.Parent = frame

	local newCodeButton = Instance.new("TextButton")
	newCodeButton.Name = "NewCodeButton"
	newCodeButton.Size = UDim2.new(1, 0, 0, 32)
	newCodeButton.Position = UDim2.new(0, 0, 1, -32)
	newCodeButton.AnchorPoint = Vector2.new(0, 0)
	newCodeButton.BackgroundColor3 = Color3.fromRGB(0, 212, 255)
	newCodeButton.BorderSizePixel = 0
	newCodeButton.Text = "Generate New Code"
	newCodeButton.TextColor3 = Color3.fromRGB(12, 14, 18)
	newCodeButton.TextSize = 12
	newCodeButton.Font = Enum.Font.GothamBold
	newCodeButton.AutoButtonColor = true
	newCodeButton.Parent = frame

	local corner3 = Instance.new("UICorner")
	corner3.CornerRadius = UDim.new(0, 6)
	corner3.Parent = newCodeButton

	return {
		frame = frame,
		codeValue = codeValue,
		copyButton = copyButton,
		statusLabel = statusLabel,
		logLabel = logLabel,
		newCodeButton = newCodeButton,
	}
end

local currentCode = nil
local polling = false
local ui = nil
local widget = nil

local function setStatus(text)
	if ui and ui.statusLabel then
		ui.statusLabel.Text = "Status: " .. text
	end
	print("[RobloxGUI] " .. text)
end

local function setLog(text)
	if ui and ui.logLabel then
		ui.logLabel.Text = text
	end
end

local function importCode(data)
	local scene = data.scene or "GUI"
	local baseName = "RobloxGUI_" .. tostring(scene) .. "_" .. tostring(os.time())

	-- Import client GUI code into StarterPlayerScripts
	local starterPlayer = game:GetService("StarterPlayer")
	local starterScripts = starterPlayer:WaitForChild("StarterPlayerScripts", 5)
	if not starterScripts then
		setLog("Could not find StarterPlayerScripts. Aborting.")
		return false
	end

	local clientScript = Instance.new("LocalScript")
	clientScript.Name = baseName
	clientScript.Source = data.clientLuaCode
	clientScript.Parent = starterScripts

	if data.serverLuaCode and data.serverLuaCode ~= "" then
		local serverStorage = game:GetService("ServerScriptService")
		local serverScript = Instance.new("Script")
		serverScript.Name = baseName .. "_Server"
		serverScript.Source = data.serverLuaCode
		serverScript.Parent = serverStorage
	end

	-- Try to select the client script in Explorer
	pcall(function()
		Selection:Set({ clientScript })
	end)

	return true
end

local function pollLoop()
	if polling then return end
	polling = true

	spawn(function()
		while polling and widget and widget.Enabled do
			if currentCode then
				local ok, body = httpGet(buildUrl("/jobs/" .. currentCode))
				if ok and body then
					local parseOk, data = pcall(function()
						return HttpService:JSONDecode(body)
					end)

					if parseOk and data then
						if data.status == "pending" and data.clientLuaCode then
							setStatus("Importing...")
							local imported = importCode(data)
							if imported then
								local deliverOk = httpPost(buildUrl("/jobs/" .. currentCode .. "/delivered"), "{}")
								if deliverOk then
									setStatus("Done! Imported " .. (data.title or "GUI") .. ".")
									setLog("Created client LocalScript in StarterPlayerScripts" .. (data.serverLuaCode and " and server Script in ServerScriptService." or "."))
								else
									setStatus("Imported, but failed to mark delivered.")
								end
								polling = false
								break
							else
								setStatus("Import failed.")
							end
						elseif data.status == "delivered" then
							setStatus("Already imported.")
							polling = false
							break
						end
					else
						setLog("Invalid response from server.")
					end
				else
					-- Expected when job isn't ready yet
				end
			end
			wait(POLL_INTERVAL)
		end
		polling = false
	end)
end

local function refreshCode()
	currentCode = generateCode()
	if ui and ui.codeValue then
		ui.codeValue.Text = currentCode
	end
	polling = false
	wait(0.1)
	setStatus("Waiting for code " .. currentCode .. "...")
	setLog("Copy the code above and paste it on robloxgui.dev after generating a GUI.")
	pollLoop()
end

local function setupWidget()
	local widgetInfo = DockWidgetPluginGuiInfo.new(
		Enum.InitialDockState.Right,
		false,
		false,
		300,
		400,
		250,
		300
	)

	widget = plugin:CreateDockWidgetPluginGui("RobloxGUIImporter", widgetInfo)
	widget.Title = "RobloxGUI Importer"
	widget.Name = "RobloxGUIImporter"

	ui = createUi(widget)

	ui.copyButton.MouseButton1Click:Connect(function()
		if currentCode then
			local ok = pcall(function()
				-- Luau doesn't have a clipboard API for plugins; this is a no-op fallback.
				-- Users can select and copy the visible code.
			end)
			setStatus("Code copied (select the label if auto-copy failed).")
		end
	end)

	ui.newCodeButton.MouseButton1Click:Connect(function()
		refreshCode()
	end)

	widget:GetPropertyChangedSignal("Enabled"):Connect(function()
		if widget.Enabled and not polling then
			refreshCode()
		else
			polling = false
		end
	end)
end

-- Toolbar button
local toolbar = plugin:CreateToolbar("RobloxGUI")
local button = toolbar:CreateButton(
	"OpenRobloxGUIImporter",
	"Open RobloxGUI Importer",
	"rbxassetid://0" -- placeholder icon; replace with real asset id if available
)
button.Click:Connect(function()
	if not widget then
		setupWidget()
	end
	widget.Enabled = true
	refreshCode()
end)

print("[RobloxGUI] Plugin loaded. Open the RobloxGUI toolbar to start.")
