RegisterNUICallback("ev-ui:getDOJData", function(data, cb)
    local list, status = RPC.execute("ev-gov:getDOJData")
    local job = exports["isPed"]:isPed("myjob")
    local granted = false
    if tostring(job) == "judge" then
        granted = true
    elseif tostring(job) == "public_defender" then
        granted = true
    end
    cb({ data = {list = list, granted = granted, status = status}, meta = { ok = true, message = "done" } })
end)
  
RegisterNUICallback("ev-ui:setDOJStatus", function (data, cb)
    RPC.execute("ev-gov:dojApp:setStatus", exports["isPed"]:isPed("myjob"), data.status)
    local list, status = RPC.execute("ev-gov:getDOJData")
    local job = exports["isPed"]:isPed("myjob")
    local granted = false
    if tostring(job) == "judge" then
        granted = true
    elseif tostring(job) == "public_defender" then
        granted = true
    end
    cb({ data = {list = list, granted = granted, status = status}, meta = { ok = true, message = "done" } })
end)