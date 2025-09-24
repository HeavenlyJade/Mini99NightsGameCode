local MainStorage  = game:GetService('MainStorage')
local ClassMgr    = require(MainStorage.Code.Untils.ClassMgr) ---@type ClassMgr
-- local ItemRankConfig = require(MainStorage.code.common.config.ItemRankConfig) ---@type ItemRankConfig
local gg                = require(MainStorage.Code.Untils.MGlobal)    ---@type gg

-- ItemType class
---@class ItemType:Class
---@field name string 名字
---@field displayName string 显示名称
---@field description string 描述
---@field icon string 图标
---@field quality string 品级
---@field extraPower number 额外战力
---@field maxEnhanceLevel number 最大强化等级
---@field maxDurability number 最大耐久度
---@field maxStack number 最大叠加数量
---@field isStackable boolean 是否可堆叠
---@field itemTypeStr string 类型
---@field attackType string 攻击类型
---@field isMoney boolean 是否货币
---@field equipmentConfig string|nil 装备配置
---@field canHold boolean 可手持
---@field equippable boolean 是否可装备
---@field color table 颜色
---@field useCommands table 使用执行指令
---@field gainCommands table 获取执行指令
 
---@field New fun( data:table ):ItemType
local ItemType = ClassMgr.Class("ItemType")

function ItemType:OnInit(data)
	-- 基本信息（仅使用最新配置字段）
	self.name = data["名字"] or "Unknown Item"
	self.displayName = data["显示名称"] or self.name
	self.description = data["描述"] or ""
	self.icon = data["图标"] or ""
	self.quality = data["品级"] or "N"
	self.extraPower = data["额外战力"] or 0

	-- 强化/耐久与叠加
	self.maxEnhanceLevel = data["最大强化等级"] or 0
	self.maxDurability = data["最大耐久度"] or 0
	self.maxStack = data["最大叠加数量"] or 1
	self.isStackable = (self.maxStack or 1) > 1

	-- 类型与战斗属性
	self.itemTypeStr = data["类型"] or ""
	self.attackType = data["攻击类型"] or "无"
	self.isMoney = (self.itemTypeStr == "货币")

	-- 装备/持有
	self.equipmentConfig = data["装备配置"]
	self.canHold = data["可手持"] or false
	self.equippable = data["是否可装备"] or false

	-- 颜色
	self.color = data["颜色"] or { r = 255, g = 255, b = 255, a = 255 }

	-- 指令
	self.useCommands = data["使用执行指令"] or {}
	self.gainCommands = data["获取执行指令"] or {}
end

function ItemType:GetToStringParams()
    return {
        name = self.name
    }
end

---创建完整的物品数据
---@param amount number 数量
---@param enhanceLevel number|nil 强化等级
---@param quality string|nil 品质
---@return ItemData 物品数据
function ItemType:CreateCompleteItemData(amount, enhanceLevel, quality)
    return {
        name = self.name,
        amount = amount or 1,
        enhanceLevel = enhanceLevel or 0,
        quality = quality,
        itemType = self.name,
        itype = self.name,
        isStackable = self.isStackable, -- 是否可堆叠
    }
end



return ItemType