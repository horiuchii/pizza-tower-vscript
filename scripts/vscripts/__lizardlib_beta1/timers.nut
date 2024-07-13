//=========================================================================
//Copyright LizardOfOz.
//=========================================================================

//================================
//Exposed Functions.
//Intended for use by your code.
//================================

//You can skip `order` parameter. Default value is 0.
::AddTimer <- function(interval, order, timerFunc = null, scope = null)
{
    if (typeof order == "function")
    {
        scope = timerFunc;
        timerFunc = order;
        order = 0;
    }

    if (scope == null)
        scope = this;
    else if ("IsValid" in scope && scope.IsValid())
    {
        scope.ValidateScriptScope();
        scope = scope.GetScriptScope();
    }
    scope = scope.weakref();

    if (interval < 0)
        interval = 0;
    local timerEntry = [order, timerFunc, scope, interval, Time()];

    local size = timers.len();
    local i = 0;
    for (; i < size; i++)
        if (timers[i][0] <= order)
            break;
    timers.insert(i, timerEntry);

    return timerEntry;
}
::OnTimer <- AddTimer;


//If you pass one more parameter than the executed function takes,
//  that parameter will be taken as the scope.
//Also, thanks Mr.Burguers and Ficool2 for help.
::RunWithDelay <- function(delay, func, ...)
{
    local scope = null;
    local params = vargv;
    if (func.getinfos().parameters.len() - 1 < vargv.len())
        scope = vargv.pop();

    if (scope == null)
        scope = this;
    else if (scope && "IsValid" in scope && scope.IsValid())
    {
        scope.ValidateScriptScope();
        scope = scope.GetScriptScope();
    }
    local scoperef = [scope.weakref()];
    local tmpEnt = CreateByClassname("point_template");
    local name = tmpEnt.GetScriptId();
    local code = format("delays.%s[0]()", name);
    delays[name] <- [function()
    {
        local scope = (delete delays[name])[1][0];
        if (!scope || ("self" in scope && (!scope.self || !scope.self.IsValid())))
            return;
        func.acall([scope].extend(params));
    }, scoperef];
    SetPropBool(tmpEnt, "m_bForcePurgeFixedupStrings", true);
    SetPropString(tmpEnt, "m_iName", code);
    EntFireByHandle(main_script_entity, "RunScriptCode", code, delay, null, null);
    EntFireByHandle(tmpEnt, "Kill", null, delay, null, null)
}
::Schedule <- RunWithDelay;

//Deletes all timers attached to a particular scope
::DeleteAllTimersFromScope <- function(scope)
{
    for (local i = timers.len() - 1; i >= 0; i--)
        if (timers[i][2] == scope)
            timers.remove(i);
}

//Deletes all delayed functions attached to a particular scope
::DeleteAllDelaysFromScope <- function(scope)
{
    foreach(name, delay in delays)
        if (delay[1][0] == scope)
            delay[1][0] = null;
}

//==============================
//Internal Functions.
//==============================

::timers <- [];
::delays <- {};

function InitTimer()
{
    local timerHolder = SpawnEntityFromTable("point_template", {});
    timerHolder.ValidateScriptScope();
    timerHolder.GetScriptScope().LizardLibThink <- function()
    {
        main_script.LizardLibThink();
        return -1;
    }
    AddThinkToEnt(timerHolder, "LizardLibThink");
}
InitTimer();

function LizardLibThink()
{
    local time = Time();
    for (local i = timers.len() - 1; i >= 0; i --)
    {
        local entry = timers[i];
        local scope = entry[2];
        if (!scope || ("self" in scope && (!scope.self || !scope.self.IsValid())))
        {
            timers.remove(i);
        }
        else if (time - entry[3] >= entry[4])
        {
            entry[4] += entry[3];
            try { entry[1].call(scope); } catch (e) { }
        }
    }
    return -1;
}