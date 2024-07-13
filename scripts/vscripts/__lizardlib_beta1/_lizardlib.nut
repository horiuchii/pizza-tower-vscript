//=========================================================================
//Copyright LizardOfOz.
//=========================================================================

::main_script <- this;
::main_script_entity <- self;
::root_table <- getroottable();
::tf_player_manager <- Entities.FindByClassname(null, "tf_player_manager");
::tf_gamerules <- Entities.FindByClassname(null, "tf_gamerules");
tf_gamerules.ValidateScriptScope();

ClearGameEventCallbacks();

IncludeScript("__lizardlib_beta1/constants.nut");
IncludeScript("__lizardlib_beta1/util.nut");
IncludeScript("__lizardlib_beta1/listeners.nut");
IncludeScript("__lizardlib_beta1/timers.nut");
IncludeScript("__lizardlib_beta1/api_config.nut");
IncludeScript("__lizardlib_beta1/players.nut");