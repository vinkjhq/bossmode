#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <cstrike>
#include emitsoundany.inc
#include <sdktools_sound>

#define HIDE_RADAR_CSGO 1<<12
#define IN_FORWARD	  (1 << 3)
#define IN_BACK	  (1 << 4)
#define IN_MOVELEFT	 (1 << 9)
#define IN_MOVERIGHT		(1 << 10)
#define PLUGIN_VERSION "1.0.1"
new String:skyname[32];
new String:lightlevel[2];

new g_iAccount;
new weaponslot1;
new weaponslot2;
new weaponslotc4;
new BossPlayer;
new CheckRealPlayers;
new initialBossHealth;
new currentHealth;
new OldPlayerSelected;
new LastCT;
new BossAlive;
new g_GameMod;
new RandomSpyEnd;
new g_SubGameMod;
new g_AttackRandomSound;
new GLOW_ENTITY;
int Ragecount;
new entity_weapon;

new Float:g_fBossGravity[MAXPLAYERS + 1];
new MoveType:gMT_MoveTypeBoss[MAXPLAYERS + 1];

new bool:g_isDemap = false;
new bool:RageStart = false;
new bool:cbsrage = false;
new bool:Cloak = false;
new bool:Cloakready = false;
new bool:GameStarted = false;
new bool:EMP = false;
new Handle:g_hGameEnable = INVALID_HANDLE;
new bool:g_bGameEnable;
new Handle:g_hSkybox = INVALID_HANDLE;
new bool:g_bSkybox;

new Handle:g_hNV = INVALID_HANDLE;
new bool:g_bNV;

new Handle:g_hPredaEnable = INVALID_HANDLE;
new bool: g_bPredaEnable;
new Handle:g_hDukeEnable = INVALID_HANDLE;
new bool:g_bDukeEnable;
new Handle:g_hInvNoMove = INVALID_HANDLE;
new bool:g_bInvNoMove;

new Handle:g_hCvarFovTer;
new Handle:g_hEnergyPreda;
new Handle:g_hEnergyEzio;
new Handle:g_hEnergyHitman;
new Handle:g_hEnergyJoker;
new Handle:g_hEnergyBulldozer;
new Handle:g_hEnergyGentlespy;
new Handle:g_hEnergyCBS;
new Handle:g_hEnergyMurica;
new Handle:g_hEnergyDuke;
new Handle:TimerShowHealth = INVALID_HANDLE;
new Handle:TimerGameOn = INVALID_HANDLE;
new Handle:TimerC4Give = INVALID_HANDLE;

new bool:g_bPredator = false;
new bool:g_bEzio = false;
new bool:g_bHitman = false;
new bool:g_bJoker = false;
new bool:g_bBulldozer = false;
new bool:g_bGentlespy = false;
new bool:g_bCBS = false;
new bool:g_bMurica = false;
new bool:g_bDuke = false;
new bool:g_bLastCT = false;

public Plugin:myinfo = {
	name = "BossMode (based on the original plugin 1 vs All by -GoV-TonyBaretta",
	author = "KJ",
	description = "BossMode",
	version = PLUGIN_VERSION,
	url = ""
};
public OnMapStart()
{
	
	SetLightStyle(0,lightlevel);
	PrecacheSoundAny("buttons/light_power_on_switch_01.wav");
	PrecacheSoundAny("buttons/combine_button_locked.wav");
	PrecacheSoundAny("ambient/tones/elev4.wav");
	PrecacheSoundAny("bossmode/showdown.mp3");
	//Hitman
	PrecacheSoundAny("bossmode/intro_hitman.mp3");
	PrecacheSoundAny("bossmode/start_hitman.mp3");	
	PrecacheSoundAny("bossmode/rage_hitman.mp3");
	PrecacheSoundAny("bossmode/end_hitman.mp3");
	PrecacheSoundAny("bossmode/attack_hitman_1.mp3");
	PrecacheSoundAny("bossmode/attack_hitman_2.mp3");
	PrecacheSoundAny("bossmode/attack_hitman_3.mp3");
	//Ezio
	PrecacheSoundAny("bossmode/intro_ezio.mp3");
	PrecacheSoundAny("bossmode/start_ezio.mp3");
	PrecacheSoundAny("bossmode/rage_ezio.mp3");
	PrecacheSoundAny("bossmode/endrage_ezio.mp3");
	PrecacheSoundAny("bossmode/end_ezio.mp3");
	PrecacheSoundAny("bossmode/attack_ezio_1.mp3");
	PrecacheSoundAny("bossmode/attack_ezio_2.mp3");
	PrecacheSoundAny("bossmode/attack_ezio_3.mp3");
	//Bulldozer
	PrecacheSoundAny("bossmode/intro_bulldozer.mp3");
	PrecacheSoundAny("bossmode/rage_bulldozer_1.mp3");
	PrecacheSoundAny("bossmode/rage_bulldozer_2.mp3");
	PrecacheSoundAny("bossmode/rage_bulldozer_3.mp3");
	PrecacheSoundAny("bossmode/end_bulldozer_1.mp3");
	PrecacheSoundAny("bossmode/end_bulldozer_2.mp3");
	PrecacheSoundAny("bossmode/attack_bulldozer_1.mp3");
	PrecacheSoundAny("bossmode/attack_bulldozer_2.mp3");
	PrecacheSoundAny("bossmode/attack_bulldozer_3.mp3");
	PrecacheSoundAny("bossmode/attack_bulldozer_4.mp3");
	PrecacheSoundAny("bossmode/endrage_bulldozer_1.mp3");	
	PrecacheSoundAny("bossmode/endrage_bulldozer_2.mp3");	
	PrecacheSoundAny("bossmode/endrage_bulldozer_3.mp3");			
	PrecacheSoundAny("bossmode/start_bulldozer_1.mp3");	
	PrecacheSoundAny("bossmode/start_bulldozer_2.mp3");	
	PrecacheSoundAny("bossmode/start_bulldozer_3.mp3");
	//Gentlespy
	PrecacheSoundAny("bossmode/intro_gentlespy.mp3");
	PrecacheSoundAny("bossmode/start_gentlespy.mp3");	
	PrecacheSoundAny("bossmode/cloak_gentlespy.mp3");	
	PrecacheSoundAny("bossmode/endcloak_gentlespy_1.mp3");
	PrecacheSoundAny("bossmode/endcloak_gentlespy_2.mp3");
	PrecacheSoundAny("bossmode/attack_gentlespy_0.mp3");
	PrecacheSoundAny("bossmode/attack_gentlespy_1.mp3");
	PrecacheSoundAny("bossmode/attack_gentlespy_2.mp3");
	PrecacheSoundAny("bossmode/attack_gentlespy_3.mp3");
	PrecacheSoundAny("bossmode/attack_gentlespy_4.mp3");
	PrecacheSoundAny("bossmode/attack_gentlespy_5.mp3");	
	PrecacheSoundAny("bossmode/solo_gentlespy.mp3");
	//Joker
	PrecacheSoundAny("bossmode/intro_joker.mp3");
	PrecacheSoundAny("bossmode/start_joker.mp3");	
	PrecacheSoundAny("bossmode/rage_joker_1.mp3");
	PrecacheSoundAny("bossmode/rage_joker_2.mp3");
	PrecacheSoundAny("bossmode/attack_joker_1.mp3");
	PrecacheSoundAny("bossmode/attack_joker_2.mp3");
	PrecacheSoundAny("bossmode/attack_joker_3.mp3");
	//CBS
	PrecacheSoundAny("bossmode/intro_cbs.mp3");
	PrecacheSoundAny("bossmode/start_cbs.mp3");	
	PrecacheSoundAny("bossmode/end_cbs.mp3");	
	PrecacheSoundAny("bossmode/rage_cbs_1.mp3");
	PrecacheSoundAny("bossmode/rage_cbs_2.mp3");
	PrecacheSoundAny("bossmode/rage_cbs_3.mp3");	
	PrecacheSoundAny("bossmode/attack_cbs_1.mp3");
	PrecacheSoundAny("bossmode/attack_cbs_2.mp3");
	PrecacheSoundAny("bossmode/attack_cbs_3.mp3");	
	PrecacheSoundAny("bossmode/attack_cbs_rage.mp3");
	PrecacheSoundAny("bossmode/endrage_cbs_1.mp3");	
	PrecacheSoundAny("bossmode/endrage_cbs_2.mp3");	
	PrecacheSoundAny("bossmode/endrage_cbs_3.mp3");
	//Murica
	PrecacheSoundAny("bossmode/intro_murica.mp3");
	PrecacheSoundAny("bossmode/start_murica_1.mp3");
	PrecacheSoundAny("bossmode/start_murica_2.mp3");	
	PrecacheSoundAny("bossmode/start_murica_3.mp3");		
	PrecacheSoundAny("bossmode/end_murica_1.mp3");
	PrecacheSoundAny("bossmode/end_murica_2.mp3");	
	PrecacheSoundAny("bossmode/rage_murica_1.mp3");
	PrecacheSoundAny("bossmode/rage_murica_2.mp3");
	PrecacheSoundAny("bossmode/rage_murica_3.mp3");	
	PrecacheSoundAny("bossmode/attack_murica_1.mp3");
	PrecacheSoundAny("bossmode/attack_murica_2.mp3");
	PrecacheSoundAny("bossmode/attack_murica_3.mp3");	
	PrecacheSoundAny("bossmode/attack_murica_4.mp3");
	PrecacheSoundAny("bossmode/attack_murica_5.mp3");
	PrecacheSoundAny("bossmode/attack_murica_6.mp3");
	PrecacheSoundAny("bossmode/endrage_murica_1.mp3");	
	PrecacheSoundAny("bossmode/endrage_murica_2.mp3");	
	PrecacheSoundAny("bossmode/endrage_murica_3.mp3");	
	PrecacheSoundAny("bossmode/solo_murica.mp3");
	PrecacheModel("models/player/mapeadores/morell/predator/predator.mdl");
	PrecacheModel("models/player/custom_player/voikanaa/acb/ezio.mdl");
	PrecacheModel("models/player/custom_player/voikanaa/hitman/agent47.mdl"); 
	PrecacheModel("models/player/custom_player/caleon1/nkpolice/nkpolice.mdl");
	PrecacheModel("models/player/mapeadores/morell/joker/joker.mdl");
	PrecacheModel("models/player/kuristaja/tf2/spy/spy_blu.mdl");
	PrecacheModel("models/player/kuristaja/tf2/sniper/sniper_red.mdl");
	PrecacheModel("models/player/kuristaja/tf2/soldier/soldier_red.mdl");
	PrecacheModel("models/player/kuristaja/duke/duke.mdl");
	decl String:file[256];
	BuildPath(Path_SM, file, 255, "configs/1_vs_all_dl.ini");
	new Handle:fileh = OpenFile(file, "r");
	if (fileh != INVALID_HANDLE)
	{
		decl String:buffer[256];
		decl String:buffer_full[PLATFORM_MAX_PATH];

		while(ReadFileLine(fileh, buffer, sizeof(buffer)))
		{
			TrimString(buffer);
			if ( (StrContains(buffer, "//") == -1) && (!StrEqual(buffer, "")) )
			{
				PrintToServer("Reading downloads line :: %s", buffer);
				Format(buffer_full, sizeof(buffer_full), "%s", buffer);
				if (FileExists(buffer_full))
				{
					PrintToServer("Precaching %s", buffer);
					PrecacheDecal(buffer, true);
					AddFileToDownloadsTable(buffer_full);
				}
			}
		}
	}
	decl String:mapname[128];
	GetCurrentMap(mapname, sizeof(mapname));
	if (strncmp(mapname, "de_", 3) == 0)
	{
		g_isDemap = true;
	}
} 
public OnPluginStart()
{
	CreateConVar("csgo_1vsall_version", PLUGIN_VERSION, "Current 1 vs all version", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	HookEvent("player_spawn", Player_Spawn);
	HookEvent("round_end", Event_RoundEnd);
	HookEvent("round_start", Event_RoundStart);
	HookEvent("player_death", PlayerDeath); //When player suicide
	AddCommandListener(Command_JoinTeam, "jointeam");
	AddCommandListener(Command_Drop, "drop");
	AddCommandListener(Command_Rage, "+lookatweapon");
	AddCommandListener(Command_Rage, "-lookatweapon");	
	AddCommandListener(Command_Cloak, "+cloak");
	AddCommandListener(Command_Cloak, "-cloak");
	AddCommandListener(Command_Superjump, "+sjump");
	AddCommandListener(Command_Superjump, "-sjump");	
	AddCommandListener(Command_Use, "+use");
	AddCommandListener(Command_Use, "-use");
	RegAdminCmd("sm_1vsall_start", Command_AdminStart, ADMFLAG_ROOT, "Enable mod by admin command");
	HookEvent("item_pickup", OnItemPickUp, EventHookMode_Pre);
	g_hGameEnable = CreateConVar("1vsall_enable", "1", "Enable / Disable Plugin");
	g_bGameEnable = GetConVarBool(g_hGameEnable);
	g_hPredaEnable = CreateConVar("predator_enable", "1", "Enable Predator if set 1");
	g_bPredaEnable = GetConVarBool(g_hPredaEnable);
	g_hDukeEnable = CreateConVar("dukenukem_enable", "1", "Enable dukenukem if set 1");
	g_bDukeEnable = GetConVarBool(g_hDukeEnable );
	g_hCvarFovTer = CreateConVar("1vsall_Fov", "110", "Set fov distance for terror");
	g_hEnergyPreda = CreateConVar("predator_health", "100", "Predator Health, set here how much health give to Boss for EACH CLIENT ");
	g_hEnergyEzio = CreateConVar("ezio_health", "1200", "Ezio Health, set here how much health give to Boss for EACH CLIENT ");
	g_hEnergyHitman = CreateConVar("hitman_health", "1250", "Hitman Health, set here how much health give to Boss for EACH CLIENT ");	
	g_hEnergyJoker = CreateConVar("joker_health", "900", "Joker Health, set here how much health give to Boss for EACH CLIENT ");	
	g_hEnergyBulldozer = CreateConVar("bulldozer_health", "1500", "Bulldozer Health, set here how much health give to Boss for EACH CLIENT ");	
	g_hEnergyGentlespy = CreateConVar("gentlespy_health", "1200", "Gentlespy Health, set here how much health give to Boss for EACH CLIENT ");
	g_hEnergyCBS = CreateConVar("cbs_health", "1300", "CBS Health, set here how much health give to Boss for EACH CLIENT ");
	g_hEnergyMurica = CreateConVar("murica_health", "1200", "Murica Health, set here how much health give to Boss for EACH CLIENT ");
	g_hEnergyDuke = CreateConVar("dukenukem_health", "140", "DukeNukem Health, set here how much health give to Boss for EACH CLIENT ");
	g_hSkybox = CreateConVar("1vsall_skybox_lights", "0", "Set Customskybox and lights if change need restart the server");
	g_bSkybox = GetConVarBool(g_hSkybox);
	g_hInvNoMove = CreateConVar("full_inv_no_move", "0", "When Boss  don't  moving become invisible , 1 for enable");
	g_bInvNoMove = GetConVarBool(g_hInvNoMove);
	if(g_bGameEnable){
		SetConVarInt(FindConVar("mp_autoteambalance"), 0);
		SetConVarInt(FindConVar("sv_disable_immunity_alpha"), 1);
		SetConVarInt(FindConVar("mp_limitteams"), 0);
		g_hNV = CreateConVar("1vsall_nightvision", "1", "Set Nightvision for terror");
		SetConVarInt(FindConVar("mp_warmuptime"), 15);
		g_bNV = GetConVarBool(g_hNV);
	}
	if(!g_bGameEnable){
		SetConVarInt(FindConVar("mp_autoteambalance"), 1);
		SetConVarInt(FindConVar("mp_limitteams"), 1);
		SetConVarInt(FindConVar("sv_disable_immunity_alpha"), 0);
		g_hNV = CreateConVar("1vsall_nightvision", "0", "Set Nightvision for terror");
		g_bNV = GetConVarBool(g_hNV);
	}
	g_iAccount = FindSendPropOffs("CCSPlayer", "m_iAccount");
	if(g_bSkybox){
		LoadKV();
		ServerCommand("sv_skyname %s",skyname);
	}
	AutoExecConfig(true, "1_vs_all_config");
}
public LoadKV()
{
	new Handle:kv = CreateKeyValues("LigheStyle");
	if (!FileToKeyValues(kv,"cfg/sourcemod/lightstyle.txt"))
	{
		return;
	}
	if (KvJumpToKey(kv, "Settings"))
	{
		KvGetString(kv,"lightlevel",lightlevel, sizeof(lightlevel));
		KvGetString(kv,"skyname",skyname, sizeof(skyname));
		KvGoBack(kv);
	}
	
	CloseHandle(kv);	
}
public Action:OnPlayerRunCmd(client, &buttons, &Impulse, Float:Vel[3], Float:Angles[3], &Weapon)
{
	new iButtons = GetClientButtons(client);
	if (client <= 0) return Plugin_Handled;
//	if ((iButtons & IN_MOVELEFT) || (iButtons & IN_MOVERIGHT) || (iButtons & IN_FORWARD) || (iButtons & IN_BACK) || (iButtons & IN_ATTACK) || (iButtons & IN_ATTACK2)) {
//		if(((GetClientTeam(client) == CS_TEAM_T) && (client == BossPlayer)) || (IsFakeClient(client) && (GetClientTeam(client) == CS_TEAM_T)) && (client == BossPlayer)){
//			SetEntProp(client, Prop_Data, "m_nButtons", iButtons);
//			CreateTimer(0.0, PredaVisible, client);
//		}
//	}
	if(((buttons & IN_ATTACK) || (buttons & IN_ATTACK2)) && (!GameStarted))
	{
		buttons &= ~IN_ATTACK;
		buttons &= ~IN_ATTACK2;
		return Plugin_Changed;
	}
	if(((buttons & IN_ATTACK) || (buttons & IN_ATTACK2)) && (EMP) && (client != BossPlayer))
	{
		buttons &= ~IN_ATTACK;
		buttons &= ~IN_ATTACK2;
		return Plugin_Changed;
	}
	if(((buttons & IN_ATTACK) || (buttons & IN_ATTACK2)) && (GameStarted) && (g_bJoker) && (client == BossPlayer))
	{
		SetEntityRenderMode(client, RENDER_NORMAL);
		SetEntityRenderColor(client,255,255,255,255);
		CreateTimer(1.0,Jokerattack,client);
		return Plugin_Changed;
	}	
	if((buttons & IN_ATTACK2) && Cloak && (client == BossPlayer))
	{
		buttons &= ~IN_ATTACK;
		buttons &= ~IN_ATTACK2;
		return Plugin_Changed;
	}	
	if(!g_bLastCT  && (client == BossPlayer) && ((GetEntityFlags(client) & FL_ONGROUND) ) && (g_bInvNoMove) ){
		SetEntityRenderMode(client, RENDER_NORMAL);
		SetEntityRenderColor(client, 255, 255, 255, 0);
	}
	if(g_bLastCT){
		SetEntityRenderMode(client, RENDER_NORMAL);
		SetEntityRenderColor(client, 255, 255, 255, 255);
	}
	return Plugin_Continue
}
public OnClientPutInServer(client) {
	if(g_bGameEnable){
		CreateTimer(15.0, Welcome, client);
	}
}
public Action:Jokerattack(Handle:timer, any:client){
	SetEntityRenderMode(BossPlayer, RENDER_TRANSCOLOR);
	SetEntityRenderColor(BossPlayer, 0, 0, 0, 0);	
}
public Action:Command_AdminStart(client, args){
	g_bGameEnable = GetConVarBool(g_hGameEnable);
	if(!g_bGameEnable){
		SetConVarBool(g_hGameEnable,true);
		g_bGameEnable = GetConVarBool(g_hGameEnable);
		CS_TerminateRound(2.0, CSRoundEnd_Draw);
		SetConVarInt(FindConVar("sv_disable_immunity_alpha"), 1);
		PrintToChatAll("CSGO 1 VS ALL MOD IS ON");
		return Plugin_Handled;
	}
	else
	SetConVarBool(g_hGameEnable,false);
	g_bGameEnable = GetConVarBool(g_hGameEnable);
	CS_TerminateRound(2.0, CSRoundEnd_Draw);
	SetConVarInt(FindConVar("sv_disable_immunity_alpha"), 0);
	PrintToChatAll("CSGO 1 VS ALL MOD IS OFF");
	return Plugin_Handled;
}
// EVENTS
public Action:Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast){
	g_bGameEnable = GetConVarBool(g_hGameEnable);
	if(!g_bGameEnable){
		SetConVarInt(FindConVar("mp_autoteambalance"), 1);
		SetConVarInt(FindConVar("mp_limitteams"), 1);
		SetConVarInt(FindConVar("sv_disable_immunity_alpha"), 0);
		SetConVarBool(g_hNV,false);
		g_bNV = GetConVarBool(g_hNV);
		for (new i = 1; i <= MaxClients; i++)
		{
			if (i <= 0) return Plugin_Handled;
			if((IsValidClient(i)) && (GetClientTeam(i) != 1)){
				SetEntityGravity(i, 1.0);
				SetEntProp(i, Prop_Send, "m_bNightVisionOn", 0);
				SetEntProp(i, Prop_Send, "m_iDefaultFOV", 90);
				SDKUnhook(i, SDKHook_OnTakeDamage, OnTakeDamage);
				SetClientOverlay(i, "");
			}
		}
		BossPlayer = 0;
		return Plugin_Handled;
	}
	else
	if(g_bGameEnable){
		SetConVarInt(FindConVar("mp_autoteambalance"), 0);
		SetConVarInt(FindConVar("mp_limitteams"), 0);
		SetConVarInt(FindConVar("sv_disable_immunity_alpha"), 1);
		SetConVarInt(FindConVar("mp_warmuptime"), 10);
		SetConVarBool(g_hNV,true);
		g_bNV = GetConVarBool(g_hNV);
	}
	g_bDukeEnable = GetConVarBool(g_hDukeEnable);	
	g_bPredaEnable = GetConVarBool(g_hPredaEnable);
	g_bInvNoMove = GetConVarBool(g_hInvNoMove);
	g_bPredator = false;
	g_bEzio = false;
	g_bHitman = false;	
	g_bJoker = false;		
	g_bBulldozer = false;
	g_bGentlespy = false;
	g_bCBS = false;
	g_bMurica = false;		
	g_bDuke = false;
	RageStart = false;
	cbsrage = false;
	GameStarted = false;
	Ragecount = 0;
	Cloakready = false;
	Cloak = false;
	g_bLastCT = false;
	for (new client = 1; client <= MaxClients; client++)
	{
		if (client <= 0) return Plugin_Handled;
		if((IsValidClient(client)) && (GetClientTeam(client) != 1) && (GetClientTeam(client) == CS_TEAM_T)){
			CS_SwitchTeam(client, CS_TEAM_CT);
			CS_RespawnPlayer(client);
			SetEntityRenderMode(client, RENDER_NORMAL);
			SetEntityRenderColor(client, 255, 255, 255, 255); 
		}
	}
	new iEnt = -1;
	while((iEnt = FindEntityByClassname(iEnt, "weapon_c4")) != -1) //Find c4
	{
		AcceptEntityInput(iEnt,"kill"); //Destroy the entity
	}
	decl String:ClientName[50];
	BossPlayer = GetRandomPlayer();
	if (BossPlayer <= 0) return Plugin_Handled;
	else
//		while(BossPlayer == OldPlayerSelected)
//		{
//			BossPlayer = GetRandomPlayer();
//		}
	GetClientName(BossPlayer,ClientName,sizeof(ClientName));
	g_GameMod = GetRandomInt(1,7);
	if(g_GameMod <= 0)return Plugin_Handled;
	if(g_GameMod == 1){
		g_bEzio = true;
		CreateEzio();
	}
	if(g_GameMod == 2){ 
		g_bHitman = true;
		CreateHitman();
	}
	if(g_GameMod == 3){
		g_bBulldozer = true;
		CreateBulldozer();
	}
	if(g_GameMod == 4){
		g_bGentlespy = true;
		CreateGentlespy();
	}
	if(g_GameMod == 5){
		g_bJoker = true;
		CreateJoker();
	}
	if(g_GameMod == 6){
		g_bCBS = true;
		CreateCBS();
	}
	if(g_GameMod == 7){
		g_bMurica = true;
		CreateMurica();
	}	
	if(IsValidClient(BossPlayer)){
		SDKHook(BossPlayer, SDKHook_OnTakeDamage, OnTakeDamage);
		SDKHook(BossPlayer, SDKHook_WeaponCanUse, OnWeaponCanUseBoss);
		SDKHook(BossPlayer, SDKHook_WeaponDrop, OnWeaponCanUseBoss);
	}
	if(g_isDemap && g_bGameEnable){
		CreateTimer(10.0, C4CheckStart);
		TimerC4Give = CreateTimer(60.0, C4GiveCheck, BossPlayer);
	}
	return Plugin_Continue;
} 
public Action:CreatePredator(){
	if(g_bPredator){
		decl String:ClientName[50];
		GetClientName(BossPlayer,ClientName,sizeof(ClientName));
		CS_SwitchTeam(BossPlayer, CS_TEAM_T);
		CS_RespawnPlayer(BossPlayer);
		SetEntData(BossPlayer, g_iAccount, 0 );
		SetEntPropFloat(BossPlayer, Prop_Send, "m_flLaggedMovementValue", 1.6);
		SetEntityGravity(BossPlayer, 0.5);
		SetEntityModel(BossPlayer, "models/player/mapeadores/morell/predator/predator.mdl");
		SetEntityHealth(BossPlayer, (100 + GetClientCount(true)* GetConVarInt(g_hEnergyPreda)));
		initialBossHealth = GetEntProp(BossPlayer, Prop_Send, "m_iHealth");
		if ((weaponslot1 = GetPlayerWeaponSlot(BossPlayer, 0)) != -1){
			RemovePlayerItem(BossPlayer, weaponslot1);
			GivePlayerItem(BossPlayer, "weapon_awp");
			SetEntData(BossPlayer, (( FindDataMapOffs(BossPlayer, "m_iAmmo" )) + 24 ), 150);
		}
		if ((weaponslot2 = GetPlayerWeaponSlot(BossPlayer, 1)) != -1){
			RemovePlayerItem(BossPlayer, weaponslot2);
			GivePlayerItem(BossPlayer, "weapon_deagle");
			SetEntData(BossPlayer, (( FindDataMapOffs(BossPlayer, "m_iAmmo" )) + 4 ), 150);
		}
		PrintToChat(BossPlayer, "\x04[SM]\x03 Predator Weapons are AWP + Deagle + Flash + Smoke.");
		GivePlayerItem(BossPlayer, "weapon_smokegrenade");
		GivePlayerItem(BossPlayer, "weapon_flashbang");
		PrintToChatAll("\x04[SM]\x03 Predator is %s", ClientName);
		if(g_bNV){
			SetEntProp(BossPlayer, Prop_Send, "m_bNightVisionOn", 1);
		}
		SetEntProp(BossPlayer, Prop_Send, "m_iDefaultFOV", GetConVarInt(g_hCvarFovTer));
		TimerShowHealth = CreateTimer(0.0, ShowHealth, _, TIMER_REPEAT);
	}
}
public Action:CreateEzio(){
	if(g_bEzio){
		decl String:ClientName[50];
		GetClientName(BossPlayer,ClientName,sizeof(ClientName));
		CS_SwitchTeam(BossPlayer, CS_TEAM_T);
		CS_RespawnPlayer(BossPlayer);
		SetEntData(BossPlayer, g_iAccount, 0 );
		SetEntityGravity(BossPlayer, 0.5);
		SetEntityModel(BossPlayer, "models/player/custom_player/voikanaa/acb/ezio.mdl");
		SetEntityHealth(BossPlayer, (2500 + GetClientCount(true)* GetConVarInt(g_hEnergyEzio)));
		initialBossHealth = GetEntProp(BossPlayer, Prop_Send, "m_iHealth");
		if ((weaponslot1 = GetPlayerWeaponSlot(BossPlayer, 0)) != -1){
			RemovePlayerItem(BossPlayer, weaponslot1);
		}
		if ((weaponslot2 = GetPlayerWeaponSlot(BossPlayer, 1)) != -1){
			RemovePlayerItem(BossPlayer, weaponslot2);
		}
		PrintToChat(BossPlayer, "\x04[BOSS]\x03 Ezio RAGE ability is Slow-motion.");
//		ClientCommand(BossPlayer, "slot3");
		entity_weapon = GetPlayerWeaponSlot(BossPlayer, 2);
		if (IsValidEntity(entity_weapon))
		{
			RemovePlayerItem(BossPlayer, entity_weapon);
			RemoveEdict(entity_weapon);
		}			
		PrintToChatAll("\x04[BOSS]\x03 %s has become EZIO.", ClientName);
		GivePlayerItem(BossPlayer, "item_nvgs");
		SetEntProp(BossPlayer, Prop_Send, "m_iDefaultFOV", GetConVarInt(g_hCvarFovTer));
		SetEntPropFloat(BossPlayer, Prop_Send, "m_flLaggedMovementValue", 0);
		SetEntProp(BossPlayer, Prop_Data, "m_takedamage", 0, 1);
		SetEntityRenderMode(BossPlayer,RENDER_TRANSCOLOR);
		SetEntityRenderColor(BossPlayer,0,0,0,0);		
		CreateTimer (0.0, StartSound);
		TimerShowHealth = CreateTimer(0.0, ShowHealth, _, TIMER_REPEAT);
	}
}
public Action:CreateHitman(){
	if(g_bHitman){
		decl String:ClientName[50];
		GetClientName(BossPlayer,ClientName,sizeof(ClientName));
		CS_SwitchTeam(BossPlayer, CS_TEAM_T);
		CS_RespawnPlayer(BossPlayer);
		SetEntData(BossPlayer, g_iAccount, 0 );
		SetEntityGravity(BossPlayer, 0.6);
		SetEntityModel(BossPlayer, "models/player/custom_player/voikanaa/hitman/agent47.mdl");
		SetEntityHealth(BossPlayer, (3000 + GetClientCount(true)* GetConVarInt(g_hEnergyHitman)));
		initialBossHealth = GetEntProp(BossPlayer, Prop_Send, "m_iHealth");
		if ((weaponslot1 = GetPlayerWeaponSlot(BossPlayer, 0)) != -1){
			RemovePlayerItem(BossPlayer, weaponslot1);
		}
		if ((weaponslot2 = GetPlayerWeaponSlot(BossPlayer, 1)) != -1){
			RemovePlayerItem(BossPlayer, weaponslot2);
		}
		PrintToChat(BossPlayer, "\x04[BOSS]\x03 Agent 47 RAGE ability is Reload.");	
//		ClientCommand(BossPlayer, "slot3");
		PrintToChatAll("\x04[BOSS]\x03 %s has become AGENT 47.", ClientName);
		GivePlayerItem(BossPlayer, "item_nvgs");
		entity_weapon = GetPlayerWeaponSlot(BossPlayer, 2);
		if (IsValidEntity(entity_weapon))
		{
			RemovePlayerItem(BossPlayer, entity_weapon);
			RemoveEdict(entity_weapon);
		}					
		SetEntProp(BossPlayer, Prop_Send, "m_iDefaultFOV", GetConVarInt(g_hCvarFovTer));
		SetEntPropFloat(BossPlayer, Prop_Send, "m_flLaggedMovementValue", 1.25);
		SetEntProp(BossPlayer, Prop_Data, "m_takedamage", 0, 1);
		SetEntityRenderMode(BossPlayer,RENDER_TRANSCOLOR);
		SetEntityRenderColor(BossPlayer,0,0,0,0);			
		CreateTimer (0.0, StartSound);
		TimerShowHealth = CreateTimer(0.0, ShowHealth, _, TIMER_REPEAT);
	}
}
public Action:CreateBulldozer(){
	if(g_bBulldozer){
		decl String:ClientName[50];
		GetClientName(BossPlayer,ClientName,sizeof(ClientName));
		CS_SwitchTeam(BossPlayer, CS_TEAM_T);
		CS_RespawnPlayer(BossPlayer);
		SetEntData(BossPlayer, g_iAccount, 0 );
		SetEntityGravity(BossPlayer, 0.8);
		SetEntityModel(BossPlayer, "models/player/custom_player/caleon1/nkpolice/nkpolice.mdl");
		SetEntityHealth(BossPlayer, (1000 + GetClientCount(true)* GetConVarInt(g_hEnergyBulldozer)));
		initialBossHealth = GetEntProp(BossPlayer, Prop_Send, "m_iHealth");
		if ((weaponslot1 = GetPlayerWeaponSlot(BossPlayer, 0)) != -1){
			RemovePlayerItem(BossPlayer, weaponslot1);
		}
		if ((weaponslot2 = GetPlayerWeaponSlot(BossPlayer, 1)) != -1){
			RemovePlayerItem(BossPlayer, weaponslot2);
		}
		PrintToChat(BossPlayer, "\x04[BOSS]\x03 Bulldozer RAGE ability is Bulletjam.");
		entity_weapon = GetPlayerWeaponSlot(BossPlayer, 2);
		if (IsValidEntity(entity_weapon))
		{
			RemovePlayerItem(BossPlayer, entity_weapon);
			RemoveEdict(entity_weapon);
		}			
		PrintToChatAll("\x04[BOSS]\x03 %s has become BULLDOZER.", ClientName);
		GivePlayerItem(BossPlayer, "item_nvgs");
		SetEntProp(BossPlayer, Prop_Send, "m_iDefaultFOV", GetConVarInt(g_hCvarFovTer));
		SetEntPropFloat(BossPlayer, Prop_Send, "m_flLaggedMovementValue", 0.8);
		SetEntProp(BossPlayer, Prop_Data, "m_takedamage", 0, 1);
		SetEntityRenderMode(BossPlayer,RENDER_TRANSCOLOR);
		SetEntityRenderColor(BossPlayer,0,0,0,0);			
		CreateTimer (0.0, StartSound);
		TimerShowHealth = CreateTimer(0.0, ShowHealth, _, TIMER_REPEAT);
	}
}
public Action:CreateGentlespy(){
	if(g_bGentlespy){
		decl String:ClientName[50];
		GetClientName(BossPlayer,ClientName,sizeof(ClientName));
		CS_SwitchTeam(BossPlayer, CS_TEAM_T);
		CS_RespawnPlayer(BossPlayer);
		SetEntData(BossPlayer, g_iAccount, 0 );
		SetEntityGravity(BossPlayer, 0.7);
		SetEntityModel(BossPlayer, "models/player/kuristaja/tf2/spy/spy_blu.mdl");
		SetEntityHealth(BossPlayer, (2500 + GetClientCount(true)* GetConVarInt(g_hEnergyGentlespy)));
		initialBossHealth = GetEntProp(BossPlayer, Prop_Send, "m_iHealth");
		if ((weaponslot1 = GetPlayerWeaponSlot(BossPlayer, 0)) != -1){
			RemovePlayerItem(BossPlayer, weaponslot1);
		}
		if ((weaponslot2 = GetPlayerWeaponSlot(BossPlayer, 1)) != -1){
			RemovePlayerItem(BossPlayer, weaponslot2);
		}
		PrintToChat(BossPlayer, "\x04[BOSS]\x03 Gentlespy RAGE ability is Judgement Day.");
		PrintToChatAll("\x04[BOSS]\x03 %s has become GENTLESPY.", ClientName);
		entity_weapon = GetPlayerWeaponSlot(BossPlayer, 2);
		if (IsValidEntity(entity_weapon))
		{
			RemovePlayerItem(BossPlayer, entity_weapon);
			RemoveEdict(entity_weapon);
		}				
		GivePlayerItem(BossPlayer, "item_nvgs");
		SetEntProp(BossPlayer, Prop_Send, "m_iDefaultFOV", GetConVarInt(g_hCvarFovTer));
		SetEntPropFloat(BossPlayer, Prop_Send, "m_flLaggedMovementValue", 0);
		SetEntProp(BossPlayer, Prop_Data, "m_takedamage", 0, 1);		
		CreateTimer (0.0, StartSound);
		TimerShowHealth = CreateTimer(0.0, ShowHealth, _, TIMER_REPEAT);
	}
}
public Action:CreateJoker(){
	if(g_bJoker){
		decl String:ClientName[50];
		GetClientName(BossPlayer,ClientName,sizeof(ClientName));
		CS_SwitchTeam(BossPlayer, CS_TEAM_T);
		CS_RespawnPlayer(BossPlayer);
		SetEntData(BossPlayer, g_iAccount, 0 );
		SetEntityGravity(BossPlayer, 0.8);
		SetEntityModel(BossPlayer, "models/player/mapeadores/morell/joker/joker.mdl");
		SetEntityHealth(BossPlayer, (2500 + GetClientCount(true)* GetConVarInt(g_hEnergyJoker)));
		initialBossHealth = GetEntProp(BossPlayer, Prop_Send, "m_iHealth");
		if ((weaponslot1 = GetPlayerWeaponSlot(BossPlayer, 0)) != -1){
			RemovePlayerItem(BossPlayer, weaponslot1);
		}
		if ((weaponslot2 = GetPlayerWeaponSlot(BossPlayer, 1)) != -1){
			RemovePlayerItem(BossPlayer, weaponslot2);
		}
		PrintToChat(BossPlayer, "\x04[BOSS]\x03 Joker RAGE ability is Drug.");	
		PrintToChatAll("\x04[BOSS]\x03 %s has become JOKER.", ClientName);
		GivePlayerItem(BossPlayer, "item_nvgs");
		entity_weapon = GetPlayerWeaponSlot(BossPlayer, 2);
		if (IsValidEntity(entity_weapon))
		{
			RemovePlayerItem(BossPlayer, entity_weapon);
			RemoveEdict(entity_weapon);
		}					
		SetEntProp(BossPlayer, Prop_Send, "m_iDefaultFOV", GetConVarInt(g_hCvarFovTer));
		SetEntPropFloat(BossPlayer, Prop_Send, "m_flLaggedMovementValue",0);
		SetEntProp(BossPlayer, Prop_Data, "m_takedamage", 0, 1);	
		CreateTimer (0.0, StartSound);
		TimerShowHealth = CreateTimer(0.0, ShowHealth, _, TIMER_REPEAT);
	}
}
public Action:CreateCBS(){
	if(g_bCBS){
		decl String:ClientName[50];
		GetClientName(BossPlayer,ClientName,sizeof(ClientName));
		CS_SwitchTeam(BossPlayer, CS_TEAM_T);
		CS_RespawnPlayer(BossPlayer);
		SetEntData(BossPlayer, g_iAccount, 0 );
		SetEntityGravity(BossPlayer, 0.6);
		SetEntityModel(BossPlayer, "models/player/kuristaja/tf2/sniper/sniper_red.mdl");
		SetEntityHealth(BossPlayer, (3200 + GetClientCount(true)* GetConVarInt(g_hEnergyCBS)));
		initialBossHealth = GetEntProp(BossPlayer, Prop_Send, "m_iHealth");
		if ((weaponslot1 = GetPlayerWeaponSlot(BossPlayer, 0)) != -1){
			RemovePlayerItem(BossPlayer, weaponslot1);
		}
		if ((weaponslot2 = GetPlayerWeaponSlot(BossPlayer, 1)) != -1){
			RemovePlayerItem(BossPlayer, weaponslot2);
		}
		PrintToChat(BossPlayer, "\x04[BOSS]\x03 Christian Brutal Sniper RAGE ability is The AWPer Hand.");	
//		ClientCommand(BossPlayer, "slot3");
		PrintToChatAll("\x04[BOSS]\x03 %s has become CHRISTIAN BRUTAL SNIPER.", ClientName);
		GivePlayerItem(BossPlayer, "item_nvgs");
		entity_weapon = GetPlayerWeaponSlot(BossPlayer, 2);
		if (IsValidEntity(entity_weapon))
		{
			RemovePlayerItem(BossPlayer, entity_weapon);
			RemoveEdict(entity_weapon);
		}					
		SetEntProp(BossPlayer, Prop_Send, "m_iDefaultFOV", GetConVarInt(g_hCvarFovTer));
		SetEntPropFloat(BossPlayer, Prop_Send, "m_flLaggedMovementValue", 1.3);
		SetEntProp(BossPlayer, Prop_Data, "m_takedamage", 0, 1);
		SetEntityRenderMode(BossPlayer,RENDER_TRANSCOLOR);
		SetEntityRenderColor(BossPlayer,0,0,0,0);			
		CreateTimer (0.0, StartSound);
		TimerShowHealth = CreateTimer(0.0, ShowHealth, _, TIMER_REPEAT);
	}
}
public Action:CreateMurica(){
	if(g_bMurica){
		decl String:ClientName[50];
		GetClientName(BossPlayer,ClientName,sizeof(ClientName));
		CS_SwitchTeam(BossPlayer, CS_TEAM_T);
		CS_RespawnPlayer(BossPlayer);
		SetEntData(BossPlayer, g_iAccount, 0 );
		SetEntityGravity(BossPlayer, 0.5);
		SetEntityModel(BossPlayer, "models/player/kuristaja/tf2/soldier/soldier_red.mdl");
		SetEntityHealth(BossPlayer, (2800 + GetClientCount(true)* GetConVarInt(g_hEnergyMurica)));
		initialBossHealth = GetEntProp(BossPlayer, Prop_Send, "m_iHealth");
		if ((weaponslot1 = GetPlayerWeaponSlot(BossPlayer, 0)) != -1){
			RemovePlayerItem(BossPlayer, weaponslot1);
		}
		if ((weaponslot2 = GetPlayerWeaponSlot(BossPlayer, 1)) != -1){
			RemovePlayerItem(BossPlayer, weaponslot2);
		}
		PrintToChat(BossPlayer, "\x04[BOSS]\x03 The First American RAGE ability is Shotgun Rush.");	
//		ClientCommand(BossPlayer, "slot3");
		PrintToChatAll("\x04[BOSS]\x03 %s has become THE FIRST AMERICAN.", ClientName);
		GivePlayerItem(BossPlayer, "item_nvgs");
		entity_weapon = GetPlayerWeaponSlot(BossPlayer, 2);
		if (IsValidEntity(entity_weapon))
		{
			RemovePlayerItem(BossPlayer, entity_weapon);
			RemoveEdict(entity_weapon);
		}					
		SetEntProp(BossPlayer, Prop_Send, "m_iDefaultFOV", GetConVarInt(g_hCvarFovTer));
		SetEntPropFloat(BossPlayer, Prop_Send, "m_flLaggedMovementValue", 1.2);
		SetEntProp(BossPlayer, Prop_Data, "m_takedamage", 0, 1);
		SetEntityRenderMode(BossPlayer,RENDER_TRANSCOLOR);
		SetEntityRenderColor(BossPlayer,0,0,0,0);			
		CreateTimer (0.0, StartSound);
		TimerShowHealth = CreateTimer(0.0, ShowHealth, _, TIMER_REPEAT);
	}
}
public Action:CreateDukeNukem(){
	if(g_bDuke){
		decl String:ClientName[50];
		GetClientName(BossPlayer,ClientName,sizeof(ClientName));
		CS_SwitchTeam(BossPlayer, CS_TEAM_T);
		CS_RespawnPlayer(BossPlayer);
		SetEntData(BossPlayer, g_iAccount, 0 );
		SetEntPropFloat(BossPlayer, Prop_Send, "m_flLaggedMovementValue", 1.2); 
		SetEntityGravity(BossPlayer, 0.5);
		SetEntityModel(BossPlayer, "models/player/kuristaja/duke/duke.mdl");
		SetEntityHealth(BossPlayer, (100 + GetClientCount(true)* GetConVarInt(g_hEnergyDuke)));
		initialBossHealth = GetEntProp(BossPlayer, Prop_Send, "m_iHealth");
		if ((weaponslot1 = GetPlayerWeaponSlot(BossPlayer, 0)) != -1){
			RemovePlayerItem(BossPlayer, weaponslot1);
			GivePlayerItem(BossPlayer, "weapon_scar20");
		}
		if ((weaponslot2 = GetPlayerWeaponSlot(BossPlayer, 1)) != -1){
			RemovePlayerItem(BossPlayer, weaponslot2);
			GivePlayerItem(BossPlayer, "weapon_elite");
		}
		PrintToChat(BossPlayer, "\x04[SM]\x03 DukeNukem Weapons are Scar20+ DualBeretta + Flash + Smoke.");
		GivePlayerItem(BossPlayer, "weapon_smokegrenade");
		GivePlayerItem(BossPlayer, "weapon_flashbang");
		PrintToChatAll("\x04[SM]\x03 DukeNukem is %s", ClientName);
		if(g_bNV){
			SetEntProp(BossPlayer, Prop_Send, "m_bNightVisionOn", 1);
		}
		SetEntProp(BossPlayer, Prop_Send, "m_iDefaultFOV", GetConVarInt(g_hCvarFovTer));
		TimerShowHealth = CreateTimer(0.0, ShowHealth, _, TIMER_REPEAT);
	}
}
public Action:StartSound(Handle:timer, any:client){
	if(g_bEzio){
	EmitSoundToAllAny("bossmode/intro_ezio.mp3",SOUND_FROM_PLAYER,SNDCHAN_STATIC);
	CreateTimer(57.0,GameOnPre,BossPlayer);
	}
	else if(g_bHitman){
	EmitSoundToAllAny("bossmode/intro_hitman.mp3",SOUND_FROM_PLAYER,SNDCHAN_STATIC);
	CreateTimer(55.0,GameOnPre,BossPlayer);
	}	
	else if(g_bBulldozer){
	EmitSoundToAllAny("bossmode/intro_bulldozer.mp3",SOUND_FROM_PLAYER,SNDCHAN_STATIC);
	CreateTimer(56.0,GameOnPre,BossPlayer);
	}
	else if(g_bGentlespy){
	EmitSoundToAllAny("bossmode/intro_gentlespy.mp3",SOUND_FROM_PLAYER,SNDCHAN_STATIC);
	CreateTimer(5.0,GameOnPre,BossPlayer);
	}
	else if(g_bJoker){
	EmitSoundToAllAny("bossmode/intro_joker.mp3",SOUND_FROM_PLAYER,SNDCHAN_STATIC);
	CreateTimer(56.0,GameOnPre,BossPlayer);
	}
	else if(g_bCBS){
	EmitSoundToAllAny("bossmode/intro_CBS.mp3",SOUND_FROM_PLAYER,SNDCHAN_STATIC);
	CreateTimer(5.0,GameOnPre,BossPlayer);
	}
	else if(g_bMurica){
	EmitSoundToAllAny("bossmode/intro_murica.mp3",SOUND_FROM_PLAYER,SNDCHAN_STATIC);
	CreateTimer(56.0,GameOnPre,BossPlayer);
	}	
}
public Action:GameOnPre(Handle:timer, any:client){	
	if(IsValidClient(BossPlayer))
		{
		GameStarted = true;
		if(g_bEzio)
		{
		EmitSoundToAllAny("bossmode/start_ezio.mp3");	
		SetEntityRenderMode(BossPlayer,RENDER_NORMAL);
		SetEntityRenderColor(BossPlayer,255,255,255,255);
		GivePlayerItem(BossPlayer,"weapon_knife");
		CreateTimer(3.0,GameOn,BossPlayer);
		}
		else if(g_bHitman)
		{
		EmitSoundToAllAny("bossmode/start_hitman.mp3");		
		SetEntityRenderMode(BossPlayer,RENDER_NORMAL);
		SetEntityRenderColor(BossPlayer,255,255,255,255);
		CreateTimer(5.0,GameOn,BossPlayer);
		}
		else if(g_bBulldozer)
		{
		SetEntPropFloat(BossPlayer, Prop_Send, "m_flLaggedMovementValue", 0.6);
		int bulldzstart;
		bulldzstart = GetRandomInt(1,3)
		if(bulldzstart == 1)
		EmitSoundToAllAny("bossmode/start_bulldozer_1.mp3");
		else if(bulldzstart == 2)
		EmitSoundToAllAny("bossmode/start_bulldozer_2.mp3");
		else if(bulldzstart == 3)
		EmitSoundToAllAny("bossmode/start_bulldozer_3.mp3");
		CreateTimer(4.0,GameOn,BossPlayer);	
		}
		else if(g_bGentlespy)
		{
		EmitSoundToAllAny("bossmode/start_gentlespy.mp3");
		SetEntityRenderMode(BossPlayer,RENDER_NORMAL);
		SetEntityRenderColor(BossPlayer,255,255,255,255);
		CreateTimer(5.0,GameOn,BossPlayer);
		}
		else if(g_bJoker)
		{
		EmitSoundToAllAny("bossmode/start_joker.mp3");
		CreateTimer(4.0,GameOn,BossPlayer);
		}
		else if(g_bCBS)
		{
		EmitSoundToAllAny("bossmode/start_cbs.mp3");
		SetEntityRenderMode(BossPlayer,RENDER_NORMAL);
		SetEntityRenderColor(BossPlayer,255,255,255,255);
		CreateTimer(5.0,GameOn,BossPlayer);
		}
		else if(g_bMurica)
		{
		int muricastart;
		muricastart = GetRandomInt(1,3);
		if(muricastart == 1)
		EmitSoundToAllAny("bossmode/start_murica_1.mp3");	
		else if(muricastart == 2)
		EmitSoundToAllAny("bossmode/start_murica_2.mp3");
		else if(muricastart == 3)
		EmitSoundToAllAny("bossmode/start_murica_3.mp3");
		SetEntityRenderMode(BossPlayer,RENDER_NORMAL);
		SetEntityRenderColor(BossPlayer,255,255,255,255);
		CreateTimer(5.0,GameOn,BossPlayer);
		}		
		}		
}
public Action:GameOn(Handle:timer, any:client){	
	if(IsValidClient(BossPlayer))
		{
		GameStarted = true;
		if(g_bEzio)
		{
		SetEntPropFloat(BossPlayer, Prop_Send, "m_flLaggedMovementValue", 1.4);	 		
		}
		else if(g_bHitman)
		{	
		GivePlayerItem(BossPlayer,"weapon_knife");
		GivePlayerItem(BossPlayer,"weapon_usp_silencer");
		}
		else if(g_bBulldozer)
		{	
		SetEntityRenderMode(BossPlayer,RENDER_NORMAL);
		SetEntityRenderColor(BossPlayer,255,255,255,255);
		GivePlayerItem(BossPlayer,"weapon_knife");
		GivePlayerItem(BossPlayer,"weapon_m249");	
		}
		else if(g_bGentlespy)
		{
		SetEntPropFloat(BossPlayer, Prop_Send, "m_flLaggedMovementValue", 1.2);
		GivePlayerItem(BossPlayer,"weapon_knife");			
		CreateTimer(15.0,Cloakwatch,client);
		}
		else if(g_bJoker)
		{
		SetEntPropFloat(BossPlayer, Prop_Send, "m_flLaggedMovementValue", 1.2);
		GivePlayerItem(BossPlayer,"weapon_knife");
		SetEntityRenderMode(BossPlayer,RENDER_TRANSCOLOR);
		SetEntityRenderColor(BossPlayer,0,0,0,0);
		}
		else if(g_bCBS)
		{	
		GivePlayerItem(BossPlayer,"weapon_knife");
		}
		else if(g_bMurica)
		{	
		GivePlayerItem(BossPlayer,"weapon_knife");
		}		
		SetEntProp(BossPlayer, Prop_Data, "m_takedamage", 2, 1);
		CreateTimer(0.0,Rageometer,client,TIMER_REPEAT);		
		}
}
public Action:Command_Superjump(client, const String:sCommand[], iArgs)
{
	if((IsValidClient(client)) && (client == BossPlayer)){
		decl Float:vVel[3];
		vVel[0] = 0;
		vVel[1] = 0;
		vVel[2] = 1500;
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vVel);
	}
}
public Action:Cloakwatch(Handle:timer, any:client){
	if(IsValidClient(BossPlayer) && IsPlayerAlive(BossPlayer) && (g_bGentlespy)){
		Cloakready = true;
		SetClientOverlay(BossPlayer, "1_vs_all/rageready");	
	}
}
public Action:Command_Cloak(client, const String:sCommand[], iArgs)
{
	if((IsValidClient(client)) && (client == BossPlayer) && Cloakready && (g_bGentlespy)){
		Cloak = true;
		SetClientOverlay(client, "");
		SetEntityRenderMode(client,RENDER_TRANSCOLOR);
		SetEntityRenderColor(client,255,255,255,0);		
		entity_weapon = GetPlayerWeaponSlot(client, 2);
		if (IsValidEntity(entity_weapon))
		{
			RemovePlayerItem(BossPlayer, entity_weapon);
			RemoveEdict(entity_weapon);
		}				
		EmitSoundToAllAny("bossmode/cloak_gentlespy.mp3");
		CreateTimer(7.5,Cloakcooldown,client);		
	}
}
public Action:Cloakcooldown(Handle:timer, any:client){
	if(IsValidClient(BossPlayer) && IsPlayerAlive(BossPlayer) && (g_bGentlespy)){
		Cloak = false;
		SetEntityRenderMode(client,RENDER_NORMAL);
		SetEntityRenderColor(client,255,255,255,255);	
		Cloakready = false;
		GivePlayerItem(client,"weapon_knife");
		int cloakend;
		cloakend = GetRandomInt(1,2);
		if(cloakend == 1)
		EmitSoundToAllAny("bossmode/endcloak_gentlespy_1.mp3");
		else if(cloakend == 2)
		EmitSoundToAllAny("bossmode/endcloak_gentlespy_2.mp3");
		CreateTimer(15.0,Cloakwatch,client);
	}
}
public Action:Rageometer(Handle:timer, any:client){
	if(!IsValidClient(BossPlayer))
		return Plugin_Handled;
	if(IsValidClient(BossPlayer))
	currentHealth = GetEntProp(BossPlayer, Prop_Send, "m_iHealth");
	if(IsValidClient(BossPlayer) && IsPlayerAlive(BossPlayer) && (!g_bGentlespy)){
	if(initialBossHealth >= 40000){
		if((Ragecount == 0) && ((initialBossHealth *5/7) < currentHealth <= (initialBossHealth *6/7))){
			RageStart = true;
			SetClientOverlay(BossPlayer, "1_vs_all/rageready");		
		}
		else if((Ragecount == 1) && ((initialBossHealth *4/7) < currentHealth <= (initialBossHealth *5/7))){
			RageStart = true;
			SetClientOverlay(BossPlayer, "1_vs_all/rageready");		
		}
		else if((Ragecount == 2) && ((initialBossHealth *3/7) < currentHealth <= (initialBossHealth *4/7))){
			RageStart = true;
			SetClientOverlay(BossPlayer, "1_vs_all/rageready");		
		}			
		else if((Ragecount == 3) && ((initialBossHealth *2/7) < currentHealth <= (initialBossHealth *3/7))){
			RageStart = true;
			SetClientOverlay(BossPlayer, "1_vs_all/rageready");		
		}
		else if((Ragecount == 4) && ((initialBossHealth *1/7) < currentHealth <= (initialBossHealth *2/7))){
			RageStart = true;
			SetClientOverlay(BossPlayer, "1_vs_all/rageready");		
		}
		else if((Ragecount == 5) && (currentHealth <= (initialBossHealth *1/7))){
			RageStart = true;
			SetClientOverlay(BossPlayer, "1_vs_all/rageready");		
		}					
	}
	else if(initialBossHealth >= 28000){
		if((Ragecount == 0) && ((initialBossHealth *2/3) < currentHealth <= (initialBossHealth *5/6))){
			RageStart = true;
			SetClientOverlay(BossPlayer, "1_vs_all/rageready");		
		}
		else if((Ragecount == 1) && ((initialBossHealth *1/2) < currentHealth <= (initialBossHealth *2/3))){
			RageStart = true;
			SetClientOverlay(BossPlayer, "1_vs_all/rageready");		
		}
		else if((Ragecount == 2) && ((initialBossHealth *1/3) < currentHealth <= (initialBossHealth *1/2))){
			RageStart = true;
			SetClientOverlay(BossPlayer, "1_vs_all/rageready");		
		}			
		else if((Ragecount == 3) && ((initialBossHealth *1/6) < currentHealth <= (initialBossHealth *1/3))){
			RageStart = true;
			SetClientOverlay(BossPlayer, "1_vs_all/rageready");		
		}	
		else if((Ragecount == 4) && (currentHealth <= (initialBossHealth *1/6))){
			RageStart = true;
			SetClientOverlay(BossPlayer, "1_vs_all/rageready");		
		}		
	}
	else if(initialBossHealth >= 15000){
		if((Ragecount == 0) && ((initialBossHealth *3/5) < currentHealth <= (initialBossHealth *4/5))){
			RageStart = true;
			SetClientOverlay(BossPlayer, "1_vs_all/rageready");		
		}
		else if((Ragecount == 1) && ((initialBossHealth *2/5) < currentHealth <= (initialBossHealth *3/5))){
			RageStart = true;
			SetClientOverlay(BossPlayer, "1_vs_all/rageready");		
		}
		else if((Ragecount == 2) && ((initialBossHealth *1/5) < currentHealth <= (initialBossHealth *2/5))){
			RageStart = true;
			SetClientOverlay(BossPlayer, "1_vs_all/rageready");		
		}			
		else if((Ragecount == 3) && (currentHealth <= (initialBossHealth *1/5))){
			RageStart = true;
			SetClientOverlay(BossPlayer, "1_vs_all/rageready");		
		}	
	}
	else if(initialBossHealth >= 8000){
		if((Ragecount == 0) && ((initialBossHealth *1/2) < currentHealth <= (initialBossHealth *3/4))){
			RageStart = true;
			SetClientOverlay(BossPlayer, "1_vs_all/rageready");		
		}
		else if((Ragecount == 1) && ((initialBossHealth *1/4) < currentHealth <= (initialBossHealth *1/2))){
			RageStart = true;
			SetClientOverlay(BossPlayer, "1_vs_all/rageready");		
		}
		else if((Ragecount == 2) && (currentHealth <= (initialBossHealth *1/4))){
			RageStart = true;
			SetClientOverlay(BossPlayer, "1_vs_all/rageready");		
		}				
	}		
	else if(initialBossHealth >= 5000){
		if((Ragecount == 0) && ((initialBossHealth *1/3) < currentHealth <= (initialBossHealth *2/3))){
			RageStart = true;
			SetClientOverlay(BossPlayer, "1_vs_all/rageready");		
		}
		else if((Ragecount == 1) && (currentHealth <= (initialBossHealth *1/3))){
			RageStart = true;
			SetClientOverlay(BossPlayer, "1_vs_all/rageready");		
		}			
	}
	else if((initialBossHealth <= 5000) && (Ragecount == 0) && (currentHealth <= 2800)){
		RageStart = true;
		SetClientOverlay(BossPlayer, "1_vs_all/rageready");
	}
	}
	return Plugin_Continue;	
}
public Action:Event_RoundEnd(Handle:event, const String:name[], bool:dontBroadcast){
	if(!g_bGameEnable)return Plugin_Handled;
	for (new client = 1; client <= MaxClients; client++){
		if(IsValidClient(client) && (GetClientTeam(client) == CS_TEAM_T) && (client == BossPlayer)){
			if((g_bEzio) && IsPlayerAlive(BossPlayer))
			{
			EmitSoundToAllAny("bossmode/end_ezio.mp3",SOUND_FROM_PLAYER,SNDCHAN_STATIC);
			}
			if((g_bGentlespy) && IsPlayerAlive(BossPlayer))
			{
			EmitSoundToAllAny("bossmode/end_gentlespy.mp3",SOUND_FROM_PLAYER,SNDCHAN_STATIC);
			}
			ServerCommand("sm_slay %s",GetClientUserId(client));
			CreateTimer(2.0, EndRoundPlayerSelected, client);
		}
		if(IsValidClient(client) && (GetClientTeam(client) == CS_TEAM_T)){
			if((weaponslot1 = GetPlayerWeaponSlot(client, 0)) != -1){
				RemovePlayerItem(client, weaponslot1);
			}
			if ((weaponslot2 = GetPlayerWeaponSlot(client, 1)) != -1){
				RemovePlayerItem(client, weaponslot2);
				SetEntityRenderMode(client, RENDER_NORMAL);
				SetEntityRenderColor(client, 255, 255, 255, 255); 
				SetClientOverlay(client, "");
			}
			if(IsValidClient(client) && (GetClientTeam(client) == CS_TEAM_CT)&& (client != BossPlayer)){
				SetEntityRenderMode(client, RENDER_NORMAL);
				SetEntityRenderColor(client, 255, 255, 255, 255); 
				SetClientOverlay(client, "");
			}
		}
	}
	g_bLastCT = false;
	g_bPredator = false;
	g_bEzio = false;
	g_bDuke = false;
	Ragecount = 0;
	RageStart = false;
	EMP = false;
	cbsrage = false;
	Cloakready = false;
	Cloak = false;
	ClearTimer(TimerC4Give);
	//KillTimer(TimerShowHealth);
	return Plugin_Continue;		
}
public void OnClientDisconnect(client)
{
	if(!g_bGameEnable)return;
	else
	if(client == BossPlayer)
	{
		CS_TerminateRound(2.0, CSRoundEnd_Draw);
		SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
		SetClientOverlay(client, "");
		BossAlive = GetPlayerSelectedCount();
		if(BossAlive <= 0){
			CS_TerminateRound(1.0, CSRoundEnd_Draw);
		}
	}
}
public Player_Spawn(Handle:event, const String:name[], bool:dontBroadcast) 
{
	if(!g_bGameEnable)return false;
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (client <= 0) return false;
	if((IsValidClient(client) && GetClientTeam(client) == CS_TEAM_T) && (client != BossPlayer)){
		CS_SwitchTeam(client, CS_TEAM_CT);
		//ForcePlayerSuicide(client);
		CS_RespawnPlayer(client);
		SetEntityGravity(client, 1.0);
		SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
		SetEntProp(client, Prop_Send, "m_bNightVisionOn", 0);
		SetEntProp(client, Prop_Send, "m_iDefaultFOV", 90);
		if ((weaponslot1 = GetPlayerWeaponSlot(client, 0)) != -1){
			RemovePlayerItem(client, weaponslot1);
		}
		if ((weaponslot2 = GetPlayerWeaponSlot(client, 1)) != -1){
			RemovePlayerItem(client, weaponslot2);
		}
//		GivePlayerItem(client, "weapon_m4a1");
//		GivePlayerItem(client, "weapon_deagle");
		SetEntData(client, g_iAccount, 16000 );
		SetEntityRenderMode(client, RENDER_NORMAL);
		SetEntityRenderColor(client, 255, 255, 255, 255);
		if ((weaponslotc4 = GetPlayerWeaponSlot(client, 4)) != -1){
			RemovePlayerItem(client, weaponslotc4);
		}
	}	
	CreateTimer(0.0, RemoveRadar, client);
	if((IsValidClient(client) && GetClientTeam(client) == CS_TEAM_CT) && (client != BossPlayer)){
		SetEntProp(client, Prop_Send, "m_bNightVisionOn", 0);
		SetEntProp(client, Prop_Send, "m_iDefaultFOV", 90);
		SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
		if ((weaponslot1 = GetPlayerWeaponSlot(client, 0)) != -1){
			RemovePlayerItem(client, weaponslot1);
		}
		if ((weaponslot2 = GetPlayerWeaponSlot(client, 1)) != -1){
			RemovePlayerItem(client, weaponslot2);
		}
//		GivePlayerItem(client, "weapon_m4a1");
//		GivePlayerItem(client, "weapon_deagle");
		SetEntData(client, g_iAccount, 16000 );
		SetEntityGravity(client, 1.0);
		SetEntityRenderMode(client, RENDER_NORMAL);
		SetEntityRenderColor(client, 255, 255, 255, 255); 
	}
	return true;
}
public PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	if(!g_bGameEnable)return false;
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (client <= 0) return false;
	if (BossPlayer <= 0) return false;
	if(IsValidClient(client) && (GetClientTeam(client) == CS_TEAM_T) && (client == BossPlayer)){
		KillTimer(TimerShowHealth);
		SDKUnhook(BossPlayer, SDKHook_WeaponCanUse, OnWeaponCanUseBoss);
		SDKUnhook(BossPlayer, SDKHook_WeaponDrop, OnWeaponCanUseBoss);
		CreateTimer(2.0, EndRoundPlayerSelected, client);
	}
	else if(IsValidClient(client) && (GetClientTeam(client) == CS_TEAM_CT) && (client != BossPlayer) && (!g_bLastCT))
	{
	if((!g_bBulldozer) && (!g_bGentlespy)){
		g_AttackRandomSound = GetRandomInt(1,3)
	if(g_bEzio){
		if(g_AttackRandomSound == 1)
		EmitSoundToAllAny("bossmode/attack_ezio_1.mp3");
		else if(g_AttackRandomSound == 2)
		EmitSoundToAllAny("bossmode/attack_ezio_2.mp3");
		else
		EmitSoundToAllAny("bossmode/attack_ezio_3.mp3");
		}
	else if(g_bHitman){
		if(g_AttackRandomSound == 1)
		EmitSoundToAllAny("bossmode/attack_hitman_1.mp3");
		else if(g_AttackRandomSound == 2)
		EmitSoundToAllAny("bossmode/attack_hitman_2.mp3");
		else
		EmitSoundToAllAny("bossmode/attack_hitman_3.mp3");
		}
	else if(g_bJoker){
		if(g_AttackRandomSound == 1)
		EmitSoundToAllAny("bossmode/attack_joker_1.mp3");
		else if(g_AttackRandomSound == 2)
		EmitSoundToAllAny("bossmode/attack_joker_2.mp3");
		else
		EmitSoundToAllAny("bossmode/attack_joker_3.mp3");
		}
	else if(g_bCBS){
	if(cbsrage)
		EmitSoundToAllAny("bossmode/attack_cbs_rage.mp3");
	else if(!cbsrage)
	{
		if(g_AttackRandomSound == 1)
		EmitSoundToAllAny("bossmode/attack_cbs_1.mp3");
		else if(g_AttackRandomSound == 2)
		EmitSoundToAllAny("bossmode/attack_cbs_2.mp3");
		else
		EmitSoundToAllAny("bossmode/attack_cbs_3.mp3");
		}
	}
	}
	else if(g_bBulldozer){
		g_AttackRandomSound = GetRandomInt(1,10)
		if(g_AttackRandomSound == 3)
		EmitSoundToAllAny("bossmode/attack_bulldozer_1.mp3");
		else if(g_AttackRandomSound == 5)
		EmitSoundToAllAny("bossmode/attack_bulldozer_2.mp3");
		else if(g_AttackRandomSound == 7)
		EmitSoundToAllAny("bossmode/attack_bulldozer_3.mp3");
		else if(g_AttackRandomSound == 8)
		EmitSoundToAllAny("bossmode/attack_bulldozer_4.mp3");		
	}
	else if(g_bGentlespy){
		g_AttackRandomSound = GetRandomInt(1,10);
		if(g_AttackRandomSound == 1)
		EmitSoundToAllAny("bossmode/attack_gentlespy_1.mp3");
		else if(g_AttackRandomSound == 3)
		EmitSoundToAllAny("bossmode/attack_gentlespy_2.mp3");
		else if(g_AttackRandomSound == 5)
		EmitSoundToAllAny("bossmode/attack_gentlespy_3.mp3");
		else if(g_AttackRandomSound == 7)
		EmitSoundToAllAny("bossmode/attack_gentlespy_4.mp3");
		else if(g_AttackRandomSound == 9)
		EmitSoundToAllAny("bossmode/attack_gentlespy_5.mp3");
		else
		EmitSoundToAllAny("bossmode/attack_gentlespy_0.mp3");						
	}
	else if(g_bMurica){
		g_AttackRandomSound = GetRandomInt(1,6);
		if(g_AttackRandomSound == 1)
		EmitSoundToAllAny("bossmode/attack_murica_1.mp3");
		else if(g_AttackRandomSound == 2)
		EmitSoundToAllAny("bossmode/attack_murica_2.mp3");
		else if(g_AttackRandomSound == 3)
		EmitSoundToAllAny("bossmode/attack_murica_3.mp3");
		else if(g_AttackRandomSound == 4)
		EmitSoundToAllAny("bossmode/attack_murica_4.mp3");
		else if(g_AttackRandomSound == 5)
		EmitSoundToAllAny("bossmode/attack_murica_5.mp3");
		else if(g_AttackRandomSound == 6)
		EmitSoundToAllAny("bossmode/attack_murica_6.mp3");
		}	
	}
	BossAlive = GetPlayerSelectedCount();
	if(BossAlive <= 0) return false;
	if(BossAlive >= 1){
		LastCT = GetPlayerCount();
	}
	SDKUnhook(client, SDKHook_WeaponCanUse, OnWeaponCanUseBoss);
	SDKUnhook(client, SDKHook_WeaponDrop, OnWeaponCanUseBoss);
	if(LastCT <= 0) return false;
	if(LastCT == 1){
		RageStart = false;
		g_bLastCT = true;
		decl String:LastCTName[50];
		decl String:PlayerSName[50];
		if(IsValidClient(client) && (GetClientTeam(client) == CS_TEAM_T) && (client == BossPlayer)){
			GetClientName(BossPlayer,PlayerSName,sizeof(PlayerSName));
		}
		for (new i = 1; i <= MaxClients; i++){
			if ((IsValidClient(i) && IsPlayerAlive(i) && (GetClientTeam(i) == CS_TEAM_CT)) || (IsValidClient(i) && IsFakeClient(i) && IsPlayerAlive(i) && (GetClientTeam(i) == CS_TEAM_CT))){
				if(g_bGentlespy)
				EmitSoundToAllAny("bossmode/solo_gentlespy.mp3");
				if(g_bMurica)
				EmitSoundToAllAny("bossmode/solo_murica.mp3");
				EmitSoundToClientAny(i,"bossmode/showdown.mp3");
				GetClientName(BossPlayer,PlayerSName,sizeof(PlayerSName));
				GetClientName(i,LastCTName,sizeof(LastCTName));
				PrintToChatAll("\x04[SM]\x03 Showdown \x05 %s \x03VS \x05 %s.", PlayerSName, LastCTName);
//				SetClientOverlay(i, "1_vs_all/showdown");
//				SetClientOverlay(BossPlayer, "1_vs_all/showdown");
//				SetEntityHealth(BossPlayer, 100);
//				SetEntityRenderMode(i, RENDER_NORMAL);
//				SetEntityRenderColor(BossPlayer, 255, 255, 255, 255);
//				SetEntityRenderMode(BossPlayer, RENDER_NORMAL);
//				SetEntityRenderColor(i, 255, 255, 255, 255);				
//				SetEntityHealth(i, 100);
				CreateTimer(3.0, RemoveOverlay, i);
				CreateTimer(3.0, RemoveOverlay, BossPlayer);
//				if(g_bNV){
//					SetEntProp(i, Prop_Send, "m_bNightVisionOn", 1);
//				}
				SetEntProp(i, Prop_Send, "m_iDefaultFOV", GetConVarInt(g_hCvarFovTer));
				SDKHook(i, SDKHook_WeaponCanUse, OnWeaponCanUseBoss);
				SDKHook(i, SDKHook_WeaponDrop, OnWeaponCanUseBoss);
			}
		}
		return true;
	}
	else
	return LastCT;
}
public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype){
	if (BossPlayer <= 0) return Plugin_Handled;
//	currentHealth = GetEntProp(BossPlayer, Prop_Send, "m_iHealth");
//	if((currentHealth <= (initialBossHealth *3/4)) && (victim == BossPlayer) && (!g_bLastCT)){
//		RageStart = true;
//		while (currentHealth > (initialBossHealth *1/2))
//		{
//		}
//		if((currentHealth <= (initialBossHealth *1/2)) && (victim == BossPlayer))
//		{
//		RageStart = true;
//		SetClientOverlay(victim, "1_vs_all/rageready");		
//		}		
//	}	
	return Plugin_Continue;	
}
public Action:OnItemPickUp(Handle:hEvent, const String:szName[], bool:bDontBroadcast){
	if(!g_bGameEnable)return Plugin_Handled;
	new iClient = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	if (iClient <= 0) return Plugin_Handled;
		if(IsValidClient(iClient) && (GetClientTeam(iClient) == CS_TEAM_T) && (iClient == BossPlayer)){
			if ((weaponslot1 = GetPlayerWeaponSlot(iClient, 0)) != -1){
				RemovePlayerItem(iClient, weaponslot1);
			}
			if ((weaponslot2 = GetPlayerWeaponSlot(iClient, 1)) != -1){
				RemovePlayerItem(iClient, weaponslot2);
			}
			ClientCommand(iClient, "slot3");
		}
	if(g_bPredator){
		if(IsValidClient(iClient) && (GetClientTeam(iClient) == CS_TEAM_T) && (iClient == BossPlayer)){
			if ((weaponslot1 = GetPlayerWeaponSlot(iClient, 0)) != -1){
				return Plugin_Handled;
			}
			if ((weaponslot2 = GetPlayerWeaponSlot(iClient, 1)) != -1){
				return Plugin_Handled;
			}
		}
		if(IsValidClient(iClient) && (GetClientTeam(iClient) == CS_TEAM_CT) && (g_bLastCT)){
			if ((weaponslot1 = GetPlayerWeaponSlot(iClient, 0)) != -1){
				return Plugin_Handled;
			}
			if ((weaponslot2 = GetPlayerWeaponSlot(iClient, 1)) != -1){
				return Plugin_Handled;
			}
		}
	}
	if(g_bDuke){
		if(IsValidClient(iClient) && (GetClientTeam(iClient) == CS_TEAM_T) && (iClient == BossPlayer)){
			if ((weaponslot1 = GetPlayerWeaponSlot(iClient, 0)) != -1){
				return Plugin_Handled;
			}
			if ((weaponslot2 = GetPlayerWeaponSlot(iClient, 1)) != -1){
				return Plugin_Handled;
			}
		}
		if(IsValidClient(iClient) && (GetClientTeam(iClient) == CS_TEAM_CT) && (g_bLastCT)){
			if ((weaponslot1 = GetPlayerWeaponSlot(iClient, 0)) != -1){
				return Plugin_Handled;
			}
			if ((weaponslot2 = GetPlayerWeaponSlot(iClient, 1)) != -1){
				return Plugin_Handled;
			}
		}
	}
	return Plugin_Continue;
}
public OnGameFrame()
{
	for(new i = 1; i < MaxClients; i++)
	{
		if(IsClientInGame(i) && IsPlayerAlive(i))
		{
			new MoveType:MT_MoveType = GetEntityMoveType(i), Float:fGravity = GetEntityGravity(i);
			if(MT_MoveType == MOVETYPE_LADDER)
			{
				if(fGravity != 0.0)
				{
					g_fBossGravity[i] = fGravity;
				}
			}
			else
			{
				if(gMT_MoveTypeBoss[i] == MOVETYPE_LADDER)
				{
					SetEntityGravity(i, g_fBossGravity[i]);
				}
				g_fBossGravity[i] = fGravity;
			}
			gMT_MoveTypeBoss[i] = MT_MoveType;
		}
		else
		{
			if(IsValidClient(i) && (GetClientTeam(i) == CS_TEAM_T) && (i == BossPlayer)){
				g_fBossGravity[i] = 0.5;
				if(g_bEzio){
					g_fBossGravity[i] = 0.3;
				}
				gMT_MoveTypeBoss[i] = MOVETYPE_WALK;
			}
		}
	}
}
//TIMERS
public Action:EndRoundPlayerSelected(Handle:timer, any:client){
	if (client <= 0) return Plugin_Handled;
	if(IsValidClient(client) && (client != BossPlayer)){
		SetEntityRenderMode(client, RENDER_NORMAL);
		SetEntityRenderColor(client, 255, 255, 255, 255); 
	}
	if(IsValidClient(client) && (GetClientTeam(client) == CS_TEAM_T) && (client == BossPlayer)){
		CheckRealPlayers = GetPlayerCountRealPlayers();
		if(CheckRealPlayers >= 2){
			OldPlayerSelected = BossPlayer;
		}
		CS_SwitchTeam(client, CS_TEAM_CT);
		SetEntityGravity(client, 1.0);
		SetEntityRenderMode(client, RENDER_NORMAL);
		SetEntityRenderColor(client, 255, 255, 255, 255);  
		SetEntData(client, g_iAccount, 16000 );
		SetEntProp(client, Prop_Send, "m_bNightVisionOn", 0);
		SetEntProp(client, Prop_Send, "m_iDefaultFOV", 90);
		SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
		if ((weaponslot1 = GetPlayerWeaponSlot(client, 0)) != -1){
			RemovePlayerItem(client, weaponslot1);
		}
		if ((weaponslot2 = GetPlayerWeaponSlot(client, 1)) != -1){
			RemovePlayerItem(client, weaponslot2);
		}
//		GivePlayerItem(client, "weapon_m4a1");
	//	GivePlayerItem(client, "weapon_deagle");
		SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
		SetClientOverlay(client, "");
	}
	return Plugin_Handled;
}
public Action:ShowHealth(Handle:timer, any:client){
	for(new i = 1; i <= MaxClients; i++)
	{
		if((IsValidClient(i)) && (IsPlayerAlive(i)) && (GetClientTeam(i) == CS_TEAM_CT) && g_bGameEnable){
			if(IsValidClient(BossPlayer) && IsPlayerAlive(BossPlayer)){
				currentHealth = GetEntProp(BossPlayer, Prop_Send, "m_iHealth");
				PrintHintText(i, "Boss Health: \"%d\"", currentHealth);
			}
		}
	}
	return Plugin_Continue;
}
public Action:C4GiveCheck(Handle:timer, any:client){
	if((IsValidClient(client)) && g_bGameEnable){
		if ((weaponslotc4 = GetPlayerWeaponSlot(client, 4)) != -1){
			RemovePlayerItem(client, weaponslotc4);
//			GivePlayerItem(client, "weapon_c4");
		}
//		else
//		GivePlayerItem(client, "weapon_c4");
	}
	TimerC4Give = INVALID_HANDLE;
	return Plugin_Handled;
}
public Action:Welcome(Handle:timer, any:client){
	if(!IsValidClient(client)) return Plugin_Handled;
	PrintToChat(client, "\x02 CSGO BOSSMODE \x06 %s \x01by \x05 KJ", PLUGIN_VERSION);
	return Plugin_Handled;
}
public Action:C4CheckStart(Handle:timer){
	for (new i = 1; i <= MaxClients; i++)
	{
		if((IsValidClient(i)) && g_bGameEnable){
			if ((weaponslotc4 = GetPlayerWeaponSlot(i, 4)) != -1){
				RemovePlayerItem(i, weaponslotc4);
			}
		}
	}
	BossAlive = GetPlayerSelectedCount();
	if(BossAlive <= 0){
		for (new i = 1; i <= MaxClients; i++)
		{
			if((IsValidClient(i)) && g_bGameEnable){
				CreateTimer(0.0, EndRoundPlayerSelected, i);
			}
		}
		CS_TerminateRound(1.0, CSRoundEnd_Draw);
	}
	return Plugin_Handled;
}
public Action:PredaInvisible(Handle:timer, any:client){
	if((!IsValidClient(client)) || (client != BossPlayer) || (GetClientTeam(client) != CS_TEAM_T) || g_bLastCT) return Plugin_Handled;
	else
	SetEntityRenderMode(client, RENDER_NORMAL);
	SetEntityRenderColor(client, 255, 255, 255, 50); 
	return Plugin_Handled;
}
public Action:PredaVisible(Handle:timer, any:client){
	if((!IsValidClient(client)) || (client != BossPlayer) || (GetClientTeam(client) != CS_TEAM_T)) return Plugin_Handled;
	else
	SetEntityRenderMode(client, RENDER_NORMAL);
	SetEntityRenderColor(client, 255, 255, 255, 255);
	CreateTimer(0.1, PredaInvisible, client);

	return Plugin_Handled;
}
public Action:RemoveRadar(Handle:timer, any:client) 
{
	if((IsValidClient(client)) && (client != BossPlayer)){	  
		SetEntProp(client, Prop_Send, "m_iHideHUD", GetEntProp(client, Prop_Send, "m_iHideHUD") | HIDE_RADAR_CSGO);
	} 
}
public Action:RemoveOverlay(Handle:timer, any:client) 
{
	if(IsValidClient(client)){	  
		SetClientOverlay(client, "");
	} 
}
public Action:Slow(Handle:timer, any:i) 
{
	if((g_bLastCT) && (IsValidClient(i)) && (i != BossPlayer)){
		SetEntPropFloat(i, Prop_Send, "m_flLaggedMovementValue", 1.6);
		EmitSoundToAllAny("bossmode/endrage_ezio.mp3");	
		SetClientOverlay(i, "");
	}
	if((IsValidClient(i)) && (i != BossPlayer)){
		SetEntPropFloat(i, Prop_Send, "m_flLaggedMovementValue", 1.0);
		SetClientOverlay(i, "");
		EmitSoundToAllAny("bossmode/endrage_ezio.mp3");	
	}
}
public Action:EndDozerRage(Handle:timer, any:i) 
{
	int bulldzendrage;
	bulldzendrage = GetRandomInt(1,3);
	if(bulldzendrage == 1)
	EmitSoundToAllAny("bossmode/endrage_bulldozer_1.mp3");	
	else if(bulldzendrage == 2)
	EmitSoundToAllAny("bossmode/endrage_bulldozer_2.mp3");	
	else if(bulldzendrage == 3)
	EmitSoundToAllAny("bossmode/endrage_bulldozer_3.mp3");	
	EMP = false;
}
public Action:EndHitmanRage(Handle:timer, any:i) 
{
	EMP = false;
}
public Action:EndMuricaRage(Handle:timer, any:i) 
{
	int endmuricaragerandom;
	endmuricaragerandom = GetRandomInt(1,3);
	if(endmuricaragerandom == 1)
	EmitSoundToAllAny("bossmode/endrage_murica_1.mp3");
	else if(endmuricaragerandom == 2)
	EmitSoundToAllAny("bossmode/endrage_murica_2.mp3");
	else if(endmuricaragerandom == 3)
	EmitSoundToAllAny("bossmode/endrage_murica_3.mp3");
		entity_weapon = GetPlayerWeaponSlot(BossPlayer, 0);
		if (IsValidEntity(entity_weapon))
		{
			RemovePlayerItem(BossPlayer, entity_weapon);
			RemoveEdict(entity_weapon);
		}	
}
public Action:EndJokerRage(Handle:timer, any:i) 
{
	ServerCommand("sm_drug @ct");
	EMP = false;
}
public Action:EndCBSRage(Handle:timer, any:i) 
{
	if((IsValidClient(i)) && (i == BossPlayer)) {
		SetEntityRenderMode(i,RENDER_NORMAL);
		int RandomCBSEnd;
		RandomCBSEnd = GetRandomInt(1,3);
		if(RandomCBSEnd == 1)
		EmitSoundToAllAny("bossmode/endrage_cbs_1.mp3");
		else if(RandomCBSEnd == 2)
		EmitSoundToAllAny("bossmode/endrage_cbs_2.mp3");
		else if(RandomCBSEnd == 3)
		EmitSoundToAllAny("bossmode/endrage_cbs_3.mp3");		
		entity_weapon = GetPlayerWeaponSlot(BossPlayer, 0);
		if (IsValidEntity(entity_weapon))
		{
			RemovePlayerItem(BossPlayer, entity_weapon);
			RemoveEdict(entity_weapon);
		}	
		cbsrage = false;
		EMP = false;
	}
}
//public Action:BatOverlayKill(Handle:timer, any:i) 
//{
//	if((g_bLastCT) && (IsValidClient(i)) && (i != BossPlayer)){
//		EmitSoundToAllAny("buttons/combine_button_locked.wav");	
//		SetClientOverlay(i, "");
//	}
//	if((IsValidClient(i)) && (i != BossPlayer)){
//		SetClientOverlay(i, "");
//		EmitSoundToAllAny("buttons/combine_button_locked.wav");
//	}
//}
public Action:DukeEndRage(Handle:timer, any:i) 
{
	if((g_bLastCT) && (IsValidClient(i))){
		EmitSoundToAllAny("buttons/combine_button_locked.wav");
		SetClientOverlay(i, "");
	}
	if((IsValidClient(i)) && (i != BossPlayer)) {
		SetClientOverlay(i, "");
		EmitSoundToAllAny("buttons/combine_button_locked.wav");
	}
	if(IsValidEntity(GLOW_ENTITY)){
		AcceptEntityInput(GLOW_ENTITY, "kill");
	}
}
public Action:RemoveDukeGod(Handle:timer, any:client) 
{
	if((IsValidClient(client)) && (client == BossPlayer)){
		if ((weaponslot1 = GetPlayerWeaponSlot(client, 0)) != -1){ 
			RemovePlayerItem(client, GetPlayerWeaponSlot(client, 0));
			GivePlayerItem(client, "weapon_scar20");
			SetEntData(client, (( FindDataMapOffs(client, "m_iAmmo" )) + 24 ), 150);
		}
		if ((weaponslot1 = GetPlayerWeaponSlot(client, 1)) != -1){ 
			RemovePlayerItem(client, GetPlayerWeaponSlot(client, 1));
			GivePlayerItem(client, "weapon_elite");
			SetEntData(client, (( FindDataMapOffs(client, "m_iAmmo" )) + 4 ), 150);
		}
		SetClientOverlay(client, "");
		SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
	} 
}
//COMMANDS
public Action:Command_Drop(client, const String:sCommand[], iArgs)
{
	if((IsValidClient(client)) && (client == BossPlayer) || (g_bLastCT)) return Plugin_Handled;
	else
	return Plugin_Continue;
}
public Action:Command_Use(client, const String:sCommand[], iArgs)
{
	if((IsValidClient(client)) && (client == BossPlayer)){
		return Plugin_Handled;
	}
	if(g_bLastCT){
		return Plugin_Handled;
	}
	else
	return Plugin_Continue;
}
public Action:Command_Buy(client, const String:sCommand[], iArgs)
{
	if((IsValidClient(client)) && (client == BossPlayer) || (g_bLastCT))return Plugin_Handled;
	else
	return Plugin_Continue;
}
public Action:Command_Rage(client, const String:sCommand[], iArgs)
{
	if((IsValidClient(client)) && (IsPlayerAlive(client)) && (client == BossPlayer) && RageStart && (!g_bLastCT)){
		SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
		SetClientOverlay(client, "");
		if(g_bPredator){
			for (new i = 1; i <= MaxClients; i++){
				if((IsValidClient(i)) && (i != BossPlayer)){	
					SetEntPropFloat(i, Prop_Send, "m_flLaggedMovementValue", 0.2);
					ClientCommand(i, "slot3");
					SetClientOverlay(i, "1_vs_all/rage_victim");
					EmitSoundToAllAny("buttons/light_power_on_switch_01.wav");
					PrintToChatAll("SLOWED");
					RageStart = false;
					CreateTimer(5.0, Slow, i);
				}
			}
		}
		if(g_bEzio){
		EmitSoundToAllAny("bossmode/rage_ezio.mp3");
		for (new i = 1; i <= MaxClients; i++){
				if((IsValidClient(i)) && (i != BossPlayer)){	
					SetEntPropFloat(i, Prop_Send, "m_flLaggedMovementValue", 0.2);				
					ClientCommand(i, "slot3");
					RageStart = false;
					CreateTimer(5.0,Slow,i);	
				}
			}
		}
		if(g_bHitman){
		EmitSoundToAllAny("bossmode/rage_hitman.mp3");
				if ((weaponslot2 = GetPlayerWeaponSlot(BossPlayer, 1)) != -1){
					RemovePlayerItem(BossPlayer, weaponslot2);					
					GivePlayerItem(BossPlayer, "weapon_usp_silencer");	
					EMP = true;
					CreateTimer(2.5,EndHitmanRage,BossPlayer);
					}					
		for (new i = 1; i <= MaxClients; i++){
				if((IsValidClient(i)) && (i != BossPlayer)){		
					ClientCommand(i, "slot3");
					RageStart = false;
				}
			}
		}
		if(g_bBulldozer){
		int bulldzrage;
		bulldzrage = GetRandomInt(1,3);
		if (bulldzrage == 1)
		EmitSoundToAllAny("bossmode/rage_bulldozer_1.mp3");
		else if (bulldzrage == 2)
		EmitSoundToAllAny("bossmode/rage_bulldozer_2.mp3");
		else if (bulldzrage == 3)
		EmitSoundToAllAny("bossmode/rage_bulldozer_3.mp3");
				if ((weaponslot1 = GetPlayerWeaponSlot(BossPlayer, 0)) != -1){
					RemovePlayerItem(BossPlayer, weaponslot1);					
						
					}
				GivePlayerItem(BossPlayer, "weapon_m249");	
				EMP = true;
				if((IsValidClient(client)) && (client == BossPlayer))
				CreateTimer(5.0,EndDozerRage,client);
		for (new i = 1; i <= MaxClients; i++){
				if((IsValidClient(i)) && (i != BossPlayer)){						
					ClientCommand(i, "slot3");
					RageStart = false;	
				}
			}
		}
		if(g_bJoker){
		int jokerrage;
		jokerrage = GetRandomInt(1,2);
		if (jokerrage == 1)
		EmitSoundToAllAny("bossmode/rage_joker_1.mp3");
		else if (jokerrage == 2)
		EmitSoundToAllAny("bossmode/rage_joker_2.mp3");
		CreateTimer(7.0,EndJokerRage,client);
		ServerCommand("sm_drug @ct");
		EMP = true;
		for (new i = 1; i <= MaxClients; i++){
				if((IsValidClient(i)) && (i != BossPlayer)){						
					ClientCommand(i, "slot3");
					RageStart = false;	
				}
			}
		}
		if(g_bCBS){
		int cbsragestart;
		cbsragestart = GetRandomInt(1,3);
		if(cbsragestart == 1)
		EmitSoundToAllAny("bossmode/rage_cbs_1.mp3");
		else if(cbsragestart == 2)
		EmitSoundToAllAny("bossmode/rage_cbs_2.mp3");
		else if(cbsragestart == 3)
		EmitSoundToAllAny("bossmode/rage_cbs_3.mp3");
		if ((weaponslot1 = GetPlayerWeaponSlot(BossPlayer, 0)) != -1){
			RemovePlayerItem(BossPlayer, weaponslot1);						
			CreateTimer(10.0,EndCBSRage,BossPlayer);
		}
		GivePlayerItem(BossPlayer, "weapon_awp");				
		EMP = true;				
		for (new i = 1; i <= MaxClients; i++){
				if((IsValidClient(i)) && (i != BossPlayer)){		
					ClientCommand(i, "slot3");
					RageStart = false;
				}
			}
		}
		if(g_bMurica){
		int muricarage;
		muricarage = GetRandomInt(1,3);
		if(muricarage == 1)
		EmitSoundToAllAny("bossmode/rage_murica_1.mp3");
		else if(muricarage == 2)
		EmitSoundToAllAny("bossmode/rage_murica_2.mp3");
		else if(muricarage == 3)
		EmitSoundToAllAny("bossmode/rage_murica_3.mp3");
		if ((weaponslot1 = GetPlayerWeaponSlot(BossPlayer, 0)) != -1){
			RemovePlayerItem(BossPlayer, weaponslot1);					
			EMP = true;
			CreateTimer(2.0,EndHitmanRage,BossPlayer);
		}
		GivePlayerItem(BossPlayer, "weapon_nova");	
		SetEntPropFloat(BossPlayer, Prop_Send, "m_flLaggedMovementValue", 1.5);
		CreateTimer(10.0,EndMuricaRage,BossPlayer);
		for (new i = 1; i <= MaxClients; i++){
				if((IsValidClient(i)) && (i != BossPlayer)){		
					ClientCommand(i, "slot3");
					RageStart = false;
				}
			}
		}		
		if(g_bDuke){
			if((IsValidClient(client)) && (client == BossPlayer)){	
				ClientCommand(client, "slot1");
				if ((weaponslot1 = GetPlayerWeaponSlot(client, 0)) != -1){
					RemovePlayerItem(client, GetPlayerWeaponSlot(client, 0));
					GivePlayerItem(client, "weapon_m249");
				}
				SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
				SetClientOverlay(client, "1_vs_all/rage_duke_attack");
				CreateLight(client);
				CreateTimer(5.0, RemoveDukeGod, client);
				EmitSoundToAllAny("1_vs_all/duke.mp3");
				PrintToChatAll("Duke");
			}
			for (new i = 1; i <= MaxClients; i++){
				if((IsValidClient(i)) && (i != BossPlayer)){
					SetClientOverlay(i, "1_vs_all/rage_duke_victim");
					CreateTimer(5.0, DukeEndRage, i);
					RageStart = false;
				}
			}
		}
		Ragecount++;
	}
	return Plugin_Continue;
}

//STOCKS
stock bool:IsValidClient(iClient) {
	if (iClient <= 0) return false;
	if (iClient > MaxClients) return false;
	if (!IsClientConnected(iClient)) return false;
	return IsClientInGame(iClient);
}
stock GetRandomPlayer()
{
	new iNumPlayers;
	decl iPlayers[MaxClients];
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && !IsFakeClient(i))
		{
			if (GetClientTeam(i) > 1)
			{
				iPlayers[iNumPlayers++] = i;
			}
		}
	}
	if (iNumPlayers == 0)
	{
		return -1;
	}
	return iPlayers[GetRandomInt(0, iNumPlayers - 1)];
}
stock CreateLight(client) {
	new Float:clientposition[3];
	GetClientAbsOrigin(client, clientposition);
	clientposition[2] += 40.0;

	GLOW_ENTITY = CreateEntityByName("env_glow");

	SetEntProp(GLOW_ENTITY, Prop_Data, "m_nBrightness", 70, 4);

	DispatchKeyValue(GLOW_ENTITY, "model", "sprites/ledglow.vmt");

	DispatchKeyValue(GLOW_ENTITY, "rendermode", "3");
	DispatchKeyValue(GLOW_ENTITY, "renderfx", "14");
	DispatchKeyValue(GLOW_ENTITY, "scale", "5.0");
	DispatchKeyValue(GLOW_ENTITY, "renderamt", "255");
	DispatchKeyValue(GLOW_ENTITY, "rendercolor", "255 255 255 255");
	DispatchSpawn(GLOW_ENTITY);
	AcceptEntityInput(GLOW_ENTITY, "ShowSprite");
	TeleportEntity(GLOW_ENTITY, clientposition, NULL_VECTOR, NULL_VECTOR);

	new String:target[20];
	FormatEx(target, sizeof(target), "glowclient_%d", client);
	DispatchKeyValue(client, "targetname", target);
	SetVariantString(target);
	AcceptEntityInput(GLOW_ENTITY, "SetParent");
	AcceptEntityInput(GLOW_ENTITY, "TurnOn");
}
GetPlayerCount()
{
	new players;
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && IsPlayerAlive(i) && (GetClientTeam(i) == CS_TEAM_CT))
			players++;
	}
	return players;
}
GetPlayerCountRealPlayers()
{
	new players;
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && IsPlayerAlive(i) && !IsFakeClient(i)  && (GetClientTeam(i) == CS_TEAM_CT))
			players++;
	}
	return players;
}
GetPlayerSelectedCount()
{
	new players;
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && IsPlayerAlive(i) && (GetClientTeam(i) == CS_TEAM_T))
			players++;
	}
	return players;
} 
SetClientOverlay(client, String:strOverlay[])
{
	if(IsValidClient(client)){
		new iFlags = GetCommandFlags("r_screenoverlay") & (~FCVAR_CHEAT);
		SetCommandFlags("r_screenoverlay", iFlags);	
		ClientCommand(client, "r_screenoverlay \"%s\"", strOverlay);
	}
}
stock ClearTimer(&Handle:Timer)
{
	if (Timer != INVALID_HANDLE)
	{
		CloseHandle(Timer);
		Timer = INVALID_HANDLE;
	}
}
public Action:Command_JoinTeam(client, const String:command[], argc)
{
	if(!argc || !client || !IsClientInGame(client))
		return Plugin_Continue;

	if(IsValidClient(client) && IsPlayerAlive(client) && (client == BossPlayer) && (GetClientTeam(client) == CS_TEAM_T)){
		PrintToChat(BossPlayer, "YOU CAN'T CHANGE TEAM");
		return Plugin_Handled;
	}

	return Plugin_Continue;
} 
public Action:OnWeaponCanUseBoss(client, weapon)  
{  
	new iButtons = GetClientButtons(client);
	if(iButtons & IN_USE){
		if( (GetClientTeam(client) == CS_TEAM_T) || (GetClientTeam(client) == CS_TEAM_CT && g_bLastCT)) 
		{  
			return Plugin_Handled;	
		}
	}
	return Plugin_Continue;	 
}
