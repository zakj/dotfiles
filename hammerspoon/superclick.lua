local superClickTimer = nil

return function()
    if superClickTimer and superClickTimer:running() then
        superClickTimer:stop()
        return
    end
    local point = hs.mouse.getAbsolutePosition()
    superClickTimer = hs.timer.new(1/50, function() hs.eventtap.leftClick(point) end):start()
end
