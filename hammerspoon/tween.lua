local function clamp(v, min, max)
    return math.min(math.max(v, min), max)
end

-- https://en.wikipedia.org/wiki/Smoothstep
local function smootherstep(edge0, edge1, x)
    x = clamp((x - edge0) / (edge1 - edge0), 0, 1)
    return x^3 * (x * (x * 6 - 15) + 10)
end

return function(fn, target, from, to, duration)
    local delta = to - from
    local function set(v)
        if target then
            fn(target, v)
        else
            fn(x)
        end
    end
    local onComplete = function() end

    set(from)
    local start = hs.timer.secondsSinceEpoch()
    timer = hs.timer.doEvery(.001, function()
        local elapsed = hs.timer.secondsSinceEpoch() - start
        if elapsed >= duration then
            timer:stop()
            set(to)
            onComplete()
        else
            set(smootherstep(0, duration, elapsed) * delta + from)
        end
    end)

    return {
        cancel = function() timer:stop() end,
        onComplete = function(fn) onComplete = fn end,
    }
end
