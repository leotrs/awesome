---- Auxiliary functions for rc.lua
local awful = require("awful")
require("globals")

--- {{{ Auxiliary functions
function relative_hex_string (n)
   -- returns a string with the percentage n/255, in hex
   return string.format("%02x", n*255/100)
end
--- }}}


--- {{{ Widgets
function mem_widget_format (widget, args)
   -- args: prct, usage, total, free, swapprct, swapusage, totalswap, freeswap, memusage
   return "<span font_desc='heavy' color='#" .. relative_hex_string(tonumber(args[1])) .. "0000'>" .. "Mem: " .. args[1] .. "</span>"
end

function cpu_widget_format (widget, args)
   -- args: total cpu usage, first core usage, second core usage, etc
   return "<span font_desc='heavy' color='#" .. relative_hex_string(tonumber(args[1])) .. "0000'>" .. "Cpu: " .. args[1] .. "</span>"
end

function vol_widget_format (widget, args)
   -- args: volume level, mute status
   if args[2] == "♩" then
      color = "'#ffa500'"
   else
      color = relative_hex_string(args[1])
      color = "'#00" .. color .. color .. "'"
   end
   
   return args[1] .. "<span color=" .. color .. ">" .. args[2] .. "</span>"
end
--- }}}

--- {{{ Autostart / Autostop
function autostart()
   -- Use a file as lock: touch at startup and delete at shutdown.
   sessf = io.open(session_file)
   if sessf then
      io.close(sessf)
   else
      awful.util.spawn_with_shell("touch " .. session_file)
      awful.util.spawn_with_shell("my-kbd-layout")
      -- awful.util.spawn_with_shell("setxkbmap es")
      -- awful.util.spawn_with_shell("xmodmap .xmodmaprc")
      -- set_keyboard("custom")
      awful.util.spawn_with_shell("semd")
      awful.util.spawn_with_shell("xscreensaver -nosplash")
      awful.util.spawn_with_shell("xcompmgr")
      awful.util.spawn_with_shell("nm-applet")
      awful.util.spawn_with_shell("nitrogen --restore")
      awful.util.spawn_with_shell("xflux.sh")
   end
end

function autostop()
   awful.util.spawn_with_shell("emdk")
   awful.util.spawn_with_shell("rm " .. session_file)
   -- awful.util.spawn_with_shell("rm " .. keyboard_file)
   awesome.quit()
end
--- }}}

--- {{{ Misc functions
-- Take screenshot
function take_screenshot ()
   local cont = 1
   for file in lfs.dir(screenshot_path) do
      if file:find("screenshot") then cont = cont + 1 end
   end
   awful.util.spawn_with_shell("scrot " .. screenshot_path .. "screenshot" .. cont .. ".png")
end

-- volume management
function vol_up ()   awful.util.spawn("amixer -q sset Master 2%+") end
function vol_down () awful.util.spawn("amixer -q sset Master 2%-") end
function vol_mute () awful.util.spawn("pactl set-sink-mute 0 toggle") end


-- mouse movement
function move_mouse_upper_left() mouse.coords({ x = 7, y = 7 }) end
function move_mouse_upper_right() mouse.coords({ x = 0.95 * screen[mouse.screen].workarea.width, y = 7 }) end

-- The following functions are for use in Mathematica:
-- input various kind of brackets and steps back into them
-- note: only works with my own custom keyboard layout, where keybode 133 is Alt Gr
function type_double_brackets()
   -- if sleeep for less than 0.25, this will simply not work
   os.execute("sleep 0.25")

   type_char(9)
   root.fake_input("key_press", 133); type_char(34); type_char(34); root.fake_input("key_release", 133)
   type_char(9)
   type_char(9)
   root.fake_input("key_press", 133); type_char(35); type_char(35); root.fake_input("key_release", 133)
   type_char(9)
   type_char(113)
end

function type_parens()
   os.execute("sleep 0.2")
   root.fake_input("key_press", 50); type_char(17); type_char(18)
   root.fake_input("key_release", 50); type_char(113)
end

function type_brackets()
   os.execute("sleep 0.2")
   root.fake_input("key_press", 133); type_char(34); type_char(35)
   root.fake_input("key_release", 133); type_char(113)   
end

function type_braces()
   os.execute("sleep 0.2")
   root.fake_input("key_press", 133); type_char(48); type_char(51)
   root.fake_input("key_release", 133); type_char(113)   
end

function type_quotes()
   os.execute("sleep 0.2")
   root.fake_input("key_press", 50); type_char(11); type_char(11)
   root.fake_input("key_release", 50); type_char(113)   
end

-- tag selection
myselectedtags = {}
function savetags () myselectedtags = awful.tag.selectedlist(mouse.screen) end
function viewsavedtags () 
   if myselectedtags then awful.tag.viewmore(myselectedtags, mouse.screen) end
end

-- other
-- function set_keyboard(mode)
--    -- mode: "custom" or "standard"
--    keyboardf = io.open(keyboard_file)
--    if keyboardf then
--       io.close(keyboardf)
--       if mode == "standard" then
-- 	 awful.util.spawn_with_shell("setxkbmap")
-- 	 awful.util.spawn_with_shell("rm " .. keyboard_file)
-- 	 mykbi.text = "standard"
--       end
--    elseif mode == "custom" then
--       awful.util.spawn_with_shell("xmodmap ~/.xmodmaprc")
--       awful.util.spawn_with_shell("touch " .. keyboard_file)
--    else
--       print("Bad argument to set_keyboard. Use 'custom' or 'standard'.")
--    end
-- end

-- function toggle_keyboard()
--    -- Use a file as lock
--    keyboardf = io.open(keyboard_file)
--    if keyboardf then
--       io.close(keyboardf)
--       set_keyboard("standard")
--    else
--       set_keyboard("custom")
--    end   
-- end

-- function toggle_keyboard_from_widget()
--    local kbf = io.open(keyboard_file)
--    if not kbf then
--       set_keyboard("custom")
--    else
--       io.close(kbf)
--       set_keyboard("standard")
--    end
-- end

function lock_screen() awful.util.spawn_with_shell("xscreensaver-command -lock") end

function suspend() awful.util.spawn_with_shell(
      "xscreensaver-command -lock && gksudo pm-suspend") end

function click(n)
   root.fake_input("button_press", n); root.fake_input("button_release", n)
end
function type_char(n)
   root.fake_input("key_press", n); root.fake_input("key_release", n)
end
--- }}}
