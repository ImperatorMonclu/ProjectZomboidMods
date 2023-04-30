local function Thievery_tryOpenInventory(worldobjects, player, otherPlayer)
    print("Thievery_tryOpenInventory")
    print(player:getDisplayName())
    print(otherPlayer:getDisplayName())
    local items = otherPlayer:getInventory():getItems()

    for i = 1, items:size() - 1 do
        local item = items:get(i)
        print(item:getName())
    end
end

local function Thievery_OnPreFillWorldObjectContextMenu(player, context, worldobjects, test)
    -- local clickedPlayer
    -- if instanceof(v, "IsoPlayer") and (v ~= playerObj) then
    --     clickedPlayer = v;
    -- end
    -- for x=v:getSquare():getX()-1,v:getSquare():getX()+1 do
    --     for y=v:getSquare():getY()-1,v:getSquare():getY()+1 do
    --         local sq = getCell():getGridSquare(x,y,v:getSquare():getZ());
    --         if sq then
    --             for i=0,sq:getMovingObjects():size()-1 do
    --                 local o = sq:getMovingObjects():get(i)
    --                 if instanceof(o, "IsoPlayer") and (o ~= player) then
    --                     clickedPlayer = o
    --                 end
    --             end
    --         end
    --     end
    -- end
    local playerObj = getSpecificPlayer(player)
    if clickedPlayer and clickedPlayer ~= playerObj then
        local option = context:addOption("getText(\"ContextMenu_Trade\", clickedPlayer:getDisplayName())", worldobjects,
            Thievery_tryOpenInventory, playerObj, clickedPlayer)
        if math.abs(playerObj:getX() - clickedPlayer:getX()) > 2 or math.abs(playerObj:getY() - clickedPlayer:getY()) >
            2 then
            option.notAvailable = true
            local tooltip = ISToolTip:new()
            tooltip:initialise()
            tooltip.description = "getText(\"ContextMenu_GetCloserToTrade\", clickedPlayer:getDisplayName())";
            option.toolTip = tooltip
        end
    end
end

-- ISWorldObjectContextMenu.onTrade = function(worldobjects, player, otherPlayer)
--     local ui = ISTradingUI:new(50, 50, 500, 500, player, otherPlayer)
--     ui:initialise();
--     ui:addToUIManager();
--     ui.pendingRequest = true;
--     ui.blockingMessage = getText("IGUI_TradingUI_WaitingAnswer", otherPlayer:getDisplayName());
--     requestTrading(player, otherPlayer);
-- end

if isClient() then
    -- Events.OnPreFillWorldObjectContextMenu.Add(Thievery_OnPreFillWorldObjectContextMenu)
    Events.OnFillWorldObjectContextMenu.Add(Thievery_OnPreFillWorldObjectContextMenu)
end
