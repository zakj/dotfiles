if hs.host.localizedName() ~= 'MPzj' then
    return
end

hs.wifi.watcher.new(function()
    local badNetworks = {'mixpanel-guest', 'MP-Chromecast'}
    if hs.fnutils.contains(badNetworks, hs.wifi.currentNetwork()) then
        hs.notify.new({
            title = 'Wrong network!',
            informativeText = 'Connected to ' .. hs.wifi.currentNetwork() .. '.',
            alwaysPresent = true,
            autoWithdraw = false,
        }):send()
    end
end):start()
