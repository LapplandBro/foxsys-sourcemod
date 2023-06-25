#pragma newdecls optional

#include <sourcemod>
#include <sdktools>
#include <morecolors>

new Float:posData[MAXPLAYERS+1][3];
new Float:angData[MAXPLAYERS+1][3];
new Float:velData[MAXPLAYERS+1][3];

public Plugin:myinfo = {
	name = "[TF2] Admin SaveLocation",
	author = "Lappland Saluzzo",
	description = "Save admin spawn location.",
	version = "1.1.0.1",
	url = "https://lurolona.su"
};

public OnPluginStart() {
	RegAdminCmd("sm_saveloc", Command_SaveLoc, ADMFLAG_ROOT);
	RegAdminCmd("sm_teleport", Command_Teleport, ADMFLAG_ROOT);
}

public OnMapEnd() {
	//reset each client locations
	for(new i = 1; i<=MAXPLAYERS; i++)
	{
		resetData(i);
	}
}

public Action:Command_SaveLoc(client, args) {
	//check if player is alive
	if(client>0&&IsPlayerAlive(client))
	{
		GetClientAbsOrigin(client, posData[client]);//save position
		GetClientEyeAngles(client, angData[client]);//save angles
		GetClientVelocity(client, velData[client]);//save velocity - internal
		
		MC_PrintToChat(client, "{GREEN}[{LIGHTGREEN}SaveLoc{GREEN}]{DEFAULT} Сохранение точки возрождения успешно.");
	}
	else//print out error and exit
	{
		MC_PrintToChat(client, "{GREEN}[{LIGHTGREEN}SaveLoc{GREEN}]{DEFAULT} Вы должны быть живым, чтобы использовать сохранение точки.");
	}
	return Plugin_Handled;
}

public Action:Command_Teleport(client, args) {
	//check if player is alive
	if(client>0&&IsPlayerAlive(client))
	{
		//check if any location was saved
		if((GetVectorDistance(posData[client],NULL_VECTOR) > 0.00)&&
		   (GetVectorDistance(angData[client],NULL_VECTOR) > 0.00))
		{
			new Float:vel[3];
			TeleportEntity(client, posData[client], angData[client], velData[client]);
			GetClientVelocity(client,vel);
			
			//debug
			//PrintToConsole(client, "tele vel: %f, %f, %f", vel[0],vel[1],vel[2]);
		}
			else//print error and exit
		{
			MC_PrintToChat(client, "{GREEN}[{LIGHTGREEN}SaveLoc{GREEN}]{DEFAULT} Сохраненной позиции не обнаружено.");
		}
	}
		else	//print error and exit
	{
		MC_PrintToChat(client, "{GREEN}[{LIGHTGREEN}SaveLoc{GREEN}]{DEFAULT} Вы должны быть живым, чтобы использовать сохранение точки.");
	}
	return Plugin_Handled;
}

GetClientVelocity(client, Float:vel[3])
{
	//dig into the entity properties for the client
	vel[0] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[0]");
	vel[1] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[1]");
	vel[2] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[2]");
}

resetData(client)
{
	posData[client] = NULL_VECTOR;
	angData[client] = NULL_VECTOR;
	velData[client] = NULL_VECTOR;
}