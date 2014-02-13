-- this file contains several tests for lupy basics
require 'array'
require 'curry'

local class = require 'lupy'
local module = class -- alias
local printTable = compose(print, Array)

-- class and module refers to the same function, but we assume this:
-- 1. module is a set of functions and constant variables (no inheritance, no instance)
-- 2. class is a prototype or template for creating objects (cannot be mixed in)


-----------------
----namespace----
-----------------

-- see 'inner class' section for more namespace examples

-- open an existing module(table) to do monkey patching
module [[math]]

  function powmod(x, y, m)
    local result = 1
    local r
    x = x % m
    while y ~= 0 do
      y, r = math.floor(y / 2), math.fmod(y, 2)
      if r == 1 then
        result = (result*x) % m
      end
      x = (x*x) % m
    end
    return result
  end

_end()

if _VERSION == "Lua 5.1" then setfenv(math.powmod, _G) end -- because 'math' module is not created by lupy

print("10**11 mod 12 = "..math.powmod(10, 11, 12)) --> 4


----------------------
----class property----
----------------------
class [[counter]]

  count = 0 -- class property
  
  function __init__(self)
    self.__class__.count = self.__class__.count + 1 -- __class__ refers to counter
  end
  
_end()

print(counter.count) --> 0

local c = counter()
print(c.count) --> 1

print(counter.count) --> 1

local d = counter()
print(d.count) --> 2

print(c.count) --> 2

print(counter.count) --> 2


--------------------
----type testing----
--------------------
class [[A]]
  function conflict(self)
    print("A")
  end
_end()

class [[B < A]] -- inheritance
  function conflict(self)
    print("B")
  end
_end()

local a = A()
local b = B()

local a_type = a.is() -- pass nil to instance function 'is' to get the instance type name
local b_type = b.is()

print(a_type)           -- 'A'
print(b_type)           -- 'B'

print(a.is(a_type))     -- 'A'
print(a.is(b_type))     -- nil

print(b.is(a_type))     -- 'A'
print(b.is(b_type))     -- 'B'

printTable(A.__type__) -- [A, Object]
printTable(B.__type__) -- [B, A, Object]


--------------------
----inner class-----
--------------------
function conflict()
  print("global")
end

class [[Outer]]
  
  function __init__(self)
    self.inner = self.Inner()
    self.__class__.inner = self.Inner()
  end
  
  function conflict(self)
    print(self, "outer")
  end
  
  class [[Inner]]

    function conflict(self)
      print(self, "inner")
    end

  _end()

_end()


local outer = Outer()
local inner = Outer.Inner()
conflict()                -- 'global'
outer.conflict()          -- outer instance, 'outer'
outer.inner.conflict()    -- inner instance of outer instance, 'inner'
Outer.inner.conflict()    -- inner instance of Outer class, 'inner'
inner.conflict()          -- inner instance, 'inner'
Outer.conflict()          -- nil, 'outer'
Outer.Inner.conflict()    -- nil, 'inner'
printTable(Outer.Inner.__type__) -- [Outer::Inner, Object]


-----------------------------
----inheritance and mixin----
--------(from Ruby)----------
-----------------------------
module [[C]]
  function conflict(self)
    print("C")
  end
_end()

module [[D]]
  function conflict(self)
    print("D")
  end
_end()

class [[E < B]] -- inheritance
  include(C) -- mixin
  include(D)
_end()

local e = E()
e.conflict() -- print 'D'

printTable(E.__type__) -- [E, D, C, B, A, Object]
