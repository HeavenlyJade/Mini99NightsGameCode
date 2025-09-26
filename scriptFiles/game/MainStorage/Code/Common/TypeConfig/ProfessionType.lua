local MainStorage = game:GetService('MainStorage')
local ClassMgr = require(MainStorage.Code.Untils.ClassMgr) ---@type ClassMgr

--- 职业类型（与 ProfessionConfig 字段对齐）
---@class ProfessionType:Class
---@field name string 名字
---@field displayName string 显示名
---@field star number 星级
---@field icon string 资源图标
---@field model string 资源模型
---@field ownedEquipments table[] 装备拥有（原始）
---@field ownedEquipmentsEn table[] 装备拥有（英文结构）{ item:string, count:number }
---@field rawAttributes table[] 属性配置（原始）
---@field attributes table<string, number> 属性键值（中）
---@field rawTalents table[] 天赋（原始）
---@field talentsEn table[] 天赋（英文结构）
---@field New fun(data:table):ProfessionType
local ProfessionType = ClassMgr.Class("ProfessionType")

--- 初始化（读取 ProfessionConfig 字段）
---@param data table
function ProfessionType:OnInit(data)
	-- 基本信息
	self.name = data["名字"] or "Unknown Profession"
	self.displayName = data["显示名"] or self.name
	self.star = data["星级"] or 0
	self.icon = data["资源图标"] or ""
	self.model = data["资源模型"] or ""

	-- 装备拥有
	self.ownedEquipments = data["装备拥有"] or {}
	self.ownedEquipmentsEn = self:__buildOwnedEquipmentsEn(self.ownedEquipments)

	-- 属性配置（兼容两种键：变量名称/属性）
	self.rawAttributes = data["属性配置"] or {}
	self.attributes = self:__buildAttributes(self.rawAttributes)

	-- 天赋
	self.rawTalents = data["天赋"] or {}
	self.talentsEn = self:__buildTalentsEn(self.rawTalents)
end

--- 获取英文结构化装备拥有
---@return table[]
function ProfessionType:GetOwnedEquipmentsEn()
	return self.ownedEquipmentsEn
end

--- 获取英文结构化天赋
---@return table[]
function ProfessionType:GetTalentsEn()
	return self.talentsEn
end

--- 构建装备拥有英文结构
---@param list table[]
---@return table[]
function ProfessionType:__buildOwnedEquipmentsEn(list)
	local result = {}
	for _, it in ipairs(list) do
		table.insert(result, {
			item = it["物品"],
			count = it["数量"] or 0,
		})
	end
	return result
end

--- 构建属性键值（中文键）
---@param list table[]
---@return table<string, number>
function ProfessionType:__buildAttributes(list)
	local cn = {}
	for _, it in ipairs(list) do
		local key = it["变量名称"] or it["属性"]
		local value = it["数值"]
		if key and value ~= nil then
			cn[key] = value
		end
	end
	return cn
end

--- 构建天赋英文结构
---@param list table[]
---@return table[]
function ProfessionType:__buildTalentsEn(list)
	local result = {}
	for _, t in ipairs(list) do
		table.insert(result, {
			name = t["天赋名称"] or "",
			effect = t["天赋效果"] or "",
			requirements = t["解锁需求"] or {},
			description = t["天赋描述"] or "",
			next = t["下一级天赋"],
		})
	end
	return result
end

return ProfessionType


