
if not LPH_OBFUSCATED and not LPH_JIT_ULTRA then
    LPH_JIT_ULTRA = function(f) return f end
    LPH_JIT_MAX = function(f) return f end
    LPH_JIT = function(f) return f end
    LPH_ENCSTR = function(s) return s end
    LPH_STRENC = function(s) return s end
    LPH_CRASH = function() while true do end return end
end
if not table_flip then
    function table_flip(t)local tt={};for i,v in pairs(t) do tt[v]=i;end;return tt;end
    b91enc={'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '!', '#', '$', '%', '&', '(', ')', '*', '+', ',', '.', '/', ':', ';', '<', '=', '>', '?', '@', '[', ']', '^', '_', '`', '{', '|', '}', '~', '"'}; b91enc[0]='A'; b91dec=table_flip(b91enc)
    function base91_decode(d)local l,v,o,b,n = #d,-1,"",0,0;for i in d:gmatch(".") do local c=b91dec[i];if not(c) then else if v < 0 then v = c;else v = v+c*91;b = bit.bor(b, bit.lshift(v,n));if bit.band(v,8191) then n = n + 13;else n = n + 14;end;while true do o=o..string.char(bit.band(b,255));b=bit.rshift(b,8);n=n-8;if not (n>7) then break;end;end;v=-1;end;end;end;if v + 1>0 then o=o..string.char(bit.band(bit.bor(b,bit.lshift(v,n)),255));end;return o;end
    function base91_encode(d)local b,n,o,l=0,0,"",#d;for i in d:gmatch(".") do b=bit.bor(b,bit.lshift(string.byte(i),n));n=n+8;if n>13 then v=bit.band(b,8191);if v>88 then b=bit.rshift(b,13);n=n-13;else v=bit.band(b,16383);b=bit.rshift(b,14);n=n-14;end;o=o..b91enc[v % 91] .. b91enc[math.floor(v / 91)];end;end;if n>0 then o=o..b91enc[b % 91];if n>7 or b>90 then o=o .. b91enc[math.floor(b / 91)];end;end;return o;end
    function is_lower(c)return c:lower() == c;end
    function swap_case(s)s = s:gsub(".", function(c)return is_lower(c) and c:upper() or c:lower();end);return s;end    
end

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Loaded, Running = false, true

-- Services
local Workspace = game:GetService("Workspace")
local Terrain = Workspace:FindFirstChildOfClass("Terrain")
local Camera = Workspace.CurrentCamera
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local NetworkClient = game:GetService("NetworkClient")
local Mouse = LocalPlayer:GetMouse()
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedPlayers = ReplicatedStorage:FindFirstChild("Players")
local CoreGui = game:GetService("CoreGui")
local ESP, ESP_RenderStepped, Framework = loadstring(game:HttpGet('https://www.octohook.xyz/ionhub/ionhub_esp.lua'))()

-- Overrides
ESP.Overrides.Get_Tool = LPH_JIT_ULTRA(function(Player)
    local Tool = ReplicatedPlayers[Player.Name].Status.GameplayVariables.EquippedTool
    local toolObject = Tool.Value
    return toolObject ~= nil and toolObject.Name or "None"
end)

-- Prepare
if not ReplicatedPlayers then
    LocalPlayer:Kick("[CODE 1] Script is outdated. DM tatar0071#0627 with this kick's code.")
end
local serverLabel
local headSound = Framework:Instance("Sound", {Volume = 10, Parent = CoreGui})
local bodySound = Framework:Instance("Sound", {Volume = 10, Parent = CoreGui})
local killSound = Framework:Instance("Sound", {Volume = 10, Parent = CoreGui})
local Library, Flags, IsClicking, LastCameraCFrame = nil, {}, false, CFrame.new(0, 0, 0)
local Utility, createTracer, __index, __newindex, __namecall
local FreeCamera = {
    Speed = 0.5,
    CFrame = CFrame.new(0, 0, 0)
}
local Aimbot = {
    Player = nil, 
    Target = nil
}
local Methods_Debug = {}
local Old_Gravity = Workspace.Gravity
local Old_Camera = {
    FieldOfView = Camera.FieldOfView,
    DiagonalFieldOfView = Camera.DiagonalFieldOfView,
    MaxAxisFieldOfView = Camera.MaxAxisFieldOfView
}
local Old_Decoration = gethiddenproperty(Terrain, "Decoration")
local Old_Lighting = {
    Ambient = Lighting.Ambient,
    Brightness = Lighting.Brightness,
    ColorShift_Bottom = Lighting.ColorShift_Bottom,
    ColorShift_Top = Lighting.ColorShift_Top,
    EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
    EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
    GlobalShadows = Lighting.GlobalShadows,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    Technology = gethiddenproperty(Lighting, "Technology"),
    ClockTime = Lighting.ClockTime,
    TimeOfDay = Lighting.TimeOfDay,
    ExposureCompensation = Lighting.ExposureCompensation
}

-- Metatable Hooks
for _, connection in pairs(getconnections(Workspace:GetPropertyChangedSignal("Gravity"))) do
    connection:Disable()
end
for _, connection in pairs(getconnections(Workspace.Changed)) do
    connection:Disable()
end
local BanRemote
local Character = LocalPlayer.Character
if Character then
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if Humanoid then
        for _, connection in pairs(getconnections(Humanoid.StateChanged)) do
            local Function = connection.Function
            local Constants = getconstants(Function)
            if table.find(Constants, "FireServer") then
                connection:Disable()
                local Upvalues = getupvalues(Function)
                for i, v in pairs(Upvalues) do
                    if typeof(v) == "Instance" and v:IsA("RemoteEvent") then
                        BanRemote = v
                    end
                end
            end
        end
    end
end
Character = nil
LPH_JIT_ULTRA(function()
    local emptyFunction = function() end
    __index = hookmetamethod(game, "__index", newcclosure(function(k, v)
        if not Running or checkcaller() or not Loaded then return __index(k, v) end
        if tostring(k) == "Barrel" and v == "CFrame" and Flags.aimbotEnabled and Flags.aimbotSilent and Aimbot.Target and Flags.aimbotEnabledBind then
            return CFrame.new(Camera.CFrame.p, Aimbot.Target.CFrame.p)
        end
        if k == Lighting then
            if Old_Lighting[v] then return Old_Lighting[v] end
        end
        if k == Camera then
            if Old_Camera[v] then return Old_Camera[v] end
            if v == "CFrame" then
                if Flags.lPlayerThirdPerson and Flags.lPlayerThirdPersonBind or Flags.lplayerFreeCamera and Flags.lplayerFreeCameraBind then
                    return LastCameraCFrame
                end
            end
        end
        if k == Workspace and v == "Gravity" then return Old_Gravity end
        if tostring(k) == "Humanoid" then
            if v == "PlatformStand" then 
                return false 
            end
            if v == "AutoRotate" then
                return true
            end
            if v == "StateChanged" then
                local Signal = {enabled = false}
                Signal.__index = Signal
                function Signal:Connect(f) 
                    local Constants = getconstants(f)
                    if table.find(Constants, "FireServer") then
                        f = emptyFunction
                    end
                    return __index(k, v):Connect(f)
                end
                function Signal:connect(f) 
                    local Constants = getconstants(f)
                    if table.find(Constants, "FireServer") then
                        f = emptyFunction
                    end
                    return __index(k, v):connect(f)
                end
                function Signal:Disconnect() end
                function Signal:disconnect() end
                function Signal:Wait() end
                function Signal:wait() end
                return Signal
            end
        end
        if v == "CanCollide" and k.Parent == LocalPlayer.Character then return true end
        if v == "Archivable" and k == LocalPlayer.Character then return false end
        return __index(k, v)
    end))
    local Salo = {{stepAmount = 43, dropTiming = 0.0005}}
    __namecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        if not Running or checkcaller() or not Loaded then return __namecall(self, ...) end
        local Args, Method, Script = {...}, getnamecallmethod():lower(), getcallingscript()
        if tostring(self) == "Humanoid" and Method == "getstate" then
            local Call = __namecall(self, ...)
            if Call == Enum.HumanoidStateType.Swimming then
                return Call
            end
            return Enum.HumanoidStateType.Running
        end
        if Method == "fireserver" then
            if tostring(self):lower() == "errorlog" or tostring(self):lower() == "errrorlog" or self == BanRemote then
                return
            end
            local Args_4 = Args[4]
            if type(Args_4) == "table" and Args_4[1] and Args_4[1].stepAmount then
                local Call
                if Flags.aimbotEnabled and Flags.aimbotSilent and Aimbot.Target then
                    Args[4] = Salo
                    Call = __namecall(self, unpack(Args))
                end
                Call = Call or __namecall(self, ...)
                syn.set_thread_identity(7)
                local Hit = Args[2]
                if Hit.Name:lower():find("head") then
                    headSound:Play()
                else
                    bodySound:Play()
                end
                if Flags.logsHitRegistration then
                    local TargetStuds = math.floor((Hit.Position - Camera.CFrame.p).Magnitude + 0.5)
                    Library:SendNotification(("Hit registration | Player: %s, Hit: %s, Distance: %sm (%s studs)"):format(Hit.Parent.Name, Hit.Name, math.floor(TargetStuds / 3.5714285714 + 0.5), TargetStuds), Flags.logsHitRegistrationDuration, Flags.logsHitRegistrationColor)
                end
                return Call
            end
        end
        if Method == "setprimarypartcframe" and Flags.modsEnabled and Flags.modsCustomViewmodel then
            return __namecall(self, Camera.CFrame * CFrame.new(0.05, -1.35, 0.7) * CFrame.new(Flags.modsCustomViewmodelX, -Flags.modsCustomViewmodelY, -Flags.modsCustomViewmodelZ))
        end
        if Flags.aimbotEnabled and Flags.aimbotSilent and Aimbot.Target and Flags.aimbotEnabledBind then
            if Method == "raycast" then
                local shouldMiss = false
                if Flags.silentMissChance >= math.random(1, 100) then
                    shouldMiss = true
                end
                local Args_3 = Args[3]
                local Origin = Flags.silentOrigin == "Camera" and Camera.CFrame.p or Flags.silentOrigin == "Head" and LocalPlayer.Character.Head.Position or Flags.silentOrigin == "First Person" and LastCameraCFrame or Args[1]
                local Target = Aimbot.Target
                local TargetPos = Target.CFrame
                if shouldMiss then
                    local Where = math.random(1, 4)
                    if Where == 1 then
                        TargetPos = TargetPos * CFrame.new(3.5, 4, 0)
                    elseif Where == 2 then
                        TargetPos = TargetPos * CFrame.new(-3.5, 4, 0)
                    elseif Where == 3 then
                        TargetPos = TargetPos * CFrame.new(3.5, -4, 0)
                    elseif Where == 4 then
                        TargetPos = TargetPos * CFrame.new(-3.5, -4, 0)
                    end
                end
                TargetPos = TargetPos.Position
                Args[2] = (TargetPos - Origin).unit * 10000
                return __namecall(self, unpack(Args))
            end
        end
        return __namecall(self, ...)
    end))
    __newindex = hookmetamethod(game, "__newindex", function(i, v, n_v)
        if not Running or checkcaller() or not Loaded then return __newindex(i, v, n_v) end

        if i == Camera and v == "CFrame" then
            LastCameraCFrame = n_v
            if Flags.lplayerFreeCamera and Flags.lplayerFreeCameraBind then
                return __newindex(i, v, CFrame.lookAt(FreeCamera.CFrame.p, FreeCamera.CFrame.p + n_v.LookVector))
            end
            if Flags.lPlayerThirdPerson and Flags.lPlayerThirdPersonBind then
                return __newindex(i, v, n_v + Camera.CFrame.LookVector * -Flags.lPlayerThirdPersonValue)
            end
            if Flags.modsEnabled and Flags.modsNoBob then
                local Script = getcallingscript()
                if tostring(Script) == "CharacterController" then
                    return __newindex(i, v, Camera.CFrame)
                end
            end
        end

        return __newindex(i, v, n_v)
    end)
end)()

function Bypass_Client()
    for i, v in pairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "A1Sent") ~= nil then 
            rawset(v, "A1Sent", true)
        end
    end
end

local FPS = nil
for i, v in next, getgc(true) do
    if type(v) == "table" and rawget(v, "updateClient") then
        FPS = v
    end
end

local VFX = nil
for i, v in next, getgc(true) do
    if type(v) == 'table' and rawget(v, "RecoilCamera") then
        VFX = v
        break
    end
end

local VFX_Impact = VFX.Impact
VFX.Impact = LPH_JIT_ULTRA(function(...)
    local Args = {...}
    local Call = VFX_Impact(...)
    syn.set_thread_identity(7)
    if Flags.logsBulletTracer then 
        if Args[6] == true then
            createTracer(Args[2], Camera.CFrame.p)
        end
    end
    return Call
end)

local ChatScript
for i, v in pairs(getgc(true)) do
    if type(v) == 'table' and rawget(v, "CreateMessageLabel") then
        ChatScript = v
    end
end

local ChatScript_CreateMessageLabel = ChatScript.CreateMessageLabel
ChatScript.CreateMessageLabel = LPH_JIT_MAX(function(...)
    local Args = {...}
    if Flags.removalsKilledBy then
        local Message = Args[2].Message
        if Message then
            if Message:lower():find("[system]") and Message:lower():find(LocalPlayer.Name:lower()) then
                if Message:find("by "..LocalPlayer.Name) then
                    Args[2].Message = "[System] No name dog just got owned by IonHub"
                    killSound:Play()
                else
                    Args[2].Message = "[System] IonHub user killed by a poor guy"
                end
            end
        end
    end
    return ChatScript_CreateMessageLabel(unpack(Args))
end)

local Visor
local Utility
Bypass_Client()
local FPS_new = FPS.new
FPS.new = function(...)
    local Call = FPS_new(...)
    Bypass_Client()
    for i, v in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
        if v:IsA("TextLabel") then
            if v.Text:find("| Server") or v.Text:find(game.JobId:lower()) or v.Text:find(LocalPlayer.UserId) or v.Text:find("Development") then
                serverLabel = v
            end
        end
    end
    if serverLabel then
        Utility:Connection(serverLabel:GetPropertyChangedSignal("Text"), LPH_JIT_ULTRA(function()
            if Flags.removalsServer then
                serverLabel.Text = ""
            end
        end))
    end
    task.spawn(function()
        local MainGui = Players.LocalPlayer.PlayerGui:WaitForChild("MainGui")
        if MainGui then 
            local MainFrame = MainGui:WaitForChild("MainFrame")
            if MainFrame then 
                local ScreenEffects = MainFrame:WaitForChild("ScreenEffects")
                Visor = ScreenEffects:WaitForChild("Visor")
                if Visor then
                    Utility:Connection(Visor:GetPropertyChangedSignal("Visible"), LPH_JIT_ULTRA(function()
                        if Flags.removalsVisor then
                            Visor.Visible = false
                        end
                    end))
                end
            end
        end
    end)
    return Call
end

local VFX_RecoilCamera = VFX.RecoilCamera
VFX.RecoilCamera = LPH_JIT_MAX(function(...)
    if Flags.modsEnabled and Flags.modsNoRecoil then
        return
    end
    return VFX_RecoilCamera(...)
end)

-- User Interface
Library = loadstring(game:HttpGet("https://www.octohook.xyz/ionhub/ionhub_ui.lua"))({
    cheatname = 'IonHub',
    gamename = 'Project Delta',
    fileext = '.json'
})
Utility = Library.utility
Library:init();
local Wheld, Sheld, Aheld, Dheld, Eheld, Qheld = false, false, false, false, false, false
local Input, Connection

LPH_JIT_ULTRA(function()
    Input = {}; do
        function Input:Block()
            ContextActionService:BindActionAtPriority("__FC", function(Action, State, Input)
                local oldSpeed = FreeCamera.Speed
                if Input.KeyCode.Name == "W" or Input.KeyCode.Name == "Up" then
                    Wheld = State.Name == "Begin" and true or false
                end
                if Input.KeyCode.Name == "S" or Input.KeyCode.Name == "Down" then
                    Sheld = State.Name == "Begin" and true or false
                end
                if Input.KeyCode.Name == "A" or Input.KeyCode.Name == "Left" then
                    Aheld = State.Name == "Begin" and true or false
                end
                if Input.KeyCode.Name == "D" or Input.KeyCode.Name == "Right" then
                    Dheld = State.Name == "Begin" and true or false
                end
                if Input.KeyCode.Name == "E" or Input.KeyCode.Name == "Space" then
                    Eheld = State.Name == "Begin" and true or false
                end
                if Input.KeyCode.Name == "Q" or Input.KeyCode.Name == "LeftControl" then
                    Qheld = State.Name == "Begin" and true or false
                end
                return Enum.ContextActionResult.Sink
            end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.E, Enum.KeyCode.Q, Enum.KeyCode.Up, Enum.KeyCode.Down, Enum.KeyCode.Right, Enum.KeyCode.Left, Enum.KeyCode.Space, Enum.KeyCode.LeftControl, Enum.KeyCode.LeftShift, Enum.KeyCode.LeftAlt)
        end
        function Input:Unblock()
            ContextActionService:UnbindAction("__FC")
            Wheld, Sheld, Aheld, Dheld, Eheld, Qheld = false, false, false, false, false, false
        end
        Input.__index = Input
    end

    do
        function FreeCamera:Start()
            local Character = LocalPlayer.Character
            if Character then
                local Humanoid = Character:FindFirstChildOfClass("Humanoid")
                if Humanoid then
                    Humanoid.AutoRotate = false
                end
            end
            FreeCamera.CFrame = Camera.CFrame
            if Connection ~= nil then Connection:Disconnect() Connection = nil end
            Input:Block()
            Connection = Utility:Connection(RunService.RenderStepped, function()
                local Character = LocalPlayer.Character
                if Character then
                    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
                    if Humanoid then
                        Humanoid.AutoRotate = false
                        local Speed = FreeCamera.Speed
                        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift) then
                            Speed = Speed * 3
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) or UserInputService:IsKeyDown(Enum.KeyCode.RightAlt) then
                            Speed = Speed / 3
                        end
                        local newCFrame = FreeCamera.CFrame * CFrame.new((Aheld and Dheld and 0) or (Aheld and -Speed) or (Dheld and Speed), (Eheld and Qheld and 0) or (Qheld and -Speed) or (Eheld and Speed), (Wheld and Sheld and 0) or (Wheld and -Speed) or (Sheld and Speed))
                        FreeCamera.CFrame = CFrame.lookAt(newCFrame.p, newCFrame.p + Camera.CFrame.LookVector)
                        Camera.CFrame = FreeCamera.CFrame
                    end
                end
            end)
        end
        function FreeCamera:Stop()
            if Connection ~= nil then Connection:Disconnect() Connection = nil end
            Input:Unblock()
            Wheld, Sheld, Aheld, Dheld, Eheld, Qheld = false, false, false, false, false, false
            local Character = LocalPlayer.Character
            if Character then
                local Head, HumanoidRootPart, Humanoid = Character:FindFirstChild("Head"), Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChildOfClass("Humanoid")
                if Head and HumanoidRootPart and Humanoid then
                    Camera.CFrame = CFrame.lookAt(Camera.CFrame.p, Camera.CFrame.p + HumanoidRootPart.CFrame.LookVector)
                    Humanoid.AutoRotate = true
                end
            end
        end
        function FreeCamera:Unload()
            if Connection ~= nil then Connection:Disconnect() Connection = nil end
            Input:Unblock()
            local Character = LocalPlayer.Character
            if Character then
                local HumanoidRootPart, Humanoid = Character:FindFirstChildOfClass("HumanoidRootPart"), Character:FindFirstChildOfClass("Humanoid")
                if HumanoidRootPart and Humanoid then
                    Camera.CFrame = CFrame.lookAt(Camera.CFrame.p, Camera.CFrame.p + HumanoidRootPart.CFrame.LookVector)
                    Humanoid.AutoRotate = true
                end
            end
            Input, FreeCamera, Wheld, Sheld, Aheld, Dheld, Eheld, Qheld, Workspace, Camera, Players, LocalPlayer, RunService, UserInputService, HttpService, Lighting, NetworkClient, Mouse, ContextActionService = nil
        end
        FreeCamera.__index = FreeCamera
    end
end)()
local FOV_Circle = Framework:Draw("Circle", {Radius = Camera.ViewportSize.X / 2, Position = Camera.ViewportSize / 2, Thickness = 1, Transparency = 1, Color = Color3.new(1, 1, 1)})
Flags = Library.flags
local Options = Library.options
if not IonHub_User then
    getgenv().IonHub_User = {
        UID = 0, 
        User = "admin"
    }
end
local Utility, Window, Tabs, Sections, Settings = Library.utility, nil, {}, {}, nil; do
    -- Default Size - UDim2.new(0, 525, 0, 650)
    Window = Library.NewWindow({title = 'IonHub | Project Delta | CRACK BY liam#4567 - OCTOHOOK.XYZ ON TOP', size = UDim2.new(0, 625, 0, 808)})
    Tabs = {
        Settings = Library:CreateSettingsTab(Window),
        Combat = Window:AddTab("Combat"),
        Visuals = Window:AddTab("Visuals"),
        Miscellaneous = Window:AddTab("Miscellaneous"),
        Players = Window:AddTab("Players")
    }
    Sections = {
        Combat = {
            Aimbot = Tabs.Combat:AddSection("Aimbot", 1),
            Silent = Tabs.Combat:AddSection("Silent", 2),
            Modifications = Tabs.Combat:AddSection("Weapon Modifications", 2)
        },
        Visuals = {
            Players = Tabs.Visuals:AddSection("Players", 1),
            Lighting = Tabs.Visuals:AddSection("Lighting", 2),
            Camera = Tabs.Visuals:AddSection("Camera", 1),
            Other = Tabs.Visuals:AddSection("Other", 2),
            ["Inventory Viewer"] = Tabs.Visuals:AddSection("Inventory Viewer", 2),
            Objects = Tabs.Visuals:AddSection("Objects", 1)
        },
        Miscellaneous = {
            LocalPlayer = Tabs.Miscellaneous:AddSection("LocalPlayer", 1),
            Network = Tabs.Miscellaneous:AddSection("Network", 2),
            ["Hit Sound"] = Tabs.Miscellaneous:AddSection("Hit Sound", 2),
            Removals = Tabs.Miscellaneous:AddSection("Removals", 1)
        },
        Players = {
            Players = Tabs.Players:AddSection("Players", 1),
            Server = Tabs.Players:AddSection("Server", 2)
        },
        Settings = {
            Other = Tabs.Settings:AddSection("Other", 2)
        }
    }
end

-- Functions
local tracerDebounce = false
createTracer = LPH_JIT_ULTRA(function(To, From)
    if not tracerDebounce then
        tracerDebounce = true
        spawn(function()
            task.wait()
            tracerDebounce = false
        end)
        local PartTo = Framework:Instance("Part", {Transparency = 1, Position = To, CanCollide = false, Anchored = true, Parent = Camera})
        local PartFrom = Framework:Instance("Part", {Transparency = 1, Position = From, CanCollide = false, Anchored = true, Parent = Camera})
        local Attachment0 = Instance.new("Attachment", PartTo)
        local Attachment1 = Instance.new("Attachment", PartFrom)
        local RaySize = Flags.logsBulletTracerThickness
        local Beam = Framework:Instance("Beam", {FaceCamera = true, Color = ColorSequence.new(Flags.logsBulletTracerColor), Width0 = RaySize, Width1 = RaySize, LightEmission = 1, LightInfluence = 0, Attachment0 = Attachment0, Attachment1 = Attachment1, Parent = PartTo})
        task.spawn(function()
            task.wait(2)
            for i = 0.5, 0, -0.015 do
                Beam.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,1 - i), NumberSequenceKeypoint.new(1,1 - i)})
                RunService.Stepped:Wait()
            end
            PartTo:Destroy()
            PartFrom:Destroy()
        end)
    end
end)

getTarget = LPH_JIT_ULTRA(function()
    if LocalPlayer.Character == nil then return {Predicted = nil, Target = nil, Player = nil} end
    local Player_, Target, Minimal_Mag = nil, nil, math.huge
    for _, Player in pairs(Players:GetPlayers()) do
        if Player == LocalPlayer then continue end
        if Flags.teamCheck and ESP:Get_Team(LocalPlayer) == ESP:Get_Team(Player) then continue end
        local Character = ESP:Get_Character(Player)
        if Character == nil then continue end
        local Head, HumanoidRootPart, Humanoid = Character:FindFirstChild("Head"), Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChildOfClass("Humanoid")
        if not Head or not HumanoidRootPart or not Humanoid or Humanoid.Health <= 0 then continue end
        local aimTo = Flags.aimbotAimTo == "Head" and "Head" or Flags.aimbotAimTo == "Torso" and "HumanoidRootPart" or Flags.aimbotAimTo == "Random" and (math.random(1, 2) == 1 and "Head" or "HumanoidRootPart")
        local aimToPart = Character:FindFirstChild(aimTo)
        if not aimToPart then continue end
        if Flags.aimbotCheckFriend and LocalPlayer:IsFriendsWith(Player.UserId) then continue end
        if Flags.aimbotCheckVisible and not ESP:Check_Visible(aimToPart, true) then continue end
        if Flags.aimbotCheckInvisible then 
            if Head.Transparency == 1 or ReplicatedPlayers[Player.Name].Status.GameplayVariables:GetAttribute("Invisible") == true then continue end
        end
        if Flags.aimbotCheckGod and ReplicatedPlayers[Player.Name].Status.GameplayVariables:GetAttribute("GodMode") == true then continue end
        if Flags.aimbotCheckNoclip then if (Humanoid.RigType == "R15" and Character.UpperTorso.CanCollide == false) or (Humanoid.RigType == "R6" and Character.Torso.CanCollide == false) then continue end end
        local Vector, On_Screen = Camera:WorldToViewportPoint(aimToPart.Position)
        if math.floor(Vector.Z / 3.5714285714 + 0.5) > Flags.aimbotDistance then continue end
        if Flags.aimbotScanMode == "Field of View" then
            local Magnitude = (Vector2.new(Vector.X, Vector.Y) - Camera.ViewportSize / 2).Magnitude
            if On_Screen and Magnitude < Flags.aimbotFoV and Magnitude < Minimal_Mag then
                Minimal_Mag = Magnitude
                Target = aimToPart
                Player_ = Player
            end
        else
            Target = aimToPart
            Player_ = Player
        end
    end
    return {
        Predicted = Target and Target.Position + Target.Velocity * ((Flags.aimbotPrediction and Flags.aimbotPredictionMultiplier) or 0) or nil,
        Target = Target,
        Player = Player_
    }
end)

MouseButton1Click = LPH_JIT_ULTRA(function(delay)
    if not Library.open then
        IsClicking = true
        if Library.open == false and Library.opening == false then
            if delay ~= nil then
                mouse1press()
                task.wait(delay)
                mouse1release()
            else
                mouse1press()
                mouse1release()
            end
            IsClicking = false
        end
    end
end)

-- Combat - Aimbot
Sections.Combat.Aimbot:AddToggle({text = "Enabled", tooltip = "Enables the aimbot.", flag = "aimbotEnabled", callback = function(State)
    for _, option in pairs(Sections.Combat.Aimbot.options) do
        if option.flag == "aimbotEnabled" then continue end
        if option.flag == "aimbotAutoFireNoLags" then
            if Flags.aimbotAutoFire then
                if State then
                    option.enabled = State
                else
                    option.enabled = State
                end
            else
                if not State then
                    option.enabled = State
                end
            end
            continue
        end
        if option.risky ~= nil then
            option.enabled = State
        end
    end
    Sections.Combat.Aimbot:UpdateOptions()
    Tabs.Combat:UpdateSections()
end}):AddBind({text = "Aimbot", flag = "aimbotEnabledBind", tooltip = "Enables the aimbot only when this key is held. Select BACKSPACE to make aimbot always aim.", mode = "hold"})

Sections.Combat.Aimbot:AddToggle({text = "Silent", flag = "aimbotSilent", tooltip = "Makes it so the aimbot's snapping is invisible. Also changes bullet trajectory if proper Function selected (More accurate aiming).", enabled = false, risky = true})

Sections.Combat.Aimbot:AddToggle({text = "Auto Fire", flag = "aimbotAutoFire", tooltip = "Automatically fires the weapon.", enabled = false, callback = function(State)
    Options.aimbotAutoFireNoLags.enabled = State
    Options.aimbotAutoFire:UpdateOptions()
    Tabs.Combat:UpdateSections()
end})

Sections.Combat.Aimbot:AddToggle({text = "Auto Fire Disable Fake Lag", flag = "aimbotAutoFireNoLags", tooltip = "Disables fake lags on auto firing.", enabled = false})

Sections.Combat.Aimbot:AddSlider({text = "Aim Speed", flag = "aimbotSpeed", enabled = false, min = 0.001, max = 1, value = 1, increment = 0.001})

Sections.Combat.Aimbot:AddList({text = "Part", flag = "aimbotAimTo", tooltip = "Makes the aimbot target a specific body part.", enabled = false, selected = "Head", values = {"Head", "Torso", "Random"}})

Sections.Combat.Aimbot:AddSlider({text = "Field of View", flag = "aimbotFoV", tooltip = "Makes the aimbot only target players who are withing the selected field of view.", enabled = false, min = 0, max = Camera.ViewportSize.X / 2 + 200, value = Camera.ViewportSize.X / 2, callback = function(Value)
    FOV_Circle.Radius = Value
end})

Sections.Combat.Aimbot:AddSlider({text = "Distance", flag = "aimbotDistance", tooltip = "Makes the aimbot only target players who are withing the selected distance.", enabled = false, min = 0, max = 5000, value = 1000, suffix = "m"})

Sections.Combat.Aimbot:AddToggle({text = "Target Lock", tooltip = "Makes the aimbot aim at one target unless dead.", flag = "aimbotLockTarget", enabled = false})

Sections.Combat.Aimbot:AddList({text = "Target Mode", flag = "aimbotScanMode", tooltip = "Changes how aimbot will find a new target. Cycle checks all players, ignores field of view.", enabled = false, selected = "Field of View", values = {"Cycle", "Field of View"}})

Sections.Combat.Aimbot:AddToggle({text = "Prediction", flag = "aimbotPrediction", tooltip = "Makes the aimbot velocity predict the current target. Silent aimbot ignores this.", enabled = false, callback = function(State)
    Options.aimbotPredictionMultiplier.enabled = State
    Options.aimbotPrediction:UpdateOptions()
    Tabs.Combat:UpdateSections()
end}):AddSlider({flag = "aimbotPredictionMultiplier", tooltip = "Changes velocity prediction strength.", enabled = false, min = 0, max = 0.4, increment = 0.001, value = 0.15})

Sections.Combat.Aimbot:AddToggle({text = "Friend Check", flag = "aimbotCheckFriend", tooltip = "Makes the aimbot don't target roblox friends.", enabled = false})

Sections.Combat.Aimbot:AddToggle({text = "Visible Check", flag = "aimbotCheckVisible", tooltip = "Makes the aimbot don't target invisible players.", enabled = false})

Sections.Combat.Aimbot:AddToggle({text = "Invisible Check", flag = "aimbotCheckInvisible", tooltip = "Makes the aimbot don't target transparent players (Admins).", enabled = false})

Sections.Combat.Aimbot:AddToggle({text = "God Mode Check", flag = "aimbotCheckGod", tooltip = "Makes the aimbot don't target players in god mode (Admins).", enabled = false})

Sections.Combat.Aimbot:AddToggle({text = "Noclip Check", flag = "aimbotCheckNoclip", tooltip = "Makes the aimbot don't target noclipping players (Admins).", enabled = false})

Utility:Connection(RunService.RenderStepped, LPH_JIT_ULTRA(function()
    if not Flags.aimbotEnabled or not Flags.aimbotEnabledBind then
        ESP.Settings.Highlight.Target = nil
        return 
    end
    if Flags.aimbotLockTarget then
        if Aimbot.Target ~= nil then
            if not Flags.aimbotEnabledBind then
                Aimbot = getTarget()
            end
        end
    else
        Aimbot = getTarget()
    end
    ESP.Settings.Highlight.Target = (Aimbot.Player ~= nil and ESP:Get_Character(Aimbot.Player)) or nil
    if Flags.aimbotSilent then
        if not Flags.aimbotEnabledBind then return end
        if Flags.aimbotAutoFire and Aimbot.Target then
            if Flags.aimbotAutoFireNoLags then
                NetworkClient:SetOutgoingKBPSLimit(math.huge)
            end
            IsClicking = true
            MouseButton1Click(Flags.betweenClickTime)
            IsClicking = false
        end
        return
    end
    if Aimbot.Target then
        Camera.CFrame = Flags.aimbotSpeed < 1 and Camera.CFrame:lerp(CFrame.lookAt(Camera.CFrame.p, Aimbot.Predicted), Flags.aimbotSpeed) or CFrame.lookAt(Camera.CFrame.p, Aimbot.Predicted)
        if Flags.aimbotAutoFire then
            local Vector, On_Screen = Camera:WorldToViewportPoint(Aimbot.Predicted)
            local MouseLocation = UserInputService:GetMouseLocation()
            local Magnitude = (Vector2.new(Vector.X, Vector.Y) - MouseLocation).Magnitude
            if On_Screen and Magnitude <= 2 then
                if Flags.aimbotAutoFireNoLags then
                    NetworkClient:SetOutgoingKBPSLimit(math.huge)
                end
                IsClicking = true
                MouseButton1Click(Flags.betweenClickTime)
                IsClicking = false
            end
        end
    end
end))

-- Combat - Silent
Sections.Combat.Silent:AddSlider({text = "Miss Chance", flag = "silentMissChance", min = 0, max = 100, suffix = "%"})

-- Combat - Weapon Modifications
Sections.Combat.Modifications:AddToggle({text = "Enabled", flag = "modsEnabled", tooltip = "Enables weapon modifications.", callback = function(State)
    for _, option in pairs(Sections.Combat.Modifications.options) do
        if option.flag == "modsEnabled" then continue end
        if option.risky ~= nil then
            option.enabled = State
        end
    end
    Sections.Combat.Modifications:UpdateOptions()
    Tabs.Combat:UpdateSections()
end})
Sections.Combat.Modifications:AddToggle({text = "No Recoil", flag = "modsNoRecoil", tooltip = "Removes weapon recoil.", enabled = false})
Sections.Combat.Modifications:AddToggle({text = "No Camera Bob", flag = "modsNoBob", tooltip = "Removes camera bobbing.", enabled = false})
Sections.Combat.Modifications:AddToggle({text = "Custom Viewmodel", flag = "modsCustomViewmodel", tooltip = "Changes weapon viewmodel position.", enabled = false, callback = function(State)
    Options.modsCustomViewmodelZ.enabled = State
    Options.modsCustomViewmodelY.enabled = State
    Options.modsCustomViewmodelX.enabled = State
    Options.modsCustomViewmodel:UpdateOptions()
    Tabs.Combat:UpdateSections()
end})
Options.modsCustomViewmodel:AddSlider({flag = "modsCustomViewmodelZ", tooltip = "Viewmodel position coordinate Z.", enabled = false, min = -5, max = 5, value = 0, increment = 0.01})
Options.modsCustomViewmodel:AddSlider({flag = "modsCustomViewmodelY", tooltip = "Viewmodel position coordinate Y.", enabled = false, min = -5, max = 5, value = 0, increment = 0.01})
Options.modsCustomViewmodel:AddSlider({flag = "modsCustomViewmodelX", tooltip = "Viewmodel position coordinate X.", enabled = false, min = -5, max = 5, value = 0, increment = 0.01})

-- Visuals - Players
Sections.Visuals.Players:AddToggle({text = "Enabled", flag = "plrEspEnabled", tooltip = "Enables the player ESP.", callback = function(State)
    for _, option in pairs(Sections.Visuals.Players.options) do
        if option.flag == "plrEspEnabled" then continue end
        if option.flag == "plrEspBoxOutline" then
            if Flags.plrEspBox then
                if State then
                    option.enabled = State
                else
                    option.enabled = State
                end
            else
                if not State then
                    option.enabled = State
                end
            end
            continue
        end
        if option.risky ~= nil then
            option.enabled = State
        end
    end
    Sections.Visuals.Players:UpdateOptions()
    Tabs.Visuals:UpdateSections()
    ESP:Toggle(State)
end})

Sections.Visuals.Players:AddToggle({text = "Highlight Target", flag = "plrEspHighlight", tooltip = "Highlights current aimbot target.", enabled = false, callback = function(State)
    ESP.Settings.Highlight.Enabled = State
    Options.plrEspHighlightColor.enabled = State
    Options.plrEspHighlight:UpdateOptions()
    Tabs.Visuals:UpdateSections()
end})
Options.plrEspHighlight:AddColor({text = "Highlight Color", flag = "plrEspHighlightColor", enabled = false, color = Color3.new(1, 0, 0), callback = function(Color)
    ESP.Settings.Highlight.Color = Color
end})

Sections.Visuals.Players:AddToggle({text = "Box", flag = "plrEspBox", tooltip = "Draw a bounding box around the player.", enabled = false, callback = function(State)
    ESP.Settings.Box.Enabled = State
    Options.plrEspBoxOutline.enabled = State
    Options.plrEspBoxColor.enabled = State
    Options.plrEspBox:UpdateOptions()
    Sections.Visuals.Players:UpdateOptions()
    Tabs.Visuals:UpdateSections()
end})
Options.plrEspBox:AddColor({text = "Box Color", flag = "plrEspBoxColor", enabled = false, callback = function(Color, Transparency)
    ESP.Settings.Box.Color = Color
    ESP.Settings.Box.Transparency = Transparency
end})

Sections.Visuals.Players:AddToggle({text = "Box Outline", flag = "plrEspBoxOutline", tooltip = "Draw outline around box.", enabled = false, callback = function(State)
    ESP.Settings.Box_Outline.Enabled = State
    Options.plrEspBoxOutlineColor.enabled = State
    Options.plrEspBoxOutline:UpdateOptions()
    Tabs.Visuals:UpdateSections()
end})
Options.plrEspBoxOutline:AddColor({text = "Box Outline Color", flag = "plrEspBoxOutlineColor", enabled = false, color = Color3.new(0, 0, 0), callback = function(Color, Transparency)
    ESP.Settings.Box_Outline.Color = Color
    ESP.Settings.Box_Outline.Transparency = Transparency
end})

Sections.Visuals.Players:AddToggle({text = "Healthbar", flag = "plrEspHpBar", tooltip = "Show player's health amount with a bar on ESP.", enabled = false, callback = function(State)
    ESP.Settings.Healthbar.Enabled = State
    Options.plrEspHpBarColor.enabled = State
    Options.plrEspHpBarPos.enabled = State
    Options.plrEspHpBar:UpdateOptions()
    Tabs.Visuals:UpdateSections()
end})
Options.plrEspHpBar:AddColor({text = "Healthbar Color", flag = "plrEspHpBarColor", enabled = false, color = Color3.fromRGB(40, 252, 3), callback = function(Color)
    ESP.Settings.Healthbar.Color_Lerp = Color
end})
Options.plrEspHpBar:AddList({flag = "plrEspHpBarPos", tooltip = "Position of healthbar towards to the box.", enabled = false, selected = "Left", values = {"Top", "Bottom", "Left", "Right"}, callback = function(Position)
    ESP.Settings.Healthbar.Position = Position
end})

Sections.Visuals.Players:AddToggle({text = "Name", flag = "plrEspName", tooltip = "Show player's name on ESP.", enabled = false, callback = function(State)
    ESP.Settings.Name.Enabled = State
    Options.plrEspNameColor.enabled = State
    Options.plrEspNamePos.enabled = State
    Options.plrEspName:UpdateOptions()
    Tabs.Visuals:UpdateSections()
end})
Options.plrEspName:AddColor({text = "Name Color", flag = "plrEspNameColor", enabled = false, callback = function(Color, Transparency)
    ESP.Settings.Name.Color = Color
    ESP.Settings.Name.Transparency = Transparency
end})
Options.plrEspName:AddList({flag = "plrEspNamePos", tooltip = "Position of name drawing towards to the box.", enabled = false, selected = "Top", values = {"Top", "Bottom", "Left", "Right"}, callback = function(Position)
    ESP.Settings.Name.Position = Position
end})

Sections.Visuals.Players:AddToggle({text = "Distance", flag = "plrEspDist", tooltip = "Show player's distance from you on ESP.", enabled = false, callback = function(State)
    ESP.Settings.Distance.Enabled = State
    Options.plrEspDistColor.enabled = State
    Options.plrEspDistPos.enabled = State
    Options.plrEspDist:UpdateOptions()
    Tabs.Visuals:UpdateSections()
end})
Options.plrEspDist:AddColor({text = "Distance Color", flag = "plrEspDistColor", enabled = false, callback = function(Color, Transparency)
    ESP.Settings.Distance.Color = Color
    ESP.Settings.Distance.Transparency = Transparency
end})
Options.plrEspDist:AddList({flag = "plrEspDistPos", tooltip = "Position of distance drawing towards to the box.", enabled = false, selected = "Bottom", values = {"Top", "Bottom", "Left", "Right"}, callback = function(Position)
    ESP.Settings.Distance.Position = Position
end})

Sections.Visuals.Players:AddToggle({text = "Tool", flag = "plrEspTool", tooltip = "Show player's held tool on ESP.", enabled = false, callback = function(State)
    ESP.Settings.Tool.Enabled = State
    Options.plrEspToolColor.enabled = State
    Options.plrEspToolPos.enabled = State
    Options.plrEspTool:UpdateOptions()
    Tabs.Visuals:UpdateSections()
end})
Options.plrEspTool:AddColor({text = "Tool Color", flag = "plrEspToolColor", enabled = false, callback = function(Color, Transparency)
    ESP.Settings.Tool.Color = Color
    ESP.Settings.Tool.Transparency = Transparency
end})
Options.plrEspTool:AddList({flag = "plrEspToolPos", tooltip = "Position of tool drawing towards to the box", enabled = false, selected = "Right", values = {"Top", "Bottom", "Left", "Right"}, callback = function(Position)
    ESP.Settings.Tool.Position = Position
end})

Sections.Visuals.Players:AddToggle({text = "Health", flag = "plrEspHp", tooltip = "Show player's health amount with text on ESP.", enabled = false, callback = function(State)
    ESP.Settings.Health.Enabled = State
    Options.plrEspHpColor.enabled = State
    Options.plrEspHpPos.enabled = State
    Options.plrEspHp:UpdateOptions()
    Tabs.Visuals:UpdateSections()
end})
Options.plrEspHp:AddColor({text = "Health Color", flag = "plrEspHpColor", enabled = false, callback = function(Color, Transparency)
    ESP.Settings.Health.Color = Color
    ESP.Settings.Health.Transparency = Transparency
end})
Options.plrEspHp:AddList({flag = "plrEspHpPos", tooltip = "Position of health drawing towards to the box.", enabled = false, selected = "Right", values = {"Top", "Bottom", "Left", "Right"}, callback = function(Position)
    ESP.Settings.Health.Position = Position
end})

Sections.Visuals.Players:AddToggle({text = "Chams", flag = "plrEspChams", tooltip = "Applies Chams material to the player.", enabled = false, callback = function(State)
    ESP.Settings.Chams.Enabled = State
    Options.plrEspChamsOutCol.enabled = State
    Options.plrEspChamsColor.enabled = State
    Options.plrEspChamsMode.enabled = State
    Options.plrEspChams:UpdateOptions()
    Tabs.Visuals:UpdateSections()
end})
Options.plrEspChams:AddColor({text = "Chams Color", flag = "plrEspChamsColor", tooltip = "Color of Chams", enabled = false, trans = 0.5, callback = function(Color, Transparency)
    ESP.Settings.Chams.Color = Color
    ESP.Settings.Chams.Transparency = Transparency
end})
Options.plrEspChams:AddColor({text = "Chams Outline Color", flag = "plrEspChamsOutCol", tooltip = "Color of Chams outline", enabled = false, color = Color3.new(0, 0, 0), callback = function(Color, Transparency)
    ESP.Settings.Chams.OutlineColor = Color
    ESP.Settings.Chams.OutlineTransparency = Transparency
end})
Options.plrEspChams:AddList({flag = "plrEspChamsMode", tooltip = "Chams color mode", enabled = false, selected = "Visible", values = {"Standard", "Visible"}, callback = function(Mode)
    ESP.Settings.Chams.Mode = Mode
end})

Sections.Visuals.Players:AddList({text = "Image", flag = "plrEspImage", enabled = false, selected = "None", values = {"None", "Taxi", "Gorilla", "Saul Goodman", "Peter Griffin", "John Herbert", "Fortnite"}, callback = function(Value)
    if Value == "None" then
        ESP.Settings.Image.Enabled = false
    else
        ESP.Settings.Image.enabled = false
        ESP.Settings.Image.Image = Value
        ESP:UpdateImages()
    end
end})

Sections.Visuals.Players:AddSlider({text = "Draw Distance", flag = "plrEspDrawDistance", enabled = false, suffix = "m", min = 1, max = 5000, value = 1000, callback = function(Value)
    ESP.Settings.Maximal_Distance = Value
end})

Sections.Visuals.Players:AddToggle({text = "Bold Text", flag = "plrEspBold", enabled = false, callback = function(State)
    ESP.Settings.Bold_Text = State
end})

LPH_JIT_ULTRA(function()
    for _, Player in pairs(Players:GetPlayers()) do
        if Player == LocalPlayer then continue end
        ESP:Player(Player)
    end
end)()

-- Visuals - Lighting
local Sky = Lighting:FindFirstChildOfClass("Sky")
if not Sky then
    Sky = Framework:Instance("Sky", {Parent = Lighting})
end
local SkyBoxes = {
    ["Standard"] = {
        ["SkyboxBk"] = Sky.SkyboxBk,
        ["SkyboxDn"] = Sky.SkyboxDn,
        ["SkyboxFt"] = Sky.SkyboxFt,
        ["SkyboxLf"] = Sky.SkyboxLf,
        ["SkyboxRt"] = Sky.SkyboxRt,
        ["SkyboxUp"] = Sky.SkyboxUp,
    },
    ["Among Us"] = {
        ["SkyboxBk"] = "rbxassetid://5752463190",
        ["SkyboxDn"] = "rbxassetid://5752463190",
        ["SkyboxFt"] = "rbxassetid://5752463190",
        ["SkyboxLf"] = "rbxassetid://5752463190",
        ["SkyboxRt"] = "rbxassetid://5752463190",
        ["SkyboxUp"] = "rbxassetid://5752463190"
    },
    ["Neptune"] = {
        ["SkyboxBk"] = "rbxassetid://218955819",
        ["SkyboxDn"] = "rbxassetid://218953419",
        ["SkyboxFt"] = "rbxassetid://218954524",
        ["SkyboxLf"] = "rbxassetid://218958493",
        ["SkyboxRt"] = "rbxassetid://218957134",
        ["SkyboxUp"] = "rbxassetid://218950090"
    },
    ["Aesthetic Night"] = {
        ["SkyboxBk"] = "rbxassetid://1045964490",
        ["SkyboxDn"] = "rbxassetid://1045964368",
        ["SkyboxFt"] = "rbxassetid://1045964655",
        ["SkyboxLf"] = "rbxassetid://1045964655",
        ["SkyboxRt"] = "rbxassetid://1045964655",
        ["SkyboxUp"] = "rbxassetid://1045962969"
    },
    ["Redshift"] = {
        ["SkyboxBk"] = "rbxassetid://401664839",
        ["SkyboxDn"] = "rbxassetid://401664862",
        ["SkyboxFt"] = "rbxassetid://401664960",
        ["SkyboxLf"] = "rbxassetid://401664881",
        ["SkyboxRt"] = "rbxassetid://401664901",
        ["SkyboxUp"] = "rbxassetid://401664936"
    },
}
Sections.Visuals.Lighting:AddToggle({text = "Enabled", flag = "lightingEnabled", tooltip = "Enables lighting modifications.", callback = function(State)
    if State then
        if Flags.lightingAmbient then
            Lighting.Ambient = Flags.lightingAmbientAmnt
        end
        if Flags.lightingBrightness then
            Lighting.Brightness = Flags.lightingBrightnessAmnt
        end
        if Flags.lightingColorShift_Bottom then
            Lighting.ColorShift_Bottom = Flags.lightingColorShift_BottomAmnt
        end
        if Flags.lightingColorShift_Top then
            Lighting.ColorShift_Top = Flags.lightingColorShift_TopAmnt
        end
        if Flags.lightingEnvironmentDiffuseScale then
            Lighting.EnvironmentDiffuseScale = Flags.lightingEnvironmentDiffuseScaleAmnt
        end
        if Flags.lightingEnvironmentSpecularScale then
            Lighting.EnvironmentSpecularScale = Flags.lightingEnvironmentSpecularScaleAmnt
        end
        if Flags.lightingGlobalShadows then
            Lighting.GlobalShadows = Flags.lightingGlobalShadows
        end
        if Flags.lightingOutdoorAmbient then
            Lighting.OutdoorAmbient = Flags.lightingOutdoorAmbientAmnt
        end
        if Flags.lightingTechnology then
            sethiddenproperty(Lighting, "Technology", Flags.lightingTechnologyAmnt)
        end
        if Flags.lightingDecoration then
            sethiddenproperty(Terrain, "Decoration", not Flags.lightingDecoration)
        end
        if Flags.lightingClockTime then
            Lighting.ClockTime = Flags.lightingClockTimeAmnt
        end
        if Flags.lightingExposureCompensation then
            Lighting.ExposureCompensation = Flags.lightingExposureCompensationAmnt
        end
        for Index, Asset in pairs(SkyBoxes[Flags.lightingSky]) do
            Sky[Index] = Asset
        end
    else
        for Property, Value in pairs(Old_Lighting) do
            pcall(function()
                Lighting[Property] = Value
                if Property == "Technology" then
                    sethiddenproperty(Lighting, "Technology", Old_Lighting.Technology)
                end
            end)
        end
        for Index, Asset in pairs(SkyBoxes.Standard) do
            Sky[Index] = Asset
        end
        sethiddenproperty(Terrain, "Decoration", Old_Decoration)
    end
    for _, option in pairs(Sections.Visuals.Lighting.options) do
        if option.flag == "lightingEnabled" then continue end
        if option.risky ~= nil then
            option.enabled = State
        end
    end
    Sections.Visuals.Lighting:UpdateOptions()
    Tabs.Visuals:UpdateSections()
    ESP:Toggle(State)
end})

Sections.Visuals.Lighting:AddToggle({text = "Ambient", flag = "lightingAmbient", enabled = false, callback = function(State)
    if State and Flags.lightingEnabled then
        Lighting.Ambient = Flags.lightingAmbientAmnt
    else
        Lighting.Ambient = Old_Lighting.Ambient
    end
    Options.lightingAmbientAmnt.enabled = State
    Options.lightingAmbient:UpdateOptions()
    Tabs.Visuals:UpdateSections()
end})
Options.lightingAmbient:AddColor({text = "Ambient Color", flag = "lightingAmbientAmnt", enabled = false, color = Old_Lighting.Ambient, callback = function(Color)
    if Flags.lightingEnabled and Flags.lightingAmbient then
        Lighting.Ambient = Color
    end
end})
Utility:Connection(Lighting:GetPropertyChangedSignal("Ambient"), LPH_JIT_ULTRA(function()
    if Flags.lightingEnabled and Flags.lightingAmbient then
        Lighting.Ambient = Flags.lightingAmbientAmnt
    end
end))

Sections.Visuals.Lighting:AddToggle({text = "Brightness", flag = "lightingBrightness", enabled = false, callback = function(State)
    if State and Flags.lightingEnabled then
        Lighting.Brightness = Flags.lightingBrightnessAmnt
    else
        Lighting.Brightness = Old_Lighting.Brightness
    end
    Options.lightingBrightnessAmnt.enabled = State
    Options.lightingBrightness:UpdateOptions()
    Tabs.Visuals:UpdateSections()
end})
Options.lightingBrightness:AddSlider({flag = "lightingBrightnessAmnt", enabled = false, min = 0, max = 10, increment = 0.01, value = Old_Lighting.Brightness, callback = function(Value)
    if Flags.lightingEnabled and Flags.lightingBrightness then
        Lighting.Brightness = Value
    end
end})
Utility:Connection(Lighting:GetPropertyChangedSignal("Brightness"), LPH_JIT_ULTRA(function()
    if Flags.lightingEnabled and Flags.lightingBrightness then
        Lighting.Brightness = Flags.lightingBrightnessAmnt
    end
end))

Sections.Visuals.Lighting:AddToggle({text = "ColorShift Bottom", flag = "lightingColorShift_Bottom", enabled = false, callback = function(State)
    if State and Flags.lightingEnabled then
        Lighting.ColorShift_Bottom = Flags.lightingColorShift_BottomAmnt
    else
        Lighting.ColorShift_Bottom = Old_Lighting.ColorShift_Bottom
    end
    Options.lightingColorShift_BottomAmnt.enabled = State
    Options.lightingColorShift_Bottom:UpdateOptions()
    Tabs.Visuals:UpdateSections()
end})
Options.lightingColorShift_Bottom:AddColor({text = "ColorShift Bottom Color", flag = "lightingColorShift_BottomAmnt", enabled = false, color = Old_Lighting.ColorShift_Bottom, callback = function(Color)
    if Flags.lightingEnabled and Flags.lightingColorShift_Bottom then
        Lighting.ColorShift_Bottom = Color
    end
end})
Utility:Connection(Lighting:GetPropertyChangedSignal("ColorShift_Bottom"), LPH_JIT_ULTRA(function()
    if Flags.lightingEnabled and Flags.lightingColorShift_Bottom then
        Lighting.ColorShift_Bottom = Flags.lightingColorShift_BottomAmnt
    end
end))

Sections.Visuals.Lighting:AddToggle({text = "ColorShift Top", flag = "lightingColorShift_Top", enabled = false, callback = function(State)
    if State and Flags.lightingEnabled then
        Lighting.ColorShift_Top = Flags.lightingColorShift_TopAmnt
    else
        Lighting.ColorShift_Top = Old_Lighting.ColorShift_Top
    end
    Options.lightingColorShift_TopAmnt.enabled = State
    Options.lightingColorShift_Top:UpdateOptions()
    Tabs.Visuals:UpdateSections()
end})
Options.lightingColorShift_Top:AddColor({text = "ColorShift Top Color", flag = "lightingColorShift_TopAmnt", enabled = false, color = Old_Lighting.ColorShift_Top, callback = function(Color)
    if Flags.lightingEnabled and Flags.lightingColorShift_Top then
        Lighting.ColorShift_Top = Color
    end
end})
Utility:Connection(Lighting:GetPropertyChangedSignal("ColorShift_Top"), LPH_JIT_ULTRA(function()
    if Flags.lightingEnabled and Flags.lightingColorShift_Top then
        Lighting.ColorShift_Top = Flags.lightingColorShift_TopAmnt
    end
end))

Sections.Visuals.Lighting:AddToggle({text = "Diffuse Scale", flag = "lightingEnvironmentDiffuseScale", enabled = false, callback = function(State)
    if State and Flags.lightingEnabled then
        Lighting.EnvironmentDiffuseScale = Flags.lightingEnvironmentDiffuseScaleAmnt
    else
        Lighting.EnvironmentDiffuseScale = Old_Lighting.EnvironmentDiffuseScale
    end
    Options.lightingEnvironmentDiffuseScaleAmnt.enabled = State
    Options.lightingEnvironmentDiffuseScale:UpdateOptions()
    Tabs.Visuals:UpdateSections()
end})
Options.lightingEnvironmentDiffuseScale:AddSlider({flag = "lightingEnvironmentDiffuseScaleAmnt", enabled = false, min = 0, max = 1, increment = 0.001, value = Old_Lighting.EnvironmentDiffuseScale, callback = function(Value)
    if Flags.lightingEnabled and Flags.lightingEnvironmentDiffuseScale then
        Lighting.EnvironmentDiffuseScale = Value
    end
end})
Utility:Connection(Lighting:GetPropertyChangedSignal("EnvironmentDiffuseScale"), LPH_JIT_ULTRA(function()
    if Flags.lightingEnabled and Flags.lightingEnvironmentDiffuseScale then
        Lighting.EnvironmentDiffuseScale = Flags.lightingEnvironmentDiffuseScaleAmnt
    end
end))

Sections.Visuals.Lighting:AddToggle({text = "Specular Scale", flag = "lightingEnvironmentSpecularScale", enabled = false, callback = function(State)
    if State and Flags.lightingEnabled then
        Lighting.EnvironmentSpecularScale = Flags.lightingEnvironmentSpecularScaleAmnt
    else
        Lighting.EnvironmentSpecularScale = Old_Lighting.EnvironmentSpecularScale
    end
    Options.lightingEnvironmentSpecularScaleAmnt.enabled = State
    Options.lightingEnvironmentSpecularScale:UpdateOptions()
    Tabs.Visuals:UpdateSections()
end})
Options.lightingEnvironmentSpecularScale:AddSlider({flag = "lightingEnvironmentSpecularScaleAmnt", enabled = false, min = 0, max = 1, increment = 0.001, value = Old_Lighting.EnvironmentSpecularScale, callback = function(Value)
    if Flags.lightingEnabled and Flags.lightingEnvironmentSpecularScale then
        Lighting.EnvironmentSpecularScale = Value
    end
end})
Utility:Connection(Lighting:GetPropertyChangedSignal("EnvironmentSpecularScale"), LPH_JIT_ULTRA(function()
    if Flags.lightingEnabled and Flags.lightingEnvironmentSpecularScale then
        Lighting.EnvironmentSpecularScale = Flags.lightingEnvironmentSpecularScaleAmnt
    end
end))

Sections.Visuals.Lighting:AddToggle({text = "Global Shadows", flag = "lightingGlobalShadows", enabled = false, callback = function(State)
    if State then
        if Flags.lightingEnabled then
            Lighting.GlobalShadows = State
        end
    else
        Lighting.GlobalShadows = Old_Lighting.GlobalShadows
    end
end}):SetState(Old_Lighting.GlobalShadows)
Utility:Connection(Lighting:GetPropertyChangedSignal("GlobalShadows"), LPH_JIT_ULTRA(function()
    if Flags.lightingEnabled and Flags.lightingGlobalShadows then
        Lighting.GlobalShadows = Flags.lightingGlobalShadows
    end
end))

Sections.Visuals.Lighting:AddToggle({text = "Outdoor Ambient", flag = "lightingOutdoorAmbient", enabled = false, callback = function(State)
    if State and Flags.lightingEnabled then
        Lighting.OutdoorAmbient = Flags.lightingOutdoorAmbientAmnt
    else
        Lighting.OutdoorAmbient = Old_Lighting.OutdoorAmbient
    end
    Options.lightingOutdoorAmbientAmnt.enabled = State
    Options.lightingOutdoorAmbient:UpdateOptions()
    Tabs.Visuals:UpdateSections()
end})
Options.lightingOutdoorAmbient:AddColor({text = "Outdoor Ambient Color", flag = "lightingOutdoorAmbientAmnt", enabled = false, color = Old_Lighting.OutdoorAmbient, callback = function(Color)
    if Flags.lightingEnabled and Flags.lightingOutdoorAmbient then
        Lighting.OutdoorAmbient = Color
    end
end})
Utility:Connection(Lighting:GetPropertyChangedSignal("OutdoorAmbient"), LPH_JIT_ULTRA(function()
    if Flags.lightingEnabled and Flags.lightingOutdoorAmbient then
        Lighting.OutdoorAmbient = Flags.lightingOutdoorAmbientAmnt
    end
end))

Sections.Visuals.Lighting:AddToggle({text = "Technology", flag = "lightingTechnology", enabled = false, callback = function(State)
    if State and Flags.lightingEnabled then
        sethiddenproperty(Lighting, "Technology", Flags.lightingTechnologyAmnt)
    else
        sethiddenproperty(Lighting, "Technology", Old_Lighting.Technology)
    end
    Options.lightingTechnologyAmnt.enabled = State
    Options.lightingTechnology:UpdateOptions()
    Tabs.Visuals:UpdateSections()
end})
Options.lightingTechnology:AddList({flag = "lightingTechnologyAmnt", enabled = false, selected = tostring(Old_Lighting.Technology):sub(17), values = {"Future", "ShadowMap", "Voxel", "Compatibility"}, callback = function(Technology)
    if Flags.lightingEnabled and Flags.lightingTechnology then
        sethiddenproperty(Lighting, "Technology", Technology)
    end
end})

Sections.Visuals.Lighting:AddToggle({text = "Decoration", flag = "lightingDecoration", enabled = false, callback = function(State)
    if Flags.lightingEnabled then
        sethiddenproperty(Terrain, "Decoration", State)
    end
end}):SetState(Old_Decoration)

Sections.Visuals.Lighting:AddToggle({text = "Time", flag = "lightingClockTime", enabled = false, callback = function(State)
    if State and Flags.lightingEnabled then
        Lighting.ClockTime = Flags.lightingClockTimeAmnt
    else
        Lighting.ClockTime = Old_Lighting.ClockTime
    end
    Options.lightingClockTimeAmnt.enabled = State
    Options.lightingClockTime:UpdateOptions()
    Tabs.Visuals:UpdateSections()
end})
Options.lightingClockTime:AddSlider({flag = "lightingClockTimeAmnt", enabled = false, suffix = "h", min = 0, max = 23.99, increment = 0.01, value = Old_Lighting.ClockTime, callback = function(Value)
    if Flags.lightingEnabled and Flags.lightingClockTime then
        Lighting.ClockTime = Value
    end
end})
Utility:Connection(Lighting:GetPropertyChangedSignal("ClockTime"), LPH_JIT_ULTRA(function()
    if Flags.lightingEnabled and Flags.lightingClockTime then
        Lighting.ClockTime = Flags.lightingClockTimeAmnt
    end
end))

Sections.Visuals.Lighting:AddToggle({text = "Exposure Compensation", flag = "lightingExposureCompensation", enabled = false, callback = function(State)
    if State and Flags.lightingEnabled then
        Lighting.ExposureCompensation = Flags.lightingExposureCompensationAmnt
    else
        Lighting.ExposureCompensation = Old_Lighting.ExposureCompensation
    end
    Options.lightingExposureCompensationAmnt.enabled = State
    Options.lightingExposureCompensation:UpdateOptions()
    Tabs.Visuals:UpdateSections()
end})
Options.lightingExposureCompensation:AddSlider({flag = "lightingExposureCompensationAmnt", enabled = false, min = -3, max = 3, increment = 0.001, value = Old_Lighting.ExposureCompensation, callback = function(Value)
    if Flags.lightingEnabled and Flags.lightingExposureCompensation then
        Lighting.ExposureCompensation = Value
    end
end})
Utility:Connection(Lighting:GetPropertyChangedSignal("ExposureCompensation"), LPH_JIT_ULTRA(function()
    if Flags.lightingEnabled and Flags.lightingExposureCompensation then
        Lighting.ExposureCompensation = Flags.lightingExposureCompensationAmnt
    end
end))

Sections.Visuals.Lighting:AddList({text = "Sky", flag = "lightingSky", enabled = false, selected = "Standard", values = {"Standard", "Among Us", "Neptune", "Aesthetic Night", "Redshift"}, callback = function(Value)
    if Flags.lightingEnabled then
        for Index, Asset in pairs(SkyBoxes[Value]) do
            Sky[Index] = Asset
        end
    end
end})

-- Visuals - Camera
Sections.Visuals.Camera:AddToggle({text = "Field of View", flag = "cameraFoV", callback = function(State)
    if State then
        Camera.FieldOfView = Flags.cameraFoVValue
    else
        Camera.FieldOfView = Old_Camera.FieldOfView
    end
    Options.cameraFoVValue.enabled = State
    Options.cameraFoV:UpdateOptions()
    Tabs.Visuals:UpdateSections()
end})
Options.cameraFoV:AddSlider({flag = "cameraFoVValue", enabled = false, suffix = "Â°", min = 1, max = 120, value = Old_Camera.FieldOfView, callback = function(Value)
    if Flags.cameraFoV then
        Camera.FieldOfView = Value
    end
end})

Sections.Visuals.Camera:AddToggle({text = "Zoom", flag = "cameraZoom", callback = function(State)
    if State then
        Camera.FieldOfView = Flags.cameraZoomValue
    else
        Camera.FieldOfView = Old_Camera.FieldOfView
    end
    Options.cameraZoomValue.enabled = State
    Options.cameraZoom:UpdateOptions()
    Tabs.Visuals:UpdateSections()
end})
Options.cameraZoom:AddBind({text = "Zoom", flag = "cameraZoomBind", tooltip = "Enables the zoom only when this key is held. Select BACKSPACE to make zoom always active.", mode = "hold", callback = function(State)
    if Flags.cameraZoom then
        if State then
            Camera.FieldOfView = Flags.cameraZoomValue
        else
            if Flags.cameraFoV then
                Camera.FieldOfView = Flags.cameraFoVValue
            else
                Camera.FieldOfView = Old_Camera.FieldOfView
            end
        end
    end
end})
Options.cameraZoom:AddSlider({flag = "cameraZoomValue", enabled = false, suffix = "Â°", min = 1, max = 120, value = Old_Camera.FieldOfView, callback = function(Value)
    if Flags.cameraZoom then
        Camera.FieldOfView = Value
    end
end})

Sections.Visuals.Camera:AddToggle({text = "Third Person", flag = "lPlayerThirdPerson", callback = function(State)
    Options.lPlayerThirdPersonValue.enabled = State
    Options.lPlayerThirdPerson:UpdateOptions()
    Tabs.Visuals:UpdateSections()
end})
Options.lPlayerThirdPerson:AddBind({text = "Third Person", flag = "lPlayerThirdPersonBind", tooltip = "Toggles the third person when this key was pressed. Select BACKSPACE to make third person always active."})
Options.lPlayerThirdPerson:AddSlider({flag = "lPlayerThirdPersonValue", tooltip = "Third person distance.", enabled = false, min = 0, max = 100, increment = 0.1})

Sections.Visuals.Camera:AddToggle({text = "Free Camera", flag = "lplayerFreeCamera", tooltip = "Blocks character movement and releases camera movement.", callback = function(State)
    if State then
        if Flags.lplayerFreeCameraBind then
            FreeCamera:Start()
        end
    else
        FreeCamera:Stop()
    end
    Options.lplayerFreeCameraSpeed.enabled = State
    Options.lplayerFreeCamera:UpdateOptions()
    Tabs.Visuals:UpdateSections()
end})
Options.lplayerFreeCamera:AddSlider({flag = "lplayerFreeCameraSpeed", tooltip = "Free camera speed.", enabled = false, min = 0, max = 2, value = 0.5, increment = 0.01, callback = function(Value)
    FreeCamera.Speed = Value
end})
Options.lplayerFreeCamera:AddBind({text = "Free Camera", flag = "lplayerFreeCameraBind", tooltip = "Toggles the free camera when this key was pressed. Select BACKSPACE to make free camera always active.", callback = function(State)
    if State then
        if Flags.lplayerFreeCamera then
            FreeCamera:Start()
        else
            FreeCamera:Stop()
        end
    else
        FreeCamera:Stop()
    end
end})

Utility:Connection(Camera:GetPropertyChangedSignal("FieldOfView"), LPH_JIT_ULTRA(function()
    if Flags.cameraZoom and Flags.cameraZoomBind then
        Camera.FieldOfView = Flags.cameraZoomValue
        return
    end
    if Flags.cameraFoV then
        Camera.FieldOfView = Flags.cameraFoVValue
    end
end))

-- Visuals - Other
Sections.Visuals.Other:AddToggle({text = "Field of View Circle", tooltip = "Draws a circle displaying your aimbot's field of view.", flag = "visualsShowFoV", callback = function(State)
    FOV_Circle.Visible = State
    Options.visualsShowFoVCol.enabled = State
    Options.visualsShowFoV:UpdateOptions()
    Tabs.Visuals:UpdateSections()
end}):AddColor({text = "FOV Circle Color", flag = "visualsShowFoVCol", enabled = false, callback = function(Color, Transparency)
    FOV_Circle.Color = Color
    FOV_Circle.Transparency = 1 - Transparency
end})

local VisualizeLagFolder
Sections.Visuals.Other:AddToggle({text = "Visualize Fake Lag", flag = "visualsVisualizeLags", tooltip = "Shows your fake lag position. May cause lags if fake lag limit is low.", callback = function(State)
    if not State then
        task.spawn(function()
            task.wait()
            VisualizeLagFolder:ClearAllChildren()
        end)
    end
    Options.visualsVisualizeLagsColor.enabled = State
    Options.visualsVisualizeLags:UpdateOptions()
    Tabs.Visuals:UpdateSections()
end}):AddColor({text = "Visualized Fake Lag Color", flag = "visualsVisualizeLagsColor", enabled = false})

Sections.Visuals.Other:AddToggle({text = "Chinese Hat", flag = "visualsChineseHat", tooltip = "Draws a chinese hat on your head.", callback = function(State)
    ESP.Settings.China_Hat.Enabled = State
    for i = 1,30 do
        ESP.China_Hat[i][1].Visible = State
        ESP.China_Hat[i][2].Visible = State
    end
    Options.visualsChineseHatColor.enabled = State
    Options.visualsChineseHatHeight.enabled = State
    Options.visualsChineseHatRadius.enabled = State
    Options.visualsChineseHatOffset.enabled = State
    Options.visualsChineseHat:UpdateOptions()
    Tabs.Visuals:UpdateSections()
end}):AddColor({text = "Chinese Hat Color", flag = "visualsChineseHatColor", enabled = false, trans = 0.5, callback = function(Color, Transparency)
    ESP.Settings.China_Hat.Color = Color
    ESP.Settings.China_Hat.Transparency = Transparency
end})
Options.visualsChineseHat:AddSlider({flag = "visualsChineseHatHeight", tooltip = "Chinese hat height.", enabled = false, min = -5, max = 5, value = 0.5, increment = 0.1, callback = function(Value)
    ESP.Settings.China_Hat.Height = Value
end})
Options.visualsChineseHat:AddSlider({flag = "visualsChineseHatRadius", tooltip = "Chinese hat radius.", enabled = false, min = -5, max = 5, value = 1, increment = 0.1, callback = function(Value)
    ESP.Settings.China_Hat.Radius = Value
end})
Options.visualsChineseHat:AddSlider({flag = "visualsChineseHatOffset", tooltip = "Chinese hat offset.", enabled = false, min = -5, max = 5, value = 1, increment = 0.1, callback = function(Value)
    ESP.Settings.China_Hat.Offset = Value
end})

Sections.Visuals.Other:AddToggle({text = "Bullet Tracer", tooltip = "Draws your fired bullet's tracer.", flag = "logsBulletTracer", callback = function(State)
    Options.logsBulletTracerThickness.enabled = State
    Options.logsBulletTracerColor.enabled = State
    Options.logsBulletTracer:UpdateOptions()
    Tabs.Visuals:UpdateSections()
end}):AddColor({text = "Tracer Color", flag = "logsBulletTracerColor", enabled = false})
Options.logsBulletTracer:AddSlider({flag = "logsBulletTracerThickness", tooltip = "Tracer thickness.", enabled = false, min = 0, max = 0.4, value = 0.03, increment = 0.01})

Sections.Visuals.Other:AddToggle({text = "Hit Registration", tooltip = "Notifies you hit registration information (Name, hit part, distance).", flag = "logsHitRegistration", callback = function(State)
    Options.logsHitRegistrationDuration.enabled = State
    Options.logsHitRegistrationColor.enabled = State
    Options.logsHitRegistration:UpdateOptions()
    Tabs.Visuals:UpdateSections()
end}):AddColor({text = "Notification Color", flag = "logsHitRegistrationColor", enabled = false})
Options.logsHitRegistration:AddSlider({flag = "logsHitRegistrationDuration", tooltip = "Notification duration.", enabled = false, min = 1, max = 10, value = 5,})

-- Visuals - Inventory Viewer
local InventoryViewer = {
    Size = Vector2.new(300, 14), 
    Main = Framework:Draw("Square", {Thickness = 0, Size = Vector2.new(300, 14), Filled = true, Position = Vector2.new(100, 100), Transparency = 0.4}),
    Texts = {}
}
LPH_JIT_ULTRA(function()
    function InventoryViewer:Clear()
        for i, v in pairs(self.Texts) do
            v:Remove()
            self.Texts[i] = nil
            self.Main.Size = self.Size
        end
    end
    function InventoryViewer:AddText(Text, Tabulated, Main_Text)
        local Main = self.Main
        local Drawing = Framework:Draw("Text", {Text = Text, Color = Color3.new(1, 1, 1), Transparency = 1, Size = 13, Font = 2, Outline = true, Visible = true})
        table.insert(self.Texts, Drawing)
        local Drawings = #self.Texts
        Main.Size = Vector2.new(self.Size.X, 14 * Drawings)
        Drawing.Position = Main.Position + Vector2.new(5, (Drawings - 1) * 14)
        if Main_Text then
            Drawing.Center = true
            Drawing.Position = Main.Position + Vector2.new(Main.Size.X / 2, 0)
        end
        if Tabulated then
            Drawing.Position = Main.Position + Vector2.new(20, (Drawings - 1) * 14)
        end
        return Drawing
    end
    function InventoryViewer:Update()
        self.Size = Vector2.new(300, 14)
        local Scan, Containers, _Players = {}, table.find(Flags.invViewToScan, "Containers"), table.find(Flags.invViewToScan, "Players")
        if Containers then
            for i, v in pairs(Workspace.Containers:GetChildren()) do
                if v:IsA("Model") and v:FindFirstChild("Inventory") then
                    table.insert(Scan, v)
                end
            end
        end
        if _Players then
            for i, v in pairs(Players:GetPlayers()) do
                if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChildOfClass("Humanoid") then
                    table.insert(Scan, v.Character)
                end
            end
        end
        local Target, Magnitude, lowMagnitude = nil, math.huge, math.huge
        for i, v in pairs(Scan) do
            local PrimaryPart = v.PrimaryPart
            if PrimaryPart then
                local Vector, onScreen = Camera:WorldToViewportPoint(PrimaryPart.Position)
                if onScreen then
                    local Magnitude = (Camera.ViewportSize / 2 - Framework:V3_To_V2(Vector)).Magnitude
                    if Magnitude < lowMagnitude then
                        lowMagnitude = Magnitude
                        Target = v
                    end
                end
            end
        end
        if not Target then
            self:Clear()
            self:AddText("Inventory Viewer", false, true)
            return
        end
        local Humanoid = Target:FindFirstChildOfClass("Humanoid")
        self:Clear()
        local MainText = self:AddText(Target.Name, false, true)
        Scan = {}
        local Maximal_X = 0
        if Humanoid then
            local Folder = ReplicatedPlayers[Target.Name]
            table.insert(Scan, Folder.Inventory)
            table.insert(Scan, Folder.Clothing)
            for i, v in pairs(Scan) do
                local Name = v.Name
                if Name == "Inventory" then
                    for _, Item in pairs(v:GetChildren()) do
                        local ItemProperties = Item:FindFirstChild("ItemProperties")
                        if ItemProperties then
                            local ammoString = ""
                            local isGun = false
                            local ItemType = ItemProperties:GetAttribute("ItemType")
                            if ItemType and ItemType == "RangedWeapon" then
                                isGun = true
                                local Attachments = Item:FindFirstChild("Attachments")
                                if Attachments then
                                    local Magazine = Attachments:FindFirstChild("Magazine")
                                    if Magazine then
                                        Magazine = Magazine:FindFirstChildOfClass("StringValue")
                                        if Magazine then
                                            local MagazineProperties = Magazine:FindFirstChild("ItemProperties")
                                            if MagazineProperties then
                                                local LoadedAmmo = MagazineProperties:FindFirstChild("LoadedAmmo")
                                                if LoadedAmmo then
                                                    for _, Slot in pairs(LoadedAmmo:GetChildren()) do
                                                        local AmmoType, Amount = Slot:GetAttribute("AmmoType"), Slot:GetAttribute("Amount")
                                                        if AmmoType and Amount then
                                                            ammoString = ammoString .. Amount .. " - " .. AmmoType:gsub("Tracer", "T") .. "; "
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            if ammoString == "" and isGun == false then
                                self:AddText("[Hotbar] " .. Item.Name)
                            elseif ammoString == "" then
                                local HotbarDrawing = self:AddText("[Hotbar] " .. Item.Name .. " [OUT OF AMMO]")
                                local textBoundsX = HotbarDrawing.TextBounds.X
                                if textBoundsX > Maximal_X then
                                    Maximal_X = textBoundsX
                                end
                                if Maximal_X > self.Size.X then
                                    self.Size = Vector2.new(Maximal_X + 10, self.Main.Size.Y)
                                    self.Main.Size = self.Size
                                    MainText.Position = self.Main.Position + Vector2.new(self.Main.Size.X / 2, 0)
                                end
                            else
                                ammoString = ammoString:sub(0, ammoString:len() - 2)
                                local HotbarDrawing = self:AddText("[Hotbar] " .. Item.Name .. " ["..ammoString.."]")
                                local textBoundsX = HotbarDrawing.TextBounds.X
                                if textBoundsX > Maximal_X then
                                    Maximal_X = textBoundsX
                                end
                                if Maximal_X > self.Size.X then
                                    self.Size = Vector2.new(Maximal_X + 10, self.Main.Size.Y)
                                    self.Main.Size = self.Size
                                    MainText.Position = self.Main.Position + Vector2.new(self.Main.Size.X / 2, 0)
                                end
                            end
                        else
                            self:AddText("[Hotbar] " .. Item.Name)
                        end
                    end
                elseif Name == "Clothing" then
                    for _, Clothing in pairs(v:GetChildren()) do
                        -- Clothing
                        local Attachments = Clothing:FindFirstChild("Attachments")
                        local attachmentString = ""
                        if Attachments then
                            for _, Slot in pairs(Attachments:GetChildren()) do
                                local Attachment = Slot:FindFirstChildOfClass("StringValue")
                                if Attachment then
                                    attachmentString = attachmentString .. Attachment.Name .. "; "
                                end
                            end
                        end
                        attachmentString = attachmentString:sub(0, attachmentString:len() - 2)
                        if attachmentString == "" then
                            self:AddText(Clothing.Name)
                        else
                            local ClothingDrawing = self:AddText(Clothing.Name .. " [".. attachmentString .."]")
                            local textBoundsX = ClothingDrawing.TextBounds.X
                            if textBoundsX > Maximal_X then
                                Maximal_X = textBoundsX
                            end
                            if Maximal_X > self.Size.X then
                                self.Size = Vector2.new(Maximal_X + 10, self.Main.Size.Y)
                                self.Main.Size = self.Size
                                MainText.Position = self.Main.Position + Vector2.new(self.Main.Size.X / 2, 0)
                            end
                        end

                        -- Clothing Inventory
                        local Inventory = Clothing:FindFirstChild("Inventory")
                        if Inventory then
                            for _, Item in pairs(Inventory:GetChildren()) do
                                local ItemProperties = Item:FindFirstChild("ItemProperties")
                                if ItemProperties then
                                    local Amount = ItemProperties:GetAttribute("Amount")
                                    if Amount then
                                        if Amount > 1 then
                                            self:AddText(Item.Name .. " [" .. tostring(Amount) .. "]", true)
                                        else
                                            self:AddText(Item.Name, true)
                                        end
                                    else
                                        self:AddText(Item.Name, true)
                                    end
                                else
                                    self:AddText(Item.Name, true)
                                end
                            end
                        end
                    end
                end
            end
        else
            local Inventory = Target:FindFirstChild("Inventory")
            if Inventory then
                for _, Item in pairs(Inventory:GetChildren()) do
                    local ItemProperties = Item:FindFirstChild("ItemProperties")
                    if ItemProperties then
                        local Amount = ItemProperties:GetAttribute("Amount")
                        if Amount then
                            if Amount > 1 then
                                self:AddText(Item.Name .. " [" .. tostring(Amount) .. "]")
                            else
                                self:AddText(Item.Name)
                            end
                        else
                            self:AddText(Item.Name)
                        end
                    else
                        self:AddText(Item.Name)
                    end
                end
            end
        end
    end
    InventoryViewer.__index = InventoryViewer

    local invViewer, canUpdate = nil, true
    Sections.Visuals["Inventory Viewer"]:AddToggle({text = "Enabled", flag = "invViewEnabled", callback = function(State)
        if State then
            if invViewer ~= nil then
                invViewer:Disconnect()
            end
            invViewer = Utility:Connection(RunService.Heartbeat, function()
                if not canUpdate then return end
                canUpdate = false
                InventoryViewer:Update()
                task.wait(Flags.invViewUpdateTime)
                canUpdate = true
            end)
            InventoryViewer.Main.Visible = true
        else
            if invViewer ~= nil then
                invViewer:Disconnect()
            end
            InventoryViewer.Main.Visible = false
            task.spawn(function()
                task.wait()
                InventoryViewer:Clear()
            end)
        end
        Options.invViewColor.enabled = State
        Options.invViewToScan.enabled = State
        Options.invViewUpdateTime.enabled = State
        Options.invViewY.enabled = State
        Options.invViewX.enabled = State
        Options.invViewEnabled:UpdateOptions()
        Tabs.Visuals:UpdateSections()
    end}):AddColor({text = "Inventory Window Color", flag = "invViewColor", enabled = false, color = Color3.new(0, 0, 0), trans = 0.6, callback = function(Color, Transparency)
        InventoryViewer.Main.Color = Color
        InventoryViewer.Main.Transparency = Framework:Drawing_Transparency(Transparency)
    end})

    Options.invViewEnabled:AddList({flag = "invViewToScan", tooltip = "What should inventory viewer scan.", enabled = false, values = {"Players", "Containers"}, selected = {"Players", "Containers"}, multi = true, min = 1})
    Options.invViewEnabled:AddSlider({flag = "invViewUpdateTime", tooltip = "Inventory viewer update time.", enabled = false, min = 0, max = 1, value = 0.1, increment = 0.01})
    Options.invViewEnabled:AddSlider({flag = "invViewY", tooltip = "Window coordinate Y.", enabled = false, min = 0, max = Camera.ViewportSize.Y, value = 100, callback = function(Value)
        InventoryViewer.Main.Position = Vector2.new(InventoryViewer.Main.Position.X, Value)
    end})
    Options.invViewEnabled:AddSlider({flag = "invViewX", tooltip = "Window coordinate X.", enabled = false, min = 0, max = Camera.ViewportSize.X, value = 100, callback = function(Value)
        InventoryViewer.Main.Position = Vector2.new(Value, InventoryViewer.Main.Position.Y)
    end})
end)()

Utility:Connection(Camera:GetPropertyChangedSignal("ViewportSize"), LPH_JIT_ULTRA(function()
    Options.aimbotFoV.max = Camera.ViewportSize.X / 2 + 200
    Options.invViewX.max = Camera.ViewportSize.X
    Options.invViewY.max = Camera.ViewportSize.Y
    FOV_Circle.Position = Camera.ViewportSize / 2
end))

-- Visuals - Objects
LPH_JIT_MAX(function()
    local objectConnections = {}
    Sections.Visuals.Objects:AddToggle({text = "Enabled", flag = "objectsEnabled", tooltip = "Enables objects esp.", callback = function(State)
        ESP.Settings.Objects_Enabled = State
        for _, option in pairs(Sections.Visuals.Objects.options) do
            if option.flag == "objectsEnabled" then continue end
            if option.risky ~= nil then
                option.enabled = State
            end
        end
        Sections.Visuals.Objects:UpdateOptions()
        Tabs.Visuals:UpdateSections()
    end})
    local AiZones = Workspace:FindFirstChild("AiZones")
    if AiZones then
        for _, Zone in pairs(AiZones:GetChildren()) do
            Utility:Connection(Zone.ChildAdded, function(Child)
                if Child:IsA("Model") then
                    if Child.PrimaryPart and Flags.objectsEnabled and Flags.objectsAiEntities then
                        ESP:Object(Child, {
                            Type = "Bandit",
                            Color = Flags.objectsAiEntitiesColor,
                            Transparency = Framework:Drawing_Transparency(Options.objectsAiEntitiesColor.trans),
                            Outline = Flags.objectOutline
                        })
                    end
                    if objectConnections[Child] == nil then
                        objectConnections[Child] = Utility:Connection(Child:GetPropertyChangedSignal("PrimaryPart"), function()
                            if Child.PrimaryPart == nil then
                                local Object = ESP:GetObject(Child)
                                if Object then
                                    Object:Destroy()
                                end
                            elseif Flags.objectsEnabled and Flags.objectsAiEntities then
                                ESP:Object(Child, {
                                    Type = "Bandit",
                                    Color = Flags.objectsAiEntitiesColor,
                                    Transparency = Framework:Drawing_Transparency(Options.objectsAiEntitiesColor.trans),
                                    Outline = Flags.objectOutline
                                })
                            end
                        end)
                    end
                end
            end)
            Utility:Connection(Zone.ChildRemoved, function(Child)
                if Child:IsA("Model") then
                    local Object = ESP:GetObject(Child)
                    if Object then
                        Object:Destroy()
                    end
                end
            end)
        end
        Sections.Visuals.Objects:AddToggle({text = "AI Entities", flag = "objectsAiEntities", enabled = false, callback = function(State)
            if State then
                for _, Zone in pairs(AiZones:GetChildren()) do
                    for _, Item in pairs(Zone:GetChildren()) do
                        ESP:Object(Item, {
                            Type = "Bandit",
                            Color = Flags.objectsAiEntitiesColor,
                            Transparency = Framework:Drawing_Transparency(Options.objectsAiEntitiesColor.trans),
                            Outline = Flags.objectOutline
                        })
                        if objectConnections[Item] == nil then
                            objectConnections[Item] = Utility:Connection(Item:GetPropertyChangedSignal("PrimaryPart"), function()
                                if Item.PrimaryPart == nil then
                                    local Object = ESP:GetObject(Item)
                                    if Object then
                                        Object:Destroy()
                                    end
                                elseif Flags.objectsEnabled and Flags.objectsAiEntities then
                                    ESP:Object(Item, {
                                        Type = "Bandit",
                                        Color = Flags.objectsAiEntitiesColor,
                                        Transparency = Framework:Drawing_Transparency(Options.objectsAiEntitiesColor.trans),
                                        Outline = Flags.objectOutline
                                    })
                                end
                            end)
                        end
                    end
                end
            else
                for _, Object in pairs(ESP.Objects) do
                    if Object.Type == "Bandit" then
                        Object:Destroy()
                    end
                end
            end
            Options.objectsAiEntitiesColor.enabled = State
            Options.objectsAiEntities:UpdateOptions()
            Tabs.Visuals:UpdateSections()
        end})
        Options.objectsAiEntities:AddColor({text = "Bandits Color", flag = "objectsAiEntitiesColor", enabled = false, callback = function(Color, Transparency)
            for _, Object in pairs(ESP.Objects) do
                if Object.Type == "Bandit" then
                    for _, Drawing in pairs(Object.Components) do
                        Drawing.Color = Color
                        Drawing.Transparency = Framework:Drawing_Transparency(Transparency)
                    end
                end
            end
        end})
    end
    local Containers = Workspace:FindFirstChild("Containers")
    if Containers then
        Utility:Connection(Containers.ChildAdded, function(Child)
            if Child:IsA("Model") then
                if Child.PrimaryPart and Flags.objectsEnabled and Flags.objectsContainers then
                    ESP:Object(Child, {
                        Type = "Container",
                        Color = Flags.objectsContainersColor,
                        Transparency = Framework:Drawing_Transparency(Options.objectsContainersColor.trans),
                        Outline = Flags.objectOutline
                    })
                end
                if objectConnections[Child] == nil then
                    objectConnections[Child] = Utility:Connection(Child:GetPropertyChangedSignal("PrimaryPart"), function()
                        if Child.PrimaryPart == nil then
                            local Object = ESP:GetObject(Child)
                            if Object then
                                Object:Destroy()
                            end
                        elseif Flags.objectsEnabled and Flags.objectsContainers then
                            ESP:Object(Child, {
                                Type = "Container",
                                Color = Flags.objectsContainersColor,
                                Transparency = Framework:Drawing_Transparency(Options.objectsContainersColor.trans),
                                Outline = Flags.objectOutline
                            })
                        end
                    end)
                end
            end
        end)
        Utility:Connection(Containers.ChildRemoved, function(Child)
            if Child:IsA("Model") then
                local Object = ESP:GetObject(Child)
                if Object then
                    Object:Destroy()
                end
            end
        end)
        Sections.Visuals.Objects:AddToggle({text = "Containers", flag = "objectsContainers", enabled = false, callback = function(State)
            if State then
                for _, Item in pairs(Containers:GetChildren()) do
                    ESP:Object(Item, {
                        Type = "Container",
                        Color = Flags.objectsContainersColor,
                        Transparency = Framework:Drawing_Transparency(Options.objectsContainersColor.trans),
                        Outline = Flags.objectOutline
                    })
                    if objectConnections[Item] == nil then
                        objectConnections[Item] = Utility:Connection(Item:GetPropertyChangedSignal("PrimaryPart"), function()
                            if Item.PrimaryPart == nil then
                                local Object = ESP:GetObject(Item)
                                if Object then
                                    Object:Destroy()
                                end
                            elseif Flags.objectsEnabled and Flags.objectsContainers then
                                ESP:Object(Item, {
                                    Type = "Container",
                                    Color = Flags.objectsContainersColor,
                                    Transparency = Framework:Drawing_Transparency(Options.objectsContainersColor.trans),
                                    Outline = Flags.objectOutline
                                })
                            end
                        end)
                    end
                end
            else
                for _, Object in pairs(ESP.Objects) do
                    if Object.Type == "Container" then
                        Object:Destroy()
                    end
                end
            end
            Options.objectsContainersColor.enabled = State
            Options.objectsContainers:UpdateOptions()
            Tabs.Visuals:UpdateSections()
        end})
        Options.objectsContainers:AddColor({text = "Containers Color", flag = "objectsContainersColor", enabled = false, callback = function(Color, Transparency)
            for _, Object in pairs(ESP.Objects) do
                if Object.Type == "Container" then
                    for _, Drawing in pairs(Object.Components) do
                        Drawing.Color = Color
                        Drawing.Transparency = Framework:Drawing_Transparency(Transparency)
                    end
                end
            end
        end})
    end
    local DroppedItems = Workspace:FindFirstChild("DroppedItems")
    if DroppedItems then
        Utility:Connection(DroppedItems.ChildAdded, function(Child)
            if Child:IsA("Model") then
                if Child.PrimaryPart and Flags.objectsEnabled and Flags.objectsDropped then
                    ESP:Object(Child, {
                        Type = "Dropped",
                        Color = Flags.objectsDroppedColor,
                        Transparency = Framework:Drawing_Transparency(Options.objectsDroppedColor.trans),
                        Outline = Flags.objectOutline
                    })
                end
                if objectConnections[Child] == nil then
                    objectConnections[Child] = Utility:Connection(Child:GetPropertyChangedSignal("PrimaryPart"), function()
                        if Child.PrimaryPart == nil then
                            local Object = ESP:GetObject(Child)
                            if Object then
                                Object:Destroy()
                            end
                        elseif Flags.objectsEnabled and Flags.objectsDropped then
                            ESP:Object(Child, {
                                Type = "Dropped",
                                Color = Flags.objectsDroppedColor,
                                Transparency = Framework:Drawing_Transparency(Options.objectsDroppedColor.trans),
                                Outline = Flags.objectOutline
                            })
                        end
                    end)
                end
            end
        end)
        Utility:Connection(DroppedItems.ChildRemoved, function(Child)
            if Child:IsA("Model") then
                local Object = ESP:GetObject(Child)
                if Object then
                    Object:Destroy()
                end
            end
        end)
        Sections.Visuals.Objects:AddToggle({text = "Dropped Items", flag = "objectsDropped", enabled = false, callback = function(State)
            if State then
                for _, Item in pairs(DroppedItems:GetChildren()) do
                    ESP:Object(Item, {
                        Type = "Dropped",
                        Color = Flags.objectsDroppedColor,
                        Transparency = Framework:Drawing_Transparency(Options.objectsDroppedColor.trans),
                        Outline = Flags.objectOutline
                    })
                    if objectConnections[Item] == nil then
                        objectConnections[Item] = Utility:Connection(Item:GetPropertyChangedSignal("PrimaryPart"), function()
                            if Item.PrimaryPart == nil then
                                local Object = ESP:GetObject(Item)
                                if Object then
                                    Object:Destroy()
                                end
                            elseif Flags.objectsEnabled and Flags.objectsDropped then
                                ESP:Object(Item, {
                                    Type = "Dropped",
                                    Color = Flags.objectsDroppedColor,
                                    Transparency = Framework:Drawing_Transparency(Options.objectsDroppedColor.trans),
                                    Outline = Flags.objectOutline
                                })
                            end
                        end)
                    end
                end
            else
                for _, Object in pairs(ESP.Objects) do
                    if Object.Type == "Dropped" then
                        Object:Destroy()
                    end
                end
            end
            Options.objectsDroppedColor.enabled = State
            Options.objectsDropped:UpdateOptions()
            Tabs.Visuals:UpdateSections()
        end})
        Options.objectsDropped:AddColor({text = "Dropped Items Color", flag = "objectsDroppedColor", enabled = false, callback = function(Color, Transparency)
            for _, Object in pairs(ESP.Objects) do
                if Object.Type == "Dropped" then
                    for _, Drawing in pairs(Object.Components) do
                        Drawing.Color = Color
                        Drawing.Transparency = Framework:Drawing_Transparency(Transparency)
                    end
                end
            end
        end})
    end
    local NoCollision = Workspace:FindFirstChild("NoCollision")
    if NoCollision then
        local ExitLocations = NoCollision:FindFirstChild("ExitLocations")
        if ExitLocations then
            Utility:Connection(ExitLocations.ChildAdded, function(Child)
                if Child:IsA("BasePart") then
                    if Flags.objectsEnabled and Flags.objectsExits then
                        ESP:Object(Child, {
                            Type = "Exit",
                            Color = Flags.objectsExitsColor,
                            Transparency = Framework:Drawing_Transparency(Options.objectsExitsColor.trans),
                            Outline = Flags.objectOutline
                        })
                    end
                end
            end)
            Utility:Connection(ExitLocations.ChildRemoved, function(Child)
                if Child:IsA("BasePart") then
                    local Object = ESP:GetObject(Child)
                    if Object then
                        Object:Destroy()
                    end
                end
            end)
            Sections.Visuals.Objects:AddToggle({text = "Exit Locations", flag = "objectsExits", enabled = false, callback = function(State)
                if State then
                    for _, Item in pairs(ExitLocations:GetChildren()) do
                        if Item:IsA("BasePart") then
                            ESP:Object(Item, {
                                Type = "Exit",
                                Color = Flags.objectsExitsColor,
                                Transparency = Framework:Drawing_Transparency(Options.objectsExitsColor.trans),
                                Outline = Flags.objectOutline
                            })
                        end
                    end
                else
                    for _, Object in pairs(ESP.Objects) do
                        if Object.Type == "Exit" then
                            Object:Destroy()
                        end
                    end
                end
                Options.objectsExitsColor.enabled = State
                Options.objectsExits:UpdateOptions()
                Tabs.Visuals:UpdateSections()
            end})
            Options.objectsExits:AddColor({text = "Exit Locations Color", flag = "objectsExitsColor", enabled = false, callback = function(Color, Transparency)
                for _, Object in pairs(ESP.Objects) do
                    if Object.Type == "Exit" then
                        for _, Drawing in pairs(Object.Components) do
                            Drawing.Color = Color
                            Drawing.Transparency = Framework:Drawing_Transparency(Transparency)
                        end
                    end
                end
            end})
        end
    end

    Sections.Visuals.Objects:AddSlider({text = "Draw Distance", flag = "objectDrawDistance", enabled = false, suffix = "m", min = 1, max = 5000, value = 1000, callback = function(Value)
        ESP.Settings.Object_Maximal_Distance = Value
    end})

    Sections.Visuals.Objects:AddToggle({text = "Text Outline", flag = "objectOutline", enabled = false, callback = function(State)
        for _, Object in pairs(ESP.Objects) do
            if Object.Type == "Player" then continue end
            for _, Drawing in pairs(Object.Components) do
                Drawing.Outline = State
            end
        end
    end}):SetState(true)
end)()

-- Miscellaneous - LocalPlayer
local SpeedHack
Sections.Miscellaneous.LocalPlayer:AddToggle({text = "Speedhack", flag = "lplayerSpeedhack", tooltip = "Speeds up your character.", callback = LPH_JIT_MAX(function(State)
    if State then
        if SpeedHack ~= nil then
            SpeedHack:Disconnect()
            SpeedHack = nil
        end
        SpeedHack = Utility:Connection(RunService.Stepped, function()
            local IsFlying = (Flags.lPlayerSpeedhackFly and Flags.lPlayerSpeedhackFlyBind) or false
            local Character, SpeedActive, Speed, FlyEnabled, Fly = LocalPlayer.Character, Flags.lplayerSpeedhackBind or false, IsFlying and Flags.lPlayerSpeedhackFlySpeed or Flags.lplayerSpeedhackValue
            if not Library.open and Character then
                local HumanoidRootPart, Humanoid = Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChildOfClass("Humanoid")
                if HumanoidRootPart and Humanoid then
                    if SpeedActive then
                        if Humanoid:GetState() ~= Enum.HumanoidStateType.Climbing and UserInputService:IsKeyDown(Enum.KeyCode.W) then HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + Camera.CFrame.LookVector * Speed end
                        if UserInputService:IsKeyDown(Enum.KeyCode.S) then HumanoidRootPart.CFrame = HumanoidRootPart.CFrame - Camera.CFrame.LookVector * Speed end
                        if UserInputService:IsKeyDown(Enum.KeyCode.A) then HumanoidRootPart.CFrame = HumanoidRootPart.CFrame - Camera.CFrame.RightVector * Speed end
                        if UserInputService:IsKeyDown(Enum.KeyCode.D) then HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + Camera.CFrame.RightVector * Speed end
                    end
                    if SpeedActive and IsFlying then
                        HumanoidRootPart:ApplyImpulse(-HumanoidRootPart.Velocity)
                        HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                        HumanoidRootPart.CFrame = CFrame.lookAt(HumanoidRootPart.Position, HumanoidRootPart.Position + Camera.CFrame.LookVector)
                        Workspace.Gravity = 0
                        Humanoid.PlatformStand = Flags.lPlayerSpeedhackFlyPlatformStand
                        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then HumanoidRootPart.CFrame = HumanoidRootPart.CFrame * CFrame.new(0, Speed, 0) end
                        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then HumanoidRootPart.CFrame = HumanoidRootPart.CFrame * CFrame.new(0, -Speed, 0) end
                    end
                end
            end
        end)
    else
        task.spawn(function()
            task.wait()
            if SpeedHack ~= nil then
                SpeedHack:Disconnect()
                SpeedHack = nil
            end
            if LocalPlayer.Character then
                local Humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if Humanoid then
                    Humanoid.PlatformStand = false
                end
            end
            if Flags.lplayerGravity then
                Workspace.Gravity = Flags.lplayerGravityValue
            else
                Workspace.Gravity = Old_Gravity
            end
        end)
    end
    Options.flyText1.enabled = State
    Options.flyText2.enabled = State
    Options.flyText3.enabled = State
    Options.lplayerSpeedhackValue.enabled = State
    Options.lPlayerSpeedhackFly.enabled = State
    Options.lplayerSpeedhack:UpdateOptions()
    Sections.Miscellaneous.LocalPlayer:UpdateOptions()
    Tabs.Miscellaneous:UpdateSections()
end)})
Options.lplayerSpeedhack:AddBind({text = "Speedhack", flag = "lplayerSpeedhackBind", tooltip = "Toggles the speedhack when this key was pressed. Select BACKSPACE to make speedhack always active.", callback = function(State)
    if not State and Flags.lPlayerSpeedhackFly then
        task.spawn(function()
            task.wait()
            if LocalPlayer.Character then
                local Humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if Humanoid then
                    Humanoid.PlatformStand = false
                end
            end
            if Flags.lplayerGravity then
                Workspace.Gravity = Flags.lplayerGravityValue
            else
                Workspace.Gravity = Old_Gravity
            end
        end)
    end
end})
Options.lplayerSpeedhack:AddSlider({flag = "lplayerSpeedhackValue", tooltip = "Speedhack speed.", enabled = false, min = 0, max = 0.13, increment = 0.0001, value = 0})

Sections.Miscellaneous.LocalPlayer:AddText({text = "You have around 3 seconds in air when", flag = "flyText1", enabled = false})
Sections.Miscellaneous.LocalPlayer:AddText({text = "flying. Use fly like spider or you will", flag = "flyText2", enabled = false})
Sections.Miscellaneous.LocalPlayer:AddText({text = "get kicked.", flag = "flyText3", enabled = false})

Sections.Miscellaneous.LocalPlayer:AddToggle({text = "Speedhack Fly", flag = "lPlayerSpeedhackFly", tooltip = "Lets you fly with speedhack enabled.", enabled = false, risky = true, callback = function(State)
    if not State then
        task.spawn(function()
            task.wait()
            if LocalPlayer.Character then
                local Humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if Humanoid then
                    Humanoid.PlatformStand = false
                end
            end
            if Flags.lplayerGravity then
                Workspace.Gravity = Flags.lplayerGravityValue
            else
                Workspace.Gravity = Old_Gravity
            end
        end)
    end
    Options.lPlayerSpeedhackFlySpeed.enabled = State
    Options.lPlayerSpeedhackFlyPlatformStand.enabled = State
    Options.lPlayerSpeedhackFly:UpdateOptions()
    Sections.Miscellaneous.LocalPlayer:UpdateOptions()
    Tabs.Miscellaneous:UpdateSections()
end}):AddBind({text = "Speedhack Fly", flag = "lPlayerSpeedhackFlyBind", tooltip = "Enables the speedhack flying only when this fly active and key is held. Select BACKSPACE to make speedhack flying always active.", mode = "hold", callback = function(State)
    if Flags.lPlayerSpeedhackFly then
        if not State then
            task.spawn(function()
                task.wait()
                if LocalPlayer.Character then
                    local Humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if Humanoid then
                        Humanoid.PlatformStand = false
                    end
                end
                if Flags.lplayerGravity then
                    Workspace.Gravity = Flags.lplayerGravityValue
                else
                    Workspace.Gravity = Old_Gravity
                end
            end)
        end
    end
end})
Options.lPlayerSpeedhackFly:AddSlider({flag = "lPlayerSpeedhackFlySpeed", tooltip = "Speedhack speed when flying.", enabled = false, min = 0, max = 0.2, increment = 0.0001, value = 0})

Sections.Miscellaneous.LocalPlayer:AddToggle({text = "Fly Platform Stand", flag = "lPlayerSpeedhackFlyPlatformStand", tooltip = "If disabled then you probably will fly in vehicles. Disabling makes on foot fly unstable.", enabled = false}):SetState(true)

Sections.Miscellaneous.LocalPlayer:AddToggle({text = "Gravity", flag = "lplayerGravity", tooltip = "Changes world gravity.", callback = function(State)
    if State then
        Workspace.Gravity = Flags.lplayerGravityValue
    else
        Workspace.Gravity = Old_Gravity
    end
    Options.lplayerGravityValue.enabled = State
    Options.lplayerGravity:UpdateOptions()
    Tabs.Miscellaneous:UpdateSections()
end}):AddSlider({flag = "lplayerGravityValue", tooltip = "Gravity value.", enabled = false, min = 0, max = 1000, increment = 0.001, value = Old_Gravity, callback = function(Value)
    if Flags.lplayerGravity then
        Workspace.Gravity = Value
    end
end})

Utility:Connection(Workspace:GetPropertyChangedSignal("Gravity"), LPH_JIT_ULTRA(function()
    if Flags.lplayerSpeedhack and Flags.lPlayerSpeedhackFly and Flags.lPlayerSpeedhackFlyBind then
        Workspace.Gravity = 0
        return
    end
    if Flags.lplayerGravity then
        Workspace.Gravity = Flags.lplayerGravityValue
    end
end))

Sections.Miscellaneous.LocalPlayer:AddToggle({text = "Auto Hop", flag = "lplayerBhop", tooltip = "Makes you jump as soon as you land."}):AddBind({text = "Auto Hop", flag = "lplayerBhopBind", tooltip = "Enables the auto hop only when this key is held. Select BACKSPACE to make auto hop always active.", mode = "hold"})

Sections.Miscellaneous.LocalPlayer:AddToggle({text = "Infinite Jump", flag = "lplayerInfJump", tooltip = "Lets you jump when in air.", risky = true}):AddBind({text = "Infinite Jump", flag = "lplayerInfJumpBind", tooltip = "Enables the infinite jump only when this key is held. Select BACKSPACE to make infinite jump always active.", risky = true, mode = "hold"})

Utility:Connection(UserInputService.JumpRequest, LPH_JIT_ULTRA(function()
    if Flags.lplayerInfJump and Flags.lplayerInfJumpBind then
        local Character = LocalPlayer.Character
        if Character then
            local Humanoid = Character:FindFirstChildOfClass("Humanoid")
            if Humanoid then
                Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end))

if LocalPlayer.Character then
    local Humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if Humanoid then
        Utility:Connection(Humanoid.StateChanged, LPH_JIT_ULTRA(function(_, newState)
            if newState == Enum.HumanoidStateType.Landed then
                if Flags.lplayerBhop and Flags.lplayerBhopBind then
                    Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end))
    end
end

Utility:Connection(LocalPlayer.CharacterAdded, LPH_JIT_ULTRA(function(Character)
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if Humanoid then
        Utility:Connection(Humanoid.StateChanged, function(_, newState)
            if newState == Enum.HumanoidStateType.Landed then
                if Flags.lplayerBhop and Flags.lplayerBhopBind then
                    Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    else
        local c; c = Utility:Connection(Character.ChildAdded, function(Humanoid)
            if Humanoid:IsA("Humanoid") then
                Utility:Connection(Humanoid.StateChanged, function(_, newState)
                    if newState == Enum.HumanoidStateType.Landed then
                        if Flags.lplayerBhop and Flags.lplayerBhopBind then
                            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                        end
                    end
                end)
                c:Disconnect()
            end
        end)
    end
end))

-- Miscellaneous - Network
VisualizeLagFolder = Framework:Instance("Folder", {Parent = Camera})
Sections.Miscellaneous.Network:AddToggle({text = "Fake Lag", flag = "networkFakeLag", callback = LPH_JIT_ULTRA(function(State)
    if State then
        task.spawn(function()
            task.wait()
            local Tick = 0
            while Flags.networkFakeLag and Running do
                Tick = Tick + 1
                local Character = LocalPlayer.Character
                if Character then
                    local Head, HumanoidRootPart, Humanoid = Character:FindFirstChild("Head"), Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChild("Humanoid")
                    if Head and HumanoidRootPart and Humanoid and Humanoid.Health > 0 then
                        if Tick >= Flags.networkFakeLagLimit then
                            Tick = 0
                            NetworkClient:SetOutgoingKBPSLimit(math.huge)
                            if Flags.visualsVisualizeLags then
                                VisualizeLagFolder:ClearAllChildren()
                                Character.Archivable = true
                                local Clone = Character:Clone()
                                Character.Archivable = false
                                for _, Child in pairs(Clone:GetDescendants()) do
                                    if Child:IsA("SurfaceAppearance") or Child:IsA("Humanoid") or Child:IsA("BillboardGui") or Child:IsA("Decal") or Child.Name == "HumanoidRootPart" then
                                        Child:Destroy()
                                        continue
                                    end
                                    if Child:IsA("BasePart") then
                                        Child.CanCollide = false
                                        Child.Anchored = true
                                        Child.Material = Enum.Material.ForceField
                                        Child.Color = Flags.visualsVisualizeLagsColor
                                        Child.Transparency = Options.visualsVisualizeLagsColor.trans
                                        Child.Size = Child.Size + Vector3.new(0.025, 0.025, 0.025)
                                    end
                                end
                                Clone.Parent = VisualizeLagFolder
                            end
                        elseif (Flags.aimbotAutoFireNoLags and IsClicking and true) or (Flags.networkFakeLagNoMouse and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and true) then
                            Tick = 0
                            NetworkClient:SetOutgoingKBPSLimit(math.huge)
                            if Flags.visualsVisualizeLags then
                                VisualizeLagFolder:ClearAllChildren()
                                Character.Archivable = true
                                local Clone = Character:Clone()
                                Character.Archivable = false
                                for _, Child in pairs(Clone:GetDescendants()) do
                                    if Child:IsA("SurfaceAppearance") or Child:IsA("Humanoid") or Child:IsA("BillboardGui") or Child:IsA("Decal") or Child.Name == "HumanoidRootPart" then
                                        Child:Destroy()
                                        continue
                                    end
                                    if Child:IsA("BasePart") then
                                        Child.CanCollide = false
                                        Child.Anchored = true
                                        Child.Material = Enum.Material.ForceField
                                        Child.Color = Flags.visualsVisualizeLagsColor
                                        Child.Transparency = Options.visualsVisualizeLagsColor.trans
                                        Child.Size = Child.Size + Vector3.new(0.025, 0.025, 0.025)
                                    end
                                end
                                Clone.Parent = VisualizeLagFolder
                            end
                        else
                            NetworkClient:SetOutgoingKBPSLimit(1)
                        end
                    end
                end
                RunService.Stepped:Wait()
            end
        end)
    else 
        task.spawn(function()
            task.wait()
            NetworkClient:SetOutgoingKBPSLimit(math.huge)
            VisualizeLagFolder:ClearAllChildren()
        end)
    end
    Options.networkFakeLagLimit.enabled = State
    Options.networkFakeLagNoMouse.enabled = State
    Options.networkFakeLag:UpdateOptions()
    Sections.Miscellaneous.Network:UpdateOptions()
    Tabs.Miscellaneous:UpdateSections()
end)}):AddSlider({flag = "networkFakeLagLimit", tooltip = "Lag ticks limit (How long you will not send bandwidth).", enabled = false, suffix = "t", min = 0, max = 80, value = 0})

Sections.Miscellaneous.Network:AddToggle({text = "Disable Fake Lag On Mouse", flag = "networkFakeLagNoMouse", enabled = false, tooltip = "Disables fake lags when holding left mouse button.",})

-- Miscellaneous - Hit Sound
local hitSounds = {
    Neverlose = "rbxassetid://8726881116",
    Gamesense = "rbxassetid://4817809188",
    One = "rbxassetid://7380502345",
    Bell = "rbxassetid://6534947240",
    Rust = "rbxassetid://1255040462",
    TF2 = "rbxassetid://2868331684",
    Slime = "rbxassetid://6916371803",
    ["Among Us"] = "rbxassetid://5700183626",
    Minecraft = "rbxassetid://4018616850",
    ["CS:GO"] = "rbxassetid://6937353691",
    Saber = "rbxassetid://8415678813",
    Baimware = "rbxassetid://3124331820",
    Osu = "rbxassetid://7149255551",
    ["TF2 Critical"] = "rbxassetid://296102734",
    Bat = "rbxassetid://3333907347",
    ["Call of Duty"] = "rbxassetid://5952120301",
    Bubble = "rbxassetid://6534947588",
    Pick = "rbxassetid://1347140027",
    Pop = "rbxassetid://198598793",
    Bruh = "rbxassetid://4275842574",
    Bamboo = "rbxassetid://3769434519",
    Crowbar = "rbxassetid://546410481",
    Weeb = "rbxassetid://6442965016",
    Beep = "rbxassetid://8177256015",
    Bambi = "rbxassetid://8437203821",
    Stone = "rbxassetid://3581383408",
    ["Old Fatality"] = "rbxassetid://6607142036",
    Click = "rbxassetid://8053704437",
    Ding = "rbxassetid://7149516994",
    Snow = "rbxassetid://6455527632",
    Laser = "rbxassetid://7837461331",
    Mario = "rbxassetid://2815207981",
    Steve = "rbxassetid://4965083997",
    Snowdrake = "rbxassetid://7834724809"
}
local allSounds = {}
allSounds[1] = "Standard"
for i, v in pairs(hitSounds) do
    allSounds[#allSounds + 1] = i
end

Sections.Miscellaneous["Hit Sound"]:AddList({text = "Head", flag = "headSound", tooltip = "Sound played when you hit someone in head.", selected = "Standard", values = allSounds, callback = function(Value)
    local standardHitsound = Value == "Standard"
    if standardHitsound then
        headSound.SoundId = ""
    else
        headSound.SoundId = hitSounds[Value]
    end
    headSound:Play()
    Options.headSoundVolume.enabled = not standardHitsound
    Sections.Miscellaneous["Hit Sound"]:UpdateOptions()
    Tabs.Miscellaneous:UpdateSections()
end})

Sections.Miscellaneous["Hit Sound"]:AddSlider({text = "Head Sound Volume", flag = "headSoundVolume", enabled = false, min = 0, max = 10, value = 10, increment = 0.1, callback = function(Value)
    headSound.Volume = Value
    if not headSound.IsPlaying then
        headSound:Play()
    end
end})

Sections.Miscellaneous["Hit Sound"]:AddList({text = "Body", flag = "bodySound", tooltip = "Sound played when you hit someone in body.", selected = "Standard", values = allSounds, callback = function(Value)
    local standardHitsound = Value == "Standard"
    if standardHitsound then
        bodySound.SoundId = ""
    else
        bodySound.SoundId = hitSounds[Value]
    end
    bodySound:Play()
    Options.bodySoundVolume.enabled = not standardHitsound
    Sections.Miscellaneous["Hit Sound"]:UpdateOptions()
    Tabs.Miscellaneous:UpdateSections()
end})

Sections.Miscellaneous["Hit Sound"]:AddSlider({text = "Body Sound Volume", flag = "bodySoundVolume", enabled = false, min = 0, max = 10, value = 10, increment = 0.1, callback = function(Value)
    bodySound.Volume = Value
    if not bodySound.IsPlaying then
        bodySound:Play()
    end
end})

Sections.Miscellaneous["Hit Sound"]:AddList({text = "Kill", flag = "killSound", tooltip = "Sound played when you kill someone.", selected = "Standard", values = allSounds, callback = function(Value)
    local standardHitsound = Value == "Standard"
    if standardHitsound then
        killSound.SoundId = ""
    else
        killSound.SoundId = hitSounds[Value]
    end
    killSound:Play()
    Options.killSoundVolume.enabled = not standardHitsound
    Sections.Miscellaneous["Hit Sound"]:UpdateOptions()
    Tabs.Miscellaneous:UpdateSections()
end})

Sections.Miscellaneous["Hit Sound"]:AddSlider({text = "Kill Sound Volume", flag = "killSoundVolume", enabled = false, min = 0, max = 10, value = 10, increment = 0.1, callback = function(Value)
    killSound.Volume = Value
    if not killSound.IsPlaying then
        killSound:Play()
    end
end})

-- Miscellaneous - Removals
local Clouds = Terrain:FindFirstChildOfClass("Clouds")
if Clouds then
    Sections.Miscellaneous.Removals:AddToggle({text = "Clouds", flag = "removalsClouds", callback = function(State)
        Clouds.Parent = State and CoreGui or Terrain 
    end})
end

local Atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
if Atmosphere then
    Sections.Miscellaneous.Removals:AddToggle({text = "Atmosphere", flag = "removalsAtmosphere", callback = function(State)
        Atmosphere.Parent = State and CoreGui or Lighting 
    end})
end

for i, v in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
    if v:IsA("TextLabel") then
        if v.Text:find("| Server") or v.Text:find(game.JobId:lower()) or v.Text:find(LocalPlayer.UserId) then
            serverLabel = v
        end
    end
end
if serverLabel then
    Sections.Miscellaneous.Removals:AddToggle({text = "Server Information", flag = "removalsServer", callback = function(State)
        task.spawn(function()
            task.wait()
            if State then
                serverLabel.Text = ""
            end
        end)
    end})
    Utility:Connection(serverLabel:GetPropertyChangedSignal("Text"), LPH_JIT_ULTRA(function()
        if Flags.removalsServer then
            serverLabel.Text = ""
        end
    end))
end

local MainGui = Players.LocalPlayer.PlayerGui:FindFirstChild("MainGui")
if MainGui then 
    local MainFrame = MainGui:FindFirstChild("MainFrame")
    if MainFrame then 
        local ScreenEffects = MainFrame:FindFirstChild("ScreenEffects")
        Visor = ScreenEffects:FindFirstChild("Visor")
        if Visor then
            Sections.Miscellaneous.Removals:AddToggle({text = "Visor", flag = "removalsVisor", callback = function(State)
                task.spawn(function()
                    task.wait()
                    if Visor.Visible and State then
                        Visor.Visible = false
                    end
                end)
            end})
            Utility:Connection(Visor:GetPropertyChangedSignal("Visible"), LPH_JIT_ULTRA(function()
                if Flags.removalsVisor then
                    Visor.Visible = false
                end
            end))
        end
    end
end

Sections.Miscellaneous.Removals:AddToggle({text = "Chat Killed By You", flag = "removalsKilledBy", tooltip = "Strips your name, target name, hit, distance information from chat. Good for recording."})

local leafTable = {}
Sections.Miscellaneous.Removals:AddToggle({text = "Leafs", flag = "removalsLeafs", tooltip = "Removes leafs. Increases perfomance.", callback = function(State)
    if State then
        for i, v in next, workspace.SpawnerZones.Foliage:GetDescendants() do
            if v:IsA("MeshPart") and v.TextureID == "" then
                leafTable[i] = {
                    Part = v,
                    Old = v.Parent
                }
                v.Parent = CoreGui
            end
        end
    else
        pcall(function()
            for i, v in pairs(leafTable) do
                v.Part.Parent = v.Old
            end
            leafTable = {}
        end)
    end
end})

-- Players - Players
local joinedAfterMe = {}
updateInfo = LPH_JIT_MAX(function(Name, Again)
    local Player = Players:FindFirstChild(Name)
    if not Player then return end
    if not Again then
        Options.playersName:SetText(("Name: %s"):format(Name))
        Options.playersAge:SetText(("Account Age: %sd"):format(Player.AccountAge))
        local User = game:HttpGet("https://users.roblox.com/v1/users/"..Player.UserId)
        local Data = HttpService:JSONDecode(User)
        Options.playersDate:SetText(("Join Date: %s"):format(Data.created:sub(1,10)))
        Options.playersMembership:SetText(("Roblox Membership: %s"):format(tostring(gethiddenproperty(Player, "MembershipTypeReplicate")):sub(21)))
        Options.playersJoined:SetText(("Joined Server After You: %s"):format(table.find(joinedAfterMe, Name) and "Yes" or "No"))
    end
    local Character, Health, Distance, Invis, Noclip, God = ESP:Get_Character(Player), "-", "-", "-", "-", "-"
    if Character then
        local Head, HumanoidRootPart, Humanoid = Character:FindFirstChild("Head"), Character:FindFirstChild("HumanoidRootPart"), Character:FindFirstChildOfClass("Humanoid")
        if Humanoid and HumanoidRootPart then
            Distance = tostring(math.floor((HumanoidRootPart.Position - Camera.CFrame.p).Magnitude / 3.5714285714 + 0.5)).."m"
            Health = tostring(math.floor(Humanoid.Health + 0.5))
            Invis = Head.Transparency == 1 and "Yes" or ReplicatedPlayers[Player.Name].Status.GameplayVariables:GetAttribute("Invisible") == true and "Yes" or "No"
            God = ReplicatedPlayers[Player.Name].Status.GameplayVariables:GetAttribute("GodMode") == true and "Yes" or "No"
            Noclip = (Humanoid.RigType == "R15" and Character.UpperTorso.CanCollide == false and "Yes") or (Humanoid.RigType == "R6" and Character.Torso.CanCollide == false and "Yes") or "No"
        end
    end
    local Team = ESP:Get_Team(Player)
    Options.playersTeam:SetText(("Team: %s"):format((Team ~= nil and tostring(Team)) or "None"))
    Options.playersInvis:SetText(("Invisible: %s"):format(Invis))
    Options.playersGod:SetText(("God Mode: %s"):format(God))
    Options.playersNoclipping:SetText(("Noclipping: %s"):format(Noclip))
    Options.playersHealth:SetText(("Health: %s"):format(Health))
    Options.playersDistance:SetText(("Distance: %s"):format(Distance))
    Options.playersTool:SetText(("Tool: %s"):format(ESP:Get_Tool(Player)))
end)
Sections.Players.Players:AddList({text = "Player", flag = "playersPlayer", callback = LPH_JIT_MAX(function(Name)
    updateInfo(Name)
end)})
Sections.Players.Players:AddText({text = "Name: -", flag = "playersName"})
Sections.Players.Players:AddText({text = "Account Age: -", flag = "playersAge"})
Sections.Players.Players:AddText({text = "Join Date: -", flag = "playersDate"})
Sections.Players.Players:AddText({text = "Roblox Membership: -", flag = "playersMembership"})
Sections.Players.Players:AddText({text = "Joined Server After You: -", flag = "playersJoined"})
Sections.Players.Players:AddText({text = "Team: -", flag = "playersTeam"})
Sections.Players.Players:AddText({text = "Invisible: -", flag = "playersInvis"})
Sections.Players.Players:AddText({text = "God Mode: -", flag = "playersGod"})
Sections.Players.Players:AddText({text = "Noclipping: -", flag = "playersNoclipping"})
Sections.Players.Players:AddText({text = "Health: -", flag = "playersHealth"})
Sections.Players.Players:AddText({text = "Distance: -", flag = "playersDistance"})
Sections.Players.Players:AddText({text = "Tool: -", flag = "playersTool"})

local isSpectating, SubjectChanged, HumanoidDied = false, nil, nil
Sections.Players.Players:AddButton({text = "Spectate", flag = "spectateButton", callback = LPH_JIT_MAX(function()
    if not isSpectating then
        pcall(function()
            local Character = LocalPlayer.Character
            if Character then
                local Humanoid = Character:FindFirstChildOfClass("Humanoid")
                if Humanoid then
                    Humanoid.AutoRotate = false
                end
            end
            Camera.CameraSubject = Players[Flags.playersPlayer].Character
            isSpectating = true
            Options.spectateButton:SetText("Unspectate")
            SubjectChanged = Utility:Connection(Camera:GetPropertyChangedSignal("CameraSubject"), function()
                Camera.CameraSubject = LocalPlayer.Character
                local Character = LocalPlayer.Character
                if Character then
                    local Humanoid, HumanoidRootPart = Character:FindFirstChildOfClass("Humanoid"), Character:FindFirstChild("HumanoidRootPart")
                    if Humanoid and HumanoidRootPart then
                        Camera.CFrame = CFrame.lookAt(Camera.CFrame.p, Camera.CFrame.p + HumanoidRootPart.CFrame.LookVector)
                        Humanoid.AutoRotate = true
                    end
                end
                isSpectating = false
                Options.spectateButton:SetText("Spectate")
                SubjectChanged:Disconnect()
                SubjectChanged = nil
            end)
            local Humanoid = Players[Flags.playersPlayer].Character:FindFirstChildOfClass("Humanoid")
            if Humanoid then
                HumanoidDied = Utility:Connection(Humanoid.Died, function()
                    Camera.CameraSubject = LocalPlayer.Character
                    local Character = LocalPlayer.Character
                    if Character then
                        local Humanoid, HumanoidRootPart = Character:FindFirstChildOfClass("Humanoid"), Character:FindFirstChild("HumanoidRootPart")
                        if Humanoid and HumanoidRootPart then
                            Camera.CFrame = CFrame.lookAt(Camera.CFrame.p, Camera.CFrame.p + HumanoidRootPart.CFrame.LookVector)
                            Humanoid.AutoRotate = true
                        end
                    end
                    isSpectating = false
                    Options.spectateButton:SetText("Spectate")
                    HumanoidDied:Disconnect()
                    HumanoidDied = nil
                end)
            end
        end)
    else
        pcall(function()
            if SubjectChanged ~= nil then
                SubjectChanged:Disconnect()
                SubjectChanged = nil
            end
            if HumanoidDied ~= nil then
                HumanoidDied:Disconnect()
                HumanoidDied = nil
            end
            Camera.CameraSubject = LocalPlayer.Character
            local Character = LocalPlayer.Character
            if Character then
                local Humanoid, HumanoidRootPart = Character:FindFirstChildOfClass("Humanoid"), Character:FindFirstChild("HumanoidRootPart")
                if Humanoid and HumanoidRootPart then
                    Camera.CFrame = CFrame.lookAt(Camera.CFrame.p, Camera.CFrame.p + HumanoidRootPart.CFrame.LookVector)
                    Humanoid.AutoRotate = true
                end
            end
            isSpectating = false
            Options.spectateButton:SetText("Spectate")
        end)
    end
end)})

Sections.Players.Players:AddButton({text = "Update", callback = LPH_JIT_MAX(function()
    updateInfo(Flags.playersPlayer, true)
end)})

for _, Player in pairs(Players:GetPlayers()) do
    Options.playersPlayer:AddValue(Player.Name)
end

local staffInServer = {}
local staffDatabase
--[[local staffDatabase = syn.request({Url = 'https://testedhub.dev/uac/fetch-users?apikey=7eea209149c8c0bc81d525a1d2dc2f6d2a9ec052947a4200a9f0096751c5b45f', Method = 'GET'})
if staffDatabase.Success then
    staffDatabase = HttpService:JSONDecode(staffDatabase.Body)
    for _, Data in pairs(staffDatabase) do
        if type(Data) == "table" then
            table.insert(staffDatabase, tonumber(Data.userid));
        end
    end
else]]
    staffDatabase = {}
    Library:SendNotification('Could not connect to staff database. Some staff may not be detected (God, Invisible still detected).', 15, Color3.new(1, 0, 0))
--end
local adminAlarm = Framework:Instance("Sound", {SoundId = "rbxassetid://176820116", Volume = 10, Parent = CoreGui})
local adminFinder = {}
adminFinder.__index = adminFinder
function adminFinder:Check(Player, Joined)
    task.spawn(function()
        local ReplicatedPlayersPlayer = ReplicatedPlayers:WaitForChild(Player.Name)
        local Status = ReplicatedPlayersPlayer:WaitForChild("Status")
        local GameplayVariables = Status:WaitForChild("GameplayVariables")
        local Invisible, GodMode = GameplayVariables:GetAttribute("Invisible"), GameplayVariables:GetAttribute("GodMode")
        local Reason, inStaffDatabase = "", table.find(staffDatabase, Player.UserId)
        local UACRole, VikingRole = "", ""
        pcall(function()
            UACRole = Player:GetRoleInGroup(13810797)
        end)
        pcall(function()
            VikingRole = Player:GetRoleInGroup(3765739)
        end)
        if Reason == "" and inStaffDatabase then
            Reason = "Database"
        end
        if Reason == "" and Invisible == true then
            Reason = "Invisible"
        end
        if Reason == "" and GodMode == true then
            Reason = "GodMode"
        end
        if Reason == "" and UACRole ~= "Guest" then
            Reason = UACRole == "Member" and "Staff" or UACRole
        end
        if Reason == "" and not table.find({"Guest", "Member", "Elite Member"}, VikingRole) then
            Reason = VikingRole
        end
        if Reason ~= "" then
            if not table.find(staffInServer, Player.UserId) then
                table.insert(staffInServer, Player.UserId)
            end
            Options.serverStaff:SetText(("Staff in server: %s"):format(tostring(#staffInServer)))
            if Joined then
                Library:SendNotification(("Untrusted user or staff joined your server. | Name: %s, Reason: %s"):format(Player.Name, Reason), 60, Color3.new(1, 0, 0))
            else
                Library:SendNotification(("Untrusted user or staff was found in your server. | Name: %s, Reason: %s"):format(Player.Name, Reason), 60, Color3.new(1, 0, 0))
            end
            adminAlarm:Play()
            --syn.request({Url = ('https://testedhub.dev/uac/send-latest?apikey=%s&username=%s&userid=%s&jobid=%s&pop=%s'):format('7eea209149c8c0bc81d525a1d2dc2f6d2a9ec052947a4200a9f0096751c5b45f', Player.Name, Player.UserId, game.JobId, #Players:GetPlayers()), Method = 'GET'})
        end
    end)
end

Utility:Connection(Players.PlayerAdded, LPH_JIT_MAX(function(Player)
    if Player == LocalPlayer then return end
    adminFinder:Check(Player, true)
    local cc; cc = Utility:Connection(Player.CharacterAdded, function(Character)
        local Head = Character:WaitForChild("Head")
        local ccc; ccc = Utility:Connection(Head:GetPropertyChangedSignal("Transparency"), function()
            if not table.find(staffInServer, Player.UserId) then
                table.insert(staffInServer, Player.UserId)
            end
            Options.serverStaff:SetText(("Staff in server: %s"):format(tostring(#staffInServer)))
            Library:SendNotification(("Untrusted user or staff was found in your server. | Name: %s, Reason: %s"):format(Player.Name, "Invisible"), 60, Color3.new(1, 0, 0))
            adminAlarm:Play()
            if not table.find(staffDatabase, Player.UserId) then
                --syn.request({Url = ('https://testedhub.dev/uac/add-user?apikey=%s&username=%s&userid=%s'):format('7eea209149c8c0bc81d525a1d2dc2f6d2a9ec052947a4200a9f0096751c5b45f', Player.Name, Player.UserId), Method = 'GET'});
                table.insert(staffDatabase, Player.UserId)
            end
            ccc:Disconnect()
            cc:Disconnect();
        end)
    end)
    task.spawn(function()
        local ReplicatedPlayersPlayer = ReplicatedPlayers:WaitForChild(Player.Name)
        local Status = ReplicatedPlayersPlayer:WaitForChild("Status")
        local GameplayVariables = Status:WaitForChild("GameplayVariables")
        local c; c = Utility:Connection(GameplayVariables.AttributeChanged, function(Attribute)
            if Attribute:lower() == 'invisible' or Attribute:lower() == 'godmode' then
                if not table.find(staffInServer, Player.UserId) then
                    table.insert(staffInServer, Player.UserId)
                end
                Options.serverStaff:SetText(("Staff in server: %s"):format(tostring(#staffInServer)))
                Library:SendNotification(("Untrusted user or staff was found in your server. | Name: %s, Reason: %s"):format(Player.Name, Attribute), 60, Color3.new(1, 0, 0))
                adminAlarm:Play()
                if not table.find(staffDatabase, Player.UserId) then
                    --syn.request({Url = ('https://testedhub.dev/uac/add-user?apikey=%s&username=%s&userid=%s'):format('7eea209149c8c0bc81d525a1d2dc2f6d2a9ec052947a4200a9f0096751c5b45f', Player.Name, Player.UserId), Method = 'GET'});
                    table.insert(staffDatabase, Player.UserId)
                end
                c:Disconnect();
            end
        end)
    end)
    table.insert(joinedAfterMe, Player.Name)
    Options.playersPlayer:AddValue(Player.Name)
    ESP:Player(Player)
    Options.serverStaff:SetText(("Staff in server: %s"):format(tostring(#staffInServer)))
end))

Utility:Connection(Players.PlayerRemoving, LPH_JIT_MAX(function(Player)
    if Player == LocalPlayer then return end
    local inDb = table.find(staffInServer, Player.UserId)
    if inDb then
        table.remove(staffInServer, inDb)
        Library:SendNotification(("Untrusted user or staff has left your server. | Name: %s"):format(Player.Name), 60, Color3.new(1, 0, 0))
        adminAlarm:Play()
    end
    local Object = ESP:GetObject(Player)
    if Object then
        Object:Destroy()
    end
    for i, v in pairs(joinedAfterMe) do
        if v == Player.Name then
            joinedAfterMe[i] = nil
        end
    end
    Options.playersPlayer:RemoveValue(Player.Name)
    Options.serverStaff:SetText(("Staff in server: %s"):format(tostring(#staffInServer)))
end))

-- Players - Server
Sections.Players.Server:AddText({text = "Staff in server: 0", flag = "serverStaff"})

for _, Player in pairs(Players:GetPlayers()) do
    if Player == LocalPlayer then continue end
    adminFinder:Check(Player)
    local cc; cc = Utility:Connection(Player.CharacterAdded, function(Character)
        local Head = Character:WaitForChild("Head")
        local ccc; ccc = Utility:Connection(Head:GetPropertyChangedSignal("Transparency"), function()
            if not table.find(staffInServer, Player.UserId) then
                table.insert(staffInServer, Player.UserId)
            end
            Options.serverStaff:SetText(("Staff in server: %s"):format(tostring(#staffInServer)))
            Library:SendNotification(("Untrusted user or staff was found in your server. | Name: %s, Reason: %s"):format(Player.Name, "Invisible"), 60, Color3.new(1, 0, 0))
            adminAlarm:Play()
            if not table.find(staffDatabase, Player.UserId) then
                --syn.request({Url = ('https://testedhub.dev/uac/add-user?apikey=%s&username=%s&userid=%s'):format('7eea209149c8c0bc81d525a1d2dc2f6d2a9ec052947a4200a9f0096751c5b45f', Player.Name, Player.UserId), Method = 'GET'});
                table.insert(staffDatabase, Player.UserId)
            end
            ccc:Disconnect()
            cc:Disconnect();
        end)
    end)
    task.spawn(function()
        local ReplicatedPlayersPlayer = ReplicatedPlayers:WaitForChild(Player.Name)
        local Status = ReplicatedPlayersPlayer:WaitForChild("Status")
        local GameplayVariables = Status:WaitForChild("GameplayVariables")
        local c; c = Utility:Connection(GameplayVariables.AttributeChanged, function(Attribute)
            if Attribute:lower() == 'invisible' or Attribute:lower() == 'godmode' then
                table.insert(staffInServer, Player.UserId)
                Options.serverStaff:SetText(("Staff in server: %s"):format(tostring(#staffInServer)))
                Library:SendNotification(("Untrusted user or staff was found in your server. | Name: %s, Reason: %s"):format(Player.Name, Attribute), 60, Color3.new(1, 0, 0))
                adminAlarm:Play()
                if not table.find(staffDatabase, Player.UserId) then
                    --syn.request({Url = ('https://testedhub.dev/uac/add-user?apikey=%s&username=%s&userid=%s'):format('7eea209149c8c0bc81d525a1d2dc2f6d2a9ec052947a4200a9f0096751c5b45f', Player.Name, Player.UserId), Method = 'GET'});
                    table.insert(staffDatabase, Player.UserId)
                end
                c:Disconnect();
            end
        end)
    end)
    if Player.Character then
        task.spawn(function()
            local Head = Player.Character:FindFirstChild("Head")
            if Head then
                local cccc; cccc = Utility:Connection(Head:GetPropertyChangedSignal("Transparency"), function()
                    if not table.find(staffInServer, Player.UserId) then
                        table.insert(staffInServer, Player.UserId)
                    end
                    Options.serverStaff:SetText(("Staff in server: %s"):format(tostring(#staffInServer)))
                    Library:SendNotification(("Untrusted user or staff was found in your server. | Name: %s, Reason: %s"):format(Player.Name, "Invisible"), 60, Color3.new(1, 0, 0))
                    adminAlarm:Play()
                    if not table.find(staffDatabase, Player.UserId) then
                        --syn.request({Url = ('https://testedhub.dev/uac/add-user?apikey=%s&username=%s&userid=%s'):format('7eea209149c8c0bc81d525a1d2dc2f6d2a9ec052947a4200a9f0096751c5b45f', Player.Name, Player.UserId), Method = 'GET'});
                        table.insert(staffDatabase, Player.UserId)
                    end
                    cccc:Disconnect()
                end)
                if Head.Transparency ~= 0 then
                    if not table.find(staffInServer, Player.UserId) then
                        table.insert(staffInServer, Player.UserId)
                    end
                    Options.serverStaff:SetText(("Staff in server: %s"):format(tostring(#staffInServer)))
                    Library:SendNotification(("Untrusted user or staff was found in your server. | Name: %s, Reason: %s"):format(Player.Name, "Invisible"), 60, Color3.new(1, 0, 0))
                    adminAlarm:Play()
                    if not table.find(staffDatabase, Player.UserId) then
                        --syn.request({Url = ('https://testedhub.dev/uac/add-user?apikey=%s&username=%s&userid=%s'):format('7eea209149c8c0bc81d525a1d2dc2f6d2a9ec052947a4200a9f0096751c5b45f', Player.Name, Player.UserId), Method = 'GET'});
                        table.insert(staffDatabase, Player.UserId)
                    end
                end
            end
        end)
        task.spawn(function()
            local ReplicatedPlayersPlayer = ReplicatedPlayers:WaitForChild(Player.Name)
            local Status = ReplicatedPlayersPlayer:WaitForChild("Status")
            local GameplayVariables = Status:WaitForChild("GameplayVariables")
            local Invisible, GodMode = GameplayVariables:GetAttribute("Invisible"), GameplayVariables:GetAttribute("GodMode")
            if Invisible == true then
                if not table.find(staffInServer, Player.UserId) then
                    table.insert(staffInServer, Player.UserId)
                end
                Options.serverStaff:SetText(("Staff in server: %s"):format(tostring(#staffInServer)))
                Library:SendNotification(("Untrusted user or staff was found in your server. | Name: %s, Reason: %s"):format(Player.Name, "Invisible"), 60, Color3.new(1, 0, 0))
                adminAlarm:Play()
                if not table.find(staffDatabase, Player.UserId) then
                    --syn.request({Url = ('https://testedhub.dev/uac/add-user?apikey=%s&username=%s&userid=%s'):format('7eea209149c8c0bc81d525a1d2dc2f6d2a9ec052947a4200a9f0096751c5b45f', Player.Name, Player.UserId), Method = 'GET'});
                    table.insert(staffDatabase, Player.UserId)
                end
            elseif GodMode == true then
                if not table.find(staffInServer, Player.UserId) then
                    table.insert(staffInServer, Player.UserId)
                end
                Options.serverStaff:SetText(("Staff in server: %s"):format(tostring(#staffInServer)))
                Library:SendNotification(("Untrusted user or staff was found in your server. | Name: %s, Reason: %s"):format(Player.Name, "GodMode"), 60, Color3.new(1, 0, 0))
                adminAlarm:Play()
                if not table.find(staffDatabase, Player.UserId) then
                    --syn.request({Url = ('https://testedhub.dev/uac/add-user?apikey=%s&username=%s&userid=%s'):format('7eea209149c8c0bc81d525a1d2dc2f6d2a9ec052947a4200a9f0096751c5b45f', Player.Name, Player.UserId), Method = 'GET'});
                    table.insert(staffDatabase, Player.UserId)
                end
            end
        end)
    end
end

-- Settings - Other
Sections.Settings.Other:AddToggle({text = "Improved Visible Check", flag = "improvedVisibleCheck", tooltip = "Improves visible check by multi casting rays. Medium low perfomance impact.", callback = function(State)
    ESP.Settings.Improved_Visible_Check = State
end}):SetState(true)

Sections.Settings.Other:AddSlider({text = "Between Clicks Time", flag = "betweenClickTime", tooltip = "Wait time between mouse press and mouse release.", min = 0, max = 1, increment = 0.01})

-- Unload
Utility:Connection(Library.unloaded, LPH_JIT_MAX(function()
    Running = false
    task.spawn(function()
        task.wait()
        pcall(function()
            for i, v in pairs(leafTable) do
                v.Part.Parent = v.Old
            end
            leafTable = {}
        end)
        for Index, Asset in pairs(SkyBoxes.Standard) do
            Sky[Index] = Asset
        end
        for _, Object in pairs(ESP.Objects) do
            Object:Destroy()
        end
        ESP_RenderStepped:Disconnect()
        adminAlarm:Destroy()
        ChatScript.CreateMessageLabel = ChatScript_CreateMessageLabel
        if Clouds then Clouds.Parent = Terrain end
        if Atmosphere then Atmosphere.Parent = Lighting end
        InventoryViewer:Clear()
        InventoryViewer.Main:Remove()
        headSound:Destroy()
        bodySound:Destroy()
        killSound:Destroy()
        FPS.new = FPS_new
        VFX.Impact = VFX_Impact
        VFX.RecoilCamera = VFX_RecoilCamera
        for Property, Value in pairs(Old_Lighting) do
            pcall(function()
                Lighting[Property] = Value
                if Property == "Technology" then
                    sethiddenproperty(Lighting, "Technology", Old_Lighting.Technology)
                end
            end)
        end
        sethiddenproperty(Terrain, "Decoration", Old_Decoration)
        Camera.FieldOfView = Old_Camera.FieldOfView
        FOV_Circle:Remove()
        FOV_Circle = nil
        if LocalPlayer.Character then
            local Humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if Humanoid then
                Humanoid.PlatformStand = false
            end
        end
        Workspace.Gravity = Old_Gravity
        for _, connection in pairs(getconnections(Workspace:GetPropertyChangedSignal("Gravity"))) do
            connection:Enable()
        end
        for _, connection in pairs(getconnections(Workspace.Changed)) do
            connection:Enable()
        end
        local Character = LocalPlayer.Character
        if Character then
            local Humanoid = Character:FindFirstChildOfClass("Humanoid")
            if Humanoid then
                for _, connection in pairs(getconnections(Humanoid.StateChanged)) do
                    connection:Enable()
                end
            end
        end
        VisualizeLagFolder:Destroy()
        VisualizeLagFolder = nil
        settings().Network.IncomingReplicationLag = 0
        NetworkClient:SetOutgoingKBPSLimit(math.huge)
        FreeCamera:Unload()
        Running, Loaded = nil
    end)
end))

syn.request({
    Url = "http://127.0.0.1:6463/rpc?v=1",
    Method = "POST",
    Headers = {
        ["Content-Type"] = "application/json",
        Origin = "https://discord.com"
    },
    Body = game:GetService("HttpService"):JSONEncode({
        cmd = "INVITE_BROWSER",
        nonce = game:GetService("HttpService"):GenerateGUID(false),
        args = {code = "uvV5B24nAP"};
    });
});

Loaded = true