local ESX = nil

local Pending = {}   

local Sessions = {}  

local Connecting = {}

local function Now() return GetGameTimer() end

local function Token()

    return string.format("%08x%08x", math.random(0, 0x7fffffff), (os.time() + math.random(1000, 9999)) % 0xffffffff)

end

local function ClearPlayer(src)

    Pending[src] = nil

    Sessions[src] = nil

    Connecting[src] = nil

end

if Config.UseESX then

    CreateThread(function()

        local ok, obj = pcall(function()

            return exports['es_extended']:getSharedObject()

        end)

        if ok and obj then ESX = obj return end

        local attempts = 0

        while ESX == nil and attempts < 25 do

            TriggerEvent('esx:getSharedObject', function(o) ESX = o end)

            attempts = attempts + 1

            Wait(200)

        end

    end)

end

local function GetXPlayer(src)

    if not ESX then return nil end

    return ESX.GetPlayerFromId(src)

end

local function IsAdmin(src)

    if src == 0 then return true end

    if not Config.UseESX then return false end

    local xPlayer = GetXPlayer(src)

    if not xPlayer then return false end

    local group = (xPlayer.getGroup and xPlayer.getGroup()) or xPlayer.group or "user"

    if Config.AdminGroups then

        local gl = tostring(group):lower()

        for _, g in ipairs(Config.AdminGroups) do

            if gl == tostring(g):lower() then return true end

        end

    end

    local perm = (xPlayer.getPermissions and xPlayer.getPermissions()) or xPlayer.permission_level or (xPlayer.get and xPlayer.get('permission_level'))

    if perm ~= nil and Config.AdminPermissions then

        local n = tonumber(perm)

        if n then

            for _, minLvl in ipairs(Config.AdminPermissions) do

                if n >= tonumber(minLvl) then return true end

            end

        end

    end

    return false

end

local function Identifiers(src)

    local ids = {

        steam = nil,

        discord = nil,

        license = nil,

        ip = GetPlayerEndpoint(src)

    }

    for i = 0, GetNumPlayerIdentifiers(src) - 1 do

        local id = GetPlayerIdentifier(src, i)

        if id then

            if not ids.steam and id:sub(1,6) == "steam:" then ids.steam = id end

            if not ids.license and id:sub(1,8) == "license:" then ids.license = id end

            if not ids.discord and id:sub(1,8) == "discord:" then ids.discord = id end

        end

    end

    return ids

end

local function GetRP(src)

    local out = {

        name = GetPlayerName(src) or "Namoshakhas",

        rpName = "Namoshakhas",

        job = "Namoshakhas",

        group = "user",

        permLevel = "0",

        money = "0"

    }

    if not Config.UseESX then return out end

    local xPlayer = GetXPlayer(src)

    if not xPlayer then return out end

    out.rpName = (xPlayer.getName and xPlayer.getName()) or out.name

    local job = (xPlayer.getJob and xPlayer.getJob()) or xPlayer.job

    if job and job.name then

        local gradeLabel = (job.grade_label or job.gradeLabel or job.grade_name or job.gradeName)

        out.job = gradeLabel and (tostring(job.name) .. " - " .. tostring(gradeLabel)) or tostring(job.name)

    end

    out.group = (xPlayer.getGroup and xPlayer.getGroup()) or xPlayer.group or "user"

    local perm = (xPlayer.getPermissions and xPlayer.getPermissions()) or xPlayer.permission_level or (xPlayer.get and xPlayer.get('permission_level'))

    if perm ~= nil then out.permLevel = tostring(perm) end

    local bank = (xPlayer.getAccount and xPlayer.getAccount('bank'))

    if bank and bank.money ~= nil then

        out.money = tostring(bank.money)

    elseif xPlayer.getMoney then

        out.money = tostring(xPlayer.getMoney())

    end

    return out

end

local function DiscordLog(src, reason, color)

    if not Config.DiscordWebhook or Config.DiscordWebhook == "" or tostring(Config.DiscordWebhook):find("YOUR_DISCORD") then return end

    local rp = GetRP(src)

    local ids = Identifiers(src)

    local discordShown = "Nist"

    if ids.discord then

        discordShown = "<@" .. ids.discord:gsub("discord:", "") .. "> (" .. ids.discord .. ")"

    end

    local embed = {

        {

            color = color or 15158332,

            title = "AFK_FoxGScript",

            description = "**Dalile Barkhord:** " .. tostring(reason),

            fields = {

                { name = "Player", value = string.format("%s | RP: **%s** (ID: %s)", rp.name, rp.rpName, tostring(src)), inline = false },

                { name = "Job", value = tostring(rp.job), inline = true },

                { name = "Access", value = tostring(rp.group) .. " (Perm: " .. tostring(rp.permLevel) .. ")", inline = true },

                { name = "Ping", value = tostring(GetPlayerPing(src)) .. " ms", inline = true },

                { name = "IP", value = tostring(ids.ip or "Namoshakhas"), inline = true },

                { name = "Steam", value = "`" .. tostring(ids.steam or "Nist") .. "`", inline = true },

                { name = "License", value = "`" .. tostring(ids.license or "Nist") .. "`", inline = false },

                { name = "Discord", value = tostring(discordShown), inline = false }

            },

            footer = { text = (Config.ServerName or "Server") .. " | " .. os.date("!%Y-%m-%d %H:%M:%S UTC") }

        }

    }

    PerformHttpRequest(Config.DiscordWebhook, function() end, "POST", json.encode({

        username = Config.BotName or "AFK_FoxGScript",

        avatar_url = Config.BotAvatar,

        embeds = embed

    }), { ["Content-Type"] = "application/json" })

end

local function BanDB(src, reason)

    local lic = "Unknown"

    for i = 0, GetNumPlayerIdentifiers(src) - 1 do

        local id = GetPlayerIdentifier(src, i)

        if id and id:sub(1,8) == "license:" then lic = id break end

    end

    local query = "INSERT INTO banlist (identifier, reason, expiration) VALUES (@id, @reason, @exp)"

    local params = {

        ["@id"] = lic,

        ["@reason"] = tostring(reason),

        ["@exp"] = (Config.BanDurationHours and Config.BanDurationHours > 0) and (os.time() + (Config.BanDurationHours * 3600)) or 0

    }

    if exports["oxmysql"] then

        exports["oxmysql"]:execute(query, params)

    elseif MySQL and MySQL.Async then

        MySQL.Async.execute(query, params)

    end

end

local function Punish(src, reason)

    if Config.ActionOnViolation == "ban" then

        BanDB(src, Config.BanReasonDB or "AFK_FoxGScript ban")

        DropPlayer(src, "[BANNED] " .. tostring(reason))

    else

        DropPlayer(src, tostring(reason))

    end

end

local function StartPending(src, kind)

    local generatedToken = Token()

    Pending[src] = { token = generatedToken, created = Now(), kind = kind }

    TriggerClientEvent("afk_foxg:challenge", src, generatedToken, kind == "pre")

end

AddStateBagChangeHandler("afkfoxg_ready", nil, function(bagName, _, value)

    if not value then return end

    local src = tonumber(bagName:gsub("player:", ""), 10)

    if not src then return end

    if not Connecting[src] then return end

    if Pending[src] then return end

    StartPending(src, "pre")

end)

AddEventHandler("playerConnecting", function(_, _, deferrals)

    local src = source

    ClearPlayer(src)

    Connecting[src] = { deferrals = deferrals, startedAt = Now() }

    deferrals.defer()

    Wait(0)

    local start = Now()

    local hardTimeout = tonumber(Config.PreLoadHardTimeoutMs) or 25000

    while true do

        if not Connecting[src] then return end

        if Sessions[src] and Sessions[src].verified then

            deferrals.done()

            Connecting[src] = nil

            return

        end

        deferrals.update("[AFK-FoxG] Dar hale check FoxG... lotfan sabr konid")

        Wait(350)

        if (Now() - start) > hardTimeout then

            DiscordLog(src, "Pre-load check timeout (ready/reply naresid).", 16744448)

            deferrals.done(Config.Messages.dropHandshakeFail or "Handshake fail")

            ClearPlayer(src)

            return

        end

    end

end)

RegisterNetEvent("afk_foxg:replyPreAuth", function(token, isAlive, isTampered)

    local src = source

    local p = Pending[src]

    if not p or p.kind ~= "pre" or p.token ~= token then

        DiscordLog(src, "Pre-auth token mismatch.", 16711680)

        Punish(src, Config.Messages.dropHandshakeFail or "Handshake fail")

        ClearPlayer(src)

        return

    end

    Pending[src] = nil

    if isTampered then

        DiscordLog(src, "Tamper/Hook in pre-auth.", 16711680)

        Punish(src, Config.Messages.dropTamper or "Tamper detected")

        ClearPlayer(src)

        return

    end

    if isAlive ~= true then

        if Config.BypassAdmins and IsAdmin(src) then

            Sessions[src] = { verified = true, lastOk = Now(), joinedAt = Now(), inFlightToken = nil }

            return

        end

        DiscordLog(src, "FoxG not alive on connect.", 16744448)

        Punish(src, Config.Messages.dropFoxDead or "FoxG not alive")

        ClearPlayer(src)

        return

    end

    Sessions[src] = { verified = true, lastOk = Now(), joinedAt = Now(), inFlightToken = nil }

end)

RegisterNetEvent("afk_foxg:replyChallenge", function(token, isAlive, isTampered)

    local src = source

    local s = Sessions[src]

    if not s or not s.verified or s.inFlightToken ~= token then

        DiscordLog(src, "Heartbeat token mismatch.", 16711680)

        Punish(src, Config.Messages.dropHandshakeFail or "Handshake fail")

        ClearPlayer(src)

        return

    end

    s.inFlightToken = nil

    if isTampered then

        DiscordLog(src, "Tamper/Hook in session.", 16711680)

        Punish(src, Config.Messages.dropTamper or "Tamper detected")

        ClearPlayer(src)

        return

    end

    if isAlive ~= true then

        DiscordLog(src, "FoxG went dead (grace).", 16711680)

        TriggerClientEvent("afk_foxg:quarantine", src)

        local grace = tonumber(Config.GracePeriodBeforeKick) or 8000

        SetTimeout(grace, function()

            if GetPlayerPing(src) > 0 then

                Punish(src, Config.Messages.dropFoxDead or "FoxG not alive")

                ClearPlayer(src)

            end

        end)

        return

    end

    s.lastOk = Now()

end)

CreateThread(function()

    local checkInterval = tonumber(Config.CheckInterval) or 12000

    local responseTimeout = tonumber(Config.ResponseTimeout) or 7000

    local immunity = tonumber(Config.InitialImmunityTime) or 10000

    while true do

        Wait(checkInterval)

        local now = Now()

        for src, p in pairs(Pending) do

            if (now - p.created) > responseTimeout then

                DiscordLog(src, "Pre-auth timeout.", 16744448)

                Punish(src, Config.Messages.dropHandshakeFail or "Handshake timeout")

                ClearPlayer(src)

            end

        end

        for src, s in pairs(Sessions) do

            if GetPlayerPing(src) > 0 then

                if s.inFlightToken then

                    if (now - (s.lastOk or now)) > responseTimeout then

                        DiscordLog(src, "Heartbeat timeout (no reply).", 16711680)

                        Punish(src, Config.Messages.dropTimeout or "Heartbeat timeout")

                        ClearPlayer(src)

                    end

                else

                    local isImmune = (now - (s.joinedAt or now)) < immunity

                    if (not isImmune) and (now - (s.lastOk or now)) > responseTimeout then

                        DiscordLog(src, "Heartbeat stale.", 16711680)

                        Punish(src, Config.Messages.dropTimeout or "Heartbeat timeout")

                        ClearPlayer(src)

                    else

                        local heartbeatToken = Token()

                        s.inFlightToken = heartbeatToken

                        TriggerClientEvent("afk_foxg:challenge", src, heartbeatToken, false)

                    end

                end

            end

        end

    end

end)

RegisterCommand("foxcheck", function(src, args)

    if src ~= 0 and not IsAdmin(src) then return end

    local target = tonumber(args[1] or "")

    if not target or not GetPlayerName(target) then

        local tip = "Format: /foxcheck [ID]"

        if src == 0 then print(tip) else TriggerClientEvent("chat:addMessage", src, { args = { "[FoxG]", tip } }) end

        return

    end

    local ok = Sessions[target] and Sessions[target].verified

    local msg = string.format("[FoxG] ID %d (%s): %s", target, GetPlayerName(target), ok and "^2ACTIVE^0" or "^1NOT VERIFIED^0")

    if src == 0 then print(msg) else TriggerClientEvent("chat:addMessage", src, { args = { "[FoxG]", msg } }) end

end, false)

RegisterCommand("foxstats", function(src)

    if src ~= 0 and not IsAdmin(src) then return end

    local c = 0

    for _, s in pairs(Sessions) do if s and s.verified then c = c + 1 end end

    local msg = string.format("[FoxG] Verified online: %d", c)

    if src == 0 then print(msg) else TriggerClientEvent("chat:addMessage", src, { args = { "[FoxG]", msg } }) end

end, false)

AddEventHandler("playerDropped", function()

    ClearPlayer(source)

end)
