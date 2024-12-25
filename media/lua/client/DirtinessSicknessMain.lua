--
--                                  @*x/||x8
--                                   %8%n&v]`Ic
--                                     *)   }``W
--                                     *>&  1``n
--                                  &@ tI1/^`"@
--                                 &11\]"``^v
--                                M"`````,[&@@@@@
--                            &#cv(`:[/];"`````^r%
--                        @z);^`^;}"~}"........;&
--                 @WM##n~;+"`^^^.<[}}+,`'''`:tB
--                 #*xj<;).`i"``"l}}}}}}}%@B
--                 j^'..`+..,}}}}}}}}}}}(
--                  /,'.'...I}}}}}}}}}}}r
--                    @Muj/x*c"`'';}}}}}n
--                           !..'!}}}}}}x
--                          r`^;[}}}}}}}t                        @|M
--                         8{}}}}}}}}}}}{&                       B?>|@
--                         \}}}}}}}}}}}}})W                      x}?'<
--                        v}}}}}}}}}}}}}}}}/v#&%B  @@          Bj}}:.`
--                        :,}}}}}}}}}}}}}}}}}}}}}}}{{{1)(|/jnzr{}+"..-
--                        :.;}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}]l,;_c
--                        (.:}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}t
--                      &r_^']}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}+*
--                   Mt-I,,,^`[}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}"W
--               *\+;,,,,,,,,",}}}}}}}}}}}]??]]}}}}}}}}}}}}}}}]""*
--             c;,,,,:;+{rW8BBB!+}}}}}}}}}>,:;!}}}}}}}}}}}}-"^`"l\%
--             W:,,,?@         n'+}}}}}}}?:,,,:[}}}}}}}}}}}:.,,,+|f@
--              /,,,i8          ,"}}}}}}|vnrrrrt}}}}}}}}}}}"`,,,:1|\v@
--               xI,,;rB%%B     [:}}}}{u        c(}}}}}}}}},`,,,,;}||/8
--                @fl]trrrrr    *}}}}}t           &vf(}}}}}]`:,,,,,?||t
--                  @*rrrrrx    *}}}}})@              &/}}}}-nxj\{[)|||xc#
--                     Mrrrv    v}}}}}c                 u}}}}}}r   8t|||||8
--                      8nr*    x}}}}n                   j}}}}}v    Bj|||?t
--                        &B    r}}}\                    %}}}}>%     &_]}:u
--                              j}}}z                    _"~l`1    Bx<,,,;B
--                              njxt@                @z}"....!   z[;;;;:;}
--                           %MvnnnnM               *~"^^^``iB  B*xrrrffrrB
--                         Wunnnnnnn*             &cnnnnnnnv   @*z*****zz#
--                        &MWWWWWWMWB            WMWWWWWWMWB
------------------------------------------------------------------------------------------------------
-- AUTHOR: Badonn the Deer
-- LICENSE: MIT
-- REFERENCES: N/A
-- Did this code help you write your own mod? Consider donating to me at https://ko-fi.com/badonnthedeer!
-- I'm in financial need and every little bit helps!!
--
-- Have a problem or question? Reach me on Discord: badonn
------------------------------------------------------------------------------------------------------

require "MF_ISMoodle"
TAB = require("fol_Take_A_Bath");
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
    local cap = sbv.SicknessCap;
    local increaseAmt = sbv.IncreaseSicknessAmt
    local sicknessLevel = player:getBodyDamage():getFoodSicknessLevel();
    if sicknessLevel >= cap
    then
        --if someone has a higher Food Sickness already, just return that and don't modify it.
        return sicknessLevel;
    else
        --else add increaseAmt to Food Sickness and return that (or that cap if said amount would be larger.)
        return (math.min((sicknessLevel + increaseAmt), sbv.SicknessCap))
    end

end

DirtinessSickness.setMoodleValue = function(player, value)
    local moodle = MF.getMoodle("DirtinessSickness", player:getPlayerNum());
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

    local moodle = MF.getMoodle("DirtinessSickness", player:getPlayerNum());
    local sbv =  SandboxVars.DirtinessSickness;

    moodle:setThresholds(sbv.CriticalThreshold, sbv.HighThreshold, sbv.MediumThreshold, sbv.LowThreshold, nil, nil, nil, nil);
    DirtinessSickness.setMoodleValue(player, 1.0);
end

DirtinessSickness.createMoodleWithValue = function(player, value)
    --don't use the regular create in moodle framework because it conflicts with trying to customize stuff
    MF.ISMoodle:new("DirtinessSickness", player)

    local moodle = MF.getMoodle("DirtinessSickness", player:getPlayerNum());
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
            local moodle = MF.getMoodle("DirtinessSickness", player:getPlayerNum());
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
                        if rolledChance <= sbv.CriticalSickChancePerHour
                        then
                            player:getBodyDamage():setFoodSicknessLevel(DirtinessSickness.getNewFoodSicknessValue(player));
                        end
                    elseif moodleLevel == 3
                    then
                        if rolledChance <= sbv.HighSickChancePerHour
                        then
                            player:getBodyDamage():setFoodSicknessLevel(DirtinessSickness.getNewFoodSicknessValue(player));
                        end
                    elseif moodleLevel == 2
                    then
                        if rolledChance <= sbv.MediumSickChancePerHour
                        then
                            player:getBodyDamage():setFoodSicknessLevel(DirtinessSickness.getNewFoodSicknessValue(player));
                        end
                    elseif moodleLevel == 1
                    then
                        if rolledChance <= sbv.LowSickChancePerHour
                        then
                            player:getBodyDamage():setFoodSicknessLevel(DirtinessSickness.getNewFoodSicknessValue(player));
                        end
                    end
                else
                    --failsafe for other methods of getting clean
                    DirtinessSickness.setMoodleValue(player, 1.0);
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
    local moodle = MF.getMoodle("DirtinessSickness", self.character:getPlayerNum());
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

if getActivatedMods():contains("fol_Take_A_Bath")
then
    local origTakeABathActionPerform = Fol_Take_A_Bath_TUB_Action.perform
    Fol_Take_A_Bath_TUB_Action.perform = function(self)
        origTakeABathActionPerform(self);
        DirtinessSickness.setMoodleValue(self.character, 1.0);
    end
end


--[[ unnecessary since ending bath early doesn't clean you at all.
local origTakeABathActionStop = Fol_Take_A_Bath_TUB_Action.stop
Fol_Take_A_Bath_TUB_Action.stop = function(self)
    origTakeABathActionStop(self)
    local sbv = SandboxVars.DirtinessSickness
    local moodle = MF.getMoodle("DirtinessSickness", self.character:getPlayerNum());
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
end]]

Events.OnCreatePlayer.Add(DirtinessSickness.DSPlayerCreate);
Events.OnSave.Add(DirtinessSickness.DSSave);
Events.EveryHours.Add(DirtinessSickness.DSEveryHours);

return DirtinessSickness;