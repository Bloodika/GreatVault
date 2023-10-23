local stillLoading = true
local tableContent
local CELL_WIDTH = 100
local CELL_HEIGHT = 20
local NUM_CELLS = 5 -- cells per row
local createRow = function(index)
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

local createCell = function(rowIndex, contents)
    for i=1, #contents do
        tableContent.rows[rowIndex].columns[i]:SetText(contents[i]);
    end
    tableContent.rows[rowIndex]:Show()
end

local frame = CreateFrame("Frame","Great Vault", UIParent, "BasicFrameTemplateWithInset")
frame:SetSize(CELL_WIDTH*NUM_CELLS+40,300)
frame:SetPoint("CENTER")
frame:SetMovable(true)
frame:Hide()
frame:SetScript("OnMouseDown",frame.StartMoving)
frame:SetScript("OnMouseUp",frame.StopMovingOrSizing)

local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
close:SetPoint("TOPRIGHT", frame, "TOPRIGHT")

local ff = CreateFrame("Button", nil, frame, "UIPanelButtonGrayTemplate")
ff:SetPoint("TOPLEFT", frame, "TOPLEFT")

frame.scrollFrame = CreateFrame("ScrollFrame",nil,frame,"UIPanelScrollFrameTemplate")
frame.scrollFrame:SetPoint("TOPLEFT",12,-32)
frame.scrollFrame:SetPoint("BOTTOMRIGHT",-34,8)

frame.scrollFrame.scrollChild = CreateFrame("Frame",nil,frame.scrollFrame)
frame.scrollFrame.scrollChild:SetSize(100,100)
frame.scrollFrame.scrollChild:SetPoint("TOPLEFT",5,-5)
frame.scrollFrame:SetScrollChild(frame.scrollFrame.scrollChild)

tableContent = frame.scrollFrame.scrollChild
tableContent.rows = {}
createRow(1)
createCell(1, {"Character","Realm","Mythic","Raid","PVP"})  

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

frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("WEEKLY_REWARDS_UPDATE")
frame:RegisterEvent("WEEKLY_REWARDS_ITEM_CHANGED")
frame:RegisterEvent("MYTHIC_PLUS_NEW_WEEKLY_RECORD")
frame:RegisterEvent("ADDON_LOADED");
frame:RegisterEvent("PLAYER_LOGOUT");
frame:SetScript("OnEvent",function(self, event, arg1)
    local loaded, finished = IsAddOnLoaded("GreatVault")
    if(event =="ADDON_LOADED" and arg1 == "GreatVault") then
        local realmName = GetRealmName()
        if(GreatVaultDatabase == nil) then
            GreatVaultDatabase = {}
        end
        if(not GreatVaultDatabase[realmName]) then
            GreatVaultDatabase[realmName] = {}
        end
        saveCurrentCharacter()
    elseif event == "PLAYER_LOGOUT" then
        saveCurrentCharacter()
    elseif event =="PLAYER_ENTERING_WORLD" then
        C_Timer.NewTicker(3,fillTableContent,1)
    elseif event == "WEEKLY_REWARDS_UPDATE" then
        if stillLoading then
            saveCurrentCharacter()
            C_Timer.NewTicker(3,fillTableContent, 1)
        end
    end
end
)

fillTableContent = function()
    local i = 1
    stillLoading = false
    for realmName,realmCharacters in pairs(GreatVaultDatabase) do
        for characterName, activity in pairs(realmCharacters) do
            createRow(i + 1)
            createCell(i + 1,{characterName, realmName, activity.mythic.."/3", activity.raid.."/3", activity.pvp.."/3"})
            i = i + 1
        end
    end
end
