array<float> playerFrags;
array<string> playerAuth;
bool shouldLoad = false;
string supposedMap = "";
void PluginInit(){
  g_Module.ScriptInfo.SetAuthor("Paranoid_AF");
  g_Module.ScriptInfo.SetContactInfo("Feel free to contact me on GitHub.");
  g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @onJoin);
  g_Hooks.RegisterHook(Hooks::Game::MapChange, @onMapChange);
}

void MapInit(){
  if(!shouldLoad){
    for(int i=0; i<int(playerAuth.length()); i++){
      playerAuth.removeLast();
      playerFrags.removeLast();
    }
  }
}

void saveScore(CBasePlayer@ pPlayer){
  int legacyIndex = playerAuth.find(g_EngineFuncs.GetPlayerAuthId(pPlayer.edict()));
  if(legacyIndex >= 0){
    playerAuth.removeAt(legacyIndex);
    playerFrags.removeAt(legacyIndex);
  }
  playerAuth.insertLast(g_EngineFuncs.GetPlayerAuthId(pPlayer.edict()));
  playerFrags.insertLast(pPlayer.pev.frags);
}

void loadScore(CBasePlayer@ pPlayer){
  int legacyIndex = playerAuth.find(g_EngineFuncs.GetPlayerAuthId(pPlayer.edict()));
  if(supposedMap == g_Engine.mapname){
    if(legacyIndex >= 0){
      pPlayer.pev.frags = playerFrags[legacyIndex];
      playerAuth.removeAt(legacyIndex);
      playerFrags.removeAt(legacyIndex);
    }
  }else{
    supposedMap = "";
  }
}

HookReturnCode onJoin(CBasePlayer@ pPlayer){
  if(shouldLoad){
    loadScore(pPlayer);
  }
  return HOOK_HANDLED;
}

HookReturnCode onMapChange(){
  for(int i=0; i<g_Engine.maxClients; i++){
    CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i+1);
    if(pPlayer !is null){
      if(shouldSave()){
        saveScore(pPlayer);
        shouldLoad = true;
      }else{
        shouldLoad = false;
      }
    }
  }
  return HOOK_HANDLED;
}

bool shouldSave(){
  string nextMap = g_EngineFuncs.CVarGetString("mp_nextmap");
  if(nextMap == ""){
    nextMap = g_EngineFuncs.CVarGetString("mp_survival_nextmap");
  }
  if(nextMap == ""){
    return false;
  }else{
    supposedMap = nextMap;
    return true;
  }
}