-- HZ RECOVERY
-- [PERSONALIZED: FULL INTEGRITY | HEARTBEAT | PCALLS | UNDERSCORE NAMING]

local _players = game:GetService('Players')
local _LocalPlayer = _players.LocalPlayer
local _userInput = game:GetService("UserInputService")
local _runService = game:GetService("RunService")
local _coreGui = game:GetService("CoreGui")
local _starterGui = game:GetService("StarterGui")
local _lighting = game:GetService("Lighting")

-- [WHITELIST]
local WHITELISTED_USERS = {
    [5206038338] = true,
    [9722416815] = true,
    [3365293121] = true
}
if not WHITELISTED_USERS[_LocalPlayer.UserId] then return end

-- [SYSTEM STATES]
local _states = {
    vampire = false, myopic = false, glitch = false, cursed = false,
    maptide = false, freeze = false, jail = false, blind = false,
    fling = false, speed = false, esp = false, gravity = false,
    toxic = false, collision = false, noclip = false, sit = false,
    muteBoomboxes = false,
    activeColor = Color3.fromRGB(0, 255, 255),
    anchorTime = 0.05
}

local _stablePos = nil
local _lastSnapTime = 0
local _pendingRecall = false
local _lastFreezePos = nil
local _activeHeadsit = nil

-- [UI SETUP]
local ScreenGui = Instance.new("ScreenGui", _coreGui)
ScreenGui.Name = "HZ_Recovery"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.Position = UDim2.new(0.5, -100, 0.2, 0) 
MainFrame.Size = UDim2.new(0, 200, 0, 350)
MainFrame.Active = true

local function round(obj, r)
    local c = Instance.new("UICorner", obj)
    c.CornerRadius = UDim.new(0, r or 15)
end
round(MainFrame, 20)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "HZ RECOVERY"
Title.TextColor3 = Color3.fromRGB(0, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold

local Scroll = Instance.new("ScrollingFrame", MainFrame)
Scroll.Size = UDim2.new(1, 0, 1, -50)
Scroll.Position = UDim2.new(0, 0, 0, 40)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 20, 0)
Scroll.ScrollBarThickness = 2

local UIList = Instance.new("UIListLayout", Scroll)
UIList.Padding = UDim.new(0, 6); UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function createBtn(text, color)
    local b = Instance.new("TextButton", Scroll)
    b.Size = UDim2.new(0.9, 0, 0, 30)
    b.BackgroundColor3 = color
    b.Text = text
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 9
    round(b, 10)
    return b
end

-- [PICKER & SLIDER LOGIC]
local PickerFrame = Instance.new("Frame", ScreenGui)
PickerFrame.Size = UDim2.new(0, 160, 0, 180)
PickerFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
PickerFrame.Visible = false
round(PickerFrame, 10)

local HueSlider = Instance.new("TextButton", PickerFrame)
HueSlider.Size = UDim2.new(0.9, 0, 0, 20)
HueSlider.Position = UDim2.new(0.05, 0, 0.05, 0)
HueSlider.Text = "Color"
HueSlider.TextColor3 = Color3.new(1,1,1)
HueSlider.AutoButtonColor = false
round(HueSlider, 5)

local SatSlider = Instance.new("TextButton", PickerFrame)
SatSlider.Size = UDim2.new(0.9, 0, 0, 20)
SatSlider.Position = UDim2.new(0.05, 0, 0.20, 0)
SatSlider.Text = "Saturation"
SatSlider.TextColor3 = Color3.new(1,1,1)
SatSlider.AutoButtonColor = false
round(SatSlider, 5)

local ValSlider = Instance.new("TextButton", PickerFrame)
ValSlider.Size = UDim2.new(0.9, 0, 0, 20)
ValSlider.Position = UDim2.new(0.05, 0, 0.35, 0)
ValSlider.Text = "Brightness"
ValSlider.TextColor3 = Color3.new(1,1,1)
ValSlider.AutoButtonColor = false
round(ValSlider, 5)

local SpeedSlider = Instance.new("TextButton", PickerFrame)
SpeedSlider.Size = UDim2.new(0.9, 0, 0, 20)
SpeedSlider.Position = UDim2.new(0.05, 0, 0.55, 0)
SpeedSlider.Text = "Speed: 0.05s"
SpeedSlider.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SpeedSlider.TextColor3 = Color3.new(1,1,1)
SpeedSlider.AutoButtonColor = false
round(SpeedSlider, 5)

local ClosePicker = createBtn("Apply Settings", Color3.fromRGB(0, 255, 255))
ClosePicker.Parent = PickerFrame
ClosePicker.Position = UDim2.new(0.05, 0, 0.78, 0)
ClosePicker.Size = UDim2.new(0.9, 0, 0, 25)

-- [INPUTS & BUTTONS]
local NameInput = Instance.new("TextBox", Scroll)
NameInput.Size = UDim2.new(0.9, 0, 0, 30)
NameInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
NameInput.PlaceholderText = "Enter Name..."
NameInput.Text = ""
NameInput.TextColor3 = Color3.new(1, 1, 1)
NameInput.Font = Enum.Font.Gotham
NameInput.TextSize = 10
round(NameInput, 5)

local TpBtn = createBtn("Teleport", Color3.fromRGB(60, 60, 60))
local HeadsitBtn = createBtn("Headsit", Color3.fromRGB(100, 40, 150))
local ColorBtn = createBtn("Color All", _states.activeColor)
local RefreshBtn = createBtn("Refresh", Color3.fromRGB(46, 204, 113))
local SpawnBtn   = createBtn("To Spawn", Color3.fromRGB(0, 120, 215))
local FBBtn      = createBtn("Fullbright [One-Time]", Color3.fromRGB(241, 196, 15))
local NCBtn      = createBtn("Noclip (Off)", Color3.fromRGB(130, 0, 0))
local ACBtn      = createBtn("Anti Collision (Off)", Color3.fromRGB(130, 0, 0))
local UnflyBtn   = createBtn("Unfly Player", Color3.fromRGB(255, 165, 0))
local ToxicBtn   = createBtn("Anti Toxic (Off)", Color3.fromRGB(130, 0, 0))
local SitBtn     = createBtn("Anti Sit (Off)", Color3.fromRGB(130, 0, 0))
local GravityBtn = createBtn("Anti Gravity (Off)", Color3.fromRGB(130, 0, 0))
local FlingBtn   = createBtn("Anti Fling (Off)", Color3.fromRGB(130, 0, 0))
local SpeedBtn   = createBtn("Anti Speed (Off)", Color3.fromRGB(130, 0, 0))
local ESPBtn     = createBtn("Enlightened Esp (Off)", Color3.fromRGB(130, 0, 0))
local GlitchBtn  = createBtn("Anti Glitch (Off)", Color3.fromRGB(130, 0, 0))
local VampBtn    = createBtn("Anti Vampire (Off)", Color3.fromRGB(130, 0, 0))
local MyopicBtn  = createBtn("Anti Myopic (Off)", Color3.fromRGB(130, 0, 0))
local VoidBtn    = createBtn("Anti Maptide (Off)", Color3.fromRGB(130, 0, 0))
local RecallBtn  = createBtn("Anti Freeze (Off)", Color3.fromRGB(130, 0, 0))
local JailBtn    = createBtn("Anti Jail (Off)", Color3.fromRGB(130, 0, 0))
local BlindBtn   = createBtn("Anti Blind (Off)", Color3.fromRGB(130, 0, 0))
local CursedBtn  = createBtn("Anti Cursed (Off)", Color3.fromRGB(130, 0, 0))

-- [BOOMBOX LOGIC]
local function _setBoomboxVolume(vol)
    pcall(function()
        for _, _p in pairs(_players:GetPlayers()) do
            local _containers = {_p.Backpack, _p.Character}
            for _, _folder in pairs(_containers) do
                if _folder then
                    local _box = _folder:FindFirstChild("SuperFlyGoldBoombox")
                    if _box then
                        local _handle = _box:FindFirstChild("Handle")
                        if _handle then
                            local _sound = _handle:FindFirstChild("Sound")
                            if _sound and _sound:IsA("Sound") then
                                _sound.Volume = vol
                            end
                        end
                    end
                end
            end
        end
    end)
end

_LocalPlayer.Chatted:Connect(function(_msg)
    local _cmd = _msg:lower()
    if _cmd == "!muteboomboxes" then
        _states.muteBoomboxes = true
        _starterGui:SetCore("SendNotification", {Title = "HZ RECOVERY", Text = "Boomboxes Muted"})
    elseif _cmd == "!unmuteboomboxes" then
        _states.muteBoomboxes = false
        _setBoomboxVolume(1)
        _starterGui:SetCore("SendNotification", {Title = "HZ RECOVERY", Text = "Boomboxes Unmuted"})
    end
end)

-- [PICKER & SLIDER LOGIC]
local _h, _s, _v = 0, 1, 1
local function updatePickerColor()
    _states.activeColor = Color3.fromHSV(_h, _s, _v)
    ColorBtn.BackgroundColor3 = _states.activeColor
    HueSlider.BackgroundColor3 = Color3.fromHSV(_h, 1, 1)
end

local function handleSlider(slider, callback)
    slider.MouseButton1Down:Connect(function()
        local con
        con = _runService.RenderStepped:Connect(function()
            if not _userInput:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then con:Disconnect() return end
            local mousePos = _userInput:GetMouseLocation().X
            local relativePos = math.clamp((mousePos - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
            callback(relativePos)
        end)
    end)
end

handleSlider(HueSlider, function(p) _h = p updatePickerColor() end)
handleSlider(SatSlider, function(p) _s = p updatePickerColor() end)
handleSlider(ValSlider, function(p) _v = p updatePickerColor() end)
handleSlider(SpeedSlider, function(p) 
    _states.anchorTime = math.clamp(p * 0.5, 0.001, 0.5) 
    SpeedSlider.Text = string.format("Speed: %.3fs", _states.anchorTime)
end)

ColorBtn.MouseButton2Click:Connect(function()
    PickerFrame.Position = UDim2.new(0, ColorBtn.AbsolutePosition.X + 210, 0, ColorBtn.AbsolutePosition.Y)
    PickerFrame.Visible = not PickerFrame.Visible
end)

ClosePicker.MouseButton1Click:Connect(function() PickerFrame.Visible = false end)

-- [COLOR ALL LOGIC]
local function _performColorAll()
    pcall(function()
        local _char = _LocalPlayer.Character
        local _hum = _char:FindFirstChildOfClass("Humanoid")
        local _paint = _LocalPlayer.Backpack:FindFirstChild("Paint") or _char:FindFirstChild("Paint")
        
        if not _paint then
            _starterGui:SetCore("SendNotification", {Title = "HZ RECOVERY", Text = "Equip Paint first!"})
            return
        end

        _paint.Parent = _char
        _hum:EquipTool(_paint)
        
        local _event = _paint:FindFirstChild("Script"):FindFirstChild("Event")
        if not _event then return end

        local _bricksFolder = workspace:FindFirstChild("Bricks")
        if not _bricksFolder then return end

        for _, _v in pairs(_bricksFolder:GetDescendants()) do
            if _v.Name == "Brick" and _v:IsA("BasePart") then
                _char:PivotTo(_v.CFrame * CFrame.new(0, 2, 0))
                
                _event:FireServer(
                    _v, 
                    "Top", 
                    _v.Position, 
                    'both \u{1f91d}', 
                    _states.activeColor,
                    'Anchor'
                )
                task.wait(_states.anchorTime)
            end
        end
    end)
end

-- [UTILITY LOGIC]
local function _fullbright()
    pcall(function()
        _lighting.Brightness = 2
        _lighting.ClockTime = 14
        _lighting.FogEnd = 100000
        _lighting.GlobalShadows = false
        _lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        for _, v in pairs(_lighting:GetDescendants()) do
            if v:IsA("Atmosphere") or v:IsA("Sky") then v:Destroy() end
        end
    end)
end

local function _unfly()
    pcall(function()
        local _char = _LocalPlayer.Character
        for _, _v in pairs(_char:GetDescendants()) do
            if _v:IsA("BaseScript") and (_v.Name:lower():find("fly") or _v.Name:lower():find("flying")) then _v.Disabled = true end
            if _v:IsA("BodyVelocity") or _v:IsA("BodyGyro") or _v:IsA("RocketPropulsion") then _v:Destroy() end
        end
        if _char:FindFirstChildOfClass("Humanoid") then _char:FindFirstChildOfClass("Humanoid").PlatformStand = false end
    end)
end

-- [HEARTBEAT LOOP]
_runService.Heartbeat:Connect(function()
    pcall(function()
        local char = _LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not root or not hum then return end

        if _states.muteBoomboxes then _setBoomboxVolume(0) end

        if _activeHeadsit and _activeHeadsit.Character and _activeHeadsit.Character:FindFirstChild("Head") then
            if hum.Jump then _activeHeadsit = nil else
                hum.Sit = true
                char:PivotTo(_activeHeadsit.Character.Head.CFrame * CFrame.new(0, 1.5, 0))
            end
        elseif _activeHeadsit then _activeHeadsit = nil end

        if _states.noclip then for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end
        if _states.collision then
            for _, p in pairs(_players:GetPlayers()) do
                if p ~= _LocalPlayer and p.Character then
                    for _, v in pairs(p.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
                end
            end
        end
        if _states.sit and not _activeHeadsit then if hum.Sit then hum.Sit = false end end
        if _states.toxic then
            local tox = char:FindFirstChild("Toxify")
            if tox then tox.Disabled = true end
        end
        if _states.gravity then if math.abs(workspace.Gravity - 196.2) > 0.1 then workspace.Gravity = 196.2 end end
        if _states.fling then
            if root.AssemblyLinearVelocity.Magnitude > 150 or root.AssemblyAngularVelocity.Magnitude > 150 then
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
                char:PivotTo(_stablePos or root.CFrame)
            end
        end
        if _states.speed and hum then hum.WalkSpeed = 16 end
        if _states.maptide then
            if root.Position.Y < -30 then 
                root.AssemblyLinearVelocity = Vector3.zero
                char:PivotTo(CFrame.new(root.Position.X, 200, root.Position.Z)) 
            end
            pcall(function() workspace.FallenPartsDestroyHeight = 0/0 end) 
        end
        if _states.freeze and char:FindFirstChild("Hielo") then
            if not _pendingRecall then 
                _lastFreezePos = root.CFrame
                _pendingRecall = true
                if hum then hum.Health = 0 end 
            end
        end
        if _pendingRecall and not char:FindFirstChild("Hielo") then
            if _lastFreezePos then char:PivotTo(_lastFreezePos) end
            _pendingRecall = false
        end

        if _states.esp then
            for _, p in pairs(_players:GetPlayers()) do
                if p ~= _LocalPlayer and p.Character then
                    local _hasArken = p.Backpack:FindFirstChild("The Arkenstone") or p.Character:FindFirstChild("The Arkenstone")
                    local _espObj = p.Character:FindFirstChild("HZ_ESP")
                    if _hasArken then
                        if not _espObj then
                            local h = Instance.new("Highlight")
                            h.Name = "HZ_ESP"
                            h.FillColor = Color3.fromRGB(0, 150, 255)
                            h.OutlineColor = Color3.new(1, 1, 1)
                            h.FillTransparency = 0.5
                            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            h.Parent = p.Character
                        end
                    else
                        if _espObj then _espObj:Destroy() end
                    end
                end
            end
        else
            for _, p in pairs(_players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("HZ_ESP") then p.Character.HZ_ESP:Destroy() end
            end
        end

        if _states.vampire then 
            workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
            _starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
            _starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
            local _pg = _LocalPlayer:FindFirstChild("PlayerGui")
            if _pg then
                for _, _gui in pairs(_pg:GetChildren()) do
                    if _gui:IsA("ScreenGui") then
                        local _name = _gui.Name:lower()
                        if _name:find("inventory") or _name:find("hotbar") or _name:find("item") then
                            _gui.Enabled = true
                        end
                    end
                end
            end
        end
        if _states.myopic then for _, v in pairs(_lighting:GetChildren()) do if v:IsA("BlurEffect") then v.Enabled = false end end end
        if _states.jail then for _, v in pairs(char:GetChildren()) do if v.Name:lower():find("jail") then v:Destroy() end end end
        if _states.blind then 
            local pg = _LocalPlayer:FindFirstChild("PlayerGui")
            if pg then for _, ui in pairs(pg:GetChildren()) do if ui.Name:lower():find("blind") then ui.Enabled = false end end end
        end
        if _states.cursed then for _, e in pairs(_lighting:GetChildren()) do if e:IsA("ColorCorrectionEffect") then e.Enabled = false end end end
        if tick() - _lastSnapTime > 0.5 then
            if root.AssemblyLinearVelocity.Magnitude < 50 then _stablePos = root.CFrame end
            _lastSnapTime = tick()
        end
        if _states.glitch and _stablePos then
            if (root.Position - _stablePos.Position).Magnitude > 1000 then char:PivotTo(_stablePos) end
        end
    end)
end)

-- [TOGGLE LOGIC]
local function toggle(btn, key, name)
    _states[key] = not _states[key]
    btn.Text = name .. (_states[key] and " (On)" or " (Off)")
    btn.BackgroundColor3 = _states[key] and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(130, 0, 0)
end

-- [CONNECTIONS]
ColorBtn.MouseButton1Click:Connect(_performColorAll)
FBBtn.MouseButton1Click:Connect(_fullbright)
UnflyBtn.MouseButton1Click:Connect(_unfly)
SpawnBtn.MouseButton1Click:Connect(function() pcall(function() _LocalPlayer.Character:PivotTo(CFrame.new(0, 27, 0)) end) end)

HeadsitBtn.MouseButton1Click:Connect(function()
    pcall(function()
        local tName = NameInput.Text:lower()
        if tName == "" or tName == " " then _activeHeadsit = nil return end
        for _, p in pairs(_players:GetPlayers()) do
            if p.Name:lower():sub(1, #tName) == tName or p.DisplayName:lower():sub(1, #tName) == tName then
                _activeHeadsit = p
                break
            end
        end
    end)
end)

RefreshBtn.MouseButton1Click:Connect(function()
    pcall(function()
        local _c = _LocalPlayer.Character
        if _c and _c:FindFirstChild("HumanoidRootPart") then
            local _oldCF = _c.HumanoidRootPart.CFrame
            _LocalPlayer.Character:BreakJoints()
            local _con
            _con = _LocalPlayer.CharacterAdded:Connect(function(_newChar)
                local _newRoot = _newChar:WaitForChild("HumanoidRootPart", 5)
                if _newRoot then _newChar:PivotTo(_oldCF) end
                _con:Disconnect()
            end)
        end
    end)
end)

TpBtn.MouseButton1Click:Connect(function()
    pcall(function()
        local tName = NameInput.Text:lower()
        for _, p in pairs(_players:GetPlayers()) do
            if p.Name:lower():sub(1, #tName) == tName or p.DisplayName:lower():sub(1, #tName) == tName then
                if p.Character then _LocalPlayer.Character:PivotTo(p.Character:GetPivot()) end
                break
            end
        end
    end)
end)

NCBtn.MouseButton1Click:Connect(function() toggle(NCBtn, "noclip", "Noclip") end)
ACBtn.MouseButton1Click:Connect(function() toggle(ACBtn, "collision", "Anti Collision") end)
ToxicBtn.MouseButton1Click:Connect(function() toggle(ToxicBtn, "toxic", "Anti Toxic") end)
SitBtn.MouseButton1Click:Connect(function() toggle(SitBtn, "sit", "Anti Sit") end)
GravityBtn.MouseButton1Click:Connect(function() toggle(GravityBtn, "gravity", "Anti Gravity") end)
FlingBtn.MouseButton1Click:Connect(function() toggle(FlingBtn, "fling", "Anti Fling") end)
SpeedBtn.MouseButton1Click:Connect(function() toggle(SpeedBtn, "speed", "Anti Speed") end)
ESPBtn.MouseButton1Click:Connect(function() toggle(ESPBtn, "esp", "Enlightened Esp") end)
GlitchBtn.MouseButton1Click:Connect(function() toggle(GlitchBtn, "glitch", "Anti Glitch") end)
VampBtn.MouseButton1Click:Connect(function() toggle(VampBtn, "vampire", "Anti Vampire") end)
MyopicBtn.MouseButton1Click:Connect(function() toggle(MyopicBtn, "myopic", "Anti Myopic") end)
VoidBtn.MouseButton1Click:Connect(function() toggle(VoidBtn, "maptide", "Anti Maptide") end)
RecallBtn.MouseButton1Click:Connect(function() toggle(RecallBtn, "freeze", "Anti Freeze") end)
JailBtn.MouseButton1Click:Connect(function() toggle(JailBtn, "jail", "Anti Jail") end)
BlindBtn.MouseButton1Click:Connect(function() toggle(BlindBtn, "blind", "Anti Blind") end)
CursedBtn.MouseButton1Click:Connect(function() toggle(CursedBtn, "cursed", "Anti Cursed") end)

local drag, sPos, sInput
MainFrame.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then drag = true sInput = input.Position sPos = MainFrame.Position end end)
_userInput.InputChanged:Connect(function(input) if drag and input.UserInputType == Enum.UserInputType.MouseMovement then local delta = input.Position - sInput MainFrame.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + delta.X, sPos.Y.Scale, sPos.Y.Offset + delta.Y) end end)
_userInput.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end end)
_userInput.InputBegan:Connect(function(i, p) if not p and i.KeyCode == Enum.KeyCode.L then MainFrame.Visible = not MainFrame.Visible end end)
