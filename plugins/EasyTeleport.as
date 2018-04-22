CTextMenu@ tpMenu = null;
void PluginInit(){
  g_Module.ScriptInfo.SetAuthor("Paranoid_AF");
  g_Module.ScriptInfo.SetContactInfo("Feel free to contact me on Github.");
  g_Hooks.RegisterHook(Hooks::Player::ClientSay, @onChat);
}

HookReturnCode onChat( SayParameters@ pParams )
{
  CBasePlayer@ cPlayer = pParams.GetPlayer();
  CBasePlayer@ cTarget;
  array<int> cTopBoard(g_Engine.maxClients);
  const CCommand@ cArgs = pParams.GetArguments();
  pParams.ShouldHide = true;
  if(cPlayer is null){
    g_PlayerFuncs.SayText(cPlayer, "Teleportation faild for invailid input.\nOnly valid numbers are allowed.\n");
    return HOOK_CONTINUE;
  }
  if (cArgs[0] != "/TP" && cArgs[0] != "/tp" && cArgs[0] != "!TP" && cArgs[0] != "!tp"){
    return HOOK_CONTINUE;
  }
  if(cArgs[1] == ""){
    // trigger teleport menu
  }
  if(atoi(cArgs[1]) < 1 || atoi(cArgs[1]) > g_Engine.maxClients){
    CBasePlayer@ cFindPlayerByName;
    for(int i = 1; i <= g_Engine.maxClients; i++){
      @cFindPlayerByName = g_PlayerFuncs.FindPlayerByIndex(i);
      if(cFindPlayerByName !is null){
        string targetPlayerName = cFindPlayerByName.pev.netname;
        if(targetPlayerName.ToLowercase() == cArgs[1].ToLowercase()){
          break;
        }
      }
    }
    if(cFindPlayerByName !is null){
      string targetPlayerName = cFindPlayerByName.pev.netname;
      if(targetPlayerName.ToLowercase() == cArgs[1].ToLowercase()){
        cPlayer.SetOrigin(cFindPlayerByName.GetOrigin()+Vector(0,0,5));
        g_PlayerFuncs.SayText(cPlayer, "Teleporting you to " + cFindPlayerByName.pev.netname +"...\n");
        pParams.ShouldHide = true;
        return HOOK_HANDLED;
      }
    }
    g_PlayerFuncs.SayText(cPlayer, "Teleportation faild for invailid input.\nOnly valid numbers are allowed.\n");
    return HOOK_CONTINUE;
  }
  @cTarget = getPlayerByRank(atoi(cArgs[1]));
  if(cTarget is null){
    g_PlayerFuncs.SayText(cPlayer, "Teleportation faild for invailid input.\nOnly valid numbers are allowed.\n");
    return HOOK_CONTINUE;
  }
  cPlayer.SetOrigin(cTarget.GetOrigin()+Vector(0,0,5));
  g_PlayerFuncs.SayText(cPlayer, "Teleporting you to " + cTarget.pev.netname +"...\n");
  return HOOK_HANDLED;
}

array<int> fetchPlayerListSortedByScore(){
  array<int> cScoreBoard(g_Engine.maxClients);
  array<int> cTopBoard(g_Engine.maxClients);
  for(int i = 1; i <= g_Engine.maxClients; i++){
    CBasePlayer@ cThisPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
    if(cThisPlayer is null){
      break;
    }
    cScoreBoard[i - 1] = int(cThisPlayer.pev.frags);
  }
  cTopBoard[0] = 0;
  for(int i = 1; i <= int(cScoreBoard.length() - 1); i++){
    if(cScoreBoard[i] > cScoreBoard[i - 1]){
      cTopBoard[i - 1] = i;
      cTopBoard[i] = i - 1;
    }else{
      cTopBoard[i] = i;
    }
  }
  return cTopBoard;
}

CBasePlayer@ getPlayerByRank(int playerRank){
  CBasePlayer@ cTarget;
  array<int> cTopBoard = fetchPlayerListSortedByScore();
  @cTarget = g_PlayerFuncs.FindPlayerByIndex(cTopBoard[playerRank - 1] + 1);
  return cTarget;
}