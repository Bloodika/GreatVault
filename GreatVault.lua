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

local function GreatVault_AggregateRewards(characterName,level,className, realm, activities)
    local character = {
        characterName = characterName;
        level = level;
        className = className;
        realm = realm;
        mythic = 0;
        raid = 0;
        pvp = 0;
    };
    for _,activity in pairs(activities) do
        if(activity.currentItemLevel) then
            if (activity.type ==1 ) then
                character.mythic = character.mythic + 1
            elseif(activity.type == 2) then
                character.pvp = character.pvp + 1;
            elseif(activity.type == 3) then
                character.raid = character.raid + 1
            end
        end
    end
    return character;
end

local function GreatVault_GetAllActivities()
    local finalActivities = GreatVault_GetActivities(1)
    for k, v in pairs(GreatVault_GetActivities(2)) do table.insert(finalActivities, v) end
    for k, v in pairs(GreatVault_GetActivities(3)) do table.insert(finalActivities, v) end
    return finalActivities;
end


function GreatVault_saveCurrentCharacter()
    local level = UnitLevel("player")
    if level == 70 then
        local characterName = UnitName("player")
        local realmName = GetRealmName()
        local className = UnitClass("player")
        local activites = GreatVault_GetAllActivities()
        GreatVaultDatabase[realmName][characterName] = GreatVault_AggregateRewards(characterName,level,className, realmName, activites)
    end
end