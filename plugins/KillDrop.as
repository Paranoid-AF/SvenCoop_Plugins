#include "Random";
#include "KillDropConf";
Random::PCG randomObj = Random::PCG();
array<EHandle> monsterList;
array<string> nameList;
array<Vector> posList;
CScheduledFunction@ refreshMonster;

void PluginInit(){
  g_Module.ScriptInfo.SetAuthor("Paranoid_AF");
  g_Module.ScriptInfo.SetContactInfo("Feel free to contact me on GitHub.");
}

void MapInit(){
  g_Scheduler.ClearTimerList();
  monsterList.removeRange(0, monsterList.length());
  nameList.removeRange(0, nameList.length());
  posList.removeRange(0, posList.length());
  @refreshMonster = null;
  bool mapAllowed = true;
  for(int i=0; i<int(bannedMaps.length()); i++){
    if(bannedMaps[i] == g_Engine.mapname){
      mapAllowed = false;
      break;
    }
  }
  if(mapAllowed){
    @refreshMonster = g_Scheduler.SetInterval("timer_refreshMonster", 0.3, g_Scheduler.REPEAT_INFINITE_TIMES);
  }
}

void timer_refreshMonster(){
  for(int i=0; i<int(monsterList.length()); i++){
    CBaseEntity@ thatMonster = monsterList[i];
    if(thatMonster is null || !thatMonster.IsAlive()){
      dropItems(nameList[i], posList[i]);
    }
  }
  monsterList.removeRange(0, monsterList.length());
  nameList.removeRange(0, nameList.length());
  posList.removeRange(0, posList.length());
  CBaseEntity@ thisMonster = null;
  int monsterNumber = 0;
  while((@thisMonster = g_EntityFuncs.FindEntityByClassname(thisMonster, "monster_*")) !is null){
    int relationship = thisMonster.IRelationshipByClass(CLASS_PLAYER);
    if(thisMonster.IsAlive() && relationship != R_AL && relationship != R_NO){
      EHandle thisMonsterHandle = thisMonster;
      monsterList.insertLast(thisMonsterHandle);
      nameList.insertLast(thisMonster.GetClassname());
      posList.insertLast(thisMonster.GetOrigin());
    }
  }
}

void dropItems(string monsterName, Vector position){
  if(dropList.exists(monsterName)){
    dictionary dropLoot = cast<dictionary>(dropList[monsterName]);
    array<string> dictKeys = dropLoot.getKeys();
    int randomSum = 0;
    for(int i=0; i<int(dictKeys.length()); i++){
      randomSum += int(dropLoot[dictKeys[i]]);
    }
    int randomNum = int(randomObj.nextInt(randomSum + 1));
    int thisRandom = 0;
    for(int i=0; i<int(dictKeys.length()); i++){
      thisRandom += int(dropLoot[dictKeys[i]]);
      if(thisRandom >= randomNum){
        g_EntityFuncs.Create(dictKeys[i], position + Vector(0, 0, 50), Vector(0, 0, 0), false).KeyValue("m_flCustomRespawnTime", "-1");
        break;
      }
    }
  }
}