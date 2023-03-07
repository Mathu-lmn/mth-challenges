local longestFreefallSurvived = 0.0

function math.round(num, numDecimalPlaces)
    return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

function StartLongestFreefallSurvivedChallenge()
    inChallenge = true
    -- reset stat to 0
    StatSetFloat(GetHashKey("MP0_LONGEST_SURVIVED_FREEFALL"), 0.0, true)

    startMissionScreen("Longest Freefall Survived Challenge", "Survive to the longest freefall")
    Wait(1000)
    while inScaleform do
        Wait(100)
    end
    startScoreboard()
    Citizen.CreateThread(function()
        TriggerServerEvent("mth-challenges:updateEvent", longestFreefallSurvived)

        while inChallenge do
            local _, currentFreefall = StatGetFloat(GetHashKey("MP0_LONGEST_SURVIVED_FREEFALL"), -1)
            currentFreefall = math.round(currentFreefall, 2)
            if currentFreefall > longestFreefallSurvived and isParticipating then
                longestFreefallSurvived = currentFreefall
                TriggerServerEvent("mth-challenges:updateEvent", longestFreefallSurvived)
            end
            Citizen.Wait(1000)
        end
    end)

    Citizen.CreateThread(function()
        while inChallenge do
            DrawInstruction("Your objective is to survive to the longest freefall")
            Citizen.Wait(500)
        end
    end)
end

function EndLongestFreefallSurvivedChallenge()
    longestFreefallSurvived = 0
    inChallenge = false
end

RegisterNetEvent("StartLongestFreefallSurvivedChallenge", StartLongestFreefallSurvivedChallenge)
RegisterNetEvent("EndLongestFreefallSurvivedChallenge", EndLongestFreefallSurvivedChallenge)