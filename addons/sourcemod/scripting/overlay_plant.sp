#pragma semicolon 1
#pragma newdecls required

#include <sdktools_stringtables>
#include <smartdm>

ConVar
	cvModel,
	cvTime;

Handle
	hTimerOverlay[MAXPLAYERS+1];

char
	sModel[256];

public Plugin myinfo =
{
	name = "[Overlay] Event bomb planted",
	author = "Nek.'a 2x2 | ggwp.site ",
	description = "Оверлей при установки бомбы",
	version = "1.0.0",
	url = "https://ggwp.site/"
};

public void OnPluginStart()
{
	cvModel = CreateConVar("sm_plant_overlay", "", "Оверлей установки плента");

	cvTime = CreateConVar("sm_plant_time", "3.0", "Через сколько времени оверлей будет удалён");

	HookEvent("bomb_planted", Event_BombPlanted);

	AutoExecConfig(true, "overlay_plant");
}

public void OnConfigsExecuted()
{
	cvModel.GetString(sModel, sizeof(sModel));
	if(sModel[0])
	{
		char sBuffer[256];
		sBuffer = sModel;
		PrecacheModel(sModel, true);
		Format(sBuffer, sizeof(sBuffer), "materials/%s.vmt", sModel);
		Downloader_AddFileToDownloadsTable(sBuffer); 
	}
}

void Event_BombPlanted(Event hEvent, const char[] name, bool dontBroadcast)
{
	for(int i = 1; i <= MaxClients; i++) if(IsClientInGame(i) && !IsFakeClient(i))
	{
		ShowOverlayToClient(i, sModel);
	}
}

void ShowOverlayToClient(int client, const char[] sOverlay)
{
	ClientCommand(client, "r_screenoverlay \"%s\"", sOverlay);
	delete hTimerOverlay[client];
	hTimerOverlay[client] = CreateTimer(cvTime.FloatValue, Timer_ClearOverlay, GetClientUserId(client));
}

Action Timer_ClearOverlay(Handle hTimer, any UserID)
{
	int client = GetClientOfUserId(UserID);
	if(!(0 < client <= MaxClients && IsClientInGame(client) && !IsFakeClient(client)))
		return Plugin_Continue;

	ClientCommand(client, "r_screenoverlay \"\"");
	hTimerOverlay[client] = null;
	return Plugin_Stop;
}

public void OnClientDisconnect(int client)
{
	delete hTimerOverlay[client];
}