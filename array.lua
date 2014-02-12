require 'itertools'

local class = require 'lupy'
local unpack = unpack or table.unpack

class [[Array < Sequence]]

  include(Iterable) -- classes mixin(like Ruby)

  function __init__(self, ...)
    self.seq = {...}
    if #self.seq == 1 and type(self.seq[1]) == "table" then
      self.seq = {unpack(self.seq[1])}
    end
  end

  function get(self, i)
    return self.seq[i]
  end

  function set(self, i, v)
    self.seq[i] = v
  end

  function length(self)
    return #self.seq
  end

  function __tostring(self) -- representation function used by tostring(like Python's __str__)
    local ret = "["
    for v in self do
      ret = ret..tostring(v)..", "
    end
    return ret:gsub(", $", "]")
  end

_end()


class [[Array]] -- reopen class here to add or modify sth.(i.e. monkey patching)(like Ruby)

  function append(self, ...)
    for i = 1, select("#", ...) do
      self.seq[#self.seq + 1] = select(i, ...)
    end
  end
  
  function slice(self, m, n)
    m = m > 0 and m or (m + #self.seq + 1)
    n = n > 0 and n or (n + #self.seq + 1)
    local new_seq = Array()
    for i = m, n do
      new_seq.append(self.get(i))
    end
    return new_seq
  end

  function join(self, sep)
    sep = sep or ""
    local ret = ""
    for e in self do
      ret = ret..tostring(e)..sep
    end
    return ret:sub(1, #ret - #sep)
  end

  function __add(self, b) -- operator overloading (+)
    return Array(list(chain(self, b)))
  end
  
  function __newindex(self, i, v)
    if type(i) == "number" then
      rawset(self.seq, i, v)
    else
      rawset(self, i, v)
    end
  end

_end()


-- tests
if not ... then

class [[Stack < Array]] -- inheritance(like Ruby)

  function push(self, v)
    self.append(v)
  end
  
  function pop(self)
    return table.remove(self.seq)
  end
  
  function top(self)
    return self.get(self.length())
  end
  
  function __tostring(self) -- override
    return "["..Array.__tostring(self)..">" -- calling superclass's method(like Python)
  end

_end()

local a = Array(1, 2, 3, 4, 5) -- create an Array instance(like Python)
print("a = ", a, "initial state")

for v in a do -- test for 'Iterator' mixin
  io.write(v.." ")
end
print("\titerate 'a'")

for v in a do -- iterate again
  io.write(v.." ")
end
print("\titerate 'a' again")

print("a[2] = ", a.get(2), "using 'get' method")

a.set(4, 9)
print("a=", a, "set a[4] = 9, using 'set' method")

a[3] = 8
print("a=", a, "set a[3] = 8, using '__newindex' metamethod\n")

local b = a.slice(2, -2) -- create a new Array instance by 'slice' method
print("b = ", b, "this is a slice of 'a' (i.e. b = a[2, -2])")
print("len(b) = ", b.length(), "using 'length' method\n")


local c = Stack(1, 2, 3) -- test for subclass(inheritance)
print("c = ", c, "initial stack")

c.set(3, 4)
print("c=", c, "set c[3]=4, test for calling superclass method")

c.push(5)
print("c = ", c, "push '5' to the top of stack")

print("top(c) = ", c.top(), "using 'top' method")
print("top(c) = ", c.pop(), "using 'pop' method")
print("c = ", c, "final state\n")

-- test for operator overloading
print("a + b + c = ", a + b + c , "using '__add' metamethod\n")

end -- end of tests
