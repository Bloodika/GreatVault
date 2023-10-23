local function GetActivities(activityType)
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

local function GreatVault_AggregateRewards(characterName, realm, activities)
    local finalActivities = {
        characterName = characterName;
        realm = realm;
        mythic = 0;
        raid = 0;
        pvp = 0;
    };
    for _,activity in pairs(activities) do
        if(activity.currentItemLevel) then
            if (activity.type==1) then
                finalActivities.mythic = finalActivities.mythic + 1
            elseif(activity.type == 2) then
                finalActivities.pvp = finalActivities.pvp + 1;
            elseif(activity.type == 3) then
                finalActivities.raid = finalActivities.raid + 1
            end
        end
    end
    return finalActivities;
end

local function GreatVault_GetAllActivities()
    local finalActivities = GetActivities(1)
    for k, v in pairs(GetActivities(2)) do table.insert(finalActivities, v) end
    for k, v in pairs(GetActivities(3)) do table.insert(finalActivities, v) end
    return finalActivities;
end


function saveCurrentCharacter()
    local characterName = UnitName("player")
    local realmName = GetRealmName()
    local activites = GreatVault_GetAllActivities()
    GreatVaultDatabase[realmName][characterName] = GreatVault_AggregateRewards(characterName, realmName, activites)    
end