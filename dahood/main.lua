local userinputservice = game:GetService('UserInputService')
local players = game:GetService('Players')
local workspace = game:GetService('Workspace')

local tau = 2 * math.pi
local camera = workspace.CurrentCamera
local client = players.LocalPlayer


local function get_player_mouse()
    local dist = fov_settings.radius
    local player = nil 
    
    for i, v in pairs(players:GetPlayers()) do 
        if (v == client) then continue end 
        
        local char = v.Character 
        local root = char and char:FindFirstChild('HumanoidRootPart')
        
        if (char and root) then 
            local pos = camera:WorldToViewportPoint(root.Position)
            local mag = (Vector2.new(pos.x, pos.y) - userinputservice:GetMouseLocation()).magnitude
            
            if (mag < dist) then 
                dist = mag 
                player = v 
            end
        end
    end
    
    return player
end

local function anti_detect()
    local target = get_player_mouse()
    
    if (not target) then return end 
    
    local char = target.Character 
    local root = char and char:FindFirstChild('HumanoidRootPart')
    
    if (char and root) then 
        local velo = root.Velocity 
        
        if (velo.x > 50 or velo.y > 50 or velo.z > 50 or velo.x < -50 or velo.y < -50 or velo.z < -50) then 
            return true 
        end
    end
    
    return false
end

local function get_ping()
    local new_ping = (anti_detect() and prediction * 16) or prediction
    return new_ping
end

local function get_prediction()
    local target = get_player_mouse()
    
    if (not target) then return end 
    
    local char = target.Character 
    local root = char and char:FindFirstChild('HumanoidRootPart')
    local humanoid = char and char:FindFirstChild('Humanoid')
    
    if (char and root and humanoid) then 
        local velocity_pred = (root.Position + (root.Velocity * get_ping()))
        local movedirection_pred = (root.Position + (humanoid.MoveDirection * get_ping()))
        
        return (anti_detect() and movedirection_pred) or velocity_pred
    end
end

local index; index = hookmetamethod(game, '__index', function(self, key)
    if (self:IsA('Mouse') and key == 'Hit') then 
        local target = get_player_mouse()
        return (target and CFrame.new(get_prediction())) or index(self, key)
    end
   
    return index(self, key) 
end)
