local exports = {}
local settingsKey = 'caffeinated'
local sleepType = 'displayIdle'
local menuItem = hs.menubar.new(false)

local function set(value)
  if value == nil then
    value = hs.caffeinate.toggle(sleepType)
  else
    hs.caffeinate.set(sleepType, value, true)
  end
  if value then
    menuItem:returnToMenuBar()
    menuItem:setClickCallback(exports.toggle)
    menuItem:setIcon(hs.image.imageFromName('NSTouchBarControlStripLockScreenTemplate'))
  else
    menuItem:removeFromMenuBar()
  end
end

function exports.toggle()
  local caffeinated = hs.settings.get(settingsKey)
  hs.settings.set(settingsKey, not caffeinated)
end

local function updateCaffeination()
  set(hs.settings.get(settingsKey))
end

function exports.start()
  hs.settings.watchKey(settingsKey, settingsKey, updateCaffeination)
  updateCaffeination()
end

return exports
