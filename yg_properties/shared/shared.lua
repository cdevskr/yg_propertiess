Shared = {}

function Shared.IsAdmin(playerData)
  if not playerData or not playerData.permission then return false end
  for _, g in ipairs(Config.AdminGroups) do
    if playerData.permission == g then return true end
  end
  return false
end

function Shared.BucketForProperty(propertyId)
  return Config.BucketBase + tonumber(propertyId)
end

function Shared.DecodeVec4(jsonStr)
  local t = json.decode(jsonStr)
  return vector4(t.x + 0.0, t.y + 0.0, t.z + 0.0, (t.w or 0.0) + 0.0)
end

function Shared.EncodeVec4(v)
  return json.encode({ x = v.x, y = v.y, z = v.z, w = v.w or 0.0 })
end