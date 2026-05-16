local BR = _G.BalancedRolls

local ROW_HEIGHT = 18
local FRAME_WIDTH = 480
local FRAME_HEIGHT = 460
local NAME_WIDTH = 130
local RH_WIDTH = 200
local MOD_WIDTH = 80

function BR:ToggleMainWindow()
    if self.MainFrame and self.MainFrame:IsShown() then
        self.MainFrame:Hide()
        return
    end
    self:ShowMainWindow()
end

function BR:ShowMainWindow()
    if self.MainFrame then
        self.MainFrame:Show()
        self:RefreshMainWindowList()
        return
    end

    local frame = CreateFrame("Frame", "BalancedRollsMainFrame", UIParent, "BackdropTemplate")
    frame:SetSize(FRAME_WIDTH, FRAME_HEIGHT)
    frame:SetPoint("CENTER")
    frame:SetBackdrop(_G.BACKDROP_DARK_DIALOG_32_32)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetClampedToScreen(true)
    frame:SetFrameStrata("HIGH")
    frame:SetToplevel(true)

    _G.BALANCED_ROLLS_MAIN_WINDOW = frame
    tinsert(UISpecialFrames, "BALANCED_ROLLS_MAIN_WINDOW")

    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeBtn:SetSize(30, 30)
    closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 8, 5)
    closeBtn:SetScript("OnClick", function() frame:Hide() end)

    local titleBar = CreateFrame("Frame", nil, frame)
    titleBar:SetHeight(24)
    titleBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -8)
    titleBar:SetPoint("TOPRIGHT", closeBtn, "TOPLEFT", -2, 0)
    titleBar:EnableMouse(true)
    titleBar:RegisterForDrag("LeftButton")
    titleBar:SetScript("OnDragStart", function() frame:StartMoving() end)
    titleBar:SetScript("OnDragStop", function() frame:StopMovingOrSizing() end)

    local titleText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    titleText:SetPoint("LEFT", titleBar, "LEFT", 4, 0)
    titleText:SetText("Balanced Rolls")
    titleText:SetTextColor(1, 0.84, 0, 1)

    local historyBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    historyBtn:SetSize(140, 25)
    historyBtn:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -42)
    historyBtn:SetText("Loot History")
    historyBtn:SetScript("OnClick", function()
        if BR.LootHistoryUI then
            BR.LootHistoryUI:Toggle()
        end
    end)

    local importBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    importBtn:SetSize(140, 25)
    importBtn:SetPoint("TOPLEFT", historyBtn, "BOTTOMLEFT", 0, -6)
    importBtn:SetText("Import Data")
    importBtn:SetScript("OnClick", function()
        BR:ShowImportWindow()
    end)

    local countText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    countText:SetPoint("LEFT", importBtn, "RIGHT", 12, 0)
    countText:SetTextColor(0.7, 0.7, 0.7)
    frame.countText = countText

    -- Header row
    local headerRow = CreateFrame("Frame", nil, frame)
    headerRow:SetHeight(18)
    headerRow:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -118)
    headerRow:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -36, -118)

    local function makeHeader(parent, text, offsetX, width, justify)
        local fs = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        fs:SetPoint("LEFT", parent, "LEFT", offsetX, 0)
        fs:SetWidth(width)
        fs:SetJustifyH(justify or "LEFT")
        fs:SetText(text)
        fs:SetTextColor(1, 0.84, 0, 1)
        return fs
    end

    makeHeader(headerRow, "Name", 0, NAME_WIDTH, "LEFT")
    makeHeader(headerRow, "Raid-Helper Name", NAME_WIDTH, RH_WIDTH, "LEFT")
    makeHeader(headerRow, "Roll Modifier", NAME_WIDTH + RH_WIDTH, MOD_WIDTH, "RIGHT")

    local headerSep = headerRow:CreateTexture(nil, "ARTWORK")
    headerSep:SetHeight(1)
    headerSep:SetPoint("BOTTOMLEFT", headerRow, "BOTTOMLEFT", 0, -2)
    headerSep:SetPoint("BOTTOMRIGHT", headerRow, "BOTTOMRIGHT", 0, -2)
    headerSep:SetColorTexture(0.4, 0.4, 0.4, 0.6)

    -- List background (Gargul textArea style)
    local listBg = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    listBg:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 4, right = 3, top = 4, bottom = 3 },
    })
    listBg:SetBackdropColor(0, 0, 0)
    listBg:SetBackdropBorderColor(0.4, 0.4, 0.4)
    listBg:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -140)
    listBg:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -16, 16)

    local scrollFrame = CreateFrame("ScrollFrame", nil, listBg, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", listBg, "TOPLEFT", 8, -8)
    scrollFrame:SetPoint("BOTTOMRIGHT", listBg, "BOTTOMRIGHT", -28, 8)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(FRAME_WIDTH - 60, 1)
    scrollFrame:SetScrollChild(content)

    self.MainFrame = frame
    self.MainScrollFrame = scrollFrame
    self.MainContent = content
    self.MainRows = {}

    self:RefreshMainWindowList()
end

local function getOrCreateMainRow(index)
    if BR.MainRows[index] then
        return BR.MainRows[index]
    end

    local row = CreateFrame("Frame", nil, BR.MainContent)
    row:SetHeight(ROW_HEIGHT)
    row:SetPoint("TOPLEFT", BR.MainContent, "TOPLEFT", 0, -(index - 1) * ROW_HEIGHT)
    row:SetPoint("TOPRIGHT", BR.MainContent, "TOPRIGHT", 0, -(index - 1) * ROW_HEIGHT)

    local bg = row:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    if index % 2 == 0 then
        bg:SetColorTexture(1, 1, 1, 0.05)
    else
        bg:SetColorTexture(0, 0, 0, 0)
    end
    row.bg = bg

    local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    nameText:SetPoint("LEFT", row, "LEFT", 4, 0)
    nameText:SetWidth(NAME_WIDTH - 4)
    nameText:SetJustifyH("LEFT")
    nameText:SetWordWrap(false)
    nameText:SetTextColor(1, 1, 1)
    row.nameText = nameText

    local rhText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    rhText:SetPoint("LEFT", row, "LEFT", NAME_WIDTH, 0)
    rhText:SetWidth(RH_WIDTH - 4)
    rhText:SetJustifyH("LEFT")
    rhText:SetWordWrap(false)
    rhText:SetTextColor(0.85, 0.85, 0.85)
    row.rhText = rhText

    local modText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    modText:SetPoint("LEFT", row, "LEFT", NAME_WIDTH + RH_WIDTH, 0)
    modText:SetWidth(MOD_WIDTH)
    modText:SetJustifyH("RIGHT")
    modText:SetWordWrap(false)
    row.modText = modText

    BR.MainRows[index] = row
    return row
end

function BR:RefreshMainWindowList()
    if not self.MainFrame or not self.MainContent then return end

    -- Hide existing rows
    for _, row in ipairs(self.MainRows) do
        row:Hide()
    end

    -- Collect entries sorted by name
    local entries = {}
    for _, entry in pairs(self.PlayerData) do
        table.insert(entries, entry)
    end
    table.sort(entries, function(a, b)
        return (a.name or ""):lower() < (b.name or ""):lower()
    end)

    local numRows = #entries
    self.MainContent:SetHeight(math.max(numRows * ROW_HEIGHT, 1))

    for i, entry in ipairs(entries) do
        local row = getOrCreateMainRow(i)
        row.nameText:SetText(entry.name or "")
        row.rhText:SetText(entry.raidHelperName ~= "" and entry.raidHelperName or "-")

        local mod = entry.rollModifier or 1
        local modStr
        if mod == math.floor(mod) then
            modStr = tostring(math.floor(mod))
        else
            modStr = string.format("%.2f", mod)
        end
        row.modText:SetText(modStr)

        -- Color modifier: green if >1, red if <1, white if =1
        if mod > 1 then
            row.modText:SetTextColor(0.573, 1, 0)
        elseif mod < 1 then
            row.modText:SetTextColor(1, 0.4, 0.4)
        else
            row.modText:SetTextColor(1, 1, 1)
        end

        row:Show()
    end

    if self.MainFrame.countText then
        if numRows == 0 then
            self.MainFrame.countText:SetText("No data imported yet.")
        elseif numRows == 1 then
            self.MainFrame.countText:SetText("1 player imported.")
        else
            self.MainFrame.countText:SetText(numRows .. " players imported.")
        end
    end
end
