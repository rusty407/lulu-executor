--[[
    NEON EXECUTOR - A premium Roblox Lua Executor UI
    Built with Love2D for Arch Linux + Hyprland/Wayland
    Author: Neon Executor Project
    Version: 1.0.0
--]]

-- ============================================================
-- THEME SYSTEM
-- ============================================================
local theme = {
    -- Background layers
    bg_deep      = {0.04, 0.04, 0.06, 1},       -- #0A0A0F
    bg_panel     = {0.07, 0.07, 0.10, 1},        -- #111119
    bg_editor    = {0.05, 0.05, 0.08, 1},        -- #0D0D14
    bg_gutter    = {0.06, 0.06, 0.09, 1},        -- #0F0F17
    bg_tab       = {0.09, 0.09, 0.13, 1},        -- #171721
    bg_tab_act   = {0.11, 0.11, 0.17, 1},        -- #1C1C2B
    bg_button    = {0.10, 0.10, 0.16, 1},        -- #1A1A29
    bg_console   = {0.04, 0.05, 0.07, 1},        -- #0A0D12
    bg_find      = {0.08, 0.08, 0.12, 1},        -- #141420

    -- Accent colors
    neon_cyan    = {0.00, 0.90, 0.85, 1},        -- #00E6D9
    neon_green   = {0.00, 0.95, 0.60, 1},        -- #00F299
    neon_blue    = {0.20, 0.60, 1.00, 1},        -- #3399FF
    neon_purple  = {0.60, 0.30, 1.00, 1},        -- #994DFF
    neon_orange  = {1.00, 0.55, 0.10, 1},        -- #FF8C1A
    neon_pink    = {1.00, 0.30, 0.70, 1},        -- #FF4DB3
    accent_dim   = {0.00, 0.60, 0.57, 0.3},     -- dimmed accent for borders

    -- Text colors
    text_primary  = {0.92, 0.93, 0.96, 1},       -- #EBEEF5
    text_secondary= {0.50, 0.53, 0.62, 1},       -- #808599
    text_dim      = {0.28, 0.30, 0.38, 1},       -- #484D61
    text_gutter   = {0.32, 0.35, 0.45, 1},       -- #525973
    text_status   = {0.40, 0.43, 0.52, 1},       -- #666D85

    -- Syntax highlighting
    syn_keyword   = {0.00, 0.88, 0.82, 1},       -- cyan  - function, local, if...
    syn_builtin   = {0.20, 0.60, 1.00, 1},       -- blue  - print, pairs, ipairs...
    syn_string    = {0.00, 0.90, 0.55, 1},       -- green - "strings"
    syn_number    = {1.00, 0.55, 0.10, 1},       -- orange- numbers
    syn_comment   = {0.35, 0.38, 0.50, 1},       -- gray  - -- comments
    syn_func_name = {0.55, 0.35, 1.00, 1},       -- purple- function names
    syn_operator  = {1.00, 0.30, 0.70, 1},       -- pink  - operators
    syn_bool      = {1.00, 0.55, 0.10, 1},       -- orange- true, false, nil

    -- UI metrics
    topbar_h     = 46,
    statusbar_h  = 26,
    gutter_w     = 56,
    tab_h        = 34,
    console_h    = 150,
    button_r     = 7,
    tab_r        = 6,
}

-- ============================================================
-- FONTS (Love2D will use default; we set sizes)
-- ============================================================
local fonts = {}

-- ============================================================
-- STATE
-- ============================================================
local state = {
    -- Tabs
    tabs = {
        { name = "script1.lua", lines = {"-- LULU EXECUTOR", "-- Write your Lua code here", "", 'print("Hello from Neon Executor!")'} },
    },
    active_tab = 1,

    -- Editor scroll
    scroll_y   = 0,
    scroll_x   = 0,
    line_h     = 20,
    char_w     = 9.6,  -- approximate monospace char width

    -- Cursor
    cursor_line = 1,
    cursor_col  = 1,
    cursor_blink      = 0,
    cursor_blink_rate = 0.53,
    cursor_visible    = true,

    -- Selection
    sel_start_line = nil,
    sel_start_col  = nil,
    sel_end_line   = nil,
    sel_end_col    = nil,
    selecting      = false,

    -- Console
    console_lines  = {"[LULU EXECUTOR] Ready.", "[INFO] Hyprland/Wayland mode active."},
    console_scroll = 0,
    show_console   = true,

    -- Find/Replace
    show_find    = false,
    find_text    = "",
    replace_text = "",
    find_field   = "find",  -- "find" or "replace"
    find_results = {},
    find_idx     = 0,

    -- UI focus
    focus        = "editor",  -- "editor", "find", "replace", "console"

    -- Window
    win_w = 1200,
    win_h = 750,

    -- Inject animation
    inject_anim  = 0,
    inject_pulse = false,

    -- Drag state for resize
    dragging_console = false,
    drag_start_y     = 0,
    drag_start_h     = 150,
}

-- ============================================================
-- LUA SYNTAX KEYWORDS
-- ============================================================
local LUA_KEYWORDS = {
    ["function"]=true,["local"]=true,["end"]=true,["if"]=true,["then"]=true,
    ["else"]=true,["elseif"]=true,["for"]=true,["do"]=true,["while"]=true,
    ["repeat"]=true,["until"]=true,["return"]=true,["break"]=true,["in"]=true,
    ["and"]=true,["or"]=true,["not"]=true,["goto"]=true,
}
local LUA_BUILTINS = {
    ["print"]=true,["tostring"]=true,["tonumber"]=true,["type"]=true,
    ["pairs"]=true,["ipairs"]=true,["next"]=true,["select"]=true,
    ["unpack"]=true,["rawget"]=true,["rawset"]=true,["rawequal"]=true,
    ["setmetatable"]=true,["getmetatable"]=true,["require"]=true,
    ["pcall"]=true,["xpcall"]=true,["error"]=true,["assert"]=true,
    ["load"]=true,["loadstring"]=true,["loadfile"]=true,["dofile"]=true,
    ["collectgarbage"]=true,["coroutine"]=true,["string"]=true,["table"]=true,
    ["math"]=true,["io"]=true,["os"]=true,["package"]=true,
    ["task"]=true,["game"]=true,["workspace"]=true,["script"]=true,
    ["wait"]=true,["spawn"]=true,["warn"]=true,
}
local LUA_BOOLS = {["true"]=true,["false"]=true,["nil"]=true,["self"]=true}

-- ============================================================
-- HELPER FUNCTIONS
-- ============================================================
local function clamp(v, lo, hi) return math.max(lo, math.min(hi, v)) end

local function set_color(c, alpha)
    if alpha then
        love.graphics.setColor(c[1], c[2], c[3], alpha)
    else
        love.graphics.setColor(c[1], c[2], c[3], c[4] or 1)
    end
end

local function lerp(a, b, t) return a + (b - a) * t end

-- Draw a rounded rectangle
local function round_rect(x, y, w, h, r, fill_color, stroke_color, stroke_w)
    if fill_color then
        set_color(fill_color)
        love.graphics.rectangle("fill", x, y, w, h, r, r)
    end
    if stroke_color then
        love.graphics.setLineWidth(stroke_w or 1)
        set_color(stroke_color)
        love.graphics.rectangle("line", x, y, w, h, r, r)
    end
end

-- Draw a glowing line (horizontal or vertical separator)
local function glow_line(x1, y1, x2, y2, color, alpha)
    love.graphics.setLineWidth(1)
    set_color(color, (alpha or 0.15))
    love.graphics.line(x1, y1, x2, y2)
end

-- Get current tab's lines
local function get_lines()
    return state.tabs[state.active_tab].lines
end

-- Current tab name
local function get_tab_name()
    return state.tabs[state.active_tab].name
end

-- ============================================================
-- SYNTAX HIGHLIGHTING TOKENIZER
-- ============================================================
-- Returns a list of {text, color} segments for a line
local function tokenize_line(line)
    local segments = {}
    local i = 1
    local len = #line

    while i <= len do
        -- Comment: --
        if line:sub(i, i+1) == "--" then
            local rest = line:sub(i)
            -- Long comment --[[
            if rest:sub(1,4) == "--[[" then
                local close = rest:find("]]", 5, true)
                if close then
                    segments[#segments+1] = {text=rest:sub(1,close+1), color=theme.syn_comment}
                    i = i + close + 1
                else
                    segments[#segments+1] = {text=rest, color=theme.syn_comment}
                    i = len + 1
                end
            else
                segments[#segments+1] = {text=rest, color=theme.syn_comment}
                i = len + 1
            end

        -- String: " or '
        elseif line:sub(i,i) == '"' or line:sub(i,i) == "'" then
            local q = line:sub(i,i)
            local j = i + 1
            while j <= len do
                if line:sub(j,j) == "\\" then j = j + 2
                elseif line:sub(j,j) == q then j = j + 1; break
                else j = j + 1 end
            end
            segments[#segments+1] = {text=line:sub(i, j-1), color=theme.syn_string}
            i = j

        -- Long string [[
        elseif line:sub(i,i+1) == "[[" then
            local close = line:find("]]", i+2, true)
            if close then
                segments[#segments+1] = {text=line:sub(i,close+1), color=theme.syn_string}
                i = close + 2
            else
                segments[#segments+1] = {text=line:sub(i), color=theme.syn_string}
                i = len + 1
            end

        -- Number
        elseif line:sub(i,i):match("%d") or
               (line:sub(i,i) == "." and line:sub(i+1,i+1):match("%d")) then
            local j = i
            while j <= len and (line:sub(j,j):match("[%d%.xXeE_]") or
                  (line:sub(j,j):match("[+-]") and line:sub(j-1,j-1):match("[eE]"))) do
                j = j + 1
            end
            segments[#segments+1] = {text=line:sub(i,j-1), color=theme.syn_number}
            i = j

        -- Identifier / keyword
        elseif line:sub(i,i):match("[%a_]") then
            local j = i
            while j <= len and line:sub(j,j):match("[%w_]") do j = j + 1 end
            local word = line:sub(i, j-1)
            local col
            if LUA_KEYWORDS[word] then col = theme.syn_keyword
            elseif LUA_BUILTINS[word] then col = theme.syn_builtin
            elseif LUA_BOOLS[word] then col = theme.syn_bool
            else col = theme.text_primary end
            -- Check if next non-space is '(' = function call → purple name
            if not LUA_KEYWORDS[word] and not LUA_BUILTINS[word] and not LUA_BOOLS[word] then
                local rest = line:sub(j):match("^%s*%(")
                if rest then col = theme.syn_func_name end
            end
            segments[#segments+1] = {text=word, color=col}
            i = j

        -- Operators & punctuation
        elseif line:sub(i,i):match("[%+%-%*/%%^#&|~<>=%.%(%)%[%]%{%}%,%;%:]") then
            segments[#segments+1] = {text=line:sub(i,i), color=theme.syn_operator}
            i = i + 1

        -- Whitespace / other
        else
            local j = i
            while j <= len and not line:sub(j,j):match('[%a%d%s_"\'%-%+%*/%%^#&|~<>=%.%(%)%[%]%{%}%,%;%:]') do
                j = j + 1
            end
            if j == i then j = i + 1 end
            segments[#segments+1] = {text=line:sub(i,j-1), color=theme.text_primary}
            i = j
        end
    end
    return segments
end

-- ============================================================
-- LAYOUT CALCULATOR
-- ============================================================
local layout = {}

local function calc_layout()
    local W = state.win_w
    local H = state.win_h
    local console_h = state.show_console and state.console_h or 0
    local find_h    = state.show_find and 36 or 0

    layout.topbar   = {x=0, y=0, w=W, h=theme.topbar_h}
    layout.tabbar   = {x=0, y=theme.topbar_h, w=W, h=theme.tab_h}
    layout.find_bar = {x=0, y=theme.topbar_h + theme.tab_h, w=W, h=find_h}
    layout.editor   = {
        x = 0,
        y = theme.topbar_h + theme.tab_h + find_h,
        w = W,
        h = H - theme.topbar_h - theme.tab_h - find_h - console_h - theme.statusbar_h,
    }
    layout.console  = {
        x = 0,
        y = layout.editor.y + layout.editor.h,
        w = W,
        h = console_h,
    }
    layout.statusbar = {x=0, y=H - theme.statusbar_h, w=W, h=theme.statusbar_h}
    layout.gutter   = {x=layout.editor.x, y=layout.editor.y,
                       w=theme.gutter_w, h=layout.editor.h}
    layout.code_area = {
        x = layout.editor.x + theme.gutter_w,
        y = layout.editor.y,
        w = layout.editor.w - theme.gutter_w,
        h = layout.editor.h,
    }
end

-- ============================================================
-- EDITOR UTILITIES
-- ============================================================

-- Ensure cursor stays in bounds
local function clamp_cursor()
    local lines = get_lines()
    state.cursor_line = clamp(state.cursor_line, 1, #lines)
    local llen = #lines[state.cursor_line]
    state.cursor_col  = clamp(state.cursor_col, 1, llen + 1)
end

-- Scroll so cursor is visible
local function ensure_cursor_visible()
    local ed = layout.editor
    local line_h = state.line_h
    local visible_lines = math.floor(ed.h / line_h) - 1

    -- Vertical scroll
    if state.cursor_line - 1 < state.scroll_y then
        state.scroll_y = state.cursor_line - 1
    elseif state.cursor_line - 1 > state.scroll_y + visible_lines then
        state.scroll_y = state.cursor_line - 1 - visible_lines
    end
    state.scroll_y = math.max(0, state.scroll_y)

    -- Horizontal scroll
    local col_x = (state.cursor_col - 1) * state.char_w
    local visible_w = layout.code_area.w - 16
    if col_x < state.scroll_x then
        state.scroll_x = col_x
    elseif col_x > state.scroll_x + visible_w then
        state.scroll_x = col_x - visible_w
    end
    state.scroll_x = math.max(0, state.scroll_x)
end

-- Get leading whitespace of a line (for auto-indent)
local function get_indent(line)
    local indent = line:match("^(%s*)")
    return indent or ""
end

-- Insert character at cursor
local function insert_char(ch)
    local lines = get_lines()
    local line = lines[state.cursor_line]
    lines[state.cursor_line] = line:sub(1, state.cursor_col - 1) .. ch .. line:sub(state.cursor_col)
    state.cursor_col = state.cursor_col + 1
end

-- Delete character before cursor (backspace)
local function backspace()
    local lines = get_lines()
    if state.cursor_col > 1 then
        local line = lines[state.cursor_line]
        lines[state.cursor_line] = line:sub(1, state.cursor_col - 2) .. line:sub(state.cursor_col)
        state.cursor_col = state.cursor_col - 1
    elseif state.cursor_line > 1 then
        local cur  = lines[state.cursor_line]
        local prev = lines[state.cursor_line - 1]
        state.cursor_col = #prev + 1
        lines[state.cursor_line - 1] = prev .. cur
        table.remove(lines, state.cursor_line)
        state.cursor_line = state.cursor_line - 1
    end
end

-- Delete character at cursor (delete key)
local function delete_forward()
    local lines = get_lines()
    local line = lines[state.cursor_line]
    if state.cursor_col <= #line then
        lines[state.cursor_line] = line:sub(1, state.cursor_col - 1) .. line:sub(state.cursor_col + 1)
    elseif state.cursor_line < #lines then
        lines[state.cursor_line] = line .. lines[state.cursor_line + 1]
        table.remove(lines, state.cursor_line + 1)
    end
end

-- Insert newline with auto-indent
local function insert_newline()
    local lines = get_lines()
    local line = lines[state.cursor_line]
    local indent = get_indent(line)

    -- Increase indent after block-opening keywords
    local trimmed = line:match("^%s*(.-)%s*$")
    if trimmed:match("then%s*$") or trimmed:match("do%s*$") or
       trimmed:match("function%s*[%w_.:]*%s*%b()%s*$") or
       trimmed:match("{%s*$") then
        indent = indent .. "    "
    end

    local before = line:sub(1, state.cursor_col - 1)
    local after  = line:sub(state.cursor_col)
    lines[state.cursor_line] = before
    table.insert(lines, state.cursor_line + 1, indent .. after)
    state.cursor_line = state.cursor_line + 1
    state.cursor_col  = #indent + 1
end

-- Add a new tab
local function add_tab(name, content)
    name = name or ("script" .. (#state.tabs + 1) .. ".lua")
    local lines = content and {} or {"-- New script", ""}
    if content then
        for ln in (content .. "\n"):gmatch("([^\n]*)\n") do
            lines[#lines+1] = ln
        end
        if #lines == 0 then lines = {""} end
    end
    table.insert(state.tabs, {name=name, lines=lines})
    state.active_tab = #state.tabs
    state.cursor_line = 1; state.cursor_col = 1
    state.scroll_y = 0; state.scroll_x = 0
end

-- Close tab
local function close_tab(idx)
    if #state.tabs <= 1 then return end
    table.remove(state.tabs, idx)
    state.active_tab = clamp(state.active_tab, 1, #state.tabs)
end

-- ============================================================
-- CONSOLE
-- ============================================================
local function console_log(msg, level)
    level = level or "OUT"
    local prefix = {
        OUT  = "[OUT] ",
        ERR  = "[ERR] ",
        INFO = "[INFO] ",
        SYS  = "[SYS] ",
    }
    local line = (prefix[level] or "[?] ") .. tostring(msg)
    -- Split on newlines
    for l in (line .. "\n"):gmatch("([^\n]*)\n") do
        if l ~= "" or #state.console_lines == 0 then
            state.console_lines[#state.console_lines + 1] = l
        end
    end
    -- Auto scroll console to bottom
    state.console_scroll = math.max(0, #state.console_lines - 1)
end

-- ============================================================
-- EXECUTE CODE
-- ============================================================
local function execute_code()
    local lines = get_lines()
    local code = table.concat(lines, "\n")

    console_log("─────────────────────────────────", "SYS")
    console_log("Executing script: " .. get_tab_name(), "SYS")

    -- Redirect print
    local original_print = print
    local output_lines = {}

    -- Override print to capture output
    _G.print = function(...)
        local args = {...}
        local parts = {}
        for _, v in ipairs(args) do parts[#parts+1] = tostring(v) end
        local line = table.concat(parts, "\t")
        output_lines[#output_lines+1] = line
        original_print(...)
    end

    -- Execute
    local fn, err = load(code, "@" .. get_tab_name())
    if not fn then
        console_log("Compile error: " .. tostring(err), "ERR")
    else
        local ok, run_err = pcall(fn)
        for _, ln in ipairs(output_lines) do
            console_log(ln, "OUT")
        end
        if not ok then
            console_log("Runtime error: " .. tostring(run_err), "ERR")
        else
            console_log("Execution complete.", "SYS")
        end
    end

    _G.print = original_print
    state.show_console = true
end

-- ============================================================
-- FILE I/O
-- ============================================================
local function save_file()
    local lines = get_lines()
    local content = table.concat(lines, "\n")
    local ok, err = love.filesystem.write("neon_script.lua", content)
    if ok then
        console_log("Saved → " .. love.filesystem.getSaveDirectory() .. "/neon_script.lua", "SYS")
    else
        console_log("Save failed: " .. tostring(err), "ERR")
    end
end

local function load_file()
    if love.filesystem.getInfo("neon_script.lua") then
        local content, err = love.filesystem.read("neon_script.lua")
        if content then
            add_tab("neon_script.lua", content)
            console_log("Loaded neon_script.lua", "SYS")
        else
            console_log("Load failed: " .. tostring(err), "ERR")
        end
    else
        console_log("neon_script.lua not found. Save first.", "INFO")
    end
end

-- ============================================================
-- FIND/REPLACE
-- ============================================================
local function find_all(pattern, is_plain)
    state.find_results = {}
    if pattern == "" then return end
    local lines = get_lines()
    for li, line in ipairs(lines) do
        local ci = 1
        while ci <= #line do
            local s, e = line:find(pattern, ci, is_plain ~= false)
            if s then
                state.find_results[#state.find_results+1] = {line=li, s=s, e=e}
                ci = e + 1
            else break end
        end
    end
end

local function find_next()
    find_all(state.find_text, true)
    if #state.find_results == 0 then return end
    state.find_idx = state.find_idx % #state.find_results + 1
    local r = state.find_results[state.find_idx]
    state.cursor_line = r.line
    state.cursor_col  = r.s
    ensure_cursor_visible()
end

local function replace_current()
    if state.find_idx == 0 or #state.find_results == 0 then find_next(); return end
    local r = state.find_results[state.find_idx]
    local lines = get_lines()
    local line = lines[r.line]
    lines[r.line] = line:sub(1,r.s-1) .. state.replace_text .. line:sub(r.e+1)
    find_all(state.find_text, true)
    state.find_idx = math.min(state.find_idx, #state.find_results)
end

local function replace_all()
    if state.find_text == "" then return end
    local lines = get_lines()
    local count = 0
    for i, line in ipairs(lines) do
        local new_line = line:gsub(state.find_text:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]","%%%1"), state.replace_text)
        if new_line ~= line then count = count + 1 end
        lines[i] = new_line
    end
    console_log("Replaced in " .. count .. " lines.", "SYS")
    find_all(state.find_text, true)
end

-- ============================================================
-- DRAWING FUNCTIONS
-- ============================================================

local function draw_topbar()
    local tb = layout.topbar
    -- Background
    round_rect(tb.x, tb.y, tb.w, tb.h, 0, theme.bg_panel)
    glow_line(0, tb.h, tb.w, tb.h, theme.neon_cyan, 0.12)

    -- Logo / Title
    local title_x = 18
    -- Neon dot accent
    love.graphics.setLineWidth(0)
    set_color(theme.neon_cyan)
    love.graphics.circle("fill", title_x - 2, tb.h/2, 5)
    set_color(theme.neon_cyan, 0.2)
    love.graphics.circle("fill", title_x - 2, tb.h/2, 9)

    set_color(theme.text_primary)
    love.graphics.setFont(fonts.title)
    love.graphics.print("LULU", title_x + 8, tb.h/2 - 10)

    set_color(theme.neon_cyan)
    love.graphics.print("EXECUTOR", title_x + 8 + fonts.title:getWidth("NEON") + 6, tb.h/2 - 10)

    -- Version tag
    love.graphics.setFont(fonts.small)
    set_color(theme.text_dim)
    love.graphics.print("v1.0", title_x + 8, tb.h/2 + 3)

    -- Buttons area (right side)
    local btn_y    = tb.h/2 - 12
    local btn_h    = 25
    local btn_gap  = 8
    local right_x  = tb.w - 12

    -- Helper to draw top bar button
    local function draw_topbtn(label, x, w, accent, action_name)
        local mx, my = love.mouse.getPosition()
        local hovered = mx >= x and mx <= x+w and my >= tb.y and my <= tb.y+btn_h
        local bg = hovered and {accent[1]*0.25, accent[2]*0.25, accent[3]*0.25, 1} or theme.bg_button
        round_rect(x, btn_y, w, btn_h, theme.button_r, bg)
        love.graphics.setLineWidth(1)
        set_color(accent, hovered and 0.9 or 0.6)
        love.graphics.rectangle("line", x, btn_y, w, btn_h, theme.button_r)
        -- Glow on hover
        if hovered then
            set_color(accent, 0.08)
            love.graphics.rectangle("fill", x-2, btn_y-2, w+4, btn_h+4, theme.button_r+2)
        end
        love.graphics.setFont(fonts.ui_bold)
        set_color(hovered and accent or theme.text_secondary)
        local tw = fonts.ui_bold:getWidth(label)
        love.graphics.print(label, x + (w - tw)/2, btn_y + (btn_h - fonts.ui_bold:getHeight())/2)
    end

    -- Save / Load / Find buttons
    local btns = {
        {"FIND", 80, theme.neon_purple},
        {"SAVE", 66, theme.neon_green},
        {"LOAD", 66, theme.neon_blue},
        {"+ TAB", 68, theme.neon_cyan},
    }
    local bx = right_x
    for _, b in ipairs(btns) do
        local lbl, w, col = b[1], b[2], b[3]
        bx = bx - w - btn_gap
        draw_topbtn(lbl, bx, w, col)
    end
    bx = bx - 10

    -- Inject button (animated pulse when active)
    local inj_w = 88
    bx = bx - inj_w - btn_gap
    local pulse = 0.5 + 0.5 * math.sin(state.inject_anim * 4)
    local ij_col = {lerp(theme.neon_orange[1], theme.neon_pink[1], pulse),
                    lerp(theme.neon_orange[2], theme.neon_pink[2], pulse),
                    lerp(theme.neon_orange[3], theme.neon_pink[3], pulse), 1}
    draw_topbtn("⚡ INJECT", bx, inj_w, ij_col)

    -- Execute button (primary CTA)
    local exe_w = 98
    bx = bx - exe_w - btn_gap
    draw_topbtn("▶  EXECUTE", bx, exe_w, theme.neon_cyan)
end

local function draw_tabbar()
    local tb = layout.tabbar
    round_rect(tb.x, tb.y, tb.w, tb.h, 0, theme.bg_deep)
    glow_line(0, tb.y + tb.h, tb.w, tb.y + tb.h, theme.neon_cyan, 0.08)

    local tx = 8
    for i, tab in ipairs(state.tabs) do
        local is_active = (i == state.active_tab)
        local tw = fonts.ui:getWidth(tab.name) + 28
        local ty = tb.y + 4
        local th = tb.h - 4

        if is_active then
            round_rect(tx, ty, tw, th, theme.tab_r, theme.bg_tab_act)
            set_color(theme.neon_cyan)
            love.graphics.setLineWidth(1.5)
            love.graphics.rectangle("line", tx, ty, tw, th, theme.tab_r)
            -- Active indicator line
            set_color(theme.neon_cyan)
            love.graphics.setLineWidth(2)
            love.graphics.line(tx + theme.tab_r, ty + th - 1, tx + tw - theme.tab_r, ty + th - 1)
        else
            round_rect(tx, ty, tw, th, theme.tab_r, theme.bg_tab)
            love.graphics.setLineWidth(1)
            set_color(theme.text_dim, 0.3)
            love.graphics.rectangle("line", tx, ty, tw, th, theme.tab_r)
        end

        love.graphics.setFont(fonts.ui)
        set_color(is_active and theme.text_primary or theme.text_secondary)
        love.graphics.print(tab.name, tx + 8, ty + (th - fonts.ui:getHeight())/2)

        -- Close button
        local cx = tx + tw - 16
        local cy = ty + th/2 - 5
        set_color(theme.text_dim, is_active and 0.7 or 0.35)
        love.graphics.print("×", cx, cy - 1)

        tx = tx + tw + 4
    end

    -- New tab "+" mini button
    set_color(theme.text_dim, 0.5)
    love.graphics.setFont(fonts.ui)
    love.graphics.print("+", tx + 4, tb.y + (tb.h - fonts.ui:getHeight())/2)
end

local function draw_find_bar()
    if not state.show_find then return end
    local fb = layout.find_bar
    round_rect(fb.x, fb.y, fb.w, fb.h, 0, theme.bg_find)
    glow_line(0, fb.y + fb.h, fb.w, fb.y + fb.h, theme.neon_purple, 0.15)

    local lx = 12
    -- Label
    love.graphics.setFont(fonts.small)
    set_color(theme.neon_purple, 0.8)
    love.graphics.print("FIND", lx, fb.y + (fb.h - fonts.small:getHeight())/2)
    lx = lx + 40

    -- Find field
    local fw = 220
    local fy = fb.y + 4
    local fh = fb.h - 8
    local is_ff = state.focus == "find"
    round_rect(lx, fy, fw, fh, 5, theme.bg_panel)
    set_color(is_ff and theme.neon_purple or theme.text_dim, is_ff and 0.8 or 0.3)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", lx, fy, fw, fh, 5)
    love.graphics.setFont(fonts.mono_sm)
    set_color(theme.text_primary)
    local ft = state.find_text
    love.graphics.print(ft, lx + 6, fy + (fh - fonts.mono_sm:getHeight())/2)
    if is_ff and state.cursor_visible then
        local cx = lx + 6 + fonts.mono_sm:getWidth(ft)
        set_color(theme.neon_purple)
        love.graphics.setLineWidth(1.5)
        love.graphics.line(cx, fy + 4, cx, fy + fh - 4)
    end
    lx = lx + fw + 8

    -- Replace label
    set_color(theme.neon_pink, 0.8)
    love.graphics.setFont(fonts.small)
    love.graphics.print("→", lx, fb.y + (fb.h - fonts.small:getHeight())/2)
    lx = lx + 20

    -- Replace field
    local is_rf = state.focus == "replace"
    round_rect(lx, fy, fw, fh, 5, theme.bg_panel)
    set_color(is_rf and theme.neon_pink or theme.text_dim, is_rf and 0.8 or 0.3)
    love.graphics.rectangle("line", lx, fy, fw, fh, 5)
    love.graphics.setFont(fonts.mono_sm)
    set_color(theme.text_primary)
    love.graphics.print(state.replace_text, lx + 6, fy + (fh - fonts.mono_sm:getHeight())/2)
    if is_rf and state.cursor_visible then
        local cx = lx + 6 + fonts.mono_sm:getWidth(state.replace_text)
        set_color(theme.neon_pink)
        love.graphics.setLineWidth(1.5)
        love.graphics.line(cx, fy + 4, cx, fy + fh - 4)
    end
    lx = lx + fw + 8

    -- Buttons
    local function find_btn(label, col)
        local bw = fonts.small:getWidth(label) + 16
        round_rect(lx, fy, bw, fh, 5, {col[1]*0.15, col[2]*0.15, col[3]*0.15, 1})
        set_color(col, 0.8)
        love.graphics.rectangle("line", lx, fy, bw, fh, 5)
        love.graphics.setFont(fonts.small)
        love.graphics.print(label, lx + 8, fy + (fh - fonts.small:getHeight())/2)
        lx = lx + bw + 6
    end
    find_btn("Next", theme.neon_purple)
    find_btn("Replace", theme.neon_pink)
    find_btn("All", theme.neon_orange)

    -- Result count
    if #state.find_results > 0 then
        set_color(theme.neon_green, 0.7)
        love.graphics.setFont(fonts.small)
        love.graphics.print(state.find_idx .. "/" .. #state.find_results, lx + 4,
            fb.y + (fb.h - fonts.small:getHeight())/2)
    end

    -- Close
    set_color(theme.text_dim, 0.7)
    love.graphics.setFont(fonts.ui)
    love.graphics.print("✕", fb.w - 24, fb.y + (fb.h - fonts.ui:getHeight())/2)
end

local function draw_editor()
    local ed = layout.editor
    local gutter = layout.gutter
    local code_area = layout.code_area

    -- Backgrounds
    round_rect(ed.x, ed.y, ed.w, ed.h, 0, theme.bg_editor)
    round_rect(gutter.x, gutter.y, gutter.w, gutter.h, 0, theme.bg_gutter)
    glow_line(gutter.x + gutter.w, gutter.y, gutter.x + gutter.w, gutter.y + gutter.h, theme.neon_cyan, 0.10)

    -- Clip to code area
    love.graphics.setScissor(code_area.x, code_area.y, code_area.w, code_area.h)
    love.graphics.setScissor(ed.x, ed.y, ed.w, ed.h)

    local lines = get_lines()
    local line_h = state.line_h
    local char_w = state.char_w
    local start_line = math.floor(state.scroll_y) + 1
    local end_line   = math.min(#lines, start_line + math.ceil(ed.h / line_h) + 1)
    local off_y = state.scroll_y - math.floor(state.scroll_y)

    for li = start_line, end_line do
        local screen_y = ed.y + (li - start_line - off_y) * line_h + 4

        -- Current line highlight
        if li == state.cursor_line and state.focus == "editor" then
            set_color(theme.neon_cyan, 0.04)
            love.graphics.rectangle("fill", ed.x, screen_y - 2, ed.w, line_h)
            set_color(theme.neon_cyan, 0.06)
            love.graphics.setLineWidth(1)
            love.graphics.line(ed.x + gutter.w + 2, screen_y - 2,
                               ed.x + gutter.w + 2, screen_y + line_h - 2)
        end

        -- Find highlight
        for _, r in ipairs(state.find_results) do
            if r.line == li then
                local fx = code_area.x + (r.s - 1) * char_w - state.scroll_x
                local fw = (r.e - r.s + 1) * char_w
                set_color(theme.neon_purple, 0.25)
                love.graphics.rectangle("fill", fx, screen_y - 2, fw, line_h)
            end
        end

        -- Gutter: line numbers
        love.graphics.setFont(fonts.mono_sm)
        set_color(li == state.cursor_line and theme.neon_cyan or theme.text_gutter,
                  li == state.cursor_line and 0.9 or 0.55)
        local numStr = tostring(li)
        local nw = fonts.mono_sm:getWidth(numStr)
        love.graphics.print(numStr, gutter.x + gutter.w - nw - 10, screen_y)

        -- Code: tokenized
        local line = lines[li] or ""
        local segments = tokenize_line(line)
        local px = code_area.x - state.scroll_x
        love.graphics.setFont(fonts.mono)
        for _, seg in ipairs(segments) do
            set_color(seg.color)
            love.graphics.print(seg.text, px, screen_y)
            px = px + fonts.mono:getWidth(seg.text)
        end
    end

    -- Cursor
    if state.focus == "editor" and state.cursor_visible then
        local screen_y = ed.y + (state.cursor_line - start_line - off_y) * line_h + 4
        local cx = code_area.x + (state.cursor_col - 1) * char_w - state.scroll_x
        set_color(theme.neon_cyan)
        love.graphics.setLineWidth(2)
        love.graphics.line(cx, screen_y, cx, screen_y + line_h - 2)
        -- Cursor top nub
        love.graphics.setLineWidth(1)
        love.graphics.line(cx - 3, screen_y, cx + 3, screen_y)
    end

    love.graphics.setScissor()

    -- Scrollbar (vertical)
    local total_h = #lines * line_h
    if total_h > ed.h then
        local sb_w   = 4
        local sb_x   = ed.x + ed.w - sb_w - 2
        local sb_h   = ed.h - 4
        local thumb_h = math.max(20, sb_h * (ed.h / total_h))
        local thumb_y = ed.y + 2 + (state.scroll_y / (#lines - 1)) * (sb_h - thumb_h)
        round_rect(sb_x, ed.y + 2, sb_w, sb_h, 2, {0.15, 0.15, 0.20, 1})
        round_rect(sb_x, thumb_y, sb_w, thumb_h, 2, theme.neon_cyan, nil, nil)
    end
end

local function draw_console()
    if not state.show_console then return end
    local con = layout.console
    round_rect(con.x, con.y, con.w, con.h, 0, theme.bg_console)

    -- Drag handle / header
    set_color(theme.bg_panel)
    love.graphics.rectangle("fill", con.x, con.y, con.w, 18)
    glow_line(0, con.y, con.w, con.y, theme.neon_cyan, 0.15)
    love.graphics.setFont(fonts.small)
    set_color(theme.neon_cyan, 0.7)
    love.graphics.print("CONSOLE OUTPUT", 12, con.y + 2)
    set_color(theme.text_dim, 0.6)
    love.graphics.print("(drag to resize)", 140, con.y + 2)

    -- Clear button
    set_color(theme.text_dim, 0.5)
    love.graphics.print("[CLEAR]", con.w - 60, con.y + 2)

    -- Console lines
    if con.h <= 18 then return end
    love.graphics.setScissor(con.x, con.y + 18, con.w, con.h - 18)
    love.graphics.setFont(fonts.mono_sm)
    local line_h   = 16
    local start_i  = math.max(1, #state.console_lines - math.floor((con.h - 18) / line_h) - state.console_scroll)
    local end_i    = #state.console_lines
    local py = con.y + 20

    for i = start_i, end_i do
        local ln = state.console_lines[i]
        -- Color by prefix
        if ln:match("^%[ERR%]") then
            set_color(theme.neon_pink)
        elseif ln:match("^%[SYS%]") then
            set_color(theme.neon_cyan, 0.7)
        elseif ln:match("^%[INFO%]") then
            set_color(theme.neon_blue, 0.8)
        else
            set_color(theme.text_secondary)
        end
        love.graphics.print(ln, 12, py)
        py = py + line_h
    end

    love.graphics.setScissor()
end

local function draw_statusbar()
    local sb = layout.statusbar
    round_rect(sb.x, sb.y, sb.w, sb.h, 0, theme.bg_panel)
    glow_line(0, sb.y, sb.w, sb.y, theme.neon_cyan, 0.10)

    love.graphics.setFont(fonts.small)
    local lx = 14

    -- Status dot
    set_color(theme.neon_green)
    love.graphics.circle("fill", lx, sb.y + sb.h/2, 4)
    lx = lx + 12

    -- Status text
    set_color(theme.text_status)
    local parts = {
        "Ready",
        "•",
        "Hyprland / Wayland",
        "•",
        "Ln " .. state.cursor_line .. ", Col " .. state.cursor_col,
        "•",
        #get_lines() .. " lines",
        "•",
        "Love2D " .. love.getVersion(),
    }
    love.graphics.print(table.concat(parts, "  "), lx, sb.y + (sb.h - fonts.small:getHeight())/2)

    -- Right side: keybind hints
    local hints = "Ctrl+Enter: Execute  •  Ctrl+S: Save  •  Ctrl+F: Find  •  Ctrl+W: Close Tab"
    local hw = fonts.small:getWidth(hints)
    set_color(theme.text_dim, 0.6)
    love.graphics.print(hints, sb.w - hw - 14, sb.y + (sb.h - fonts.small:getHeight())/2)
end

-- ============================================================
-- LOVE2D CALLBACKS
-- ============================================================

function love.load()
    love.window.setTitle("NEON EXECUTOR")
    love.window.setMode(state.win_w, state.win_h, {
        resizable = true,
        vsync     = 1,
        minwidth  = 700,
        minheight = 450,
    })
    love.keyboard.setKeyRepeat(true)
    love.graphics.setBackgroundColor(theme.bg_deep[1], theme.bg_deep[2], theme.bg_deep[3])

    -- Load fonts (monospace recommended; fallback to default)
    local font_size_mono   = 14
    local font_size_mono_s = 12
    local font_size_ui     = 13
    local font_size_title  = 14
    local font_size_small  = 11

    -- Try to load a system monospace font for Arch Linux
    local mono_paths = {
        "/usr/share/fonts/TTF/JetBrainsMono-Regular.ttf",
        "/usr/share/fonts/jetbrains-mono/JetBrainsMono-Regular.ttf",
        "/usr/share/fonts/TTF/FiraCode-Regular.ttf",
        "/usr/share/fonts/TTF/DejaVuSansMono.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf",
        "/usr/share/fonts/noto/NotoSansMono-Regular.ttf",
    }
    local mono_bold_paths = {
        "/usr/share/fonts/TTF/JetBrainsMono-Bold.ttf",
        "/usr/share/fonts/jetbrains-mono/JetBrainsMono-Bold.ttf",
        "/usr/share/fonts/TTF/FiraCode-Bold.ttf",
        "/usr/share/fonts/TTF/DejaVuSansMono-Bold.ttf",
    }

    local function try_font(paths, size)
        for _, p in ipairs(paths) do
            if love.filesystem.getInfo and io.open(p) then
                local ok, f = pcall(love.graphics.newFont, p, size)
                if ok then io.open(p):close(); return f end
            end
        end
        return love.graphics.newFont(size)
    end

    fonts.mono     = try_font(mono_paths, font_size_mono)
    fonts.mono_sm  = try_font(mono_paths, font_size_mono_s)
    fonts.ui       = love.graphics.newFont(font_size_ui)
    fonts.ui_bold  = love.graphics.newFont(font_size_ui)
    fonts.title    = love.graphics.newFont(font_size_title)
    fonts.small    = love.graphics.newFont(font_size_small)

    -- Measure monospace character width
    state.char_w   = fonts.mono:getWidth("M")
    state.line_h   = fonts.mono:getHeight() + 4

    calc_layout()
    console_log("NEON EXECUTOR initialized.", "SYS")
    console_log("Press Ctrl+Enter to execute. Ctrl+F to find. Ctrl+S to save.", "INFO")
end

function love.update(dt)
    state.inject_anim = state.inject_anim + dt

    -- Cursor blink
    state.cursor_blink = state.cursor_blink + dt
    if state.cursor_blink >= state.cursor_blink_rate then
        state.cursor_blink  = 0
        state.cursor_visible = not state.cursor_visible
    end

    -- Console drag resize
    if state.dragging_console then
        local _, my = love.mouse.getPosition()
        local delta = state.drag_start_y - my
        state.console_h = clamp(state.drag_start_h + delta, 60, state.win_h - 200)
        calc_layout()
    end
end

function love.draw()
    calc_layout()
    draw_topbar()
    draw_tabbar()
    draw_find_bar()
    draw_editor()
    draw_console()
    draw_statusbar()
end

function love.resize(w, h)
    state.win_w = w
    state.win_h = h
    calc_layout()
end

-- ============================================================
-- MOUSE INPUT
-- ============================================================

function love.mousepressed(x, y, button)
    local tb = layout.topbar
    local tabbar = layout.tabbar
    local ed = layout.editor
    local code_area = layout.code_area
    local con = layout.console

    -- Top bar button hit detection
    if y >= tb.y and y <= tb.y + tb.h then
        -- Re-derive button positions
        local btn_h   = 25
        local btn_y   = tb.h/2 - 12
        local btn_gap = 8
        local bx      = tb.w - 12

        -- Buttons right-to-left order: FIND, SAVE, LOAD, +TAB
        local btns = {
            {label="FIND", w=80, action=function()
                state.show_find = not state.show_find
                if state.show_find then state.focus = "find" end
                calc_layout()
            end},
            {label="SAVE", w=66, action=save_file},
            {label="LOAD", w=66, action=load_file},
            {label="+ TAB", w=68, action=function() add_tab() end},
        }
        for _, b in ipairs(btns) do
            bx = bx - b.w - btn_gap
            if x >= bx and x <= bx + b.w and y >= btn_y and y <= btn_y + btn_h then
                b.action(); return
            end
        end
        bx = bx - 10
        -- INJECT
        local inj_w = 88
        bx = bx - inj_w - btn_gap
        if x >= bx and x <= bx + inj_w and y >= btn_y and y <= btn_y + btn_h then
            state.inject_pulse = true
            console_log("Injecting... (simulated)", "SYS")
            return
        end
        -- EXECUTE
        local exe_w = 98
        bx = bx - exe_w - btn_gap
        if x >= bx and x <= bx + exe_w and y >= btn_y and y <= btn_y + btn_h then
            execute_code(); return
        end
    end

    -- Tab bar
    if y >= tabbar.y and y <= tabbar.y + tabbar.h then
        local tx = 8
        for i, tab in ipairs(state.tabs) do
            local tw = fonts.ui:getWidth(tab.name) + 28
            if x >= tx and x <= tx + tw then
                -- Close button
                local cx = tx + tw - 16
                if x >= cx and x <= cx + 14 then
                    close_tab(i)
                else
                    state.active_tab = i
                    state.scroll_y = 0; state.scroll_x = 0
                    state.cursor_line = 1; state.cursor_col = 1
                end
                return
            end
            tx = tx + tw + 4
        end
        -- "+" new tab
        if x >= tx and x <= tx + 24 then
            add_tab(); return
        end
    end

    -- Editor click → set cursor
    if x >= ed.x and x <= ed.x + ed.w and y >= ed.y and y <= ed.y + ed.h then
        state.focus = "editor"
        local lines = get_lines()
        local off_y = state.scroll_y - math.floor(state.scroll_y)
        local rel_y = y - ed.y - 4
        local clicked_line = math.floor(state.scroll_y) + 1 + math.floor((rel_y + off_y * state.line_h) / state.line_h)
        clicked_line = clamp(clicked_line, 1, #lines)
        local rel_x = x - code_area.x + state.scroll_x
        local clicked_col = math.max(1, math.floor(rel_x / state.char_w) + 1)
        clicked_col = clamp(clicked_col, 1, #lines[clicked_line] + 1)
        state.cursor_line  = clicked_line
        state.cursor_col   = clicked_col
        state.cursor_visible = true
        state.cursor_blink   = 0
        return
    end

    -- Console drag handle
    if state.show_console and y >= con.y and y <= con.y + 18 then
        -- Clear button
        if x >= con.w - 60 and x <= con.w then
            state.console_lines = {}
            return
        end
        state.dragging_console = true
        state.drag_start_y     = y
        state.drag_start_h     = state.console_h
        return
    end

    -- Find bar
    if state.show_find and layout.find_bar then
        local fb = layout.find_bar
        if y >= fb.y and y <= fb.y + fb.h then
            -- Find field
            if x >= 52 and x <= 272 then state.focus = "find"; return end
            if x >= 294 and x <= 514 then state.focus = "replace"; return end
            -- Close
            if x >= fb.w - 32 then
                state.show_find = false
                state.focus = "editor"
                calc_layout()
                return
            end
            -- Next / Replace / All buttons
            local bx2 = 522
            local bh = fb.h - 8
            local fy = fb.y + 4
            for _, b in ipairs({
                {label="Next",    w=50, action=find_next},
                {label="Replace", w=68, action=replace_current},
                {label="All",     w=36, action=replace_all},
            }) do
                if x >= bx2 and x <= bx2 + b.w and y >= fy and y <= fy + bh then
                    b.action(); return
                end
                bx2 = bx2 + b.w + 6
            end
        end
    end
end

function love.mousereleased(x, y, button)
    state.dragging_console = false
end

function love.wheelmoved(x, y)
    local mx, my = love.mouse.getPosition()
    local ed = layout.editor
    local con = layout.console

    if state.show_console and my >= con.y and my <= con.y + con.h then
        state.console_scroll = clamp(state.console_scroll - y, 0, #state.console_lines)
    elseif my >= ed.y and my <= ed.y + ed.h then
        local lines = get_lines()
        state.scroll_y = clamp(state.scroll_y - y * 3, 0, math.max(0, #lines - 3))
    end
end

-- ============================================================
-- KEYBOARD INPUT
-- ============================================================

function love.keypressed(key, scancode, isrepeat)
    local ctrl  = love.keyboard.isDown("lctrl", "rctrl")
    local shift = love.keyboard.isDown("lshift", "rshift")

    -- Global shortcuts
    if ctrl then
        if key == "return" then execute_code(); return end
        if key == "s" then save_file(); return end
        if key == "o" then load_file(); return end
        if key == "f" then
            state.show_find = not state.show_find
            if state.show_find then state.focus = "find"
            else state.focus = "editor" end
            calc_layout(); return
        end
        if key == "w" then
            close_tab(state.active_tab); return
        end
        if key == "t" then add_tab(); return end
        -- Tab switching
        if key == "tab" then
            if shift then
                state.active_tab = (state.active_tab - 2) % #state.tabs + 1
            else
                state.active_tab = state.active_tab % #state.tabs + 1
            end
            return
        end
        -- Console toggle
        if key == "`" or key == "grave" then
            state.show_console = not state.show_console
            calc_layout(); return
        end
        -- Select all
        if key == "a" and state.focus == "editor" then
            local lines = get_lines()
            state.cursor_line = #lines
            state.cursor_col  = #lines[#lines] + 1
            return
        end
    end

    -- Find field input
    if state.focus == "find" then
        if key == "escape" then
            state.show_find = false; state.focus = "editor"; calc_layout(); return
        elseif key == "return" then find_next(); return
        elseif key == "tab" then state.focus = "replace"; return
        elseif key == "backspace" then
            state.find_text = state.find_text:sub(1, -2)
            find_all(state.find_text, true); return
        end
        return
    end

    if state.focus == "replace" then
        if key == "escape" then state.focus = "find"; return
        elseif key == "return" then replace_current(); return
        elseif key == "tab" then state.focus = "find"; return
        elseif key == "backspace" then
            state.replace_text = state.replace_text:sub(1, -2); return
        end
        return
    end

    -- Editor navigation
    if state.focus == "editor" then
        local lines = get_lines()
        state.cursor_visible = true
        state.cursor_blink   = 0

        if key == "up" then
            if state.cursor_line > 1 then
                state.cursor_line = state.cursor_line - 1
                state.cursor_col  = clamp(state.cursor_col, 1, #lines[state.cursor_line] + 1)
            end
        elseif key == "down" then
            if state.cursor_line < #lines then
                state.cursor_line = state.cursor_line + 1
                state.cursor_col  = clamp(state.cursor_col, 1, #lines[state.cursor_line] + 1)
            end
        elseif key == "left" then
            if ctrl then
                -- Word jump left
                local line = lines[state.cursor_line]
                local col = state.cursor_col - 2
                while col > 0 and line:sub(col,col):match("%w") do col = col - 1 end
                state.cursor_col = col + 1
            else
                if state.cursor_col > 1 then
                    state.cursor_col = state.cursor_col - 1
                elseif state.cursor_line > 1 then
                    state.cursor_line = state.cursor_line - 1
                    state.cursor_col  = #lines[state.cursor_line] + 1
                end
            end
        elseif key == "right" then
            if ctrl then
                -- Word jump right
                local line = lines[state.cursor_line]
                local col = state.cursor_col
                while col <= #line and line:sub(col,col):match("%w") do col = col + 1 end
                state.cursor_col = col
            else
                if state.cursor_col <= #lines[state.cursor_line] then
                    state.cursor_col = state.cursor_col + 1
                elseif state.cursor_line < #lines then
                    state.cursor_line = state.cursor_line + 1
                    state.cursor_col  = 1
                end
            end
        elseif key == "home" then
            -- Smart home: go to first non-whitespace, or column 1
            local line = lines[state.cursor_line]
            local indent_end = (line:match("^(%s*)") or ""):len() + 1
            state.cursor_col = (state.cursor_col == indent_end) and 1 or indent_end
        elseif key == "end" then
            state.cursor_col = #lines[state.cursor_line] + 1
        elseif key == "pageup" then
            local page = math.floor(layout.editor.h / state.line_h)
            state.cursor_line = math.max(1, state.cursor_line - page)
            state.scroll_y    = math.max(0, state.scroll_y - page)
        elseif key == "pagedown" then
            local page = math.floor(layout.editor.h / state.line_h)
            state.cursor_line = math.min(#lines, state.cursor_line + page)
            state.scroll_y    = math.min(#lines - 1, state.scroll_y + page)

        elseif key == "return" then insert_newline()
        elseif key == "backspace" then backspace()
        elseif key == "delete" then delete_forward()

        elseif key == "tab" then
            -- Insert 4 spaces
            for _ = 1, 4 do insert_char(" ") end
        end

        clamp_cursor()
        ensure_cursor_visible()
    end
end

function love.textinput(text)
    if state.focus == "editor" then
        insert_char(text)
        clamp_cursor()
        ensure_cursor_visible()
        state.cursor_visible = true
        state.cursor_blink   = 0

    elseif state.focus == "find" then
        state.find_text = state.find_text .. text
        find_all(state.find_text, true)

    elseif state.focus == "replace" then
        state.replace_text = state.replace_text .. text
    end
end

function love.mousemoved(x, y, dx, dy)
    -- Cursor changes near console drag handle
end
