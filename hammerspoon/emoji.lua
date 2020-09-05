local u = require 'util'

exports = {}

local function imageFromEmoji(emoji)
  local canvas = hs.canvas.new({x = 0, y = 0, w = 100, h = 100}):appendElements({
    frame = {x = 0, y = 5, w = 100, h = 100},
    text = emoji,
    textAlignment = 'center',
    textColor = {black = 1},
    textSize = 70,
    type = 'text',
  })
  local image = canvas:imageFromCanvas()
  canvas:delete()
  return image
end

local function resultToChoice(item)
  local codes = u.map(u.split(item.Code, ' '), function(x) return tonumber(x, 16) end)
  local emoji = hs.utf8.codepointToUTF8(table.unpack(codes))
  return {
    text = string.lower(item.Name),
    emoji = emoji,
    image = imageFromEmoji(emoji),
  }
end

local function emojiFinder(query, onSuccess)
  local url = 'https://emojifinder.com/*/ajax.php?action=search&query=' .. hs.http.encodeForQuery(query)
  hs.http.asyncGet(url, nil, function(status, body, headers)
    local data = hs.json.decode(body)
    if data.status == 'error' then return end
    local results = u.filter(data.results, function(x) return not (x.Code == nil or x.Name == "") end)
    onSuccess(u.map(results, resultToChoice))
  end)
end


function exports.chooser()
  local ch = hs.chooser.new(function(item)
    if item then
      hs.eventtap.keyStrokes(item.emoji)
    end
  end)
  ch:placeholderText('Search emoji…')
  ch:show()

  local lastUpdateId = 0
  local lastQueryId = 0
  ch:queryChangedCallback(function(query)
    lastQueryId = lastQueryId + 1
    local id = lastQueryId

    emojiFinder(query, function(choices)
      if id > lastUpdateId then
        lastUpdateId = id
        ch:choices(choices)
      end
    end)
  end)
end

return exports
