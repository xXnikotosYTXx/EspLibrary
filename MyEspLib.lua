local Config = {
    Box               = false,
    BoxOutline        = false,
    BoxColor          = Color3.fromRGB(255,255,255),
    BoxOutlineColor   = Color3.fromRGB(0,0,0),
    HealthBar         = true, -- Включаем отображение здоровья
    HealthBarSide     = "Left", -- Left,Bottom,Right
    Names             = false,
    NamesOutline      = false,
    NamesColor        = Color3.fromRGB(255,255,255),
    NamesOutlineColor = Color3.fromRGB(0,0,0),
    NamesFont         = 2, -- 0,1,2,3
    NamesSize         = 13,
    MaxDistance       = 350  -- Максимальное расстояние в метрах
}

function CreateEsp(Player)
    local Box,BoxOutline,Name,HealthBar,HealthBarOutline = Drawing.new("Square"),Drawing.new("Square"),Drawing.new("Text"),Drawing.new("Square"),Drawing.new("Square")
    local Updater = game:GetService("RunService").RenderStepped:Connect(function()
    if Player.Character ~= nil and Player.Character:FindFirstChild("Humanoid") ~= nil and Player.Character:FindFirstChild("HumanoidRootPart") ~= nil and Player.Character.Humanoid.Health > 0 and Player.Character:FindFirstChild("Head") ~= nil then
            local Target2dPosition,IsVisible = workspace.CurrentCamera:WorldToViewportPoint(Player.Character.HumanoidRootPart.Position)
            local distance = (workspace.CurrentCamera.CFrame.p - Player.Character.HumanoidRootPart.Position).magnitude  -- Вычисление дистанции
            if distance > Config.MaxDistance then  -- Если игрок слишком далеко, скрываем ESP
                Box.Visible = false
                BoxOutline.Visible = false
                Name.Visible = false
                HealthBar.Visible = false
                HealthBarOutline.Visible = false
                return
            end
            
            local scale_factor = 1 / (Target2dPosition.Z * math.tan(math.rad(workspace.CurrentCamera.FieldOfView * 0.5)) * 2) * 100
            local width, height = math.floor(40 * scale_factor), math.floor(60 * scale_factor)
            if Config.Box then
                Box.Visible = IsVisible
                Box.Color = Config.BoxColor
                Box.Size = Vector2.new(width,height)
                Box.Position = Vector2.new(Target2dPosition.X - Box.Size.X / 2,Target2dPosition.Y - Box.Size.Y / 2)
                Box.Thickness = 1
                Box.ZIndex = 69
                if Config.BoxOutline then
                    BoxOutline.Visible = IsVisible
                    BoxOutline.Color = Config.BoxOutlineColor
                    BoxOutline.Size = Vector2.new(width,height)
                    BoxOutline.Position = Vector2.new(Target2dPosition.X - Box.Size.X / 2,Target2dPosition.Y - Box.Size.Y / 2)
                    BoxOutline.Thickness = 3
                    BoxOutline.ZIndex = 1
                else
                    BoxOutline.Visible = false
                end
            else
                Box.Visible = false
                BoxOutline.Visible = false
            end
            if Config.Names then
                Name.Visible = IsVisible
                Name.Color = Config.NamesColor
                Name.Text = Player.Name.." "..math.floor(distance).."m"
                Name.Center = true
                Name.Outline = Config.NamesOutline
                Name.OutlineColor = Config.NamesOutlineColor
                Name.Position = Vector2.new(Target2dPosition.X,Target2dPosition.Y - height * 0.5 + -15)
                Name.Font = Config.NamesFont
                Name.Size = Config.NamesSize
            else
                Name.Visible = false
            end
            if Config.HealthBar then
                -- Задаем параметры для внешней рамки полосы здоровья
                HealthBarOutline.Visible = IsVisible
                HealthBarOutline.Color = Color3.fromRGB(0,0,0)
                HealthBarOutline.Filled = true
                HealthBarOutline.ZIndex = 1

                -- Задаем параметры для самой полосы здоровья
                HealthBar.Visible = IsVisible
                local humanoid = Player.Character:FindFirstChild("Humanoid")
                local healthPercentage = humanoid.Health / humanoid.MaxHealth
                HealthBar.Color = Color3.fromRGB(255,0,0):lerp(Color3.fromRGB(0,255,0), healthPercentage)
                HealthBar.Thickness = 1
                HealthBar.Filled = true
                HealthBar.ZIndex = 69

                -- В зависимости от расположения полосы здоровья на экране
                if Config.HealthBarSide == "Left" then
                    HealthBarOutline.Size = Vector2.new(2,height)
                    HealthBarOutline.Position = Vector2.new(Target2dPosition.X - Box.Size.X / 2,Target2dPosition.Y - Box.Size.Y / 2) + Vector2.new(-3,0)
                    
                    HealthBar.Size = Vector2.new(1,-(HealthBarOutline.Size.Y - 2) * healthPercentage)
                    HealthBar.Position = HealthBarOutline.Position + Vector2.new(1,-1 + HealthBarOutline.Size.Y)
                elseif Config.HealthBarSide == "Bottom" then
                    HealthBarOutline.Size = Vector2.new(width,3)
                    HealthBarOutline.Position = Vector2.new(Target2dPosition.X - Box.Size.X / 2,Target2dPosition.Y - Box.Size.Y / 2) + Vector2.new(0,height + 2)

                    HealthBar.Size = Vector2.new((HealthBarOutline.Size.X - 2) * healthPercentage,1)
                    HealthBar.Position = HealthBarOutline.Position + Vector2.new(1,-1 + HealthBarOutline.Size.Y)
                elseif Config.HealthBarSide == "Right" then
                    HealthBarOutline.Size = Vector2.new(2,height)
                    HealthBarOutline.Position = Vector2.new(Target2dPosition.X - Box.Size.X / 2,Target2dPosition.Y - Box.Size.Y / 2) + Vector2.new(width + 1,0)
                    
                    HealthBar.Size = Vector2.new(1,-(HealthBarOutline.Size.Y - 2) * healthPercentage)
                    HealthBar.Position = HealthBarOutline.Position + Vector2.new(1,-1 + HealthBarOutline.Size.Y)
                end
            else
                HealthBar.Visible = false
                HealthBarOutline.Visible = false
            end
        else
            Box.Visible = false
            BoxOutline.Visible = false
            Name.Visible = false
            HealthBar.Visible = false
            HealthBarOutline.Visible = false
            if not Player then
                Box:Remove()
                BoxOutline:Remove()
                Name:Remove()
                HealthBar:Remove()
                HealthBarOutline:Remove()
                Updater:Disconnect()
            end
        end
    end)
end

for _,v in pairs(game:GetService("Players"):GetPlayers()) do
   if v ~= game:GetService("Players").LocalPlayer then
      CreateEsp(v)
      v.CharacterAdded:Connect(CreateEsp(v))
   end
end

game:GetService("Players").PlayerAdded:Connect(function(v)
   if v ~= game:GetService("Players").LocalPlayer then
      CreateEsp(v)
      v.CharacterAdded:Connect(CreateEsp(v))
   end
end)

return Config
