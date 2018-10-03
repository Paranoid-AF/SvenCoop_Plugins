// NOTE: This is the config file for the BuyStuff plugin.
array<array<string>> bsConf = { // Format: Entity Name, Display Name, Price, Category
                              {"weapon_crowbar", "Crowbar", "1", "Melee & Essentials"},
                              {"weapon_9mmhandgun", "9mm Pistol", "15", "Secondary"}
};
string bsTitle = "Buy Stuff"; // Title of the buy menu
string bsDescription = "Purchase items using your scores."; // Description of the buy menu
array<array<string>> disallowedWeapons = { // The first one should be the map name, the followed should be weapons that are banned in the map. However, if an array has only the map name, everything will be disallowed to be purchased.
                                         {"abandoned", "9mm Pistol"}
};