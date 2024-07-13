::AddCombo <- function(client, count = 1)
{
	local fresh_combo = client.GetVar("combo_count") ? false : true;
	local combo = client.AddVar("combo_count", count);

	AddComboTime(client, fresh_combo ? 1 : (1.0/7.0));

	client.SetVar("combo_shakeframes", 4);
	UpdateComboDigits(client);
	UpdateRankVisuals(client);

	//update our combo title if we reach a new one
	if(combo % 10 == 0)
	{
		UpdateComboTier(client, false);
		PlaySoundForPlayer("PizzaTower.ComboUp", client);
	}
}

::AddComboTime <- function(client, amount)
{
	local combo_time = client.GetVar("combo_time");
	client.SetVar("combo_time", clamp(combo_time + amount, 0, 1));
	return client.GetVar("combo_time");
}

::SubtractComboTime <- function(client, amount)
{
	local combo_time = client.GetVar("combo_time");
	client.SetVar("combo_time", clamp(combo_time - amount, 0, 1));
	return client.GetVar("combo_time");
}

::EndCombo <- function(client, play_sound)
{
	AddScore(client, CalculateCombo(client.GetVar("combo_count")));
	UpdateComboTier(client, true);
	client.SetVar("combo_time", 0);
	client.SetVar("combo_count", 0);
	UpdateRankVisuals(client);
	UpdateScoreNumbers(client);

	if(play_sound)
		PlaySoundForPlayer("PizzaTower.ComboEnd", client);
}

const TIER_COUNT = 15;
::UpdateComboTier <- function(client, end_combo)
{
	local combo = client.GetVar("combo_count");
	local combo_tier = (combo / 10);

	local hud_prop = GetHUDProp(client, "combo_tier").ent;

	hud_prop.SetSkin(combo_tier % (TIER_COUNT + 1));

	//display "DOWNRIGHT" if we loop our tiers
	hud_prop.SetBodygroup(hud_prop.FindBodygroupByName("downright_mod"), (combo_tier > TIER_COUNT).tointeger());

	//display "THAT STREAK WAS" if we have no more combo
	hud_prop.SetBodygroup(hud_prop.FindBodygroupByName("lost_combo"), end_combo.tointeger());

	client.SetVar("combo_lastupdatetier", Time());
}

::UpdateComboDigits <- function(client)
{
	local combo_str = client.GetVar("combo_count").tostring();
	if(client.GetVar("combo_count") > 999)
		combo_str = "999";

	local combo_len = combo_str.len();
	local combo_prop = GetHUDProp(client, "combo").ent;

	// Set Visibility and Numbers
	combo_str = (combo_len == 1 ? "ee" + combo_str : combo_len == 2 ? "e" + combo_str : combo_str);
	for(local i = 0; i < 3; i++)
	{
		local j = remap(2, 0, 0, 2, i)
		combo_prop.SetBodygroup(i + 1, combo_str[j] == 'e' ? 10 : combo_str[j].tochar().tointeger())
	}
}

::CalculateCombo <- function(combo)
{
	return floor((combo * combo * 0.25) + (10 * combo));
}

::ComboThink <- function()
{
	local hud_prop = GetHUDProp(self, "combo_tier").ent;

	//should we start fading out our tier
	if(self.GetVar("combo_lastupdatetier") + 2.0 < Time())
		SetEntityColor(hud_prop, [255,255,255,interp_to(GetEntityColor(hud_prop).a, self.GetVar("combo_count") >= 10 ? 50 : 0, 150).tointeger()])
	else
		SetEntityColor(hud_prop, [255,255,255,254])

	if(!self.GetVar("combo_frozen") && SubtractComboTime(self, FrameTime() / 8) <= 0 && self.GetVar("combo_count") > 0)
	{
		EndCombo(self, true);
	}

	local combo_x_offset = -3.65;
	local combo_y_offset = 6.35;

	if(self.GetVar("combo_count") > 0)
	{
		combo_x_offset += (pulse(5, 0.15) * 0.15);

		if(self.GetVar("combo_time") < 0.25)
			combo_y_offset += (pulse(10, 1) * 0.15);
		else if(self.GetVar("combo_time") < 0.5)
			combo_y_offset += (pulse(15, 1) * 0.075);
	}
	else //no combo
	{
		combo_y_offset = 13;
	}

	local speed = 10;

	SetHUDPosition(self, "combo", Vector2D(combo_x_offset, combo_y_offset), true, speed);
	SetHUDPosition(self, "combo_fill", Vector2D(combo_x_offset + remap(1, 0, 0, 3.5, self.GetVar("combo_time")) - 2.0, combo_y_offset - 0.55), true, speed);

	if(self.GetVar("combo_shakeframes") > 0)
	{
		self.SubtractVar("combo_shakeframes", 1);
		GetHUDProp(self, "combo").ent.SetSkin(1);
	}
	else if(GetHUDProp(self, "combo").ent.GetSkin() == 1)
		GetHUDProp(self, "combo").ent.SetSkin(0);
}