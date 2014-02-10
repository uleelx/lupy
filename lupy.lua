if _VERSION == "Lua 5.2" and ... then
  local modname = ...
  local getinfo, upvaluejoin = debug.getinfo, debug.upvaluejoin
  if getinfo(require, "S").what == "C" then
    upvaluejoin(getinfo(1, 'f').func, 1, getinfo(3, 'f').func, 1)
    local _require = require
    require = function(m)
      if m == modname then
        package.loaded[modname] = nil
      end
      return _require(m)
    end
  else
    upvaluejoin(getinfo(1, 'f').func, 1, getinfo(4, 'f').func, 1)
  end
end

local unpack, concat, insert = unpack or table.unpack, table.concat, table.insert
local match = string.match

local metamethods = {
  "__add", "__sub", "__mul", "__div", "__mod", "__pow", "__unm",
  "__concat", "__len", "__eq", "__lt", "__le","__newindex", "__call"
}

return function(name)
  local env = _ENV or getfenv(2)
  local clsname, supername = match(name, "([%w_]*)%s*<?%s*([%w_]*)")
  local newclass = env[clsname]
  if not newclass then
    local superclass = env[supername] or env
    newclass = {
      __type = {clsname, unpack(superclass.__type or {"Object"})},
      is = function(self, c) return match(concat(self.__type, ','), (c or "([^,]+)")) end,
      include = function(...)
        for i = 1, select("#", ...) do
          local cls = select(i, ...)
          insert(newclass.__type, 2, cls.__type[1])
          for k, v in pairs(cls) do
            if k ~= "__type" and k ~= "__index" and k ~= "include" and k ~= "is" then
              newclass[k] = v
            end
          end
        end
      end,
      __index = function(self, member_name)
        local member = newclass[member_name]
        if type(member) == "function" then
          if _VERSION == "Lua 5.1" then setfenv(member, _G) end
          return function(...)
            return member(self, ...)
          end
        else
          return member or newclass.__missing and function(...)
            return newclass.__missing(self, member_name, ...)
          end
        end
      end
    }
    for _, k in pairs(metamethods) do
      newclass[k] = superclass[k]
    end
    setmetatable(newclass, {
      __index = superclass,
      __call = function(class, ...)
        local instance = setmetatable({}, class)
        if class.__init__ then class.__init__(instance, ...) end
        return instance
      end
    })
    env[clsname] = newclass
  end
  newclass._end = function() _ENV, _end = env end
  _ENV = newclass
  if _VERSION == "Lua 5.1" then
    newclass._end = function()
      _ENV, newclass._end = nil
      setfenv(2, env)
    end
    setfenv(2, newclass)
  end
end
