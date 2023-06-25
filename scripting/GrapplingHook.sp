#pragma semicolon 1

#define PLUGIN_VERSION "1.1.04"

#include <sourcemod>
#include <morecolors>

new Handle:g_Cvar_GrapplingHook;

public Plugin:myinfo = {
	name = "[TF2] GrapplingHook Toggler",
	author = "Lappland Saluzzo",
	description = "Toggles the Grappling Hook Cvar",
	version = PLUGIN_VERSION,
	url = "https://www.lurolona.su"
};

public OnPluginStart() { 
	RegAdminCmd("sm_grapplingHook", Command_GrapplingHookToggle, ADMFLAG_GENERIC, "Toggles the Grappling Hook ConVar");
	RegAdminCmd("sm_grapple", Command_GrapplingHookToggle, ADMFLAG_GENERIC, "Toggles the Grappling Hook ConVar");
	RegAdminCmd("sm_ghook", Command_GrapplingHookToggle, ADMFLAG_GENERIC, "Toggles the Grappling Hook ConVar");
	
	g_Cvar_GrapplingHook = FindConVar("tf_grapplinghook_enable");
}

public Action:Command_GrapplingHookToggle(client, args) {
	SetConVarBool(g_Cvar_GrapplingHook, !GetConVarBool(g_Cvar_GrapplingHook));
	CPrintToChatAll("{OLIVE}[GrapplingHook]{DEFAULT} Абордажный крюк был %s", GetConVarBool(g_Cvar_GrapplingHook) ? "{green}включен{default}" : "{red}отключен{default}");
	return Plugin_Handled;
}