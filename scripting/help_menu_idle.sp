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
	name = "[TF2] Server Menu Achievement",
	author = "Lappland Saluzzo",
	description = "Main navigation menu in a Achievement Server",
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
	
	AutoExecConfig(true, "Achievement_menu");

}

public Action:Command_Menu(client, args) {
	if (client)
		CreateHelpMenu(client);

	return Plugin_Handled;
}

stock CreateHelpMenu(client) {
	Handle menu = CreateMenu(HelpMenuHandler);
	SetMenuTitle(menu, "Меню | FoxSys Project");

	AddMenuItem(menu, "1", "Пожаловаться | Report");
	AddMenuItem(menu, "2", "Справочная | SB");
	AddMenuItem(menu, "3", "Операторы онлайн | API");
	AddMenuItem(menu, "4", "Кинуть кости | RTD");
	AddMenuItem(menu, "5", "Магазин | Shop");
	AddMenuItem(menu, "6", "Насмешки | Taunt");
	AddMenuItem(menu, "7", "Ачивки | API");
	AddMenuItem(menu, "8", "Ссылка на DS | Menu"); //https://discord.gg/ZwbrJk5r9h
	AddMenuItem(menu, "9", "Машинка | Car");
	AddMenuItem(menu, "10", "Дружелюбие | FR");
	AddMenuItem(menu, "11", "Стать роботом | BR");
	AddMenuItem(menu, "12", "Стать скелетом | BS");
	AddMenuItem(menu, "13", "Стать статуей | CIV");
	AddMenuItem(menu, "14", "Монетка | Shop");
	AddMenuItem(menu, "15", "Ранжирование | PR");
	AddMenuItem(menu, "16", "Наборы убийц | SH");
	AddMenuItem(menu, "17", "Радиостанции | HR");
	AddMenuItem(menu, "18", "Огненный след | FP");
	AddMenuItem(menu, "19", "Эффекты шапок | US");
	AddMenuItem(menu, "20", "Инж. Панели | Pads");
	AddMenuItem(menu, "21", "Углы обзора | Reset");
	AddMenuItem(menu, "22", "Третье лицо | TP");
	AddMenuItem(menu, "23", "Первое лицо | FP");
	AddMenuItem(menu, "24", "Настройки игры | ST");
	AddMenuItem(menu, "25", "Подсветиться | RME");
	AddMenuItem(menu, "26", "Серверы | ServerList");
	AddMenuItem(menu, "27", "Эффекты Рэгдоллов | CR");

	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, 30);
}

public HelpMenuHandler(Handle:menu, MenuAction:action, client, item) {
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
				FakeClientCommand(client, "sm_admins");
			}
				case 4:
			{
				FakeClientCommand(client, "sm_rtd");
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
				decl String:CLink[128];
				GetConVarString(hLink, CLink, sizeof(CLink));
				MC_PrintToChat(client, "{#7366bd}[Discord]{default} Cообщество в Discord: {#7366bd}%s\n{#7366bd}✦{default} Присоединившись к серверу, не забудьте авторизоваться!", CLink);
			}
				case 9:
			{
				FakeClientCommand(client, "sm_car");
			}
				case 10:
			{
				FakeClientCommand(client, "sm_friendly");
			}
				case 11:
			{
				FakeClientCommand(client, "sm_robot");
			}
				case 12:
			{
				FakeClientCommand(client, "sm_skeleton");
			}
				case 13:
			{
				FakeClientCommand(client, "sm_civ");
			}
				case 14:
			{
				FakeClientCommand(client, "sm_flip");
			}
				case 15:
			{
				FakeClientCommand(client, "sm_rank");
			}
				case 16:
			{
				FakeClientCommand(client, "sm_sheens");
			}
				case 17:
			{
				FakeClientCommand(client, "sm_radio");
			}
				case 18:
			{
				FakeClientCommand(client, "sm_footprints");
			}
				case 19:
			{
				FakeClientCommand(client, "sm_unusuals");
			}
				case 20:
			{
				FakeClientCommand(client, "sm_pads");
			}
				case 21:
			{
				FakeClientCommand(client, "sm_fov");
			}
				case 22:
			{
				FakeClientCommand(client, "sm_tp");
			}
				case 23:
			{
				FakeClientCommand(client, "sm_fp");
			}
				case 24:
			{
				FakeClientCommand(client, "sm_settings");
			}
				case 25:
			{
				FakeClientCommand(client, "sm_rainbowme");
			}
				case 26:
			{
				FakeClientCommand(client, "sm_servers");
			}
				case 27:
			{
				FakeClientCommand(client, "sm_ragdoll");
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
