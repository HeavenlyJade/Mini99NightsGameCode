local MainStorage = game:GetService('MainStorage')
local ClassMgr = require(MainStorage.Code.Untils.ClassMgr) ---@type ClassMgr
local MConfig = require(MainStorage.Code.Common.GameConfig.MConfig) ---@type common_config

--- 装备类型（与 EquipmentConfig 字段对齐）
---@class EquipmentType:Class
---@field name string 名字
---@field displayName string 显示名称
---@field description string 描述
---@field icon string 资源图标
---@field model string 资源模型
---@field equipmentCategory string 装备类型
---@field attackRange number 攻击距离
---@field damage number 伤害
---@field attackSpeed number 攻速
---@field maxDurability number 最大耐久度
---@field bulletCount number 子弹数量
---@field critMultiplier number 爆伤倍率
---@field critSocket string 爆伤位置
---@field attributes table<string, number> 属性键值表（由属性配置展开）
---@field rawAttributes table[] 原始属性配置数组
---@field attributesEn table<string, number> 英文属性键值表
---@field New fun(data:table):EquipmentType
local EquipmentType = ClassMgr.Class("EquipmentType")

--- 初始化（读取 EquipmentConfig 字段）
---@param data table
function EquipmentType:OnInit(data)
	-- 基本信息
	self.name = data["名字"] or "Unknown Equipment"
	self.displayName = data["显示名称"] or self.name
	self.description = data["描述"] or ""
	self.icon = data["资源图标"] or ""
	self.model = data["资源模型"] or ""
	self.equipmentCategory = data["装备类型"] or ""

	-- 数值参数
	self.attackRange = data["攻击距离"] or 0
	self.damage = data["伤害"] or 0
	self.attackSpeed = data["攻速"] or 0
	self.maxDurability = data["最大耐久度"] or 0
	self.bulletCount = data["子弹数量"] or 0
	self.critMultiplier = data["爆伤倍率"] or 0
	self.critSocket = data["爆伤位置"] or ""

	-- 属性配置展开为键值表
	self.rawAttributes = data["属性配置"] or {}
	self.attributes = {}
	self.attributesEn = {}
	for _, item in ipairs(self.rawAttributes) do
		local key = item and item["属性"]
		local value = item and item["数值"]
		if key and value then
			self.attributes[key] = value
			-- 使用 PlayerStatsConfig 将中文属性名映射为英文key
			local enKey = MConfig.PlayerStatsConfig[key]
			if enKey then
				self.attributesEn[enKey] = value
			end
		end
	end
end

--- 是否为武器（依据装备类型或是否有伤害/攻速）
---@return boolean
function EquipmentType:IsWeapon()
	if self.equipmentCategory == "武器" then return true end
	return (self.damage or 0) > 0 or (self.attackSpeed or 0) > 0
end

--- 获取全部属性（已展开）
---@return table<string, number>
function EquipmentType:GetAttributes()
	return self.attributes
end

--- 获取英文属性（按 PlayerStatsConfig 映射）
---@return table<string, number>
function EquipmentType:GetAttributesEn()
	return self.attributesEn
end

--- 获取显示用的参数
function EquipmentType:GetToStringParams()
	return { name = self.name }
end

return EquipmentType


