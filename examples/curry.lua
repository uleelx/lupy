-- test for curry -> itertools -> class

require 'itertools'

function curry(func, ...)
  local prebind = {...}
  local nparams = debug.getinfo(func, "u").nparams
  local function helper(arg_chain, still_need)
    if still_need < 1 then
      return func(table.unpack(list(arg_chain)))
    else
      return function (...)
        local tail_args = {...}
        return helper(
          chain(arg_chain, tail_args),
          still_need - math.max(1, #tail_args)
        )
      end
    end
  end
  return helper(prebind, math.max(1, nparams - #prebind))
end

function compose(f, g, ...)
  local lambdas = {f, g, ...}
  return function(...)
    local state = {...}
    for lambda in reverse(lambdas) do
      state = {lambda(table.unpack(state))}
    end
    return table.unpack(state)
  end
end

function travel(process, iterator)
  repeat
    local items = {iterator()}
    if #items > 0 then
      if type(process) == "function" then
        process(table.unpack(items))
      end
    end
  until #items == 0
end


-- tests
if not ... then

function multiplyAndAdd (a,b,c) return a * b + c end
multiplyAndAdd_curried         = curry(        multiplyAndAdd       )

multiplyBySevenAndAdd_v1       = multiplyAndAdd_curried(    7       )
multiplyBySevenAndAdd_v2       = curry( multiplyAndAdd,     7       )

multiplySevenByEightAndAdd_v1  = multiplyAndAdd_curried(    7, 8    )
multiplySevenByEightAndAdd_v2  = curry(    multiplyAndAdd,  7, 8    )
multiplySevenByEightAndAdd_v3  = multiplyBySevenAndAdd_v1(     8    )
multiplySevenByEightAndAdd_v4  = multiplyBySevenAndAdd_v2(     8    )

multiplySevenByEightAndAddNine = curry( multiplyAndAdd,  7, 8, 9    )

assert( multiplyAndAdd(7, 8, 9) == multiplyBySevenAndAdd_v1(8, 9)      )
assert( multiplyAndAdd(7, 8, 9) == multiplyBySevenAndAdd_v2(8, 9)      )
assert( multiplyAndAdd(7, 8, 9) == multiplySevenByEightAndAdd_v1(9)    )
assert( multiplyAndAdd(7, 8, 9) == multiplySevenByEightAndAdd_v2(9)    )
assert( multiplyAndAdd(7, 8, 9) == multiplySevenByEightAndAdd_v3(9)    )
assert( multiplyAndAdd(7, 8, 9) == multiplySevenByEightAndAdd_v4(9)    )
assert( multiplyAndAdd(7, 8, 9) == multiplySevenByEightAndAddNine()    )

---
before = curry(compose)

printAfter = before(print)

printf = printAfter(string.format)

-- travel table and print each pair after string formating("key" => value)
pp = compose(curry(travel, curry(printf, '%q => %s')), pair)
pp(_G)

-- print the result of 'a' multiply 'b' and add 'c'
printStuff = printAfter(multiplyAndAdd)
printStuff(7, 8, 9) -- print 65 as the result of 7 * 8 + 9

end
