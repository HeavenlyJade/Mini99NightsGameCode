local MainStorage = game:GetService('MainStorage')
local ClassMgr = require(MainStorage.Code.Untils.ClassMgr) ---@type ClassMgr
local MConfig = require(MainStorage.Code.Common.GameConfig.MConfig) ---@type common_config

--- 技能类型（与 SkillConfigConfig 字段对齐）
---@class SkillType:Class
---@field name string 技能名称
---@field displayName string 显示名称
---@field maxLevel number 技能最大等级
---@field maxStar number 最大星级
---@field icon string 图标
---@field quality string 品级
---@field skillCategory string 技能类型
---@field bindBuffs string[] buff绑定列表
---@field targets string[] 作用目标
---@field castVfx string 释放特效
---@field castRange number 施法距离
---@field indicatorRadius number 指示器半径
---@field damage table 技能伤害组成（原始）
---@field damageEn table 技能伤害组成（英文结构）
---@field damageType any 伤害类型
---@field attributeConfig table[] 属性配置
---@field dropItems table[] 掉落物品列表（原始）
---@field dropItemsEn table[] 掉落物品列表（英文结构）
---@field cooldownFormula string 冷却时间公式
---@field precheckCosts table[] 消耗前置检查
---@field costConfig table[] 消耗配置
---@field upgradeReqs table[] 技能升级需求列表（原始）
---@field upgradeReqsEn table[] 技能升级需求列表（英）
---@field starReqs table[] 技能升星需求列表（原始）
---@field starReqsEn table[] 技能升星需求列表（英）
---@field New fun(data:table):SkillType
local SkillType = ClassMgr.Class("SkillType")

--- 初始化（读取 SkillConfigConfig 字段）
---@param data table
function SkillType:OnInit(data)
	-- 基本信息
	self.name = data["技能名称"] or "Unknown Skill"
	self.displayName = data["显示名称"] or self.name
	self.maxLevel = data["技能最大等级"] or 1
	self.maxStar = data["最大星级"] or 0
	self.icon = data["图标"] or ""
	self.quality = data["品级"] or ""
	self.skillCategory = data["技能类型"] or ""

	-- 绑定/目标/表现
	self.bindBuffs = data["buff绑定列表"] or {}
	self.targets = data["作用目标"] or {}
	self.castVfx = data["释放特效"] or ""
	self.castRange = data["施法距离"] or 0
	self.indicatorRadius = data["指示器半径"] or 0

	-- 伤害
	self.damage = data["技能伤害组成"] or {}
	self.damageEn = self:__buildDamageEn(self.damage)
	self.damageType = data["伤害类型"]

	-- 属性配置
	self.attributeConfig = data["属性配置"] or {}

	-- 掉落物品
	self.dropItems = data["掉落物品列表"] or {}
	self.dropItemsEn = self:__buildDropItemsEn(self.dropItems)

	-- 冷却与消耗
	self.cooldownFormula = data["冷却时间公式"] or ""
	self.precheckCosts = data["消耗前置检查"] or {}
	self.costConfig = data["消耗配置"] or {}

	-- 需求
	self.upgradeReqs = data["技能升级需求列表"] or {}
	self.upgradeReqsEn = self:__buildReqsEn(self.upgradeReqs)
	self.starReqs = data["技能升星需求列表"] or {}
	self.starReqsEn = self:__buildReqsEn(self.starReqs)
end

--- 获取英文伤害结构
---@return table
function SkillType:GetDamageEn()
	return self.damageEn
end

--- 获取英文升级需求
---@return table[]
function SkillType:GetUpgradeReqsEn()
	return self.upgradeReqsEn
end

--- 获取英文升星需求
---@return table[]
function SkillType:GetStarReqsEn()
	return self.starReqsEn
end

--- 获取属性配置
---@return table[]
function SkillType:GetAttributeConfig()
	return self.attributeConfig
end

--- 获取掉落物品列表（原始）
---@return table[]
function SkillType:GetDropItems()
	return self.dropItems
end

--- 获取掉落物品列表（英文结构）
---@return table[]
function SkillType:GetDropItemsEn()
	return self.dropItemsEn
end

--- 构建伤害英文结构
---@param dmg table
---@return table
function SkillType:__buildDamageEn(dmg)
	return {
		baseDamage = dmg and dmg["基础伤害"] or 0,
		levelDamageFormula = dmg and dmg["等级伤害"] or "",
		otherBonusFormula = dmg and dmg["其它加成公式"] or "",
		additionalDamageFormulas = dmg and dmg["附加伤害公式"] or {},
	}
end

--- 构建通用需求英文结构
---@param list table[]
---@return table[]
function SkillType:__buildReqsEn(list)
	local result = {}
	for _, it in ipairs(list) do
		table.insert(result, {
			level = it["等级"] or 0,
			description = it["需求描述"] or "",
			itemRequirements = it["物品需求列表"] or {},
			attributeConditions = it["属性条件列表"] or {},
			variableConditions = it["变量条件列表"] or {},
		})
	end
	return result
end

--- 构建掉落物品英文结构
---@param items table[]
---@return table[]
function SkillType:__buildDropItemsEn(items)
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

return SkillType


