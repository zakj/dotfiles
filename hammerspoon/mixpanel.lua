if hs.host.localizedName() ~= 'MPzj' then
    return
end

hs.wifi.watcher.new(function()
    local badNetworks = {'mixpanel-guest', 'MP-Chromecast'}
    local currentNetwork = hs.wifi.currentNetwork()
    if currentNetwork == nil then
        -- disconnecting
        return
    end
    if hs.fnutils.contains(badNetworks, currentNetwork) then
        hs.notify.new({
            title = 'Wrong network!',
            informativeText = 'Connected to ' .. currentNetwork .. '.',
            alwaysPresent = true,
            autoWithdraw = false,
        }):send()
    end
end):start()
