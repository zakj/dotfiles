-- Reload config on change.
return hs.pathwatcher.new(hs.configdir, hs.reload)
