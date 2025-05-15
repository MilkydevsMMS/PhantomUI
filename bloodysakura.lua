local PhantomUI = {}
local UIS = game:GetService("UserInputService")

local theme = {
    background = Color3.fromRGB(30, 30, 30),
    text = Color3.fromRGB(255, 255, 255),
    accent = Color3.fromRGB(0, 120, 255),
    dark = true
}

function PhantomUI:ToggleTheme()
    theme.dark = not theme.dark
    if theme.dark then
        theme.background = Color3.fromRGB(30, 30, 30)
        theme.text = Color3.fromRGB(255, 255, 255)
    else
        theme.background = Color3.fromRGB(240, 240, 240)
        theme.text = Color3.fromRGB(10, 10, 10)
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

    local function updateUI()
        header.Position = frame.Position + Vector2.new(10, 10)
        for _, v in ipairs(elements) do
            if v.__type == "button" then
                v.Text.Position = frame.Position + v.Offset
            end
        end
    end

    -- Mobile Drag
    UIS.TouchStarted:Connect(function(input, processed)
        local pos = Vector2.new(input.Position.X, input.Position.Y)
        if pos.X >= frame.Position.X and pos.X <= frame.Position.X + frame.Size.X and
           pos.Y >= frame.Position.Y and pos.Y <= frame.Position.Y + 25 then
            dragging = true
            dragStart = pos
            startPos = frame.Position
        end
    end)

    UIS.TouchMoved:Connect(function(input, processed)
        if dragging then
            local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStart
            frame.Position = startPos + delta
            updateUI()
        end
    end)

    UIS.TouchEnded:Connect(function(input, processed)
        dragging = false
    end)

    -- Add Mobile Button
    function elements:AddButton(text, callback)
        local button = Drawing.new("Text")
        button.Text = "[ " .. text .. " ]"
        button.Size = 16
        button.Color = theme.accent
        button.Outline = true
        button.Visible = true

        local offset = Vector2.new(10, 40 + (#elements * 30))
        button.Position = frame.Position + offset

        table.insert(elements, {
            __type = "button",
            Text = button,
            Offset = offset
        })

        UIS.TouchStarted:Connect(function(input)
            local touchPos = Vector2.new(input.Position.X, input.Position.Y)
            local bpos = button.Position
            local size = Vector2.new(button.TextBounds.X, button.TextBounds.Y)

            if touchPos.X >= bpos.X and touchPos.X <= bpos.X + size.X and
               touchPos.Y >= bpos.Y and touchPos.Y <= bpos.Y + size.Y then
                pcall(callback)
            end
        end)
    end

    -- Notify
    function elements:Notify(msg, duration)
        local note = Drawing.new("Text")
        note.Text = msg
        note.Size = 16
        note.Color = theme.accent
        note.Outline = true
        note.Position = Vector2.new(30, 400)
        note.Visible = true

        task.spawn(function()
            wait(duration or 3)
            note:Remove()
        end)
    end

    -- Theme toggle button
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
