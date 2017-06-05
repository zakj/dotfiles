-- Reload config on change.
watcher = hs.pathwatcher.new(hs.configdir, function()
    hs.reload()
    hs.alert('Loaded Hammerspoon config.', 1)
end):start()
