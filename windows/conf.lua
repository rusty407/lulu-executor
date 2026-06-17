-- conf.lua
function love.conf(t)
    t.window.title = "Velocity • Neon Executor"
    t.window.width = 1280
    t.window.height = 720
    t.window.resizable = true
    t.window.minwidth = 960
    t.window.minheight = 540
    t.window.borderless = false
    t.window.fullscreen = false
    t.window.vsync = 1
    t.modules.joystick = false
    t.modules.physics = false
    t.modules.sound = false
    t.modules.video = false
    t.console = false
end
