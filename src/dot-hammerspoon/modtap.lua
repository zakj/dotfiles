return {
  eventtaps = {},

  start = function(self, mod, mods, key, delay)
    local modDown = hs.eventtap.checkKeyboardModifiers()[mod]
    local wantsTap = false
    local timer = hs.timer.delayed.new(delay, function() wantsTap = false end)

    local types = hs.eventtap.event.types
    local eventtap = hs.eventtap.new({ types.flagsChanged, types.keyDown }, function(e)
      if e:getType() == types.keyDown then
        -- Pressing any other key cancels the tap.
        wantsTap = false
      elseif e:getType() == types.flagsChanged then
        -- If the modifier we're watching hasn't changed, nothing to do.
        if e:getFlags()[mod] == modDown then return end
        modDown = e:getFlags()[mod]

        if modDown then
          wantsTap = true
          timer:start()
        elseif wantsTap then
          wantsTap = false
          timer:stop()
          hs.eventtap.keyStroke(mods, key, 5000)
          -- return true -- suppress event  XXX not needed?
        end
      end
    end)

    self.eventtaps[#self.eventtaps + 1] = eventtap -- prevent GC
    eventtap:start()
    return eventtap
  end
}
