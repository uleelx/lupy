local class = require 'lupy'

class [[PipeElement]]

  function __init__(self)
    self.runner = coroutine.create(self.process)
  end

  function resume(self)
    local ok, ret = coroutine.resume(self.runner)
    if ok then return ret end
  end

  function input(self)
    return self.source.resume()
  end

  function process(self)
    local value = self.input()
    while value do
      self.handle_value(value)
      value = self.input()
    end
  end

  function handle_value(self, value)
    self.output(value)
  end

  function output(self, value)
    coroutine.yield(value)
  end

  function __sub(self, other)
    other.source = self
    return other
  end

_end()


-- tests (KWIC system with pipe filter architecture)
if not ... then

class [[Input < PipeElement]]

  function load(self, str)
    self.stream = str
  end

  function process(self)
    for line in string.gmatch(self.stream, "([^\n]+)") do
      self.output(line)
    end
  end

_end()


class [[CircularShifter < PipeElement]]

  function handle_value(self, line)
    local line_a = {}
    for word in string.gmatch(line, "(%w+)") do
      line_a[#line_a + 1] = word
    end
    for i = 1, #line_a do
      table.insert(line_a, 1, table.remove(line_a))
      self.output(table.concat(line_a, " "))
    end
  end

_end()


class [[Alphabetizer < PipeElement]]

  function process(self)
    local result = {}
    local value = self.input()
    while value do
      result[#result + 1] = value
      value = self.input()
    end
    table.sort(result)
    for _, line in ipairs(result) do
      self.output(line)
    end
  end

_end()


class [[Output < PipeElement]]

  function handle_value(self, str)
    print(str)
  end

_end()

-- create the filters
local input = Input()
local shift = CircularShifter()
local alpha = Alphabetizer()
local echo = Output()

-- create the pipeline(connect the filters)
local pipeline = input-shift-alpha-echo

-- preload the source of pipeline
input.load([[Star Wars
The Empire Strikes Back
The Return of the Jedi]])

-- activate the pipeline
pipeline.resume()

--[[
prints this:

Back The Empire Strikes
Empire Strikes Back The
Jedi The Return of the
Return of the Jedi The
Star Wars
Strikes Back The Empire
The Empire Strikes Back
The Return of the Jedi
Wars Star
of the Jedi The Return
the Jedi The Return of
]]
end
