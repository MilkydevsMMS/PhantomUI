-- PhantomUI Library by ChatGPT
local PhantomUI = {}
local UIS = game:GetService("UserInputService")

local theme = {
    background = Color3.fromRGB(30, 30, 30),
    text = Color3.fromRGB(255, 255, 255),
    accent = Color3.fromRGB(0, 120, 255),
    dark = true
}

function PhantomUI:ToggleTheme()
    if theme.dark then
        theme.background = Color3.fromRGB(240, 240, 240)
        theme.text = Color3.fromRGB(10, 10, 10)
        theme.accent = Color3.fromRGB(0, 120, 255)
        theme.dark = false
    else
        theme.background = Color3.fromRGB(30, 30, 30)
        theme.text = Color3.fromRGB(255, 255, 255)
        theme.accent = Color3.fromRGB(0, 120, 255)
        theme.dark = true
    end
end

function PhantomUI:CreateWindow(title)
    local elements = {}
    local dragging = false
    local dragStart, startPos

    local frame = Drawing.new("Square")
    frame.Size = Vector2.new(300, 250)
    frame.Position = Vector2.new(100, 100)
    frame.Color = theme.background
    frame.Filled = true
    frame.Visible = true

    local header = Drawing.new("Text")
    header.Text = title or "Window"
    header.Size = 16
    header.Color = theme.text
    header.Position = frame.Position + Vector2.new(10, 10)
    header.Outline = true
    header.Visible = true

    local function updatePos()
        header.Position = frame.Position + Vector2.new(10, 10)
        for _, v in ipairs(elements) do
            if v.__type == "button" then
                v.Text.Position = frame.Position + v.Offset
            end
        end
    end

    -- Draggable
    UIS.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mouse = Vector2.new(input.Position.X, input.Position.Y)
            if mouse.X >= frame.Position.X and mouse.X <= frame.Position.X + frame.Size.X and
               mouse.Y >= frame.Position.Y and mouse.Y <= frame.Position.Y + 25 then
                dragging = true
                dragStart = mouse
                startPos = frame.Position
            end
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStart
            frame.Position = startPos + delta
            updatePos()
        end
    end)

    -- Add Button
    function elements:AddButton(text, callback)
        local buttonText = Drawing.new("Text")
        buttonText.Text = "[ " .. text .. " ]"
        buttonText.Size = 16
        buttonText.Color = theme.accent
        buttonText.Outline = true
        buttonText.Visible = true

        local offset = Vector2.new(10, 40 + (#elements * 25))
        buttonText.Position = frame.Position + offset

        table.insert(elements, {
            __type = "button",
            Text = buttonText,
            Offset = offset
        })

        -- Click detection
        UIS.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local mouse = Vector2.new(input.Position.X, input.Position.Y)
                if mouse.X >= buttonText.Position.X and mouse.X <= buttonText.Position.X + 200 and
                   mouse.Y >= buttonText.Position.Y and mouse.Y <= buttonText.Position.Y + 20 then
                    pcall(callback)
                end
            end
        end)
    end

    -- Notification (simple toast)
    function elements:Notify(msg, duration)
        local note = Drawing.new("Text")
        note.Text = msg
        note.Size = 16
        note.Color = theme.accent
        note.Outline = true
        note.Position = Vector2.new(50, 400)
        note.Visible = true

        task.spawn(function()
            wait(duration or 3)
            note:Remove()
        end)
    end

    -- Theme Toggle Button
    elements:AddButton("Toggle Theme", function()
        PhantomUI:ToggleTheme()
        frame.Color = theme.background
        header.Color = theme.text
        for _, v in ipairs(elements) do
            if v.Text then
                v.Text.Color = theme.accent
            end
        end
    end)

    return elements
end

return PhantomUI
