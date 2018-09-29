//this Autosplitter was made by
//Argusdusty, Gammler33 and lachszunge
state("Broforce_beta")
{
	// The level of the current campaign (used for splitting)
	byte level : "mono.dll", 0x1F8BE4, 0xA4, 0x6D4, 0x14C, 0x90, 0x18; // If you need to scan for this: offset always ends with 0x18
	
	// The timer behind the 3...2...1...Go! countdown. See start for more details (used for Autostarting)
	float start_timer : "Broforce_beta.exe", 0xFE4CB0, 0x30, 0xA8, 0x34;
	
	// Indicates whether or not we're in the main menu. 1 when we are, 0 when we aren't (used for Autoreset)
	byte menu : "Broforce_beta.exe", 0xFE5210, 0x120, 0xC;
	
	//Game Speed (1 = 100%) (used in last split)
	float game_speed : "Broforce_beta.exe", 0x102055C, 0xBC;
	
	//Total Time passed since starting the game. (not needed)
	//float total_timer : "gameoverlayrenderer.dll", 0x123B60;
	
	//Satan Health (used in last Split)
	byte satan_health : "Broforce_beta.exe", 0x10205A8, 0x220, 0x6E4, 0x18, 0x98, 0x1E8;
	
	//Is the Game currently loading (0 = no; 1 - 255 = yes)
	byte is_loading : "Broforce_beta.exe", 0x101FDB2;
}

startup
{

}

init
{

}

start
{
	// There are multiple start timers roughly in multiples of 400 (0, 400, ..., 1600)
	// They are imprecise. Off by at most a few dozen from "correct" values
	// Picked the 1200 timer, which hits 0 right as "Go" starts
	// Putting the threshold under that for more accurate starts
	// Extra validation is there so it doesn't randomly trigger (the timers are weird)
	if (current.level == 0 &&
	    (current.start_timer < old.start_timer) && 
	    (current.start_timer < 0) && 
	    (current.start_timer > -400))
	{
		vars.campaign = 0;
		return true;
	}
}

isLoading
{
	//is_loading is set to 4 after the satan introduction cut scene for whatever reason. If load removal does not work remove the second condition
	if (current.is_loading == 0 || current.is_loading == 4) {
		return false;
	}else{
		return true;
	}
}

reset
{
	if (current.menu == 1 && old.menu == 0) {
		return true;
	}
}

split
{
	// Detect level change
	if (current.level == old.level+1){
		return true;
	}
	// Detect the ending
	// Not Perfect since BroLee can slow the game_speed down to 0.1 Needs additional checking
	if (current.level == 63 && current.game_speed < 0.30 && current.satan_health < 200)
	{
		return true;
	}
}
