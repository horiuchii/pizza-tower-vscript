::CTFPlayer.SetVar <- function(name, value)
{
    local playerVars = this.GetScriptScope();
    playerVars[name] <- value;
    return value;
}
::CTFBot.SetVar <- CTFPlayer.SetVar;

::CTFPlayer.GetVar <- function(name)
{
    local playerVars = this.GetScriptScope();
    return playerVars[name];
}
::CTFBot.GetVar <- CTFPlayer.GetVar;

::CTFPlayer.AddVar <- function(name, addValue)
{
    local playerVars = this.GetScriptScope();
    local value = playerVars[name];
    return playerVars[name] <- value + addValue;
}
::CTFBot.AddVar <- CTFPlayer.AddVar;

::CTFPlayer.SubtractVar <- function(name, subtractValue)
{
    local playerVars = this.GetScriptScope();
    local value = playerVars[name];
    return playerVars[name] <- value - subtractValue;
}
::CTFBot.SubtractVar <- CTFPlayer.SubtractVar;

::CreateInstancedProp <- function(client, model, pos, rot = QAngle(0,0,0), scale = 1.0)
{
    PrecacheModel(model);
    local prop = CreateByClassname("obj_teleporter"); // not using SpawnEntityFromTable as that creates spawning noises
    prop.Teleport(true, pos, true, rot, false, Vector(0,0,0));
    prop.DispatchSpawn();

    prop.AddEFlags(EFL_NO_THINK_FUNCTION); // prevents the entity from disappearing
    prop.SetSolid(SOLID_NONE);
    prop.SetMoveType(MOVETYPE_NOCLIP, MOVECOLLIDE_DEFAULT);
    prop.SetCollisionGroup(COLLISION_GROUP_NONE);
    SetPropBool(prop, "m_bPlacing", true);
    SetPropInt(prop, "m_fObjectFlags", 2); // sets "attachment" flag, prevents entity being snapped to player feet
    SetPropEntity(prop, "m_hBuilder", client);
    SetPropEntity(prop, "m_hOwnerEntity", client);

    prop.SetModel(model);
    prop.SetModelScale(scale, 0.0);
    prop.KeyValueFromInt("disableshadows", 1);

    return prop;
}

::PlaySoundForPlayer <- function(sound, client)
{
    client.PrecacheSoundScript(sound);
    EmitSoundOnClient(sound, client);
}

::ReverseString <- function(inputString)
{
    local reversedString = "";

    for(local i = inputString.len() - 1; i >= 0; i--)
    	reversedString += inputString[i];

    return reversedString;
}

::interp_to <- function(current, target, speed)
{
	local diff = target - current;

	// If distance is too small, just set the desired location
	if((diff * diff) < 0)
		return target;

	local step = speed * FrameTime();
	return current + clamp(diff, -step, step);
}

::pulse <- function(speed, freq)
{
	return 0.5*(1+sin(speed*PI*freq*Time()))
}

::remap <- function(imin, imax, omin, omax, v)
{
	return omin + (v - imin) * (omax - omin) / (imax - imin);
}

::CTFPlayer.IsAirborne <- function()
{
	return !!!(GetPropInt(this, "m_fFlags") & FL_ONGROUND);
}

::WasButtonPressedLastFrame <- function(player_index, button_query, current_buttons)
{
    return !(PreviousButtons[player_index] & button_query) && current_buttons & button_query;
}

::CTFPlayer.GetButtons <- function()
{
	return GetPropInt(this, "m_nButtons");
}