Utils = {}

function Utils.round(n, d)
  d = d or 0
  local m = 10 ^ d
  return math.floor((tonumber(n) or 0) * m + 0.5) / m
end

function Utils.money(n)
  n = math.floor(tonumber(n) or 0)
  local s = tostring(n)
  local out = s:reverse():gsub('(%d%d%d)', '%1,'):reverse()
  return out:gsub('^,', '')
end

function Utils.now()
  return os.time()
end

function Utils.trim(v)
  return tostring(v or ''):gsub('^%s+', ''):gsub('%s+$', '')
end

function Utils.bool(v)
  return v == true or v == 1 or v == '1'
end

function Utils.enc(v)
  return json.encode(v)
end

function Utils.dec(v, fallback)
  if type(v) == 'table' then return v end
  if type(v) ~= 'string' or v == '' then return fallback end
  local ok, res = pcall(json.decode, v)
  if ok then return res end
  return fallback
end

function Utils.gradeRight(grade, right)
  local grades = Config.Business and Config.Business.grades or {}
  local cfg = grades[tonumber(grade) or 0] or grades[0]
  return cfg and cfg[right] == true or false
end
