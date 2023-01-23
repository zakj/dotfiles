-- TODO cleanup
local function init()
  local self = {}
  local _handlers = {}
  local _modDownCount = {}
  local _lastFlags = {}

  local flagsTap = hs.eventtap.new({ hs.eventtap.event.types.flagsChanged }, function(e)
    for k in pairs(e:getFlags()) do
      if _lastFlags[k] == nil then
        if _modDownCount[k] == nil then _modDownCount[k] = 0 end
        _modDownCount[k] = _modDownCount[k] + 1
        hs.timer.doAfter(0.2, function()
          _modDownCount[k] = _modDownCount[k] - 1
        end)
        if _modDownCount[k] % 2 == 0 and _handlers[k] ~= nil then
          _handlers[k]()
        end
      end
    end
    _lastFlags = e:getFlags()
  end)

  function self.on(mod, fn)
    _handlers[mod] = fn
    flagsTap:start()
  end

  function self.off(mod)
    _handlers[mod] = nil
    -- TODO: turn off eventtap if all handler values are nil
  end

  return self
end

return init()
