#pragma semicolon 1
#pragma newdecls optional

#include <tf2_stocks>
#include <morecolors>
#include <sdkhooks>
#include <tf2>

#define VERSION "1.1.0.9"
#define URL "http://lurolona.su"
#define FCVARS FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY

new iS[MAXPLAYERS+1][MAXPLAYERS+1];

public Plugin:myinfo =
{
	name = "[TF2] Scoring Players",
	author = "Lappland Saluzzo",
	description = "Автоматические ведение счёта между игроками.",
	version = VERSION,
	url = URL
}

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max) {
	if(GetEngineVersion() != Engine_TF2)
	{
		Format(error, err_max, "This plugin only works for Team Fortress 2");
		return APLRes_Failure;
	}
	return APLRes_Success;
}

public OnPluginStart() {
	HookEvent("player_death", PD);
	CreateConVar("sm_scoring_version", VERSION, "Version of Scoring Players plugin.", FCVARS);
}

public OnClientDisconnect_Post(C) {
	new i=1;
	do iS[i][C]=iS[C][i] = 0;
	while(i++<MaxClients);
}

public PD(Handle:E, String:N[], bool:B) {
	decl a;
	if (GetEventInt(E, "death_flags") != TF_DEATHFLAG_DEADRINGER) {
		if((a=GetClientOfUserId(GetEventInt(E,"attacker"))))
		{
			decl v;
			if((v=GetClientOfUserId(GetEventInt(E,"userid"))) !=a)
			{
				++iS[a][v];
				CPrintToChat(a, "{CRIMSON}►{DEFAULT} {RED}СЧЁТ:{DEFAULT} %N {RED}%i{DEFAULT}:{BLUE}%i{DEFAULT} %N", a, iS[a][v], iS[v][a], v);
				CPrintToChat(v, "{CRIMSON}►{DEFAULT} {RED}СЧЁТ:{DEFAULT} %N {BLUE}%i{DEFAULT}:{RED}%i{DEFAULT} %N", v, iS[v][a], iS[a][v], a);
			}
		} 
	} else if((a=GetClientOfUserId(GetEventInt(E,"attacker"))))
		{
			decl v;
			if((v=GetClientOfUserId(GetEventInt(E,"userid"))) !=a) { 
				new f = iS[a][v];
				++f;
				CPrintToChat(a, "{CRIMSON}►{DEFAULT} {RED}СЧЁТ:{DEFAULT} %N {RED}%i{DEFAULT}:{BLUE}%i{DEFAULT} %N", a, f, iS[v][a], v); f = 0;
		}
	}
}
