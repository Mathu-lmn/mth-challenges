isParticipating = true
inScaleform = false
inChallenge = false
local showScoreboard = false
local percentage = 1
local current_cooldown = 0

-- FORMATTING STUFF

local ScreenCoords = {
    baseX = 0.918,
    baseY = 0.984,
    titleOffsetX = 0.012,
    titleOffsetY = -0.009,
    valueOffsetX = 0.0785,
    valueOffsetY = -0.0165,
    pbarOffsetX = 0.005,
    pbarOffsetY = 0.0015
}

local Sizes = {
    timerBarWidth = 0.165,
    timerBarHeight = 0.035,
    timerBarMargin = 0.038,
    pbarWidth = 0.1616,
    pbarHeight = 0.0205
}

local text = {
    r = 80, g = 190, b = 80, a = 255,
}

local sprite = {
    r = 255, g = 255, b = 255, a = 190,
}

local percentbar = {
    r1 = 255,
    g1 = 255,
    b1 = 255,
    a1 = 255,
    r2 = 40,
    g2 = 175,
    b2 = 95,
    a2 = 255,
}

local scoreboard = {
    { name = "Player 1", score = 0 },
    { name = "Player 2", score = 0 },
    { name = "Player 3", score = 0 },
}

RegisterCommand("toggle_challenges", function()
    isParticipating = not isParticipating
    if isParticipating then
        TriggerEvent("chat:addMessage", { args = { "~r~[mth-challenges]", "You will enter the next challenge !" } })
    else
        TriggerEvent("chat:addMessage", { args = { "~r~[mth-challenges]", "You are no longer participating in challenges" } })
        showScoreboard = false
        inChallenge = false
    end
end)

RegisterNetEvent("mth-challenges:startEvent")
AddEventHandler("mth-challenges:startEvent", function(event, cooldown)
    if isParticipating then
        TriggerEvent(event)
        current_cooldown = cooldown
    end
end)

RegisterNetEvent("mth-challenges:endEvent")
AddEventHandler("mth-challenges:endEvent", function(event, bestPlayer)
    if isParticipating and inChallenge then
        showScoreboard = false
        percentage = 1
        if bestPlayer ~= nil and bestPlayer[1].score ~= 0 then
            showResults(bestPlayer)
        end
        TriggerEvent(event)
    end
end)

RegisterNetEvent("mth-challenges:updateScoreboard")
AddEventHandler("mth-challenges:updateScoreboard", function(data, percentage_remaining)
    if isParticipating and inChallenge then
        scoreboard = data
    end
end)

RegisterNetEvent("mth-challenges:updateTimer")
AddEventHandler("mth-challenges:updateTimer", function(percentage_remaining)
    if isParticipating and inChallenge then
        percentage = percentage_remaining / 100
    end
end)

function showResults(bestPlayer)
    ClearPrints()

    local begin = GetGameTimer()

    local scaleform = RequestScaleformMovie("MP_BIG_MESSAGE_FREEMODE")
    while not HasScaleformMovieLoaded(scaleform) do
        Citizen.Wait(0)
    end

    BeginScaleformMovieMethod(scaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
    PushScaleformMovieMethodParameterString("~r~Challenge Results")
    PushScaleformMovieMethodParameterString("~w~" .. bestPlayer[1].name .. " won the challenge with a score of ~g~" .. bestPlayer[1].score .. "~w~ !")
    EndScaleformMovieMethod()

    PlaySoundFrontend(-1, "Mission_Pass_Notify", "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", 1)
    while GetGameTimer() - begin < 5000 do
        Citizen.Wait(0)
        DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
    end
end

function startScoreboard()
    showScoreboard = true

    if not isParticipating then
        return
    end

    Citizen.CreateThread(function()
        while showScoreboard do
            Citizen.Wait(0)
            displayScoreboard()
        end
    end)
    -- do the timer countdown
    Citizen.CreateThread(function()
        while showScoreboard do
            Citizen.Wait(current_cooldown / 100)
            percentage = percentage - 0.01
        end
    end)
end

function displayScoreboard()
    local safeZone = GetSafeZoneSize()
    local safeZoneX = (1.0 - safeZone) * 0.5
    local safeZoneY = (1.0 - safeZone) * 0.5

    local drawY1 = (ScreenCoords.baseY - safeZoneY) - (3 * Sizes.timerBarMargin)
    local drawY2 = (ScreenCoords.baseY - safeZoneY) - (2 * Sizes.timerBarMargin)
    local drawY3 = (ScreenCoords.baseY - safeZoneY) - (1 * Sizes.timerBarMargin)

    DrawSprite("timerbars", "all_black_bg", ScreenCoords.baseX - safeZoneX + 0.005, drawY1, Sizes.timerBarWidth, Sizes.timerBarHeight, 0, sprite.r, sprite.g, sprite.b, sprite.a)
    DrawSprite("timerbars", "all_black_bg", ScreenCoords.baseX - safeZoneX + 0.005, drawY2, Sizes.timerBarWidth, Sizes.timerBarHeight, 0, sprite.r, sprite.g, sprite.b, sprite.a)
    DrawSprite("timerbars", "all_black_bg", ScreenCoords.baseX - safeZoneX + 0.005, drawY3, Sizes.timerBarWidth, Sizes.timerBarHeight, 0, sprite.r, sprite.g, sprite.b, sprite.a)

    AddTextEntry("player1", scoreboard[1].name .. " - " .. scoreboard[1].score)
    AddTextEntry("player2", scoreboard[2].name .. " - " .. scoreboard[2].score)
    AddTextEntry("player3", scoreboard[3].name .. " - " .. scoreboard[3].score)

    SetTextScale(1.0, 0.45)
    SetTextColour(text.r, text.g, text.b, text.a)
    SetTextCentre(true)
    BeginTextCommandDisplayText("player1")
    EndTextCommandDisplayText((ScreenCoords.baseX - safeZoneX) + ScreenCoords.titleOffsetX, drawY1 + ScreenCoords.valueOffsetY)

    SetTextScale(1.0, 0.45)
    SetTextColour(text.r, text.g, text.b, text.a)
    SetTextCentre(true)
    BeginTextCommandDisplayText("player2")
    EndTextCommandDisplayText((ScreenCoords.baseX - safeZoneX) + ScreenCoords.titleOffsetX, drawY2 + ScreenCoords.valueOffsetY)

    SetTextScale(1.0, 0.45)
    SetTextColour(text.r, text.g, text.b, text.a)
    SetTextCentre(true)
    BeginTextCommandDisplayText("player3")
    EndTextCommandDisplayText((ScreenCoords.baseX - safeZoneX) + ScreenCoords.titleOffsetX, drawY3 + ScreenCoords.valueOffsetY)

    local pbarX = (ScreenCoords.baseX - safeZoneX) + ScreenCoords.pbarOffsetX
    local pbarY = (ScreenCoords.baseY - safeZoneY) + ScreenCoords.pbarOffsetY
    local width = Sizes.pbarWidth * percentage

    DrawRect(pbarX, pbarY, Sizes.pbarWidth, Sizes.pbarHeight, percentbar.r1, percentbar.g1, percentbar.b1, percentbar.a1)
    DrawRect((pbarX - Sizes.pbarWidth / 2) + width / 2, pbarY, width, Sizes.pbarHeight, percentbar.r2, percentbar.g2, percentbar.b2, percentbar.a2)
end

function DrawInstruction(instruction)
    AddTextEntry('mth-challenges:Subtitle', instruction)
    BeginTextCommandPrint('mth-challenges:Subtitle')
    AddTextComponentSubstringPlayerName(instruction)
    EndTextCommandPrint(500, true)
end

function startMissionScreen(title, instructions)
    inScaleform = true
    -- SHOW SCALEFORM WITH INSTRUCTIONS
    PlaySoundFrontend( -1, "FLIGHT_SCHOOL_LESSON_PASSED", "HUD_AWARDS")
    -- scaleform to show big message to start the challenge.
    local begin = GetGameTimer()
    local scaleform = RequestScaleformMovie("MP_BIG_MESSAGE_FREEMODE")
    while not HasScaleformMovieLoaded(scaleform) do
        Citizen.Wait(0)
    end
    while GetGameTimer() - begin < 5000 do
        Citizen.Wait(0)
        BeginScaleformMovieMethod(scaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
        ScaleformMovieMethodAddParamTextureNameString(title)
        ScaleformMovieMethodAddParamTextureNameString(instructions)
        EndScaleformMovieMethod()
        DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
    end
    inScaleform = false
end

AddEventHandler('playerSpawned', function()
    if not isParticipating then
        return
    end
    Wait(5000)
    local player = GetPlayerServerId(PlayerId())
    TriggerServerEvent('mth-challenges:playerConnected', player)
end)