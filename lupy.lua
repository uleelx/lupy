local getinfo, upvaluejoin = debug.getinfo, debug.upvaluejoin
local getfenv, setfenv, setmetatable, rawset, type = getfenv, setfenv, setmetatable, rawset, type
local unpack, concat, insert = unpack or table.unpack, table.concat, table.insert
local pairs, match = pairs, string.match

local metamethods = {
  "__add", "__sub", "__mul", "__div", "__mod", "__pow", "__unm",
  "__concat", "__len", "__eq", "__lt", "__le","__newindex", "__call"
}

local Object = {__index = _ENV, __type__ = {"Object"}}
setmetatable(Object, Object)

return function(name)
  if _VERSION == "Lua 5.2" then
    upvaluejoin(getinfo(1, 'f').func, 1,
                getinfo(2, 'f').func, 1)
  end
  local env = _ENV or getfenv(2)
  local clsname, supername = match(name, "([%w_]*)%s*<?%s*([%w_]*)")
  local newclass = env[clsname]
  if not newclass then
    local superclass = env[supername] or (env.__type__ and Object or env)
    newclass = {
      __type__ = {
        env.__type__ and env.__type__[1].."::"..clsname or clsname,
        unpack(superclass.__type__ or {"Object"})
      },
      is = function(self, c)
        return match(concat(self.__type__, ','), (c or "([^,]+)"))
      end,
      include = function(m)
        insert(newclass.__type__, 2, m.__type__[1])
        for k, v in pairs(m) do
          if k ~= "__index" and
             k ~= "__type__" and k ~= "__class__" and
             k ~= "include" and k ~= "is" then
            newclass[k] = v
          end
        end
      end,
      __index = function(self, member_name)
        local member = newclass[member_name]
        if type(member) == "function" then
          return function(...) return member(self, ...) end
        else
          return member or newclass.__missing__ and function(...)
            return newclass.__missing__(self, member_name, ...)
          end
        end
      end
    }
    for _, k in pairs(metamethods) do newclass[k] = superclass[k] end
    newclass.__class__ = newclass
    local meta = {
      __index = superclass,
      __call = function(class, ...)
        local instance = setmetatable({}, class)
        if class.__init__ then class.__init__(instance, ...) end
        return instance
      end
    }
    if _VERSION == "Lua 5.1" then
      meta.__newindex = function(class, k, v)
        if type(v) == "function" then setfenv(v, _G) end
        rawset(class, k, v)
      end
    end
    setmetatable(newclass, meta)
    env[clsname] = newclass
  end
  if _VERSION == "Lua 5.1" then
    newclass._end = function()
      _ENV, newclass._end = nil
      setfenv(2, env)
    end
    setfenv(2, newclass)
  else
    newclass._end = function() _ENV, _end = env end
    _ENV = newclass
  end
end
