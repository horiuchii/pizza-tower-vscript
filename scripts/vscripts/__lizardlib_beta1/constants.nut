//=========================================================================
//Copyright LizardOfOz.
//=========================================================================

//================================
//Exposed Functions.
//Intended for use by your code.
//================================

::AddPropFloat <- function(entity, property, value)
{
    SetPropFloat(entity, property, GetPropFloat(entity, property) + value);
}

::AddPropInt <- function(entity, property, value)
{
    SetPropInt(entity, property, GetPropInt(entity, property) + value);
}

//==============================
//Internal Functions.
//
//This code folds Constants and NetProps
//  so that you could write
//  GetPropInt(...) instead of NetProps.GetPropInt(...)
//  or
//  TF_CLASS_HEAVYWEAPONS instead of Constants.ETFClass.TF_CLASS_HEAVYWEAPONS
//==============================

function FoldStuff()
{
    if ("TF_TEAM_UNASSIGNED" in root_table)
        return;

    foreach (k, v in ::NetProps.getclass())
        if (k != "IsValid")
            root_table[k] <- ::NetProps[k].bindenv(::NetProps);

    foreach (k, v in ::Entities.getclass())
        if (k != "IsValid")
            root_table[k] <- ::Entities[k].bindenv(::Entities);

    foreach (_, cGroup in Constants)
        foreach (k, v in cGroup)
            root_table[k] <- v != null ? v : 0;

    ::TF_TEAM_UNASSIGNED <- TEAM_UNASSIGNED;
    ::TF_TEAM_SPECTATOR <- TEAM_SPECTATOR;
    ::TF_CLASS_HEAVY <- TF_CLASS_HEAVYWEAPONS;
    ::MAX_PLAYERS <- MaxClients().tointeger();
}
FoldStuff();