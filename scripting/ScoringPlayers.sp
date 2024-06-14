#pragma semicolon 1
#pragma newdecls optional

#include <tf2>
#include <tf2_stocks>
#include <sdkhooks>
#include <sdktools>
#include <multicolors>

#define MaxPlayers 33
#define VERSION "1.3.0.9"
#define URL "https://foxsys-tech.ru"
#define FCVARS FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY

new iS[MAXPLAYERS+1][MAXPLAYERS+1];

public Plugin:myinfo = {
	name = "[FXSS] Scoring Players",
	author = "Lappland_Bro",
	description = "Автоматическое ведение счёта между игроками",
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

public OnMapStart() {
	AddFileToDownloadsTable("sound/gl_endmusic/ows_50_96.mp3");
	AddFileToDownloadsTable("sound/gl_endmusic/ows_10_96.mp3");
		
	PrecacheSound("gl_endmusic/ows_50_96.mp3", true);
	PrecacheSound("gl_endmusic/ows_10_96.mp3", true);
}

public OnPluginStart() {
	CreateConVar("sm_scoring_version", VERSION, "Version of Scoring Players plugin.", FCVARS);
	
	AddFileToDownloadsTable("sound/gl_endmusic/ows_50_96.mp3");
	AddFileToDownloadsTable("sound/gl_endmusic/ows_10_96.mp3");
		
	PrecacheSound("gl_endmusic/ows_50_96.mp3", true);
	PrecacheSound("gl_endmusic/ows_10_96.mp3", true);
	
	HookEvent("player_death", PlayerDeath);
}

public OnClientDisconnect_Post(C) {
	new i=1;
	do iS[i][C]=iS[C][i] = 0;
	while(i++<MaxClients);
}

public PlayerDeath(Handle:E, String:N[], bool:B) {
	
	decl a;
	decl v;
	if (GetEventInt(E, "death_flags") != TF_DEATHFLAG_DEADRINGER) {
		if((a=GetClientOfUserId(GetEventInt(E,"attacker"))))
		{
			if((v=GetClientOfUserId(GetEventInt(E,"userid"))) !=a && !IsFakeClient(v) && !IsFakeClient(a))
			{
				++iS[a][v];
				CPrintToChat(a, "{GRAY}►{GRAY} СЧЁТ:{GRAY} %N {DARKGREEN}%i{GRAY}:{GRAY}%i{GRAY} %N", a, iS[a][v], iS[v][a], v);
				CPrintToChat(v, "{GRAY}►{GRAY} СЧЁТ:{GRAY} %N {GRAY}%i{GRAY}:{DARKGREEN}%i{GRAY} %N", v, iS[v][a], iS[a][v], a);
			}
		} 
	} else if((a=GetClientOfUserId(GetEventInt(E,"attacker"))))
		{
			if((v=GetClientOfUserId(GetEventInt(E,"userid"))) !=a) { 
				new f = iS[a][v];
				++f;
				CPrintToChat(a, "{GRAY}►{GRAY} {RED}СЧЁТ:{GRAY} %N {RED}%i{GRAY}:{BLUE}%i{GRAY} %N", a, f, iS[v][a], v); f = 0;
		}
	}
	
	if(iS[a][v] == 5 && iS[v][a] == 0) {
		CPrintToChatAll("{GRAY}►{GRAY} Игрок {WHITE}%N{GRAY} сделал 5 убийств ПОДРЯД без смертей!", a);
		EmitSoundToAll("gl_endmusic/ows_50_96.mp3", SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_CONVO);
		// Какая бооль... какая бооль... 5:0
	}
	
	if(iS[a][v] == 10 && iS[v][a] == 0) {
		CPrintToChatAll("{GRAY}►{GRAY} Игрок {WHITE}%N{GRAY} сделал 10 убийств ПОДРЯД без смертей!", a);
		EmitSoundToAll("gl_endmusic/ows_10_96.mp3", SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_CONVO);
		// 1-2-3-4-5-6-7 прости, меня все бесит, 8-9-10.
	}
}
