local emoji = require('emoji')
local fn = hs.fnutils
local message = require('message')
local u = require('util')

local HITS_KEY = 'launcher-hits'
local modal = hs.hotkey.modal.new()

local function asyncGetInstalledApplications(callback)
  local spotlight = hs.spotlight.new()
  spotlight:queryString([[
    kMDItemContentType == "com.apple.application-bundle" &&
    kMDItemCFBundleIdentifier like "*" &&
    !kMDItemSupportFileType like 'MDSystemFile'
  ]])
  spotlight:setCallback(function(obj, message)
    if message ~= 'didFinish' then return end
    local choices = {}
    for i = 1, #obj do
      local bundleID = obj[i]:valueForAttribute('kMDItemCFBundleIdentifier')
      choices[bundleID] = {
        bundleID = bundleID,
        image = hs.image.imageFromAppBundle(bundleID),
        text = obj[i]:valueForAttribute('kMDItemDisplayName'),
      }
    end
    callback(u.values(choices))
  end)
  spotlight:start()
end

local function finderSelection()
  local success, output = hs.osascript.javascript("Application('Finder').selection().map(x => x.url()).join(' ');")
  if not success then return '' end
  return output
end

local function completionFn(item)
  modal:exit()
  if not item then return end

  -- TODO: This is horrible, but functions can't be passed as choices. Maybe explicit types?
  if item.bundleID then  -- application
    hs.application.open(item.bundleID)
  elseif item.path then  -- folder
    hs.open(item.path)
  elseif item.text == 'Emoji' then
    emoji.chooser()
  else
    message.show('Unknown item type:\n' .. hs.inspect(item))
  end

  local hits = hs.settings.get(HITS_KEY) or {}
  hits[item.text] = (hits[item.text] or 0) + 1
  hs.settings.set(HITS_KEY, hits)
end

-- TODO sleep
-- TODO simple calculator (if query matches arithmetic regex)
return function()
  local ch = hs.chooser.new(completionFn)
  hs.settings.watchKey('launcher', HITS_KEY, function() ch:refreshChoicesCallback() end)

  ch:showCallback(function() modal:enter() end)
  modal:bind('cmd', 'd', nil, function()
    local item = ch:selectedRowContents()
    if not item.bundleID then
      message.show('No application selected.', 2)
    else
      print(hs.inspect(item))
      io.popen('open -b "' .. item.bundleID .. '" ' .. finderSelection())
      ch:hide()
    end
  end)

  local installedApplications = {}
  asyncGetInstalledApplications(function(choices)
    installedApplications = choices
    ch:refreshChoicesCallback()
  end)

  local home = os.getenv('HOME')
  local folders = fn.imap({'Desktop', 'Documents', 'Downloads'}, function(name)
    local path = home .. '/' .. name
    return {
      image = hs.image.iconForFile(path),
      path = path,
      text = name,
    }
  end)

  ch:choices(function(query)
    local choices = {}
    choices = fn.concat(choices, folders)
    choices = fn.concat(choices, installedApplications)
    choices = fn.concat(choices, {
      {text = 'Emoji', image = emoji.imageFromEmoji('😃')},
    })

    local hits = hs.settings.get(HITS_KEY) or {}
    table.sort(choices, function(a, b)
      local aHits = hits[a.text] or 0
      local bHits = hits[b.text] or 0
      return aHits > bHits or (aHits == bHits and a.text < b.text)
    end)

    return choices
  end)

  return function()
    ch:query('')
    ch:show()
  end
end
