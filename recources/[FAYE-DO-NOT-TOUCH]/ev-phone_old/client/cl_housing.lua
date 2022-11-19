local editMode = false

RegisterNUICallback('getHousingData', function(_, cb)
  local characterId = exports["isPed"]:isPed("cid")
  local roomNumber, roomType, available, owned, access = RPC.execute("getHousingData", characterId)
  cb({
    roomNumber = roomNumber,
    roomType = roomType,
    available = available,
    owned = owned,
    access = access
  })
end)

RegisterNUICallback('checkLocation', function(data, cb)
  local success, data = exports["ev-housing"]:currentLocation()
  if not success then 
    cb({foundHouse = false})
    return
  end
  cb({foundHouse = true, foundHouseName = data.housingName, foundHousePrice = data.housingPrice, foundHouseCategory = data.housingCat, foundHouseIsOwned = data.isOwned})
end)

RegisterNUICallback('purchaseHousing', function(data, cb)
  local complete, info = exports["ev-housing"]:buyProperty()
  if not complete then 
    cb({success = false, owned = info})
    return
  end
  cb({success = true, owned = info})
end)

RegisterNUICallback('manageHousingLocks', function(data, cb)
  local characterId = exports["isPed"]:isPed("cid")
  if data.action == "lock" then
    local result, message = exports["ev-housing"]:lock(tonumber(data.id))
    if not result then
      TriggerEvent("DoLongHudText", message, 2)
    end
    local roomNumber, roomType, available, owned, access = RPC.execute("getHousingData", characterId)
    if result then
      cb({
        owned = owned,
        access = access
      })
    end
  else
    local result, message = exports["ev-housing"]:unlock(tonumber(data.id))
    if not result then
      TriggerEvent("DoLongHudText", message, 2)
    end
    local roomNumber, roomType, available, owned, access = RPC.execute("getHousingData", characterId)
    if result then
      cb({
        owned = owned,
        access = access
      })
    end
  end
end)

RegisterNUICallback('setHousingGps', function(data, cb)
  local result, message = exports["ev-housing"]:setGps(data.id)
end)

RegisterNUICallback('enterEditMode', function(data, cb)
    local success, message = exports["ev-housing"]:enterEdit(data.id)
    cb({ data = message,  meta = { ok = success, message = (not success and message or 'done') } })
end)

RegisterNUICallback("ev-ui:housingEditPropertyConfig", function(data, cb)
  if data.type == "backdoor" then
      exports["ev-housing"]:setBackdoor()
  elseif data.type == "inventory" then
    exports["ev-housing"]:setInventory()
  elseif data.type == "garage" then
    exports["ev-housing"]:setGarage()
  elseif data.type == "char-changer" then
    exports["ev-housing"]:setCharChanger()
  elseif data.type == "crafting" then
    exports["ev-housing"]:placeBench()
  elseif data.type == "furniture" then
    exports["ev-housing"]:openFurniture()
    TriggerEvent("ev-ui:restartUI")
  end
  cb({ data = {},  meta = { ok = true, message = "done" } })
end)

RegisterNUICallback('exitEditMode', function(data, cb)
  local success, message = exports["ev-housing"]:exitEdit(true)
  cb({ data = "Success",  meta = { ok = true, message = 'done' } })
end)