-- Reload config on change.
watcher = hs.pathwatcher.new(hs.configdir, hs.reload)
hs.alert('Loaded Hammerspoon config.', 1)
return watcher
