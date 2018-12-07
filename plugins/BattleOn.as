/*
  Inspired from w00tguy's Classic Mode Deluxe: https://forums.svencoop.com/showthread.php/45371-Classic-Mode-Deluxe
  
  Known Bugs:
  - Explosive weapons won't do damage. A shame tho.
  - Player's model won't disappear after death in survival mode.
*/

bool pvpActivated = true;
const string mapListFile = "scripts/plugins/PvpMaps.txt";
float pvpTimeLimit = 600;
float g_iTimeWarning = 30;
const int HUD_CHAN_TIMER = 0;
array<string> mapList;
CScheduledFunction@ refreshHUD;

void PluginInit(){
  g_Module.ScriptInfo.SetAuthor("Paranoid_AF");
  g_Module.ScriptInfo.SetContactInfo("Feel free to contact me on GitHub.");
  
  File@ file = g_FileSystem.OpenFile(mapListFile, OpenFile::READ);
  if (file !is null && file.IsOpen()) {
    while(!file.EOFReached()) {
      string sLine;
      file.ReadLine(sLine);
      if (sLine.SubString(0,1) == "//" || sLine.IsEmpty())
        continue;

      array<string> parsed = sLine.Split(" ");
      if (parsed.length() < 1)
        continue;

      mapList.insertLast(parsed[0]);
    }
    file.Close();
  }
}

void MapInit(){
  g_SoundSystem.PrecacheSound("common/bodysplat.wav");
  g_Game.PrecacheModel("models/gibman.mdl");
  pvpActivated = shouldEnable();
  g_Scheduler.ClearTimerList();
  @refreshHUD = null;
  if(pvpActivated){
    @refreshHUD = g_Scheduler.SetInterval("timer_refreshHUD", 0.3, g_Scheduler.REPEAT_INFINITE_TIMES);
    g_Hooks.RegisterHook(Hooks::Player::PlayerTakeDamage, @PlayerTakeDamage);
  }
}

void timer_refreshHUD(){
  for(int i=0; i<g_Engine.maxClients; i++){
    CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i+1);
    if(pPlayer !is null){
      SendTimer(pPlayer);
    }
  }
  if(pvpTimeLimit - g_Engine.time <= 0){
    g_EngineFuncs.CVarSetFloat("mp_timelimit", 0.01);
  }
}

bool shouldEnable(){
  bool isIt = false;
  for(int i=0; i<int(mapList.length()); i++){
    if(mapList[i] == g_Engine.mapname){
      isIt = true;
    }
  }
  return isIt;
}

void SendTimer(CBasePlayer@ pPlayer){
  bool fTimeWarning = (pvpTimeLimit - g_Engine.time) <= g_iTimeWarning;
  HUDNumDisplayParams params;
  params.channel = HUD_CHAN_TIMER;
  params.flags = HUD_ELEM_SCR_CENTER_X | HUD_ELEM_DEFAULT_ALPHA |
    HUD_TIME_MINUTES | HUD_TIME_SECONDS | HUD_TIME_COUNT_DOWN;
  if(fTimeWarning){
    params.flags |= HUD_TIME_MILLISECONDS;
  }
  params.value = pvpTimeLimit - g_Engine.time;
  params.x = 0;
  params.y = 0.06;
  params.color1 = fTimeWarning ? RGBA_RED : RGBA_SVENCOOP;
  params.spritename = "stopwatch";
  g_PlayerFuncs.HudTimeDisplay( null, params );
}

HookReturnCode PlayerTakeDamage(DamageInfo@ info){
  if(pvpActivated){
    CBasePlayer@ pPlayer = cast<CBasePlayer@>(g_EntityFuncs.Instance(info.pVictim.pev));
    entvars_t@ pInflictor = info.pInflictor !is null ? info.pInflictor.pev : null;
    entvars_t@ pAttacker = info.pAttacker !is null ? info.pAttacker.pev : null;
    CBasePlayer@ atkPlayer = cast<CBasePlayer@>(g_EntityFuncs.Instance(info.pAttacker.pev));
    if(!isValidPlayer(atkPlayer) || (pPlayer !is null && pPlayer is atkPlayer)){
      return HOOK_CONTINUE;
    }
    PvpTakeDamage(pPlayer, pInflictor, pAttacker, info.flDamage, info.bitsDamageType);
    info.flDamage = 0;
  }
  return HOOK_HANDLED;
}

int PvpTakeDamage(CBasePlayer@ pPlayer, entvars_t@ pInflictor, entvars_t@ pAttacker, float flDamage, int bitsDamageType){
  const float armorRatio = 0.6;
  CBasePlayer@ atkPlayer = cast<CBasePlayer@>(g_EntityFuncs.Instance(pAttacker));
  if(bitsDamageType & DMG_BLAST != 0){
    flDamage *= 2;
  }
  if(pPlayer.pev.armorvalue >= armorRatio * flDamage){
    pPlayer.pev.armorvalue -= armorRatio * flDamage;
    pPlayer.pev.health -= (1 - armorRatio) * flDamage;
  }else{
    pPlayer.pev.health -= flDamage - pPlayer.pev.armorvalue;
    pPlayer.pev.armorvalue = 0;
  }
  
  float flTake = int(flDamage);
  if(pInflictor !is null){
    @pPlayer.pev.dmg_inflictor = pInflictor.get_pContainingEntity();
  }
  pPlayer.pev.dmg_take += flTake;
  
  if(pPlayer.pev.health <= 0){
    if(g_Engine.time - pPlayer.m_fDeadTime > g_EngineFuncs.CVarGetFloat("mp_respawndelay")){
      g_PlayerFuncs.ClientPrintAll(HUD_PRINTNOTIFY, string(atkPlayer.pev.netname) + " :: "  + string(atkPlayer.m_hActiveItem.GetEntity().pev.classname) + " :: " + string(pPlayer.pev.netname) + "\n");
      pPlayer.pev.health = 0;
      pPlayer.pev.armorvalue = 0;
      pPlayer.pev.deadflag = DEAD_DYING;
      pPlayer.pev.rendermode = 1;
      pPlayer.pev.renderamt = 0;
      g_EntityFuncs.SpawnRandomGibs(pPlayer.pev, 1, 1);
      g_SoundSystem.PlaySound(pPlayer.edict(), CHAN_AUTO, "common/bodysplat.wav", 1.0f, 1.0f);
      atkPlayer.pev.frags++;
      pPlayer.m_iDeaths++;
    }
    return 0;
  }

  return 1;
}


bool isValidPlayer(CBasePlayer@ vPlayer){
  if(vPlayer !is null ){
    for(int i=0; i<g_Engine.maxClients; i++){
      CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i+1);
      if(pPlayer !is null && pPlayer is vPlayer){
        return true;
      }
    }
    return false;
  }else{
    return false;
  }
}
