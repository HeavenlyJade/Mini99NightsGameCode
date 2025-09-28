local MainStorage = game:GetService('MainStorage')
local ClassMgr = require(MainStorage.Code.Untils.ClassMgr) ---@type ClassMgr

--- 成就类型（与 AchievementConfigConfig 字段对齐）
---@class AchievementType:Class
---@field achievementId string 成就ID
---@field name string 名称
---@field description string 描述
---@field sortOrder number 排序
---@field starLevel number 星级
---@field icon string 图标
---@field unlockConditions table[] 解锁条件
---@field unlockConditionsEn table[] 解锁条件（英文结构）
---@field unlockRewards table[] 解锁奖励
---@field unlockRewardsEn table[] 解锁奖励（英文结构）
---@field New fun(data:table):AchievementType
local AchievementType = ClassMgr.Class("AchievementType")

--- 初始化（读取 AchievementConfigConfig 字段）
---@param data table
function AchievementType:OnInit(data)
    -- 基本信息
    self.achievementId = data["成就ID"] or ""
    self.name = data["名字"] or "Unknown Achievement"
    self.description = data["描述"] or ""
    self.sortOrder = data["排序"] or 0
    self.starLevel = data["星级"] or 1
    self.icon = data["图标"] or ""
    
    -- 解锁条件
    self.unlockConditions = data["解锁条件"] or {}
    self.unlockConditionsEn = self:__buildUnlockConditionsEn(self.unlockConditions)
    
    -- 解锁奖励
    self.unlockRewards = data["解锁奖励"] or {}
    self.unlockRewardsEn = self:__buildUnlockRewardsEn(self.unlockRewards)
end

--- 构建解锁条件英文结构
---@param rawConditions table[] 原始解锁条件
---@return table[] 英文结构解锁条件
function AchievementType:__buildUnlockConditionsEn(rawConditions)
    local result = {}
    for _, condition in ipairs(rawConditions) do
        table.insert(result, {
            variableType = condition["变量类型"] or "",
            variableName = condition["变量名称"] or "",
            conditionType = condition["条件类型"] or "",
            compareValue = condition["比较值"] or 0,
            description = condition["描述"] or ""
        })
    end
    return result
end

--- 构建解锁奖励英文结构
---@param rawRewards table[] 原始解锁奖励
---@return table[] 英文结构解锁奖励
function AchievementType:__buildUnlockRewardsEn(rawRewards)
    local result = {}
    for _, reward in ipairs(rawRewards) do
        table.insert(result, {
            rewardType = reward["奖励类型"] or "",
            itemName = reward["物品名称"] or "",
            itemCount = reward["物品数量"] or 0,
            variableName = reward["变量名称"] or "",
            value = reward["数值"] or 0,
            description = reward["描述"] or ""
        })
    end
    return result
end

--- 检查成就是否满足解锁条件
---@param playerData table 玩家数据
---@return boolean 是否满足解锁条件
function AchievementType:CheckUnlockConditions(playerData)
    for _, condition in ipairs(self.unlockConditionsEn) do
        if not self:__checkSingleCondition(condition, playerData) then
            return false
        end
    end
    return true
end

--- 检查单个解锁条件
---@param condition table 解锁条件
---@param playerData table 玩家数据
---@return boolean 是否满足条件
function AchievementType:__checkSingleCondition(condition, playerData)
    local variableName = condition.variableName
    local compareValue = condition.compareValue
    local conditionType = condition.conditionType
    
    if not variableName or variableName == "" then
        return true
    end
    
    local currentValue = playerData[variableName] or 0
    
    if conditionType == "大于等于" then
        return currentValue >= compareValue
    elseif conditionType == "大于" then
        return currentValue > compareValue
    elseif conditionType == "等于" then
        return currentValue == compareValue
    elseif conditionType == "小于等于" then
        return currentValue <= compareValue
    elseif conditionType == "小于" then
        return currentValue < compareValue
    end
    
    return false
end

--- 获取成就的钻石奖励数量
---@return number 钻石奖励数量
function AchievementType:GetGemReward()
    for _, reward in ipairs(self.unlockRewardsEn) do
        if reward.rewardType == "物品" and reward.itemName == "钻石" then
            return reward.itemCount or 0
        end
    end
    return 0
end

--- 获取成就的变量奖励
---@return table[] 变量奖励列表
function AchievementType:GetVariableRewards()
    local result = {}
    for _, reward in ipairs(self.unlockRewardsEn) do
        if reward.rewardType == "变量" and reward.variableName ~= "" then
            table.insert(result, {
                variableName = reward.variableName,
                value = reward.value or 0,
                description = reward.description
            })
        end
    end
    return result
end

--- 获取成就的星级显示文本
---@return string 星级显示文本
function AchievementType:GetStarLevelText()
    return tostring(self.starLevel) .. "星"
end

--- 获取成就的排序键（用于排序）
---@return number 排序键
function AchievementType:GetSortKey()
    return self.sortOrder
end

return AchievementType
