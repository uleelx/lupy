local metamethods = {
  "__add", "__sub", "__mul", "__div", "__mod", "__pow", "__unm", "__concat", "__len",
  "__eq", "__lt", "__le", "__newindex", "__call", "__pairs", "__ipairs", "__gc"
}

local function new(class, ...)
  local o = setmetatable({__class__ = class}, class)
  if class.__init__ then class.__init__(o, ...) end
  return o
end

local function include(m)
  debug.upvaluejoin(include, 1, debug.getinfo(2, 'f').func, 1)
  table.insert(_ENV.__type__, 2, m.__type__[1])
  for k, v in pairs(m) do
    if k ~= "__index" and k ~= "__type__" then _ENV[k] = v end
  end
end

local function is(self, c)
  return string.match(table.concat(self.__type__, ','), (c or "([^,]+)"))
end

local function dig(self, member_name)
  local class = self.__class__
  local member = class[member_name]
  if type(member) == "function" then
    return function(...) return member(self, ...) end
  else
    return member or class.__missing__ and function(...)
      return class.__missing__(self, member_name, ...)
    end
  end
end

local Object = {__index = _ENV, __type__ = {"Object"}, is = is, include = include}
setmetatable(Object, Object)

local function class(name)
  local env = _ENV
  local name, supername = string.match(name, "([%w_]*)%s*<?%s*([%w_]*)")
  local self = env[name]
  if not self then
    local super = env[supername] or Object
    self = {__index = dig, __type__ = {name, table.unpack(super.__type__)}}
    for _, k in ipairs(metamethods) do self[k] = super[k] end
    setmetatable(self, {__index = super, __call = new})
    env[name] = self
  end
  debug.upvaluejoin(class, 1, debug.getinfo(2, 'f').func, 1)
  self._end = function() _ENV, _end = env end
  _ENV = self
end

return class
