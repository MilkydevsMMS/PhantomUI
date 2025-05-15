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

    local function isTouch()
        return UIS.TouchEnabled and not UIS.MouseEnabled
    end

    -- Drag Support (Mouse and Mobile Touch)
    local function inputBegan(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local pos = Vector2.new(input.Position.X, input.Position.Y)
            if pos.X >= frame.Position.X and pos.X <= frame.Position.X + frame.Size.X and
               pos.Y >= frame.Position.Y and pos.Y <= frame.Position.Y + 25 then
                dragging = true
                dragStart = pos
                startPos = frame.Position
            end
        end
    end

    local function inputChanged(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
            local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStart
            frame.Position = startPos + delta
            updatePos()
        end
    end

    local function inputEnded(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end

    UIS.InputBegan:Connect(inputBegan)
    UIS.InputChanged:Connect(inputChanged)
    UIS.InputEnded:Connect(inputEnded)

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

        local function clicked(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                local pos = Vector2.new(input.Position.X, input.Position.Y)
                local p = buttonText.Position
                if pos.X >= p.X and pos.X <= p.X + 200 and pos.Y >= p.Y and pos.Y <= p.Y + 20 then
                    pcall(callback)
                end
            end
        end

        UIS.InputBegan:Connect(clicked)
    end

    -- Notification
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
