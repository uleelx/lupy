lupy
===========

A small Python-style OO implementation for Lua. It also gains some good features from Ruby.<br>
It has been tested on Lua 5.2.3 using the examples in repo. Welcome to fork and test it more.

Philosophy
===========

"Things should be as simple as possible, but no simpler." [[1]](http://python-history.blogspot.com/2009/01/pythons-design-philosophy.html)

Usage
==========
Copy *lupy.lua* file to your project or where your lua libraries stored.<br>
Then write this in any Lua file where you want to use it:
```lua
local class = require 'lupy'
```
More usage can be found in the examples.

Quick Look
==========

```lua
local class = require 'lupy'

class [[Person]]

  function __init__(self, name)
    self.name = name
  end

  function say(self, msg)
    print(self.name.." says: "..msg)
  end

_end()

local I = Person("Peer")

I.say("Hello world!")

-- Peer says: Hello world!

```

Features
=======

- Python-like constructor, method definition, instance creating and method calling
- Ruby-like inheritance, mixins, missing methods handler and monkey patching
- lexical scope based encapsulation
- inheritance tree based type testing
- namespace and inner class support
- metamethods support
- class property support
- abstract method support

License
=======

lupy is distributed under the MIT license.
