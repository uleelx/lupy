require 'array'

local class = require 'lupy'

class [[XML]]

  function __init__(self)
    self.builder = Array()
  end
  
  function cat(self, ...)
    return Array(...).join("\n")
  end
  
  function append(self, ...)
    self.builder.append(...)
  end
  
  function __tostring(self)
    return self.builder.join("\n")
  end
  
  function __missing__(self, tag, ...) -- using __missing to handle unpredictable tag name given by user
    if type(...) == "table" then
      return self.Node(tag, self.cat(...), true)
    else
      return self.Node(tag, ...)
    end
  end
  
  class [[Node]] -- an inner class of XML

    function __init__(self, tag, value, complex)
      self.tag = tag
      self.value = value
      self.fmt = complex and "\n" or ""
    end
    
    function __tostring(self)
      return string.format(
        "<%s>%s%s%s</%s>",
        self.tag, self.fmt,
        self.value,
        self.fmt, self.tag
      )
    end
 
  _end()

_end()


-- tests
if not ... then

local xml = XML()
xml.append(
  xml.Person(
    xml.Name("Peer"),
    xml.Gender("Male"),
    xml.Age("24"),
    xml.Score(
      xml.Math("A"),
      xml.Physics("B")
    )
  ),
  xml.Person(
    xml.Name("Maud"),
    xml.Gender("Female"),
    xml.Age("25"),
    xml.Score(
      xml.Music("C"),
      xml.Chemistry("A")
    )
  )
)
print(xml)

end
