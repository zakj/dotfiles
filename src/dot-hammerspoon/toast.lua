local Panel = require 'panel'

local toasts = {} ---@type Toast[]
local baseText = hs.styledtext.new(' ', {
  color = { black = 1 },
  font = { name = hs.styledtext.defaultFonts.system, size = 16 },
})

local function defaultdict(factory)
  return setmetatable({}, {
    __index = function(t, k)
      t[k] = factory()
      return t[k]
    end
  })
end

local function repositionToasts()
  local margin = 20
  local byScreen = defaultdict(function() return {} end)

  for _, toast in ipairs(toasts) do
    local frame = toast.panel:frame()
    local siblings = byScreen[toast.panel.screen:getUUID()]
    if #siblings == 0 then
      local screen = toast.panel.screen:fullFrame()
      toast.panel:position(Panel.pos.absolute(screen.w - margin - frame.w, screen.h - margin - frame.h))
    else
      toast.panel:position(Panel.pos.relativeTo(siblings[#siblings].panel, 'top', { align = "end", offset = { y = -12 } }))
    end
    table.insert(siblings, toast)
  end
end

---@class Toast
---@field panel Panel
---@field timer? any
local Toast = {}
Toast.__index = Toast

---@param msg any
---@param duration? number
---@return Toast
function Toast.new(msg, duration)
  local self = setmetatable({}, Toast)
  self.panel = Panel.new()
  self.timer = nil

  if type(msg) ~= 'string' then
    msg = hs.inspect(msg)
  end
  local text = baseText:setString(msg)
  local element = self.panel:textElement(text, { x = 0, y = 0 })
  self.panel:setElements({ element }, { xPadding = 16, yPadding = 8 })
  self.panel:mouseCallback(function() self:delete() end)

  table.insert(toasts, self)
  repositionToasts()
  self.panel:show()

  if duration ~= nil then
    self.timer = hs.timer.doAfter(duration, function() self:delete() end)
  end

  return self
end

function Toast:delete()
  for i, toast in ipairs(toasts) do
    if toast == self then
      table.remove(toasts, i)
      break
    end
  end
  repositionToasts()
  self.panel:delete()
  self.panel = nil
  self.timer = nil
end

return Toast.new
