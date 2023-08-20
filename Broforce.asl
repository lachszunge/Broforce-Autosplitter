/*
* Current Features:
* Split after every level, except final level
* Remove loads when playing in online lobby
* Reset run when entering main menu
* Load Removal
*
* Missing Features:
* Automatic Start
* Final Split
*/

state("Broforce_beta")
{
}

startup
{
	//This is the bytecode for the GameState::getInstance() method
	//Three packages of 00 have been added to the beginning, otherwise a unique match may not be found in memory

	String signatureGameState = "00 00 " +	//add [rax],al
				"00 55 48 " +				//add [rbp + 48],dl
				"8B EC " +					//mov ebp,esp
				"48 83 EC 10 " +			//sub rsp,10
				"48 B8 ???????????????? " +	//mov rax,????????????????			<--- GameState.Instance
				"48 8B 00 " +				//mov rax,[rax]
				"48 85 C0 " +				//test rax,rax
				"0F85 4C000000 " +			//jne GameState:get_Instance+6a
				"48 B9 ???????????????? " +	//mov rcx,????????????????
				"48 83 EC 20 " +			//sub rsp,20
				"49 BB ???????????????? " +	//mov r11,System:Object:_icall_wrapper_mono_object_new_fast
				"41 FF D3 " +				//call r11
				"48 83 C4 20 " +			//add rsp,20
				"48 89 45 F8 " +			//mov [rbp-08],rax
				"48 8B C8 " +				//mov rcx,rax
				"48 83 EC 20 " +			//sub rsp,20
				"49 BB ???????????????? " +	//mov r11,GameState:.ctor
				"41 FF D3 " +				//call r11
				"48 83 C4 20 " +			//add rsp,20
				"48 8B 4D F8 " +			//mov rcx,[rbp-08]
				"48 B8 ???????????????? " +	//mov rax,????????????????
				"48 89 08 " +				//mov [rax],rcx
				"48 B8 ???????????????? " +	//mov rax,????????????????0
				"48 8B 00 " +				//mov rax,[rax]
				"C9 " +						//leave
				"C3";						//ret

	//This is the Bytecode for the SceneLoader::LevelLoadComplete() method

	String signatureIsLoadingScene = "00 00 00 " +
				"55 " +
				"48 8B EC " +
				"48 83 EC 10 " +
				"48 89 4D F8 " +
				"48 89 55 F0 " +
				"48 B8 ???????????????? " +		//<----- _numScenesLoading
				"48 63 08 " +
				"FF C1 " +
				"48 B8 ???????????????? " +
				"89 08 " +
				"48 B8 ???????????????? " +		//<----- _isLoadingScene
				"C6 00 01 " +
				"48 8B 4D F8 " +
				"48 63 55 F0 " +
				"48 83 EC 20 " +
				"49 BB ???????????????? " +
				"41 FF D3 " +
				"48 83 C4 20 " +
				"C9 " +
				"C3 00 00";

	//This is the Bytecode for the HealthBar::HideHealthBar() method

	String signatureHealthBar = "00 00 " +		//0
				"55 " +							//2
				"48 8B EC " +					//3
				"48 B8 ???????????????? " +		//<----- HealthBar.Instance
				"48 8B 00 " +
				"48 8B C8 " +
				"48 83 EC 20" +
				"83 38 00 " +
				"49 BB ????????????????" +		//<----- HealthBar:Hide
				"41 FF D3 " +
				"48 83 C4 20 " +
				"C9 " +
				"C3 " +
				"00 00";
						
						
						
	//The Byte offset inside the signature is defined here (0x30 HEX = 48 DEC)
	vars.scanGameState = new SigScanTarget(0xD, signatureGameState);
	vars.scanIsLoading = new SigScanTarget(0x30, signatureIsLoadingScene);
	vars.scanHealthBar = new SigScanTarget(0x8, signatureHealthBar);

	//Settings
	settings.Add("bossSplit", false, "Split only after Boss (Arcade)");
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

	settings.Add("loadRemoval", true, "Remove Load Times");
	settings.SetToolTip("loadRemoval", "Pauses the timer when the game loads");

	settings.Add("campaignSplits", false, "Spllit after every World (Campaign)");

	settings.Add("autoReset", true, "Automatically reset when in Main Menu");
	
	vars.bossLevels = new int[14] {5, 10, 15, 18, 22, 26, 29, 34, 39, 44, 49, 57, 61, 63};
	vars.bossKillCount = 0;
}

init
{

	
	vars.selectedBossLevels = new bool[14] 
	{
		settings["bossTerrorkopter"], settings["bossGR666"], settings["bossMegacockter"],
		settings["bossStealthTank"], settings["bossSkyFortress"], settings["bossRailFortress"],
		settings["bossTerrorbot"], settings["bossAcidCrawler"], settings["bossHumongoCrawler"],
		settings["bossTerrorkrawler"], settings["bossHeart"], settings["bossBoneWurm"],
		settings["bossSatan"], settings["bossSatanTrue"]
	};

	var ptrGameState = IntPtr.Zero;
	var ptrIsLoading = IntPtr.Zero;
	var ptrHealthBar = IntPtr.Zero;

	//Scan the memory for the specified signatures
    foreach (var page in game.MemoryPages(true))
    {
		var scanner = new SignatureScanner(game, page.BaseAddress, (int)page.RegionSize);

		if (ptrGameState == IntPtr.Zero)
		{
			ptrGameState = scanner.Scan(vars.scanGameState);
		}
		if (ptrIsLoading == IntPtr.Zero)
		{
			ptrIsLoading = scanner.Scan(vars.scanIsLoading);
		}
		if (ptrHealthBar == IntPtr.Zero)
		{
			ptrHealthBar = scanner.Scan(vars.scanHealthBar);
		}
		
		//once both signatures have been found abort the search
		if (ptrGameState != IntPtr.Zero && ptrIsLoading != IntPtr.Zero && ptrHealthBar != IntPtr.Zero)
		{
			break;
		}
    }

	//If no match is found throw an error
    if (ptrGameState == IntPtr.Zero)
    {
        Thread.Sleep(5000);
		print("OH NO: Game State couldnt be located");
        throw new Exception();
		
    }
	if (ptrIsLoading == IntPtr.Zero)
	{
        Thread.Sleep(5000);
		print("OH NO: IsLoading couldnt be located");
        throw new Exception();
    }

	if (ptrHealthBar == IntPtr.Zero)
	{
        Thread.Sleep(5000);
		print("OH NO: HealthBar couldnt be located");
        throw new Exception();
    }

	//Define Watchers to constantly read the found addresses
	vars.watchers = new MemoryWatcherList();
	vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer(ptrGameState, 0x0, 0x38)) {Name = "level"});
	vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer(ptrGameState, 0x0, 0x48)) {Name = "gameMode"});
	vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer(ptrIsLoading, 0x0)) {Name = "isLoading"});
	vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer(ptrHealthBar, 0x0, 0x40)) {Name = "healthBarVisible"});
	vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer(ptrHealthBar, 0x0, 0x30, 0xD4)) {Name = "healthBarUnitHealth"});
}

update
{
	//update watcher variables
	vars.watchers.UpdateAll(game);

	if(vars.watchers["level"].Current == 0)
	{
		vars.bossKillCount = 0;
	}
}

reset
{
	//GameMode 5 = NotSet; 
	if (settings["autoReset"] && vars.watchers["gameMode"].Current == 5) {
		return true;
	}
}

isLoading
{
	if (settings["loadRemoval"] && vars.watchers["isLoading"].Current == 1) {
		return true;
	}
	return false;
}

split
{
	if (vars.watchers["level"].Current == 63 && vars.watchers["healthBarVisible"].Current == 1 && vars.watchers["healthBarUnitHealth"].Current == -1)
	{
		return true;
	}

	if (vars.watchers["level"].Current == vars.watchers["level"].Old + 1 && !settings["campaignSplits"])
	{
		
		if(settings["bossSplit"])
		{
			if(vars.watchers["level"].Old == vars.bossLevels[vars.bossKillCount] )
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
	else if (settings["campaignSplits"] && vars.watchers["level"].Current < vars.watchers["level"].Old)
	{
		return true;
	}
	return false;
}
