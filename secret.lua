-- Paint Custom GUI | LocalScript in StarterPlayerScripts
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer
local PGui = LP:WaitForChild("PlayerGui")

local _inputText  = "Heaven"
local _blockColor = Color3.fromRGB(163, 162, 165)
local _pingDelay  = 0.2

local _sideColors = {
	Top    = Color3.fromRGB(255, 80,  255),
	Bottom = Color3.fromRGB(80,  255, 255),
	Front  = Color3.fromRGB(255, 80,  80),
	Back   = Color3.fromRGB(80,  255, 80),
	Left   = Color3.fromRGB(80,  80,  255),
	Right  = Color3.fromRGB(255, 255, 80),
}

local _sideStates = {Front=true,Back=true,Left=true,Right=true,Top=true,Bottom=true}
local sidesOrdered = {"Front","Back","Left","Right","Top","Bottom"}
local sideEnums = {
	Front=Enum.NormalId.Front, Back=Enum.NormalId.Back,
	Left=Enum.NormalId.Left,   Right=Enum.NormalId.Right,
	Top=Enum.NormalId.Top,     Bottom=Enum.NormalId.Bottom,
}

local function getRemote()
	local char = LP.Character
	local tool = char and char:FindFirstChild("Paint") or LP.Backpack:FindFirstChild("Paint")
	if not tool then return nil end
	local s = tool:FindFirstChild("Script")
	if not s then return nil end
	return s:FindFirstChild("Event")
end

local function runSpray(mode)
	local char  = LP.Character
	local brick = RS:FindFirstChild("Brick") or workspace:FindFirstChild("Brick")
	if not (char and char:FindFirstChild("HumanoidRootPart") and brick) then
		warn("[PaintGUI] Need character + Brick in ReplicatedStorage"); return
	end
	local hrpPos = char.HumanoidRootPart.Position
	local remote = getRemote()
	if not remote then warn("[PaintGUI] Paint tool not equipped!"); return end

	if mode == "revert" then
		local rc = Color3.fromRGB(173,172,175)
		-- plastic first to reset material
		remote:FireServer(brick, Enum.NormalId.Top, hrpPos, "both \u{1F91D}", Color3.fromRGB(192,192,192), "plastic", " ")
		task.wait(0.1)
		-- clear each side with a space so text is wiped
		remote:FireServer(brick, Enum.NormalId.Top,    hrpPos, "both \u{1F91D}", rc, "spray", " ")
		task.wait(0.1)
		remote:FireServer(brick, Enum.NormalId.Bottom, hrpPos, "both \u{1F91D}", rc, "spray", " ")
		task.wait(0.1)
		remote:FireServer(brick, Enum.NormalId.Left,   hrpPos, "both \u{1F91D}", rc, "spray", " ")
		task.wait(0.1)
		remote:FireServer(brick, Enum.NormalId.Right,  hrpPos, "both \u{1F91D}", rc, "spray", " ")
		task.wait(0.1)
		remote:FireServer(brick, Enum.NormalId.Back,   hrpPos, "both \u{1F91D}", rc, "spray", " ")
		task.wait(0.1)
		remote:FireServer(brick, Enum.NormalId.Front,  hrpPos, "both \u{1F91D}", rc, "spray", " ")
		if not brick.Anchored then
			task.wait(0.1)
			remote:FireServer(brick, Enum.NormalId.Top, hrpPos, "material", rc, "anchor", " ")
		end
		if not brick.CanCollide then
			task.wait(0.1)
			remote:FireServer(brick, Enum.NormalId.Top, hrpPos, "material", rc, "collide", " ")
		end
		return
	end

	if mode == "anchor" or mode == "toxic" or mode == "plastic" or mode == "smooth" then
		remote:FireServer(brick, Enum.NormalId.Front, brick.Position, "both \u{1F91D}", _blockColor, mode, " ")
	else
		local textTable = string.split(_inputText, ",")
		task.wait(0.1)
		for i, side in ipairs(sidesOrdered) do
			if _sideStates[side] then
				local txt = (textTable[i] or textTable[1] or " "):gsub("^%s*(.-)%s*$", "%1")
				remote:FireServer(brick, sideEnums[side], brick.Position, "both \u{1F91D}", _sideColors[side], "spray", txt)
				task.wait(_pingDelay)
			end
		end
	end
end

-- GUI
local sg = Instance.new("ScreenGui")
sg.Name="PaintGUI"; sg.ResetOnSpawn=false; sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; sg.Parent=PGui

local reopenBtn=Instance.new("TextButton")
reopenBtn.Size=UDim2.new(0,90,0,26); reopenBtn.Position=UDim2.new(0,10,0,10)
reopenBtn.BackgroundColor3=Color3.fromRGB(40,120,220); reopenBtn.BorderSizePixel=0
reopenBtn.Text="🎨 Paint [L]"; reopenBtn.TextColor3=Color3.new(1,1,1)
reopenBtn.Font=Enum.Font.GothamBold; reopenBtn.TextSize=11; reopenBtn.Visible=false; reopenBtn.Parent=sg
Instance.new("UICorner",reopenBtn).CornerRadius=UDim.new(0,6)

local main=Instance.new("Frame")
main.Size=UDim2.new(0,300,0,400); main.Position=UDim2.new(0,20,0,50)
main.BackgroundColor3=Color3.fromRGB(14,14,20); main.BorderSizePixel=0
main.Active=true; main.Draggable=true; main.ClipsDescendants=true; main.Parent=sg
Instance.new("UICorner",main).CornerRadius=UDim.new(0,10)

local accent=Instance.new("Frame")
accent.Size=UDim2.new(1,0,0,3); accent.BackgroundColor3=Color3.fromRGB(40,120,220); accent.BorderSizePixel=0; accent.Parent=main
Instance.new("UICorner",accent).CornerRadius=UDim.new(0,10)

local titleBar=Instance.new("Frame")
titleBar.Size=UDim2.new(1,0,0,36); titleBar.Position=UDim2.new(0,0,0,3)
titleBar.BackgroundColor3=Color3.fromRGB(20,20,30); titleBar.BorderSizePixel=0; titleBar.Parent=main

local titleLbl=Instance.new("TextLabel")
titleLbl.Size=UDim2.new(1,-44,1,0); titleLbl.Position=UDim2.new(0,12,0,0); titleLbl.BackgroundTransparency=1
titleLbl.Text="🎨 Paint Custom"; titleLbl.TextColor3=Color3.fromRGB(40,120,220)
titleLbl.Font=Enum.Font.GothamBold; titleLbl.TextSize=14; titleLbl.TextXAlignment=Enum.TextXAlignment.Left; titleLbl.Parent=titleBar

local closeBtn=Instance.new("TextButton")
closeBtn.Size=UDim2.new(0,28,0,28); closeBtn.Position=UDim2.new(1,-34,0.5,-14)
closeBtn.BackgroundColor3=Color3.fromRGB(200,50,50); closeBtn.BorderSizePixel=0
closeBtn.Text="X"; closeBtn.TextColor3=Color3.new(1,1,1); closeBtn.Font=Enum.Font.GothamBold; closeBtn.TextSize=12; closeBtn.Parent=titleBar
Instance.new("UICorner",closeBtn).CornerRadius=UDim.new(0,6)

local scroll=Instance.new("ScrollingFrame")
scroll.Size=UDim2.new(1,0,1,-39); scroll.Position=UDim2.new(0,0,0,39)
scroll.BackgroundTransparency=1; scroll.BorderSizePixel=0
scroll.ScrollBarThickness=4; scroll.ScrollBarImageColor3=Color3.fromRGB(40,120,220)
scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; scroll.CanvasSize=UDim2.new(0,0,0,0); scroll.Parent=main
local sl=Instance.new("UIListLayout",scroll); sl.Padding=UDim.new(0,5); sl.HorizontalAlignment=Enum.HorizontalAlignment.Center
local sp=Instance.new("UIPadding",scroll)
sp.PaddingLeft=UDim.new(0,8); sp.PaddingRight=UDim.new(0,8); sp.PaddingTop=UDim.new(0,6); sp.PaddingBottom=UDim.new(0,10)

local function divider(label)
	local f=Instance.new("Frame"); f.Size=UDim2.new(1,0,0,20); f.BackgroundColor3=Color3.fromRGB(28,28,42); f.BorderSizePixel=0; f.Parent=scroll
	Instance.new("UICorner",f).CornerRadius=UDim.new(0,5)
	local t=Instance.new("TextLabel"); t.Size=UDim2.new(1,-8,1,0); t.Position=UDim2.new(0,8,0,0); t.BackgroundTransparency=1
	t.Text=label; t.TextColor3=Color3.fromRGB(40,140,255); t.Font=Enum.Font.GothamBold; t.TextSize=11; t.TextXAlignment=Enum.TextXAlignment.Left; t.Parent=f
end

local function textInput(ph, def, cb)
	local f=Instance.new("Frame"); f.Size=UDim2.new(1,0,0,32); f.BackgroundColor3=Color3.fromRGB(24,24,36); f.BorderSizePixel=0; f.Parent=scroll
	Instance.new("UICorner",f).CornerRadius=UDim.new(0,7)
	local tb=Instance.new("TextBox"); tb.Size=UDim2.new(1,-16,1,-8); tb.Position=UDim2.new(0,8,0,4)
	tb.BackgroundTransparency=1; tb.Text=def or ""; tb.PlaceholderText=ph
	tb.PlaceholderColor3=Color3.fromRGB(90,90,110); tb.TextColor3=Color3.fromRGB(230,230,240)
	tb.Font=Enum.Font.Gotham; tb.TextSize=13; tb.ClearTextOnFocus=false; tb.TextXAlignment=Enum.TextXAlignment.Left; tb.Parent=f
	tb.FocusLost:Connect(function() if cb then cb(tb.Text) end end)
end

local function colorPicker(label, defaultColor, cb)
	local col={r=math.floor(defaultColor.R*255),g=math.floor(defaultColor.G*255),b=math.floor(defaultColor.B*255)}
	local function getColor() return Color3.fromRGB(col.r,col.g,col.b) end
	local frame=Instance.new("Frame"); frame.Size=UDim2.new(1,0,0,88); frame.BackgroundColor3=Color3.fromRGB(20,20,30); frame.BorderSizePixel=0; frame.Parent=scroll
	Instance.new("UICorner",frame).CornerRadius=UDim.new(0,7)
	local hdr=Instance.new("TextLabel"); hdr.Size=UDim2.new(1,-52,0,20); hdr.Position=UDim2.new(0,8,0,4); hdr.BackgroundTransparency=1
	hdr.Text=label; hdr.TextColor3=Color3.fromRGB(200,200,215); hdr.Font=Enum.Font.GothamBold; hdr.TextSize=12; hdr.TextXAlignment=Enum.TextXAlignment.Left; hdr.Parent=frame
	local preview=Instance.new("Frame"); preview.Size=UDim2.new(0,36,0,18); preview.Position=UDim2.new(1,-44,0,4)
	preview.BackgroundColor3=defaultColor; preview.BorderSizePixel=0; preview.Parent=frame
	Instance.new("UICorner",preview).CornerRadius=UDim.new(0,4)
	for i,ch in ipairs({{k="r",lbl="R",tint=Color3.fromRGB(220,60,60)},{k="g",lbl="G",tint=Color3.fromRGB(60,200,80)},{k="b",lbl="B",tint=Color3.fromRGB(60,120,255)}}) do
		local y=26+(i-1)*20
		local lbl2=Instance.new("TextLabel"); lbl2.Size=UDim2.new(0,12,0,16); lbl2.Position=UDim2.new(0,8,0,y+1); lbl2.BackgroundTransparency=1
		lbl2.Text=ch.lbl; lbl2.TextColor3=ch.tint; lbl2.Font=Enum.Font.GothamBold; lbl2.TextSize=11; lbl2.Parent=frame
		local track=Instance.new("TextButton"); track.Size=UDim2.new(1,-80,0,8); track.Position=UDim2.new(0,22,0,y+4)
		track.BackgroundColor3=Color3.fromRGB(38,38,55); track.BorderSizePixel=0; track.Text=""; track.Parent=frame
		Instance.new("UICorner",track).CornerRadius=UDim.new(0,4)
		local fill=Instance.new("Frame"); fill.Size=UDim2.new(col[ch.k]/255,0,1,0); fill.BackgroundColor3=ch.tint; fill.BorderSizePixel=0; fill.Parent=track
		Instance.new("UICorner",fill).CornerRadius=UDim.new(0,4)
		local box=Instance.new("TextBox"); box.Size=UDim2.new(0,36,0,16); box.Position=UDim2.new(1,-44,0,y)
		box.BackgroundColor3=Color3.fromRGB(28,28,42); box.BorderSizePixel=0; box.Text=tostring(col[ch.k])
		box.TextColor3=Color3.fromRGB(220,220,235); box.Font=Enum.Font.Gotham; box.TextSize=11; box.Parent=frame
		Instance.new("UICorner",box).CornerRadius=UDim.new(0,4)
		local function apply(x)
			local rel=math.clamp((x-track.AbsolutePosition.X)/math.max(track.AbsoluteSize.X,1),0,1)
			col[ch.k]=math.clamp(math.floor(rel*255),0,255)
			fill.Size=UDim2.new(col[ch.k]/255,0,1,0); box.Text=tostring(col[ch.k])
			preview.BackgroundColor3=getColor(); if cb then cb(getColor()) end
		end
		local drag=false
		track.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true;apply(i.Position.X) end end)
		UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
		UIS.InputChanged:Connect(function(i) if drag and i.UserInputType==Enum.UserInputType.MouseMovement then apply(i.Position.X) end end)
		box.FocusLost:Connect(function()
			local n=tonumber(box.Text)
			if n then col[ch.k]=math.clamp(math.floor(n),0,255);fill.Size=UDim2.new(col[ch.k]/255,0,1,0);preview.BackgroundColor3=getColor();if cb then cb(getColor()) end end
			box.Text=tostring(col[ch.k])
		end)
	end
end

local function makeToggle(label, default, cb)
	local f=Instance.new("Frame"); f.Size=UDim2.new(1,0,0,30); f.BackgroundColor3=Color3.fromRGB(20,20,30); f.BorderSizePixel=0; f.Parent=scroll
	Instance.new("UICorner",f).CornerRadius=UDim.new(0,7)
	local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(1,-50,1,0); lbl.Position=UDim2.new(0,10,0,0); lbl.BackgroundTransparency=1
	lbl.Text=label; lbl.TextColor3=Color3.fromRGB(200,200,215); lbl.Font=Enum.Font.Gotham; lbl.TextSize=12; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Parent=f
	local state=default
	local btn=Instance.new("TextButton"); btn.Size=UDim2.new(0,38,0,20); btn.Position=UDim2.new(1,-46,0.5,-10)
	btn.BackgroundColor3=state and Color3.fromRGB(40,180,80) or Color3.fromRGB(60,60,80); btn.BorderSizePixel=0; btn.Text=""; btn.Parent=f
	Instance.new("UICorner",btn).CornerRadius=UDim.new(0,10)
	local knob=Instance.new("Frame"); knob.Size=UDim2.new(0,16,0,16)
	knob.Position=state and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)
	knob.BackgroundColor3=Color3.new(1,1,1); knob.BorderSizePixel=0; knob.Parent=btn
	Instance.new("UICorner",knob).CornerRadius=UDim.new(0,8)
	btn.MouseButton1Click:Connect(function()
		state=not state
		btn.BackgroundColor3=state and Color3.fromRGB(40,180,80) or Color3.fromRGB(60,60,80)
		knob.Position=state and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)
		if cb then cb(state) end
	end)
end

local function makeButton(label, color, cb)
	local btn=Instance.new("TextButton"); btn.Size=UDim2.new(1,0,0,34); btn.BackgroundColor3=color; btn.BorderSizePixel=0
	btn.Text=label; btn.TextColor3=Color3.new(1,1,1); btn.Font=Enum.Font.GothamBold; btn.TextSize=13; btn.Parent=scroll
	Instance.new("UICorner",btn).CornerRadius=UDim.new(0,8)
	btn.MouseButton1Click:Connect(function() if cb then cb() end end)
end

-- BUILD
divider("Spray Text  (comma = per side)")
textInput("Text1, Text2...", _inputText, function(v) _inputText = v end)
divider("Block Color")
colorPicker("Block Color", _blockColor, function(c) _blockColor = c end)
divider("Spray Color Per Side")
for _,side in ipairs(sidesOrdered) do
	colorPicker("🎨 "..side, _sideColors[side], function(c) _sideColors[side] = c end)
end
divider("Side Toggles")
for _,side in ipairs(sidesOrdered) do
	makeToggle(side, true, function(v) _sideStates[side]=v end)
end
divider("Actions")
makeButton("🎨 Execute Spray", Color3.fromRGB(40,120,220), function() runSpray("spray") end)
makeButton("⚓ Anchor Block",  Color3.fromRGB(50,140,80),  function() runSpray("anchor") end)
makeButton("☠️ Toxify Block",  Color3.fromRGB(160,60,180), function() runSpray("toxic") end)
makeButton("🔄 Revert Brick",  Color3.fromRGB(160,80,40),  function() runSpray("revert") end)
makeButton("💥 Break Bkit", Color3.fromRGB(180,40,40), function()
	local pc = LP.Character
	if not pc then return end
	local brick = RS:FindFirstChild("Brick")
	if not (pc:FindFirstChild("Delete") and pc:FindFirstChild("HumanoidRootPart") and brick) then
		warn("[BreakBkit] Need Delete tool + Brick in ReplicatedStorage"); return
	end
	pc.Delete.Script.Event:FireServer(brick, pc.HumanoidRootPart.Position)
end)

divider("Protection")
local _antiToxic = false
local _antiMaptide = false
local _antiFreeze = false
local _antiJail = false
local _antiFling = false
local _lastPos = nil
local _pendingRecall = false
local _lastFreezePos = nil
local _jailDebounce = false

local function applyAntiToxic(char)
	if not char then return end
	local toxify = char:FindFirstChild("Toxify")
	if toxify then
		toxify.Disabled = _antiToxic
		print("[AntiToxic] Toxify script " .. (_antiToxic and "DISABLED" or "ENABLED"))
	end
end

makeToggle("🛡️ Anti Toxic", false, function(enabled)
	_antiToxic = enabled
	applyAntiToxic(LP.Character)
end)

makeToggle("🌊 Anti Maptide", false, function(enabled)
	_antiMaptide = enabled
	if enabled then
		pcall(function() workspace.FallenPartsDestroyHeight = 0/0 end)
	else
		pcall(function() workspace.FallenPartsDestroyHeight = -500 end)
	end
end)

makeToggle("❄️ Anti Freeze", false, function(enabled)
	_antiFreeze = enabled
end)

makeToggle("🔒 Anti Jail", false, function(enabled)
	_antiJail = enabled
end)

makeToggle("💨 Anti Fling", false, function(enabled)
	_antiFling = enabled
end)

divider("Utility")
makeButton("💀 Force Reset", Color3.fromRGB(140,40,40), function()
	local char = LP.Character
	if char and char:FindFirstChildOfClass("Humanoid") then
		char:FindFirstChildOfClass("Humanoid").Health = 0
	end
end)

makeButton("🏠 Teleport to Spawn", Color3.fromRGB(40,100,180), function()
	local char = LP.Character
	if char and char:FindFirstChild("HumanoidRootPart") then
		char:PivotTo(CFrame.new(-0, 200, 0))
	end
end)

LP.CharacterAdded:Connect(function(char)
	task.wait(0.1) -- minimal wait just for HumanoidRootPart to exist
	applyAntiToxic(char)
	if _pendingRecall and _lastFreezePos then
		local root = char:WaitForChild("HumanoidRootPart", 5)
		if root then
			char:PivotTo(_lastFreezePos)
			task.wait(0.1)
			char:PivotTo(_lastFreezePos)
			_pendingRecall = false
		end
	end
end)

-- Heartbeat
game:GetService("RunService").Heartbeat:Connect(function()
	local char = LP.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not root or not hum then return end

	-- Save last stable position
	if root.AssemblyLinearVelocity.Magnitude < 50 then
		_lastPos = root.CFrame
	end

	if _antiToxic then
		local tox = char:FindFirstChild("Toxify")
		if tox then tox.Disabled = true end
	end

	if _antiMaptide then
		pcall(function() workspace.FallenPartsDestroyHeight = 0/0 end)
		if root.Position.Y < -30 then
			root.AssemblyLinearVelocity = Vector3.zero
			char:PivotTo(CFrame.new(root.Position.X, 200, root.Position.Z))
		end
	end

	if _antiFreeze then
		if char:FindFirstChild("Hielo") then
			if not _pendingRecall then
				_lastFreezePos = root.CFrame
				_pendingRecall = true
				hum.Health = 0
			end
		end
	end

	if _antiJail then
		local jail = char:FindFirstChild("Jail", true)
		if jail then
			pcall(function() jail:Destroy() end)
		end
	end

	if _antiFling then
		-- Reset ANY velocity no matter how small
		if root.AssemblyLinearVelocity ~= Vector3.zero or root.AssemblyAngularVelocity ~= Vector3.zero then
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
		end
	end
end)

local function setOpen(open) main.Visible=open; reopenBtn.Visible=not open end
closeBtn.MouseButton1Click:Connect(function() setOpen(false) end)
reopenBtn.MouseButton1Click:Connect(function() setOpen(true) end)
UIS.InputBegan:Connect(function(input,gpe)
	if gpe then return end
	if input.KeyCode==Enum.KeyCode.L then setOpen(not main.Visible) end
end)

-- CHAT COMMANDS
local _cmdDelay = 0.05 -- default delay

local function getTextChatService()
	return game:GetService("TextChatService")
end

local function sendMsg(text)
	-- Print to output so user can see feedback
	print("[CMD] " .. text)
end

local function runUnanchorAll()
	local char = LP.Character
	if not (char and char:FindFirstChild("HumanoidRootPart")) then
		sendMsg("Need character!"); return
	end
	local tool = LP.Backpack:FindFirstChild("Paint") or char:FindFirstChild("Paint")
	if not tool then sendMsg("Need Paint tool!"); return end
	local s = tool:FindFirstChild("Script")
	if not s then sendMsg("Paint Script not found!"); return end
	local remote = s:FindFirstChild("Event")
	if not remote then sendMsg("Paint Event not found!"); return end

	local bricksFolder = workspace:FindFirstChild("Bricks")
	if not bricksFolder then sendMsg("No Bricks folder in Workspace!"); return end

	local count = 0
	local found = 0

	-- Search all descendants of Bricks for any part named "Brick"
	for _, obj in pairs(bricksFolder:GetDescendants()) do
		if obj.Name == "Brick" and obj:IsA("BasePart") then
			found += 1
			if not obj:FindFirstChild("Drag") and obj.Anchored then
				char:PivotTo(obj.CFrame * CFrame.new(0, 4, 0))
				task.wait(_cmdDelay)
				remote:FireServer(obj, Enum.NormalId.Front, obj.Position, "both \u{1F91D}", Color3.fromRGB(163,162,165), "anchor", " ")
				task.wait(_cmdDelay)
				count += 1
			end
		end
	end

	sendMsg("Found " .. found .. " bricks. Unanchored " .. count .. ".")
end

-- Chat command detection
local function handleCmd(text)
	text = text:lower():gsub("^%s*(.-)%s*$", "%1") -- trim
	if text == "-unanchor all" then
		task.spawn(runUnanchorAll)
	elseif text:sub(1, 10) == "-setdelay " then
		local val = tonumber(text:sub(11))
		if val then
			val = math.clamp(val, 0.02, 0.15)
			_cmdDelay = val
			sendMsg("Delay set to " .. val .. "s")
		end
	end
end

-- TextChatService (modern Roblox)
local tcs = game:GetService("TextChatService")
tcs.MessageReceived:Connect(function(msg)
	if msg.TextSource and msg.TextSource.UserId == LP.UserId then
		handleCmd(msg.Text)
	end
end)

-- Legacy fallback
LP.Chatted:Connect(function(msg)
	handleCmd(msg)
end)

print("[PaintGUI] Ready! L = toggle. Commands: -unanchor all | -setdelay 0.02~0.15")
