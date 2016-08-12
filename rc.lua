-- Standard awesome library
local awful	= require("awful")
awful.rules	= require("awful.rules")
require("awful.autofocus")

local beautiful = require("beautiful")
local naughty	= require("naughty")
local vicious	= require("vicious")
local lfs	= require("lfs")
local menu	= require("debian.menu")
local remote	= require("awful.remote")
local wibox     = require("wibox")
local gears     = require("gears")

-- My files
local globals	= require("globals")
local funcs	= require("funcs")

-- {{{ Themes
-- beautiful.init(theme_path .. "myzen.lua")
beautiful.init(theme_path .. "wombat/theme.lua")
for s = 1, screen.count() do
   gears.wallpaper.maximized(beautiful.wallpaper, s, true)
end
-- }}}

-- {{{ Variable definitions
-- Table of layouts to cover with awful.layout.inc, order matters.
layouts = {
   awful.layout.suit.floating,
   awful.layout.suit.tile,
   awful.layout.suit.tile.left,
   awful.layout.suit.tile.bottom,
   awful.layout.suit.tile.top,
   awful.layout.suit.fair,
   awful.layout.suit.fair.horizontal,
   awful.layout.suit.spiral,
   awful.layout.suit.spiral.dwindle,
   awful.layout.suit.max,
   awful.layout.suit.max.fullscreen,
   awful.layout.suit.magnifier}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {
   names   = {"fun",      "doc",      "shell",     "math",    "stuff",    "talk",    "read",       "media",    "dumb"},
   layouts = {layouts[5], layouts[5], layouts[5], layouts[2], layouts[3], layouts[5], layouts[10], layouts[2], layouts[10]}
}
for s = 1, screen.count() do
   -- Each screen has its own tag table.
   tags[s] = awful.tag(tags.names, s, tags.layouts)
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "restart", awesome.restart }, { "quit", autostop}}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "Debian", debian.menu.Debian_menu.Debian },
                                    { "open terminal", terminal }}})

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox
-- Create separator icon
separator = wibox.widget.imagebox()
separator:set_image(awful.util.getdir("config") .. "/themes/spacer.png")

-- Create a textclock widget
mytextclock = awful.widget.textclock()

-- Create a volume widget
myvol = wibox.widget.textbox()
vicious.register(myvol, vicious.widgets.volume, vol_widget_format, 2, "Master")
myvol:buttons(awful.util.table.join(
		 awful.button({ }, 1, function () vol_mute(); vicious.force({myvol}) end),
		 awful.button({ }, 4, function () vol_up(); vicious.force({myvol}) end),
		 awful.button({ }, 5, function () vol_down(); vicious.force({myvol}) end)))

-- Create a memory widget
mymem = wibox.widget.textbox()
vicious.register(mymem, vicious.widgets.mem, mem_widget_format, 13)

-- Create a cpu widget
mycpu = wibox.widget.textbox()
vicious.register(mycpu, vicious.widgets.cpu, cpu_widget_format, 13)

-- Create a battery widget
mybat = wibox.widget.textbox()
vicious.register(mybat, vicious.widgets.bat, "$2$1", 13, "BAT0")


-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
   awful.button({ }, 1, awful.tag.viewonly),
   awful.button({ modkey }, 1, awful.client.movetotag),
   awful.button({ }, 3, awful.tag.viewtoggle),
   awful.button({ modkey }, 3, awful.client.toggletag))
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
   awful.button({ }, 1, function (c)
			   if not c:isvisible() then
			      awful.tag.viewonly(c:tags()[1])
			   end
			   client.focus = c
			   c:raise()
			end),
   awful.button({ }, 3, function ()
			   if instance then
			      instance:hide()
			      instance = nil
			   else
			      instance = awful.menu.clients({ width=250 })
			   end
			end))

for s = 1, screen.count() do
   -- Create a promptbox for each screen
   mypromptbox[s] = awful.widget.prompt()
   -- Create an imagebox widget which will contain an icon indicating which layout we're using.
   -- We need one layoutbox per screen.
   mylayoutbox[s] = awful.widget.layoutbox(s)
   mylayoutbox[s]:buttons(awful.util.table.join(
			     awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
			     awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end)))
   -- Create a taglist widget
   mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

   -- Create a tasklist widget
   mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)
   -- mytasklist[s] = awful.widget.tasklist(function(c)
   -- 					    return awful.widget.tasklist.filter.currenttags(c, s)
   -- 					 end, mytasklist.buttons)

   -- Create the wibox
   mywibox[s] = awful.wibox({ position = "top", height = "30", screen = s })

   -- Widgets that are aligned to the left
   local left_layout = wibox.layout.fixed.horizontal()
   left_layout:add(mylauncher)
   left_layout:add(mytaglist[s])
   left_layout:add(mypromptbox[s])

   -- Widgets that are aligned to the right
   local right_layout = wibox.layout.fixed.horizontal()
   if s == 1 then right_layout:add(wibox.widget.systray()) end
   right_layout:add(separator)
   right_layout:add(myvol)
   right_layout:add(separator)
   right_layout:add(mymem)
   right_layout:add(separator)
   right_layout:add(mycpu)
   right_layout:add(separator)
   right_layout:add(mybat)
   right_layout:add(separator)
   right_layout:add(mytextclock)
   right_layout:add(separator)
   right_layout:add(mylayoutbox[s])

   -- Now bring it all together (with the tasklist in the middle)
   local layout = wibox.layout.align.horizontal()
   layout:set_left(left_layout)
   layout:set_middle(mytasklist[s])
   layout:set_right(right_layout)

   mywibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Mouse bindings
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
   awful.key({ modkey,           }, "Left",   awful.tag.viewprev),
   awful.key({ modkey,           }, "Right",  awful.tag.viewnext),
   awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

   -- Mouse emulation
   awful.key({ modkey,         }, "Insert", move_mouse_upper_left),
   -- awful.key({ modkey,         }, "Delete", move_mouse_upper_right),

   -- Various chars on one keystroke
   -- awful.key({ modkey,         }, "/", type_double_square_brackets),
   -- awful.key({ modkey,         }, "/",
   -- 	     function()
   -- 		c = client.focus
   -- 		naughty.notify(
   -- 		   { text     = c.instance,
   -- 		     position = "top_right",
   -- 		     screen   = mouse.screen })
   -- 	     end
   -- 	    ),

   -- Store the active tag configuration
   awful.key({ modkey, "Shift" }, "0", savetags),
   awful.key({ modkey,         }, "0", viewsavedtags),

   -- Applications
   awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
   -- awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),
   awful.key({ modkey,           }, "e", function () awful.util.spawn(editor_cmd) end),
   awful.key({ modkey,           }, "c", function () awful.util.spawn(browser) end),
   awful.key({ modkey,           }, "i", function () awful.util.spawn("/usr/local/Wolfram/Mathematica/10.3/Executables/Mathematica") end),
   -- awful.key({ modkey,           }, "v", function () awful.util.spawn("audacious") end),
   awful.key({ modkey, "Control" }, "r", awesome.restart),
   awful.key({ modkey, "Shift"   }, "q", autostop),
   awful.key({ modkey,           }, "F12", suspend),
   awful.key({ modkey,           }, "Print", take_screenshot),
   awful.key({ 	                 }, "XF86AudioRaiseVolume", function () vol_up(); vicious.force({myvol}) end),
   awful.key({ 	                 }, "XF86AudioLowerVolume", function () vol_down(); vicious.force({myvol}) end),
   awful.key({ 	                 }, "XF86AudioMute", function () vol_mute(); vicious.force({myvol}) end),
   awful.key({                   }, "XF86MonBrightnessDown", function () awful.util.spawn("xbacklight -dec 10") end),
   awful.key({                   }, "XF86MonBrightnessUp", function () awful.util.spawn("xbacklight -inc 10") end),
   awful.key({                   }, "XF86Sleep", function () awful.util.spawn("systemctl suspend") end),

   -- Layout manipulation
   awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)	end),
   awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)	end),
   awful.key({ modkey,           }, "l", function () awful.tag.incmwfact( 0.05)		end),
   awful.key({ modkey,           }, "h", function () awful.tag.incmwfact(-0.05)		end),
   awful.key({ modkey, "Shift"   }, "h", function () awful.tag.incnmaster( 1)		end),
   awful.key({ modkey, "Shift"   }, "l", function () awful.tag.incnmaster(-1)		end),
   awful.key({ modkey, "Control" }, "h", function () awful.tag.incncol( 1)		end),
   awful.key({ modkey, "Control" }, "l", function () awful.tag.incncol(-1)		end),
   awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1)	end),
   awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1)	end),
   awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1)	end),
   awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1)	end),
   awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
   awful.key({ modkey,           }, "Tab",
	     function ()
		awful.client.focus.history.previous()
		if client.focus then client.focus:raise() end
	     end),

   awful.key({ modkey,           }, "j",
	     function ()
		awful.client.focus.byidx( 1)
		if client.focus then client.focus:raise() end
	     end),
   awful.key({ modkey,           }, "k",
	     function ()
		awful.client.focus.byidx(-1)
		if client.focus then client.focus:raise() end
	     end),

   -- Prompt
   awful.key({ modkey }, "x", function () mypromptbox[mouse.screen]:run() end),
   -- Run last command. Keycode 111 is Down arrow
   awful.key({ modkey }, "r", function () mypromptbox[mouse.screen]:run(); type_char(111) end)

   -- awful.key({ modkey }, "x", function ()
   -- 				 awful.prompt.run({ prompt = "Run Lua code: " },
   -- 						  mypromptbox[mouse.screen].widget,
   -- 						  awful.util.eval, nil,
   -- 						  awful.util.getdir("cache") .. "/history")
   -- 			      end)

   -- awful.key({ modkey }, "BackSpace", toggle_keyboard)
)

-- general client keys: for every client
clientkeys = awful.util.table.join(
   awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
   awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
   awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
   awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
   awful.key({ modkey, "Control" }, "o",      awful.client.movetoscreen                        ),
   awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
   -- awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
   awful.key({ modkey,           }, "n",      function (c) c.minimized = not c.minimized    end),
   awful.key({ modkey,           }, "m",
	     function (c)
		c.maximized_horizontal = not c.maximized_horizontal
		c.maximized_vertical   = not c.maximized_vertical
	     end)
)

-- Application specific keys
mathematicakeys = awful.util.table.join(
   clientkeys,
   awful.key({ hyperkey,           }, "i", type_double_brackets),
   awful.key({ hyperkey,           }, "j", type_parens),
   awful.key({ hyperkey,           }, "k", type_brackets),
   awful.key({ hyperkey,           }, "l", type_braces),
   awful.key({ hyperkey,           }, "ntilde", type_quotes)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
   globalkeys = awful.util.table.join(globalkeys,
				      awful.key({ modkey }, "#" .. i + 9,
						function ()
						   local screen = mouse.screen
						   if tags[screen][i] then
						      awful.tag.viewonly(tags[screen][i])
						   end
						end),
				      awful.key({ modkey, "Control" }, "#" .. i + 9,
						function ()
						   local screen = mouse.screen
						   if tags[screen][i] then
						      awful.tag.viewtoggle(tags[screen][i])
						   end
						end),
				      awful.key({ modkey, "Shift" }, "#" .. i + 9,
						function ()
						   if client.focus and tags[client.focus.screen][i] then
						      awful.client.movetotag(tags[client.focus.screen][i])
						   end
						end),
				      awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
						function ()
						   if client.focus and tags[client.focus.screen][i] then
						      awful.client.toggletag(tags[client.focus.screen][i])
						   end
						end))
end

clientbuttons = awful.util.table.join(
   awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
   awful.button({ modkey }, 1, awful.mouse.client.move),
   awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
   -- All clients will match this rule.
   { rule = { },
     properties = { border_width = beautiful.border_width,
		    border_color = beautiful.border_normal,
		    focus = true,
		    keys = clientkeys,
		    buttons = clientbuttons,
		    size_hints_honor = false } },
   { rule = { class = "MPlayer" },
     properties = { floating = true } },
   { rule = { class = "pinentry" },
     properties = { floating = true } },
   { rule = { class = "gimp" },
     properties = { floating = true } },
   { rule = { class = "Exe", instance = "exe"}, -- Chrome flash fullscreens
     properties = { floating = true } },
   { rule = { class = "Plugin-container", instance = "plugin-container"}, -- Firefox flash fullscreens
     properties = { floating = true } },
   { rule = { instance = "XMathematic"},
     properties = { keys = mathematicakeys } },
   { rule = { class = "Mathematica"},
     properties = { keys = mathematicakeys } },
   { rule = { class = "TK"},
     properties = { floating = true } }
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
			       -- Add a titlebar
			       -- awful.titlebar.add(c, { modkey = modkey })

			       -- Enable sloppy focus
			       c:add_signal("mouse::enter",
					    function(c)
					       if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
					       and awful.client.focus.filter(c) then
					       client.focus = c
					    end
					 end)

			       if not startup then
				  -- Set the windows at the slave,
				  -- i.e. put it at the end of others instead of setting it master.
				  -- awful.client.setslave(c)

				  -- Put windows in a smart way, only if they do not set an initial position.
				  if not c.size_hints.user_position and not c.size_hints.program_position then
				     awful.placement.no_overlap(c)
				     awful.placement.no_offscreen(c)
				  end
			       end
			    end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{{ Autostart
autostart()
-- }}}
