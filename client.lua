--[[
TO DO:
    CORE:
        - inventory organizacji 🟢 
        - konto bankowe 🟢
        - sejf organizacji 🟢
        - szafka z ubraniami 🟡
        - strefa wokol twojej dzielnicy/siedziby gdzie dowiadujesz sie ze ktos handluje/przebywa 🔴
        - menu szefa 
            a) dodawanie/wyrzucanie 🟢
            b) awansowanie/degradowanie 🟢
            c) zarzadzanie garazem 🟡
        - garaz ekipowy, dodawanie aut dla ekipy, zeby kazdy mogl z niej skorzystac 🟡
        - mlo gangi, organizacje ten sam interior z blipem 🟡
    SKRYPTY:
        - malowanie tablic/odrywanie ich
        - zlecenia na kradziez samochodow
        - zlecenia na zabojstwo npc
        - wlamania do domow
    STREFY:
        - przejmowanie
        - przychody ze strefy
        - przedmioty ze strefy    

 
]]--
ESX = exports['es_extended']:getSharedObject()

organisations = {}
local display = false
gui = false

AddEventHandler('onClientResourceStart', function(resourceName)    
    --print(json.encode(Config.organisations))
    if resourceName == 'ox_inventory' or resourceName == GetCurrentResourceName() then
        for _,v in pairs(Config.organisations) do
            organisations[v.id] = {
                id = v.id,
                name = v.name,
                boss = v.boss,
                stash = v.stash,
                entrance = v.entrance,
                exit = v.exit,
                blip = v.blip,
                clothes = v.clothes
            }

            Citizen.CreateThread(function()
                exports['xrp_markers']:RegisterMarker(6, organisations[v.id].stash.coords, 10, 1.5, true, 'Szafka organizacji | ~INPUT_CONTEXT~', function()
                    if IsControlJustPressed(0, 38) then
                        ESX.TriggerServerCallback('xrp_organisations:checkSquad', function(org)
                            id = org                            
                            if id ~= nil then
                                exports.ox_inventory:openInventory('stash', "org"..id)
                            else 
                                return
                            end                            
                        end)
                    end
                end)
                exports['xrp_markers']:RegisterMarker(6, organisations[v.id].clothes, 10, 1.5, true, 'Ubrania organizacji | ~INPUT_CONTEXT~', function()
                    if IsControlJustPressed(0, 38) then
                        ESX.TriggerServerCallback('xrp_organisations:checkSquad', function(org)
                            id = org                               
                        end)                            
                        if id ~= nil then
                            TriggerEvent('esx_clotheshop:getClothes')
                        else 
                            return
                        end
                    end
                end)
                exports['xrp_markers']:RegisterMarker(6, organisations[v.id].boss, 10, 1.5, true, 'Komputer prezesa | ~INPUT_CONTEXT~', function()
                    if IsControlJustPressed(0, 38) then
                        ESX.TriggerServerCallback('xrp_organisations:checkSquad', function(org)
                            id = org                               
                        end)
                        ESX.TriggerServerCallback('xrp_organisations:checkBoss', function(grade)
                            ranga = grade                                 
                        end)
                        if id ~= nil and ranga == 4  then
                            org = organisations[v.id].id                    
                            TriggerEvent('xrp_organisations:openBossMenu', org)
                        else 
                            return false
                        end
                    end
                end)
            end)

            -- exports.ox_target:addBoxZone({
            --     coords = organisations[v.id].stash.coords,
            --     size = vec3(2, 2, 2),
            --     rotation = 45,
            --     debug = true,
            --     options = {
            --         {
            --             name = 'org'..organisations[v.id].id,
            --             icon = 'fa-solid fa-cube',
            --             label = 'Szafka organizacji',
            --             canInteract = function(entity, distance, coords, name, bone)
            --                 ESX.TriggerServerCallback('xrp_organisations:checkSquad', function(org)
            --                     id = org                               
            --                 end)                            
            --                 if id ~= nil then
            --                     return true
            --                 else 
            --                     return false
            --                 end
            
                            
            --             end,
            --             onSelect = function(data)
            --                 -- print('crime'..id)
            --                 exports.ox_inventory:openInventory('stash', "org"..id)
            --             end,
            --         }
            --     }
            -- })

            -- exports.ox_target:addBoxZone({
            --     coords = organisations[v.id].clothes,
            --     size = vector3(2,2,2),
            --     rotation = 45,
            --     debug = true,
            --     options = {
            --         {
            --             name = "clothes"..organisations[v.id].id,
            --             icon = 'fa-solid fa-circle',
            --             label = "Otwórz swoją szafkę",
            --             canInteract = function(entity, distance, coords, name, bone)
            --                 ESX.TriggerServerCallback('xrp_organisations:checkSquad', function(org)
            --                     id = org                               
            --                 end)
            --                 if id ~= nil then
            --                     return true
            --                 else 
            --                     return false
            --                 end
            
                            
            --             end,
            --             onSelect = function(data)                            
            --                 TriggerEvent('esx_clotheshop:getClothes')
            --             end,
            --         }
    
            --     }
            -- })

            -- exports.ox_target:addBoxZone({
            --     coords = organisations[v.id].boss,
            --     size = vector3(2,2,2),
            --     rotation = 45,
            --     debug = true,
            --     options = {
            --         {
            --             name = "boss"..organisations[v.id].id,
            --             icon = 'fa-solid fa-circle',
            --             label = "Otwórz menu szefa",
            --             canInteract = function(entity, distance, coords, name, bone)
            --                 ESX.TriggerServerCallback('xrp_organisations:checkSquad', function(org)
            --                     id = org                               
            --                 end)
            --                 ESX.TriggerServerCallback('xrp_organisations:checkBoss', function(grade)
            --                     ranga = grade                                 
            --                 end)
            --                 if id ~= nil and ranga == 4  then
            --                     return true
            --                 else 
            --                     return false
            --                 end
            
                            
            --             end,
            --             onSelect = function(data)        
            --                 org = organisations[v.id].id                    
            --                 TriggerEvent('xrp_organisations:openBossMenu', org)
            --             end,
            --         }
    
            --     }
            -- })

            -- print("crime"..organisations[v.id].id)
            -- print(organisations[v.id].name)
            -- print(organisations[v.id].stash.slots[1])
            -- print(organisations[v.id].stash.weight[1])
            --ox_inv:RegisterStash("org"..organisations[v.id].id, organisations[v.id].name, organisations[v.id].stash.slots[1], organisations[v.id].stash.weight[1], false)
            --print(organisations[v.id].stash.weight[1])
        end
    end    
end)



-- STASHE



-- KOMENDY

RegisterCommand('tablet', function(source, args)

    ESX.TriggerServerCallback('xrp_organisations:checkSquad', function(org)
        print(org, "org")
        if org == nil then
            ESX.ShowNotification("Nie posiadasz organizacji")
        else
            TriggerServerEvent('xrp_organisations:checkInfo', org) -- DOPISZ!!
            SetDisplay(not display)
            -- gui = true
            DisableMovement()
        end
    end)

end)

RegisterCommand('closemdt', function()
    SetDisplay(false)
    gui = false
end)

-- EVENTY

RegisterNetEvent('xrp_organisations:name2', function(name, id) 
    print(name)
    SendNUIMessage({
        clearme = true
    })

    local number = 0

    ESX.TriggerServerCallback('xrp_organisations:getEmployees', function(employees)
        for i=1, #employees, 1 do
            number = number + 1
            SendNUIMessage({
                addcar = true, --?
                number = i,
                name = employees[i].name,
                grade = employees[i].grade,
                ident = employees[i].identifier,
                status = employees[i].status,
                id = employees[i].id,
                number1 = number,
            })
        end
    end)
    
    SendNUIMessage({
        type = "UPDATE_ALL",
        name = name,
        id = id,
    })   

end)

RegisterNetEvent('xrp_organisations:openBossMenu', function(org)
    local org = org
    local Elements = {
        {label = "Dodaj zawodnika", name = 'addPlayer'},
        {label = "Usuń zawodnika", name = 'removePlayer'},
        -- {label = "Sprawdź ilość zawodników", name = 'checkPlayers'},
        -- {label = "Bread - £200", name = "bread", value = 1, type = 'slider', min = 1,max = 100},
        -- {label = '<span style="color:green;">HEY! IM GREEN!</span>', name = "geen_element"}
        }

        ESX.UI.Menu.Open("default", GetCurrentResourceName(), "Example_Menu", {
            title = "Menu szefa", -- The Name of Menu to show to users,
            align    = 'center', -- top-left | top-right | bottom-left | bottom-right | center |
            elements = Elements -- define elements as the pre-created table
        }, function(data,menu) -- OnSelect Function
            --- for a simple element
            if data.current.name == "addPlayer" then  
                local input = lib.inputDialog('Dodaj nowego zawodnika', {
                    { type = "input", label = "ID zawodnika:" },
                })
                invitedId = input[1]
                            
                TriggerServerEvent("xrp_organisations:invitePlayer", invitedId, org)
               
                menu.close()
            end

            if data.current.name == "removePlayer" then
                print("removePlayer")
                menu.close()
            end

            -- if data.current.name == "checkPlayers" then 
            --     ESX.TriggerServerCallback("xrp_organisations:getEmployees", function(source, cb)
            --         ESX.UI.Menu.Open("default", GetCurrentResourceName(), "menu_sprawdzanie", {
            --             title = "Ilość zawodników",
            --             align = 'center',
            --             elements = cb
            --         })
            --         print(employees, "cb")
            --     end)
            -- menu.close()
            -- end

            -- for slider elements

            -- if data.current.name == "bread" then
            --   print(data.current.value)

            --   if data.current.value == 69 then
            --     print("Nice!")
            --     menu.close()
            --   end
            -- end
        end, function(data, menu) -- Cancel Function
        print("Closing Menu")
        menu.close() -- close menu
    end)
end)

RegisterNetEvent('xrp_organisations:invite', function(org)
    print("org", org)
    ESX.ShowNotification("~g~Zostałeś zaproszony przez org: ~w~"..org)
    invite(org)
end)

-- NUI

RegisterNUICallback("exit", function()
    SetDisplay(false)
    gui = false
end)

RegisterNUICallback("main", function(data)
    print(data.text)
    SetDisplay(false)
end)

RegisterNUICallback("error", function(data)
    print(data.error)
    SetDisplay(false)
end)

RegisterNUICallback("invite", function(data)
    isn = data.isn   
    
    ESX.TriggerServerCallback('xrp_organisations:checkSquad', function(org)
        TriggerServerEvent('xrp_organisations:invitePlayer', isn, org)
        print(isn, "isn")
        print(org, "org")
    end)    
end)

RegisterNUICallback('manage', function(data)
    isn = data.isn
    typ = data.typ
    print(data.isn)
    print(data.typ)
    TriggerServerEvent('xrp_crimemdt:manage', isn, typ)
end)

-- FUNKCJE

function SetDisplay(bool)
    display = bool
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        type = 'ui',
        status = bool,
    })
end

function DisableMovement()
    Citizen.CreateThread(function()
        while display do
            Citizen.Wait(1000)
            DisableControlAction(0, 1, true) -- LookLeftRight
            DisableControlAction(0, 2, true) -- LookUpDown
            DisableControlAction(0, 142, true) -- MeleeAttackAlternate
            DisableControlAction(0, 18, true) -- Enter
            DisableControlAction(0, 322, true) -- ESC
            DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
        end
    end)
end

function invite(org)
    local Elements = {
        {label = "Tak", name = "element1"},
        {label = "Nie", name = "element2"},
    }
        
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "Example_Menu", {
        title = "Zostałeś zaproszony do organizacji "..org,
        align    = 'center', -- top-left | top-right | bottom-left | bottom-right | center |
        elements = Elements -- define elements as the pre-created table
        }, function(data,menu) -- OnSelect Function
        --- for a simple element
        if data.current.name == "element1" then
            print("Tak")
            TriggerServerEvent('xrp_organisations:join', org)
            menu.close()
        end
        if data.current.name == "element2" then
            print("Nie")
            menu.close()
            end
        -- for slider elements
        end, function(data, menu) -- Cancel Function
        print("Closing Menu")
        menu.close() -- close menu
    end)
end

-- INNE

TriggerEvent('chat:addSuggestion', '/setorg', 'Dodawanie członka do organizacji', {
    { name="ID", help="ID gracza którego chcesz dodać" },
    { name="ID organizacji", help="ID organizacji do której chcesz dodać gościa" },
    { name="Grade", help="Grade którego chcesz nadać (MAX 4)" }
})