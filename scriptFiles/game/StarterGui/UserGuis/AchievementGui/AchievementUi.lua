local MainStorage = game:GetService("MainStorage")
local ClassMgr = require(MainStorage.Code.Untils.ClassMgr) ---@type ClassMgr
local ViewBase = require(MainStorage.Code.Client.UI.ViewBase) ---@type ViewBase
local ViewButton = require(MainStorage.Code.Client.UI.ViewButton) ---@type ViewButton
local ViewList = require(MainStorage.Code.Client.UI.ViewList) ---@type ViewList
local ClientEventManager = require(MainStorage.Code.Client.Event.ClientEventManager) ---@type ClientEventManager
local ConfigLoader = require(MainStorage.Code.Common.ConfigLoader) ---@type ConfigLoader
local gg = require(MainStorage.Code.Untils.MGlobal) ---@type gg

local uiConfig = {
    uiName = "AchievementUi",
    layer = 3,
    hideOnInit = true,
}

---@class AchievementUi:ViewBase
local AchievementUi = ClassMgr.Class("AchievementUi", ViewBase)

function AchievementUi:OnInit(node, config)
    -- 初始化UI组件
    self:InitUIComponents()
    
    -- 注册事件
    self:RegisterEvents()
end

---初始化UI组件
function AchievementUi:InitUIComponents()
        -- 关闭按钮
    self.CloseButton = self:Get("成就底图/关闭按钮", ViewButton) ---@type ViewButton
    
    -- 展示图标相关组件
    self.ShowIcon = self:Get("成就底图/展示图标") ---@type ViewComponent
    self.ShowIconTitle = self:Get("成就底图/展示图标/称号") ---@type ViewComponent
    self.ShowIconDesc = self:Get("成就底图/展示图标/描述") ---@type ViewComponent
    self.ShowBtn = self:Get("成就底图/展示图标/展示按钮", ViewButton) ---@type ViewButton
    self.NotShowBtn = self:Get("成就底图/展示图标/卸下按钮", ViewButton) ---@type ViewButton
    
    -- 展示图标星星组件
    self.ShowIconStars = {}
    for i = 1, 5 do
        self.ShowIconStars[i] = {
            layer = self:Get("成就底图/展示图标/星星/星星底图_" .. i),
            star = self:Get("成就底图/展示图标/星星/星星底图_" .. i .. "/星星")
        }
    end
    
    -- 图标列表
    self.IconListTempList    = self:Get("成就底图/图标列表模版/", ViewList) ---@type ViewList
    self.IconListTempList:SetVisible(false)
    self.IconListTemp = self:Get("成就底图/图标列表模版/图标模版", ViewButton) ---@type ViewButton
    self.IconList = self:Get("成就底图/图标列表", ViewList) ---@type ViewList
    
    self.IconList:SetVisible(true)
    
    -- 选中底图
    self.SelectIcon = self:Get("选中底图") ---@type ViewComponent
    
    -- 成就图标模板
    self.IconTemplate = self:Get("图标", ViewButton) ---@type ViewButton
    self.IconTemplate:SetVisible(false)
    
    -- 成就图标列表
    self.AchievementIcons = {} ---@type ViewButton[]
    
    -- 初始化成就图标列表
    self:InitAchievementIcons()
end

---初始化成就图标列表
function AchievementUi:InitAchievementIcons()
    -- 获取成就配置数据
    local achievements = ConfigLoader.GetAchievementsBySort()
    if not achievements or #achievements == 0 then
        gg.log("警告：未找到成就配置数据")
        return
    end
    
    -- 设置图标列表大小
    self.IconList:SetElementSize(#achievements)
    
    -- 创建成就图标
    for index, achievement in ipairs(achievements) do
        local iconComponent = self.IconList:GetChild(index) ---@type ViewComponent
        if iconComponent then
            -- 创建ViewButton包装器
            local iconButton = ViewButton.New(iconComponent.node, self, iconComponent.path)
            
            -- 存储成就数据
            iconButton.extraParams = iconButton.extraParams or {}
            iconButton.extraParams.achievementId = achievement.achievementId
            iconButton.extraParams.achievement = achievement
            
            -- 装载成就数据到UI
            self:LoadAchievementDataToUI(iconButton, achievement)
            
            -- 存储到数组中
            self.AchievementIcons[index] = iconButton
        end
    end
end

---将成就数据装载到UI
---@param iconButton ViewButton 成就图标按钮
---@param achievement AchievementType 成就数据
function AchievementUi:LoadAchievementDataToUI(iconButton, achievement)
    -- 设置成就图标
    if iconButton.node["图标"] then
        iconButton.node["图标"].Image = achievement.icon or ""
    end
    
    -- 设置成就名称
    if iconButton.node["称号"] then
        iconButton.node["称号"].Title = achievement.name or ""
    end
    
    -- 设置成就描述
    if iconButton.node["描述"] then
        iconButton.node["描述"].Title = achievement.description or ""
    end
    
    -- 设置钻石奖励
    local gemReward = achievement:GetGemReward()
    if iconButton.node["钻石"] and iconButton.node["钻石"]["数量"] then
        iconButton.node["钻石"]["数量"].Title = tostring(gemReward)
    end
    
    -- 设置星星等级
    local starLevel = achievement.starLevel or 0
    for i = 1, 5 do
        local starLayer = iconButton.node["星星"]["星星底图_" .. i]
        local star = starLayer and starLayer["星星"]
        if starLayer and star then
            starLayer.Visible = i <= starLevel
        end
    end
end

---注册事件
function AchievementUi:RegisterEvents()
    -- 关闭按钮事件
    if self.CloseButton then
        self.CloseButton.clickCb = function(ui, button)
            self:Close()
        end
    end
    
    -- 展示按钮事件
    if self.ShowBtn then
        self.ShowBtn.clickCb = function(ui, button)
            self:OnShowAchievementClick()
        end
    end
    
    -- 卸下按钮事件
    if self.NotShowBtn then
        self.NotShowBtn.clickCb = function(ui, button)
            self:OnHideAchievementClick()
        end
    end
    
    -- 成就图标点击事件
    for _, iconButton in ipairs(self.AchievementIcons) do
        iconButton.clickCb = function(ui, button)
            self:OnAchievementIconClick(iconButton)
        end
    end
end

---成就图标点击处理
---@param iconButton ViewButton 被点击的图标按钮
function AchievementUi:OnAchievementIconClick(iconButton)
    local achievementId = iconButton.extraParams and iconButton.extraParams.achievementId
    local achievement = iconButton.extraParams and iconButton.extraParams.achievement
    
    if not achievementId or not achievement then
        gg.log("错误：成就数据缺失")
        return
    end
    
    gg.log(string.format("成就图标被点击：%s", achievement.name or achievementId))
    
    -- 更新展示图标
    self:UpdateShowIcon(achievement)
    
    -- 更新选中状态
    self:UpdateSelectedIcon(iconButton)
end

---更新展示图标
---@param achievement AchievementType 成就数据
function AchievementUi:UpdateShowIcon(achievement)
    -- 更新展示图标
    if self.ShowIcon and self.ShowIcon.node["图标"] then
        self.ShowIcon.node["图标"].Image = achievement.icon or ""
    end
    
    -- 更新称号
    if self.ShowIconTitle and self.ShowIconTitle.node then
        self.ShowIconTitle.node.Title = achievement.name or ""
    end
    
    -- 更新描述
    if self.ShowIconDesc and self.ShowIconDesc.node then
        self.ShowIconDesc.node.Title = achievement.description or ""
    end
    
    -- 更新星星等级
    local starLevel = achievement.starLevel or 0
    for i = 1, 5 do
        local starData = self.ShowIconStars[i]
        if starData.layer and starData.star then
            starData.layer.node.Visible = i <= starLevel
        end
    end
end

---更新选中图标状态
---@param selectedIcon ViewButton 选中的图标按钮
function AchievementUi:UpdateSelectedIcon(selectedIcon)
    -- 隐藏所有选中底图
    for _, iconButton in ipairs(self.AchievementIcons) do
        if iconButton.node["选中底图"] then
            iconButton.node["选中底图"].Visible = false
        end
    end
    
    -- 显示当前选中的底图
    if selectedIcon.node["选中底图"] then
        selectedIcon.node["选中底图"].Visible = true
    end
end

---展示成就点击处理
function AchievementUi:OnShowAchievementClick()
    gg.log("展示成就按钮被点击")
    -- 发送展示成就请求
    ClientEventManager.SendToServer("ShowAchievement", {
        action = "show"
    })
end

---卸下成就点击处理
function AchievementUi:OnHideAchievementClick()
    gg.log("卸下成就按钮被点击")
    -- 发送卸下成就请求
    ClientEventManager.SendToServer("ShowAchievement", {
        action = "hide"
    })
end

---设置当前展示的成就
---@param achievementId string 成就ID
function AchievementUi:SetCurrentAchievement(achievementId)
    -- 查找对应的成就图标
    for _, iconButton in ipairs(self.AchievementIcons) do
        if iconButton.extraParams and iconButton.extraParams.achievementId == achievementId then
            local achievement = iconButton.extraParams.achievement
            if achievement then
                self:UpdateShowIcon(achievement)
                self:UpdateSelectedIcon(iconButton)
                return
            end
        end
    end
    
    gg.log(string.format("警告：未找到成就ID %s", achievementId))
end

return AchievementUi.New(script.Parent, uiConfig)