/////////////////////////////////////////////
// Ammo amount extender and regenerator
//  ver 1.0.0
/////////////////////////////////////////////

CScheduledFunction@ g_pRegeneTimer = null;
const float INTERVAL = 1.0;

const int AMMO_PREFIX    = 0;
const int AMMO_NAME      = 1;
const int AMMO_THROWTYPE = 2;

const string TYPE_NOT_THROW = "";
const string TYPE_THROW     = "*";

// Ammo type array
// [0] Cvar prefix name. this is for XXX_interval, XXX_regene, and XXX_max.
// [1] Ammo type name. this is using at GiveAmmo command.
// [2] Throw type. like grenade, or not.
const string[][] g_ammoType = {
    {"9mm"        , "9mm"           , TYPE_NOT_THROW },
    {"buckshot"   , "buckshot"      , TYPE_NOT_THROW },
    {"357"        , "357"           , TYPE_NOT_THROW },
    {"crossbow"   , "bolts"         , TYPE_NOT_THROW },
    {"556"        , "556"           , TYPE_NOT_THROW },
    {"argrenade"  , "ARgrenades"    , TYPE_NOT_THROW },
    {"rpgclip"    , "rockets"       , TYPE_NOT_THROW },
    {"gaussclip"  , "uranium"       , TYPE_NOT_THROW },
    {"handgrenade", "Hand Grenade"  , TYPE_THROW     },
    {"satchel"    , "Satchel Charge", TYPE_THROW     },
    {"hornet"     , "Hornets"       , TYPE_NOT_THROW },
    {"tripmine"   , "Trip Mine"     , TYPE_THROW     },
    {"snark"      , "Snarks"        , TYPE_THROW     },
    {"762"        , "m40a1"         , TYPE_NOT_THROW },
    {"sporeclip"  , "sporeclip"     , TYPE_NOT_THROW },
    {"medikit"    , "health"        , TYPE_NOT_THROW }
};

// Ammo Infomation
class CAmmoInfo {
    int count;        // Current timer count
    CCVar@ pInterval; // Timer Interval
    CCVar@ pRegene;   // Regeneration ammo amount
    CCVar@ pMax;      // Max ammo amount
    
    CAmmoInfo() {
        count = 0;
    }
};

array<CAmmoInfo> g_ammoInfo(g_ammoType.length());

/** Plugin Init */
void PluginInit() {
    // ....(^^;)b yay
    g_Module.ScriptInfo.SetAuthor("takedeppo.50cal");
    g_Module.ScriptInfo.SetContactInfo("http://steamcommunity.com/id/takedeppo");

    // Cvar (set with prefix)
    for (uint i = 0; i < g_ammoType.length(); i++) {
        SetAmmoParameter(i,  g_ammoType[i][AMMO_PREFIX]);
    }
    
    // Event hook
    g_Hooks.RegisterHook(Hooks::Player::PlayerSpawn, @PlayerSpawn);

    // Timer
    if (g_pRegeneTimer !is null) {
        g_Scheduler.RemoveTimer(g_pRegeneTimer);
    }
    @g_pRegeneTimer = g_Scheduler.SetInterval("AmmoRegeneTimer", INTERVAL);
}

/** Set Cvar Paramater */
void SetAmmoParameter(uint &in index, string &in prefix) {
    // Cvar
    @g_ammoInfo[index].pInterval = CCVar(prefix + "_interval", 0, prefix + " ammo regeneration interval [seconds]", ConCommandFlag::AdminOnly);
    @g_ammoInfo[index].pRegene   = CCVar(prefix + "_regene",   0, prefix + " ammo regeneration amount [number]",    ConCommandFlag::AdminOnly);
    @g_ammoInfo[index].pMax      = CCVar(prefix + "_max",      0, prefix + " ammo max amount [number]",             ConCommandFlag::AdminOnly);
}

/** Player Spawn */
HookReturnCode PlayerSpawn(CBasePlayer@ pPlayer) {
    for (uint i = 0; i < g_ammoType.length(); i++) {
        bool isEnabled = (g_ammoInfo[i].pMax.GetInt() > 0);
        if (isEnabled) {
            pPlayer.SetMaxAmmo(g_ammoType[i][AMMO_NAME], g_ammoInfo[i].pMax.GetInt());
        }
    }
    return HOOK_CONTINUE;
}

/** Ammo regeneration timer function*/
void AmmoRegeneTimer() {
    const int MAX = 2147483647; // 2^31 max of signed int
    
    // each ammo type
    for (uint i = 0; i < g_ammoType.length(); i++) {
        // if setting(=both interval and regeneration amount) is enabled, provide ammo.
        if ((g_ammoInfo[i].pInterval.GetInt() > 0) && (g_ammoInfo[i].pRegene.GetInt() > 0)) {
            
            if (g_ammoInfo[i].count >= g_ammoInfo[i].pInterval.GetInt()) {
                g_ammoInfo[i].count = 0;
                
                bool fromWeapon = (g_ammoType[i][AMMO_THROWTYPE] == TYPE_NOT_THROW);
                // give each player
                for (int j = 1; j <= g_Engine.maxClients; j++) {
                    CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(j);
                    if ((pPlayer !is null) && (pPlayer.IsConnected()) && (pPlayer.IsAlive())) {
                        pPlayer.GiveAmmo(g_ammoInfo[i].pRegene.GetInt(), g_ammoType[i][AMMO_NAME], MAX, fromWeapon);
                    }
                }
            } else {
                g_ammoInfo[i].count++;
            }
        }
    }
}
