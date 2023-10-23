local headerRows = {"Character","Level","Class","Realm","Mythic","Raid","PVP"}
local stillLoading = true
local tableContent
local CELL_WIDTH = 100
local CELL_HEIGHT = 20
local NUM_CELLS = #headerRows
local frame;

local GreatVault_createRow = function(index)
    local row = CreateFrame("Button",nil, tableContent)
    row:SetSize(CELL_WIDTH*NUM_CELLS,CELL_HEIGHT)
    row:SetPoint("TOPLEFT",0,-(index-1)*CELL_HEIGHT)
    row.columns = {}
    for j=1,NUM_CELLS do
        row.columns[j] = row:CreateFontString(nil, "ARTWORK","GameFontHighlight")
        row.columns[j]:SetPoint("LEFT",(j-1)*CELL_WIDTH,0)
    end
    tableContent.rows[index] = row
end

local GreatVault_createCells = function(rowIndex, contents)
    for i=1, #contents do
        tableContent.rows[rowIndex].columns[i]:SetText(contents[i]);
    end
    tableContent.rows[rowIndex]:Show()
end

local function GreatVault_createFrame()
    frame = CreateFrame("Frame","Great Vault", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(CELL_WIDTH*NUM_CELLS+40,300)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:Hide()
    frame:SetScript("OnMouseDown",frame.StartMoving)
    frame:SetScript("OnMouseUp",frame.StopMovingOrSizing)
    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", frame, "TOPRIGHT")
end

local function GreatVault_createScrollFrame()
    frame.scrollFrame = CreateFrame("ScrollFrame",nil,frame,"UIPanelScrollFrameTemplate")
    frame.scrollFrame:SetPoint("TOPLEFT",12,-32)
    frame.scrollFrame:SetPoint("BOTTOMRIGHT",-34,8)
    frame.scrollFrame.scrollChild = CreateFrame("Frame",nil,frame.scrollFrame)
    frame.scrollFrame.scrollChild:SetSize(100,100)
    frame.scrollFrame.scrollChild:SetPoint("TOPLEFT",5,-5)
    frame.scrollFrame:SetScrollChild(frame.scrollFrame.scrollChild)
end

local function GreatVault_createContent()
    tableContent = frame.scrollFrame.scrollChild
    tableContent.rows = {}
end

local function GreatVault_createHeaderRow()
    GreatVault_createRow(1)
    GreatVault_createCells(1, headerRows)  
end

local function GreatVault_createMinimapIcon()
    local ldb = LibStub:GetLibrary('LibDataBroker-1.1')
    local LDBIcon = ldb and LibStub("LibDBIcon-1.0", true)
    local minimapIcon = ldb:NewDataObject('GreatVault', {
        type = 'data source',
        label = 'Great Vault',
        text = 'Great Vault',
        tocname = "GreatVault",
        icon = "Interface\\Addons\\GreatVault\\icon.BLP",
        OnClick = function(clickedframe,button)
            if frame:IsShown() then
                frame:Hide()
            else
                frame:Show()
            end
            
        end,
    })
    LDBIcon:Register("GreatVault", minimapIcon, nil)
end

local function GreatVault_handleEvents(self, event, arg1)
    if(event =="ADDON_LOADED" and arg1 == "GreatVault") then
        local realmName = GetRealmName()
        if(GreatVaultDatabase == nil) then
            GreatVaultDatabase = {}
        end
        if(not GreatVaultDatabase[realmName]) then
            GreatVaultDatabase[realmName] = {}
        end
        GreatVault_saveCurrentCharacter()
    elseif event == "PLAYER_LOGOUT" then
        GreatVault_saveCurrentCharacter()
    elseif event =="PLAYER_ENTERING_WORLD" then
        C_Timer.NewTicker(3,GreatVault_fillTableContent,1)
    elseif event == "WEEKLY_REWARDS_UPDATE" then
        if stillLoading then
            GreatVault_saveCurrentCharacter()
            C_Timer.NewTicker(3,GreatVault_fillTableContent, 1)
        end
    end 
end

local function GreatVault_registerEvents()
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:RegisterEvent("WEEKLY_REWARDS_UPDATE")
    frame:RegisterEvent("WEEKLY_REWARDS_ITEM_CHANGED")
    frame:RegisterEvent("MYTHIC_PLUS_NEW_WEEKLY_RECORD")
    frame:RegisterEvent("ADDON_LOADED");
    frame:RegisterEvent("PLAYER_LOGOUT");
    frame:SetScript("OnEvent",GreatVault_handleEvents)
end

GreatVault_fillTableContent = function()
    local i = 1
    stillLoading = false
    for realmName,realmCharacters in pairs(GreatVaultDatabase) do
        for characterName, characterInfo in pairs(realmCharacters) do
            GreatVault_createRow(i + 1)
            GreatVault_createCells(i + 1,{characterName,characterInfo.level, characterInfo.className,realmName, characterInfo.mythic.."/3", characterInfo.raid.."/3", characterInfo.pvp.."/3"})
            i = i + 1
        end
    end
end

GreatVault_createFrame()
GreatVault_createScrollFrame()
GreatVault_createMinimapIcon()
GreatVault_createContent()
GreatVault_createHeaderRow()
GreatVault_registerEvents()