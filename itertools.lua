local class = require 'lupy'

local module = class -- alias

---------------
---Interface---
---------------

module [[Iterable]]

  function __call(self)
    local items = {self.next()}
    if #items > 0 then return table.unpack(items) end
    self.reset()
  end

_end()


---------------
---Iterators---
---------------

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


class [[Chain]]

  include(Iterable)
  
  function __init__(self, ...)
    self.iters = iter{...}
    self.reset()
  end

  function reset(self)
    self.yield = self.iters()
    self.yield = self.yield and iter(self.yield)
  end

  function next(self)
    local item  = self.yield()
    if item then return item end
    self.reset()
    if not self.yield then return end
    return self.next()
  end

_end()


class [[Reverse < Sequence]]

  include(Iterable)

  function reset(self)
    self.pointer = #self.seq + 1
  end
  
  function next(self)
    if not self.pointer then self.reset() end
    self.pointer = self.pointer - 1
    return self.seq[self.pointer]
  end

_end()


class [[Range]]

  include(Iterable)

  function __init__(self, i, j, s)
    self.start = i or 1
    self.last = j
    self.step = s or (j < i and -1 or 1)
    self.reset()
  end
  
  function reset(self)
    self.pointer = self.start - self.step
  end
  
  function next(self)
    self.pointer = self.pointer + self.step
    if (self.step > 0 and self.pointer <= self.last)
      or (self.step < 0 and self.pointer >= self.last) then
      return self.pointer
    end
    self.reset()
  end

_end()


class [[Map]]

  include(Iterable)

  function __init__(self, f, ...)
    self.func = f
    self.its = {...}
    for i = 1, #self.its do
      self.its[i] = iter(self.its[i])
    end
    self.its = iter(self.its)
  end
  
  function reset(self)
    for it in self.its do
      it.reset()
    end
  end
  
  function next(self)
    local x = {}
    local done = false
    for it in self.its do
      x[#x + 1] = it()
      done = done or x[#x] == nil
    end
    if not done then return self.func(table.unpack(x)) end
  end

_end()

class [[Pair]]

  include(Iterable)
  
  function __init__(self, t)
    self.table = t
    self.reset()
  end
  
  function reset(self)
    self.yield = pairs(self.table)
    self.pointer = nil
  end
  
  function next(self)
    local k, v = self.yield(self.table, self.pointer)
    self.pointer = k
    return k, v
  end
  
_end()

--------------
---wrappers---
--------------

function iter(seq)
  if seq.is and seq.is("Iterable") then 
    return seq
  elseif type(seq) == "table" then
    return Sequence(seq)
  end
  error "Can not iterate"
end

function list(iterator)
  if iterator.is and iterator.is("Iterable") then
    local sequence = {}
    for x in iterator do
      table.insert(sequence, x)
    end
    return sequence
  elseif type(iterator) == "table" then
    return iterator
  end
  error "Can not make a list"
end

function chain(...)
  return Chain(...)
end

function reverse(sequence)
  return Reverse(list(sequence))
end

function range(i, j, s)
  return Range(i, j, s)
end

function map(f, ...)
  return Map(f, ...)
end

function zip(...)
    return map(function(...) return ... end, ...)
end

function pair(...)
  return Pair(...)
end
