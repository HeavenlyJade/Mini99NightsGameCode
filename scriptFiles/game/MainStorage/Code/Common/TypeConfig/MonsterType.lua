local MainStorage = game:GetService('MainStorage')
local ClassMgr = require(MainStorage.Code.Untils.ClassMgr) ---@type ClassMgr
local MConfig = require(MainStorage.Code.Common.GameConfig.MConfig) ---@type common_config

--- 怪物类型（与 MonsterConfigConfig 字段对齐）
---@class MonsterType:Class
---@field name string 名字
---@field displayName string 显示名
---@field description string 描述
---@field modelRes string 模型资源
---@field animationRes string 动画资源
---@field modelCache string 模型缓存
---@field animator string 动画状态机
---@field monsterCategory string 怪物类型
---@field showHpBar boolean 是否显示血条
---@field rawAttributes table[] 属性配置（原始）
---@field attributesEn table[] 属性配置（英文结构） { attribute:string, value:number, mode:string }
---@field behaviors table[] 行为列表（原始）
---@field behaviorsEn table[] 行为列表（英文结构） { logic:string, weight:number, playAnimationName:string }
---@field skillConfigs string[] 技能配置列表（技能名）
---@field dropItems table[] 死亡掉落列表（原始）
---@field dropItemsEn table[] 死亡掉落列表（英文结构） { item:string, quantity:number, probability:number, effectType:string }
---@field New fun(data:table):MonsterType
local MonsterType = ClassMgr.Class("MonsterType")

--- 初始化（读取 MonsterConfigConfig 字段）
---@param data table
function MonsterType:OnInit(data)
	-- 基础信息
	self.name = data["名字"] or "Unknown Monster"
	self.displayName = data["显示名"] or self.name
	self.description = data["描述"] or ""

	-- 资源与动画
	self.modelRes = data["模型资源"] or ""
	self.animationRes = data["动画资源"] or ""
	self.modelCache = data["模型缓存"] or ""
	self.animator = data["动画状态机"] or ""

	-- 分类与显示
	self.monsterCategory = data["怪物类型"] or ""
	self.showHpBar = data["是否显示血条"] or false

	-- 属性配置
	self.rawAttributes = data["属性配置"] or {}
	self.attributesEn = self:__buildAttributesEn(self.rawAttributes)

	-- 行为列表
	self.behaviors = data["行为列表"] or {}
	self.behaviorsEn = self:__buildBehaviorsEn(self.behaviors)

	-- 技能配置
	self.skillConfigs = data["技能配置列表"] or {}

	-- 掉落
	self.dropItems = data["死亡掉落列表"] or {}
	self.dropItemsEn = self:__buildDropItemsEn(self.dropItems)
end

--- 获取英文属性配置
---@return table[]
function MonsterType:GetAttributesEn()
	return self.attributesEn
end

--- 获取英文行为配置
---@return table[]
function MonsterType:GetBehaviorsEn()
	return self.behaviorsEn
end

--- 获取技能名称列表
---@return string[]
function MonsterType:GetSkillNames()
	return self.skillConfigs
end

--- 获取掉落（英文）
---@return table[]
function MonsterType:GetDropItemsEn()
	return self.dropItemsEn
end

--- 构建属性英文结构
---@param list table[]
---@return table[]
function MonsterType:__buildAttributesEn(list)
	local result = {}
	for _, it in ipairs(list) do
		table.insert(result, {
			attribute = it["属性"] or "",
			value = it["数值"] or 0,
			mode = it["作用方式"] or "",
		})
	end
	return result
end

--- 构建行为英文结构
---@param list table[]
---@return table[]
function MonsterType:__buildBehaviorsEn(list)
	local result = {}
	for _, it in ipairs(list) do
		table.insert(result, {
			logic = it["行为逻辑"] or "",
			weight = it["权重"] or 0,
			playAnimationName = it["播放动画名称"] or "",
		})
	end
	return result
end

--- 构建掉落英文结构
---@param items table[]
---@return table[]
function MonsterType:__buildDropItemsEn(items)
	local result = {}
	for _, item in ipairs(items) do
		table.insert(result, {
			item = item["物品"] or "",
			quantity = item["数量"] or 0,
			probability = item["概率"] or 0,
			effectType = item["作用方式"] or "",
		})
	end
	return result
end

return MonsterType


