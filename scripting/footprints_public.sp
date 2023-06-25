#pragma newdecls optional

#include <tf2attributes>
#include <morecolors>

new Float:FootprintID[MAXPLAYERS+1] = 0.0

public Plugin:myinfo = 
{
	name = "[TF2] Halloween Footprints",
	author = "Oshizu",
	description = "Looks Fancy Ahhhh",
	version = "1.1.0.1",
	url = "https://lurolona.su"
}

public OnPluginStart() {
	RegAdminCmd("sm_footprints", FootSteps, ADMFLAG_RESERVATION)
	RegAdminCmd("sm_footsteps", FootSteps, ADMFLAG_RESERVATION)

	HookEvent("player_spawn", PlayerSpawn, EventHookMode_Post)
}

public OnClientDisconnect(client) {
	if(FootprintID[client] > 0.0)
	{
		FootprintID[client] = 0.0
	}
}

public Action:PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast) {
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(FootprintID[client] > 0.0)
	{
		TF2Attrib_SetByName(client, "SPELL: set Halloween footstep type", FootprintID[client]);
	}
}

public Action:FootSteps(client, args) {
	new Handle:ws = CreateMenu(FootStepsCALLBACK);
	SetMenuTitle(ws, "Выберите эффект следов:");

	AddMenuItem(ws, "0", "Без эффекта");
	AddMenuItem(ws, "X", "----------", ITEMDRAW_DISABLED);
	AddMenuItem(ws, "1", "Цвет команды");
	AddMenuItem(ws, "7777", "Синий");
	AddMenuItem(ws, "933333", "Голубой")
	AddMenuItem(ws, "8421376", "Желтый");
	AddMenuItem(ws, "4552221", "Зеленый");
	AddMenuItem(ws, "3100495", "Темно-зеленый");
	AddMenuItem(ws, "51234123", "Лаймовый");
	AddMenuItem(ws, "5322826", "Коричневый");
	AddMenuItem(ws, "8355220", "Темно-коричневый");
	AddMenuItem(ws, "13595446", "Оранжевый");
	AddMenuItem(ws, "8208497", "Кремовый");
	AddMenuItem(ws, "41234123", "Розовый");
	AddMenuItem(ws, "300000", "Сатанисткий");
	AddMenuItem(ws, "2", "Фиолетовый");
	AddMenuItem(ws, "83552", "Призрачный");
	AddMenuItem(ws, "9335510", "Огненный");

	DisplayMenu(ws, client, MENU_TIME_FOREVER);

	return Plugin_Handled;
}

public FootStepsCALLBACK(Handle:menu, MenuAction:action, client, param2) {
	if(action == MenuAction_End) CloseHandle(menu);

	if(action == MenuAction_Select)
	{
		decl String:info[12];
		GetMenuItem(menu, param2, info, sizeof(info));

		new Float:weapon_glow = StringToFloat(info);
		FootprintID[client] = weapon_glow
		if(weapon_glow == 0.0)
		{
			TF2Attrib_RemoveByName(client, "SPELL: set Halloween footstep type")
		}
		else
		{
			TF2Attrib_SetByName(client, "SPELL: set Halloween footstep type", weapon_glow);
		}
	}
}