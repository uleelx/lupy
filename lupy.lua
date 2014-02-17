local getinfo, upvaluejoin = debug.getinfo, debug.upvaluejoin
local setmetatable, rawset, type = setmetatable, rawset, type
local unpack, concat, insert = table.unpack, table.concat, table.insert
local ipairs, pairs, match = ipairs, pairs, string.match

local metamethods = {
  "__add", "__sub", "__mul", "__div", "__mod", "__pow", "__unm", "__concat",
  "__len", "__eq", "__lt", "__le", "__newindex", "__call", "__pairs", "__ipairs"
}

local function is(self, c)
  return match(concat(self.__type__, ','), (c or "([^,]+)"))
end

local function include(class, m)
  insert(class.__type__, 2, m.__type__[1])
  for k, v in pairs(m) do
    if k ~= "__index" and k ~= "__type__"and k ~= "include" then
      class[k] = v
    end
  end
end

local function retrieve(self, member_name)
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

local Object = {__index = _ENV, __type__ = {"Object"}, is = is}
setmetatable(Object, Object)

local function class(name)
  local env = _ENV
  local clsname, supername = match(name, "([%w_]*)%s*<?%s*([%w_]*)")
  local newclass = env[clsname]
  if not newclass then
    local superclass = env[supername] or Object
    newclass = {
      __type__ = {clsname, unpack(superclass.__type__)},
      include = function(m) include(newclass, m) end,
      __index = retrieve
    }
    for _, k in ipairs(metamethods) do newclass[k] = superclass[k] end
    setmetatable(newclass, {
      __index = superclass,
      __call = function(class, ...)
        local instance = setmetatable({__class__ = class}, class)
        if class.__init__ then class.__init__(instance, ...) end
        return instance
      end
    })
    env[clsname] = newclass
  end
  upvaluejoin(class, 1, getinfo(2, 'f').func, 1)
  newclass._end = function() _ENV, _end = env end
  _ENV = newclass
end

return class