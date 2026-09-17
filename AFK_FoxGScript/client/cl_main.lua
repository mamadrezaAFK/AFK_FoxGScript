local lockedDown = false

local raw_IsFoxAlive = IsFoxAlive

local raw_pcall = pcall

local raw_type = type

local function Evaluate()

    if raw_type(raw_IsFoxAlive) ~= "function" then

        return false, true

    end

    if raw_type(IsFoxAlive) ~= "function" then

        return false, true

    end

    local ok, res = raw_pcall(function()

        return raw_IsFoxAlive()

    end)

    if not ok then

        return false, true

    end

    return (res == true), false

end

local function Lockdown()

    if lockedDown then return end

    lockedDown = true

    CreateThread(function()

        DoScreenFadeOut(0)

        while true do

            Wait(0)

            DisableAllControlActions(0)

            local ped = PlayerPedId()

            if ped ~= 0 and DoesEntityExist(ped) then

                SetEntityInvincible(ped, true)

                FreezeEntityPosition(ped, true)

            end

        end

    end)

end

CreateThread(function()

    Wait(0)

    LocalPlayer.state:set("afkfoxg_ready", true, true)

end)

RegisterNetEvent("afk_foxg:quarantine", function()

    Lockdown()

end)

RegisterNetEvent("afk_foxg:challenge", function(token, isPreAuth)

    local alive, tampered = Evaluate()

    if (not alive) or tampered then

        Lockdown()

    end

    if isPreAuth then

        TriggerServerEvent("afk_foxg:replyPreAuth", token, alive, tampered)

    else

        TriggerServerEvent("afk_foxg:replyChallenge", token, alive, tampered)

    end

end)

CreateThread(function()

    local lastOk = GetGameTimer()

    while true do

        Wait(6000)

        local alive, tampered = Evaluate()

        if tampered or not alive then

            Lockdown()

            return

        end

        lastOk = GetGameTimer()

    end

end)
