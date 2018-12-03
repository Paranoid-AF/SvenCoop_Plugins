int fragsEachDosh = 5;
int MaxDoshAmount = 255;
array<float> lastSoundEffect(g_Engine.maxClients);
void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor("Paranoid_AF & Dr. Abc.");
	g_Module.ScriptInfo.SetContactInfo("Feel free to contact Paranoid_AF on GitHub.");
	g_Hooks.RegisterHook(Hooks::Player::ClientSay, @onChat);
	g_Hooks.RegisterHook(Hooks::Player::ClientDisconnect, @onDisconnect);
}

void MapInit(){
  for(int i=0; i<g_Engine.maxClients; i++){
    lastSoundEffect[i] = g_Engine.time;
  }
	g_Game.PrecacheModel("models/common/dosh.mdl");
	g_SoundSystem.PrecacheSound("common/dosh.wav");
	g_Game.PrecacheGeneric("sound/common/dosh.wav");
	g_CustomEntityFuncs.RegisterCustomEntity("item_dosh", "item_dosh");
}

HookReturnCode onDisconnect(CBasePlayer@ pPlayer){
	CBaseEntity@ pEntity = null;
	while((@pEntity = g_EntityFuncs.FindEntityByClassname(pEntity, "item_dosh")) !is null)
	{
		if(pEntity.pev.targetname == string(getPlayerIndex(pPlayer)))
			g_EntityFuncs.Remove(pEntity);
	}
	return HOOK_HANDLED;
}

class item_dosh: ScriptBasePlayerAmmoEntity{
	void Spawn()
	{ 
		g_EntityFuncs.SetModel(self, "models/common/dosh.mdl");
		BaseClass.Spawn();
	}

	bool AddAmmo(CBaseEntity@ pOther)
	{
		CBaseEntity@ pPlayer = cast<CBaseEntity@>(g_PlayerFuncs.FindPlayerByIndex(atoi(self.pev.targetname)));
		if(pPlayer !is null)
		{
			pOther.pev.frags += fragsEachDosh;
      if(g_Engine.time - lastSoundEffect[getPlayerIndex(cast<CBasePlayer@>(pOther)) - 1] >= 1){
        if(pPlayer !is pOther){
          g_PlayerFuncs.ClientPrint(cast<CBasePlayer@>(pOther), HUD_PRINTTALK, "[ThrowDosh] You just received " + string(fragsEachDosh) + " scores from "+ g_PlayerFuncs.FindPlayerByIndex(atoi(self.pev.targetname)).pev.netname +".\n");
        }
        g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, "common/dosh.wav", 1, ATTN_NORM);
        lastSoundEffect[getPlayerIndex(cast<CBasePlayer@>(pOther)) - 1] = g_Engine.time;
      }
			
		return true;
		}
		else
		{
			return false;
		}
	}
}

HookReturnCode onChat(SayParameters@ pParams){
	CBasePlayer@ pPlayer = pParams.GetPlayer();
	const CCommand@ cArgs = pParams.GetArguments();
	if(pPlayer !is null && !pPlayer.IsAlive() && (cArgs[0].ToLowercase() == "!dosh" || cArgs[0].ToLowercase() == "/dosh"))
	{
		g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[ThrowDosh] Sorry, but you can't throw dosh since you're dead now.\n");
		pParams.ShouldHide = true;
	}
	
	if(pPlayer !is null && pPlayer.IsAlive() && (cArgs[0].ToLowercase() == "!dosh" || cArgs[0].ToLowercase() == "/dosh"))
	{
		int doshTotal = ((atoi(cArgs[1]) >= MaxDoshAmount) ? MaxDoshAmount : (atoi(cArgs[1])));
		if(doshTotal < fragsEachDosh)
			doshTotal = fragsEachDosh;
		int doshAmount = ((doshTotal >= 1) ?  doshTotal / fragsEachDosh : 1);
	if(pPlayer.pev.frags >= fragsEachDosh * doshAmount)
	{
		for(int i=0; i<doshAmount; i++)
		{
        CBaseEntity@ pDosh = g_EntityFuncs.Create("item_dosh", pPlayer.pev.origin + g_Engine.v_forward * 30 + g_Engine.v_up * 5 ,Vector(Math.RandomLong (-25,25),Math.RandomLong (-25,25),Math.RandomLong (-25,25)), false);
		pDosh.pev.velocity = pPlayer.pev.velocity + g_Engine.v_forward * Math.RandomLong (250,300) + g_Engine.v_up * Math.RandomLong (140,200) + g_Engine.v_right * Math.RandomLong (-25,25);
        pDosh.pev.angles = Math.VecToAngles( pDosh.pev.velocity );
        pDosh.KeyValue("m_flCustomRespawnTime", "-1");
        pDosh.pev.targetname = string(getPlayerIndex(pPlayer));
        
        pPlayer.pev.frags -= fragsEachDosh;
		}
	}
	else
	{
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
	for(int i = 1; i <= g_Engine.maxClients; i++)
	{
		@findPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
		if(findPlayer is pPlayer)
		{
			thisIndex = i;
			break;
		}
	}
	return thisIndex;
}