CTextMenu@ tpMenu = null;
CTextMenu@ tpConfirm = null;
array<int> pReceivedRequest(g_Engine.maxClients);
array<float> pLastSend(g_Engine.maxClients);
array<bool> pAllowTp(g_Engine.maxClients, true);
CCVar@ eztpDisabled;
CCVar@ eztpCooldown;
void PluginInit(){
  g_Module.ScriptInfo.SetAuthor("Paranoid_AF");
  g_Module.ScriptInfo.SetContactInfo("Feel free to contact me on GitHub.");
  g_Hooks.RegisterHook(Hooks::Player::ClientSay, @onChat);
  g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @onJoin);
  @eztpDisabled = CCVar("disabled", 0, "Change it to 0 to enable and 1 to disable.", ConCommandFlag::AdminOnly);
  @eztpCooldown = CCVar("cooldown", 0, "Set cooldown between each request.", ConCommandFlag::AdminOnly);
}

void MapInit(){
  eztpDisabled.SetInt(0);
  eztpCooldown.SetInt(0);
  for(int i = 1; i <= (int(pReceivedRequest.length()) - 1); i++){
    pReceivedRequest[i] = 0;
  }
  for(int i = 1; i <= (int(pLastSend.length()) - 1); i++){
    pLastSend[i] = 0;
  }
}

HookReturnCode onJoin(CBasePlayer@ pPlayer){
  int thisPlayer = getPlayerIndex(pPlayer);
  pReceivedRequest[thisPlayer] = 0;
  pLastSend[thisPlayer] = 0;
  pAllowTp[thisPlayer] = true;
  return HOOK_HANDLED;
}

HookReturnCode onChat(SayParameters@ pParams){
  CBasePlayer@ cPlayer = pParams.GetPlayer();
  CBasePlayer@ cTarget;
  array<int> cTopBoard(g_Engine.maxClients);
  const CCommand@ cArgs = pParams.GetArguments();
  if(cPlayer is null){
    g_PlayerFuncs.SayText(cPlayer, "[EasyTeleport] Teleportation failed, only valid players are allowed.\n");
    return HOOK_CONTINUE;
  }
  if(cArgs[0] == "/TPON" || cArgs[0] == "/tpon" || cArgs[0] == "!TPON" || cArgs[0] == "!tpon"){
    pAllowTp[getPlayerIndex(cPlayer)] = true;
    pParams.ShouldHide = true;
    g_PlayerFuncs.SayText(cPlayer, "[EasyTeleport] Successfully enabled teleportation for you.\n");
    return HOOK_HANDLED;
  }
  if(cArgs[0] == "/TPOFF" || cArgs[0] == "/tpoff" || cArgs[0] == "!TPOFF" || cArgs[0] == "!tpoff"){
    pAllowTp[getPlayerIndex(cPlayer)] = false;
    pParams.ShouldHide = true;
    g_PlayerFuncs.SayText(cPlayer, "[EasyTeleport] Successfully disabled teleportation for you.\n");
    return HOOK_HANDLED;
  }
  if(cArgs[0] != "/TP" && cArgs[0] != "/tp" && cArgs[0] != "!TP" && cArgs[0] != "!tp"){
    return HOOK_CONTINUE;
  }
  pParams.ShouldHide = true;
  int isDisabled = eztpDisabled.GetInt();
  if(isDisabled == 1){
    g_PlayerFuncs.SayText(cPlayer, "[EasyTeleport] Teleportation is disabled by the map for better gameplay.\n");
    return HOOK_CONTINUE;
  }
  if(cArgs[1] == ""){
    openTpMenu(cPlayer);
    return HOOK_HANDLED;
  }
  CBasePlayer@ cFindPlayerByName = getPlayerCBasePlayerByName(cArgs[1]);
  if(cFindPlayerByName !is null){
    string targetPlayerName = cFindPlayerByName.pev.netname;
    if(targetPlayerName.ToLowercase() == cArgs[1].ToLowercase()){
      sendTeleportRequest(cPlayer, cFindPlayerByName);
      return HOOK_HANDLED;
    }
  }
  g_PlayerFuncs.SayText(cPlayer, "[EasyTeleport] Teleportation failed for invailid input. Only valid names are allowed.\n");
  return HOOK_CONTINUE;
}

void openTpMenu(CBasePlayer@ pPlayer){
  @tpMenu = CTextMenu(tpMenuRespond);
  tpMenu.SetTitle("[EasyTeleport]\nPick a player for teleportation.\n");
  array<string> playerName(g_Engine.maxClients);
  for(int i = 1; i <= (int(g_Engine.maxClients)); i++){
    CBasePlayer@ cThisPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
    if(cThisPlayer !is null && pAllowTp[getPlayerIndex(cThisPlayer)]){
      playerName[i - 1] = cThisPlayer.pev.netname;
    }
  }
  if(playerName[0] != ""){
    for(int i = 1; i <= (int(playerName.length())-1); i++)
    {
      string thisName = playerName[i - 1];
      if(thisName != "" && thisName != " "){
        tpMenu.AddItem(thisName, null);
      }
    }
    tpMenu.Register();
    tpMenu.Open(0, 0, pPlayer);
  }else{
    g_PlayerFuncs.SayText(pPlayer, "[EasyTeleport] No player available.\n");
  }
}

CBasePlayer@ getPlayerCBasePlayerByName(string pName){
  CBasePlayer@ cFindPlayerByName = null;
  for(int i = 1; i <= g_Engine.maxClients; i++){
    @cFindPlayerByName = g_PlayerFuncs.FindPlayerByIndex(i);
    if(cFindPlayerByName !is null){
      string targetPlayerName = cFindPlayerByName.pev.netname;
      if(targetPlayerName.ToLowercase() == pName.ToLowercase()){
        break;
      }
    }
  }
  return cFindPlayerByName;
}

int getPlayerIndex(CBasePlayer@ pPlayer){
  CBasePlayer@ cFindPlayerByName = null;
  int thisIndex;
  for(int i = 1; i <= g_Engine.maxClients; i++){
    @cFindPlayerByName = g_PlayerFuncs.FindPlayerByIndex(i);
    if(cFindPlayerByName is pPlayer){
      thisIndex = i;
      break;
    }
  }
  return thisIndex;
}

void tpMenuRespond(CTextMenu@ mMenu, CBasePlayer@ pPlayer, int iPage, const CTextMenuItem@ mItem){
  if(mItem !is null && pPlayer !is null){
    CBasePlayer@ cTarget = getPlayerCBasePlayerByName(mItem.m_szName);
    if(pPlayer.IsAlive() && pPlayer.pev.deadflag != DEAD_DYING){
      if(cTarget.IsAlive() && cTarget.pev.deadflag != DEAD_DYING){
        sendTeleportRequest(pPlayer, cTarget);
      }else{
        g_PlayerFuncs.SayText(pPlayer, "[EasyTeleport] Sorry, your target player is now dead.\n");
      }
    }else{
       g_PlayerFuncs.SayText(pPlayer, "[EasyTeleport] Sorry but you're dead, so you can't get teleported.\n");
    }
  }
}

void sendTeleportRequest(CBasePlayer@ pPlayer, CBasePlayer@ cTarget){
  int thisSender = getPlayerIndex(pPlayer);
  if((g_Engine.time - pLastSend[thisSender]) > eztpCooldown.GetInt()){
    if(pAllowTp[getPlayerIndex(cTarget)]){
      pReceivedRequest[getPlayerIndex(cTarget)] = getPlayerIndex(pPlayer);
      @tpConfirm = CTextMenu(tpConfirmRespond);
      tpConfirm.SetTitle("[EasyTeleport]\nYou've got a new teleportation request from " + pPlayer.pev.netname +".\nOnly confirm when you think it's safe to do so.\n");
      tpConfirm.AddItem("Accept", null);
      tpConfirm.AddItem("Decline", null);
      tpConfirm.Register();
      tpConfirm.Open(0, 0, cTarget);
      g_PlayerFuncs.SayText(pPlayer, "[EasyTeleport] Your teleportation request is sent to " + cTarget.pev.netname +", please wait for confirmation.\n");
      pLastSend[thisSender] = g_Engine.time;
    }else{
      g_PlayerFuncs.SayText(pPlayer, "[EasyTeleport] The target player has disabled teleportation.\n");
    }
  }else{
    g_PlayerFuncs.SayText(pPlayer, "[EasyTeleport] Please wait for a while before the cooldown for " + string(eztpCooldown.GetInt()) + "s ends.\n");
  }
}

void tpConfirmRespond(CTextMenu@ mMenu, CBasePlayer@ pPlayer, int iPage, const CTextMenuItem@ mItem){
  CBasePlayer@ cSourcePlayer = g_PlayerFuncs.FindPlayerByIndex(pReceivedRequest[getPlayerIndex(pPlayer)]);
  if(cSourcePlayer !is null){
    if(mItem.m_szName == "Accept" && pPlayer !is null){
      if(pPlayer.IsAlive() && pPlayer.pev.deadflag != DEAD_DYING){
        if(cSourcePlayer.IsAlive() && cSourcePlayer.pev.deadflag != DEAD_DYING){
          g_PlayerFuncs.SayText(cSourcePlayer, "[EasyTeleport] Teleporting you to " + pPlayer.pev.netname +"...\n");
          cSourcePlayer.SetOrigin(pPlayer.GetOrigin()+Vector(0,0,4));
          NetworkMessage msg(MSG_ONE, NetworkMessages::NetworkMessageType(9), cSourcePlayer.edict());
          msg.WriteString("unstuck");
          msg.End();
        }else{
          g_PlayerFuncs.SayText(pPlayer, "[EasyTeleport] Sorry, the player is now not alive.\n");
        }
      }else{
         g_PlayerFuncs.SayText(pPlayer, "[EasyTeleport] Sorry but it seems that you're dead.\n");
      }
    }
    if(mItem.m_szName == "Decline" && pPlayer !is null){
      pReceivedRequest[getPlayerIndex(pPlayer)] = 0;
      g_PlayerFuncs.SayText(cSourcePlayer, "[EasyTeleport] Sorry, your teleportation request to " + pPlayer.pev.netname +" was rejected by the player.\n");
    }
  }
}