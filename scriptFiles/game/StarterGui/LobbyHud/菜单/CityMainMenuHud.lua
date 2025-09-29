local MainStorage = game:GetService("MainStorage")
local ClassMgr = require(MainStorage.Code.Untils.ClassMgr) ---@type ClassMgr
local ViewBase = require(MainStorage.Code.Client.UI.ViewBase) ---@type ViewBase
local ViewButton = require(MainStorage.Code.Client.UI.ViewButton) ---@type ViewButton
local ClientEventManager = require(MainStorage.Code.Client.Event.ClientEventManager) ---@type ClientEventManager
local gg = require(MainStorage.Code.Untils.MGlobal) ---@type gg

local uiConfig = {
    uiName = "CityMainMenuHud",
    layer = -1,
    hideOnInit = false,
}

---@class CityMainMenuHud:ViewBase
local CityMainMenuHud = ClassMgr.Class("CityMainMenuHud", ViewBase)

function CityMainMenuHud:OnInit(node, config)
    -- 初始化按钮
    self.RoleButton = self:Get("职业界面", ViewButton) ---@type ViewButton
    self.AchievementButton = self:Get("成就界面", ViewButton) ---@type ViewButton
    self.QuestButton = self:Get("任务界面", ViewButton) ---@type ViewButton
    
    -- 设置按钮可见性
    self.RoleButton.img.Visible = true
    self.AchievementButton.img.Visible = true
    self.QuestButton.img.Visible = true
    
    -- 注册按钮事件
    self:RegisterButtonEvents()
    
    -- 注册场景切换事件
    self:RegisterSceneEvents()
end

---注册按钮点击事件
function CityMainMenuHud:RegisterButtonEvents()
    local function onButtonClick(buttonName)
        return function(ui, button)
            gg.log(string.format("'%s'按钮被点击", buttonName), button.node.Name)
            ClientEventManager.SendToServer("ClickMenu", {
                PageName = button.node.Name
            })
        end
    end
    
    -- 任务按钮特殊处理 - 直接打开 QuestUi
    self.QuestButton.clickCb = function(ui, button)
        gg.log("'任务'按钮被点击", button.node.Name)
        self:OpenQuestUi()
    end
    
    -- 职业按钮特殊处理 - 直接打开 RoleUi
    self.RoleButton.clickCb = function(ui, button)
        gg.log("'职业'按钮被点击", button.node.Name)
        self:OpenRoleUi()
    end
    
    -- 成就按钮特殊处理 - 直接打开 AchievementUi
    self.AchievementButton.clickCb = function(ui, button)
        gg.log("'成就'按钮被点击", button.node.Name)
        self:OpenAchievementUi()
    end
end

---打开任务界面
function CityMainMenuHud:OpenQuestUi()
    local QuestUi = ViewBase.GetUI("QuestUi")
    if QuestUi then
        QuestUi:Open()
        gg.log("任务界面已打开")
    else
        gg.log("错误：未找到 QuestUi 界面")
    end
end

---打开职业界面
function CityMainMenuHud:OpenRoleUi()
    local RoleUi = ViewBase.GetUI("RoleUi")
    if RoleUi then
        RoleUi:Open()
        gg.log("职业界面已打开")
    else
        gg.log("错误：未找到 RoleUi 界面")
    end
end

---打开成就界面
function CityMainMenuHud:OpenAchievementUi()
    local AchievementUi = ViewBase.GetUI("AchievementUi")
    if AchievementUi then
        AchievementUi:Open()
        gg.log("成就界面已打开")
    else
        gg.log("错误：未找到 AchievementUi 界面")
    end
end

---注册场景相关事件
function CityMainMenuHud:RegisterSceneEvents()
    -- 场景切换事件
    -- ClientEventManager.Subscribe("PlayerSwitchScene", function(evt)
    --     if evt.sceneType == common_const.SCENE_TYPE[1] then
    --         gg.client_scene_name = evt.name
    --         -- gg.client_scene_Type = evt.sceneType
    --         self:Open()
    --     else    
    --         self:Close()
    --     end
    -- end)
    
    -- 关闭城镇界面事件
    ClientEventManager.Subscribe("CloseCityHud", function(evt)
        self:Close()
    end)
end

return CityMainMenuHud.New(script.Parent, uiConfig)