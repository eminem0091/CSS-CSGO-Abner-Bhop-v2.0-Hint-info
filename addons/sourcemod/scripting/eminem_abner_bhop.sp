#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#pragma newdecls required // 2015 rules 
#define PLUGIN_VERSION "2.0"

Handle hBhop;
Handle hAutoBhop;
bool CSGO;
int WATER_LIMIT;

public Plugin myinfo =
{
	name = "[CSS/CS:GO] AbNeR Bunny Hoping",
	author = "AbNeR_CSS",
	description = "Auto BHOP, MR. EMINEM",
	version = PLUGIN_VERSION,
	url = "www.tecnohardclan.com"
}

public void OnPluginStart()
{       
	//Load translation
	LoadTranslations("autobhop.phrases");

	AutoExecConfig(true, "abnerbhop");
	CreateConVar("abnerbhop_version", PLUGIN_VERSION, "Bhop Version", FCVAR_NOTIFY|FCVAR_REPLICATED);
	hBhop 						= CreateConVar("abner_bhop", "1", "Enable/disable Plugin", FCVAR_NOTIFY|FCVAR_REPLICATED);
	hAutoBhop 					= CreateConVar("abner_autobhop", "0", "Enable/Disable AutoBhop", FCVAR_NOTIFY|FCVAR_REPLICATED);
	
	HookEvent("round_start",Event_RoundStart, EventHookMode_PostNoCopy);
	
	char theFolder[40];
	GetGameFolderName(theFolder, sizeof(theFolder));
	CSGO = StrEqual(theFolder, "csgo");
	(CSGO) ? (WATER_LIMIT = 2) : (WATER_LIMIT = 1);
}

public void OnConfigsExecuted()
{
	if(GetConVarInt(hBhop) == 1) BhopOn();
}

public void OnClientPutInServer(int client)
{
	if(!CSGO) // To boost in CSGO use together https://forums.alliedmods.net/showthread.php?t=244387
		SDKHook(client, SDKHook_PreThink, PreThink); //This make you fly in CSS;	
}

//=============================================================================================================================================================================================

public Action Event_RoundStart(Handle hEvent, const char[] sName, bool bDontBroadcast)
{
    CreateTimer(3.0, bhop_msg_info);
}
 
public Action bhop_msg_info(Handle timer, any client)
{
    if(GetConVarInt(hAutoBhop) == 1)
    {
        PrintHintTextToAll("%t", "autobhop_aktivni");
    }
    else if(GetConVarInt(hAutoBhop) == 0)
    {
        PrintHintTextToAll("%t", "autobhop_neaktivni");
    }
}

//=============================================================================================================================================================================================

public Action PreThink(int client)
{
	if(IsValidClient(client) && IsPlayerAlive(client) && GetConVarInt(hBhop) == 1)
	{
		SetEntPropFloat(client, Prop_Send, "m_flStamina", 0.0); 
	}
}

void BhopOn()
{
	if(!CSGO)
	{
		SetCvar("sv_enablebunnyhopping", "1");
		SetCvar("sv_airaccelerate", "2000");
	}
	else 
	{
		SetCvar("sv_enablebunnyhopping", "1"); 
		SetCvar("sv_staminamax", "0");
		SetCvar("sv_airaccelerate", "2000");
		SetCvar("sv_staminajumpcost", "0");
		SetCvar("sv_staminalandcost", "0");
	}
}

stock void SetCvar(char[] scvar, char[] svalue)
{
	Handle cvar = FindConVar(scvar);
	SetConVarString(cvar, svalue, true);
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	if(GetConVarInt(hBhop) == 1 && GetConVarInt(hAutoBhop) == 1) //Check if plugin and autobhop is enabled
		if (IsPlayerAlive(client) && buttons & IN_JUMP) //Check if player is alive and is in pressing space
			if(!(GetEntityMoveType(client) & MOVETYPE_LADDER) && !(GetEntityFlags(client) & FL_ONGROUND)) //Check if is not in ladder and is in air
				if(waterCheck(client) < WATER_LIMIT)
					buttons &= ~IN_JUMP; 
	return Plugin_Continue;
}

int waterCheck(int client)
{
	return GetEntProp(client, Prop_Data, "m_nWaterLevel");
}

stock bool IsValidClient(int client)
{
	if(client <= 0 ) return false;
	if(client > MaxClients) return false;
	if(!IsClientConnected(client)) return false;
	return IsClientInGame(client);
}





