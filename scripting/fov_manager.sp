#include <multicolors>
#include <clientprefs>
#define Tag "{grey}[Fov Manager]{default}"
#define MaxPlayers 33

public Plugin myinfo = {
	name = "[ANY] FOV Manager",
	author = "Teamkiller324, Lappland_Bro",
	description = "Manage the viewmodel fov.",
	version = "1.3.0",
	url = "https://steamcommunity.com/id/Teamkiller324"
}

//Standalone module from Random Commands Plugin, originally called "Tk Unrestricted FOV"

int g_FOV[MaxPlayers+1] = {-1, ...};

char Prefix[128];

ConVar fovEnable, fovMinimum, fovMaximum, fovPrefix;
Cookie fovCookie;


public void OnPluginStart() {
	LoadTranslations("fov_manager.phrases");
	LoadTranslations("common.phrases");
	
	RegConsoleCmd("sm_fov", FovCmd, "FOV Manager - Set a custom fov on yourself");
	RegConsoleCmd("sm_randomfov", RandomFovCmd, "FOV Manager - Set a random fov on yourself");
	
	fovEnable = CreateConVar("sm_fovmanager_enable", "1", "FOV Manager - Enable / Disable Unrestricted FOV", _, true, _, true, 1.0);
	fovMinimum = CreateConVar("sm_fovmanager_minimum", "75", "FOV Manager - Minimum Unrestricted FOV", _, true, 10.0, true, 360.0);
	fovMaximum = CreateConVar("sm_fovmanager_maximum", "120", "FOV Manager - Maximum Unrestricted FOV", _, true, 10.0, true, 360.0);
	fovPrefix = CreateConVar("sm_fovmanager_prefix", "{lightgreen}[Fov Manager]", "FOV Manager - Chat prefix");
	fovPrefix.AddChangeHook(PrefixCallback);
	fovPrefix.GetString(Prefix, sizeof(Prefix));
	Format(Prefix, sizeof(Prefix), "%s{default}", Prefix);
	
	fovCookie = new Cookie("sm_fovmanager_cookie", "Fov Manager", CookieAccess_Private);
	
	HookEvent("player_spawn", Player_Spawn);
}

void PrefixCallback(ConVar cvar, const char[] oldvalue, const char[] newvalue) {
	cvar.GetString(Prefix, sizeof(Prefix));
	Format(Prefix, sizeof(Prefix), "%s{default}", Prefix);
}

public void OnClientPostAdminCheck(int client) {
	if(!IsValidClient(client)) return;
	char cookie[8];
	fovCookie.Get(client, cookie, sizeof(cookie));
	if(strlen(cookie) > 0) g_FOV[client] = StringToInt(cookie);
}

Action FovCmd(int client, int args) {	
	if(!fovEnable.BoolValue) return Plugin_Handled;
	
	if(!AreClientCookiesCached(client)) {
		ReplyToCommand(client, "\x04[FOV Manager] \x01This command is currently unavailable. Please try again later.");
		return Plugin_Handled;
	}
	
	if(client == 0) {
		CReplyToCommand(client, "[FOV Manager] This command may only be used ingame");
		return Plugin_Handled;
	}
	
	int	fov	= GetCmdInt(1);
	
	if(fov == 0) {
		QueryClientConVar(client, "fov_desired", OnFOVQueried);
		CReplyToCommand(client, "{green}[{lightgreen}FOV Manager{green}]{white} Your FOV has been reset.");
		return Plugin_Handled;
	}

	else if(args < 1) {
		CPrintToChat(client, "%s %t", Prefix, "#FOV_Usage", fovMinimum.IntValue, fovMaximum.IntValue);
		return Plugin_Handled;
	}
	
	if(fov < fovMinimum.IntValue) {
		CPrintToChat(client, "%s %t", Prefix, "#FOV_Error_Minimum", fovMinimum.IntValue);
		return Plugin_Handled;
	}
	else if(fov > fovMaximum.IntValue) {
		CPrintToChat(client, "%s %t", Prefix, "#FOV_Error_Maximum", fovMaximum.IntValue);
		return Plugin_Handled;
	}
	
	SetFOV(client, fov);
	g_FOV[client] = fov;
	
	char val[16];
	IntToString(fov, val, sizeof(val));
	fovCookie.Set(client, val);
	CPrintToChat(client, "%s %t", Prefix, "#FOV_Set", fov);
	
	return Plugin_Handled;
}

Action RandomFovCmd(int client, int args) {
	if(!fovEnable.BoolValue) return Plugin_Handled;
		
	if(client == 0) {
		CReplyToCommand(client, "[FOV Manager] This command may only be used ingame");
		return Plugin_Handled;
	}
	
	int	picker = GetRandomInt(fovMinimum.IntValue, fovMaximum.IntValue);
	SetFOV(client, picker);
	g_FOV[client] = picker;
	
	CPrintToChat(client, "%s %t", Prefix, "#FOV_Randomized", picker);
	return Plugin_Handled;
}

public Player_Spawn(Event event, const char[] event_name, bool dontBroadcast) {
	
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!AreClientCookiesCached(client)) {
		return;
	}
	
	decl String:cookie[12];
	GetClientCookie(client, fovCookie, cookie, sizeof(cookie));
	int fov = StringToInt(cookie);
	if(fov < GetConVarInt(fovMinimum) || fov > GetConVarInt(fovMaximum)) {
		return;
	}
	
	SetFOV(client, fov);
}

bool IsValidClient(int client) {
	if(client < 1 || client > MaxPlayers) return false;
	if(!IsClientConnected(client)) return false;
	if(!IsClientInGame(client)) return false;

	if(IsClientReplay(client)) return false;
	if(IsClientSourceTV(client)) return false;
	if(IsFakeClient(client)) return false;
	
	return true;
}

int GetCmdInt(int argnum) {
	char dummy[16];
	GetCmdArg(argnum, dummy, sizeof(dummy));
	return StringToInt(dummy);
}

void SetFOV(int client, int value) {
	SetEntProp(client, Prop_Send, "m_iFOV", value);
	SetEntProp(client, Prop_Send, "m_iDefaultFOV", value);
}

public OnFOVQueried(QueryCookie:cookie, client, ConVarQueryResult:result, const String:cvarName[], const String:cvarValue[]) {
	if(result != ConVarQuery_Okay)
		return;
	g_FOV[client] = -1;
	SetClientCookie(client, fovCookie, "");
	SetEntProp(client, Prop_Send, "m_iFOV", StringToInt(cvarValue));
	SetEntProp(client, Prop_Send, "m_iDefaultFOV", StringToInt(cvarValue));
}