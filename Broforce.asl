state("Broforce_beta")
{
}
startup
{
	vars.scanTarget = new SigScanTarget(15, "00 00 00 00 00 00 00 55 8B EC 83 EC 08 8B 05 ???????? 85 C0 75 29 83 EC 0C 68 ???????? E8 ???????? 83 C4 10 83 EC 0C 89 45 FC 50 E8 ???????? 83 C4 10 8B 4D FC B8 ???????? 89 08 8B 05 ???????? C9 C3");

	//Settings
	settings.Add("bossSplit", false, "Split only after Boss");
	settings.SetToolTip("bossSplit", "Split only after a Boss Level (Restart livesplit/game to register change)");
	settings.Add("bossTerrorkopter", true, "Terrorkopter", "bossSplit");
	settings.Add("bossGR666", true, "GR666", "bossSplit");
	settings.Add("bossMegacockter", true, "Megacockter", "bossSplit");
	settings.Add("bossStealthTank", true, "Stealth Tank", "bossSplit");
	settings.Add("bossSkyFortress", true, "Sky Fortress", "bossSplit");
	settings.Add("bossRailFortress", true, "Rail Fortress", "bossSplit");
	settings.Add("bossTerrorbot", true, "Terrorbot", "bossSplit");
	settings.Add("bossAcidCrawler", true, "Acid Crawler", "bossSplit");
	settings.Add("bossHumongoCrawler", true, "Humongo Crawler", "bossSplit");
	settings.Add("bossTerrorkrawler", true, "Terrorkrawler", "bossSplit");
	settings.Add("bossHeart", true, "Heart of the Hive", "bossSplit");
	settings.Add("bossBoneWurm", true, "Bone Wurm", "bossSplit");
	settings.Add("bossSatan", true, "Satan", "bossSplit");
	settings.Add("bossSatanTrue", true, "Satan True Form", "bossSplit");
	

	vars.bossLevels = new int[14] {5, 10, 15, 18, 22, 26, 29, 34, 39, 44, 49, 57, 61, 63};
	


}
init
{

	vars.bossKillCount = 0;
	vars.selectedBossLevels = new bool[14] 
	{
		settings["bossTerrorkopter"], settings["bossGR666"], settings["bossMegacockter"],
		settings["bossStealthTank"], settings["bossSkyFortress"], settings["bossRailFortress"],
		settings["bossTerrorbot"], settings["bossAcidCrawler"], settings["bossHumongoCrawler"],
		settings["bossTerrorkrawler"], settings["bossHeart"], settings["bossBoneWurm"],
		settings["bossSatan"], settings["bossSatanTrue"]
	};


    var ptr = IntPtr.Zero;

    foreach (var page in game.MemoryPages(true)) {
		var scanner = new SignatureScanner(game, page.BaseAddress, (int)page.RegionSize);

		if (ptr == IntPtr.Zero) {
			ptr = scanner.Scan(vars.scanTarget);
		} else {
			break;
		}
    }
    if (ptr == IntPtr.Zero) {
        Thread.Sleep(1000);
		print("OH NOOO");
        throw new Exception();
		
    }
	vars.level = new MemoryWatcher<int>(new DeepPointer(ptr, 0x0, 0x18));
}

update
{
	vars.level.Update(game);

	if(vars.level.Current == 0){
		vars.bossKillCount = 0;
	}
}



split
{
	if (vars.level.Current == vars.level.Old + 1)
	{
		if(settings["bossSplit"])
		{
			if(vars.level.Old == vars.bossLevels[vars.bossKillCount] )
			{
				if(vars.selectedBossLevels[vars.bossKillCount])
				{
					vars.bossKillCount = vars.bossKillCount + 1;
					return true;
				}
				else
				{
					vars.bossKillCount = vars.bossKillCount + 1;
				}
			}
		}
		else
		{
			return true;
		}
	}
}
