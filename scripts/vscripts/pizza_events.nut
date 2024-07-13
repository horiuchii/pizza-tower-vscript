OnGameEvent("player_death", function(params)
{
    local client = GetPlayerFromUserID(params.userid);
    ReturnToHub(client);
	EntFireByHandle(client, "RunScriptCode", "activator.ForceRespawn()", -1, client, client);
})

OnGameEvent("OnTakeDamage", function(params)
{
    params.damage = 0;
})

::HasPlayerBeenSetup <- array(MAX_PLAYERS, false)

::InitPlayerVars <- function(client)
{
    //combo
    client.SetVar("combo_count", 0);
    client.SetVar("combo_time", 0);
    client.SetVar("combo_shakeframes", 0);
    client.SetVar("combo_lastupdatetier", 0);
    client.SetVar("combo_frozen", false);

    //hud
    client.SetVar("hud_props", {});
    client.SetVar("tv_staticframes", 0);
    client.SetVar("tv_holdframes", 0);

    //stages
    client.SetVar("stage", null);
    client.SetVar("escape", false);
    client.SetVar("secret", 0);
    client.SetVar("secret_active", false);

    //score
    client.SetVar("score", 0);
}

OnGameEvent("player_connect", function(params)
{
    HasPlayerBeenSetup[params.index + 1] = false;
})

OnGameEvent("teamplay_round_start", function(params)
{
    for (local i = 1; i <= MAX_PLAYERS ; i++)
    {
        local player = PlayerInstanceFromIndex(i)
        if (player == null) continue;

        HasPlayerBeenSetup[i] = false;
    }
})

OnGameEvent("player_spawn", function(params)
{
	local client = GetPlayerFromUserID(params.userid);

	if(!client || !client.IsPlayer() || client.GetTeam() == TEAM_UNASSIGNED || client.GetTeam() == TEAM_SPECTATOR || !client.IsAlive())
		return;

    local player_index = client.GetEntityIndex();

    SetPropInt(client, "m_iFov", 90);
    client.SwitchTeam(TF_TEAM_RED);
    client.ValidateScriptScope();
    client.AddHudHideFlags(HIDEHUD_HEALTH);

    if(!HasPlayerBeenSetup[player_index])
    {
        InitPlayerVars(client);
        HasPlayerBeenSetup[player_index] = true;
    }

    KillHUD(client);
    CreatePlayerHUD(client);
})