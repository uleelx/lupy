-- using lupy as a namespace function
-- you can name it 'module', 'namespace', etc.
local module = require 'lupy'

-- open an existing namespace(table) to do monkey patching
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


if _VERSION == "Lua 5.1" then setfenv(math.powmod, _G) end

-- test
print("10**11 mod 12 = "..math.powmod(10, 11, 12)) --> 4

print("\n----- show newest math library-----")
for k, v in pairs(math) do
  io.write(k.."\t"..tostring(v))
  if k == "powmod" then
    print("  (this function is added by monkey patching)")
  else
    io.write('\n')
  end
end