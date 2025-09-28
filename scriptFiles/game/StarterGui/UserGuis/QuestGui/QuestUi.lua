local MainStorage = game:GetService("MainStorage")
local ClassMgr = require(MainStorage.Code.Untils.ClassMgr) ---@type ClassMgr
local ViewBase = require(MainStorage.Code.Client.UI.ViewBase) ---@type ViewBase
local ViewButton = require(MainStorage.Code.Client.UI.ViewButton) ---@type ViewButton
local ViewList = require(MainStorage.Code.Client.UI.ViewList) ---@type ViewList
local ClientEventManager = require(MainStorage.Code.Client.Event.ClientEventManager) ---@type ClientEventManager
local ConfigLoader = require(MainStorage.Code.Common.ConfigLoader) ---@type ConfigLoader
local gg = require(MainStorage.Code.Untils.MGlobal) ---@type gg

local uiConfig = {
    uiName = "QuestUi",
    layer = 3,
    hideOnInit = true,
}

---@class QuestUi:ViewBase
local QuestUi = ClassMgr.Class("QuestUi", ViewBase)

function QuestUi:OnInit(node, config)
    -- 初始化UI组件
    self:InitUIComponents()
    
    -- 注册事件
    self:RegisterEvents()
end

---初始化UI组件
function QuestUi:InitUIComponents()
    -- 关闭按钮
    self.CloseButton = self:Get("任务栏底图/关闭按钮", ViewButton) ---@type ViewButton
    
    -- 任务描述和进度
    -- self.QuestDesc = self:Get("描述").node ---@type UITextLabel
    -- self.QuestProgress = self:Get("进度").node ---@type UITextLabel
    
    -- 任务列表组件
    self.QuestLists = {} ---@type ViewButton[]
    self.QuestTemplatesList = self:Get("任务栏底图/任务栏模版", ViewList) ---@type ViewList
    self.QuestTemplatesList:SetVisible(false)
    self.QuestTemplates = self:Get("任务栏底图/任务栏模版/任务栏模版", ViewButton) ---@type ViewButton
    self.QuestListContainer = self:Get("任务栏底图/任务栏列表", ViewList) ---@type ViewList
    self.QuestListContainer:SetVisible(true)
    self.QuestTypes = {"战斗","收集","合作","生存"}
    -- 初始化各类任务栏
    self:InitQuestTypes()
end

---初始化任务类型UI
function QuestUi:InitQuestTypes()
    -- 循环预定义的任务类型
    for index, taskType in ipairs(self.QuestTypes) do
        -- 克隆任务模板
        local questTemplate = self.QuestTemplates.node:Clone()
        questTemplate.Name = taskType .. "任务栏"
        questTemplate.Parent = self.QuestListContainer.node
        

        -- 创建ViewButton包装器
        local questButton = ViewButton.New(questTemplate["任务图标"], self, questTemplate.Name)
        
        -- 存储到对应的数组中
        self.QuestLists[index] = questButton
        
        -- 设置任务类型相关数据（使用额外参数存储）
        questButton.extraParams = questButton.extraParams or {}
        questButton.extraParams.taskType = taskType
        questButton.extraParams.questIndex = index
        
        -- 尝试获取该类型的示例任务数据
        local TaskData = self:GetSampleTaskByType(taskType) ---@type TaskType|nil
        if TaskData then
            -- 装载任务数据到UI
            self:LoadTaskDataToUI(questTemplate, TaskData, index)
        end
        
        -- 注册点击事件（如果需要的话）
        -- 可以在这里添加其他UI元素的点击事件
    end
end

---根据任务类型获取示例任务
---@param taskType string 任务类型
---@return TaskType|nil 示例任务
function QuestUi:GetSampleTaskByType(taskType)
    -- 使用ConfigLoader.GetTasksBy获取指定类型和分类的任务
    local tasks = ConfigLoader.GetTasksBy(taskType, "每日")
    if tasks and #tasks > 0 then
        -- 返回第一个任务
        return tasks[1]
    end
    return nil
end

---将任务数据装载到UI
---@param questTemplate  ViewButton 任务按钮
---@param task TaskType 任务数据
---@param index number 任务索引
function QuestUi:LoadTaskDataToUI(questTemplate, task, index)
    -- 设置任务名称（如果有对应的UI元素）
    -- 这里可以根据实际的UI结构来设置任务相关信息
    -- 例如：questButton:Get("任务名称").node.Title = task.name
    
    -- 设置任务描述
    -- questButton:Get("任务描述").node.Title = task.description
    -- questTemplate.Title = task.name
    questTemplate["任务类型"].Title = task.taskType
    local questList = ViewList.New(questTemplate["任务列表"], self, questTemplate.Name) ---@type ViewList
    local taskIcon = questTemplate["任务图标"] 


    local completeConditions = task.completeConditionsEn
    questList:SetElementSize(#completeConditions)
    for i, completeCondition in ipairs(completeConditions) do
        local questItem = questList:GetChild(i) ---@type ViewButton
        questItem.node["描述"].Title = completeCondition["description"]
        questItem.node["进度"].Title = "0/"..completeCondition["compareValue"]

    end
end

---注册事件
function QuestUi:RegisterEvents()
    -- 关闭按钮事件
    if self.CloseButton then
        self.CloseButton.clickCb = function(ui, button)
            self:Close()
        end
    end
    
    -- 任务图标钻石按钮事件已在InitQuestTypes中注册
end

---任务奖励点击处理
---@param questIndex number 任务索引
function QuestUi:OnQuestRewardClick(questIndex)
    gg.log(string.format("任务%d奖励按钮被点击", questIndex))
    -- 发送任务奖励请求
    ClientEventManager.SendToServer("QuestReward", {
        questIndex = questIndex
    })
end

---显示任务描述
---@param description string 任务描述
function QuestUi:SetQuestDescription(description)
    -- if self.QuestDesc then
    --     self.QuestDesc.Title = description or ""
    -- end
end

---显示任务进度
---@param progress string 任务进度
function QuestUi:SetQuestProgress(progress)
    -- if self.QuestProgress then
    --     self.QuestProgress.Title = progress or ""
    -- end
end


return QuestUi.New(script.Parent, uiConfig)