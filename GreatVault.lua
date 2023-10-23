local function GreatVault_GetActivities(activityType)
	local activities = C_WeeklyRewards.GetActivities(activityType);
	table.sort(activities, function(a,b) return a.index < b.index end)
	for _,activity in pairs(activities) do
		if activity.progress >= activity.threshold then
			local currentLink, _ = C_WeeklyRewards.GetExampleRewardItemHyperlinks(activity.id);
			activity.currentItemLevel = GetDetailedItemLevelInfo(currentLink);
		end
	end
	return activities
end

local function GreatVault_AggregateRewards(activities)
    local character = {
        characterName = UnitName("player");
        level = UnitLevel("player");
        className = UnitClass("player");
        faction = UnitFactionGroup("player");
        itemLevel = math.floor(GetAverageItemLevel());
        realm = GetRealmName();
        mythic = 0;
        raid = 0;
        pvp = 0;
    };
    
    for _,activity in pairs(activities) do
        if(activity.currentItemLevel) then
            if (activity.type == Enum.WeeklyRewardChestThresholdType.MythicPlus) then
                character.mythic = character.mythic + 1
            elseif(activity.type == Enum.WeeklyRewardChestThresholdType.RankedPvP) then
                character.pvp = character.pvp + 1;
            elseif(activity.type == Enum.WeeklyRewardChestThresholdType.Raid) then
                character.raid = character.raid + 1
            end
        end
    end
    return character;
end

local function GreatVault_GetAllActivities()
    local finalActivities = GreatVault_GetActivities(Enum.WeeklyRewardChestThresholdType.MythicPlus)
    for k, v in pairs(GreatVault_GetActivities(Enum.WeeklyRewardChestThresholdType.RankedPvP)) do table.insert(finalActivities, v) end
    for k, v in pairs(GreatVault_GetActivities(Enum.WeeklyRewardChestThresholdType.Raid)) do table.insert(finalActivities, v) end
    return finalActivities;
end


function GreatVault_saveCurrentCharacter()
    local level = UnitLevel("player")
    if level == 70 then
        local activites = GreatVault_GetAllActivities()
        local characterName = UnitName("player");
        local realmName = GetRealmName();
        GreatVaultDatabase[realmName][characterName] = GreatVault_AggregateRewards(activites)
    end
end