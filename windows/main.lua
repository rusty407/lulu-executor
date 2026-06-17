local utf8 = require("utf8")

-- ==================== CONFIG & STATE ====================
local WINDOW_W, WINDOW_H = love.graphics.getDimensions()

local THEME = {
    bg = {10/255, 10/255, 15/255, 1},
    panel = {20/255, 20/255, 30/255, 1},
    panel2 = {15/255, 15/255, 25/255, 1},
    accent_cyan = {0/255, 255/255, 255/255, 1},
    accent_green = {0/255, 255/255, 100/255, 1},
    accent_purple = {180/255, 0/255, 255/255, 1},
    text = {230/255, 230/255, 235/255, 1},
    text_dim = {160/255, 160/255, 170/255, 1},
    success = {0/255, 255/255, 120/255, 1},
    error = {255/255, 80/255, 80/255, 1},
}

local STATE = {
    velocityState = "NotAttached", -- NotAttached | Attaching | Attached | Executed | Error
    statusText = "Status: Not Attached",
    statusColor = THEME.text_dim,
    consoleLogs = {},
    tabs = {
        {name = "script1.lua", content = "-- Welcome to Velocity Neon\nprint(\"Hello from Neon Executor!\")", cursorX = 1, cursorY = 1, scrollY = 0, modified = false}
    },
    activeTab = 1,
    cursorBlink = 0,
    showFindReplace = false,
    findText = "",
    replaceText = "",
}

local FONT = love.graphics.newFont("fonts/consola.ttf", 16) -- Assume user places a monospace font or fallback
if not love.filesystem.getInfo("fonts/consola.ttf") then
    FONT = love.graphics.newFont(16) -- system fallback
end
love.graphics.setFont(FONT)

local LINE_HEIGHT = 22
local EDITOR_PADDING = 20
local SCROLLBAR_WIDTH = 12

-- Button helper
local function createButton(x, y, w, h, text, color)
    return {x=x, y=y, w=w, h=h, text=text, baseColor=color or THEME.accent_cyan, hover=false}
end

local buttons = {
    attach = createButton(40, 40, 160, 50, "⚡ ATTACH", THEME.accent_green),
    execute = createButton(220, 40, 120, 50, "Execute", THEME.accent_purple),
    newTab = createButton(1280-180, 15, 40, 30, "+", THEME.accent_cyan),
}

-- ==================== HELPER FUNCTIONS ====================
local function logConsole(msg, level)
    level = level or "info"
    table.insert(STATE.consoleLogs, {text = os.date("%H:%M:%S") .. " | " .. msg, level = level})
    if #STATE.consoleLogs > 200 then table.remove(STATE.consoleLogs, 1) end
end

local function getActiveEditor()
    return STATE.tabs[STATE.activeTab]
end

local function splitLines(text)
    local lines = {}
    for s in text:gmatch("[^\r\n]+") do
        table.insert(lines, s)
    end
    if text:sub(-1) == "\n" then table.insert(lines, "") end
    return lines
end

local function getLine(editor, n)
    local lines = splitLines(editor.content)
    return lines[n] or ""
end

-- Base64 helper for Velocity pipe (Windows Named Pipe integration)
local function base64_encode(data)
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    return ((data:gsub('.', function(x)
        local r, s = '', x:byte()
        for i=8,1,-1 do r = r .. (s % 2^i - s % 2^(i-1) > 0 and '1' or '0') end
        return r
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c = 0
        for i=1,6 do c = c + (x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end):gsub('..$', function(x)
        if #x == 2 then return b:sub(x:byte(1)-47)..b:sub(x:byte(2)-47)..'==' end
        return b:sub(x:byte(1)-47)..'==='
    end))
end

-- ==================== VELOCITY PIPE INTEGRATION ====================
--[[
    PRODUCTION INTEGRATION NOTE:
    In a real deployment, replace the local loadstring with a pipe write:

    local pipeName = "\\\\.\\pipe\\uoQcySKXSUxxJNpVQyatpHQwYoGfhcbh_" .. tostring(love.system.getPID() or 1234)
    -- Use ffi (luajit) or external DLL bridge to WriteFile on Named Pipe
    -- Example pseudocode:
    -- local encoded = base64_encode(editor.content)
    -- Write to pipe: "EXECUTE:" .. encoded
    -- Velocity backend (C# .NET 8) listens on this pipe and injects into target process.

    Folders expected by Velocity: /Scripts, /Workspace, /AutoExec
    Save files via love.filesystem.write("Scripts/neon_script.lua", content)
--]]
local function sendToVelocity(editor)
    logConsole("Sending script to Velocity backend...", "info")

    -- Local testing fallback
    local success, err = pcall(function()
        local chunk, loadErr = loadstring(editor.content)
        if chunk then
            chunk()
            STATE.velocityState = "Executed"
            logConsole("Script executed successfully (local test)", "success")
        else
            error(loadErr)
        end
    end)

    if not success then
        STATE.velocityState = "Error"
        logConsole("Execution error: " .. tostring(err), "error")
    end

    -- Real pipe would go here (commented)
    --[[
    local encoded = base64_encode(editor.content)
    -- ffi.C or external bridge: write to named pipe
    logConsole("Script delivered via Named Pipe (Base64)", "success")
    --]]
end

-- ==================== DRAWING ====================
local function drawNeonRect(x, y, w, h, color, thickness)
    love.graphics.setColor(color[1], color[2], color[3], 0.15)
    love.graphics.rectangle("fill", x, y, w, h, 8, 8)
    love.graphics.setColor(color)
    love.graphics.setLineWidth(thickness or 2)
    love.graphics.rectangle("line", x, y, w, h, 8, 8)
end

local function drawEditor()
    local editor = getActiveEditor()
    local lines = splitLines(editor.content)
    local visibleLines = math.floor((WINDOW_H - 280) / LINE_HEIGHT)

    -- Background
    love.graphics.setColor(THEME.panel)
    love.graphics.rectangle("fill", 40, 120, WINDOW_W - 80, WINDOW_H - 280, 8, 8)

    -- Line numbers rail
    love.graphics.setColor(0.08, 0.08, 0.12, 1)
    love.graphics.rectangle("fill", 40, 120, 50, WINDOW_H - 280)

    love.graphics.setScissor(40, 120, WINDOW_W - 80, WINDOW_H - 280)

    -- Lines
    for i = 1, #lines do
        local y = 130 + (i - 1 - editor.scrollY) * LINE_HEIGHT
        if y < 120 or y > WINDOW_H - 160 then goto continue end

        -- Current line highlight
        if i == editor.cursorY then
            love.graphics.setColor(0.15, 0.25, 0.35, 0.6)
            love.graphics.rectangle("fill", 40, y - 2, WINDOW_W - 100, LINE_HEIGHT)
            -- Left accent rail
            love.graphics.setColor(THEME.accent_cyan)
            love.graphics.rectangle("fill", 42, y - 2, 4, LINE_HEIGHT)
        end

        -- Line number
        love.graphics.setColor(THEME.text_dim)
        love.graphics.print(string.format("%3d", i), 48, y)

        -- Code
        love.graphics.setColor(THEME.text)
        love.graphics.print(lines[i] or "", 100, y)

        ::continue::
    end

    love.graphics.setScissor()

    -- Cursor
    STATE.cursorBlink = STATE.cursorBlink + love.timer.getDelta()
    if math.floor(STATE.cursorBlink * 2) % 2 == 0 then
        local cursorLine = getLine(editor, editor.cursorY)
        local cursorStr = cursorLine:sub(1, editor.cursorX - 1)
        local cursorPx = 100 + FONT:getWidth(cursorStr)
        local cy = 130 + (editor.cursorY - 1 - editor.scrollY) * LINE_HEIGHT

        love.graphics.setColor(THEME.accent_cyan)
        love.graphics.setLineWidth(2)
        love.graphics.line(cursorPx, cy, cursorPx, cy + LINE_HEIGHT - 4)

        -- Top nub
        love.graphics.rectangle("fill", cursorPx - 3, cy - 4, 7, 4)
    end

    -- Scrollbar
    if #lines > visibleLines then
        local scrollH = (WINDOW_H - 280) * (visibleLines / #lines)
        local scrollY = 120 + (editor.scrollY / (#lines - visibleLines)) * (WINDOW_H - 280 - scrollH)
        drawNeonRect(WINDOW_W - 60, scrollY, SCROLLBAR_WIDTH, scrollH, THEME.accent_cyan, 1)
    end
end

local function drawTabs()
    for i, tab in ipairs(STATE.tabs) do
        local x = 40 + (i-1) * 160
        local active = i == STATE.activeTab
        love.graphics.setColor(active and THEME.panel or THEME.panel2)
        love.graphics.rectangle("fill", x, 80, 150, 35, 6, 6)
        love.graphics.setColor(active and THEME.accent_cyan or THEME.text_dim)
        love.graphics.print(tab.name .. (tab.modified and " •" or ""), x + 12, 88)
    end
end

local function drawConsole()
    love.graphics.setColor(THEME.panel2)
    love.graphics.rectangle("fill", 40, WINDOW_H - 160, WINDOW_W - 80, 140, 8, 8)

    love.graphics.setColor(THEME.text_dim)
    love.graphics.print("CONSOLE", 55, WINDOW_H - 155)

    love.graphics.setScissor(40, WINDOW_H - 135, WINDOW_W - 90, 110)
    for i, log in ipairs(STATE.consoleLogs) do
        local y = WINDOW_H - 135 + (i-1) * 18
        if y > WINDOW_H - 30 then break end
        local col = log.level == "error" and THEME.error or (log.level == "success" and THEME.success or THEME.text)
        love.graphics.setColor(col)
        love.graphics.print(log.text, 55, y)
    end
    love.graphics.setScissor()
end

local function drawStatusBar()
    local statusColor = STATE.velocityState == "Attached" and THEME.success or
                       (STATE.velocityState == "Error" and THEME.error or THEME.text_dim)

    love.graphics.setColor(THEME.panel)
    love.graphics.rectangle("fill", 0, WINDOW_H - 20, WINDOW_W, 20)
    love.graphics.setColor(statusColor)
    love.graphics.print(STATE.statusText, 20, WINDOW_H - 18)

    love.graphics.setColor(THEME.text_dim)
    love.graphics.print("Velocity Neon Executor • Ctrl+Enter to Execute", WINDOW_W - 420, WINDOW_H - 18)
end

-- ==================== UPDATE & INPUT ====================
function love.update(dt)
    WINDOW_W, WINDOW_H = love.graphics.getDimensions()

    -- Button hover
    local mx, my = love.mouse.getPosition()
    for _, btn in pairs(buttons) do
        btn.hover = mx > btn.x and mx < btn.x + btn.w and my > btn.y and my < btn.y + btn.h
    end

    -- Attach animation simulation
    if STATE.velocityState == "Attaching" then
        if love.timer.getTime() % 1.2 < 0.6 then
            STATE.statusText = "Status: Attaching..."
        else
            STATE.statusText = "Status: Injecting..."
        end
    end
end

function love.draw()
    love.graphics.clear(THEME.bg)

    -- Background grid effect (subtle)
    love.graphics.setColor(0.05, 0.05, 0.08, 0.6)
    for x = 0, WINDOW_W, 40 do love.graphics.line(x, 0, x, WINDOW_H) end
    for y = 0, WINDOW_H, 40 do love.graphics.line(0, y, WINDOW_W, y) end

    drawTabs()
    drawEditor()
    drawConsole()
    drawStatusBar()

    -- Buttons
    for name, btn in pairs(buttons) do
        local col = btn.hover and {btn.baseColor[1]*1.3, btn.baseColor[2]*1.3, btn.baseColor[3]*1.3, 1} or btn.baseColor
        drawNeonRect(btn.x, btn.y, btn.w, btn.h, col, 3)
        love.graphics.setColor(1,1,1,1)
        love.graphics.print(btn.text, btn.x + (btn.w - FONT:getWidth(btn.text))/2, btn.y + 14)
    end

    if STATE.showFindReplace then
        love.graphics.setColor(THEME.panel)
        love.graphics.rectangle("fill", WINDOW_W/2 - 200, 80, 400, 120, 8, 8)
        love.graphics.setColor(THEME.accent_cyan)
        love.graphics.print("Find / Replace", WINDOW_W/2 - 80, 90)
        -- Simplified - would have input fields in full version
    end
end

function love.textinput(t)
    local editor = getActiveEditor()
    local line = getLine(editor, editor.cursorY)
    editor.content = editor.content:sub(1, editor.cursorX - 1) .. t .. editor.content:sub(editor.cursorX)
    editor.cursorX = editor.cursorX + utf8.len(t)
    editor.modified = true
end

function love.keypressed(key)
    local editor = getActiveEditor()

    if key == "return" then
        -- Auto indent simulation
        local prevLine = getLine(editor, editor.cursorY)
        local indent = prevLine:match("^(%s*)") or ""
        editor.content = editor.content .. "\n" .. indent
        editor.cursorY = editor.cursorY + 1
        editor.cursorX = #indent + 1
        editor.modified = true
    elseif key == "backspace" then
        -- Basic backspace handling (full impl would be more robust)
        if editor.cursorX > 1 then
            editor.content = editor.content:sub(1, editor.cursorX - 2) .. editor.content:sub(editor.cursorX)
            editor.cursorX = editor.cursorX - 1
        elseif editor.cursorY > 1 then
            -- Join lines (simplified)
        end
        editor.modified = true
    elseif key == "left" then
        editor.cursorX = math.max(1, editor.cursorX - 1)
    elseif key == "right" then
        editor.cursorX = editor.cursorX + 1
    elseif key == "up" then
        editor.cursorY = math.max(1, editor.cursorY - 1)
        editor.cursorX = math.min(editor.cursorX, #getLine(editor, editor.cursorY) + 1)
    elseif key == "down" then
        editor.cursorY = editor.cursorY + 1
        editor.cursorX = math.min(editor.cursorX, #getLine(editor, editor.cursorY) + 1)
    elseif key == "tab" then
        editor.content = editor.content:sub(1, editor.cursorX - 1) .. "    " .. editor.content:sub(editor.cursorX)
        editor.cursorX = editor.cursorX + 4
        editor.modified = true
    end

    -- Scrolling
    local visible = math.floor((WINDOW_H - 280) / LINE_HEIGHT)
    if editor.cursorY - editor.scrollY > visible - 2 then
        editor.scrollY = editor.cursorY - visible + 2
    elseif editor.cursorY - editor.scrollY < 2 then
        editor.scrollY = math.max(0, editor.cursorY - 2)
    end
end

function love.wheelmoved(x, y)
    local editor = getActiveEditor()
    editor.scrollY = math.max(0, editor.scrollY - y * 3)
end

function love.mousepressed(mx, my, button)
    if button ~= 1 then return end

    -- Attach button
    if mx > buttons.attach.x and mx < buttons.attach.x + buttons.attach.w and
       my > buttons.attach.y and my < buttons.attach.y + buttons.attach.h then
        STATE.velocityState = "Attaching"
        STATE.statusText = "Status: Attaching..."
        logConsole("Attempting to attach to target process...")

        -- Simulate attach delay
        love.timer.after(1.2, function()
            STATE.velocityState = "Attached"
            STATE.statusText = "Status: Attached"
            logConsole("Successfully attached to Velocity target", "success")
        end)
    end

    -- Execute button
    if mx > buttons.execute.x and mx < buttons.execute.x + buttons.execute.w and
       my > buttons.execute.y and my < buttons.execute.y + buttons.execute.h then
        sendToVelocity(getActiveEditor())
    end
end

function love.resize(w, h)
    WINDOW_W, WINDOW_H = w, h
end

-- Initial log
logConsole("Velocity Neon Executor initialized", "success")
logConsole("Ready. Press ⚡ ATTACH to begin.", "info")
