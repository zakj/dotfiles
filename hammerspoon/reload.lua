-- Reload config on change.
watcher = hs.pathwatcher.new(hs.configdir, function()
    hs.reload()
end)
hs.alert('Loaded Hammerspoon config.', 1)
return watcher
