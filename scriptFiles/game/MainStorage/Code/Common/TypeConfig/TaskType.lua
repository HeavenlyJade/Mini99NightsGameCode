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
---@field taskLocation number[] 任务地点
---@field npcLocation number[] NPC地点
---@field rewards table[] 完成奖励
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

	-- 位置信息
	self.taskLocation = data["任务地点"] or { 0, 0, 0 }
	self.npcLocation = data["NPC地点"] or { 0, 0, 0 }

	-- 奖励和指令
	self.rewards = data["完成奖励"] or {}
	self.completeCommands = data["完成执行相关指令"] or {}

	-- 时间相关
	self.timeLimit = data["任务时限"] or 0
	self.cooldownTime = data["冷却时间"] or 0

	-- 文本信息
	self.icon = data["图标"] or ""
	self.hintText = data["提示文本"] or ""
	self.completeText = data["完成文本"] or ""
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

--- 获取显示用的参数
function TaskType:GetToStringParams()
	return { 
		taskId = self.taskId,
		name = self.name,
		taskType = self.taskType
	}
end

return TaskType
