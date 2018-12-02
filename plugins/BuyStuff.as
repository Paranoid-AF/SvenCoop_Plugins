#include "bsConf"
array<CTextMenu@> shopMenu;
CTextMenu@ cateMenu = CTextMenu(cateMenuRespond);
array<string> cateNames;
array<array<string>> weaponNames;
array<array<string>> weaponNamesWithPrices;

void PluginInit(){
  g_Module.ScriptInfo.SetAuthor("Paranoid_AF");
  g_Module.ScriptInfo.SetContactInfo("Feel free to contact me on GitHub.");
  g_Hooks.RegisterHook(Hooks::Player::ClientSay, @onChat);
}

void MapInit(){
  shopMenu = {};
  cateMenu.Unregister();
  @cateMenu = CTextMenu(cateMenuRespond);
  cateNames = {};
  weaponNames = {};
  weaponNamesWithPrices = {};
  cateMenu.SetTitle("[" + bsTitle + "]\n" + bsDescription + "\n");
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
  }
  if(pPlayer !is null && pPlayer.IsAlive() && (cArgs[0].ToLowercase() == "!buy" || cArgs[0].ToLowercase() == "/buy")){
    if(cateNames.length() != 1){
      cateMenu.Open(0, 0, pPlayer);
    }else{
      shopMenu[0].Open(0, 0, pPlayer);
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
    if(amount <= pPlayer.pev.frags){
      pPlayer.pev.frags -= amount;
      return true;
    }else{
      if(int(pPlayer.pev.frags) == 0 || int(pPlayer.pev.frags) == 1){
        g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[" + bsTitle + "] You don't have enough points to purchase this! You have only " + string(int(pPlayer.pev.frags)) + " point.\n");
      }else{
        g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[" + bsTitle + "] You don't have enough points to purchase this! You have only " + string(int(pPlayer.pev.frags)) + " points.\n");
      }
      return false;
    }
  }else{
    return false;
  }
}