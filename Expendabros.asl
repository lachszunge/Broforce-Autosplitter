state("Expendabros")
{
	//Autosplitter by lachszunge
	
	bool loading : "Expendabros.exe", 0x00A1AD00, 0xB0; // found by DerKO
}
startup
{
	String signatureLevel = "55 8B EC 83 EC 08 8B 05 ???????? 3D FFFFFFFF";
	String signaturePlayer = "55 8B EC 57 56 8B 05 ???????? 83 EC 08 6A 00 50 E8 42C0FFFF";
	vars.scanTargetLevel = new SigScanTarget(8, signatureLevel);
	vars.scanTargetPlayer = new SigScanTarget(7, signaturePlayer);
}
init
{
	//Code copied from CryZe's "A Hat in Time" autosplitter
    var ptr = IntPtr.Zero;

    foreach (var page in game.MemoryPages(true)) {
		var scanner = new SignatureScanner(game, page.BaseAddress, (int)page.RegionSize);

		if (ptr == IntPtr.Zero) {
			ptr = scanner.Scan(vars.scanTargetLevel);
		} else {
			break;
		}
    }
    if (ptr == IntPtr.Zero) {
        Thread.Sleep(1000);
		print("OH NOOO");
        throw new Exception();
		
    }
	vars.level = new MemoryWatcher<int>(new DeepPointer(ptr, 0x0));
	
	ptr = IntPtr.Zero;

    foreach (var page in game.MemoryPages(true)) {
		var scanner = new SignatureScanner(game, page.BaseAddress, (int)page.RegionSize);

		if (ptr == IntPtr.Zero) {
			ptr = scanner.Scan(vars.scanTargetPlayer);
		} else {
			break;
		}
    }
    if (ptr == IntPtr.Zero) {
        Thread.Sleep(1000);
		print("OH NOOO");
        throw new Exception();
		
    }
	vars.currentBro = new MemoryWatcher<int>(new DeepPointer(ptr, -44, 0x10, 0x4C, 0x21C));
	vars.isOnHeli = new MemoryWatcher<int>(new DeepPointer(ptr, -44, 0x10, 0x4C, 0x210));
}

update
{
	vars.level.Update(game);
	vars.currentBro.Update(game);
	vars.isOnHeli.Update(game);
}
start
{
	if(vars.level.Current == 0 && vars.currentBro.Current == 27)
	{
		return true;
	}
}



split
{
	if (vars.level.Current == vars.level.Old + 1){
		return true;
	}
	if (vars.level.Current == 11 && vars.isOnHeli.Current == 1 && vars.isOnHeli.Old == 0){
		return true;
	}
}
isLoading
{
    return current.loading;
}
