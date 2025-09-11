Util = {}

function Util.now() return os.time() end
function Util.uuid()
  return ('%08x%04x%04x%04x%012x'):format(
    math.random(0,0xffffffff),
    math.random(0,0xffff),
    math.random(0,0xffff),
    math.random(0,0xffff),
    math.random(0,0xffffffffffff)
  )
end
