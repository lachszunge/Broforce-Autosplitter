/*
* Current Features:
* Split after every level, except final level
* Remove loads when playing in online lobby
* Reset run when entering main menu
*
* Missing Features:
* Automatic Start
* Final Split
* Singleplayaer load removal
*/



state("Broforce_beta")
{
}

startup
{
	//OLD PATCH
	//String signatureNetworkStreamIsPaused = "55 8B EC 83 EC 08 0FB6 45 08 85 C0 74 05 E8 ???????? B9 ???????? 0FB6";
	//String signatureGameState = "00 00 00 00 00 00 00 55 8B EC 83 EC 08 8B 05 ???????? 85 C0 75 29 83 EC 0C 68 ???????? E8 ???????? 83 C4 10 83 EC 0C 89 45 FC 50 E8";


	//CURRENT PATCH
	String signatureNetworkStreamIsPaused = "74 15 " +			//je Networking:Networking:set_PauseStream+25
						"48 83 EC 20 " +		//sub rsp,20
						"49 BB ???????????????? " +	//mov r11 RPCBatcher:FlushQueue
						"41 FF D3 " +			//call r11
						"48 83 C4 20 " +		//add rsp,20
						"48 B8 ???????????????? " +	//mov rax,????????????????		<--- streamIsPaused
						"40 88 30 " +			//mov [rax],sil
						"85 F6";			//test esi,esi
						
	String signatureGameState = "00 00 " +				//add [rax],al
				"00 55 48 " +				//add [rbp + 48],dl
				"8B EC " +				//mov ebp,esp
				"48 83 EC 10 " +			//sub rsp,10
				"48 B8 ???????????????? " +		//mov rax,????????????????			<--- GameState.Instance
				"48 8B 00 " +				//mov rax,[rax]
				"48 85 C0 " +				//test rax,rax
				"0F85 4C000000 " +			//jne GameState:get_Instance+6a
				"48 B9 ???????????????? " +		//mov rcx,????????????????
				"48 83 EC 20 " +			//sub rsp,20
				"49 BB ???????????????? " +		//mov r11,System:Object:_icall_wrapper_mono_object_new_fast
				"41 FF D3 " +				//call r11
				"48 83 C4 20 " +			//add rsp,20
				"48 89 45 F8 " +			//mov [rbp-08],rax
				"48 8B C8 " +				//mov rcx,rax
				"48 83 EC 20 " +			//sub rsp,20
				"49 BB ???????????????? " +		//mov r11,GameState:.ctor
				"41 FF D3 " +				//call r11
				"48 83 C4 20 " +			//add rsp,20
				"48 8B 4D F8 " +			//mov rcx,[rbp-08]
				"48 B8 ???????????????? " +		//mov rax,????????????????
				"48 89 08 " +				//mov [rax],rcx
				"48 B8 ???????????????? " +		//mov rax,????????????????0
				"48 8B 00 " +				//mov rax,[rax]
				"C9 " +					//leave
				"C3";					//ret
						
						
						

	vars.scanGameState = new SigScanTarget(13, signatureGameState);
	vars.scanNetworkStreamIsPaused = new SigScanTarget(25, signatureNetworkStreamIsPaused);

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

	settings.Add("onlineLoadRemoval", true, "Use online Load Removal");
	settings.SetToolTip("onlineLoadRemoval", "This can be used to remove loading times in online Lobbys. This also works if you are playing solo in an online Lobby (mind performance!)");

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
	var ptrNetworkStreamIsPaused = IntPtr.Zero;

    foreach (var page in game.MemoryPages(true))
    {
		var scanner = new SignatureScanner(game, page.BaseAddress, (int)page.RegionSize);

		if (ptrGameState == IntPtr.Zero)
		{
			ptrGameState = scanner.Scan(vars.scanGameState);
		}
		if (ptrNetworkStreamIsPaused == IntPtr.Zero)
		{
			ptrNetworkStreamIsPaused = scanner.Scan(vars.scanNetworkStreamIsPaused);
		}
		
		if (ptrNetworkStreamIsPaused != IntPtr.Zero && ptrGameState != IntPtr.Zero)
		{
			break;
		}
    }
    if (ptrGameState == IntPtr.Zero)
    {
        Thread.Sleep(5000);
		print("OH NO: Game State couldnt be located");
        throw new Exception();
		
    }
	if (ptrNetworkStreamIsPaused == IntPtr.Zero)
	{
        Thread.Sleep(5000);
		print("OH NO: Networking streamIsPaused couldnt be located");
        throw new Exception();
		
    }
	vars.watchers = new MemoryWatcherList();
	vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer(ptrGameState, 0x0, 0x30)) {Name = "level"});
	vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer(ptrGameState, 0x0, 0x40)) {Name = "gameMode"});
	vars.watchers.Add(new MemoryWatcher<byte>(new DeepPointer(ptrNetworkStreamIsPaused, 0x0)) {Name = "streamIsPaused"});
}

update
{
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
	if(settings["onlineLoadRemoval"] && vars.watchers["streamIsPaused"].Current == 1)
	{
		return true;
	}
	else
	{
		return false;
	}
}

split
{
	if (vars.watchers["level"].Current == vars.watchers["level"].Old + 1)
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
}
