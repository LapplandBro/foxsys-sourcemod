#pragma semicolon 1
#pragma newdecls optional

#include <sourcemod>
#include <sdktools>
#include <morecolors>

#define PLUGIN_VERSION "1.14"

new bool:pSpawnSet[MAXPLAYERS+1];
new Float:pSpawn[MAXPLAYERS+1][3];

new Handle:cEnabled;

public Plugin:myinfo = 
{
	name = "[TF2] Admin SetSpawn",
	author = "Lappland Saluzzo",
	description = "Setting shop Player Spawn",
	version = PLUGIN_VERSION,
	url = "http://www.lurolona.su"
}

public OnPluginStart() {
	RegAdminCmd("sm_setspawn", Command_Setplayerspawn, ADMFLAG_ROOT);
	RegAdminCmd("sm_clearspawn", Command_Clearplayerspawn, ADMFLAG_ROOT);
	CreateConVar("sm_playerspawns_version", PLUGIN_VERSION, "Player Spawns plugin version", FCVAR_NOTIFY);
	cEnabled = CreateConVar("sm_playerspawns_enable", "1", "Enables plugin");
	HookConVarChange(cEnabled, Cvar_Toggle);
	HookEvent("player_spawn", Event_Spawn);
	HookEvent("player_team", Event_TeamsChange);
}

public Cvar_Toggle(Handle:cvar, const String:oldVal[], const String:newVal[]) {
	if(StringToInt(newVal) == 0)
	{
		for(new i=1; i <= MaxClients; i++)
		{
			pSpawnSet[i] = false;
		}
	}
}

public OnClientPostAdminCheck(client) {
	pSpawnSet[client] = false;
}

public Action:Command_Setplayerspawn(client, args) {
	if(GetConVarBool(cEnabled))
	{
		if(args != 1)
		{
			MC_ReplyToCommand(client, "{GREEN}[{LIGHTGREEN}SetSpawn{GREEN}]{DEFAULT} Использование: sm_setspawn <ID/Никнейм/@Операнды>");
			return Plugin_Handled;
		}
		decl String:arg[64];
		GetCmdArg(1, arg, sizeof(arg));
		decl String:target_name[MAX_TARGET_LENGTH];
		decl target_list[MAXPLAYERS], target_count, bool:tn_is_ml;
		if((target_count = ProcessTargetString(
				arg,
				client, 
				target_list, 
				MAXPLAYERS, 
				0,
				target_name,
				sizeof(target_name),
				tn_is_ml)) <= 0)
			{
				ReplyToTargetError(client, target_count);
				return Plugin_Handled;
			}
		for(new i = 0; i < target_count; i++) {
				GetClientAbsOrigin(client, pSpawn[target_list[i]]);
				pSpawnSet[target_list[i]] = true;
			}
		if(tn_is_ml)
			MC_ShowActivity2(client, "{GREEN}[{LIGHTGREEN}SetSpawn{GREEN}]{DEFAULT} ", "Точка возрождения игрока {LIGHTGREEN}%s{DEFAULT} установлена.", target_name);
		else
			MC_ShowActivity2(client, "{GREEN}[{LIGHTGREEN}SetSpawn{GREEN}]{DEFAULT} ", "Точка возрождения игрока {LIGHTGREEN}%s{DEFAULT} установлена.", target_name);
	}
	return Plugin_Handled;	
}

public Action:Command_Clearplayerspawn(client, args) {
	if(GetConVarBool(cEnabled))
	{
		if(args != 1)
		{
			MC_ReplyToCommand(client, "{GREEN}[{LIGHTGREEN}SetSpawn{GREEN}]{DEFAULT} Использование: sm_setspawn <ID/Никнейм/@Операнды>");
			return Plugin_Handled;
		}
		decl String:arg[64];
		GetCmdArg(1, arg, sizeof(arg));
		decl String:target_name[MAX_TARGET_LENGTH];
		decl target_list[MAXPLAYERS], target_count, bool:tn_is_ml;
		if((target_count = ProcessTargetString(
				arg,
				client, 
				target_list, 
				MAXPLAYERS, 
				0,
				target_name,
				sizeof(target_name),
				tn_is_ml)) <= 0)
		{
			ReplyToTargetError(client, target_count);
			return Plugin_Handled;
		}
		for(new i = 0; i < target_count; i++)
			pSpawnSet[target_list[i]] = false;
		if(tn_is_ml)
			MC_ShowActivity2(client, "{GREEN}[{LIGHTGREEN}SetSpawn{GREEN}]{DEFAULT} ", "Точка возрождения игрока {LIGHTGREEN}%s{DEFAULT} очищена.", target_name);
		else
			MC_ShowActivity2(client, "{GREEN}[{LIGHTGREEN}SetSpawn{GREEN}]{DEFAULT} ", "Точка возрождения игрока {LIGHTGREEN}%s{DEFAULT} очищена.", target_name);
	}
	return Plugin_Handled;	
}

public Action:Event_Spawn(Handle:event, const String:name[], bool:dontBroadcast) {
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(pSpawnSet[client])
		CreateTimer(0.1, Timer_Spawn, GetClientUserId(client));
}

public Action:Event_TeamsChange(Handle:event, const String:name[], bool:dontBroadcast) {
	if(GetConVarBool(cEnabled))
		{
		new client = GetClientOfUserId(GetEventInt(event, "userid"));
		if (client >= 1)
			{
				pSpawnSet[client] = false;
				MC_PrintToChat(client, "{GREEN}[{LIGHTGREEN}SetSpawn{GREEN}]{DEFAULT} Точка возрождения сброшена.");
			}
		}
	return Plugin_Continue;
}

public Action:Timer_Spawn(Handle:timer, any:userid) {
	new client = GetClientOfUserId(userid);
	if (client >= 1)
	TeleportEntity(client, pSpawn[client], NULL_VECTOR, NULL_VECTOR);
} 