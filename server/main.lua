local currentEvent = nil
local inEvent = false
local currentEventId = -1
local percentage_remaining = 100
local PlayerData = {}

AddEventHandler("onResourceStart", function (resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    Wait(5000)
    startEvent()
end)

function startEvent()
    print("Starting event")
    -- Avoid the same event twice in a row.
    local nextEventId = math.random(#Challenges_list)
    while nextEventId == currentEventId do
        nextEventId = math.random(#Challenges_list)
    end
    currentEventId = nextEventId

    currentEvent = Challenges_list[currentEventId]
    percentage_remaining = 100
    PlayerData = {}
    TriggerClientEvent("mth-challenges:startEvent", -1, currentEvent["start"], currentEvent["countdown"])
    Wait(5000)
    inEvent = true
    Citizen.CreateThread(function()
        Citizen.Wait(currentEvent["countdown"])
        stopEvent()
        Wait(Config["cooldown"])
        startEvent()
    end)

    Citizen.CreateThread(function()
        while inEvent do
            Citizen.Wait(currentEvent["countdown"] / 100)
            percentage_remaining = percentage_remaining - 1
            if percentage_remaining % 10 == 0 then
                TriggerClientEvent("mth-challenges:updateTimer", -1, percentage_remaining, currentEvent["countdown"])
            end
        end
    end)
end


RegisterNetEvent("mth-challenges:updateEvent")
AddEventHandler("mth-challenges:updateEvent", function (data)
    if currentEvent == nil then
        return
    end
    local score = data
    local player = source
    if PlayerData[currentEventId] == nil then
        PlayerData[currentEventId] = {}
    end
    if PlayerData[currentEventId][player] == nil then
        PlayerData[currentEventId][player] = 0
    end
    if score > PlayerData[currentEventId][player] then
        PlayerData[currentEventId][player] = score
    end

    local bestPlayers = getFirst3Players(currentEventId)
    TriggerClientEvent("mth-challenges:updateScoreboard", -1, bestPlayers)
end)

function getFirst3Players(eventId)
    local data = PlayerData[eventId]
    local players = {}
    if data == nil then
        return players
    end
    for k, v in pairs(data) do
        local name = GetPlayerName(k)
        table.insert(players, {name = name, score = v})
    end
    table.sort(players, function(a, b)
        return a.score > b.score
    end)
    local bestPlayers = {
        {name = "Player 1", score = 0},
        {name = "Player 2", score = 0},
        {name = "Player 3", score = 0}
    }
    for i = 1, 3 do
        if players[i] ~= nil then
            bestPlayers[i] = players[i]
        end
    end
    return bestPlayers
end

function stopEvent()
    -- send to the players the 3 best players and their score then reset the data
    local bestPlayers = getFirst3Players(currentEventId)
    TriggerClientEvent("mth-challenges:endEvent", -1, currentEvent["end"], bestPlayers)
    PlayerData[currentEventId] = {}
    inEvent = false
end

RegisterNetEvent("mth-challenges:playerConnected")
AddEventHandler("mth-challenges:playerConnected", function()
    if currentEvent ~= nil then
        TriggerClientEvent("mth-challenges:startEvent", source, currentEvent["start"], currentEvent["countdown"])
    end
end)