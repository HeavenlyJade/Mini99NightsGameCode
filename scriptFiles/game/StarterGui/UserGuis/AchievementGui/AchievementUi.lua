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
    self.ShowIcon:SetVisible(false)
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
    self.IconTemplate = self:Get("成就底图/图标列表模版/图标模版", ViewButton) ---@type ViewButton
    self.IconList = self:Get("成就底图/图标列表", ViewList) ---@type ViewList
    
    self.IconList:SetVisible(true)
    
    -- 成就图标列表
    self.AchievementIcons = {} ---@type ViewButton[]
    
    -- 初始化成就图标列表
    self:InitAchievementIcons()
end

---初始化成就图标列表
function AchievementUi:InitAchievementIcons()
    -- 获取所有成就配置数据
    local allAchievements = ConfigLoader.GetAllAchievements()
    if not allAchievements then
        gg.log("警告：未找到成就配置数据")
        return
    end
    
    -- 转换为数组并按权重（排序）从小到大排序
    local achievements = {}
    for _, achievement in pairs(allAchievements) do
        table.insert(achievements, achievement)
    end
    
    -- 按排序字段排序（从小到大）
    table.sort(achievements, function(a, b)
        return a:GetSortKey() < b:GetSortKey()
    end)
    
    if #achievements == 0 then
        gg.log("警告：成就配置数据为空")
        return
    end
    
    -- 清空现有成就图标
    self.AchievementIcons = {}
    
    -- 创建成就图标
    for index, achievement in ipairs(achievements) do
        -- 克隆IconTemplate
        local clonedTemplate = self.IconTemplate.node:Clone()
        clonedTemplate.Name = "成就图标_" .. index
        
        -- 设置IconList为父类
        clonedTemplate:SetParent(self.IconList.node)
        
        -- 获取图标子节点进行ViewButton绑定
        local iconNode = clonedTemplate["图标"]
        -- 创建ViewButton包装器，绑定到图标子节点
        local iconButton = ViewButton.New(iconNode, self, self.IconList.path .. "/" .. clonedTemplate.Name .. "/图标")
        
        -- 存储成就数据
        iconButton.extraParams = iconButton.extraParams or {}
        iconButton.extraParams.achievementId = achievement.achievementId
        iconButton.extraParams.achievement = achievement
        
        -- 绑定点击事件
        iconButton.clickCb = function(ui, button)
            self:OnAchievementIconClick(iconButton)
        end
        
        -- 装载成就数据到UI
        self:LoadAchievementDataToUI(clonedTemplate, achievement)
        
        -- 存储到数组中
        self.AchievementIcons[index] = iconButton
     
    end
    
    -- 默认选择第一个成就进行展示
    if #self.AchievementIcons > 0 then
        local firstIconButton = self.AchievementIcons[1]
        local firstAchievement = firstIconButton.extraParams and firstIconButton.extraParams.achievement
        if firstAchievement then
            self:UpdateShowIcon(firstAchievement)
            self:UpdateSelectedIcon(firstIconButton)
            gg.log(string.format("默认展示第一个成就：%s", firstAchievement.name or "未知"))
        end
    end
    
    gg.log(string.format("成就图标列表初始化完成，共加载 %d 个成就", #achievements))
end

---将成就数据装载到UI
---@param templateNode ViewButton 成就模板节点
---@param achievement AchievementType 成就数据
function AchievementUi:LoadAchievementDataToUI(templateNode, achievement)
    
    -- 设置成就图标
    templateNode["图标"].Icon = achievement.icon or ""
    
    local gemReward = achievement:GetGemReward()
    if templateNode["图标"]["钻石"] and templateNode["图标"]["钻石"]["数量"] then
        templateNode["图标"]["钻石"]["数量"].Title = tostring(gemReward)
    end
    
    -- 设置星星等级
    local starLevel = achievement.starLevel or 0
    for i = 1, 5 do
        local starLayer = templateNode["星星"]["星星底图_" .. i]
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
    -- 显示展示图标区域
    if self.ShowIcon then
        self.ShowIcon:SetVisible(true)
    end
    
    -- 更新展示图标
    if self.ShowIcon and self.ShowIcon.node["图标"] then
        self.ShowIcon.node["图标"].Image = achievement.icon or ""
    end
    
    -- 更新称号（展示的名称）
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
    
    gg.log(string.format("展示成就：%s - %s", achievement.name or "未知", achievement.description or "无描述"))
end

---更新选中图标状态
---@param selectedIcon ViewButton 选中的图标按钮
function AchievementUi:UpdateSelectedIcon(selectedIcon)
    -- 隐藏所有选中底图
    for _, iconButton in ipairs(self.AchievementIcons) do
        local templateNode = iconButton.node.Parent
        if templateNode["选中底图"] then
            templateNode["选中底图"].Visible = false
        end
    end
    
    -- 显示当前选中的底图
    local selectedTemplateNode = selectedIcon.node.Parent
    if selectedTemplateNode["选中底图"] then
        selectedTemplateNode["选中底图"].Visible = true
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