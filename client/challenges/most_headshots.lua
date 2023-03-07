local startingHeadshotsCount = 0
local headshotsCount = 0

function StartHeadShotsChallenge()
    -- This function is called when the challenge is started.
    -- We want to set the headshot count to 0 if it's not already 0.
    headshotsCount = 0
    inChallenge = true
    -- Initialize the starting headshot count.
    local _, startingHeadshotsCount = StatGetInt(GetHashKey("mp0_headshots"), -1)

    startMissionScreen("Headshots Challenge", "Get the most headshots")
    Wait(1000)
    while inScaleform do
        Wait(100)
    end
    startScoreboard()
    Citizen.CreateThread(function()
        TriggerServerEvent("mth-challenges:updateEvent", headshotsCount)

        while inChallenge do
            local _, currentHeadshotsCount = StatGetInt(GetHashKey("mp0_headshots"), -1)
            if currentHeadshotsCount - startingHeadshotsCount > headshotsCount and isParticipating then
                headshotsCount = currentHeadshotsCount - startingHeadshotsCount
                TriggerServerEvent("mth-challenges:updateEvent", headshotsCount)
            end
            Citizen.Wait(1000)
        end
    end)

    Citizen.CreateThread(function()
        while inChallenge do
            DrawInstruction("Your objective is to get the most headshots")
            Citizen.Wait(500)
        end
    end)
end

function EndHeadShotsChallenge()
    headshotsCount = 0
    inChallenge = false
end

RegisterNetEvent("StartHeadShotsChallenge", StartHeadShotsChallenge)
RegisterNetEvent("EndHeadShotsChallenge", EndHeadShotsChallenge)