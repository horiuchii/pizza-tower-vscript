class Stage
{
    constructor(_srankpoints, _time)
    {
        SRankRequirement = _srankpoints
        EscapeTime = _time
    }

    SRankRequirement = 0
    EscapeTime = 0
}

::Stages <- {
    ["Test"] = Stage(16000, 120)
}

::ActivateEscape <- function()
{
    local client = activator;

	if(client.GetVar("escape"))
		return;

    client.SetVar("escape_time", Stages[client.GetVar("stage")].EscapeTime);
	client.SetVar("escape", true);
	client.SwitchTeam(TF_TEAM_BLUE);
    AddCombo(client);
    AddComboTime(client, 1);
    ScreenFade(client, 255, 255, 255, 255, 0.5, 0.1, 1)
	PlaySoundForPlayer("PizzaTower.PizzaTime", client);
	SetHUDPosition(client, "pizzatime", Vector2D(0, -11));
    SetHUDPosition(client, "escape_bar", Vector2D(0, -11));
    SetHUDPosition(client, "escape_fill", Vector2D(4.45, -11.025));
}

::EnterStage <- function()
{
    local client = activator;

    local stagename = split(GetPropString(caller, "m_iName"), "_")[0];

    local stage_door = FindByName(null, stagename + "_stage*");

    if(!stage_door || !(stagename in Stages))
    {
        ClientPrint(null, HUD_PRINTTALK, "Tried to send a player to stage \"" + stagename + "\" but a start or it's entry is missing!")
        return;
    }

    local trigger_name = split(GetPropString(stage_door, "m_iName"), ",");

    local entry_point = stage_door.GetOrigin();
    entry_point.x += trigger_name[1].tointeger();
    entry_point.y += trigger_name[2].tointeger();
    entry_point.z -= 64;

    client.SetVar("stage", stagename);
    client.SetVar("score", 0);
    client.SetVar("secret", 0);
    client.SetVar("secret_active", false);
    EscapeMotivator[client.entindex()] = false;
    PlayerCollectedList[client] <- [];
    client.SetOrigin(entry_point);
    client.SetAbsVelocity(Vector(0,0,0));
}

::ReturnToHub <- function(client)
{
    if(!client.GetVar("stage"))
        return;

    local hub_door = FindByName(null, client.GetVar("stage") + "_hub*");
    local trigger_name = split(GetPropString(hub_door, "m_iName"), ",");

    local hub_exit_point = hub_door.GetOrigin();
    hub_exit_point.x += trigger_name[1].tointeger();
    hub_exit_point.y += trigger_name[2].tointeger();
    hub_exit_point.z -= 64;

    client.SetOrigin(hub_exit_point);
}

::ExitStage <- function()
{
    local client = activator;
    local client_index = client.entindex();

    local stagename = split(GetPropString(caller, "m_iName"), "_")[0];

    //does this door belong to our stage and are we escaping from this shithole?
    if(stagename != client.GetVar("stage") || !client.GetVar("escape") || client.GetTeam() != TF_TEAM_BLUE)
        return;

    local hub_door = FindByName(null, stagename + "_hub*");
    local trigger_name = split(GetPropString(hub_door, "m_iName"), ",");

    local hub_exit_point = hub_door.GetOrigin();
    hub_exit_point.x += trigger_name[1].tointeger();
    hub_exit_point.y += trigger_name[2].tointeger();
    hub_exit_point.z -= 64;

    EndCombo(client, false);
    client.SetVar("stage", null);
    client.SwitchTeam(TF_TEAM_RED);
    client.SetVar("escape", false);
    EscapeMotivator[client_index] = false;
    client.SetOrigin(hub_exit_point);
    client.SetAbsVelocity(Vector(0,0,0));
    PlayerCollectedList[client] <- [];

    if(EscapeMotivator[client_index])
        EscapeMotivator[client_index].Destroy();

    SetHUDPosition(activator, "pizzatime", Vector2D(0, -11));
    SetHUDPosition(activator, "escape_bar", Vector2D(0, -11));
    SetHUDPosition(activator, "escape_fill", Vector2D(4.45, -11.025));
}