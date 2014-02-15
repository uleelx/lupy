-- this file contains several tests for lupy basics
require 'array'
require 'curry'

local class = require 'lupy'
local module = class -- alias
local printTable = compose(print, Array)

-- class and module refers to the same function, but we assume this:
-- 1. module is a set of functions and constant variables (no inheritance, no instance)
-- 2. class is a prototype or template for creating objects (cannot be mixed in)


-------------------------------
----define, create and call----
-------------------------------

class [[Person]]

  function __init__(self, name)
    self.name = name
  end
  
  function say(self, msg)
    print(self.name..": "..msg)
  end

_end()

local I = Person("Peer")
I.say("Hello world!")


-----------------
----namespace----
-----------------

-- see 'inner class' section for more namespace examples

-- open an existing module, class or raw table to do monkey patching
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

print(count) -- nil, because 'count' is not a global value

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

----------------------
----method missing----
-----(from Ruby)------
----------------------

class [[Person]]

  function __init__(self, name)
    self.name = name
  end

  function __missing__(self, method_name, ...)
    self[method_name] = ...
  end

_end()

local me = Person("Peer")
me.age(24)
me.location("Mars")

print("My name is "..me.name..". I'm "..me.age.." years old. I come from "..me.location..".")


----------------------
------metamethods-----
----------------------

class [[Complex]]

  function __init__(self, realpart, imagpart)
    self.r = realpart
    self.i = imagpart
  end
  
  function __tostring(self)
    return string.format("%f %s %fi", self.r, self.i > 0 and "+" or "-", math.abs(self.i))
  end
  
  function __add(self, other)
    return Complex(self.r + other.r, self.i + other.i)
  end
  
_end()

local x = Complex(3.0, -4.5)
local y = Complex(2.0, 7.6)
print("x = ", x)
print("y = ", y)
print("x + y = ", x + y)

class [[Complex]] -- monkey patching
  
  function __sub(self, other)
    return Complex(self.r - other.r, self.i - other.i)
  end
  
_end()

print("x - y = ", x - y)


----------------------------
-------encapsulation--------
-----(private members)------
----------------------------

-- lupy doesn't offer unique mechanism to do encapsulation
-- but it's easy to do it using Lua's block mechanism(lexical scope)

class [[Test]] do

  local private = {}
  
  function __init__(self, value)
    private[self] = {value = value}
  end
  
  function getValue(self)
    return private[self].value
  end
  
  local function store(self, value) -- private method
    private[self].value = string.format("[--%s--]", value)
  end
  
  function setValue(self, value)
    store(self, value)
  end

end _end()

print(private)              -- nil
print(store)                -- nil

local test = Test("Peer")
print(test.private)         -- nil
print(test.store)           -- nil

print(test.value)           -- nil
print(test.getValue())      -- Peer

test.setValue("Maud")
print(test.getValue())      -- [--Maud--]

local test2 = Test("Peer")
print(test2.getValue())     -- Peer
print(test.getValue())      -- [--Maud--]

test2.setValue("Ning")
print(test2.getValue())     -- [--Ning--]
print(test.getValue())      -- [--Maud--]


--------------------
----polymorphism----
--------------------

class [[Animal]]

  function __init__(self, name)  -- Constructor of the class
    self.name = name
  end
  
  function talk(self)            -- Abstract method, functionined by convention only
    error("Subclass must implement abstract method")
  end

_end()


class [[Cat < Animal]]

  function talk(self)
    return 'Meow!'
  end
  
_end()


class [[Dog < Animal]]

  function talk(self)
    return 'Woof! Woof!'
  end
  
_end()


local animals = Array(Cat('Missy'), Cat('Mr. Mistoffelees'), Dog('Lassie'))

for animal in animals do
  print(animal.name..': '..animal.talk())
end

-- prints the following:
--
-- Missy: Meow!
-- Mr. Mistoffelees: Meow!
-- Lassie: Woof! Woof!
