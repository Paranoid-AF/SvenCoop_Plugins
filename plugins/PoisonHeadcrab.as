#include "an_PseudoHooks"
CScheduledFunction@ headcrabRefreshTimer;
CScheduledFunction@ regenHealth;
CScheduledFunction@ healthDeduct;
CScheduledFunction@ healthRefresh;
EHandle h_Headcrab;
string g_PTDKey;
array<int> modifiedList;
array<int> healthToRecover(g_Engine.maxClients + 1);
array<int> currentHealth(g_Engine.maxClients + 1);
void PluginInit(){
  g_Module.ScriptInfo.SetAuthor("Paranoid_AF");
  g_Module.ScriptInfo.SetContactInfo("Feel free to contact me on GitHub.");
  g_PseudoHooks.RegisterHook(Hooks::Pseudo::Player::PlayerPostTakeDamage, any(@playerTakeDamage), g_PTDKey);
}
void MapActivate(){
  g_Scheduler.ClearTimerList();
  @headcrabRefreshTimer = g_Scheduler.SetInterval("timer_searchForHeadcrabs", 1, g_Scheduler.REPEAT_INFINITE_TIMES);
  @regenHealth = g_Scheduler.SetInterval("timer_regenHealth", 2.5, g_Scheduler.REPEAT_INFINITE_TIMES);
  @healthDeduct = g_Scheduler.SetInterval("timer_healthDeduct", 0.3, g_Scheduler.REPEAT_INFINITE_TIMES);
  @healthRefresh = g_Scheduler.SetInterval("timer_healthRefresh", 1, g_Scheduler.REPEAT_INFINITE_TIMES);
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
	if(isEntityModified(g_EngineFuncs.IndexOfEdict(pEdInflictor))){
    int thisDamage = int(Math.Floor(flDamage + 0.5f));
    healthToRecover[getPlayerIndex(pVictim)] = (currentHealth[getPlayerIndex(pVictim)] - thisDamage - 1);
    pVictim.pev.health = 1;
  }
	return HOOK_CONTINUE;
}

void timer_healthRefresh(){
  for(int i = 1; i <= (int(currentHealth.length())-1); i++){
    CBasePlayer@ cFindPlayerByName = g_PlayerFuncs.FindPlayerByIndex(i);
    if(cFindPlayerByName !is null){
      currentHealth[i] = int(cFindPlayerByName.pev.health);
    }
  }
}

void timer_regenHealth(){
  for(int i = 1; i <= (int(healthToRecover.length())-1); i++){
    if(healthToRecover[i] > 0){
      CBasePlayer@ cFindPlayerByName = null;
      @cFindPlayerByName = g_PlayerFuncs.FindPlayerByIndex(i);
      if(cFindPlayerByName !is null){
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

void timer_healthDeduct(){
  for(int i = 1; i <= (int(healthToRecover.length())-1); i++){
    if(healthToRecover[i] > 0){
      CBasePlayer@ cFindPlayerByName = null;
      @cFindPlayerByName = g_PlayerFuncs.FindPlayerByIndex(i);
      if(cFindPlayerByName is null){
        healthToRecover[i] = 0;
      }
    }
  }
}