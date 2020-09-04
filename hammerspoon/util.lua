exports = {}

function exports.filter(tbl, fn)
  local rv = {}
  for i, x in pairs(tbl) do
    if fn(x) then
      table.insert(rv, x)
    end
  end
  return rv
end

function exports.map(tbl, fn)
  local rv = {}
  for i, x in pairs(tbl) do
      rv[i] = fn(x)
  end
  return rv
end

function exports.split(str, sep)
  local rv = {}
  for chunk in string.gmatch(str, '([^' .. sep .. ']+)') do
    table.insert(rv, chunk)
  end
  return rv
end

return exports
