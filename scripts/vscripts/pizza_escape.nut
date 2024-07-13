::EscapeMotivator <- array(MAX_PLAYERS, null)

AddListener("tick_always", 0, function(timeDelta)
{
    foreach(player in GlobalPlayers)
    {
        if(player.IsAlive() && player.GetVar("escape") && !player.GetVar("secret_active"))
            player.SubtractVar("escape_time", timeDelta);
    }
})

::EscapeThink <- function()
{
    if(self.GetVar("secret_active"))
    {
        SetHUDPosition(self, "escape_bar", Vector2D(0, -9), true, 1);
        SetHUDPosition(self, "escape_fill", Vector2D(4.45, -9.025), true, 1);
        return;
    }

    if(self.GetVar("escape"))
    {
        local tilt_multiplier = remap(0, Stages[self.GetVar("stage")].EscapeTime, 15, 0, self.GetVar("escape_time"));
        SetPropVector(self, "m_Local.m_vecPunchAngleVel", Vector(RandomFloat(-5,5), RandomFloat(-5,5), GetPropVector(self, "m_Local.m_vecPunchAngleVel").z + (pulse(1, 0.15) * tilt_multiplier) - tilt_multiplier*0.5))
        local punch_ang = GetPropVector(self, "m_Local.m_vecPunchAngle");
        SetPropVector(self, "m_Local.m_vecPunchAngle", Vector(punch_ang.x/1.01,punch_ang.y/1.01,punch_ang.z))

        //do we have time left to escape?
        if(self.GetVar("escape_time") > 0)
        {
            ClientPrint(null, HUD_PRINTCENTER, self.GetVar("escape_time").tostring());
            SetHUDPosition(self, "pizzatime", Vector2D(0, 11), true, 8);
            SetHUDPosition(self, "escape_bar", Vector2D(0, -6), true, 1);
            local fill_xpos = remap(0, Stages[self.GetVar("stage")].EscapeTime, -4.45, 4.45, self.GetVar("escape_time"));
            SetHUDPosition(self, "escape_fill", Vector2D(fill_xpos, -6.025), true, 1);
        }
        else
        {
            SetHUDPosition(self, "escape_bar", Vector2D(0, -11), true, 1);
            SetHUDPosition(self, "escape_fill", Vector2D(4.45, -11.025), true, 1);

            if(!EscapeMotivator[self.entindex()])
            {
                EscapeMotivator[self.entindex()] = CreateInstancedProp(self, "models/props_halloween/halloween_demoeye.mdl", self.GetOrigin());
            }
        }
    }
}