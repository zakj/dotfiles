local exports = {}

function exports.filter(tbl, fn)
  local rv = {}
  for i, x in pairs(tbl) do
    if fn(x) then
      table.insert(rv, x)
    end
  end
  return rv
end

exports.join = table.concat

function exports.keys(tbl)
  local rv = {}
  for k, v in pairs(tbl) do
    table.insert(rv, k)
  end
  return rv
end

function exports.len(tbl)
  local n = 0
  for _ in pairs(tbl) do
    n = n + 1
  end
  return n
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
