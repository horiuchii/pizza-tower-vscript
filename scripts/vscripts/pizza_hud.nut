::GetHUDProp <- function(player, name)
{
	if(!(name in player.GetVar("hud_props")))
	{
		printl("ERROR: Tried to get a hud prop that doesn't exist! " + name);
		return null;
	}

	return player.GetVar("hud_props")[name];
}

::AddHUDProp <- function(player, name, entity, default_pos)
{
	player.GetVar("hud_props")[name] <- {
		ent = entity,
		pos = default_pos
	};
}

::SetDrawHUD <- function(player, enabled)
{
	if(enabled)
		foreach(hud in player.GetVar("hud_props"))
			hud.ent.EnableDraw();
	else
		foreach(hud in player.GetVar("hud_props"))
			hud.ent.DisableDraw();
}

::KillHUD <- function(player)
{
	local hud_props = [];

	foreach(hud in player.GetVar("hud_props"))
	{
		hud_props.append(hud.ent);
	}

	for(local i = 0; i < hud_props.len(); i++)
	{
		hud_props[i].Destroy();
	}

	player.SetVar("hud_props", {});
}

::SetHUDPosition <- function(player, hud_name, pos, lerp = false, lerp_speed = 6)
{
	local hud = GetHUDProp(player, hud_name);

	if(!hud)
	{
		printl("ERROR: Tried to set a null hud_prop position! " + hud_name);
		return;
	}

	if(lerp)
	{
		local current_pos = hud.pos;
		local interp_pos_x = interp_to(current_pos.x, pos.x, lerp_speed);
		local interp_pos_y = interp_to(current_pos.y, pos.y, lerp_speed);
		hud.ent.SetOrigin(Vector(0, interp_pos_x, interp_pos_y));
		hud.pos <- Vector2D(interp_pos_x, interp_pos_y);
	}
	else
	{
		hud.ent.SetOrigin(Vector(0, pos.x, pos.y));
		hud.pos <- Vector2D(pos.x, pos.y);
	}
}

::ParentEntity <- function(child, parent)
{
	if((!child || !child.IsValid()) || (!parent || !parent.IsValid()))
	{
		printl("ERROR: ParentEntity was called with a invalid entity, aborting! Child: " + child + " Parent: " + parent);
		return;
	}

	EntFireByHandle(child, "SetParent", "!activator", -1, parent, null);
}

::CreateHUDProp <- function(player, model, name)
{
	local hud_prop = CreateInstancedProp(player, model, player.GetOrigin(), player.GetAbsAngles())
	SetPropInt(hud_prop, "m_nRenderMode", kRenderTransColor);
	AddHUDProp(player, name, hud_prop, Vector2D(0, 0))
	return hud_prop;
}

::HudElements <- {
	["combo"] = {model = "models/pizza_tower/hud/combo.mdl", default_pos = Vector2D(-9.8, 10)},
	["combo_fill"] = {model = "models/pizza_tower/hud/combo_fill.mdl", default_pos = Vector2D(-9.8, 10)},
	["combo_tier"] = {model = "models/pizza_tower/hud/combo_tier.mdl", default_pos = Vector2D(-9.75, 1)},

	["tv"] = {model = "models/pizza_tower/hud/tv.mdl", default_pos = Vector2D(-9.75, 5)},

	["pizzatime"] = {model = "models/pizza_tower/hud/pizzatime.mdl", default_pos = Vector2D(0, -11)},
	["escape_bar"] = {model = "models/pizza_tower/hud/escape_bar.mdl", default_pos = Vector2D(0, -11)},
	["escape_fill"] = {model = "models/pizza_tower/hud/escape_fill.mdl", default_pos = Vector2D(0, -11)},

	["score"] = {model = "models/pizza_tower/hud/score_even.mdl", default_pos = Vector2D(9.75, 5)},

	["rank"] = {model = "models/pizza_tower/hud/rank.mdl", default_pos = Vector2D(5.0, 5.5)}
}

::CreatePlayerHUD <- function(player)
{
	AddThinkToEnt(player, null);
    local hud_prop_proxy = CreateByClassname("tf_wearable");
	hud_prop_proxy.Teleport(true, player.GetOrigin(), true, player.GetAbsAngles(), false, Vector(0,0,0));
	hud_prop_proxy.DispatchSpawn();
	SetPropEntity(hud_prop_proxy, "m_hOwnerEntity", player);

	foreach (name, hud_data in HudElements)
	{
		ParentEntity(CreateHUDProp(player, hud_data.model, name), hud_prop_proxy);
	}

	for (local viewmodel = player.FirstMoveChild(); viewmodel != null; viewmodel = viewmodel.NextMovePeer())
	{
		if (viewmodel.GetClassname() != "tf_viewmodel")
			continue;

		ParentEntity(hud_prop_proxy, viewmodel);
		break;
	}

	RunWithDelay(-1, function(){
		AddThinkToEnt(player, "PlayerThink");
		foreach (name, hud_data in HudElements)
		{
			SetHUDPosition(player, name, hud_data.default_pos);
		}
		hud_prop_proxy.KeyValueFromString("classname", "_killme");
	})
}