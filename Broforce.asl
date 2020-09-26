state("Broforce_beta")
{
}
startup
{
	vars.scanTarget = new SigScanTarget(15, "00 00 00 00 00 00 00 55 8B EC 83 EC 08 8B 05 ???????? 85 C0 75 29 83 EC 0C 68 ???????? E8 ???????? 83 C4 10 83 EC 0C 89 45 FC 50 E8 ???????? 83 C4 10 8B 4D FC B8 ???????? 89 08 8B 05 ???????? C9 C3");

	//Settings
	settings.Add("bossSplit", false, "Split only after Boss");
	settings.SetToolTip("bossSplit", "Split only after a Boss Level");
	
	
	vars.bossLevels = new int[11] {5, 10, 15, 18, 22, 26, 29, 39, 44, 49, 63};
	vars.bossKillCount = 0;


}
init
{
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
}


split
{
	if (vars.level.Current == vars.level.Old + 1)
	{
		if(settings["bossSplit"])
		{
			if(vars.level.Old == vars.bossLevels[vars.bossKillCount])
			{
				vars.bossKillCount++;
				return true;
			}
			
		}
		else
		{
			return true;
		}
	}
}
