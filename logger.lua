local class = require 'lupy'

class [[Logger]]

  levels = {"debug", "info", "warn", "error", "fatal"} -- class property

  function __init__(self, target)
    self.target = target
  end

  function layout(self, timestamp, src, nline, level, message)
    return string.format("[%s] (%s: %s) - %s : %s\n", timestamp, src, nline, level, message)
  end

  function commit(self, level, message)
    local info = debug.getinfo(3, "Sl")
    self.target:write(self.layout(
      os.date("%Y-%m-%d %H:%M:%S"),
      info.short_src,
      info.currentline,
      level:upper(),
      message)
    )
  end

  -- create level functions, _ENV refers to class itself
  for _, level in ipairs(levels) do
    _ENV[level] = function (self, message)
      self.commit(level, message)
    end
  end

_end()


class [[ConsoleLogger < Logger]]

  function __init__(self)
    Logger.__init__(self, io.stdout)
  end

_end()


class [[FileLogger < Logger]]

  function __init__(self, filename)
    Logger.__init__(self, assert(io.open(filename, "a+")))
  end

_end()


-- tests
if not ... then

local consoleLogger = ConsoleLogger()
consoleLogger.debug("debug log message")
consoleLogger.info("info log message")
consoleLogger.warn("warn log message")
consoleLogger.error("error log message")
consoleLogger.fatal("fatal log message")

local fileLogger = FileLogger("log.txt")
fileLogger.debug("debug log message")
fileLogger.info("info log message")
fileLogger.warn("warn log message")
fileLogger.error("error log message")
fileLogger.fatal("fatal log message")

end
