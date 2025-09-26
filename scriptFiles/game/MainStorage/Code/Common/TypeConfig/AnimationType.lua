local MainStorage = game:GetService('MainStorage')
local ClassMgr = require(MainStorage.Code.Untils.ClassMgr) ---@type ClassMgr
local MConfig = require(MainStorage.Code.Common.GameConfig.MConfig) ---@type common_config

--- 动画类型（与 AnimationConfigConfig 字段对齐）
---@class AnimationType:Class
---@field name string 名字
---@field description string 描述
---@field characterName string 角色名称
---@field initialState string 初始状态
---@field animationConfigs table[] 动画播放配置（原始）
---@field animationConfigsEn table[] 动画播放配置（英文结构）
---@field New fun(data:table):AnimationType
local AnimationType = ClassMgr.Class("AnimationType")

--- 初始化（读取 AnimationConfigConfig 字段）
---@param data table
function AnimationType:OnInit(data)
	-- 基本信息
	self.name = data["名字"] or "Unknown Animation"
	self.description = data["描述"] or ""
	self.characterName = data["角色名称"] or ""
	self.initialState = data["初始状态"] or ""

	-- 动画配置
	self.animationConfigs = data["动画播放配置"] or {}
	self.animationConfigsEn = self:__buildAnimationConfigsEn(self.animationConfigs)
end

--- 获取动画配置列表（原始）
---@return table[]
function AnimationType:GetAnimationConfigs()
	return self.animationConfigs
end

--- 获取动画配置列表（英文结构）
---@return table[]
function AnimationType:GetAnimationConfigsEn()
	return self.animationConfigsEn
end

--- 根据名称查找动画配置
---@param configName string 配置名称
---@return table|nil
function AnimationType:FindAnimationConfig(configName)
	for _, config in ipairs(self.animationConfigs) do
		if config["名称"] == configName then
			return config
		end
	end
	return nil
end

--- 根据动画名称查找配置
---@param animationName string 动画名称
---@return table|nil
function AnimationType:FindConfigByAnimationName(animationName)
	for _, config in ipairs(self.animationConfigs) do
		if config["动画名称"] == animationName then
			return config
		end
	end
	return nil
end

--- 构建动画配置英文结构
---@param configs table[]
---@return table[]
function AnimationType:__buildAnimationConfigsEn(configs)
	local result = {}
	for _, config in ipairs(configs) do
		table.insert(result, {
			name = config["名称"] or "",
			animationName = config["动画名称"] or "",
			playMode = config["播放模式"] or "",
			playTime = config["播放时间"] or 0,
			playTrigger = config["播放时机"] or "",
			effectTriggerTime = config["触发效果时间"] or 0,
		})
	end
	return result
end

return AnimationType
