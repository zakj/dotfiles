local function clamp(v, min, max)
  return math.min(math.max(v, min), max)
end

-- https://en.wikipedia.org/wiki/Smoothstep
local function smootherstep(edge0, edge1, x)
  x = clamp((x - edge0) / (edge1 - edge0), 0, 1)
  return x ^ 3 * (x * (x * 6 - 15) + 10)
end

return {
  new = function(from, to, duration, fn)
    local delta = to - from
    local onComplete = function() end
    local start
    local timer

    timer = hs.timer.new(.001, function()
      local elapsed = hs.timer.secondsSinceEpoch() - start
      if elapsed >= duration then
        timer:stop()
        fn(to)
        onComplete()
      else
        fn(smootherstep(0, duration, elapsed) * delta + from)
      end
    end)

    return {
      start = function(self)
        start = hs.timer.secondsSinceEpoch()
        fn(from)
        timer:start()
      end,
      cancel = function(self) timer:stop() end,
      onComplete = function(self, fn) onComplete = fn end,
      running = function(self) return timer:running() end,
    }
  end
}
