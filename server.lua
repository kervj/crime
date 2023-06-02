ESX = exports['es_extended']:getSharedObject()
local ox_inv = exports.ox_inventory
local lastID = 0
local user = nil
local organisations = {}

AddEventHandler('onResourceStart', function(resourceName)    
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
            }
            -- print("crime"..organisations[v.id].id)
            -- print(organisations[v.id].name)
            -- print(organisations[v.id].stash.slots[1])
            -- print(organisations[v.id].stash.weight[1])
            ox_inv:RegisterStash("org"..organisations[v.id].id, organisations[v.id].name, organisations[v.id].stash.slots[1], organisations[v.id].stash.weight[1], false)
            --print(organisations[v.id].stash.weight[1])
        end
    end    
end)

-- stashe


-- eventy

RegisterNetEvent('xrp_organisations:checkInfo', function(org) 
    local xPlayer = ESX.GetPlayerFromId(source)
    local org = org
    for _,v in pairs(Config.organisations) do
        
        if organisations[v.id]['id'] == org then
            name = organisations[v.id]['name']
            id = organisations[v.id]['id']
        end
    end
    print(name, id, "name, id")

	TriggerClientEvent("xrp_organisations:name2", source, name, id)


end)

RegisterNetEvent('xrp_organisations:invitePlayer', function(isn, org)
    print(isn, "isn1")
    print(org, "org1")
    TriggerClientEvent('xrp_organisations:invite', isn, org)
end)

RegisterNetEvent('xrp_organisations:join', function(org)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local user = MySQL.Sync.fetchAll("SELECT `org` FROM `users` WHERE `identifier` = @identifier", {
		["@identifier"] = xPlayer.identifier
	})[1] or false

    if tonumber(user["org"]) ~= nil then
        xPlayer.showNotification('Jesteś już w jakieś organizacji.', 'info', 3000)
    else  
        MySQL.Async.execute("UPDATE `users` SET `org` = @org WHERE `identifier` = @id", {
            ["@id"] = xPlayer.identifier,
            ["@org"] = org
        })
        MySQL.Async.execute("UPDATE `users` SET `org_grade` = @org_grade WHERE `identifier` = @id", {
            ["@id"] = xPlayer.identifier,
            ["@org_grade"] = 0
        })  
        xPlayer.showNotification('Dołączyłeś do organizacji '..id..'.', 'info', 3000)
    end
end)

RegisterNetEvent('xrp_crimemdt:manage', function(isn, typ)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local user = MySQL.Sync.fetchAll("SELECT * FROM `users` WHERE `identifier` = @identifier", {
        ["@identifier"] = xPlayer.identifier
    })[1] or false

    local mUser = MySQL.Sync.fetchAll("SELECT * FROM `users` WHERE `id` = @identifier", {
        ["@identifier"] = isn,
    })[1] or false
    print(mUser.identifier, "mUser")
    print(user.identifier, "usser")
    grade =  tonumber(user.org_grade)

    if typ == "promote" then
        if mUser.identifier ~= user.identifier then
            grade1 =  tonumber(mUser.org_grade)
            if grade >= Config.promotion then
                if grade1 <= 3 then
                    MySQL.Async.execute("UPDATE `users` SET `org_grade` = @badge WHERE `id` = @identifier", {
                        ["@identifier"] = isn,
                        ["@badge"] = grade1 + 1
                    })
                    TriggerClientEvent("xrp_crimemdt:refresh", _source)
                    TriggerClientEvent('esx:showNotification', _source, '~g~ Pomyślnie awansowano użytkownika o ISN: ~y~'..user.id) 
                else
                    TriggerClientEvent('esx:showNotification', _source, '~r~ Nie możesz nadać wyższej rangi niż 4')
                 end
            else
                TriggerClientEvent('esx:showNotification', _source, '~r~ Twoja ranga jest zbyt niska')    
            end
        else
            TriggerClientEvent('esx:showNotification', _source, '~r~ Nie możesz zarządzać samym sobą')
        end

    elseif typ == "degrad" then
        if mUser.identifier ~= user.identifier then
            grade1 =  tonumber(mUser.org_grade)            
            if grade >= Config.degradation then
                if grade1 >= 1 then
                    MySQL.Async.execute("UPDATE `users` SET `org_grade` = @badge WHERE `id` = @identifier", {
                        ["@identifier"] = isn,
                        ["@badge"] = grade1 - 1
                    })
                    TriggerClientEvent("xrp_crimemdt:refresh", _source)
                    TriggerClientEvent('esx:showNotification', _source, '~g~ Pomyślnie degradowano użytkownika o ISN: ~y~'..user.id) 
                else
                    TriggerClientEvent('esx:showNotification', _source, '~r~ Nie możesz nadać niższej rangi niż 0')
                end
            else
                TriggerClientEvent('esx:showNotification', _source, '~r~ Twoja ranga jest zbyt niska')    
            end
        else
            TriggerClientEvent('esx:showNotification', _source, '~r~ Nie możesz zarządzać samym sobą')
        end

    elseif typ == "fire" then
        if mUser.identifier ~= user.identifier then
            if grade >= Config.kick then
                MySQL.Async.execute("UPDATE `users` SET `org` = @badge WHERE `id` = @identifier", {
                    ["@identifier"] = isn,
                    ["@badge"] = nil
                })
                MySQL.Async.execute("UPDATE `users` SET `org_grade` = @badge WHERE `id` = @identifier", {
                    ["@identifier"] = isn,
                    ["@badge"] = nil
                })
                TriggerClientEvent("xrp_crimemdt:refresh", _source)
                TriggerClientEvent('esx:showNotification', _source, '~g~ Pomyślnie zwolniono użytkownika o ISN: ~y~'..user.id) 
            else
                TriggerClientEvent('esx:showNotification', _source, '~r~ Twoja ranga jest zbyt niska') 
            end
        else
            TriggerClientEvent('esx:showNotification', _source, '~r~ Nie możesz zarządzać samym sobą')
        end
    end
end)

-- komendy

RegisterCommand("setorg", function(source, args, user)
    local xPlayer = ESX.GetPlayerFromId(source)
    local cPlayer = ESX.GetPlayerFromId(args[1])
    local user = MySQL.Sync.fetchAll("SELECT * FROM `users` WHERE `identifier` = @identifier", {
        ["@identifier"] = cPlayer.identifier
    })[1] or false
    if xPlayer.group == "admin" then
        if user.org == nil then
            if tonumber(args[3]) > 4 then
                xPlayer.showNotification("Grade (stopień) nie może być większy niż 4.", 'info', 3000)
            else
                MySQL.Async.execute("UPDATE `users` SET `org` = @badge WHERE `identifier` = @identifier", {
                    ["@identifier"] = cPlayer.identifier,
                    ["@badge"] = args[2]
                })
                MySQL.Async.execute("UPDATE `users` SET `org_grade` = @badge WHERE `identifier` = @identifier", {
                    ["@identifier"] = cPlayer.identifier,
                    ["@badge"] = args[3]
                })
                xPlayer.showNotification("Pomyślnie dodałeś id: "..args[1].." do organizacji o id: "..args[2]..".", 'info', 3000)
            end
        else
            xPlayer.showNotification("Ten użytkownik jest w jakieś organizacji.", 'info', 3000)
        end
    else
        xPlayer.showNotification("Nie posiadasz wystarczających uprawnień do używania tej komendy.", 'info', 3000)
    end   
end)

-- funkcje

function refreshDatabase()

	MySQL.Async.fetchAll("SELECT MAX(ID) FROM `org`", {}, function(orgs)
        lastID = orgs[1]["MAX(ID)"]
        print(lastID, "S")
    end)

    MySQL.Async.fetchAll("SELECT * FROM `org`", {}, function(orgs)
        for _, org in ipairs(orgs) do
            organisations[org.id] = {
                id = org.id,
                name = org.name,
                owner = org.owner,
                balance = org.balance,
                xp = org.xp,
                lvl = org.lvl,
                btc = org.btc
            }
        end
        print(json.encode(organisations))
    end)

end

-- Callbacki

ESX.RegisterServerCallback("xrp_organisations:getEmployees", function(source, cb)

	local xPlayer = ESX.GetPlayerFromId(source)
	
	for _, v in pairs(organisations) do
		--(organisations[v.id]["owner"])
		if organisations[v.id]["owner"] == xPlayer.identifier then
			id = organisations[v.id]["id"]
			name = organisations[v.id]["name"]
			--print(id)
		end
	end

	if name then
		MySQL.Async.fetchAll('SELECT firstname, lastname, identifier, id, org, org_grade FROM users WHERE org = @job ORDER BY org_grade DESC', {
            ['@job'] = id
        }, function (results)
			local employees = {}
			for i=1, #results do
				local xPlayer2 = ESX.GetPlayerFromIdentifier(results[i].identifier)
				if xPlayer2 then
					status = "active"
				else
					status = "offline"
				end
				table.insert(employees, {
					name = results[i].firstname ..' '.. results[i].lastname,
					identifier = results[i].identifier,
					grade = results[i].org_grade,
					id = results[i].id,
                    status = status,
					badge = {

					},
					job = {

					}
				})
			end
			cb(employees)			
		end)
	end
	


end)

ESX.RegisterServerCallback("xrp_organisations:checkSquad", function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
		
    user = MySQL.Sync.fetchAll("SELECT * FROM `users` WHERE `identifier` = @identifier", {
        ["@identifier"] = xPlayer.identifier
    })[1] or false
    org = user.org
	
    -- print(org, "Cb")
	cb(org)
end)

ESX.RegisterServerCallback("xrp_organisations:checkBoss", function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
		
    user = MySQL.Sync.fetchAll("SELECT * FROM `users` WHERE `identifier` = @identifier", {
        ["@identifier"] = xPlayer.identifier
    })[1] or false
    grade = user.org_grade
    cb(grade)
end)

