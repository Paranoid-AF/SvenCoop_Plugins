#include "bsConf"
array<CTextMenu@> shopMenu;
CTextMenu@ cateMenu = CTextMenu(cateMenuRespond);
array<string> cateNames;
array<array<string>> weaponNames;
array<array<string>> weaponNamesWithPrices;
dictionary usedCurrency = {{"STEAMID", 1.0}};
array<float> playerScore(g_Engine.maxClients);
bool shouldLoad = false;
string supposedMap = "";

CScheduledFunction@ refreshHUD;

void Precache(){
  g_Game.PrecacheGeneric("sprites/misc/dollar.spr");
  g_Game.PrecacheGeneric("sprites/misc/deduct.spr");
  g_Game.PrecacheGeneric("sprites/misc/add.spr");
}

void PluginInit(){
  g_Module.ScriptInfo.SetAuthor("Paranoid_AF");
  g_Module.ScriptInfo.SetContactInfo("Feel free to contact me on GitHub.");
  usedCurrency.deleteAll();
  g_Hooks.RegisterHook(Hooks::Player::ClientSay, @onChat);
  g_Hooks.RegisterHook(Hooks::Player::ClientDisconnect, @onQuit);
  g_Hooks.RegisterHook(Hooks::Game::MapChange, @onMapChange);
}

HookReturnCode onQuit(CBasePlayer@ pPlayer){
  usedCurrency[g_EngineFuncs.GetPlayerAuthId(pPlayer.edict())] = 0;
  return HOOK_HANDLED;
}

float queryForBalance(CBasePlayer@ pPlayer){
  if(pPlayer !is null){
    return (pPlayer.pev.frags - float(usedCurrency[g_EngineFuncs.GetPlayerAuthId(pPlayer.edict())]));
  }else{
    return 0;
  }
}

HookReturnCode onMapChange(){
  if(shouldSave()){
    shouldLoad = true;
  }else{
    shouldLoad = false;
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

void timer_refreshHUD(){
  for(int i=0; i<g_Engine.maxClients; i++){
    CBasePlayer@ pPlayer =  g_PlayerFuncs.FindPlayerByIndex(i+1);
    if(pPlayer !is null){
      HUDNumDisplayParams params;
      params.channel = 3;
      params.flags = HUD_ELEM_SCR_CENTER_X | HUD_ELEM_DEFAULT_ALPHA;
      params.value = queryForBalance(pPlayer);
      params.x = 0.5;
      params.y = 0.9;
      params.defdigits = 1;
      params.maxdigits = 4;
      params.color1 = RGBA_SVENCOOP;
      params.spritename = "misc/dollar.spr";
      g_PlayerFuncs.HudNumDisplay(pPlayer, params);
      
      if(int(pPlayer.pev.frags) > int(playerScore[i])){
        showScoringHUD(pPlayer, int(pPlayer.pev.frags) - int(playerScore[i]));
      }
      playerScore[i] = pPlayer.pev.frags;
    }
  }
}

void showDeductHUD(CBasePlayer@ pPlayer, int amount){
  if(pPlayer !is null){
    HUDNumDisplayParams params;
    params.channel = 4;
    params.flags = HUD_ELEM_SCR_CENTER_X | HUD_ELEM_DEFAULT_ALPHA;
    params.value = amount;
    params.fadeinTime = 0.15;
    params.holdTime = 1;
    params.fadeoutTime = 0.15;
    params.x = 0.5;
    params.y = 0.858;
    params.defdigits = 1;
    params.maxdigits = 4;
    params.color1 = RGBA_RED;
    params.spritename = "misc/deduct.spr";
    g_PlayerFuncs.HudNumDisplay(pPlayer, params);
  }
}

void showScoringHUD(CBasePlayer@ pPlayer, int amount){
  if(pPlayer !is null){
    HUDNumDisplayParams params;
    params.channel = 4;
    params.flags = HUD_ELEM_SCR_CENTER_X | HUD_ELEM_DEFAULT_ALPHA;
    params.value = amount;
    params.fadeinTime = 0.15;
    params.holdTime = 1;
    params.fadeoutTime = 0.15;
    params.x = 0.5;
    params.y = 0.855;
    params.defdigits = 1;
    params.maxdigits = 4;
    params.color1 = RGBA_GREEN;
    params.spritename = "misc/add.spr";
    g_PlayerFuncs.HudNumDisplay(pPlayer, params);
  }
}

int getPlayerIndex(CBasePlayer@ pPlayer){
  CBasePlayer@ findPlayer = null;
  int thisIndex;
  for(int i = 1; i <= g_Engine.maxClients; i++){
    @findPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
    if(findPlayer is pPlayer){
      thisIndex = i;
      break;
    }
  }
  return thisIndex;
}

bool hasMoneySaver(){
	array<string> pluginList = g_PluginManager.GetPluginList();
	bool hasInstalled = false;
	for(int i=0; i<int(pluginList.length()); i++){
		if(pluginList[i] == "MoneySaver"){
			hasInstalled = true;
		}
	}
	return hasInstalled;
}

void MapInit(){
  Precache();
  shopMenu = {};
  cateMenu.Unregister();
  @cateMenu = CTextMenu(cateMenuRespond);
  cateNames = {};
  weaponNames = {};
  weaponNamesWithPrices = {};
  cateMenu.SetTitle("[" + bsTitle + "]\n" + bsDescription + "\n");
  for(int i=0; i<g_Engine.maxClients; i++){
      playerScore[i] = 0;
  }
  if(hasMoneySaver() && (supposedMap != g_Engine.mapname || !shouldLoad)){
    usedCurrency.deleteAll();
  }
  if(!hasMoneySaver()){
    usedCurrency.deleteAll();
  }
  g_Scheduler.ClearTimerList();
  @refreshHUD = null;
  if(isWeaponAllowed("")){
    @refreshHUD = g_Scheduler.SetInterval("timer_refreshHUD", 0.3, g_Scheduler.REPEAT_INFINITE_TIMES);
  }
  for(int i = 0; i <= (int(bsConf.length()) - 1); i++){
    int findCate = cateNames.find(bsConf[i][3]);
    if(isWeaponAllowed(bsConf[i][1])){
      if(findCate < 0){
        cateNames.insertLast(bsConf[i][3]);
        weaponNames.insertLast({bsConf[i][1]});
      }else{
        weaponNames[findCate].insertLast(bsConf[i][1]);
      }
    }
  }
  for(int i = 0; i <= (int(cateNames.length()) - 1); i++){
    cateMenu.AddItem(cateNames[i], null);
    shopMenu.resize(cateNames.length());
    weaponNamesWithPrices.resize(cateNames.length());
    @shopMenu[i] = CTextMenu(shopMenuRespond);
  }
  cateMenu.Register();
  for(int i = 0; i <= (int(weaponNames.length()) - 1); i++){
    for(int j = 0; j <= (int(weaponNames[i].length()) - 1); j++){
      if(weaponNames[i].length() != 7 && j != 0 && j % 6 == 0 && cateNames.length() != 1){
          shopMenu[i].AddItem("Back to Categories", null);
      }
      array<string> info = findInfoByName(weaponNames[i][j]);
      if(isWeaponAllowed(weaponNames[i][j])){
        if(info[2] == "1"){
          weaponNamesWithPrices[i].insertLast(weaponNames[i][j] + " - 1 Point");
          shopMenu[i].AddItem(weaponNames[i][j] + " - 1 Point", null);
        }else{
          weaponNamesWithPrices[i].insertLast(weaponNames[i][j] + " - " + info[2] + " Points");
          shopMenu[i].AddItem(weaponNames[i][j] + " - " + info[2] + " Points", null);
        }
      }
      if(j == int(weaponNames[i].length()) - 1 && cateNames.length() != 1){
        shopMenu[i].AddItem("Back to Categories", null);
      }
    }
    if(cateNames.length() != 1){
      shopMenu[i].SetTitle("[" + bsTitle + "]\nViewing: " + cateNames[i] + "\n");
    }else{
      shopMenu[i].SetTitle("[" + bsTitle + "]\n" + bsDescription + "\n");
    }
    shopMenu[i].Register();
  }
}

array<string> findInfoByName(string weaponName){
  int infoIndex = -1;
  for(int i = 0; i <= (int(bsConf.length()) - 1); i++){
    if(bsConf[i][1] == weaponName){
      infoIndex = i;
      break;
    }
  }
  if(infoIndex == -1){
    return {};
  }else{
    return bsConf[infoIndex];
  }
}

HookReturnCode onChat(SayParameters@ pParams){
  CBasePlayer@ pPlayer = pParams.GetPlayer();
  const CCommand@ cArgs = pParams.GetArguments();
  if(pPlayer !is null && !pPlayer.IsAlive() && (cArgs[0].ToLowercase() == "!buy" || cArgs[0].ToLowercase() == "/buy")){
    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[" + bsTitle + "] Sorry, but you can't purchase anything since you're dead now.\n");
    pParams.ShouldHide = true;
    return HOOK_HANDLED;
  }
  if(pPlayer !is null && pPlayer.IsAlive() && (cArgs[0].ToLowercase() == "!buy" || cArgs[0].ToLowercase() == "/buy")){
    if(isWeaponAllowed("")){
      if(cateNames.length() != 1){
        cateMenu.Open(0, 0, pPlayer);
      }else{
        shopMenu[0].Open(0, 0, pPlayer);
      }
    }else{
      g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[" + bsTitle + "] Sorry, but no weapon is allowed in this map!\n");
    }
    pParams.ShouldHide = true;
    return HOOK_HANDLED;
  }
  return HOOK_CONTINUE;
}

void cateMenuRespond(CTextMenu@ mMenu, CBasePlayer@ pPlayer, int iPage, const CTextMenuItem@ mItem){
  if(mItem !is null && pPlayer !is null){
    shopMenu[cateNames.find(mItem.m_szName)].Open(0, 0, pPlayer);
  }
}

array<string> getWeaponNameBySzName(string szName){
  string thisWeaponName;
  string thisWeaponCateIndex;
  for(int i = 0; i <= (int(weaponNamesWithPrices.length()) - 1); i++){
    for(int j = 0; j <= (int(weaponNamesWithPrices[i].length()) - 1); j++){
      int weaponIndex = weaponNamesWithPrices[i].find(szName);
      if(weaponIndex >= 0){
        thisWeaponName = weaponNames[i][weaponIndex];
        thisWeaponCateIndex = string(i);
      }
    }
  }
  return {thisWeaponName, thisWeaponCateIndex};
}

void shopMenuRespond(CTextMenu@ mMenu, CBasePlayer@ pPlayer, int iPage, const CTextMenuItem@ mItem){
  if(mItem !is null){
    if(mItem.m_szName == "Back to Categories"){
      cateMenu.Open(0, 0, pPlayer);
    }else{
      array<string> szInfo = getWeaponNameBySzName(mItem.m_szName);
      array<string> info = findInfoByName(szInfo[0]);
      if(deductCurrency(atoi(info[2]), pPlayer, info[1])){
        if(pPlayer.HasNamedPlayerItem(info[0]) is null){
          pPlayer.GiveNamedItem(info[0], 0, 0);
        }else{
          g_EntityFuncs.Create(info[0], pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");
        }
      }
      shopMenu[atoi(szInfo[1])].Open(0, 0, pPlayer);
      mMenu.Open(0, 0, pPlayer);
    }
  }
}

bool isWeaponAllowed(string weaponName){
  int mapIndex = -1;
  for(int i = 0; i <= (int(disallowedWeapons.length()) - 1); i++){
    if(disallowedWeapons[i][0] == g_Engine.mapname){
      mapIndex = i;
      break;
    }
  }
  if(mapIndex >= 0 && disallowedWeapons[mapIndex].length() == 1){
    return false;
  }
  if(mapIndex >= 0){
    for(int i = 1; i <= (int(disallowedWeapons[mapIndex].length()) - 1); i++){
      if(disallowedWeapons[mapIndex][i] == weaponName){
        return false;
      }
    }
  }
  return true;
}

bool deductCurrency(int amount, CBasePlayer@ pPlayer, string weaponName){
  if(pPlayer !is null){
    if(amount <= queryForBalance(pPlayer)){
      float originalVal = float(usedCurrency[g_EngineFuncs.GetPlayerAuthId(pPlayer.edict())]);
      usedCurrency[g_EngineFuncs.GetPlayerAuthId(pPlayer.edict())] = originalVal + amount;
      showDeductHUD(pPlayer, amount);
      return true;
    }else{
      if(int(queryForBalance(pPlayer)) == 0 || int(queryForBalance(pPlayer)) == 1){
        g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[" + bsTitle + "] You don't have enough points to purchase this! You have only " + string(int(queryForBalance(pPlayer))) + " point.\n");
      }else{
        g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[" + bsTitle + "] You don't have enough points to purchase this! You have only " + string(int(queryForBalance(pPlayer))) + " points.\n");
      }
      return false;
    }
  }else{
    return false;
  }
}