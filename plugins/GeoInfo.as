const string DataPath = "scripts/plugins/GeoInfo/";
dictionary LocationLocale;
void PluginInit(){
  g_Module.ScriptInfo.SetAuthor("Paranoid_AF");
  g_Module.ScriptInfo.SetContactInfo("Feel free to contact me on GitHub.");
  g_Hooks.RegisterHook(Hooks::Player::ClientConnected, @onJoin);
  LoadLocale();
}

HookReturnCode onJoin(edict_t@ pEntity, const string& in szPlayerName, const string& in szIPAddress, bool& out bDisallowJoin, string& out szRejectReason){
  string IP = szIPAddress;
  int FirstSymbol = int(IP.FindFirstOf(":", 0));
  if(FirstSymbol >= 0 && FirstSymbol < int(IP.Length())){
    IP = IP.SubString(0, FirstSymbol);
  }
  string Content = string(LocationLocale["MESSAGE_JOIN"]);
  Content.Replace("%LOCATION%", string(LocationLocale[GetGeoByIP(IP)]));
  Content.Replace("%NAME%", szPlayerName);
  g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, Content+"\n");
  g_Log.PrintF("[INFO - GeoInfo] "+Content+"\n");
  return HOOK_CONTINUE;
}

string GetGeoByIP(string IP){
  if(IP == "127.0.0.1" || IP == "localhost" || IP == "loopback"){
    return "LOCALHOST";
  }
  string Location = "UNKNOWN";
  array<string> FormattedIP = IP.Split(".");
  uint intIP = (atoi(FormattedIP[0]) << 24) + (atoi(FormattedIP[1]) << 16) + (atoi(FormattedIP[2]) << 8) + atoi(FormattedIP[3]);
  IP = string(intIP);
  string Filename = IP.SubString(0, 4);
  Location = GetLocation(IP, Filename);
  int counter = 0;
  while(Location == "UNKNOWN"){
    counter++;
    Location = GetLocation(IP, string(atoi(Filename)-counter));
    if(counter > 10){
      break;
    }
  }
  return Location;
}

void LoadLocale(){
	File@ file = g_FileSystem.OpenFile(DataPath+"Locale.csv", OpenFile::READ);
	if(file !is null && file.IsOpen()){
		while(!file.EOFReached()){
			string sLine;
			file.ReadLine(sLine);
      if(int(sLine.Length()) > 0){
        array<string> ProperData = sLine.Split(",");
        LocationLocale.set(string(ProperData[0]), string(ProperData[1]));
      }
		}
		file.Close();
	}else{
    g_Game.AlertMessage(at_console, "[ERROR - GeoInfo] Cannot read IP locale file: Locale.csv" + ", check if it exists and SCDS has the permission to access it!\n");
  }
}
string GetLocation(string IP, string Filename){
  string Location = "UNKNOWN";
	File@ file = g_FileSystem.OpenFile(DataPath+Filename+".csv", OpenFile::READ);
	if(file !is null && file.IsOpen()){
		while(!file.EOFReached()){
			string sLine;
			file.ReadLine(sLine);
      if(int(sLine.Length()) > 0){
        array<string> ProperData = sLine.Split(",");
        if(IP.Compare(ProperData[0]) >= 0 && IP.Compare(ProperData[1]) <= 0){
          Location = ProperData[2];
          break;
        }
      }
		}
		file.Close();
	}
  return Location;
}
