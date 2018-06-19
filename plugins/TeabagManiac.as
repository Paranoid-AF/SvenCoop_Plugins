bool lastStatus = false;
array<float> lastDuck(g_Engine.maxClients);
array<int> playerCombo(g_Engine.maxClients);
int hpEach = 3;
const int comboStarts = 2;
int pitchEachIncrease = 8;
void PluginInit(){
  g_Module.ScriptInfo.SetAuthor("Paranoid_AF");
  g_Module.ScriptInfo.SetContactInfo("Feel free to contact me on GitHub.");
}

void MapInit(){
  g_Game.PrecacheGeneric("sound/TeabagManiac/dip1.wav");
  g_Game.PrecacheGeneric("sound/TeabagManiac/dip2.wav");
  g_Game.PrecacheGeneric("sound/TeabagManiac/potato.wav");
  g_Game.PrecacheGeneric("sound/TeabagManiac/chip.wav");
  g_Game.PrecacheGeneric("sound/TeabagManiac/!dip1.wav");
  g_Game.PrecacheGeneric("sound/TeabagManiac/!dip2.wav");
  g_Game.PrecacheGeneric("sound/TeabagManiac/!potato.wav");
  g_Game.PrecacheGeneric("sound/TeabagManiac/!chip.wav");
  g_SoundSystem.PrecacheSound("TeabagManiac/dip1.wav");
  g_SoundSystem.PrecacheSound("TeabagManiac/dip2.wav");
  g_SoundSystem.PrecacheSound("TeabagManiac/potato.wav");
  g_SoundSystem.PrecacheSound("TeabagManiac/chip.wav");
  g_SoundSystem.PrecacheSound("TeabagManiac/!dip1.wav");
  g_SoundSystem.PrecacheSound("TeabagManiac/!dip2.wav");
  g_SoundSystem.PrecacheSound("TeabagManiac/!potato.wav");
  g_SoundSystem.PrecacheSound("TeabagManiac/!chip.wav");
  g_Hooks.RegisterHook(Hooks::Player::PlayerPreThink, @onChange);
}

HookReturnCode onChange(CBasePlayer@ pPlayer, uint& out uiFlags){
  if(pPlayer is null){
    g_PlayerFuncs.SayText(pPlayer, "[TeabagManiac] Invalid player!\n");
    return HOOK_CONTINUE;
  }
  int playerIndex = getPlayerIndex(pPlayer);
  int pitchIncrease = -pitchEachIncrease;
  if((pPlayer.pev.button & IN_DUCK ) != 0 && !lastStatus && (g_Engine.time - lastDuck[playerIndex]) > 0.5){
    if(playerCombo[playerIndex] > 0){
      if((pPlayer.pev.health + hpEach) > pPlayer.pev.max_health && (pPlayer.pev.max_health - hpEach) < pPlayer.pev.health){
        pPlayer.pev.health = pPlayer.pev.max_health;
      }
      if((pPlayer.pev.health + hpEach) <= pPlayer.pev.max_health){
        pPlayer.pev.health += hpEach;
      }
      if(playerCombo[playerIndex] > (comboStarts - 1)){
        int comboTemp = playerCombo[playerIndex];
        switch(playerCombo[playerIndex]){
        case comboStarts:
          g_SoundSystem.EmitSound(pPlayer.edict(), CHAN_ITEM, "TeabagManiac/dip1.wav", 1, ATTN_NORM);
          break;
        case (comboStarts+1):
          g_SoundSystem.EmitSound(pPlayer.edict(), CHAN_ITEM, "TeabagManiac/dip2.wav", 1, ATTN_NORM);
          break;
        case (comboStarts+2):
          g_SoundSystem.EmitSound(pPlayer.edict(), CHAN_ITEM, "TeabagManiac/potato.wav", 1, ATTN_NORM);
          break;
        case (comboStarts+3):
          g_SoundSystem.EmitSound(pPlayer.edict(), CHAN_ITEM, "TeabagManiac/chip.wav", 1, ATTN_NORM);
          break;
        default:
          while(comboTemp > (comboStarts + 3)){
            comboTemp -= 4;
            pitchIncrease += pitchEachIncrease;
          }
          pitchIncrease += 100;
          if(pitchIncrease > 255){
            pitchIncrease = 255;
          }
          switch(comboTemp){
          case comboStarts:
            g_SoundSystem.EmitSoundDyn(pPlayer.edict(), CHAN_ITEM, "TeabagManiac/!dip1.wav", 1, ATTN_NORM, SND_FORCE_SINGLE, pitchIncrease, 0);
            break;
          case (comboStarts+1):
            g_SoundSystem.EmitSoundDyn(pPlayer.edict(), CHAN_ITEM, "TeabagManiac/!dip2.wav", 1, ATTN_NORM, SND_FORCE_SINGLE, pitchIncrease, 0);
            break;
          case (comboStarts+2):
            g_SoundSystem.EmitSoundDyn(pPlayer.edict(), CHAN_ITEM, "TeabagManiac/!potato.wav", 1, ATTN_NORM, SND_FORCE_SINGLE, pitchIncrease, 0);
            break;
          case (comboStarts+3):
            g_SoundSystem.EmitSoundDyn(pPlayer.edict(), CHAN_ITEM, "TeabagManiac/!chip.wav", 1, ATTN_NORM, SND_FORCE_SINGLE, pitchIncrease, 0);
            break;
          }
        }
      }
    }
  playerCombo[playerIndex] += 1;
  lastStatus = true;
  lastDuck[playerIndex] = g_Engine.time;
  return HOOK_HANDLED;
  }
  if((pPlayer.pev.button & IN_DUCK ) == 0){
    lastStatus = false;
    if((g_Engine.time - lastDuck[playerIndex]) > 2){
      playerCombo[playerIndex] = 0;
    }
    return HOOK_CONTINUE;
  }
  return HOOK_CONTINUE;
}

int getPlayerIndex(CBasePlayer@ pPlayer){
  CBasePlayer@ cFindPlayer = null;
  int thisIndex;
  for(int i = 1; i <= g_Engine.maxClients; i++){
    @cFindPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
    if(cFindPlayer is pPlayer){
      thisIndex = i;
      break;
    }
  }
  return thisIndex;
}