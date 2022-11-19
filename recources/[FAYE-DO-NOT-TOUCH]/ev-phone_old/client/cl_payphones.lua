local payphoneModels = {
    `p_phonebox_02_s`,
    `prop_phonebox_03`,
    `prop_phonebox_02`,
    `prop_phonebox_04`,
    `prop_phonebox_01c`,
    `prop_phonebox_01a`,
    `prop_phonebox_01b`,
    `p_phonebox_01b_s`,
  }
  
  Citizen.CreateThread(function()
    exports["ev-interact"]:AddPeekEntryByModel(payphoneModels, {{
      event = "ev-phone:startPayPhoneCall",
      id = "uniqueIdLMAO",
      icon = "phone-volume",
      label = "Make Call",
      parameters = {},
    }}, { 
      distance = { radius = 1.5 },
      isEnabled = function()
        return true
      end
     })
  end)
  
  local entityPayPhoneCoords = nil
  AddEventHandler("ev-phone:startPayPhoneCall", function(pArgs, pEntity)
    entityPayPhoneCoords = GetEntityCoords(pEntity)
    exports['ev-interface']:openApplication('textbox', {
      callbackUrl = 'ev-phone:payphone',
      key = 1,
      items = {
        {
          icon = "phone",
          label = "Phone Number",
          name = "NumberPayphone",
        },
      },
      show = true,
    })
  end)

  RegisterInterfaceCallback('ev-phone:payphone', function(data, cb)
    cb({ data = {}, meta = { ok = true, message = '' } })
    local PhoneNumber = data.values.NumberPayphone
    if PhoneNumber ~= nil then
        RPC.execute("phone:callStart", PhoneNumber, true)
        Citizen.CreateThread(function()
          while entityPayPhoneCoords do
            if #(GetEntityCoords(PlayerPedId()) - entityPayPhoneCoords) > 2.0 then
              entityPayPhoneCoords = nil
              endPhoneCall()
            end
            Citizen.Wait(500)
          end
        end)
      end
  end)