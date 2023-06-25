#pragma semicolon 1
#pragma newdecls optional

#include <sourcemod>
#include <sdktools>
#include <morecolors>

#define VERSION "1.2.0.9"
#define URL "https://www.lurolona.su"
#define FCVARS FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY

Handle hLink;

public Plugin:myinfo = {
	name = "[TF2] Server Menu",
	author = "Lappland Saluzzo",
	description = "Main navigation menu in a Jump Server",
	version = VERSION,
	url = URL
}

public OnPluginStart() {
	RegConsoleCmd("sm_menu", Command_Menu);
	RegConsoleCmd("sm_help", Command_Menu);
	RegConsoleCmd("sm_commands", Command_Menu);
	RegConsoleCmd("sm_cmds", Command_Menu);
	
	RegConsoleCmd("sm_ds", Command_Discord);
	RegConsoleCmd("sm_discord", Command_DiscordLink);
	
	hLink = CreateConVar("sm_discordlink", "https://discord.gg/ZwbrJk5r9h", "Link to joining our Discord-community.");
	
	AutoExecConfig(true, "vsh_menu");

}

public Action:Command_Menu(client, args) {
	if (client)
		CreateHelpMenu(client);

	return Plugin_Handled;
}

stock CreateHelpMenu(client) {
	Handle menu = CreateMenu(HelpMenuHandler);
	SetMenuTitle(menu, "Меню | FoxSys Project");

	AddMenuItem(menu, "1", "Жалоба на игрока | Report");
	AddMenuItem(menu, "2", "Справочная система | SB");
	AddMenuItem(menu, "3", "Видеозаписи Easy-курса | API");
	AddMenuItem(menu, "4", "Свободный полёт | FS");
	AddMenuItem(menu, "5", "Внутриигровой магазин | Shop");
	AddMenuItem(menu, "6", "Насмешки | Taunt");
	AddMenuItem(menu, "7", "Достижения | API");
	AddMenuItem(menu, "8", "Подсветить себя | RME");
	AddMenuItem(menu, "9", "Показ нажатий | JSE");

	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, 30);
}

public HelpMenuHandler(Handle:menu, MenuAction:action, client, item)
{
	if (action == MenuAction_Select)
	{
		char info[5];
		GetMenuItem(menu, item, info, sizeof(info));

		switch (StringToInt(info))
		{
				case 1:
			{
				FakeClientCommand(client, "sm_helpop");
			}
				case 2:
			{
				ShowUrlFullscreen(client, "FoxSys Project | Sourcebans++", URL);
			}
				case 3:
			{
				ShowUrlFullscreen(client, "FoxSys Project | Sourcebans++", "https://youtube.com/playlist?list=PLkTE1g_haE4k_o3CEJZMQZgJRQQTQJqc6");
			}
				case 4:
			{
				FakeClientCommand(client, "sm_fs");
			}
				case 5:
			{
				FakeClientCommand(client, "sm_shop");
			}
				case 6:
			{
				FakeClientCommand(client, "sm_taunt");
			}
				case 7:
			{
				FakeClientCommand(client, "sm_givemeall");
			}
				case 8:
			{
				FakeClientCommand(client, "sm_rainbowme");
			}
				case 9:
			{
				FakeClientCommand(client, "sm_showkeys");
			}
		}
	}
		else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public EmptyPanelHandler(Handle:menu, MenuAction:action, client, item) {
}

public Action:Command_Discord(client, args) {
	if (client) {
		decl String:CLink[128];
		GetConVarString(hLink, CLink, sizeof(CLink));
		MC_PrintToChat(client, "{#7366bd}[Discord]{default} Cообщество в Discord: {#7366bd}%s\n{#7366bd}✦{default} Присоединившись к серверу, не забудьте авторизоваться!", CLink);
	}
	return Plugin_Handled;
}

public Action:Command_DiscordLink(client, args) {
	if (client) {
		decl String:CLink[128];
		GetConVarString(hLink, CLink, sizeof(CLink));
		ShowUrlFullscreen(client, "FXSS | Сообщество", CLink);
	}
	return Plugin_Handled;
}

public ShowUrlFullscreen(client, const String:title[], const String:url[]) {
	Handle kv = CreateKeyValues("data");

	KvSetNum(kv, "customsvr", 1);
	KvSetNum(kv, "type", MOTDPANEL_TYPE_URL);

	KvSetString(kv, "title", title);
	KvSetString(kv, "msg", url);

	ShowVGUIPanel(client, "info", kv, true);

	CloseHandle(kv);
}
