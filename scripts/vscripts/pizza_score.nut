::AddScore <- function(client, amount)
{
    client.AddVar("score", amount);

	UpdateScoreNumbers(client);
    UpdateRankVisuals(client);
}

::SubtractScore <- function(client, amount)
{
    local score = client.GetVar("score") - amount;
    score = clampFloor(score, 0);
    client.SetVar("score", score);

	UpdateScoreNumbers(client);
    UpdateRankVisuals(client);
}

::SetScore <- function(client, amount)
{
    client.SetVar("score", amount);

	UpdateScoreNumbers(client);
    UpdateRankVisuals(client);
}

PrecacheModel("models/pizza_tower/hud/score_even.mdl");
PrecacheModel("models/pizza_tower/hud/score_odd.mdl");
::UpdateScoreNumbers <- function(client)
{
	local score_str = (client.GetVar("score") + CalculateCombo(client.GetVar("combo_count"))).tostring();
    if(client.GetVar("score") > 99999)
        score_str = "99999";

	local score_len = score_str.len();

	// Set Visibility
	local score_prop = GetHUDProp(client, "score").ent;
	if(score_len == 1)
	{
		score_prop.SetModel("models/pizza_tower/hud/score_odd.mdl");
		score_prop.SetBodygroup(1, 10);
		score_prop.SetBodygroup(2, 10);
		score_prop.SetBodygroup(3, score_str.tointeger());
		score_prop.SetBodygroup(4, 10);
		score_prop.SetBodygroup(5, 10);
	}
	if(score_len == 2)
	{
		score_prop.SetModel("models/pizza_tower/hud/score_even.mdl");
		score_prop.SetBodygroup(1, 10);
		score_prop.SetBodygroup(2, score_str[0].tochar().tointeger());
		score_prop.SetBodygroup(3, score_str[1].tochar().tointeger());
		score_prop.SetBodygroup(4, 10);
	}
	if(score_len == 3)
	{
		score_prop.SetModel("models/pizza_tower/hud/score_odd.mdl");
		score_prop.SetBodygroup(1, 10);
		score_prop.SetBodygroup(2, score_str[0].tochar().tointeger());
		score_prop.SetBodygroup(3, score_str[1].tochar().tointeger());
		score_prop.SetBodygroup(4, score_str[2].tochar().tointeger());
		score_prop.SetBodygroup(5, 10);
	}
	if(score_len == 4)
	{
		score_prop.SetModel("models/pizza_tower/hud/score_even.mdl");
		score_prop.SetBodygroup(1, score_str[0].tochar().tointeger());
		score_prop.SetBodygroup(2, score_str[1].tochar().tointeger());
		score_prop.SetBodygroup(3, score_str[2].tochar().tointeger());
		score_prop.SetBodygroup(4, score_str[3].tochar().tointeger());
	}
	if(score_len == 5)
	{
		score_prop.SetModel("models/pizza_tower/hud/score_odd.mdl");
		score_prop.SetBodygroup(1, score_str[0].tochar().tointeger());
		score_prop.SetBodygroup(2, score_str[1].tochar().tointeger());
		score_prop.SetBodygroup(3, score_str[2].tochar().tointeger());
		score_prop.SetBodygroup(4, score_str[3].tochar().tointeger());
		score_prop.SetBodygroup(5, score_str[4].tochar().tointeger());
	}
}

::UpdateRankVisuals <- function(client)
{
	local srank_score = Stages[client.GetVar("stage")].SRankRequirement;
	local score = client.GetVar("score");
	score += CalculateCombo(client.GetVar("combo_count"));

	local rank_skin = 4;
	local fill_percent = 0;

	local ranks = [srank_score/8,srank_score/4,srank_score/2,srank_score];
	foreach(i, rank_score in ranks)
	{
		if(score < rank_score)
		{
			local prev_score = 0;
			if(i - 1 >= 0)
				prev_score = ranks[i - 1]

			fill_percent = (remap(prev_score, rank_score, 0, 100, score) / 5).tointeger();
			rank_skin = i;
			break;
		}
	}

	local rank_prop = GetHUDProp(client, "rank").ent;
	rank_prop.SetSkin(rank_skin)
	rank_prop.SetBodygroup(rank_prop.FindBodygroupByName("fill_percent"), fill_percent);
}