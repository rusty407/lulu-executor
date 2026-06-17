-- NEON EXECUTOR - Love2D Configuration
function love.conf(t)
    t.title          = "NEON EXECUTOR"
    t.version        = "11.5"         -- Minimum Love2D version
    t.console        = false
    t.identity       = "neon_executor"

    t.window.title   = "NEON EXECUTOR"
    t.window.width   = 1200
    t.window.height  = 750
    t.window.resizable    = true
    t.window.vsync        = 1
    t.window.minwidth     = 700
    t.window.minheight    = 450
    t.window.highdpi      = true       -- Good for HiDPI / Wayland scaling

    -- Disable unused modules
    t.modules.audio   = false
    t.modules.sound   = false
    t.modules.physics = false
    t.modules.video   = false
    t.modules.joystick= false
    t.modules.touch   = false
end
