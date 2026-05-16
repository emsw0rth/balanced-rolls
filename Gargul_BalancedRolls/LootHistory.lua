local BR = _G.BalancedRolls

BR.LootHistory = {
    history = {},
    GL = nil,
}
local LH = BR.LootHistory

function BR:InitLootHistory()
    GargulHistoryDB = GargulHistoryDB or {}
    GargulHistoryDB.history = GargulHistoryDB.history or {}
    LH.history = GargulHistoryDB.history

    local GL = _G.Gargul
    if not GL then
        self:Print("Gargul not found - loot history disabled.")
        return
    end
    LH.GL = GL

    GL.Events:register("BalancedRollsLootHistoryItemAwarded", "GL.ITEM_AWARDED", function(_, AwardEntry)
        BR:OnItemAwarded(AwardEntry)
    end)
end

function BR:OnItemAwarded(AwardEntry)
    if not AwardEntry then
        return
    end

    local itemName = AwardEntry.itemLink and AwardEntry.itemLink:match("%[(.-)%]") or "Unknown"

    local awardedTo = AwardEntry.awardedTo or "Unknown"
    local dashPos = awardedTo:find("-")
    if dashPos then
        awardedTo = awardedTo:sub(1, dashPos - 1)
    end

    local entry = {
        date = date("%Y-%m-%d %H:%M:%S", AwardEntry.timestamp or time()),
        awardedTo = awardedTo,
        item = {
            name = itemName,
            id = tostring(AwardEntry.itemID or 0),
        },
        itemLink = AwardEntry.itemLink,
        timestamp = AwardEntry.timestamp or time(),
    }

    table.insert(LH.history, entry)

    if BR.LootHistoryUI and BR.LootHistoryUI.IsOpen then
        BR.LootHistoryUI:Refresh()
    end
end

-- Hook into init
local originalInit = BR.Init
function BR:Init()
    originalInit(self)
    self:InitLootHistory()
end
