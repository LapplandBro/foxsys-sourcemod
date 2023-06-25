#pragma semicolon 1
#pragma newdecls optional

#include <sourcemod>
#include <sdktools>
#include <clientprefs>
#include <tf2>
#include <morecolors>

#define PLUGIN_VERSION	"1.3.6"

new Handle:clientcookie = INVALID_HANDLE;

new bool:g_bEnabled;
new bool:thirdperson[MAXPLAYERS + 1];
new bool:storecookies[MAXPLAYERS + 1];                              // Saving flag.
new bool:hooked;

public Plugin:myinfo =
{
	name = "[TF2] Third Person Cookies!",
	author = "Friagram, Lappland Saluzzo",
	description = "Provides Third Person",
	version = PLUGIN_VERSION,
	url = "https://lurolona.su"
};

public OnPluginStart() {
	CreateConVar("sm_tpcookie_version", PLUGIN_VERSION, "TF2 Thirdperson Cookies Version", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);

	new Handle:hCvarEnabled;
	HookConVarChange(hCvarEnabled = CreateConVar("sm_tpcookie_enabled", "1.0", "Enable/Disable Plugin [0/1]", FCVAR_REPLICATED, true, 0.0, true, 1.0), ConVarEnabledChanged);
	g_bEnabled = GetConVarBool(hCvarEnabled);
	
	RegConsoleCmd("sm_thirdperson", Command_TpOn, "Usage: sm_thirdperson");
	RegConsoleCmd("tp", Command_TpOn, "Usage: sm_thirdperson");
	RegConsoleCmd("sm_firstperson", Command_TpOff, "Usage: sm_firstperson");
	RegConsoleCmd("fp", Command_TpOff, "Usage: sm_firstperson");

	clientcookie = RegClientCookie("tp_cookie", "", CookieAccess_Private);
	
	LoadTranslations("common.phrases");
	LoadTranslations("core.phrases");
}

public OnMapStart() {
	if (g_bEnabled && !hooked)
	{
		PrintToServer("[TF2] TPC: Enabled");
		HookEvent("player_spawn", player_spawn);
		HookEvent("player_class", player_spawn);
		hooked = true;
	}
}

public ConVarEnabledChanged(Handle:convar, const String:oldvalue[], const String:newvalue[]) {
	g_bEnabled = (StringToInt(newvalue) == 0 ? false : true);
	
	if (g_bEnabled && !hooked)
	{
		PrintToServer("[TF2] TPC: Enabled");
		HookEvent("player_spawn", player_spawn);
		HookEvent("player_class", player_spawn);
		hooked = true;
	}
	else if (!g_bEnabled && hooked)
	{
		PrintToServer("[TF2] TPC: Disabled");
		UnhookEvent("player_spawn", player_spawn);
		UnhookEvent("player_class", player_spawn);
		hooked = false;

		for (new i=1; i<=MaxClients; i++)
		{
			if (IsClientInGame(i) && IsPlayerAlive(i))         // End everyone's third person
			{
				SetVariantInt(0);
				AcceptEntityInput(i, "SetForcedTauntCam");
			}  
		}
	}
}

public OnPluginEnd() {
	for (new i=1; i<=MaxClients; i++)
	{
		if (IsClientInGame(i) && IsPlayerAlive(i))
		{
			SetVariantInt(0);
			AcceptEntityInput(i, "SetForcedTauntCam");
		}
	}
}

public OnClientCookiesCached(client) {
	if (!IsFakeClient(client))
	{
		retrieveClientCookies(client);
	}
}

retrieveClientCookies(client) {
	decl String:cookie[2];

	GetClientCookie(client, clientcookie, cookie, 2);

	if (!strlen(cookie))                                        // They're new, fix them
	{
		SetClientCookie(client, clientcookie, "0");
		thirdperson[client] = false;
	}
	else
	{
		thirdperson[client] = (StringToInt(cookie) == 0 ? false : true);
	}
}

public OnClientPutInServer(client) {
	storecookies[client] = false;
}

public OnClientDisconnect(client) {
	if(storecookies[client])
	{
		storeClientCookies(client);
	}
}

storeClientCookies(client) {
	if(AreClientCookiesCached(client))                                               // make sure DB isn't being slow
	{
		decl String:cookie[2];

		IntToString(thirdperson[client], cookie, 2);
		SetClientCookie(client, clientcookie, cookie);

		storecookies[client] = false;
	}
}

public Action:player_spawn(Handle:event, const String:name[], bool:dontBroadcast) {
	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	if(!IsFakeClient(client))												// ignore bots, they don't need client pref entries
	{
		if (storecookies[client])											// they made some changes to their cookies earlier, let's go ahead and handle that now.
		{
			storeClientCookies(client);
		}

		if (thirdperson[client])
		{
			CreateTimer(0.1, Timer_EnableFp, GetClientUserId(client));			// Fixes a bug where sometimes you get stuck in first person, by forcing this mode.
		}
	}
}

public Action:Timer_EnableFp(Handle:timer, any:userid) {
	new client = GetClientOfUserId(userid);
	if (client && IsClientInGame(client) && IsPlayerAlive(client))				// Perhaps their ent could take the input if they are dead.
	{
		SetVariantInt(0);													// Enable TP camera
		AcceptEntityInput(client, "SetForcedTauntCam");
		CreateTimer(0.2, Timer_EnableTp, userid);								// Because sometimes, delay
	}
}

public Action:Timer_EnableTp(Handle:timer, any:userid) {
	new client = GetClientOfUserId(userid);
	if (client && IsClientInGame(client) && IsPlayerAlive(client))				// Perhaps their ent could take the input if they are dead.
	{
		SetVariantInt(1);													// Enable TP camera
		AcceptEntityInput(client, "SetForcedTauntCam");
	}
}

public Action:Command_TpOn(client, args) {
	if (!IsClientInGame(client))
	{
		return Plugin_Handled;
	}
	if (!CheckCommandAccess(client,"sm_thirdperson", 0))
	{
		MC_ReplyToCommand(client, "{GREEN}[{LIGHTGREEN}Third Person{GREEN}]{DEFAULT} %t.", "No Access");
		
		return Plugin_Handled;
	}
	if (!g_bEnabled)
	{
		MC_ReplyToCommand(client, "{GREEN}[{LIGHTGREEN}Third Person{GREEN}]{DEFAULT} Функционал сейчас выключен, извините за неудобства!");

		return Plugin_Handled;
	}
	if (IsPlayerAlive(client))                                                       // If they arn't alive, they won't have the cam set, it'll spam.
	{
		if (!GetEntProp(client, Prop_Send, "m_nForceTauntCam"))                  // Spaaaaaaam
		{
			MC_PrintToChat(client, "{GREEN}[{LIGHTGREEN}Third Person{GREEN}]{DEFAULT} Третье лицо - {LIGHTGREEN}%t{DEFAULT}. Для возврата - {LIGHTGREEN}!fp","On");
		}
		SetVariantInt(1);
		AcceptEntityInput(client, "SetForcedTauntCam");
	}

	thirdperson[client] = true;
	storecookies[client] = true;                                                     // Queue a save

	return Plugin_Handled;
}

public Action:Command_TpOff(client, args) {
	if (!IsClientInGame(client))
	{
		PrintToServer("Third Person: Set TP not allowed with console.");
		return Plugin_Handled;
	}
	if (!CheckCommandAccess(client,"sm_thirdperson", 0))
	{
		MC_ReplyToCommand(client, "{GREEN}[{LIGHTGREEN}Third Person{GREEN}]{DEFAULT} %t.", "No Access");

		return Plugin_Handled;
	}
	if (!g_bEnabled)
	{
		MC_ReplyToCommand(client, "{GREEN}[{LIGHTGREEN}Third Person{GREEN}]{DEFAULT} Функционал сейчас выключен, извините за неудобства!");

		return Plugin_Handled;
	}
	if (IsPlayerAlive(client))
	{
		if (GetEntProp(client, Prop_Send, "m_nForceTauntCam"))                   // Check if it's set here, else spam
		{
			MC_PrintToChat(client, "{GREEN}[{LIGHTGREEN}Third Person{GREEN}]{DEFAULT} Третье лицо - {RED}%t{DEFAULT}.","Off");
		}
		SetVariantInt(0);
		AcceptEntityInput(client, "SetForcedTauntCam");
	}

	thirdperson[client] = false;                                                     // Set it anyways, because they want us to
	storecookies[client] = true;

	return Plugin_Handled;
}

public TF2_OnConditionAdded(client, TFCond:condition) {
	if(g_bEnabled && condition == TFCond_Zoomed && thirdperson[client] && IsPlayerAlive(client))
	{
		SetVariantInt(0);
		AcceptEntityInput(client, "SetForcedTauntCam");
	}
}

public TF2_OnConditionRemoved(client, TFCond:condition) {
	if(g_bEnabled && condition == TFCond_Zoomed && thirdperson[client] && IsPlayerAlive(client))
	{
		SetVariantInt(1);
		AcceptEntityInput(client, "SetForcedTauntCam");
	}
}