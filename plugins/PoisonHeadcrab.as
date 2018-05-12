#include "an_PseudoHooks"
CScheduledFunction@ headcrabRefreshTimer;
CScheduledFunction@ regenHealth;
EHandle h_Headcrab;
string g_PTDKey;
array<int> modifiedList;
array<float> lastDeduct(g_Engine.maxClients + 1);
array<int> healthToRecover(g_Engine.maxClients + 1);
void PluginInit(){
  g_Module.ScriptInfo.SetAuthor("Paranoid_AF");
  g_Module.ScriptInfo.SetContactInfo("Feel free to contact me on GitHub.");
  g_PseudoHooks.RegisterHook(Hooks::Pseudo::Player::PlayerPostTakeDamage, any(@playerTakeDamage), g_PTDKey);
}
void MapActivate(){
  g_Scheduler.ClearTimerList();
  for(int i = 0; i <= (int(modifiedList.length()) - 1); i++){
    modifiedList.removeLast();
  }
  for(int i = 1; i <= (int(lastDeduct.length()) - 1); i++){
    lastDeduct[i] = 0;
  }
  for(int i = 1; i <= (int(healthToRecover.length()) - 1); i++){
    healthToRecover[i] = 0;
  }
  @headcrabRefreshTimer = g_Scheduler.SetInterval("timer_searchForHeadcrabs", 1, g_Scheduler.REPEAT_INFINITE_TIMES);
  @regenHealth = g_Scheduler.SetInterval("timer_regenHealth", 2.5, g_Scheduler.REPEAT_INFINITE_TIMES);
}

void timer_searchForHeadcrabs(){
  CBaseEntity@ headcrabEntity = h_Headcrab;
  @headcrabEntity = g_EntityFuncs.FindEntityByClassname(@headcrabEntity, "monster_headcrab");
  if(@headcrabEntity !is null){
    tweakForHeadcrabs(@headcrabEntity);
    h_Headcrab = headcrabEntity;
  }
}

void tweakForHeadcrabs(CBaseEntity@ headcrabEntity){
	headcrabEntity.pev.rendermode = kRenderNormal;
	headcrabEntity.pev.renderfx = kRenderFxGlowShell;
	headcrabEntity.pev.renderamt = 0;
	headcrabEntity.pev.rendercolor = Vector(255,0,0);
  modifiedList.insertLast(g_EntityFuncs.EntIndex(@headcrabEntity.edict()));
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

bool isEntityModified(int edictIndex){
  bool isModified = false;
  for(int i = 0; i <= (int(modifiedList.length())-1); i++){
    if(modifiedList[i] == edictIndex){
      isModified = true;
      break;
    }
  }
  return isModified;
}

HookReturnCode playerTakeDamage( CBasePlayer@ pVictim, edict_t@ pEdInflictor, edict_t@ pEdAttacker, const float flDamage, const int bitsDamageType, const uint bitsTrigger )
{
  int thisDamage = int(Math.Floor(flDamage + 0.2f));
  int thisPlayer = getPlayerIndex(pVictim);
  if(pVictim.pev.health == 0 || !pVictim.IsAlive() || pVictim.pev.deadflag == DEAD_DYING){
    if(healthToRecover[thisPlayer] > 0){
      CBasePlayer@ cFindPlayerByName = null;
      @cFindPlayerByName = g_PlayerFuncs.FindPlayerByIndex(thisPlayer);
      if(cFindPlayerByName is null){
        healthToRecover[thisPlayer] = 0;
      }
    }
  }else{
    if((g_Engine.time - lastDeduct[thisPlayer]) > 0.8f){
      if(isEntityModified(g_EngineFuncs.IndexOfEdict(pEdInflictor))){
        if(int(pVictim.pev.health) > thisDamage){
          g_PlayerFuncs.SayText(pVictim, "[H.E.V. Mark IV] Neurotoxin detected! Injecting antidote...\n");
          healthToRecover[thisPlayer] += (int(pVictim.pev.health) - 1 - thisDamage);
          pVictim.pev.health = 1;
        }
      }
    }
  }
  lastDeduct[thisPlayer] = g_Engine.time;
	return HOOK_CONTINUE;
}

void timer_regenHealth(){
  for(int i = 1; i <= (int(healthToRecover.length())-1); i++){
    if(healthToRecover[i] > 0){
      CBasePlayer@ cFindPlayerByName = null;
      @cFindPlayerByName = g_PlayerFuncs.FindPlayerByIndex(i);
      if(cFindPlayerByName !is null){
        if(cFindPlayerByName.pev.health < cFindPlayerByName.pev.max_health){
          if(healthToRecover[i] > 10){
            healthToRecover[i] -= 10;
            cFindPlayerByName.pev.health += 10;
          }else{
            cFindPlayerByName.pev.health += healthToRecover[i];
            healthToRecover[i] = 0;
          }
        }
      }
    }
  }
}
