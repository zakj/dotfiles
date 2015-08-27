return function(mods, key, bindings)
    local modal = hs.hotkey.modal.new(mods, key)

    function exitModal(fn)
        return function()
            fn()
            modal:exit()
        end
    end

    hs.fnutils.each(bindings, function(binding)
        local mods, key, fn = table.unpack(binding)
        if mods == nil then mods = {} end
        modal:bind(mods, key, exitModal(fn))
    end)

    local hasEscapeBinding = hs.fnutils.some(bindings, function(binding)
        local mods, key, _ = table.unpack(binding)
        return (mods == nil or mods == {}) and key == 'escape'
    end)
    if not hasEscapeBinding then
        modal:bind({}, 'escape', function() modal:exit() end)
    end

    return modal
end
