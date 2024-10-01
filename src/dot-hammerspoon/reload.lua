-- Reload config on change.
return hs.pathwatcher.new(os.getenv("HOME") .. "/etc/src/dot-hammerspoon", hs.reload)
