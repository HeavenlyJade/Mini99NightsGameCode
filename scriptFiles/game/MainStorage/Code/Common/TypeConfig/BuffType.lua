local MainStorage = game:GetService('MainStorage')
local ClassMgr = require(MainStorage.Code.Untils.ClassMgr) ---@type ClassMgr
local MConfig = require(MainStorage.Code.Common.GameConfig.MConfig) ---@type common_config

--- Buff 类型（与 BuffConfig 字段对齐）
---@class BuffType:Class
---@field id string 唯一ID
---@field name string 名字
---@field displayName string 显示名称
---@field icon string 图标
---@field vfx string 特效
---@field buffCategory string buff类型
---@field stackCategory string 堆叠类型
---@field durationType string buff时长类型
---@field duration number 持续时间（秒，-1 表示永久）
---@field rawEffects table[] 效果列表（原始）
---@field effectsEn table[] 效果列表（英文结构化）
---@field New fun(data:table):BuffType
local BuffType = ClassMgr.Class("BuffType")

--- 初始化（读取 BuffConfig 字段）
---@param data table
function BuffType:OnInit(data)
	-- 基本信息
	self.id = data["唯一ID"] or ""
	self.name = data["名字"] or self.id or "Unknown Buff"
	self.displayName = data["显示名称"] or self.name
	self.icon = data["图标"] or ""
	self.vfx = data["特效"] or ""

	-- 分类/时长
	self.buffCategory = data["buff类型"] or ""
	self.stackCategory = data["堆叠类型"] or "不可堆叠"
	self.durationType = data["buff时长类型"] or "永久"
	self.duration = data["持续时间"] or -1

	-- 效果
	self.rawEffects = data["效果列表"] or {}
	self.effectsEn = self:__buildEffectsEn(self.rawEffects)
end

--- 获取原始效果列表
---@return table[]
function BuffType:GetEffects()
	return self.rawEffects
end

--- 获取英文结构化效果列表
---@return table[]
function BuffType:GetEffectsEn()
	return self.effectsEn
end

--- 遍历每个效果回调（便于按需处理）
---@param cb fun(effect:table, index:number)
function BuffType:ForEachEffect(cb)
	for i, eff in ipairs(self.rawEffects) do
		cb(eff, i)
	end
end

--- 构建英文结构化效果
---@param list table[]
---@return table[]
function BuffType:__buildEffectsEn(list)
	local result = {}
	for _, eff in ipairs(list) do
		local e = {}
		-- 顶层字段
		e.name = eff["效果名称"] or ""
		e.description = eff["效果描述"] or ""

		-- 玩家属性影响（映射变量名称为英文key（若可映射））
		e.playerStatEffects = {}
		for _, it in ipairs(eff["玩家属性影响"] or {}) do
			local keyCn = it["变量名称"]
			local value = it["数值"]
			local mode = it["作用方式"]
			local keyEn = keyCn and MConfig.PlayerStatsConfig and MConfig.PlayerStatsConfig[keyCn] or nil
			table.insert(e.playerStatEffects, {
				key = keyCn,
				keyEn = keyEn,
				value = value,
				mode = mode,
			})
		end

		-- 玩家变量影响（保持变量名称原样，若未来有映射再扩展）
		e.playerVarEffects = {}
		for _, it in ipairs(eff["玩家变量影响"] or {}) do
			table.insert(e.playerVarEffects, {
				key = it["变量名称"],
				value = it["数值"],
				mode = it["作用方式"],
			})
		end

		-- 掉落物品列表
		e.dropItems = {}
		for _, it in ipairs(eff["掉落物品列表"] or {}) do
			table.insert(e.dropItems, {
				item = it["物品"],
				count = it["数量"],
				probability = it["概率"],
				mode = it["作用方式"],
			})
		end

		table.insert(result, e)
	end
	return result
end

return BuffType


