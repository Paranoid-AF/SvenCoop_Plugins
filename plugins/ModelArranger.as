#include "an_PseudoHooks"
array<array<string>> restrictedMaps = {
                              {"hl_c00", "hl_c04"},
                              {"touhou_hakureijinja"}
};
array<array<string>> allowedModels = {
                              {"gordon", "robo", "helmet"},
                              {"touhou_akyuu", "touhou_aya", "touhou_chen", "touhou_cirno", "touhou_daiyousei", "touhou_eirin", "touhou_flandre", "touhou_iku", "touhou_keine"}
};
string g_pMCkey;
void PluginInit(){
  g_Module.ScriptInfo.SetAuthor("Paranoid_AF");
  g_Module.ScriptInfo.SetContactInfo("Feel free to contact me on GitHub.");
  g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @PlayerJoin);
  g_PseudoHooks.RegisterHook( Hooks::Pseudo::Player::ClientUserInfoChanged, any( @playerModelChanged ), g_pMCkey, dictionary={{ CUIC_ARG_KEY, "model" }});
}

void MapActivate(){
  regularAllPlayerModels();
}

HookReturnCode playerModelChanged(KeyValueBuffer@ pKVB,const string &in szKey,const string &in szOldValue){
  array<string> cAllowedModels = fetchAllowedModels(g_Engine.mapname);
  if(szKey == "model"){
    string szNewValue = pKVB.GetValue(szKey);
    if(cAllowedModels.length() > 0 && cAllowedModels.find(szNewValue) < 0){
      CBasePlayer@ pPlayer = cast<CBasePlayer>(g_EntityFuncs.Instance(pKVB.GetClient()));
      if( pPlayer !is null && pPlayer.IsConnected()){
        g_PlayerFuncs.ClientPrint( @pPlayer, HUD_PRINTCONSOLE, "[MDLARR] Only following models are allowed:" + listArray(cAllowedModels) + ". Please pick one from them.\n");
        pKVB.SetValue(szKey, cAllowedModels[0]);
        return HOOK_HANDLED;
      }
    }
  }
  return HOOK_CONTINUE;
}

HookReturnCode PlayerJoin(CBasePlayer@ pPlayer){
  regularSomePlayer(pPlayer);
  return HOOK_HANDLED;
}

array<string> fetchAllowedModels(string mapName){
  int mapIndex;
  int thisIndex;
  int lengthOfRM = restrictedMaps.length();
  for(int i = 1; i <= lengthOfRM; i++){
    mapIndex = restrictedMaps[i -1].find(mapName);
    if(mapIndex >= 0){
      thisIndex = i - 1;
      break;
    }
  }
  if(mapIndex >=0){
    return allowedModels[thisIndex];
  } else {
    return {};
  }
}

void regularSomePlayer(CBasePlayer@ pPlayer){
  array<string> cAllowedModels = fetchAllowedModels(g_Engine.mapname);
  if (cAllowedModels.length() > 0 && pPlayer !is null && pPlayer.IsConnected()){
    KeyValueBuffer@ pInfo = g_EngineFuncs.GetInfoKeyBuffer(pPlayer.edict());
    string cPlayerModel = pInfo.GetValue("model");
    if(cAllowedModels.find(cPlayerModel) < 0){
      g_PlayerFuncs.ClientPrint( @pPlayer, HUD_PRINTCONSOLE, "[MDLARR] Only following models are allowed:" + listArray(cAllowedModels) + ". Please pick one from them.\n");
      pInfo.SetValue("model", cAllowedModels[0]);
    }
  }
}

string listArray(array<string> targetArray){
  int lengthOfArray = targetArray.length();
  string outputString;
  for(int i = 1; i <= lengthOfArray; i++){
    outputString = " " + outputString + targetArray[i - 1];
    if(i != lengthOfArray){
      outputString = outputString + ",";
    }
  }
  return outputString;
}

void regularAllPlayerModels(){
  for(int i = 1; i <= g_Engine.maxClients; i++){
    regularSomePlayer(g_PlayerFuncs.FindPlayerByIndex(i));
  }
}