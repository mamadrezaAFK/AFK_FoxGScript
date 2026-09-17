Config = {}

-- =======================================================================
--                        1. FRAMEWORK & PERMISSIONS
-- =======================================================================

-- Faal ya gheyre-faal kardane dastresi be Framework ESX
Config.UseESX = true

-- Gorooh haye admini dar ESX jadid (Group checking)
Config.AdminGroups = { 
    'admin',
    'superadmin'
} 

-- Level haye dastresi admini dar ESX ghadimi (permission_level)
Config.AdminPermissions = { 
    20, 
    21 
}

-- Aya admin ha az check shodan va kick/ban shodane FoxG moaf bashand?
Config.BypassAdmins = false


-- =======================================================================
--                        2. DISCORD & WEBHOOK LOGS
-- =======================================================================

-- Link webhook discord baraye ersale log haye takhalof
Config.DiscordWebhook = "GAPGPTMASKTOKENmwuz3aokpnX0X"

-- Name server baraye footer log ha
Config.ServerName = "AFK FoxG Script"

-- Name bot va avatar baraye ersale log dar Discord
Config.BotName = "AFK FoxG Script"
Config.BotAvatar = "https://s25.uupload.ir/files/afkmamadreza/IMG_20260513_123211_379.jpg"


-- =======================================================================
--                        3. PUNISHMENT SYSTEM
-- =======================================================================

-- Noe barkhord ba motekhallef: 'kick' ya 'ban'
Config.ActionOnViolation = "kick"

-- Modat zamane ban shodan be saat (0 = Permanent / Hameishegi)
Config.BanDurationHours = 0

-- Dalile sabt shode dar Database baraye banlist
Config.BanReasonDB = "Estefade az Cheats / Bypassing FoxG Launcher Protection"


-- =======================================================================
--                        4. TIMERS & THRESHOLDS (ms)
-- =======================================================================

-- Fasele zamani beyne har bar estelam va check kardane vaziat az client (Milisanise)
Config.CheckInterval = 7500

-- Hedeaksar zaman baraye daryafte javabe Challenge az client ghabl az timeout (Milisanise)
Config.ResponseTimeout = 14000

-- Zamane forsat (Grace period) bad az ghati launcher ghabl az kick ghatie bazikon (Milisanise)
Config.GracePeriodBeforeKick = 3500

-- Zamane amniati avalie bad az connect shodan bazikon baraye jologiri az kick eshtebahi (Milisanise)
Config.InitialImmunityTime = 12000

-- Timeout baraye marhale loading screen va playerConnecting (Milisanise)
Config.PreLoadHardTimeoutMs = 25000


-- =======================================================================
--                        5. BROADCAST & ANNOUNCEMENTS
-- =======================================================================

-- Eslam omoumi dar chat baraye hame bazikonan hengame barkhord
Config.GlobalAnnounce = true

-- Matne elam omoumi dar chat (%s = Name bazikon)
Config.AnnounceMessage = "^1[AFK-FoxG]^0 Bazikon ^3%s^0 be dalil adam vojood ya baste shodan FoxG Launcher az server kick/ban shod."


-- =======================================================================
--                        6. SYSTEM NOTIFICATIONS & DROP MESSAGES
-- =======================================================================

Config.Messages = {
    -- Payam dar chat be bazikon hengame ghati launcher
    chatWarning = "^1[AFK-FoxG]^0 FoxG Launcher shoma ghat shod! Dar hale khorooj az server...",

    -- Khata dar marhale ghabl az vorood (Pre-auth / Handshake failed)
    dropHandshakeFail = "[AFK-FoxG] Etebar sanji avalie ba Launcher FoxG movafagh nabood.",

    -- Baste shodan ya baz naboodane narm afzare launcher
    dropFoxDead = "[AFK-FoxG] Barname FoxG dar system shoma baz nist ya baste shode ast.",
    
    -- Adam daryafte pasokh dar mohlate tayin shode
    dropTimeout = "[AFK-FoxG] Ertebat ba application FoxG Launcher ghat shod (Timeout).",

    -- Dastkari memory, hook kardane function ha ya talash baraye bypass
    dropTamper = "[AFK-FoxG] Dastkari dar memory ya hook kardan tavabe shenasaee shod."
}
