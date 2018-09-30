state("Expendabros")
{
	// The level of the current campaign (used for splitting)
	byte level : "mono.dll", 0x1F4750, 0x4D8, 0x40C, 0x7C, 0x354, 0x28;
	
	// The timer behind the 3...2...1...Go! countdown.
	//float start_timer :
	
	// Indicates whether or not we're in the main menu. 1 when we are, 0 when we aren't (used for Autoreset)
	//byte menu :
	
	//Is the Game currently loading (0 = no; 1 - 255 = yes)
	//byte is_loading :
	
}

startup
{

}

init
{

}

start
{
}

isLoading
{
	//if (current.is_loading == 0) {
	//	return false;
	//}else{
	//	return true;
	//}
}

reset
{
	//if (current.menu == 1 && old.menu == 0) {
	//	return true;
	//}
}

split
{
	// Detect level change
	if (current.level == old.level+1){
		return true;
	}	
	//last level
	//if(current.level == 11 && current.endCondition == 1){
	//	return true;
	//}
}