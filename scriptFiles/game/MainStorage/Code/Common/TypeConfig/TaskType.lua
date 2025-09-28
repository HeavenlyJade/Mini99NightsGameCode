local MainStorage = game:GetService('MainStorage')
local ClassMgr = require(MainStorage.Code.Untils.ClassMgr) ---@type ClassMgr

--- 任务类型（与 TaskConfigConfig 字段对齐）
---@class TaskType:Class
---@field taskId string 任务ID
---@field name string 名称
---@field description string 描述
---@field taskType string 任务类型
---@field taskCategory string 任务分类
---@field priority number 优先级
---@field acceptConditions table[] 接取条件
---@field completeConditions table[] 完成条件
---@field completeConditionsEn table[] 完成条件（英文结构）
---@field taskLocation number[] 任务地点
---@field npcLocation number[] NPC地点
---@field rewards table[] 完成奖励
---@field rewardsEn table[] 完成奖励（英文结构）
---@field completeCommands table[] 完成执行相关指令
---@field timeLimit number 任务时限
---@field cooldownTime number 冷却时间
---@field icon string 图标
---@field hintText string 提示文本
---@field completeText string 完成文本
---@field New fun(data:table):TaskType
local TaskType = ClassMgr.Class("TaskType")

--- 初始化（读取 TaskConfigConfig 字段）
---@param data table
function TaskType:OnInit(data)
	-- 基本信息
	self.taskId = data["任务ID"] or ""
	self.name = data["名称"] or "Unknown Task"
	self.description = data["描述"] or ""
	self.taskType = data["任务类型"] or ""
	self.taskCategory = data["任务分类"] or ""
	self.priority = data["优先级"] or 0

	-- 条件配置
	self.acceptConditions = data["接取条件"] or {}
	self.completeConditions = data["完成条件"] or {}
	self.completeConditionsEn = self:__buildCompleteConditionsEn(self.completeConditions)

	-- 位置信息
	self.taskLocation = data["任务地点"] or { 0, 0, 0 }
	self.npcLocation = data["NPC地点"] or { 0, 0, 0 }

	-- 奖励和指令
	self.rewards = data["完成奖励"] or {}
	self.rewardsEn = self:__buildRewardsEn(self.rewards)
	self.completeCommands = data["完成执行相关指令"] or {}

	-- 时间相关
	self.timeLimit = data["任务时限"] or 0
	self.cooldownTime = data["冷却时间"] or 0

	-- 文本信息
	self.icon = data["图标"] or ""
	self.hintText = data["提示文本"] or ""
	self.completeText = data["完成文本"] or ""
end

--- 构建完成条件的英文结构
---@param rawConditions table[] 原始完成条件数据
---@return table[] 英文结构完成条件数据
function TaskType:__buildCompleteConditionsEn(rawConditions)
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

--- 构建奖励的英文结构
---@param rawRewards table[] 原始奖励数据
---@return table[] 英文结构奖励数据
function TaskType:__buildRewardsEn(rawRewards)
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

--- 是否为每日任务
---@return boolean
function TaskType:IsDailyTask()
	return self.taskCategory == "每日"
end

--- 是否为收集任务
---@return boolean
function TaskType:IsCollectTask()
	return self.taskType == "收集"
end

--- 获取完成条件（按变量类型筛选）
---@param variableType string 变量类型
---@return table[]
function TaskType:GetCompleteConditionsByType(variableType)
	local result = {}
	for _, condition in ipairs(self.completeConditions) do
		if condition["变量类型"] == variableType then
			table.insert(result, condition)
		end
	end
	return result
end

--- 获取完成条件的描述信息
---@param conditionIndex number 条件索引（可选，不传则返回所有条件的描述）
---@return string|table[] 单个描述或描述列表
function TaskType:GetCompleteConditionDescription(conditionIndex)
	if conditionIndex then
		local condition = self.completeConditions[conditionIndex]
		return condition and condition["描述"] or ""
	end
	
	local descriptions = {}
	for _, condition in ipairs(self.completeConditions) do
		table.insert(descriptions, condition["描述"] or "")
	end
	return descriptions
end

--- 根据描述查找完成条件
---@param description string 描述文本
---@return table|nil 匹配的条件
function TaskType:FindCompleteConditionByDescription(description)
	for _, condition in ipairs(self.completeConditions) do
		if condition["描述"] == description then
			return condition
		end
	end
	return nil
end

--- 获取英文结构的完成条件数据
---@return table[] 英文结构完成条件列表
function TaskType:GetCompleteConditionsEn()
	return self.completeConditionsEn
end

--- 根据变量类型获取完成条件
---@param variableType string 变量类型
---@return table[] 匹配的完成条件列表
function TaskType:GetCompleteConditionsByTypeEn(variableType)
	local result = {}
	for _, condition in ipairs(self.completeConditionsEn) do
		if condition.variableType == variableType then
			table.insert(result, condition)
		end
	end
	return result
end

--- 获取玩家变量类型的完成条件
---@return table[] 玩家变量类型的完成条件列表
function TaskType:GetPlayerVariableConditions()
	return self:GetCompleteConditionsByTypeEn("玩家变量")
end

--- 获取英文结构的奖励数据
---@return table[] 英文结构奖励列表
function TaskType:GetRewardsEn()
	return self.rewardsEn
end

--- 根据奖励类型获取奖励
---@param rewardType string 奖励类型
---@return table[] 匹配的奖励列表
function TaskType:GetRewardsByType(rewardType)
	local result = {}
	for _, reward in ipairs(self.rewardsEn) do
		if reward.rewardType == rewardType then
			table.insert(result, reward)
		end
	end
	return result
end

--- 获取物品奖励
---@return table[] 物品奖励列表
function TaskType:GetItemRewards()
	return self:GetRewardsByType("物品")
end

--- 获取显示用的参数
function TaskType:GetToStringParams()
	return { 
		taskId = self.taskId,
		name = self.name,
		taskType = self.taskType
	}
end

return TaskType
