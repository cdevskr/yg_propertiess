local knockPropertyId = nil

RegisterNetEvent('yg_properties:client:knockReceived', function(propertyId)
  knockPropertyId = tonumber(propertyId)
  SetTimeout(8000, function()
    if knockPropertyId == propertyId then
      knockPropertyId = nil
    end
  end)
end)

CreateThread(function()
  while true do
    local sleep = 500
    if Config.Keys and Config.Keys.doorbell and not LocalPlayer.state.ygPropertyId then
      local props = GetProperties and GetProperties() or {}
      local pc = GetEntityCoords(PlayerPedId())
      for _, prop in ipairs(props) do
        if prop.door_coords and Utils.bool(prop.locked) then
          local door = Shared.DecodeVec4(prop.door_coords)
          local dist = #(pc - vec3(door.x, door.y, door.z))
          if dist < 1.6 then
            sleep = 0
            BeginTextCommandDisplayHelp('STRING')
            AddTextComponentSubstringPlayerName('Kapıyı çal ~INPUT_CONTEXT~')
            EndTextCommandDisplayHelp(0, false, true, -1)
            if IsControlJustReleased(0, (Config.Keys and Config.Keys.knockKey) or 38) then
              TriggerServerEvent('yg_properties:server:knock', prop.id)
              Wait(800)
            end
          end
        end
      end
    end
    Wait(sleep)
  end
end)

CreateThread(function()
  while true do
    if knockPropertyId then
      local props = GetProperties and GetProperties() or {}
      for _, prop in ipairs(props) do
        if prop.id == knockPropertyId and prop.door_coords and prop.door_coords ~= '' then
          local door = Shared.DecodeVec4(prop.door_coords)
          DrawMarker(2, door.x, door.y, door.z + 1.2, 0.0, 0.0, 0.0, 180.0, 0.0, 0.0, 0.4, 0.4, 0.4, 255, 210, 90, 180, true, false, 2, false, nil, nil, false)
          break
        end
      end
      Wait(0)
    else
      Wait(400)
    end
  end
end)
