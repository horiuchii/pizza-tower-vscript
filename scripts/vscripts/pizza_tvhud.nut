enum TVSKINS {
	IDLE
    SECRET
	PANIC
	STREAK_STRESS
	BIG_COLLECT
	SPEED
}

::TVHudThink <- function()
{
    //if we are displaying static for transitions
    if(self.GetVar("tv_staticframes") > 0)
    {
        self.SubtractVar("tv_staticframes", 1);
        GetHUDProp(self, "tv").ent.SetBodygroup(1, 1);
    }
    else if(GetHUDProp(self, "tv").ent.GetBodygroup(1) == 1)
        GetHUDProp(self, "tv").ent.SetBodygroup(1, 0);

    //if we're holding the frame
    if(self.GetVar("tv_holdframes") > 0)
    {
        self.SubtractVar("tv_holdframes", 1);
        return;
    }

    //determine our idle (no panic, panic, stress, secret hoppin, etc...)
    local skin = TVSKINS.IDLE;

    if(self.InCond(TF_COND_SPEED_BOOST))
        skin = TVSKINS.SPEED;
    //else if(self.GetVar("secret_active"))
    //    skin = TVSKINS.SECRET;
    else if(self.GetVar("escape"))
        skin = TVSKINS.PANIC;
    //else if(self.GetVar("combo_count") > 50)
     //   skin = TVSKINS.STREAK_STRESS;

    if(skin != GetHUDProp(self, "tv").ent.GetBodygroup(2))
    {
        GetHUDProp(self, "tv").ent.SetBodygroup(2, skin);
        self.SetVar("tv_staticframes", 24);
    }
}

::SetTVSkin <- function(client, skin, length)
{
    client.SetVar("tv_staticframes", 24);
    client.SetVar("tv_holdframes", 24 + length);
    GetHUDProp(self, "tv").ent.SetBodygroup(2, skin);
}