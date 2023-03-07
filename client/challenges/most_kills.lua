local startingKillCount = 0
local killCount = 0

function StartMostKillsChallenge()
    -- This function is called when the challenge is started.
    -- We want to set the kill count to 0 if it's not already 0.
    killCount = 0
    inChallenge = true
    -- Initialize the starting kill count.
    local _, startingKillCount = StatGetInt(GetHashKey("MP0_KILLS"), -1)

    startMissionScreen("Most Kills Challenge", "Get the most kills")
    Wait(1000)
    while inScaleform do
        Wait(100)
    end
    startScoreboard()
    Citizen.CreateThread(function()
        TriggerServerEvent("mth-challenges:updateEvent", killCount)

        while inChallenge do
            local _, currentKillCount = StatGetInt(GetHashKey("MP0_KILLS"), -1)
            if currentKillCount - startingKillCount > killCount and isParticipating then
                killCount = currentKillCount - startingKillCount
                TriggerServerEvent("mth-challenges:updateEvent", killCount)
            end
            Citizen.Wait(1000)
        end
    end)

    Citizen.CreateThread(function()
        while inChallenge do
            DrawInstruction("Your objective is to get the most kills")
            Citizen.Wait(500)
        end
    end)
end

function EndMostKillsChallenge()
    killCount = 0
    inChallenge = false
end

RegisterNetEvent("StartMostKillsChallenge", StartMostKillsChallenge)
RegisterNetEvent("EndMostKillsChallenge", EndMostKillsChallenge)