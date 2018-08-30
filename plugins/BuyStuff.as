array<string> blockedMaps = {"thelake", "bm_sts", "ctf_warforts", "escapeplan"};
CTextMenu@ cateMenu = CTextMenu(cateMenuRespond);
CTextMenu@ shopMenu1 = CTextMenu(shopMenuRespond);
CTextMenu@ shopMenu2 = CTextMenu(shopMenuRespond);
CTextMenu@ shopMenu3 = CTextMenu(shopMenuRespond);
CTextMenu@ shopMenu4 = CTextMenu(shopMenuRespond);
CTextMenu@ shopMenu5 = CTextMenu(shopMenuRespond);
CTextMenu@ shopMenu6 = CTextMenu(shopMenuRespond);
CTextMenu@ shopMenu7 = CTextMenu(shopMenuRespond);
void PluginInit(){
  g_Module.ScriptInfo.SetAuthor("Paranoid_AF");
  g_Module.ScriptInfo.SetContactInfo("Feel free to contact me on GitHub.");
  g_Hooks.RegisterHook(Hooks::Player::ClientSay, @onChat);
  cateMenu.SetTitle("[BUY STUFF]\nPurchase items using your scores.\n");
  cateMenu.AddItem("Melee & Essentials", null);
  cateMenu.AddItem("Secondary", null);
  cateMenu.AddItem("Primary", null);
  cateMenu.AddItem("Heavy", null);
  cateMenu.AddItem("Throwable", null);
  cateMenu.AddItem("Specialist", null);
  cateMenu.AddItem("Ammo", null);
  cateMenu.Register();
  shopMenu1.SetTitle("[BUY STUFF]\nViewing: Melee & Essentials\n");
  shopMenu1.AddItem("Crowbar - 5 Points", null);
  shopMenu1.AddItem("Wrench - 7 Points", null);
  shopMenu1.AddItem("Grapple - 10 Points", null);
  shopMenu1.AddItem("Battery - 6 Points", null);
  shopMenu1.AddItem("Medic Kit - 1 Point", null);
  shopMenu1.AddItem("Back", null);
  shopMenu1.Register();
  shopMenu2.SetTitle("[BUY STUFF]\nViewing: Secondary\n");
  shopMenu2.AddItem("9mm Pistol - 15 Points", null);
  shopMenu2.AddItem(".357 Revolver - 25 Points", null);
  shopMenu2.AddItem("Desert Eagle - 25 Points", null);
  shopMenu2.AddItem("Uzi - 30 Points", null);
  shopMenu2.AddItem("Back", null);
  shopMenu2.Register();
  shopMenu3.SetTitle("[BUY STUFF]\nViewing: Primary\n");
  shopMenu3.AddItem("MP5-A3 - 50 Points", null);
  shopMenu3.AddItem("SPAS12 - 60 Points", null);
  shopMenu3.AddItem("Crossbow - 45 Points", null);
  shopMenu3.AddItem("M16 + M203 - 60 Points", null);
  shopMenu3.AddItem("Back", null);
  shopMenu3.Register();
  shopMenu4.SetTitle("[BUY STUFF]\nViewing: Heavy\n");
  shopMenu4.AddItem("RPG - 100 Points", null);
  shopMenu4.AddItem("Gauss - 120 Points", null);
  shopMenu4.AddItem("Egon - 110 Points", null);
  shopMenu4.AddItem("Hornet - 50 Points", null);
  shopMenu4.AddItem("Back", null);
  shopMenu4.Register();
  shopMenu5.SetTitle("[BUY STUFF]\nViewing: Throwable\n");
  shopMenu5.AddItem("Grenade (5 Pack) - 50 Points", null);
  shopMenu5.AddItem("Tripmine - 12 Points", null);
  shopMenu5.AddItem("Satchel Charge - 15 Points", null);
  shopMenu5.AddItem("Snark - 15 Points", null);
  shopMenu5.AddItem("Back", null);
  shopMenu5.Register();
  shopMenu6.SetTitle("[BUY STUFF]\nViewing: Specialist\n");
  shopMenu6.AddItem("M40a1 - 80 Points", null);
  shopMenu6.AddItem("M249 - 100 Points", null);
  shopMenu6.AddItem("Spore Launcher - 120 Points", null);
  shopMenu6.AddItem("Displacer - 150 Points", null);
  shopMenu6.AddItem("Long Jump Module - 30 Points", null);
  shopMenu6.AddItem("Back", null);
  shopMenu6.Register();
  shopMenu7.SetTitle("[BUY STUFF]\nViewing: Ammo\n");
  shopMenu7.AddItem(".357 ammo (6) / Revolver, Desert Eagle - 6 Points", null);
  shopMenu7.AddItem(".556 ammo (100) / M16, M249, Minigun - 15 Points", null);
  shopMenu7.AddItem(".762 ammo (5) / M40a1 - 6 Points", null);
  shopMenu7.AddItem("9mm ammo (50) / 9mm Pistol, MP5-A3, Uzi - 8 Points", null);
  shopMenu7.AddItem("AR grenades (2) / M16 + M203 - 8 Points", null);
  shopMenu7.AddItem("Buckshots (12) / SPAS12 - 6 Points", null);
  shopMenu7.AddItem("Back", null);
  shopMenu7.AddItem("Bolts (12) / Crossbow - 10 Points", null);
  shopMenu7.AddItem("Gauss Clip (20) / Gauss, Egon, Displacer - 8 Points", null);
  shopMenu7.AddItem("RPG Clip (2) / RPG - 10 Points", null);
  shopMenu7.AddItem("Spore Clip (1) / Spore Launcher - 3 Points", null);
  shopMenu7.AddItem("Back", null);
  shopMenu7.Register();
}

HookReturnCode onChat(SayParameters@ pParams){
  CBasePlayer@ pPlayer = pParams.GetPlayer();
  const CCommand@ cArgs = pParams.GetArguments();
  if(pPlayer !is null && (cArgs[0] == "!buy" || cArgs[0] == "/buy" || cArgs[0] == "!BUY" || cArgs[0] == "/BUY") && isAllowed()){
    openCateMenu(pPlayer);
    pParams.ShouldHide = true;
    return HOOK_HANDLED;
  }
  return HOOK_CONTINUE;
}

bool isAllowed(){
  bool notIncluded = true;
  for(int i = 0; i <= (int(blockedMaps.length()) - 1); i++){
    if(blockedMaps[i] == g_Engine.mapname){
      notIncluded = false;
    }
  }
  return notIncluded;
}

HookReturnCode PlayerSpawn(CBasePlayer@ pPlayer){
  if(pPlayer.pev.frags < 300){
    pPlayer.pev.frags = 300;
  }
  return HOOK_HANDLED;
}

void openCateMenu(CBasePlayer@ pPlayer){
  cateMenu.Open(0, 0, pPlayer);
}

void cateMenuRespond(CTextMenu@ mMenu, CBasePlayer@ pPlayer, int iPage, const CTextMenuItem@ mItem){
  if(mItem !is null && pPlayer !is null){
    if(mItem.m_szName == "Melee & Essentials"){
      shopMenu1.Open(0, 0, pPlayer);
    }
    if(mItem.m_szName == "Secondary"){
      shopMenu2.Open(0, 0, pPlayer);
    }
    if(mItem.m_szName == "Primary"){
      shopMenu3.Open(0, 0, pPlayer);
    }
    if(mItem.m_szName == "Heavy"){
      shopMenu4.Open(0, 0, pPlayer);
    }
    if(mItem.m_szName == "Throwable"){
      shopMenu5.Open(0, 0, pPlayer);
    }
    if(mItem.m_szName == "Specialist"){
      shopMenu6.Open(0, 0, pPlayer);
    }
    if(mItem.m_szName == "Ammo"){
      shopMenu7.Open(0, 0, pPlayer);
    }
  }
}

void shopMenuRespond(CTextMenu@ mMenu, CBasePlayer@ pPlayer, int iPage, const CTextMenuItem@ mItem){
  if(mItem !is null && pPlayer !is null){
    if(mItem.m_szName == "Crowbar - 5 Points"){
      if(deductCurrency(5, pPlayer)){
        g_EntityFuncs.Create("weapon_crowbar", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");
      }
      shopMenu1.Open(0, 0, pPlayer);
    }
    if(mItem.m_szName == "Wrench - 7 Points"){
      if(deductCurrency(7, pPlayer)){
        g_EntityFuncs.Create("weapon_pipewrench", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");
      }
      shopMenu1.Open(0, 0, pPlayer);
    }
    if(mItem.m_szName == "Grapple - 10 Points"){
      if(deductCurrency(10, pPlayer)){
        g_EntityFuncs.Create("weapon_grapple", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");
      }
      shopMenu1.Open(0, 0, pPlayer);
    }
    if(mItem.m_szName == "Battery - 6 Points"){
      if(deductCurrency(1, pPlayer)){
        g_EntityFuncs.Create("item_battery", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");
      }
      shopMenu1.Open(0, 0, pPlayer);
    }
    if(mItem.m_szName == "Medic Kit - 1 Point"){
      if(deductCurrency(1, pPlayer)){
        g_EntityFuncs.Create("item_healthkit", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");
      }
      shopMenu1.Open(0, 0, pPlayer);
    }
    if(mItem.m_szName == "9mm Pistol - 15 Points"){
      if(deductCurrency(15, pPlayer)){
        g_EntityFuncs.Create("weapon_9mmhandgun", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");
      }
      shopMenu2.Open(0, 0, pPlayer);
    }
    if(mItem.m_szName == ".357 Revolver - 25 Points"){
      if(deductCurrency(25, pPlayer)){
        g_EntityFuncs.Create("weapon_357", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");
      }
      shopMenu2.Open(0, 0, pPlayer);
    }
    if(mItem.m_szName == "Desert Eagle - 25 Points"){
      if(deductCurrency(25, pPlayer)){
        g_EntityFuncs.Create("weapon_eagle", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");
      }
      shopMenu2.Open(0, 0, pPlayer);
    }
    if(mItem.m_szName == "Uzi - 30 Points"){
      if(deductCurrency(30, pPlayer)){
        g_EntityFuncs.Create("weapon_uzi", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");
      }
      shopMenu2.Open(0, 0, pPlayer);
    }
    if(mItem.m_szName == "MP5-A3 - 50 Points"){
      if(deductCurrency(50, pPlayer)){
        g_EntityFuncs.Create("weapon_9mmAR", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");
      }
      shopMenu3.Open(0, 0, pPlayer);
    }
    if(mItem.m_szName == "SPAS12 - 60 Points"){
      if(deductCurrency(60, pPlayer)){
        g_EntityFuncs.Create("weapon_shotgun", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");
      }
      shopMenu3.Open(0, 0, pPlayer);
    }
    if(mItem.m_szName == "Crossbow - 45 Points"){
      if(deductCurrency(45, pPlayer)){
        g_EntityFuncs.Create("weapon_crossbow", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");
      }
      shopMenu3.Open(0, 0, pPlayer);
    }
    if(mItem.m_szName == "M16 + M203 - 60 Points"){
      if(deductCurrency(60, pPlayer)){
        g_EntityFuncs.Create("weapon_m16", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");
      }
      shopMenu3.Open(0, 0, pPlayer);
    }
    if(mItem.m_szName == "RPG - 100 Points"){
      if(deductCurrency(100, pPlayer)){
        g_EntityFuncs.Create("weapon_rpg", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");
      }
      shopMenu4.Open(0, 0, pPlayer);
    }
    if(mItem.m_szName == "Gauss - 120 Points"){
      if(deductCurrency(120, pPlayer)){
        g_EntityFuncs.Create("weapon_gauss", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");
      }
      shopMenu4.Open(0, 0, pPlayer);
    }
    if(mItem.m_szName == "Egon - 110 Points"){
      if(deductCurrency(110, pPlayer)){
        g_EntityFuncs.Create("weapon_egon", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");
      }
      shopMenu4.Open(0, 0, pPlayer);
    }
    if(mItem.m_szName == "Hornet - 50 Points"){
      if(deductCurrency(50, pPlayer)){
        g_EntityFuncs.Create("weapon_hornetgun", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");
      }
      shopMenu4.Open(0, 0, pPlayer);
    }
    if(mItem.m_szName == "Grenade (5 Pack) - 50 Points"){
      if(deductCurrency(50, pPlayer)){
        g_EntityFuncs.Create("weapon_handgrenade", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");
      }
      shopMenu5.Open(0, 0, pPlayer);
    }
    if(mItem.m_szName == "Tripmine - 12 Points"){
      if(deductCurrency(12, pPlayer)){
        g_EntityFuncs.Create("weapon_tripmine", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");
      }
      shopMenu5.Open(0, 0, pPlayer);
    }
    if(mItem.m_szName == "Satchel Charge - 15 Points"){
      if(deductCurrency(15, pPlayer)){
        g_EntityFuncs.Create("weapon_satchel", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");
      }
      shopMenu5.Open(0, 0, pPlayer);
    }
    if(mItem.m_szName == "Snark - 15 Points"){
      if(deductCurrency(15, pPlayer)){
        g_EntityFuncs.Create("weapon_snark", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");
      }
      shopMenu5.Open(0, 0, pPlayer);
    }
    if(mItem.m_szName == "M40a1 - 80 Points"){
      if(deductCurrency(80, pPlayer)){
        g_EntityFuncs.Create("weapon_sniperrifle", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");
      }
      shopMenu6.Open(0, 0, pPlayer);
    }
    if(mItem.m_szName == "M249 - 100 Points"){
      if(deductCurrency(100, pPlayer)){
        g_EntityFuncs.Create("weapon_m249", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");
      }
      shopMenu6.Open(0, 0, pPlayer);
    }
    if(mItem.m_szName == "Spore Launcher - 120 Points"){
      if(deductCurrency(120, pPlayer)){
        g_EntityFuncs.Create("weapon_sporelauncher", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");
      }
      shopMenu6.Open(0, 0, pPlayer);
    }
    if(mItem.m_szName == "Displacer - 150 Points"){
      if(deductCurrency(150, pPlayer)){
        g_EntityFuncs.Create("weapon_displacer", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");
      }
      shopMenu6.Open(0, 0, pPlayer);
    }
    if(mItem.m_szName == ".357 ammo (6) / Revolver, Desert Eagle - 6 Points"){
      if(deductCurrency(6, pPlayer)){
        g_EntityFuncs.Create("ammo_357", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");
      }
      shopMenu7.Open(0, 0, pPlayer);
    }
    if(mItem.m_szName == ".556 ammo (100) / M16, M249, Minigun - 15 Points"){
      if(deductCurrency(15, pPlayer)){
        g_EntityFuncs.Create("ammo_556", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");
      }
      shopMenu7.Open(0, 0, pPlayer);
    }
    if(mItem.m_szName == ".762 ammo (5) / M40a1 - 6 Points"){
      if(deductCurrency(6, pPlayer)){
        g_EntityFuncs.Create("ammo_762", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");
      }
      shopMenu7.Open(0, 0, pPlayer);
    }
    if(mItem.m_szName == "9mm ammo (50) / 9mm Pistol, MP5-A3, Uzi - 8 Points"){
      if(deductCurrency(8, pPlayer)){
        g_EntityFuncs.Create("ammo_9mmAR", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");
      }
      shopMenu7.Open(0, 0, pPlayer);
    }
    if(mItem.m_szName == "AR grenades (2) / M16 + M203 - 8 Points"){
      if(deductCurrency(8, pPlayer)){
        g_EntityFuncs.Create("ammo_ARgrenades", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");
      }
      shopMenu7.Open(0, 0, pPlayer);
    }
    if(mItem.m_szName == "Buckshots (12) / SPAS12 - 6 Points"){
      if(deductCurrency(6, pPlayer)){
        g_EntityFuncs.Create("ammo_buckshot", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");
      }
      shopMenu7.Open(0, 0, pPlayer);
    }
    if(mItem.m_szName == "Bolts (12) / Crossbow - 10 Points"){
      if(deductCurrency(10, pPlayer)){
        g_EntityFuncs.Create("ammo_crossbow", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");
      }
      shopMenu7.Open(0, 0, pPlayer);
    }
    if(mItem.m_szName == "Gauss Clip (20) / Gauss, Egon, Displacer - 8 Points"){
      if(deductCurrency(8, pPlayer)){
        g_EntityFuncs.Create("ammo_gaussclip", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");
      }
      shopMenu7.Open(0, 0, pPlayer);
    }
    if(mItem.m_szName == "RPG Clip (2) / RPG - 10 Points"){
      if(deductCurrency(10, pPlayer)){
        g_EntityFuncs.Create("ammo_rpgclip", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");
      }
      shopMenu7.Open(0, 0, pPlayer);
    }
    if(mItem.m_szName == "Spore Clip (1) / Spore Launcher - 3 Points"){
      if(deductCurrency(3, pPlayer)){
        g_EntityFuncs.Create("ammo_sporeclip", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");
      }
      shopMenu7.Open(0, 0, pPlayer);
    }
    if(mItem.m_szName == "Long Jump Module - 30 Points"){
      if(deductCurrency(30, pPlayer)){
        g_EntityFuncs.Create("item_longjump", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");
      }
      shopMenu6.Open(0, 0, pPlayer);
    }
    if(mItem.m_szName == "Back"){
      openCateMenu(pPlayer);
    }
  }
}

bool deductCurrency(int amount, CBasePlayer@ pPlayer){
  if(pPlayer !is null){
    if(amount <= pPlayer.pev.frags){
      pPlayer.pev.frags -= amount;
      return true;
    }else{
      g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[Game] You don't have enough points to purchase this! You have only " + string(pPlayer.pev.frags) + " points.");
      return false;
    }
  }else{
    return false;
  }
}
