{ ... }: {

  unfreePackages = [ "minecraft-server" ];

  services.minecraft-server = {
    enable = true;
    eula = true;
    declarative = true;
    whitelist = { };
    openFirewall = true;
    serverProperties = {
      server-port = 25565;
      difficulty = "normal";
      gamemode = "survival";
      white-list = false;
      enforce-whitelist = false;
      level-name = "world";
      motd = "Welcome!";
      pvp = true;
      player-idle-timeout = 30;
      generate-structures = true;
      max-players = 20;
      snooper-enabled = false;
      spawn-npcs = true;
      spawn-animals = true;
      spawn-monsters = true;
      allow-nether = true;
      allow-flight = false;
    };
  };

}
