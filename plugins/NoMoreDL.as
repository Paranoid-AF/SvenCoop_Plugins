array<string> onholdPlayers;
array<float> connTime;
CScheduledFunction@ playerCheck;
float banAfterKick = 0;
float kickAfterConn = 30;

void PluginInit(){
  g_Module.ScriptInfo.SetAuthor("Paranoid_AF");
  g_Module.ScriptInfo.SetContactInfo("Feel free to contact me on GitHub.");
  g_Hooks.RegisterHook(Hooks::Player::ClientConnected, @onConn);
  g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @onJoin);
}

void MapActivate(){
  g_Scheduler.ClearTimerList();
  for(int i = 0; i <= (int(onholdPlayers.length()) - 1); i++){
    onholdPlayers.removeAt(i);
  }
  for(int i = 0; i <= (int(connTime.length()) - 1); i++){
    connTime.removeAt(i);
  }
  @playerCheck = g_Scheduler.SetInterval("timer_playerCheck", 1, g_Scheduler.REPEAT_INFINITE_TIMES);
}

void timer_playerCheck(){
  for(int i = 0; i <= (int(onholdPlayers.length()) - 1); i++){
    if((g_Engine.time - connTime[i]) >= kickAfterConn){
      kickPlayerByName(onholdPlayers[i]);
    }
  }
}

HookReturnCode onJoin(CBasePlayer@ pPlayer){
  removeFromList(pPlayer.pev.netname);
  return HOOK_HANDLED;
}

HookReturnCode onConn(edict_t@ pEntity, const string& in szPlayerName, const string& in szIPAddress, bool& out bDisallowJoin, string& out szRejectReason){
  onholdPlayers.insertLast(szPlayerName);
  connTime.insertLast(g_Engine.time);
  return HOOK_HANDLED;
}

void kickPlayerByName(string szNameOrSteamId){
  g_EngineFuncs.ServerCommand("kick " + szNameOrSteamId + "\n");
  removeFromList(szNameOrSteamId);
}

void removeFromList(string szNameOrSteamId){
  int kickIndex = onholdPlayers.find(szNameOrSteamId);
  if(kickIndex >= 0){
    onholdPlayers.removeAt(kickIndex);
    connTime.removeAt(kickIndex);
  }
}