lupy
===========

A small Python-style OO implementation for Lua. It also gains some good features from Ruby.<br>
It has been tested on Lua 5.2.3 and LuaJIT 2.0.2 using the examples in repo. Welcome to fork and test it more.

Quick Look
==========

```lua
local class = require 'lupy'

local module = class -- alias

local unpack = unpack or table.unpack

module [[Iterable]]

  function __call(self)
    local items = {self.next()}
    if #items > 0 then return unpack(items) end
    self.reset()
  end

_end()

class [[Sequence]]

  include(Iterable)
  
  function __init__(self, seq)
    self.seq = seq
    self.reset()
  end
  
  function reset(self)
    self.pointer = 0
  end
  
  function next(self)
    self.pointer = self.pointer + 1
    return self.seq[self.pointer]
  end

_end()

function iter(seq)
  if seq.is and seq.is("Iterable") then 
    return seq
  elseif type(seq) == "table" then
    return Sequence(seq)
  end
  error "Can not iterate"
end

local ary = iter{'one', 'two', 'three'}

for e in ary do
  print(e)
end

--[[
one
two
three
]]

```

Usage
==========
Copy *lupy.lua* file to your project or where your lua libraries stored.<br>
Then write this in any Lua file where you want to use it:
```lua
local class = require 'lupy'
```
More usage can be found in the examples.

License
=======

lupy is distributed under the MIT license.
