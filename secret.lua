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
    prefix = "!",
    tpMode = "loop" -- Options: loop, ring, hl, vl
}

local _stablePos = nil
local _lastSnapTime = 0
local _pendingRecall = false
local _lastFreezePos = nil

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
Scroll.CanvasSize = UDim2.new(0, 0, 16, 0)
Scroll.ScrollBarThickness = 2

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

local UIList = Instance.new("UIListLayout", Scroll)
UIList.Padding = UDim.new(0, 6); UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- [TELEPORT MODULE]
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

-- [FEATURE BUTTONS]
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

local function _bringUA(targetChar)
    pcall(function()
        if not targetChar then return end
        local _root = targetChar:FindFirstChild("HumanoidRootPart")
        if not _root then return end
        
        local _parts = {}
        for _, _part in pairs(workspace:GetDescendants()) do
            if _part:IsA("BasePart") and not _part.Anchored and not _part:IsDescendantOf(targetChar) then
                table.insert(_parts, _part)
            end
        end

        local _mode = _states.tpMode
        for _i, _v in pairs(_parts) do
            if _mode == "loop" then
                _v.CFrame = _root.CFrame
            elseif _mode == "ring" then
                local _angle = (_i / #_parts) * math.pi * 2
                _v.CFrame = _root.CFrame * CFrame.new(math.cos(_angle) * 10, 0, math.sin(_angle) * 10)
            elseif _mode == "hl" then
                local _spacing = 4
                _v.CFrame = _root.CFrame * CFrame.new((_i - (#_parts/2)) * _spacing, 0, 0)
            elseif _mode == "vl" then
                local _spacing = 4
                _v.CFrame = _root.CFrame * CFrame.new(0, (_i - (#_parts/2)) * _spacing, 0)
            end
        end
    end)
end

-- [CHAT COMMANDS]
_LocalPlayer.Chatted:Connect(function(_msg)
    pcall(function()
        local _args = _msg:lower():split(" ")
        local _pref = _states.prefix

        if _args[1]:sub(1, #_pref) == _pref then
            local _cmd = _args[1]:sub(#_pref + 1)

            if _cmd == "setprefix" and _args[2] then
                _states.prefix = _args[2]
            end

            if _cmd == "setmode" and _args[2] then
                local _m = _args[2]
                if _m == "ring" or _m == "hl" or _m == "vl" or _m == "loop" then
                    _states.tpMode = _m
                end
            end

            if _cmd == "tpua" then
                local _name = _args[2]
                if _name == "me" then
                    _bringUA(_LocalPlayer.Character)
                elseif _name then
                    for _, _p in pairs(_players:GetPlayers()) do
                        if _p.Name:lower():sub(1, #_name) == _name or _p.DisplayName:lower():sub(1, #_name) == _name then
                            _bringUA(_p.Character)
                            break
                        end
                    end
                end
            end
        end
    end)
end)

-- [CORE HEARTBEAT LOOP]
_runService.Heartbeat:Connect(function()
    pcall(function()
        local char = _LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not root or not hum then return end

        if _states.noclip then
            for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
        end

        if _states.collision then
            for _, p in pairs(_players:GetPlayers()) do
                if p ~= _LocalPlayer and p.Character then
                    for _, v in pairs(p.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
                end
            end
        end

        if _states.sit then if hum.Sit then hum.Sit = false end end

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
                    local arken = p.Backpack:FindFirstChild("The Arkenstone") or p.Character:FindFirstChild("The Arkenstone")
                    if arken and not p.Character:FindFirstChild("HZ_ESP") then
                        local h = Instance.new("Highlight", p.Character)
                        h.Name = "HZ_ESP"; h.FillColor = Color3.fromRGB(0, 150, 255)
                    elseif not arken and p.Character:FindFirstChild("HZ_ESP") then
                        p.Character.HZ_ESP:Destroy()
                    end
                end
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
FBBtn.MouseButton1Click:Connect(_fullbright)
UnflyBtn.MouseButton1Click:Connect(_unfly)
SpawnBtn.MouseButton1Click:Connect(function() pcall(function() _LocalPlayer.Character:PivotTo(CFrame.new(0, 27, 0)) end) end)

RefreshBtn.MouseButton1Click:Connect(function()
    pcall(function()
        local _c = _LocalPlayer.Character
        if _c and _c:FindFirstChild("HumanoidRootPart") then
            local _oldCF = _c.HumanoidRootPart.CFrame
            _LocalPlayer.Character:BreakJoints()
            local _con
            _con = _LocalPlayer.CharacterAdded:Connect(function(_newChar)
                local _newRoot = _newChar:WaitForChild("HumanoidRootPart", 5)
                if _newRoot then 
                    _newChar:PivotTo(_oldCF) 
                end
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

-- [DRAG & TOGGLE UI]
local drag, sPos, sInput
MainFrame.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then drag = true sInput = input.Position sPos = MainFrame.Position end end)
_userInput.InputChanged:Connect(function(input) if drag and input.UserInputType == Enum.UserInputType.MouseMovement then local delta = input.Position - sInput MainFrame.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + delta.X, sPos.Y.Scale, sPos.Y.Offset + delta.Y) end end)
_userInput.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end end)

_userInput.InputBegan:Connect(function(i, p) 
    if not p and i.KeyCode == Enum.KeyCode.L then MainFrame.Visible = not MainFrame.Visible end
end)
