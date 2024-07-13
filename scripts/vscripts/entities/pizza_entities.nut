::PlayerCollectedList <- {} //array of logic_relays (player->array) that we refuse to run spawn logic on
::PlayerActiveCollectables <- {} //list of obj_teleporters spawned for player (player->logic_relay->obj_teleporter)
::CollectableList <- {} //every logic_relay with it's classname

::EntityList <- {} //list of all our entities

::LOSCheck <- function(client, logic_relay) {return TraceLine(client.EyePosition(), logic_relay.GetCenter(), client) > 0.99;}

class PizzaEntity {
    function CanSpawn(client, logic_relay, ent_data) {return true;}
    function OnCreate(client, distance, logic_relay, ent_data) {}
    function OnOutOfRange(client, distance, logic_relay, ent_data) {}
    function GetModel() {}
    function Think(client, distance, logic_relay, ent_data) {}
}

Include("entities/entities_list");

::PrecacheAllCollectables <- function()
{
    local entity = null;
    while (entity = FindByClassname(entity, "logic_relay"))
    {
        local keyvalues = split(GetPropString(entity, "m_iName"), ",");

        CollectableList[entity] <- {};

        if(!(keyvalues[0] in EntityList))
        {
            printl("Failed to init entity \"" + keyvalues[0] + "\" Did you name a logic_relay wrong?");
            continue;
        }

        CollectableList[entity].classname <- keyvalues[0];

        if(keyvalues.len() == 1)
            continue;

        //grab our keys and values
        local reading_key = true;
        for (local i = 1; i < keyvalues.len(); i++)
        {
            CollectableList[entity][keyvalues[i]] <- keyvalues[i+1];
            i++;
        }
    }
}
PrecacheAllCollectables();

::CollectableSpawnThink <- function()
{
    if(!self.GetVar("stage"))
        return;

    if(!(self in PlayerActiveCollectables))
        PlayerActiveCollectables[self] <- {}

    if(!(self in PlayerCollectedList))
        PlayerCollectedList[self] <- []

    foreach(entity, ent_data in CollectableList)
    {
        local distance = (entity.GetCenter() - self.GetCenter()).Length();

        //we're in range of this collectable, did we collect it? if not, lets spawn an obj_teleporter for it.
        if (distance <= 2000 && LOSCheck(self, entity))
        {
            //else if we didn't collect AND we dont have a prop for this collectable
            if(!(PlayerCollectedList[self].find(entity) != null) && !(entity in PlayerActiveCollectables[self]) && EntityList[ent_data.classname].CanSpawn(self, entity, ent_data))
            {
                //spawn obj_teleporter
                PlayerActiveCollectables[self][entity] <- CreateInstancedProp(self, EntityList[ent_data.classname].GetModel(), entity.GetOrigin());
                EntityList[ent_data.classname].OnCreate(self, distance, entity, ent_data);
            }

            if(entity in PlayerActiveCollectables[self])
            {
                EntityList[ent_data.classname].Think(self, distance, entity, ent_data);
            }
        }
        else
        {
            //if we're out of it's range, do we have an obj_teleporter tied to this collectable? if so destroy it
            if(entity in PlayerActiveCollectables[self])
            {
                //kill the obj_teleporter
                EntityList[ent_data.classname].OnOutOfRange(self, distance, entity, ent_data);
                PlayerActiveCollectables[self][entity].Destroy();
                delete PlayerActiveCollectables[self][entity];
            }
        }
    }
}