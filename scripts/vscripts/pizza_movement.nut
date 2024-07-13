::MoveThink <- function()
{
    WallKickThink()
}

::WasWallTraceHitLastFrame <- array(MAX_PLAYERS, false)

::WallKickThink <- function()
{
    if(self.IsAirborne() && self.GetMoveType() == MOVETYPE_WALK && self.GetButtons() & IN_FORWARD)
    {
        local origin = self.GetOrigin();

        local eyeang = self.EyeAngles()
        eyeang.x = 0

        local forward = eyeang.Forward()
        forward.z = 0;

        walltrace <-
        {
            start = origin
            end = origin + (forward * 48)
            mask = (CONTENTS_SOLID|CONTENTS_MOVEABLE|CONTENTS_PLAYERCLIP|CONTENTS_WINDOW|CONTENTS_MONSTER|CONTENTS_GRATE)
            ignore = self
        }

        if(false) DebugDrawLine(walltrace.start, walltrace.end, 0, 255, 0, true, 5);
        if(!TraceLineEx(walltrace) || !walltrace.hit)
            return;

        if(walltrace.surface_name == "TOOLS/TOOLSSKYBOX")
            return;

        local player_velocity = GetPropVector(self, "m_vecAbsVelocity");
        player_velocity.z = 450
        SetPropVector(self, "m_vecAbsVelocity", Vector(0,0,450));

        local eyepos = self.EyePosition()

        floorsnaptrace <-
        {
            start = (eyepos + Vector(0,0,50))
            end = (eyepos - Vector(0,0,200)) + (forward * 128)
            mask = (CONTENTS_SOLID|CONTENTS_MOVEABLE|CONTENTS_PLAYERCLIP|CONTENTS_WINDOW|CONTENTS_MONSTER|CONTENTS_GRATE)
            ignore = self
        }

        if(true) DebugDrawLine(floorsnaptrace.start, floorsnaptrace.end, 0, 255, 0, true, 5);
        if(!TraceLineEx(floorsnaptrace) || !floorsnaptrace.hit)
            return;

        if(floorsnaptrace.plane_normal.z != 1)
            return;

        floorsnaptrace.pos.z += 1;

        tracehull <-
        {
            start = floorsnaptrace.pos
            end = floorsnaptrace.pos
            hullmin = self.GetBoundingMins()
            hullmax = self.GetBoundingMaxs()
            mask = 16395
        }

        if(false) DebugDrawBox(tracehull.start, tracehull.hullmin, tracehull.hullmax, 255, 0, 0, 100, 5)

        if(TraceHull(tracehull) && !tracehull.hit)

        if(floorsnaptrace.pos.z - 10 <= origin.z)
        {
            self.SetAbsOrigin(floorsnaptrace.pos)

            player_velocity.z = 0

            SetPropVector(self, "m_vecAbsVelocity", player_velocity);
        }

    }
}