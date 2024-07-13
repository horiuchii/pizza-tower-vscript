//=========================================================================
//Copyright LizardOfOz.
//=========================================================================

::CreateAoE <- function(origin, radius, applyFunc, applyBuildingFunc = null)
{
    foreach(target in GetAlivePlayers())
    {
        local deltaVector = target.GetOrigin() - origin;
        local distance = deltaVector.Length();
        if (distance <= radius)
            applyFunc(target, deltaVector, distance);
    }

    for (local target = null; target = FindByClassname(target, "obj_*");)
    {
        local deltaVector = target.GetOrigin() - origin;
        local distance = deltaVector.Length();
        if (distance <= radius)
        {
            if (applyBuildingFunc)
                applyBuildingFunc(target, deltaVector, distance);
            else
                applyFunc(target, deltaVector, distance);
        }
    }
}

::CreateAoEAABB <- function(origin, min, max, applyFunc, applyBuildingFunc = null)
{
    local min = origin + min;
    local max = origin + max;
    foreach(target in GetAlivePlayers())
    {
        local targetOrigin = target.GetOrigin();
        if (targetOrigin.x >= min.x
            && targetOrigin.y >= min.y
            && targetOrigin.z >= min.z
            && targetOrigin.x <= max.x
            && targetOrigin.y <= max.y
            && targetOrigin.z <= max.z)
            {
                local deltaVector = targetOrigin - origin;
                applyFunc(target, deltaVector, deltaVector.Length());
            }
    }

    for (local target = null; target = FindByClassname(target, "obj_*");)
    {
        local targetOrigin = target.GetOrigin();
        if (targetOrigin.x >= min.x
            && targetOrigin.y >= min.y
            && targetOrigin.z >= min.z
            && targetOrigin.x <= max.x
            && targetOrigin.y <= max.y
            && targetOrigin.z <= max.z)
            {
                local deltaVector = targetOrigin - origin;
                if (applyBuildingFunc)
                    applyBuildingFunc(target, deltaVector, distance);
                else
                    applyFunc(target, deltaVector, distance);
            }
    }
}

::clampCeiling <- function(valueA, valueB)
{
    if (valueA < valueB)
        return valueA;
    return valueB;
}
::min <- clampCeiling;

::clampFloor <- function(valueA, valueB)
{
    if (valueA > valueB)
        return valueA;
    return valueB;
}
::max <- clampFloor;

::clamp <- function(value, min, max)
{
    if (value < min)
        return min;
    if (value > max)
        return max;
    return value;
}

::safeget <- function(table, field, defValue)
{
    return field in table ? table[field] : defValue;
}

::SetPersistentVar <- function(name, value)
{
    local persistentVars = tf_gamerules.GetScriptScope();
    persistentVars[name] <- value;
}

::GetPersistentVar <- function(name, defValue = null)
{
    local persistentVars = tf_gamerules.GetScriptScope();
    return name in persistentVars ? persistentVars[name] : defValue;
}

::SetEntityColor <- function(entity, rgba)
{
    local color = rgba[0] | (rgba[1] << 8) | (rgba[2] << 16) | (rgba[3] << 24);
    SetPropInt(entity, "m_clrRender", color);
}

::GetEntityColor <- function(entity)
{
    local color = NetProps.GetPropInt(entity, "m_clrRender");
    local clr = {}
    clr.r <- color & 0xFF;
    clr.g <- (color >> 8) & 0xFF;
    clr.b <- (color >> 16) & 0xFF;
    clr.a <- (color >> 24) & 0xFF;
    return clr;
}