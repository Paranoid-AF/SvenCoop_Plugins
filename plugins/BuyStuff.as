array<string> blockedMaps = {"thelake", "bm_sts", "ctf_warforts"};
CTextMenu@ shopMenu = null;
CTextMenu@ cateMenu = null;
void PluginInit(){
  g_Module.ScriptInfo.SetAuthor("Paranoid_AF");
  g_Module.ScriptInfo.SetContactInfo("Feel free to contact me on GitHub.");
  g_Hooks.RegisterHook(Hooks::Player::ClientSay, @onChat);
}

HookReturnCode onChat(SayParameters@ pParams){
  CBasePlayer@ pPlayer = pParams.GetPlayer();
  const CCommand@ cArgs = pParams.GetArguments();
  if(pPlayer !is null && (cArgs[0] == "!buy" || cArgs[0] == "/buy" || cArgs[0] == "!BUY" || cArgs[0] == "/BUY") && isAllowed()){
    openCateMenu(pPlayer);
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

void openCateMenu(CBasePlayer@ pPlayer){
  @cateMenu = CTextMenu(cateMenuRespond);
  cateMenu.SetTitle("[BUY STUFF]\nPurchase items using your scores.\n");
  cateMenu.AddItem("Melee", null);
  cateMenu.AddItem("Secondary", null);
  cateMenu.AddItem("Primary", null);
  cateMenu.AddItem("Heavy", null);
  cateMenu.AddItem("Throwable", null);
  cateMenu.AddItem("Specialist", null);
  cateMenu.AddItem("Ammo", null);
  cateMenu.Register();
  cateMenu.Open(0, 0, pPlayer);
}

void cateMenuRespond(CTextMenu@ mMenu, CBasePlayer@ pPlayer, int iPage, const CTextMenuItem@ mItem){
  @shopMenu = CTextMenu(shopMenuRespond);
  if(mItem !is null && pPlayer !is null){
    if(mItem.m_szName == "Melee"){
      shopMenu.SetTitle("[BUY STUFF]\nViewing: Melee\n");
      shopMenu.AddItem("Crowbar - 5 Points", null);
      shopMenu.AddItem("Wrench - 7 Points", null);
      shopMenu.AddItem("Grapple - 10 Points", null);
      shopMenu.AddItem("Medic Kit - 1 Point", null);
      shopMenu.AddItem("Back", null);
    }
    if(mItem.m_szName == "Secondary"){
      shopMenu.SetTitle("[BUY STUFF]\nViewing: Secondary\n");
      shopMenu.AddItem("9mm Pistol - 15 Points", null);
      shopMenu.AddItem(".357 Revolver - 25 Points", null);
      shopMenu.AddItem("Desert Eagle - 25 Points", null);
      shopMenu.AddItem("Uzi - 30 Points", null);
      shopMenu.AddItem("Back", null);
    }
    if(mItem.m_szName == "Primary"){
      shopMenu.SetTitle("[BUY STUFF]\nViewing: Primary\n");
      shopMenu.AddItem("MP5-A3 - 50 Points", null);
      shopMenu.AddItem("SPAS12 - 60 Points", null);
      shopMenu.AddItem("Crossbow - 45 Points", null);
      shopMenu.AddItem("M16 + M203 - 60 Points", null);
      shopMenu.AddItem("Back", null);
    }
    if(mItem.m_szName == "Heavy"){
      shopMenu.SetTitle("[BUY STUFF]\nViewing: Heavy\n");
      shopMenu.AddItem("RPG - 100 Points", null);
      shopMenu.AddItem("Gauss - 120 Points", null);
      shopMenu.AddItem("Egon - 110 Points", null);
      shopMenu.AddItem("Hornet - 50 Points", null);
      shopMenu.AddItem("Back", null);
    }
    if(mItem.m_szName == "Throwable"){
      shopMenu.SetTitle("[BUY STUFF]\nViewing: Throwable\n");
      shopMenu.AddItem("Grenade (5 Pack) - 50 Points", null);
      shopMenu.AddItem("Tripmine - 12 Points", null);
      shopMenu.AddItem("Satchel Charge - 15 Points", null);
      shopMenu.AddItem("Snark - 15 Points", null);
      shopMenu.AddItem("Back", null);
    }
    if(mItem.m_szName == "Specialist"){
      shopMenu.SetTitle("[BUY STUFF]\nViewing: Specialist\n");
      shopMenu.AddItem("M40a1 - 80 Points", null);
      shopMenu.AddItem("M249 - 100 Points", null);
      shopMenu.AddItem("Spore Launcher - 120 Points", null);
      shopMenu.AddItem("Displacer - 150 Points", null);
      shopMenu.AddItem("Long Jump Module - 30 Points", null);
      shopMenu.AddItem("Back", null);
    }
    if(mItem.m_szName == "Ammo"){
      shopMenu.SetTitle("[BUY STUFF]\nViewing: Ammo\n");
      shopMenu.AddItem(".357 ammo (6) / Revolver, Desert Eagle - 6 Points", null);
      shopMenu.AddItem(".556 ammo (100) / M16, M249, Minigun - 15 Points", null);
      shopMenu.AddItem(".762 ammo (5) / M40a1 - 6 Points", null);
      shopMenu.AddItem("9mm ammo (50) / 9mm Pistol, MP5-A3, Uzi - 8 Points", null);
      shopMenu.AddItem("AR grenades (2) / M16 + M203 - 8 Points", null);
      shopMenu.AddItem("Buckshots (12) / SPAS12 - 6 Points", null);
      shopMenu.AddItem("Back", null);
      shopMenu.AddItem("Bolts (12) / Crossbow - 10 Points", null);
      shopMenu.AddItem("Gauss Clip (20) / Gauss, Egon, Displacer - 8 Points", null);
      shopMenu.AddItem("RPG Clip (2) / RPG - 10 Points", null);
      shopMenu.AddItem("Spore Clip (1) / Spore Launcher - 3 Points", null);
      shopMenu.AddItem("Back", null);
    }
    shopMenu.Register();
    shopMenu.Open(0, 0, pPlayer);
  }
}

void shopMenuRespond(CTextMenu@ mMenu, CBasePlayer@ pPlayer, int iPage, const CTextMenuItem@ mItem){
  if(mItem !is null && pPlayer !is null){
    if(mItem.m_szName == "Crowbar - 5 Points"){
      if(deductCurrency(5, pPlayer)){
        g_EntityFuncs.Create("weapon_crowbar", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");;
      }
    }
    if(mItem.m_szName == "Wrench - 7 Points"){
      if(deductCurrency(7, pPlayer)){
        g_EntityFuncs.Create("weapon_pipewrench", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");;
      }
    }
    if(mItem.m_szName == "Grapple - 10 Points"){
      if(deductCurrency(10, pPlayer)){
        g_EntityFuncs.Create("weapon_grapple", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");;
      }
    }
    if(mItem.m_szName == "Medic Kit - 1 Point"){
      if(deductCurrency(1, pPlayer)){
        g_EntityFuncs.Create("weapon_medkit", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");;
      }
    }
    if(mItem.m_szName == "9mm Pistol - 15 Points"){
      if(deductCurrency(15, pPlayer)){
        g_EntityFuncs.Create("weapon_9mmhandgun", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");;
      }
    }
    if(mItem.m_szName == ".357 Revolver - 25 Points"){
      if(deductCurrency(25, pPlayer)){
        g_EntityFuncs.Create("weapon_357", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");;
      }
    }
    if(mItem.m_szName == "Desert Eagle - 25 Points"){
      if(deductCurrency(25, pPlayer)){
        g_EntityFuncs.Create("weapon_eagle", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");;
      }
    }
    if(mItem.m_szName == "Uzi - 30 Points"){
      if(deductCurrency(30, pPlayer)){
        g_EntityFuncs.Create("weapon_uzi", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");;
      }
    }
    if(mItem.m_szName == "MP5-A3 - 50 Points"){
      if(deductCurrency(50, pPlayer)){
        g_EntityFuncs.Create("weapon_9mmAR", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");;
      }
    }
    if(mItem.m_szName == "SPAS12 - 60 Points"){
      if(deductCurrency(60, pPlayer)){
        g_EntityFuncs.Create("weapon_shotgun", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");;
      }
    }
    if(mItem.m_szName == "Crossbow - 45 Points"){
      if(deductCurrency(45, pPlayer)){
        g_EntityFuncs.Create("weapon_crossbow", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");;
      }
    }
    if(mItem.m_szName == "M16 - 60 Points"){
      if(deductCurrency(60, pPlayer)){
        g_EntityFuncs.Create("weapon_m16", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");;
      }
    }
    if(mItem.m_szName == "RPG - 100 Points"){
      if(deductCurrency(100, pPlayer)){
        g_EntityFuncs.Create("weapon_rpg", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");;
      }
    }
    if(mItem.m_szName == "Gauss - 120 Points"){
      if(deductCurrency(120, pPlayer)){
        g_EntityFuncs.Create("weapon_gauss", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");;
      }
    }
    if(mItem.m_szName == "Egon - 110 Points"){
      if(deductCurrency(110, pPlayer)){
        g_EntityFuncs.Create("weapon_egon", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");;
      }
    }
    if(mItem.m_szName == "Hornet - 50 Points"){
      if(deductCurrency(50, pPlayer)){
        g_EntityFuncs.Create("weapon_hornetgun", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");;
      }
    }
    if(mItem.m_szName == "Grenade (5 Pack) - 50 Points"){
      if(deductCurrency(50, pPlayer)){
        g_EntityFuncs.Create("weapon_handgrenade", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");;
      }
    }
    if(mItem.m_szName == "Tripmine - 12 Points"){
      if(deductCurrency(12, pPlayer)){
        g_EntityFuncs.Create("weapon_tripmine", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");;
      }
    }
    if(mItem.m_szName == "Satchel Charge - 15 Points"){
      if(deductCurrency(15, pPlayer)){
        g_EntityFuncs.Create("weapon_satchel", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");;
      }
    }
    if(mItem.m_szName == "Snark - 15 Points"){
      if(deductCurrency(15, pPlayer)){
        g_EntityFuncs.Create("weapon_snark", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");;
      }
    }
    if(mItem.m_szName == "M40a1 - 80 Points"){
      if(deductCurrency(80, pPlayer)){
        g_EntityFuncs.Create("weapon_sniperrifle", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");;
      }
    }
    if(mItem.m_szName == "M249 - 100 Points"){
      if(deductCurrency(100, pPlayer)){
        g_EntityFuncs.Create("weapon_m249", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");;
      }
    }
    if(mItem.m_szName == "Spore Launcher - 120 Points"){
      if(deductCurrency(120, pPlayer)){
        g_EntityFuncs.Create("weapon_sporelauncher", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");;
      }
    }
    if(mItem.m_szName == "Displacer - 150 Points"){
      if(deductCurrency(150, pPlayer)){
        g_EntityFuncs.Create("weapon_displacer", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");;
      }
    }
    if(mItem.m_szName == ".357 ammo (6) / Revolver, Desert Eagle - 6 Points"){
      if(deductCurrency(6, pPlayer)){
        g_EntityFuncs.Create("ammo_357", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");;
      }
    }
    if(mItem.m_szName == ".556 ammo (100) / M16, M249, Minigun - 15 Points"){
      if(deductCurrency(15, pPlayer)){
        g_EntityFuncs.Create("ammo_556", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");;
      }
    }
    if(mItem.m_szName == ".762 ammo (5) / M40a1 - 6 Points"){
      if(deductCurrency(6, pPlayer)){
        g_EntityFuncs.Create("ammo_762", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");;
      }
    }
    if(mItem.m_szName == "9mm ammo (50) / 9mm Pistol, MP5-A3, Uzi - 8 Points"){
      if(deductCurrency(8, pPlayer)){
        g_EntityFuncs.Create("ammo_9mmAR", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");;
      }
    }
    if(mItem.m_szName == "AR grenades (2) / M16 + M203 - 8 Points"){
      if(deductCurrency(8, pPlayer)){
        g_EntityFuncs.Create("ammo_ARgrenades", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");;
      }
    }
    if(mItem.m_szName == "Buckshots (12) / SPAS12 - 6 Points"){
      if(deductCurrency(6, pPlayer)){
        g_EntityFuncs.Create("ammo_buckshot", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");;
      }
    }
    if(mItem.m_szName == "Bolts (12) / Crossbow - 10 Points"){
      if(deductCurrency(10, pPlayer)){
        g_EntityFuncs.Create("ammo_crossbow", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");;
      }
    }
    if(mItem.m_szName == "Gauss Clip (20) / Gauss, Egon, Displacer - 8 Points"){
      if(deductCurrency(8, pPlayer)){
        g_EntityFuncs.Create("ammo_gaussclip", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");;
      }
    }
    if(mItem.m_szName == "RPG Clip (2) / RPG - 10 Points"){
      if(deductCurrency(10, pPlayer)){
        g_EntityFuncs.Create("ammo_rpgclip", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");;
      }
    }
    if(mItem.m_szName == "Spore Clip (1) / Spore Launcher - 3 Points"){
      if(deductCurrency(3, pPlayer)){
        g_EntityFuncs.Create("ammo_sporeclip", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");;
      }
    }
    if(mItem.m_szName == "Long Jump Module - 30 Points"){
      if(deductCurrency(30, pPlayer)){
        g_EntityFuncs.Create("item_longjump", pPlayer.GetOrigin(), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");;
      }
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
      return false;
    }
  }else{
    return false;
  }
}