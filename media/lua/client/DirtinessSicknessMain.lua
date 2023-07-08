require "MF_ISMoodle"
local DirtinessSickness = {};

-- C:\Program Files (x86)\Steam\steamapps\common\ProjectZomboid\media\lua | Project Zomboid files
-- C:\Program Files (x86)\Steam\steamapps\workshop\content\108600\

-- C:\Users\[user]\Zomboid\mods
-- C:\Users\[user]\Zomboid\Logs

--Tchernobill's recommended implementation:
--require "MF_ISMoodle"
--MF.createMoodle("DirtinessSickness");
--
--local initThreshold = false
--DirtinessSickness.updatePlayerMoodle = function(player)
--    local moodle = MF.getMoodle("DirtinessSickness");
--    local sbv =  SandboxVars.DirtinessSickness;
--
--    if moodle then
--        if not initThreshold then
--            moodle:setThresholds(sbv.CriticalThreshold, sbv.HighThreshold, sbv.MediumThreshold,sbv.LowThreshold, nil, nil, nil, nil);
--        end
--
--        moodle:setValue(1.0);
--    end
--end
--...
--Events.OnPlayerUpdate.Add(DirtinessSickness.updatePlayerMoodle);

DirtinessSickness.getNewFoodSicknessValue = function(player)
    local sbv =  SandboxVars.DirtinessSickness;
    local setValue = sbv.SetSicknessLevel;
    if setValue == true
    then
        return sbv.SetSicknessLevelAmt
    else
        return (math.min((player:getBodyDamage():getFoodSicknessLevel() + sbv.IncreaseSicknessLevelAmt), 100))
    end
end

DirtinessSickness.setMoodleValue = function(player, value)
    local moodle = MF.getMoodle("DirtinessSickness");
    local modData = player:getModData().DirtinessSickness

    if modData ~= nil
    then
        modData.moodleValue = value;
    end
    if moodle ~= nil
    then
        moodle:setValue(value);
    end
end

DirtinessSickness.createMoodle = function(player)
    --don't use the regular create in moodle framework because it conflicts with trying to customize stuff
    MF.ISMoodle:new("DirtinessSickness", player)

    local moodle = MF.getMoodle("DirtinessSickness");
    local sbv =  SandboxVars.DirtinessSickness;

    moodle:setThresholds(sbv.CriticalThreshold, sbv.HighThreshold, sbv.MediumThreshold, sbv.LowThreshold, nil, nil, nil, nil);
    DirtinessSickness.setMoodleValue(player, 1.0);
end

DirtinessSickness.createMoodleWithValue = function(player, value)
    --don't use the regular create in moodle framework because it conflicts with trying to customize stuff
    MF.ISMoodle:new("DirtinessSickness", player)

    local moodle = MF.getMoodle("DirtinessSickness");
    local sbv =  SandboxVars.DirtinessSickness;

    moodle:setThresholds(sbv.CriticalThreshold, sbv.HighThreshold, sbv.MediumThreshold, sbv.LowThreshold, nil, nil, nil, nil);
    DirtinessSickness.setMoodleValue(player, player:getModData().DirtinessSickness.moodleValue);
end

DirtinessSickness.DSPlayerCreate = function(_, player)
--don't use the regular create in moodle framework because it conflicts with trying to customize stuff
    local modData = player:getModData().DirtinessSickness

    if modData == nil
    then
        MF.Moodles["DirtinessSickness"] = nil;
        player:getModData().DirtinessSickness = {};
        player:getModData().DirtinessSickness.moodleValue = 1.0;
        DirtinessSickness.createMoodle(player);
    else
        MF.Moodles["DirtinessSickness"] = nil;
        DirtinessSickness.createMoodleWithValue(player, modData.moodleValue);
    end
end


DirtinessSickness.DSEveryHours = function()
 local activePlayers = getNumActivePlayers();
    if activePlayers >= 1
    then
        for playerIndex = 0, (activePlayers - 1)
        do
            local player = getSpecificPlayer(playerIndex);
            local sbv = SandboxVars.DirtinessSickness
            local visual = player:getHumanVisual();
            local totalDirtiness = 0;
            local moodle = MF.getMoodle("DirtinessSickness");
            if moodle ~= nil
            then
                local moodleLevel = moodle:getLevel();
                local rolledChance = ZombRandFloat(0,1);
                local newMoodleValue = moodle:getValue() + sbv.DecreasePerHour
                --make sure value doesn't go below 0
                newMoodleValue = math.max(0, newMoodleValue);

                for i = 0, BloodBodyPartType.MAX:index()-1 do
                    local bloodBodyPartType = BloodBodyPartType.FromIndex(i)
                    totalDirtiness = totalDirtiness + visual:getDirt(bloodBodyPartType);
                end
                --1.0 for maximum dirtiness for each bodypart. If player is max dirty, add to moodle.
                -- -1 for MAX bodypart
                if totalDirtiness >= (sbv.DirtinessToTickUp)
                then
                    DirtinessSickness.setMoodleValue(player, newMoodleValue);
                    --moodle:setDescription(moodle:getGoodBadNeutral(), moodle:getLevel(),)
                    moodle:doWiggle();
                    if moodleLevel == 4
                    then
                        if rolledChance <= sbv.CriticalFeverChancePerHour
                        then
                            player:getBodyDamage():setFoodSicknessLevel(DirtinessSickness.getNewFoodSicknessValue(player));
                        end
                    elseif moodleLevel == 3
                    then
                        if rolledChance <= sbv.HighFeverChancePerHour
                        then
                            player:getBodyDamage():setFoodSicknessLevel(DirtinessSickness.getNewFoodSicknessValue(player));
                        end
                    elseif moodleLevel == 2
                    then
                        if rolledChance <= sbv.MediumFeverChancePerHour
                        then
                            player:getBodyDamage():setFoodSicknessLevel(DirtinessSickness.getNewFoodSicknessValue(player));
                        end
                    elseif moodleLevel == 1
                    then
                        if rolledChance <= sbv.LowFeverChancePerHour
                        then
                            player:getBodyDamage():setFoodSicknessLevel(DirtinessSickness.getNewFoodSicknessValue(player));
                        end
                    end
                end
            end
        end
    end
end

local origWashSelfPerform = ISWashYourself.perform
ISWashYourself.perform = function(self)
    origWashSelfPerform(self)
    DirtinessSickness.setMoodleValue(self.character, 1.0);
end

local origWashSelfStop = ISWashYourself.stop
ISWashYourself.stop = function(self)
    origWashSelfStop(self)
    local sbv = SandboxVars.DirtinessSickness
    local moodle = MF.getMoodle("DirtinessSickness");
    if moodle ~= nil
    then
        local visual = self.character:getHumanVisual();
        local totalDirtiness = 0;

        for i = 0, BloodBodyPartType.MAX:index()-1 do
            local bloodBodyPartType = BloodBodyPartType.FromIndex(i)
            totalDirtiness = totalDirtiness + visual:getDirt(bloodBodyPartType);
        end
        if totalDirtiness < (sbv.DirtinessToTickUp)
        then
            DirtinessSickness.setMoodleValue(self.character, 1.0);
        end
    end
end

Events.OnCreatePlayer.Add(DirtinessSickness.DSPlayerCreate);
Events.OnSave.Add(DirtinessSickness.DSSave);
Events.EveryHours.Add(DirtinessSickness.DSEveryHours);

return DirtinessSickness;