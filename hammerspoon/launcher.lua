local fn = hs.fnutils
local message = require('message')
local u = require('util')

local HITS_KEY = 'launcher-hits'
local spotlight = hs.spotlight.new()

local function asyncGetInstalledApplications(callback)
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
  if not item then return end
  local selection = finderSelection()
  print(selection)
  if not item.bundleID then
    message.show('No application selected.', 2)
  elseif selection == '' then
    message.show('No file selected.', 2)
  else
    io.popen('open -b "' .. item.bundleID .. '" ' .. selection)
  end
  local hits = hs.settings.get(HITS_KEY) or {}
  hits[item.text] = (hits[item.text] or 0) + 1
  hs.settings.set(HITS_KEY, hits)
end

return function()
  local ch = hs.chooser.new(completionFn)
  hs.settings.watchKey('launcher', HITS_KEY, function() ch:refreshChoicesCallback() end)

  local installedApplications = {}
  asyncGetInstalledApplications(function(apps)
    installedApplications = apps
    ch:refreshChoicesCallback()
  end)

  ch:choices(function(query)
    local hits = hs.settings.get(HITS_KEY) or {}
    table.sort(installedApplications, function(a, b)
      local aHits = hits[a.text] or 0
      local bHits = hits[b.text] or 0
      return aHits > bHits or (aHits == bHits and a.text < b.text)
    end)
    return installedApplications
  end)

  return function()
    local screenWidth = hs.screen.primaryScreen():frame().w
    ch:width(475 / screenWidth * 100)  -- width takes a percentage
    ch:query('')
    ch:show()
  end
end
