Bridge = Bridge or { target = nil }

local function detectTarget()
  if GetResourceState('ox_target') == 'started' then
    Bridge.target = 'ox'
  elseif GetResourceState('qb-target') == 'started' then
    Bridge.target = 'qb'
  else
    Bridge.target = nil
  end
end

CreateThread(function()
  local previous = false
  for _ = 1, 100 do
    detectTarget()
    if Bridge.target and not previous then
      TriggerEvent('yg_properties:client:targetReady', Bridge.target)
      previous = true
      return
    end
    Wait(200)
  end
end)

AddEventHandler('onClientResourceStart', function(res)
  if res == 'ox_target' or res == 'qb-target' then
    local before = Bridge.target
    detectTarget()
    if Bridge.target and Bridge.target ~= before then
      TriggerEvent('yg_properties:client:targetReady', Bridge.target)
    end
  end
end)

local function qbOptions(options)
  local out = {}
  for _, option in ipairs(options or {}) do
    out[#out + 1] = {
      label = option.label,
      icon = option.icon,
      action = function()
        if option.onSelect then option.onSelect() end
      end
    }
  end
  return out
end

function Bridge.AddSphereZone(key, coords, radius, options)
  if Bridge.target == 'ox' then
    return exports.ox_target:addSphereZone({
      coords = vec3(coords.x, coords.y, coords.z),
      radius = radius,
      debug = Config.Debug or false,
      options = options,
    })
  elseif Bridge.target == 'qb' then
    exports['qb-target']:AddCircleZone(key, vector3(coords.x, coords.y, coords.z), radius, {
      name = key,
      useZ = true,
      debugPoly = Config.Debug or false,
    }, {
      options = qbOptions(options),
      distance = radius + 0.6,
    })
    return key
  end
  return nil
end

function Bridge.RemoveZone(handle)
  if not handle then return end
  if Bridge.target == 'ox' then
    exports.ox_target:removeZone(handle)
  elseif Bridge.target == 'qb' then
    exports['qb-target']:RemoveZone(handle)
  end
end

function Bridge.AddDoorTarget(propertyId, coords, options)
  return Bridge.AddSphereZone(('yg_prop_%s'):format(propertyId), coords, 1.6, options)
end

function Bridge.AddAccessTarget(propertyId, accessId, coords, label, onSelect)
  return Bridge.AddSphereZone(('yg_prop_access_%s_%s'):format(propertyId, accessId), coords, 1.2, {
    {
      name = ('yg_prop_access_%s_%s'):format(propertyId, accessId),
      icon = 'fa-solid fa-box-open',
      label = label,
      onSelect = onSelect,
      distance = (Config.AccessPoint and Config.AccessPoint.interactDist or 1.6) + 0.4,
    }
  })
end
