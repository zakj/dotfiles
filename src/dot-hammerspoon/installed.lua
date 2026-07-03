-- Which macOS applications are installed, according to Spotlight's index.
local exports = {}

-- Retains the running query so it isn't garbage-collected before it finishes.
local pending

-- Query Spotlight for installed apps in the background, then invoke `callback`
-- with a synchronous `isInstalled(app) -> boolean` predicate. If the query
-- yields nothing (Spotlight disabled or unindexed) the callback is skipped, so
-- callers keep whatever they had rather than acting on empty data.
---@param callback fun(isInstalled: fun(app: string): boolean)
function exports.load(callback)
  pending = hs.spotlight.new():setCallback(function(query, message)
    if message ~= 'didFinish' then return end

    local set = {}
    for i = 1, #query do
      local name = (query[i]:valueForAttribute('kMDItemFSName') or ''):match('^(.*)%.app$')
      if name then set[name:lower()] = true end
    end
    query:stop()
    pending = nil
    if next(set) == nil then return end

    callback(function(app) return set[app:lower()] == true end)
  end)
  pending:queryString('kMDItemContentType == "com.apple.application-bundle"')
  pending:start()
end

return exports
