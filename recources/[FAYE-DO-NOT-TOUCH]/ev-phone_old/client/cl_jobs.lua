signedin = false
signedinjob = nil
--jobNotifcationId = 0

-- jobs
local nearFish = false
local nearFishingStand = false
local inDeliveryTruck = false
local inGarbageTruck = false
local inWaterPowerTruck = false
local inPostOpTruck = false
local isNearStore = false
local isNearTruckerForeman = false
local isNearGarbageForeman = false
local isNearPostOpForeman = false
local isNearWaterAndPowerForeman = false

--[[ RegisterNUICallback("setJobNotifcationId", function(data, cb)
    jobNotifcationId = data.id
end) ]]

RegisterNetEvent("signIntoJob")
AddEventHandler("signIntoJob", function(job)
  if signedin then exports['ev-phone']:SendAlert('error', 'You already signed in', 3000) return end
  signedin = true
  signedinjob = job
  local jobname = RPC.execute("GetSignInName", job)
  local string = "Checked in as a " .. jobname
  TriggerEvent("ev-phone:SendNotify", string, "jobcenter", "Job Center")
end)

RegisterNetEvent("getPaycheck")
AddEventHandler("getPaycheck", function(job)
  if not signedin then exports['ev-phone']:SendAlert('error', 'You are not signed in', 3000) return end
  if signedinjob == nil then exports['ev-phone']:SendAlert('error', 'You are not signed in', 3000) return end
  if tostring(signedinjob) ~= tostring(job) then exports['ev-phone']:SendAlert('error', 'You are not signed into this job', 3000) return end
  RPC.execute("collectPaycheck", signedinjob)
end)

RegisterNetEvent("offerJob")
AddEventHandler("offerJob", function(groupId, job, text)
    Wait(math.random(30000, 60000))

    if not signedin then return end
    if signedinjob == nil then return end

    local group, ingroup, src, name = RPC.execute("getGroupingData", signedinjob)

    if not ingroup then return end

    if group.inActivity then return end

    -- add a fucking check if they still got the job
    local result = DoPhoneConfirmation(nil, "Job Offer", text, "people-carry", "#90c9f9")
    if result then
        RPC.execute("startActivity", job, groupId)
    else
    end
end)

RegisterNetEvent('ev-phone:cl:send:fuelreq')
AddEventHandler('ev-phone:cl:send:fuelreq', function(FuelCost)
    local result = DoPhoneConfirmation(nil, "Gas Station", "Refuel for $"..FuelCost, "people-carry", "#90c9f9")
    if result then
        TriggerEvent('ev-fuel:cl:phone:offer:accepted', FuelCost)
    else
    end
end)

RegisterNetEvent("ev-fun:fuel")
AddEventHandler("ev-fun:fuel", function()
    -- Wait(math.random(30000, 60000))


    -- add a fucking check if they still got the job
    local result = DoPhoneConfirmation(nil, "Gas station", text, "people-carry", "#90c9f9")
     if result then
        TriggerEvent('ev-fuel:OfferAccepted')
     else
     end
end)

RegisterNUICallback('gasOfferAccepted', function()
    TriggerEvent('ev-fuel:OfferAccepted')
end)

RegisterNetEvent("showJoinRequest")
AddEventHandler("showJoinRequest", function(requester, job, groupId, name)
    local result = DoPhoneConfirmation(nil, "Request To Join", name, "people-carry", "#90c9f9")
    if result == true then
        RPC.execute("joinGroup", job, groupId, requester)
    else
        RPC.execute("resetCooldown", requester)
    end
end)

RegisterNetEvent("OfferCompleted")
AddEventHandler("OfferCompleted", function(groupId, members)
    local clientId = PlayerId()
    local src = GetPlayerServerId(clientId)
    for k,v in pairs(members) do
        if tonumber(v.src) == tonumber(src) then
            --Wait(400)
            TriggerEvent("ev-phone:SendNotify", "The offer was completed successfully.", "jobcenter", "Job Offer") 
        end
    end
end)

RegisterNetEvent("giveMaterial")
AddEventHandler("giveMaterial", function(groupId, members)
    local clientId = PlayerId()
    local src = GetPlayerServerId(clientId)
    for k,v in pairs(members) do
        if tonumber(v.src) == tonumber(src) then
            TriggerEvent('player:receiveItem', 'recyclablematerial', math.random(75, 150)) -- 75 Mats = $600 | 150 Mats = $1200
        end
    end
end)

RegisterNetEvent("OfferNotCompleted")
AddEventHandler("OfferNotCompleted", function(groupId, members)
    local clientId = PlayerId()
    local src = GetPlayerServerId(clientId)
    for k,v in pairs(members) do
        if tonumber(v.src) == tonumber(src) then
            Wait(400)
            TriggerEvent("ev-phone:SendNotify", "The offer was not completed.", "jobcenter", "Job Offer") 
        end
    end
end)

RegisterNetEvent("ev-phone:JobNotify")
AddEventHandler("ev-phone:JobNotify", function(title, text, bool, groupId)
    local serverid = GetPlayerServerId(PlayerId())
    SendReactMessage('setNotify', {
        app = "phone",
        data = {
            action = "job-notification",
            title = title,
            text = text,
            icon = { name = "people-carry", color = "white" },
            bgColor = "#90c9f9",
            cancelButton = bool,
            jobGroupId = groupId
        },
        serverid = serverid
      })
end)

RegisterNetEvent("ev-phone:ClearJobNotify")
AddEventHandler("ev-phone:ClearJobNotify", function(groupId, members)
    local clientId = PlayerId()
    local src = GetPlayerServerId(clientId)
    for k,v in pairs(members) do
        if tonumber(v.src) == tonumber(src) then
            SendReactMessage('closeNotify', {
                id = groupId, -- or use groupId to identify noti instead? 5head
            })
        end
    end
end)

RegisterNetEvent("updateJobActivity")
AddEventHandler("updateJobActivity", function(groupId, members, tasks)
    local clientId = PlayerId()
    local src = GetPlayerServerId(clientId)
    for k,v in pairs(members) do
        if tonumber(v.src) == tonumber(src) then
            SendReactMessage('updateNotify', {
                id = groupId, -- just use the groupId to update instead fuck face KEKW
                title = tasks.header,
                body = tasks.task
            })
        end
    end
end)

RegisterNetEvent("talkToTruckerForeMan")
AddEventHandler("talkToTruckerForeMan", function(groupId, groupData, members, task)
    local clientId = PlayerId()
    local src = GetPlayerServerId(clientId)
    for k,v in pairs(members) do
        if tonumber(v.src) == tonumber(src) then
            if tonumber(v.src) ~= tonumber(groupData.leader) then
                TriggerEvent("ev-phone:JobNotify", task.header, task.task, false, groupId)
            else
                TriggerEvent("ev-phone:JobNotify", task.header, task.task, true, groupId)
            end
        end
    end
end)

RegisterNetEvent("talkToWaterAndPowerForeMan")
AddEventHandler("talkToWaterAndPowerForeMan", function(groupId, groupData, members, task)
    local clientId = PlayerId()
    local src = GetPlayerServerId(clientId)
    for k,v in pairs(members) do
        if tonumber(v.src) == tonumber(src) then
            if tonumber(v.src) ~= tonumber(groupData.leader) then
                TriggerEvent("ev-phone:JobNotify", task.header, task.task, false, groupId)
            else
                TriggerEvent("ev-phone:JobNotify", task.header, task.task, true, groupId)
            end
        end
    end
end)

RegisterNetEvent("talkToPostOpForeMan")
AddEventHandler("talkToPostOpForeMan", function(groupId, groupData, members, task)
    local clientId = PlayerId()
    local src = GetPlayerServerId(clientId)
    for k,v in pairs(members) do
        if tonumber(v.src) == tonumber(src) then
            if tonumber(v.src) ~= tonumber(groupData.leader) then
                TriggerEvent("ev-phone:JobNotify", task.header, task.task, false, groupId)
            else
                TriggerEvent("ev-phone:JobNotify", task.header, task.task, true, groupId)
            end
        end
    end
end)

RegisterNetEvent("truckerIsInCar")
AddEventHandler("truckerIsInCar", function(groupId, members)
    local clientId = PlayerId()
    local src = GetPlayerServerId(clientId)
    for k,v in pairs(members) do
        if tonumber(v.src) == tonumber(src) then
            inDeliveryTruck = true
            isInDeliveryTruck()
        end
    end
end)

RegisterNetEvent("waterAndPowerIsInCar")
AddEventHandler("waterAndPowerIsInCar", function(groupId, members)
    local clientId = PlayerId()
    local src = GetPlayerServerId(clientId)
    for k,v in pairs(members) do
        if tonumber(v.src) == tonumber(src) then
            inWaterPowerTruck = true
            isInWaterPowerTruck()
        end
    end
end)

RegisterNetEvent("postOpIsInCar")
AddEventHandler("postOpIsInCar", function(groupId, members)
    local clientId = PlayerId()
    local src = GetPlayerServerId(clientId)
    for k,v in pairs(members) do
        if tonumber(v.src) == tonumber(src) then
            inPostOpTruck = true
            isInPostOpTruck()
        end
    end
end)

RegisterNetEvent("postOpIsInCar")
AddEventHandler("postOpIsInCar", function(groupId, members)
    local clientId = PlayerId()
    local src = GetPlayerServerId(clientId)
    for k,v in pairs(members) do
        if tonumber(v.src) == tonumber(src) then
            inPostOpTruck = true
            isInPostOpTruck()
        end
    end
end)

RegisterNetEvent("postOpAddGPS")
AddEventHandler("postOpAddGPS", function(groupId, members, x, y, z)
    local clientId = PlayerId()
    local src = GetPlayerServerId(clientId)
    for k,v in pairs(members) do
        if tonumber(v.src) == tonumber(src) then
            TriggerEvent('postOpIsAtLocation')
        end
    end
end)

RegisterNetEvent("truckerAddGPS")
AddEventHandler("truckerAddGPS", function(groupId, members, x, y, z)
    local clientId = PlayerId()
    local src = GetPlayerServerId(clientId)
    for k,v in pairs(members) do
        if tonumber(v.src) == tonumber(src) then
            StartGpsMultiRoute(9, true, false)
            AddPointToGpsMultiRoute(x, y, z)
            SetGpsMultiRouteRender(true)
        end
    end
end)

RegisterNetEvent("truckerClearGPS")
AddEventHandler("truckerClearGPS", function(groupId, members)
    local clientId = PlayerId()
    local src = GetPlayerServerId(clientId)
    for k,v in pairs(members) do
        if tonumber(v.src) == tonumber(src) then
            SetWaypointOff()
            ClearGpsMultiRoute()
        end
    end
end)

RegisterNetEvent("truckerIsAtStore")
AddEventHandler("truckerIsAtStore", function(groupId, members, x, y, z)
    local clientId = PlayerId()
    local src = GetPlayerServerId(clientId)
    for k,v in pairs(members) do
        if tonumber(v.src) == tonumber(src) then
            isNearStore = true
            nearStore(x, y, z)
        end
    end
end)

RegisterNetEvent("truckerIsAtForeman")
AddEventHandler("truckerIsAtForeman", function(groupId, members, x, y, z)
    local clientId = PlayerId()
    local src = GetPlayerServerId(clientId)
    for k,v in pairs(members) do
        if tonumber(v.src) == tonumber(src) then
            isNearTruckerForeman = true
            nearTruckerForeman(x, y, z)
        end
    end
end)

RegisterNetEvent("truckerDelCar")
AddEventHandler("truckerDelCar", function(groupId, members)
    local clientId = PlayerId()
    local src = GetPlayerServerId(clientId)
    for k,v in pairs(members) do
        if tonumber(v.src) == tonumber(src) then
            local playerPed = PlayerPedId()
            local veh = GetVehiclePedIsIn(playerPed)
            DeleteEntity(veh)
        end
    end
end)

RegisterNetEvent("findFishingSpot")
AddEventHandler("findFishingSpot", function(groupId, groupData, members, task)
    local clientId = PlayerId()
    local src = GetPlayerServerId(clientId)
    for k,v in pairs(members) do
        if tonumber(v.src) == tonumber(src) then
            TriggerEvent("ev-fishing:jobEvent", true)
            nearFish = true
            nearFishing()
            if tonumber(v.src) ~= tonumber(groupData.leader) then
                TriggerEvent("ev-phone:JobNotify", task.header, task.task, false, groupId)
            else
                TriggerEvent("ev-phone:JobNotify", task.header, task.task, true, groupId)
            end
        end
    end
end)

RegisterNetEvent("letThemKnowSpotIsGood")
AddEventHandler("letThemKnowSpotIsGood", function(groupId, members)
    local clientId = PlayerId()
    local src = GetPlayerServerId(clientId)
    for k,v in pairs(members) do
        if tonumber(v.src) == tonumber(src) then
            TriggerEvent("ev-fishing:jobEvent", nil)
            nearFishingStand = true
            nearFishStand()
        end
    end
end)

RegisterNetEvent("talkToGarbageForeMan")
AddEventHandler("talkToGarbageForeMan", function(groupId, groupData, members, task)
    local clientId = PlayerId()
    local src = GetPlayerServerId(clientId)
    for k,v in pairs(members) do
        if tonumber(v.src) == tonumber(src) then
            if tonumber(v.src) ~= tonumber(groupData.leader) then
                TriggerEvent("ev-phone:JobNotify", task.header, task.task, false, groupId)
            else
                TriggerEvent("ev-phone:JobNotify", task.header, task.task, true, groupId)
            end
        end
    end
end)

RegisterNetEvent("garbageIsInCar")
AddEventHandler("garbageIsInCar", function(groupId, members)
    local clientId = PlayerId()
    local src = GetPlayerServerId(clientId)
    for k,v in pairs(members) do
        if tonumber(v.src) == tonumber(src) then
            inGarbageTruck = true
            isInGarbageTruck()
        end
    end
end)

RegisterNetEvent("garbageDelCar")
AddEventHandler("garbageDelCar", function(groupId, members)
    local clientId = PlayerId()
    local src = GetPlayerServerId(clientId)
    for k,v in pairs(members) do
        if tonumber(v.src) == tonumber(src) then
            local playerPed = PlayerPedId()
            local veh = GetVehiclePedIsIn(playerPed, false)
            DeleteEntity(veh)
        end
    end
end)

RegisterNetEvent("garbageIsAtForeman") -- add post op and water & power
AddEventHandler("garbageIsAtForeman", function(groupId, members, x, y, z)
    local clientId = PlayerId()
    local src = GetPlayerServerId(clientId)
    for k,v in pairs(members) do
        if tonumber(v.src) == tonumber(src) then
            isNearGarbageForeman = true
            nearGarbageForeman(x, y, z)
        end
    end
end)

RegisterNetEvent("postOpIsAtForeman") -- add post op and water & power
AddEventHandler("postOpIsAtForeman", function(groupId, members, x, y, z)
    local clientId = PlayerId()
    local src = GetPlayerServerId(clientId)
    for k,v in pairs(members) do
        if tonumber(v.src) == tonumber(src) then
            isNearPostOpForeman = true
            nearPostOpForeman(x, y, z)
        end
    end
end)

RegisterNetEvent("waterAndPowerIsAtForeman") -- add post op and water & power
AddEventHandler("waterAndPowerIsAtForeman", function(groupId, members, x, y, z)
    local clientId = PlayerId()
    local src = GetPlayerServerId(clientId)
    for k,v in pairs(members) do
        if tonumber(v.src) == tonumber(src) then
            isNearWaterAndPowerForeman = true
            nearWaterAndPowerForeman(x, y, z)
        end
    end
end)

AddEventHandler("ev-jobs:247delivery:dropGoods", function()
    RPC.execute("completeTask", "trucker", 4)
end)

RegisterNUICallback("setJobsGps", function(data, cb)
    local x, y = RPC.execute("getJobCoords", data.id)
    local x = tonumber(x)
    local y = tonumber(y)
    SetNewWaypoint(x, y)
    exports['ev-phone']:SendAlert('inform', 'Updated GPS', 3000)
end)
  
RegisterNUICallback("getJobsData", function(_, cb)
    if not signedin then
    local data = RPC.execute("getJobsData")
    cb({jobs = data, signedin = false})
    else
      local idle, busy, ingroup, groupdata, src, jobname = RPC.execute("getGroupData", signedinjob)
      cb({jobs = {}, groups = {idle = idle, busy = busy}, signedin = true, ingroup = ingroup, groupdata = groupdata, src = src, jobname = jobname})
    end
end)

RegisterNUICallback("checkOut", function(data, cb)
    signedin = false
    signedinjob = nil
    cooldown = false
    TriggerEvent("updateGroups")
end)

RegisterNUICallback("createGroup", function(data, cb)
    if signedin == nil then return end
    RPC.execute("createGroup", signedinjob)
end)

local cooldown = false

RegisterNUICallback("joinGroup", function(data, cb)
    if not cooldown then
        cooldown = true
        RPC.execute("requestJoinGroup", signedinjob, data.id)
    else
        TriggerEvent("ev-phone:SendNotify", "You already have an active request.", "jobcenter", "Job Center")
    end
end)

RegisterNetEvent("resetCooldown")
AddEventHandler("resetCooldown", function()
    cooldown = false
end)

RegisterNUICallback("leaveGroup", function(data, cb)
    RPC.execute("leaveGroup", signedinjob, data.id)
end)

RegisterNUICallback("disbandGroup", function(data, cb)
    local id = data.id
    -- should upd
    RPC.execute("disbandGroup", signedinjob, id)
end)

RegisterNUICallback("readyGroup", function(data, cb)
    local id = data.id
    -- should upd, send back isReady state
    RPC.execute("readyGroup", signedinjob, id)
end)

RegisterNUICallback("kickGroup", function(data, cb)
    local id = data.id
    local src = data.src
    RPC.execute("kickGroup", signedinjob, id, src)
end)

RegisterNUICallback("cancelActivity", function(data, cb)
    local id = data.id
    RPC.execute("cancelActivity", signedinjob, id)
end)

RegisterNetEvent('updateGroups')
AddEventHandler('updateGroups', function()
    SendReactMessage('updateGroups', {})
end)

-- make this poly bigger
Citizen.CreateThread(function()
    exports["ev-polyzone"]:AddBoxZone("trucker_foreman", vector3(919.9, -1256.54, 25.53), 1.0, 1.8, {
        heading=30,
        minZ=22.13,
        maxZ=26.73
    })
    exports["ev-polyzone"]:AddBoxZone("garbage_foreman", vector3(-353.94, -1545.68, 27.72), 3.0, 2.0, {
        heading=0,
        minZ=24.92,
        maxZ=28.92
    })
    exports["ev-polyzone"]:AddBoxZone("waterandpower_foreman", vector3(442.99, -1969.18, 24.4), 1.4, 2.0, {
        heading=315,
        minZ=22.0,
        maxZ=26.0
    })
    exports["ev-polyzone"]:AddBoxZone("postop_foreman", vector3(-417.43, -2792.96, 6.0), 3.2, 1.4, {
        heading=320,
        minZ=3.2,
        maxZ=7.2
      })
end)

local listening = false
local function listenForKeypress(type, data, job)
  listening = true
  Citizen.CreateThread(function()
      while listening do
          if IsControlJustReleased(0, 38) then
              listening = false
              exports["ev-interface"]:hideInteraction()
              if job == "trucker" then
              -- spawn car 
              local plate = "247" .. tostring(math.random(1,9)) .. tostring(math.random(1,9)) .. tostring(math.random(1,9)) .. tostring(math.random(1,9)) .. tostring(math.random(1,9))
              local vehicle = RPC.execute("fayzie:garage:vehicleSpawn", 2053223216, { x = 912.4641723632813, y = -1258.9508056640626, z = 25.57445907592773, h = 43.63048553466797 }, plate)
              
              -- set talk to foreman task to completed
              RPC.execute("completeTask", "trucker", 1)

              TriggerEvent("vehicle:keys:addNew", plate)
              print("Give keys DONE")
              elseif job == "recycle" then
              -- spawn car
              local plate = "GRB" .. tostring(math.random(1,9)) .. tostring(math.random(1,9)) .. tostring(math.random(1,9)) .. tostring(math.random(1,9)) .. tostring(math.random(1,9))
              local vehicle = RPC.execute("fayzie:garage:vehicleSpawn", -1255698084, { x = -332.53625488281, y = -1565.9274902344, z = 25.231986999512, h = 235.33598327637 }, plate)
              
              -- set talk to foreman task to completed
              RPC.execute("completeTask", "recycle", 1)

              TriggerEvent("vehicle:keys:addNew", plate)

              elseif job == "waterandpower" then
                local hash = GetHashKey("BOXVILLE")
                local plate = "PWR" .. tostring(math.random(1,9)) .. tostring(math.random(1,9)) .. tostring(math.random(1,9)) .. tostring(math.random(1,9)) .. tostring(math.random(1,9))
                local vehicle = RPC.execute("fayzie:garage:vehicleSpawn", hash, { x = 446.18966, y = -1963.951, z = 22.943767, h = 219.07287 }, plate)
                
                -- set talk to foreman task to completed
                RPC.execute("completeTask", "waterandpower", 1)
  
                TriggerEvent("vehicle:keys:addNew", plate)
            elseif job == "postop" then
                local hash = GetHashKey("BOXVILLE4")
                local plate = "PST" .. tostring(math.random(1,9)) .. tostring(math.random(1,9)) .. tostring(math.random(1,9)) .. tostring(math.random(1,9)) .. tostring(math.random(1,9))
                local vehicle = RPC.execute("fayzie:garage:vehicleSpawn", hash, { x = -403.8789, y = -2787.399, z = 5.902821, h = 316.56219 }, plate)
                
                -- set talk to foreman task to completed
                RPC.execute("completeTask", "postop", 1)
  
                TriggerEvent("vehicle:keys:addNew", plate)
              end
          end
          Wait(0)
      end
  end)
end

function enterPoly(name, data, job)
    listenForKeypress(name, data, job)
    exports["ev-interface"]:showInteraction("[E] Ask the foreman for a vehicle")
end

function leavePoly(name, data, job)
    listening = false
    exports["ev-interface"]:hideInteraction()
end

AddEventHandler("ev-polyzone:enter", function(zone, data)
    if zone == "trucker_foreman" then
        --local signedinjob = "trucker"
        if signedinjob == "trucker" then
        local group, ingroup, src, name = RPC.execute("getGroupingData", signedinjob)
        if ingroup then
            if group.ready then
                if group.inActivity then
                    if not group["tasks"][1]["completed"] then
                        enterPoly(zone, data, "trucker")
                    end
                end
            end
        end
        end
    elseif zone == "garbage_foreman" then
        --local signedinjob = "recycle"
        if signedinjob == "recycle" then
        local group, ingroup, src, name = RPC.execute("getGroupingData", signedinjob)
        if ingroup then
            if group.ready then
                if group.inActivity then
                    if not group["tasks"][1]["completed"] then
                        enterPoly(zone, data, "recycle")
                    end
                end
            end
        end
        end
    elseif zone == "waterandpower_foreman" then
        --local signedinjob = "waterandpower"
        if signedinjob == "waterandpower" then
        local group, ingroup, src, name = RPC.execute("getGroupingData", signedinjob)
        if ingroup then
            if group.ready then
                if group.inActivity then
                    if not group["tasks"][1]["completed"] then
                        enterPoly(zone, data, "waterandpower")
                    end
                end
            end
        end
        end
    elseif zone == "postop_foreman" then
        --local signedinjob = "postop"
        if signedinjob == "postop" then
        local group, ingroup, src, name = RPC.execute("getGroupingData", signedinjob)
        if ingroup then
            if group.ready then
                if group.inActivity then
                    if not group["tasks"][1]["completed"] then
                        enterPoly(zone, data, "postop")
                    end
                end
            end
        end
        end
    end
end)

AddEventHandler("ev-polyzone:exit", function(zone)
    leavePoly()
end)

-- functions
function isInDeliveryTruck()
    local playerPed = PlayerPedId()
    Citizen.CreateThread(function()
        while inDeliveryTruck do
            Citizen.Wait(1000)
            if IsPedInAnyVehicle(playerPed, false) then
                RPC.execute("completeTask", signedinjob, 2)
                inDeliveryTruck = false
            end
        end
    end)
end

function isInWaterPowerTruck()
    local playerPed = PlayerPedId()
    Citizen.CreateThread(function()
        while inWaterPowerTruck do
            Citizen.Wait(1000)
            if IsPedInAnyVehicle(playerPed, false) then
                RPC.execute("completeTask", signedinjob, 2)
                inWaterPowerTruck = false
            end
        end
    end)
end

function isInPostOpTruck()
    local playerPed = PlayerPedId()
    Citizen.CreateThread(function()
        while inPostOpTruck do
            Citizen.Wait(1000)
            if IsPedInAnyVehicle(playerPed, false) then
                RPC.execute("completeTask", signedinjob, 2)
                inPostOpTruck = false
            end
        end
    end)
end

function nearStore(x, y, z)
    local playerPed = PlayerPedId()
    Citizen.CreateThread(function()
        while isNearStore do
            Citizen.Wait(1000)
            local playerCoords = GetEntityCoords(playerPed)
            local location = vector3(x, y, z)
            local dist = #(playerCoords - location)
            if dist <= 10.0 then
                RPC.execute("completeTask", signedinjob, 3)
                isNearStore = false
            end
        end
    end)
end

function nearTruckerForeman(x, y, z)
    local playerPed = PlayerPedId()
    Citizen.CreateThread(function()
        while isNearTruckerForeman do
            Citizen.Wait(1000)
            local playerCoords = GetEntityCoords(playerPed)
            local location = vector3(x, y, z)
            local dist = #(playerCoords - location)
            if dist <= 10.0 then
                RPC.execute("completeTask", signedinjob, 5)
                isNearTruckerForeman = false
            end
        end
    end)
end

function nearFishing()
    local playerPed = PlayerPedId()
    Citizen.CreateThread(function()
        while nearFish do
            Citizen.Wait(1000)
            local x, y, z = RPC.execute("fishing:jobs:getActiveLocation")
            local playerCoords = GetEntityCoords(playerPed)
            local location = vector3(x, y, z)
            local dist = #(playerCoords - location)
            if dist <= 50.0 then
                RPC.execute("completeTask", signedinjob, 1)
                nearFish = false
            end
        end
    end)
end

function nearFishStand()
    local playerPed = PlayerPedId()
    Citizen.CreateThread(function()
        while nearFishingStand do
            Citizen.Wait(1000)
            local playerCoords = GetEntityCoords(playerPed)
            local location = vector3(-335.83563232422, 6106.2534179688, 31.449844360352)
            local dist = #(playerCoords - location)
            if dist <= 10.0 then
                RPC.execute("completeTask", signedinjob, 3)
                nearFishingStand = false
            end
        end
    end)
end

-- this check is buggin bro (fix it)
function isInGarbageTruck()
    local playerPed = PlayerPedId()
    Citizen.CreateThread(function()
        while inGarbageTruck do
            Citizen.Wait(1000)
            if IsPedInAnyVehicle(playerPed, false) then
                RPC.execute("completeTask", signedinjob, 2)
                inGarbageTruck = false
            end
        end
    end)
end

-- garbage
local pickedUpTrash = {}
local dumpsters = {
218085040,
666561306,
-58485588,
-206690185,
1511880420,
682791951,
998415499,
1748268526,
}

local hasTrash = false
local trashObject = nil
local garbagebag = nil

RegisterNetEvent('ev-jobs:sanitationWorker:pickupTrash')
AddEventHandler('ev-jobs:sanitationWorker:pickupTrash', function(pArgs, pEntity, pContext)
    if signedinjob ~= "recycle" then return end
    local found = false
    for k,v in pairs(dumpsters) do
        if(tonumber(v) == tonumber(pContext.model)) then
            found = true
        end
    end

    if not found then
        if pickedUpTrash[pEntity] then exports['ev-phone']:SendAlert('error', 'Empty...', 3000) return end
        pickedUpTrash[pEntity] = true
        hasTrash = true
        trashObject = pEntity

        if not HasAnimDictLoaded("anim@heists@narcotics@trash") then
            RequestAnimDict("anim@heists@narcotics@trash")
            while not HasAnimDictLoaded do
                Wait(0)
            end
        end

        ClearPedTasks(PlayerPedId())
        garbagebag = CreateObject(GetHashKey("hei_prop_heist_binbag"), 0, 0, 0, true, true, true)
        AttachEntityToEntity(garbagebag, GetPlayerPed(-1), GetPedBoneIndex(GetPlayerPed(-1), 57005), 0.12, 0.0, 0.00, 25.0, 270.0, 180.0, true, true, false, true, 1, true)
        TaskPlayAnim(PlayerPedId(), 'anim@heists@narcotics@trash', 'walk', 1.0, -1.0, -1, 49, 0, false, false, false)
    else
        if pickedUpTrash[pEntity] and tonumber(pickedUpTrash[pEntity]) > 2 then exports['ev-phone']:SendAlert('error', 'Empty...', 3000) return end
        if pickedUpTrash[pEntity] == nil then pickedUpTrash[pEntity] = 0 end
        pickedUpTrash[pEntity] = pickedUpTrash[pEntity] + 1
        hasTrash = true
        trashObject = pEntity

        if not HasAnimDictLoaded("anim@heists@narcotics@trash") then
            RequestAnimDict("anim@heists@narcotics@trash")
            while not HasAnimDictLoaded do
                Wait(0)
            end
        end

        ClearPedTasks(PlayerPedId())
        garbagebag = CreateObject(GetHashKey("hei_prop_heist_binbag"), 0, 0, 0, true, true, true)
        AttachEntityToEntity(garbagebag, GetPlayerPed(-1), GetPedBoneIndex(GetPlayerPed(-1), 57005), 0.12, 0.0, 0.00, 25.0, 270.0, 180.0, true, true, false, true, 1, true)
        TaskPlayAnim(PlayerPedId(), 'anim@heists@narcotics@trash', 'walk', 1.0, -1.0, -1, 49, 0, false, false, false)
    end
end)

RegisterNetEvent('ev-jobs:sanitationWorker:vehicleTrash')
AddEventHandler('ev-jobs:sanitationWorker:vehicleTrash', function(pArgs, pEntity, pContext)
    if signedinjob ~= "recycle" then return end
    if not hasTrash then return end
    if trashObject == nil then return end
    if garbagebag == nil then return end
    
    if not HasAnimDictLoaded("anim@heists@narcotics@trash") then
        RequestAnimDict("anim@heists@narcotics@trash")
        while not HasAnimDictLoaded do
            Wait(0)
        end
    end

    ClearPedTasksImmediately(GetPlayerPed(-1))
    TaskPlayAnim(PlayerPedId(), 'anim@heists@narcotics@trash', 'throw_b', 1.0, -1.0, -1, 2, 0, false, false, false)
    Wait(800)
    local garbagebagdelete = DeleteEntity(garbagebag)
    Wait(100)
    ClearPedTasksImmediately(GetPlayerPed(-1))

    local jobCount = RPC.execute("getCurrentObjectCount", signedinjob)
    local count = jobCount
    local playerCoords = GetEntityCoords(trashObject, false)
    local zone = GetLabelText(GetNameOfZone(playerCoords.x, playerCoords.y, playerCoords.z))
    print('zone')
    print(zone)
    count = count + 1
    RPC.execute("updateObjectiveData", signedinjob, 0, count, zone)
    hasTrash = false
    trashObject = nil
    garbagebag = nil
end)

function nearGarbageForeman(x, y, z)
    local playerPed = PlayerPedId()
    Citizen.CreateThread(function()
        while isNearGarbageForeman do
            Citizen.Wait(1000)
            local playerCoords = GetEntityCoords(playerPed)
            local location = vector3(x, y, z)
            local dist = #(playerCoords - location)
            if dist <= 10.0 then
                RPC.execute("completeTask", signedinjob, 5)
                isNearGarbageForeman = false
            end
        end
    end)
end

function nearPostOpForeman(x, y, z)
    local playerPed = PlayerPedId()
    Citizen.CreateThread(function()
        while isNearPostOpForeman do
            Citizen.Wait(1000)
            local playerCoords = GetEntityCoords(playerPed)
            local location = vector3(x, y, z)
            local dist = #(playerCoords - location)
            if dist <= 10.0 then
                RPC.execute("completeTask", signedinjob, 5)
                isNearPostOpForeman = false
            end
        end
    end)
end

function nearWaterAndPowerForeman(x, y, z)
    local playerPed = PlayerPedId()
    Citizen.CreateThread(function()
        while isNearWaterAndPowerForeman do
            Citizen.Wait(1000)
            local playerCoords = GetEntityCoords(playerPed)
            local location = vector3(x, y, z)
            local dist = #(playerCoords - location)
            if dist <= 10.0 then
                RPC.execute("completeTask", signedinjob, 5)
                isNearWaterAndPowerForeman = false
            end
        end
    end)
end