Convars.SetValue("tf_dropped_weapon_lifetime", 0)

function Include(file)
{
	IncludeScript(file + ".nut", this);
}

Include("__lizardlib_beta1/_lizardlib");

Include("pizza_util");
Include("pizza_events");
Include("pizza_hud");
Include("pizza_tvhud");
Include("pizza_score");
Include("pizza_combo");
Include("pizza_stages");

Include("entities/pizza_entities");

Include("pizza_escape");

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

::PlayerThink <- function()
{
	ComboThink();
	CollectableSpawnThink();
	EscapeThink();
	TVHudThink();

	return -1;
}

function Tick()
{
    FireListeners("tick_always", 0.1);
    return 0.1;
}

::GlobalPlayers <- [];

//recache players
AddTimer(0.1, function(){
	GlobalPlayers <- GetAllClients();
})