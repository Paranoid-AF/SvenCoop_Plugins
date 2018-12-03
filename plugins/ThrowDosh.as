int fragsEachDosh = 5;

void Precache(){
  g_Game.PrecacheGeneric("models/common/lambda.mdl");
}

void PluginInit(){
  g_Module.ScriptInfo.SetAuthor("Paranoid_AF");
  g_Module.ScriptInfo.SetContactInfo("Feel free to contact me on GitHub.");
  g_Hooks.RegisterHook(Hooks::Player::ClientSay, @onChat);
  g_Hooks.RegisterHook(Hooks::Player::ClientDisconnect, @onDisconnect);
}

void MapInit(){
  g_CustomEntityFuncs.RegisterCustomEntity("item_dosh", "item_dosh");
}

HookReturnCode onDisconnect(CBasePlayer@ pPlayer){
  CBaseEntity@ pEntity = null;
  while((@pEntity = g_EntityFuncs.FindEntityByClassname(pEntity, "item_dosh")) !is null){
    if(pEntity.pev.targetname == string(getPlayerIndex(pPlayer))){
      g_EntityFuncs.Remove(pEntity);
    }
  }
  return HOOK_HANDLED;
}

class item_dosh: ScriptBasePlayerAmmoEntity{
	void Spawn(){ 
		Precache();
		if(self.SetupModel() == false){
			g_EntityFuncs.SetModel(self, "models/common/lambda.mdl");
		}else{
			g_EntityFuncs.SetModel(self, self.pev.model);
    }
		BaseClass.Spawn();
	}
	void Precache(){
		BaseClass.Precache();
		if(string(self.pev.model).IsEmpty()){
			g_Game.PrecacheModel("models/common/lambda.mdl");
		}else{
			g_Game.PrecacheModel(self.pev.model);
    }
	}
	bool AddAmmo(CBaseEntity@ pOther){
    CBaseEntity@ pPlayer = cast<CBaseEntity@>(g_PlayerFuncs.FindPlayerByIndex(atoi(self.pev.targetname)));
    if(pPlayer !is null){
      pOther.pev.frags += fragsEachDosh;
      if(pPlayer !is pOther){
        g_PlayerFuncs.ClientPrint(cast<CBasePlayer@>(pOther), HUD_PRINTTALK, "[ThrowDosh] You just received " + string(fragsEachDosh) + " scores from "+ g_PlayerFuncs.FindPlayerByIndex(atoi(self.pev.targetname)).pev.netname +".\n");
      }
      return true;
    }else{
      return false;
    }
  }
}

HookReturnCode onChat(SayParameters@ pParams){
  CBasePlayer@ pPlayer = pParams.GetPlayer();
  const CCommand@ cArgs = pParams.GetArguments();
  if(pPlayer !is null && !pPlayer.IsAlive() && (cArgs[0].ToLowercase() == "!dosh" || cArgs[0].ToLowercase() == "/dosh")){
    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[ThrowDosh] Sorry, but you can't throw dosh since you're dead now.\n");
    pParams.ShouldHide = true;
  }
  if(pPlayer !is null && pPlayer.IsAlive() && (cArgs[0].ToLowercase() == "!dosh" || cArgs[0].ToLowercase() == "/dosh")){
    int doshTotal = atoi(cArgs[1]);
    if(doshTotal < fragsEachDosh){
      doshTotal = fragsEachDosh;
    }
    int doshAmount = doshTotal / fragsEachDosh;
    if(pPlayer.pev.frags >= fragsEachDosh * doshAmount){
      for(int i=0; i<doshAmount; i++){
        TraceResult tr;
        Vector vecSrc = pPlayer.GetGunPosition();
        Vector vecAiming = pPlayer.GetAutoaimVector(AUTOAIM_5DEGREES);
        Vector vecEnd = vecSrc + vecAiming * 4096;
        g_Utility.TraceLine(vecSrc, vecEnd, dont_ignore_monsters, pPlayer.edict(), tr);
        
        CBaseEntity@ newEntity = g_EntityFuncs.Create("item_dosh", tr.vecEndPos + Vector(3*i, 3*i, 0), Vector(0, 0, 0), false);
        newEntity.KeyValue("m_flCustomRespawnTime", "-1");
        newEntity.pev.rendermode = kRenderNormal;
        newEntity.pev.renderfx = kRenderFxGlowShell;
        newEntity.pev.renderamt = 0;
        newEntity.pev.rendercolor = Vector(0,255,0);
        newEntity.pev.targetname = string(getPlayerIndex(pPlayer));
        
        pPlayer.pev.frags -= fragsEachDosh;
      }
    }else{
      g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[ThrowDosh] Sorry, but you don't have enough dosh.\n");
    }
    pParams.ShouldHide = true;
    return HOOK_HANDLED;
  }
  return HOOK_CONTINUE;
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