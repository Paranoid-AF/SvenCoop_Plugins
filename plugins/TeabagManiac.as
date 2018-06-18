bool lastStatus = false;
array<float> lastDuck(g_Engine.maxClients);
int hpEach = 3;
void PluginInit(){
  g_Module.ScriptInfo.SetAuthor("Paranoid_AF");
  g_Module.ScriptInfo.SetContactInfo("Feel free to contact me on GitHub.");
  g_Hooks.RegisterHook(Hooks::Player::PlayerPreThink, @onChange);
}

HookReturnCode onChange(CBasePlayer@ pPlayer, uint& out uiFlags){
  if(pPlayer is null){
    g_PlayerFuncs.SayText(pPlayer, "[TeabagManiac] Invalid player!\n");
    return HOOK_CONTINUE;
  }
  int playerIndex = getPlayerIndex(pPlayer);
  if((pPlayer.pev.button & IN_DUCK ) != 0 && !lastStatus && (g_Engine.time - lastDuck[playerIndex]) > 1){
    if((pPlayer.pev.health + hpEach) <= pPlayer.pev.max_health){
      pPlayer.pev.health += hpEach;
    }
    if((pPlayer.pev.health + hpEach) > pPlayer.pev.max_health && (pPlayer.pev.max_health - hpEach) < pPlayer.pev.health){
      pPlayer.pev.health = pPlayer.pev.max_health;
    }
    lastStatus = true;
    lastDuck[playerIndex] = g_Engine.time;
    return HOOK_HANDLED;
  }
  if((pPlayer.pev.button & IN_DUCK ) == 0){
    lastStatus = false;
    return HOOK_CONTINUE;
  }
  return HOOK_CONTINUE;
}

int getPlayerIndex(CBasePlayer@ pPlayer){
  CBasePlayer@ cFindPlayer = null;
  int thisIndex;
  for(int i = 1; i <= g_Engine.maxClients; i++){
    @cFindPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
    if(cFindPlayer is pPlayer){
      thisIndex = i;
      break;
    }
  }
  return thisIndex;
}