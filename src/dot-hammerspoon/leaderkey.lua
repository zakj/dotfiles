local Panel = require("panel")
local pluck = require('util').pluck

-- This is what we expect the user to pass in.
---@alias KeyMap {
---  [1]: string,
---  desc?: string,
---  app?: string,
---  url?: string,
---  fn?: function,
---  sticky?: boolean,
---  children?: KeyMap[],
---}

-- The primary datastructure for managing navigation.
---@alias Node {
---  key: string,
---  path: string,
---  parent: Node,
---  order: number,
---  children: Node[],
---  desc: string,
---  sticky: boolean,
---  fn: function,
---}

---@class LeaderKey
---@field activationMods string[]
---@field activationKeyCode number
---@field navigator Navigator
---@field backdrop any
---@field indicator Indicator
---@field infoPanel InfoPanel
---@field state State
---@field stateMap table
---@field keyDownTap any
local LeaderKey = {}
LeaderKey.__index = LeaderKey

-- TODO: maybe parsing should live elsewhere?
-- Parses keymap into a tree of Nodes and Manages navigation.
---@class Navigator
---@field root Node
---@field current Node|nil
local Navigator = {}
Navigator.__index = Navigator

-- Simple UI to show current navigation state.
---@class Indicator
---@field panel Panel
local Indicator = {}
Indicator.__index = Indicator

-- Helix-style auto-info.
---@class InfoPanel
---@field panel Panel
---@field autoShowTimer any
local InfoPanel = {}
InfoPanel.__index = InfoPanel

---@enum State
local State = {
  INACTIVE = {},
  ACTIVE = {},
  ACTIVE_INFO = {},
}

---@enum Message
local Message = {
  ENTER = {},
  EXIT = {},
  NAVIGATE = {},
  EXECUTE = {},
  GO_BACK = {},
  TOGGLE_INFO = {},
  INVALID_KEY = {},
  INFO_TIMER = {},
  CLICK_OUTSIDE = {},
}

---event:getFlags():containExactly() doesn't handle mod aliases for us.
---@param mods (string[] | string)
---@return string[]
local function normalizeMods(mods)
  local modAliases = {
    { 'cmd', 'command', '⌘' },
    { 'ctrl', 'control', '⌃' },
    { 'alt', 'option', '⌥' },
    { 'shift', '⇧' }
  }

  local result = {}
  local input = type(mods) == "table" and table.concat(mods, "-") or tostring(mods)

  for _, aliases in ipairs(modAliases) do
    if hs.fnutils.some(aliases, function(alias) return input:find(alias) end) then
      table.insert(result, aliases[1])
    end
  end

  return result
end

---@param mods (string | string[])
---@param key string
---@param keymap KeyMap
---@return LeaderKey
function LeaderKey.new(mods, key, keymap)
  local self = setmetatable({}, LeaderKey)

  self.activationMods = normalizeMods(mods)
  self.activationKeyCode = hs.keycodes.map[key]
  self.navigator = Navigator.new(keymap)
  self.indicator = Indicator.new()
  self.infoPanel = InfoPanel.new()
  self.state = State.INACTIVE
  self.stateMap = self:_createStateMap()

  -- I'd love to toggle here instead, but we consume key events before the
  -- hotkey has a chance to fire. we have to detect the mods/key manually in our
  -- key event handler.
  -- TODO if we ignore non-sticky mods in keydown handler, could we leave toggling as a responsibility of the consumer?
  hs.hotkey.bind(mods, key, function() self:_dispatch(Message.ENTER) end)

  self.keyDownTap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
    return self:_onKeyEvent(event)
  end)

  self.backdrop = hs.canvas.new(hs.screen.mainScreen():frame())
      :clickActivating(false)
      :canvasMouseEvents(true)
      :mouseCallback(function() self:_dispatch(Message.CLICK_OUTSIDE) end)
  -- Ignore clicks on panels; a non-nil callback is needed to prevent fall-through to backdrop.
  self.indicator.panel.canvas:mouseCallback(function() end)
  self.infoPanel.panel.canvas:mouseCallback(function() end)

  return self
end

function LeaderKey:_createStateMap()
  local function exitToInactive()
    self.navigator:stop()
    self.keyDownTap:stop()
    self.infoPanel:cancelAutoShow()
    self.backdrop:hide()
    self.indicator:hide()
    self.infoPanel:hide()
    return State.INACTIVE
  end

  ---@param node Node
  ---@param sticky boolean
  ---@return State|nil
  local function execute(node, sticky)
    node.fn()
    if sticky ~= node.sticky then return end
    return exitToInactive()
  end

  local function showInfo()
    self.infoPanel:update(self.navigator:getChildren(), self.navigator:getPath())
    self.infoPanel:show(self.indicator.panel)
    return State.ACTIVE_INFO
  end

  return {
    [State.INACTIVE] = {
      [Message.ENTER] = function()
        self.navigator:start()
        self.keyDownTap:start()
        self.backdrop:frame(hs.screen.mainScreen():frame())
        self.backdrop:show()
        self.indicator:show(self.navigator:getPath())
        self.infoPanel:startAutoShow(1, function()
          if self.navigator.current then
            self:_dispatch(Message.INFO_TIMER)
          end
        end)
        return State.ACTIVE
      end,
    },

    [State.ACTIVE] = {
      [Message.EXIT] = exitToInactive,
      [Message.CLICK_OUTSIDE] = exitToInactive,
      [Message.EXECUTE] = execute,
      [Message.NAVIGATE] = function(node)
        self.navigator:go(node)
        self.indicator:update(self.navigator:getPath())
      end,
      [Message.GO_BACK] = function()
        if self.navigator:back() then
          self.indicator:update(self.navigator:getPath())
        end
      end,
      [Message.TOGGLE_INFO] = showInfo,
      [Message.INVALID_KEY] = function()
        self.indicator:shake()
        return showInfo()
      end,
      [Message.INFO_TIMER] = showInfo,
    },

    [State.ACTIVE_INFO] = {
      [Message.EXIT] = exitToInactive,
      [Message.CLICK_OUTSIDE] = exitToInactive,
      [Message.EXECUTE] = execute,
      [Message.NAVIGATE] = function(node)
        self.navigator:go(node)
        self.indicator:update(self.navigator:getPath())
        self.infoPanel:update(self.navigator:getChildren(), self.navigator:getPath())
      end,
      [Message.GO_BACK] = function()
        if self.navigator:back() then
          self.indicator:update(self.navigator:getPath())
          self.infoPanel:update(self.navigator:getChildren(), self.navigator:getPath())
        end
      end,
      [Message.TOGGLE_INFO] = function()
        self.infoPanel:hide()
        return State.ACTIVE
      end,
      [Message.INVALID_KEY] = function()
        self.indicator:shake()
      end,
    },
  }
end

---@param message table
---@param ... any
function LeaderKey:_dispatch(message, ...)
  local handler = self.stateMap[self.state][message]
  if handler then
    local newState = handler(...)
    if newState then
      self.state = newState
    end
  end
end

function LeaderKey:_onKeyEvent(event)
  local keyCode = event:getKeyCode()
  local flags = event:getFlags()
  self.infoPanel:onUserActivity()

  if not self.navigator.current then
    -- Cannot assert() or error() for this, or we'll consume the event and
    -- potentially disable the keyboard. Should never happen.
    print('!!! leaderkey received event while inactive')
    return false
  end

  -- This handler fires before our activation hotkey bind, so we have to handle
  -- toggling manually.
  if keyCode == self.activationKeyCode and flags:containExactly(self.activationMods) then
    self:_dispatch(Message.EXIT)
    return true
  end

  if keyCode == hs.keycodes.map.escape then
    self:_dispatch(Message.EXIT)
    return true
  end

  if keyCode == hs.keycodes.map.delete then
    self:_dispatch(Message.GO_BACK)
    return true
  end

  -- TODO handle shifted keys
  local key = hs.keycodes.map[keyCode]
  if not key then
    return true
  end

  if key == '/' and flags:contain({ 'shift' }) then -- `?`
    self:_dispatch(Message.TOGGLE_INFO)
    return true
  end

  local node = self.navigator:get(key)
  if node then
    if next(node.children) then
      self:_dispatch(Message.NAVIGATE, node)
    else
      self:_dispatch(Message.EXECUTE, node, flags:containExactly({ 'cmd' }))
    end
  else
    self:_dispatch(Message.INVALID_KEY)
  end

  return true
end

---@param keymap KeyMap[]
---@return Navigator
function Navigator.new(keymap)
  local self = setmetatable({}, Navigator)
  self.root = { path = "", children = {} }
  self.current = nil
  self:_buildNodes(keymap, self.root)
  return self
end

---@param keymap KeyMap[]
---@param parent Node
function Navigator:_buildNodes(keymap, parent)
  for i, item in ipairs(keymap) do
    local key = item[1]
    local path = parent.path .. key

    local node = {
      key = key,
      path = path,
      parent = parent,
      order = i,
      children = {},
      desc = item.desc or item.app or "",
      sticky = item.sticky and true or false,
    }

    -- Normalize all actions to fn
    if item.fn then
      node.fn = item.fn
    elseif item.app then
      node.fn = function() hs.application.launchOrFocus(item.app) end
    elseif item.url then
      -- hs.urlevent.openURL is the right thing here, but that foregrounds
      -- whatever app handles the event, which means we lose focus for
      -- non-interactive apps. Trying this as a workaround.
      node.fn = function() hs.task.new('/usr/bin/open', nil, { '-g', item.url }):start() end
    end

    parent.children[key] = node

    if item.children then
      self:_buildNodes(item.children, node)
    end
  end
end

function Navigator:start()
  self.current = self.root
end

function Navigator:stop()
  self.current = nil
end

-- Return the node for the given key in the current context, or nil if that doesn't exist.
---@param key string
---@return Node|nil
function Navigator:get(key)
  if not self.current then return nil end
  return self.current.children[key]
end

-- Navigate to the given node.
---@param node Node
---@return nil
function Navigator:go(node)
  self.current = node
end

-- Navigate one layer up the stack; returns whether it was successful.
---@return boolean
function Navigator:back()
  if self.current and self.current.parent then
    self.current = self.current.parent
    return true
  end
  return false
end

---@return Node[]
function Navigator:getPath()
  local path = {}
  local current = self.current
  while current and current ~= self.root do
    table.insert(path, 1, current)
    current = current.parent
  end
  return path
end

---@return Node[]
function Navigator:getChildren()
  if not self.current then return {} end

  local children = {}
  for _, child in pairs(self.current.children) do
    table.insert(children, child)
  end

  -- Maintain original order.
  table.sort(children, function(a, b) return a.order < b.order end)
  return children
end

---@return Indicator
function Indicator.new()
  local self = setmetatable({}, Indicator)
  self.panel = Panel.new()
  return self
end

---@param pathNodes Node[]
function Indicator:show(pathNodes)
  self:update(pathNodes)
  self.panel.screen = hs.screen.mainScreen()
  self.panel:position(Panel.pos.center())
  self.panel:show()
end

---@param pathNodes Node[]
function Indicator:update(pathNodes)
  local keyPath = pluck(pathNodes, "key")
  local text = #keyPath == 0 and "●" or table.concat(keyPath)
  local size = 92

  local element = self.panel:textElement(hs.styledtext.new(text, {
    font = { name = hs.styledtext.defaultFonts.boldSystem.name, size = 24 },
    color = { black = 1, alpha = 0.9 },
    paragraphStyle = { alignment = "center" }
  }))

  element.frame.w = size
  self.panel:setElements({ element }, { yPadding = (size - element.frame.h) / 2 })
end

function Indicator:shake()
  self.panel:animate(Panel.anim.shake)
end

---@return any|nil
function Indicator:hide()
  return self.panel:hide()
end

---@return InfoPanel
function InfoPanel.new()
  local self = setmetatable({}, InfoPanel)
  self.panel = Panel.new()
  self.autoShowTimer = nil
  return self
end

---@param relativeTo Panel
function InfoPanel:show(relativeTo)
  self.panel.screen = hs.screen.mainScreen()
  self.panel:position(Panel.pos.relativeTo(relativeTo, 'right', { offset = { x = 16 } }))
  self.panel:show()
end

---@param children Node[]
---@param pathNodes Node[]
function InfoPanel:update(children, pathNodes)
  local fonts = hs.styledtext.defaultFonts
  local padding = 8
  local keyBoxSize = 24
  local keySymbols = {
    enter = "↩",
    escape = "⎋",
    space = "␣",
    tab = "⇥",
  }
  local elements = {}
  local headerHeight = 0
  local path = pluck(pathNodes, "desc")

  if path and #path > 0 then
    local headerElement = self.panel:textElement(
      hs.styledtext.new(table.concat(path, " › "), {
        color = { red = 0.4, green = 0.4, blue = 0.4 },
        font = { name = fonts.system.name, size = 12 },
      }),
      { x = keyBoxSize + padding }
    )
    table.insert(elements, headerElement)
    headerHeight = headerElement.frame.h + padding
  end

  for i, node in ipairs(children) do
    local yOffset = headerHeight + (keyBoxSize + padding) * (i - 1)
    local displayKey = keySymbols[node.key] or node.key

    -- Key box background
    table.insert(elements, {
      type = "rectangle",
      strokeColor = { alpha = 0.2 },
      fillColor = { white = 1, alpha = 0.5 },
      roundedRectRadii = { xRadius = 5, yRadius = 5 },
      frame = { x = 0, y = yOffset, w = keyBoxSize, h = keyBoxSize }
    })
    if node.sticky then
      local radius = keyBoxSize / 6
      table.insert(elements, {
        type = "circle",
        radius = radius,
        action = "fill",
        fillColor = { white = 0.6 },
        center = { x = keyBoxSize - radius / 2, y = yOffset + keyBoxSize - radius / 2 },
      })
    end

    local keyElement = self.panel:textElement(hs.styledtext.new(displayKey, {
      font = fonts.boldSystem,
      paragraphStyle = { alignment = "center" }
    }))
    keyElement.frame.y = yOffset + (keyBoxSize - keyElement.frame.h) / 2
    keyElement.frame.w = keyBoxSize
    table.insert(elements, keyElement)

    local descElement = self.panel:textElement(
      hs.styledtext.new(
        next(node.children) and "› " .. node.desc or node.desc,
        { font = fonts.system }
      ),
      { x = keyBoxSize + padding }
    )
    descElement.frame.y = yOffset + (keyBoxSize - descElement.frame.h) / 2
    table.insert(elements, descElement)
  end

  self.panel:setElements(elements, { padding = 16 })
end

---@return any|nil
function InfoPanel:hide()
  return self.panel:hide()
end

---@return boolean
function InfoPanel:isVisible()
  return self.panel:isShowing()
end

---@param delay number
---@param callback function
function InfoPanel:startAutoShow(delay, callback)
  self:cancelAutoShow()
  self.autoShowTimer = hs.timer.doAfter(delay, function()
    if callback then callback() end
    self.autoShowTimer = nil
  end)
end

function InfoPanel:cancelAutoShow()
  if self.autoShowTimer then
    self.autoShowTimer:stop()
    self.autoShowTimer = nil
  end
end

function InfoPanel:onUserActivity()
  self:cancelAutoShow()
end

return LeaderKey
