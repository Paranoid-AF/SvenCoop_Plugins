// List of kill drops.
// Pretty much like: {"Monster Entity Name", dictionary = {{"Drop Entity Name", Chance by Percentage}, {"Drop Entity Name", Chance by Percentage}}},
// You could add more than two items, just follow the dictionary grammar of Angelscript.
dictionary dropList = {
                        {"monster_human_grunt", dictionary = {{"ammo_buckshot", 50}, {"ammo_ARgrenades", 50}}}, 
                        {"monster2", dictionary = {{"item2", 20}, {"item4", 80}}}
};

// List of the maps in which you'd like to disable this plugin.
array<string> bannedMaps = {"stadium4", "ctf_warforts", "botparty"};