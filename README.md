lupy
===========

A small Python-style OO implementation for Lua. It also gains some good features from Ruby.
It has been tested on Lua 5.2.3 and LuaJIT 2.0.2 using the examples in repo. Welcome to test it more.

Quick Look
==========

```lua
local class = require 'lupy'

local unpack = unpack or table.unpack

class [[Iterator]]

  function __init__(self, seq)
    self.seq = seq
  end
  
  function reset(self)
    self.pointer = 0
  end
  
  function next(self)
    if not self.pointer then self.reset() end
    self.pointer = self.pointer + 1
    return self.seq[self.pointer]
  end
  
  function __call(self)
    local items = {self.next()}
    if #items > 0 then return unpack(items) end
    self.reset()
  end

_end()

function iter(seq)
  if seq.is and seq.is("Iterator") then 
    return seq
  elseif type(seq) == "table" then
    return Iterator(seq)
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
Add *lupy.lua* file inside your project or where you store your lua libraries.
Then write this in any Lua file where you want to use it:
```lua
local class = require 'lupy'
```
More usage can be found in the examples.

License
=======

lupy is distributed under the MIT license.
