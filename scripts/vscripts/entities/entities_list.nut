class Collectable extends PizzaEntity
{
    pickup_dist = 48;

    function OnCreate(client, distance, logic_relay, ent_data)
    {
        if(!("escape" in ent_data))
            ent_data["escape"] <- "0"

        if(ent_data["escape"] == "1" && !client.GetVar("escape"))
        {
            local prop = PlayerActiveCollectables[client][logic_relay];
            SetPropInt(prop, "m_nRenderMode", kRenderTransColor);
            SetEntityColor(prop, [255,255,255,25]);
        }
    }

    function Think(client, distance, logic_relay, ent_data)
    {
        if(!client.GetVar("escape") && ent_data["escape"] == "1")
            return;

        //if we're in range to collect it, add combo, add this relay to the collected list and kill the prop
        if(distance > 48)
            return;

        local prop = PlayerActiveCollectables[client][logic_relay];

        OnPickup(client, distance, logic_relay, ent_data)

        PlayerCollectedList[client].append(logic_relay);
        prop.Destroy();
        delete PlayerActiveCollectables[client][logic_relay];
    }

    function OnPickup(client, distance, logic_relay, ent_data) {}
}

EntityList["collect_small"] <- (class extends Collectable
{
    function GetModel()
    {
        return "models/items/currencypack_small.mdl";
    }

    function OnPickup(client, distance, logic_relay, ent_data)
    {
        AddCombo(client);
        AddScore(client, 10);
        PlaySoundForPlayer("PizzaTower.SmallCollect", client);
    }
})

EntityList["collect_large"] <- (class extends Collectable
{
    function GetModel()
    {
        return "models/items/currencypack_large.mdl";
    }

    function OnPickup(client, distance, logic_relay, ent_data)
    {
        AddCombo(client);
        AddComboTime(client, 1);
        AddScore(client, 100);
        PlaySoundForPlayer("PizzaTower.LargeCollect", client);
    }
})

const SECRET1 = 1;
const SECRET2 = 2;
const SECRET3 = 4;
EntityList["secret_teleport"] <- (class extends PizzaEntity
{
    function GetModel()
    {
        return "models/props_mvm/mvm_revive_tombstone.mdl";
    }

    function OnCreate(client, distance, logic_relay, ent_data)
    {
        if(!("exit" in ent_data))
            ent_data["exit"] <- "0";

        local secret_id = null;
        switch(ent_data["id"])
        {
            case "1": secret_id = SECRET1; break;
            case "2": secret_id = SECRET2; break;
            case "3": secret_id = SECRET3; break;
        }
        if(!secret_id)
            return;

        if(ent_data["exit"] == "0" && client.GetVar("secret") & secret_id)
        {
            local prop = PlayerActiveCollectables[client][logic_relay];
            prop.SetDrawEnabled(false);
        }
    }

    function Think(client, distance, logic_relay, ent_data)
    {
        local secret_id = null;
        switch(ent_data["id"])
        {
            case "1": secret_id = SECRET1; break;
            case "2": secret_id = SECRET2; break;
            case "3": secret_id = SECRET3; break;
        }
        if(!secret_id)
            return;

        // do we have this secret collected
        if(ent_data["exit"] == "0" && client.GetVar("secret") & secret_id)
            return;

        if(ent_data["exit"] == "1" && client.GetMoveType() == MOVETYPE_NONE)
            return;

        //teleport player to secret entry and give them the secret flag
        if(distance > 48)
            return;

        local entity = null;
        if(ent_data["exit"] == "1")
        {
            while (entity = FindByName(entity, "secret_teleport*"))
            {
                if(CollectableList[entity]["id"] != ent_data["id"])
                    continue;

                if(CollectableList[entity]["stage"] != ent_data["stage"])
                    continue;

                if(CollectableList[entity]["exit"] != "0")
                    continue;

                break;
            }
        }
        else
        {
            while (entity = FindByName(entity, "secret_entry*"))
            {
                if(CollectableList[entity]["id"] != ent_data["id"])
                    continue;

                if(CollectableList[entity]["stage"] != ent_data["stage"])
                    continue;

                break;
            }
        }

        if(!entity)
            return;

        if(ent_data["exit"] == "0")
            client.AddVar("secret", secret_id);

        SetDrawHUD(client, false);
        client.SetVar("combo_frozen", true);
        client.DisableDraw();
        SetPropInt(client, "m_nForceTauntCam", 1);
        client.AddEFlags(FL_ATCONTROLS);
        client.SetMoveType(MOVETYPE_NONE, MOVECOLLIDE_DEFAULT);
        client.SetVelocity(Vector(0,0,0));
        PlaySoundForPlayer("PizzaTower.SecretEnter", client);

        RunWithDelay(1, function(){
            client.SetVar("secret_active", ent_data["exit"] == "0" ? true : false);
            client.SetOrigin(entity.GetOrigin());
            if(ent_data["exit"] == "0")
                PlaySoundForPlayer("PizzaTower.SecretFind", client);
        })
        RunWithDelay(1.5, function(){
            PlaySoundForPlayer("PizzaTower.SecretExit", client);
            client.EnableDraw();
        })
        RunWithDelay(2, function(){
            SetDrawHUD(client, true);
            SetPropInt(client, "m_nForceTauntCam", 0);
            client.RemoveEFlags(FL_ATCONTROLS);
            client.SetVelocity(Vector(0,0,0));
            client.SetMoveType(MOVETYPE_WALK, MOVECOLLIDE_DEFAULT);
            client.SetVar("combo_frozen", false);
        })
    }
})

//marker point for secret_teleport into the secret
EntityList["secret_entry"] <- (class extends PizzaEntity
{
    function GetModel()
    {
        return "models/props_mvm/mvm_revive_tombstone.mdl";
    }
})