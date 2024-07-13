//=========================================================================
//Copyright LizardOfOz.
//=========================================================================

//A valid _client_ can be a spectator. A valid _player_ can not.
::GetAllClients <- function()
{
    local allPlayers = [];
    for (local i = 1; i <= MAX_PLAYERS; i++)
    {
        local player = PlayerInstanceFromIndex(i);
        if (player)
            allPlayers.push(player);
    }
    return allPlayers;
}

//A valid _client_ can be a spectator. A valid _player_ can not.
::GetAllPlayers <- function()
{
    local allPlayers = [];
    for (local i = 1; i <= MAX_PLAYERS; i++)
    {
        local player = PlayerInstanceFromIndex(i);
        if (player && player.GetTeam() > 1)
            allPlayers.push(player);
    }
    return allPlayers;
}

::GetAlivePlayers <- function()
{
    local alivePlayers = [];
    for (local i = 1; i <= MAX_PLAYERS; i++)
    {
        local player = PlayerInstanceFromIndex(i);
        if (player && GetPropInt(player, "m_lifeState") == 0)
            alivePlayers.push(player);
    }
    return alivePlayers;
}

::CTFPlayer.IsAlive <- function()
{
    return GetPropInt(this, "m_lifeState") == 0;
}
::CTFBot.IsAlive <- CTFPlayer.IsAlive;

::CTFPlayer.IsOnGround <- function()
{
    return this.GetFlags() & FL_ONGROUND;
}
::CTFBot.IsOnGround <- CTFPlayer.IsOnGround;

//A valid _client_ can be a spectator. A valid _player_ can not.
::IsValidClient <- function(player)
{
    try
    {
        return player && player.IsValid() && player.IsPlayer();
    }
    catch(e)
    {
        return false;
    }
}

//A valid _client_ can be a spectator. A valid _player_ can not.
::IsValidPlayer <- function(player)
{
    try
    {
        return player && player.IsValid() && player.IsPlayer() && player.GetTeam() > 1;
    }
    catch(e)
    {
        return false;
    }
}

::IsValidPlayerOrBuilding <- function(entity)
{
    try
    {
        return entity
            && entity.IsValid()
            && entity.GetTeam() > 1
            && (entity.IsPlayer() || startswith(entity.GetClassname(), "obj_"));
    }
    catch(e)
    {
        return false;
    }
}

::IsValidBuilding <- function(building)
{
    try
    {
        return building
            && building.IsValid()
            && startswith(building.GetClassname(), "obj_")
            && building.GetTeam() > 1;
    }
    catch(e)
    {
        return false;
    }
}

::CTFPlayer.GetUserID <- function()
{
    return GetPropIntArray(tf_player_manager, "m_iUserID", self.entindex());
}
::CTFBot.GetUserID <- CTFPlayer.GetUserID;

::GetPlayerFromParams <- function(params, key = "userid")
{
    if (!(key in params))
        return null;
    local player = GetPlayerFromUserID(params[key]);
    if (IsValidPlayer(player))
        return player;
    return null;
}

::CTFPlayer.Yeet <- function(team)
{
    SetPropEntity(this, "m_hGroundEntity", null);
    this.ApplyAbsVelocityImpulse(vector);
    this.RemoveFlag(FL_ONGROUND);
}
::CTFBot.Yeet <- CTFPlayer.Yeet;

//Normal ForceChangeTeam will not work if the player is dueling. This is a fix.
::CTFBot.SwitchTeam <- function(team)
{
    this.ForceChangeTeam(team, true);
    SetPropInt(this, "m_iTeamNum", team);
}

::CTFPlayer.SwitchTeam <- function(team)
{
    SetPropInt(this, "m_bIsCoaching", 1);
    this.ForceChangeTeam(team, true);
    SetPropInt(this, "m_bIsCoaching", 0);
}

//Might change in the future.
//I dislike that you need to manually type `player.entindex()` as a key,
// but using the ent index is the whole point - it gives us safety against nulls, invalid entities and out-of-bounds
::player_collection <- function(defValue = 0)
{
    local array = [];
    array.resize(MAX_PLAYERS + 1, defValue);
    OnGameEvent("player_connect", -999, function(player, params)
    {
        this[params.index+1] = defValue;
    }, array);
    return array;
}
::playerCollection <- player_collection;
::PlayerCollection <- player_collection;
::GetPlayerCollection <- player_collection;