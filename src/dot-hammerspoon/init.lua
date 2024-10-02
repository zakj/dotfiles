local ctrl = require 'ctrl'
local hyper = require 'hyper'
local layout = require 'layout'
local reload = require 'reload'
local toast = require 'toast'

ctrl:start()
hyper:start()
reload:start()

hs.hotkey.setLogLevel('warning')

local defaultWebHandler = hs.application.get(hs.urlevent.getDefaultHandler('http')):name()

local function withFocusedWindow(...)
  local varargs = { ... }
  return function()
    for _, fn in ipairs(varargs) do
      fn(hs.window.focusedWindow())
    end
  end
end

local function launch(name)
  return function() hs.application.launchOrFocus(name) end
end

-- TODO: just use raycast with single-character aliases?
hs.hotkey.bind(hyper.mods, 'f', launch(defaultWebHandler))
hs.hotkey.bind(hyper.mods, 'l', launch('Slack'))
hs.hotkey.bind(hyper.mods, 'm', launch('Messages'))
hs.hotkey.bind(hyper.mods, 'n', launch('Obsidian'))
hs.hotkey.bind(hyper.mods, 't', launch('kitty'))
hs.hotkey.bind(hyper.mods, 'v', launch('Zed'))

hs.urlevent.bind('autolayout', layout.autolayout)
hs.hotkey.bind(hyper.mods, 'j', function()
  layout.autolayout()
  toast('Layout complete.', 3)
end)
hs.hotkey.bind(hyper.mods, ';', hs.caffeinate.lockScreen)
hs.hotkey.bind(hyper.mods, "'", function()
  hs.execute("open -g raycast://extensions/mooxl/coffee/caffeinateToggle?launchType=background")
end)

hs.hotkey.bind(hyper.mods, 'k', withFocusedWindow(layout.moveCenter))
hs.hotkey.bind(hyper.mods, 'left', withFocusedWindow(layout.moveTL, layout.maximizeV))
hs.hotkey.bind(hyper.mods, 'right', withFocusedWindow(layout.moveTR, layout.maximizeV))

-- Make sure garbage collection doesn't break new functionality.
hs.timer.doAfter(2, collectgarbage)

toast('Hammerspoon loaded.', 1.5)
