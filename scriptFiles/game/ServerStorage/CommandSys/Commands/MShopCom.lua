--- 商城相关命令处理器
--- 用于模拟迷你币支付的最终发放阶段（跳过支付，直接发奖与记录）

local MainStorage = game:GetService("MainStorage")
local ServerStorage = game:GetService("ServerStorage")

local gg = require(MainStorage.Code.Untils.MGlobal) ---@type gg
local ConfigLoader = require(MainStorage.Code.Common.ConfigLoader) ---@type ConfigLoader

---@class ShopCommand
local ShopCommand = {}

--- 补记指定商品的购买数据（不发奖、不扣费）
---@param params table 指令参数
---@param player MPlayer 执行者（用于反馈）
---@return boolean 是否成功
function ShopCommand.appendPurchaseRecord(params, player)
	local ShopMgr = require(ServerStorage.MSystems.Shop.ShopMgr) ---@type ShopMgr
	local MServerDataManager = require(ServerStorage.Manager.MServerDataManager) ---@type MServerDataManager
    gg.log("补记购买数据", params, player)
	if not player then
		gg.log("错误：22找不到玩家对象，无法补记购买数据")
		return false
	end

	-- 目标玩家（默认当前玩家）
	local targetUin = tonumber(params["目标玩家UIN"]) or player.uin
	local targetPlayer = MServerDataManager.getPlayerByUin(targetUin)
	if not targetPlayer then
		player:SendHoverText("找不到目标玩家，UIN: " .. tostring(targetUin))
		return false
	end

	-- 商品与次数
	local shopItemId = params["商品ID"]
	local times = tonumber(params["数量"]) or 1
	if not shopItemId or shopItemId == "" then
		player:SendHoverText("缺少'商品ID'")
		return false
	end
	if times <= 0 then times = 1 end

	-- 货币类型（仅用于统计与单次花费累计，不会扣费）：迷你币/金币
	local currencyType = tostring(params["货币类型"] or "金币")

	-- 获取/创建商城实例
	local shopInstance = ShopMgr.GetOrCreatePlayerShop(targetPlayer)
	if not shopInstance then
		shopInstance = ShopMgr.OnPlayerJoin(targetPlayer)
	end
	if not shopInstance then
		player:SendHoverText("商城系统异常：无法创建玩家商城实例")
		return false
	end

	-- 商品配置
	local shopItem = ConfigLoader.GetShopItem(shopItemId)
	if not shopItem then
		player:SendHoverText("商品配置不存在：" .. tostring(shopItemId))
		return false
	end

	-- 执行补记（仅记录，不发奖、不扣费）
	local pricePer = 0
	if currencyType == "迷你币" then
		pricePer = shopItem.price and (shopItem.price.miniCoinAmount or 0) or 0
	elseif currencyType == "金币" then
		pricePer = shopItem.price and (shopItem.price.amount or 0) or 0
	end

	for _ = 1, times do
		shopInstance:UpdatePurchaseRecord(shopItemId, shopItem, currencyType)
		shopInstance:UpdateLimitCounter(shopItemId, shopItem)
		-- 手动补统计（因为未走支付流程）
		if currencyType == "迷你币" and pricePer > 0 then
			shopInstance.totalPurchaseValue = shopInstance.totalPurchaseValue + pricePer
		elseif currencyType == "金币" and pricePer > 0 then
			shopInstance.totalCoinSpent = shopInstance.totalCoinSpent + pricePer
		end
	end

	-- 可选保存与推送
	local shouldSave = params["是否保存"]
	if shouldSave == nil then shouldSave = true end
	if shouldSave == true or shouldSave == "true" or shouldSave == 1 or shouldSave == "1" then
		ShopMgr.SavePlayerShopData(targetUin)
		ShopMgr.PushShopDataToClient(targetUin)
	end

	local msg = string.format("已补记购买数据：%s × %d（货币：%s）", shopItem.configName or shopItemId, times, currencyType)
	player:SendHoverText(msg)
	gg.log("补记购买数据", targetPlayer.name, shopItemId, times, currencyType)
	return true
end

--- 模拟迷你币购买的最终发放
---@param params table 指令参数
---@param player MPlayer 玩家对象
---@return boolean 是否成功
function ShopCommand.simulateMiniGrant(params, player)
    local ShopMgr = require(ServerStorage.MSystems.Shop.ShopMgr) ---@type ShopMgr

	if not player then
		gg.log("错误：找不到玩家对象，无法模拟迷你币发放")
		return false
	end

	-- 优先使用迷你商品ID，其次根据商品ID反查
	local miniId = tonumber(params["迷你商品ID"]) or 0
	local shopItemId = params["商品ID"]
	local num = tonumber(params["数量"]) or 1

	if miniId <= 0 then
		if not shopItemId or shopItemId == "" then
			player:SendHoverText("缺少'迷你商品ID'或'商品ID'")
			return false
		end
		local shopItem = ConfigLoader.GetShopItem(shopItemId)
		if not shopItem then
			player:SendHoverText("商品配置不存在：" .. tostring(shopItemId))
			return false
		end
		local special = shopItem.specialProperties
		miniId = special and special.miniItemId or 0
	end

	if not miniId or miniId <= 0 then
		player:SendHoverText("迷你币商品ID无效，无法发放")
		return false
	end

	-- 直接走回调逻辑：发奖、更新记录、限购与客户端通知
	ShopMgr.HandleMiniPurchaseCallback(player.uin, miniId, num)
	gg.log("已模拟迷你币购买发放", player.name, "goodsid:", miniId, "数量:", num)
	--player:SendHoverText("已模拟迷你币购买发放")
	return true
end

--- 查看玩家商城记录
---@param params table 指令参数
---@param player MPlayer 玩家对象
---@return boolean 是否成功
function ShopCommand.viewShopRecords(params, player)
    local ShopMgr = require(ServerStorage.MSystems.Shop.ShopMgr) ---@type ShopMgr
    local MServerDataManager = require(ServerStorage.Manager.MServerDataManager) ---@type MServerDataManager

    if not player then
        gg.log("错误：找不到玩家对象，无法查看商城记录")
        return false
    end

    -- 获取目标玩家UIN（默认为当前玩家）
    local targetUin = tonumber(params["目标玩家UIN"]) or player.uin
    local targetPlayer = MServerDataManager.getPlayerByUin(targetUin)
    
    if not targetPlayer then
        player:SendHoverText("找不到目标玩家，UIN: " .. tostring(targetUin))
        return false
    end

    -- 获取玩家商城实例
    local shopInstance = ShopMgr.GetOrCreatePlayerShop(targetPlayer)
    if not shopInstance then
        player:SendHoverText("目标玩家商城数据不存在")
        return false
    end

    -- 获取购买记录
    local purchaseRecords = shopInstance:GetPurchaseRecords()
    local shopStats = shopInstance:GetShopStats()

    -- 构建显示信息
    local displayInfo = {}
    table.insert(displayInfo, "=== 玩家商城记录 ===")
    table.insert(displayInfo, "玩家: " .. (targetPlayer.name or "未知"))
    table.insert(displayInfo, "UIN: " .. tostring(targetUin))
    table.insert(displayInfo, "")
    
    -- 显示统计信息
    table.insert(displayInfo, "=== 消费统计 ===")
    table.insert(displayInfo, "累计迷你币消费: " .. gg.FormatLargeNumber(shopStats.totalMiniCoinSpent or 0))
    table.insert(displayInfo, "累计金币消费: " .. gg.FormatLargeNumber(shopStats.totalCoinSpent or 0))
    table.insert(displayInfo, "总购买次数: " .. tostring(shopStats.totalPurchases or 0))
    table.insert(displayInfo, "")

    -- 显示购买记录
    if next(purchaseRecords) then
        table.insert(displayInfo, "=== 购买记录 ===")
        local recordCount = 0
        for shopItemId, record in pairs(purchaseRecords) do
            if record and record.purchaseCount > 0 then
                recordCount = recordCount + 1
                local shopItem = ConfigLoader.GetShopItem(shopItemId)
                local itemName = shopItem and shopItem.configName or shopItemId
                
                table.insert(displayInfo, string.format("%d. %s", recordCount, itemName))
                table.insert(displayInfo, string.format("   购买次数: %d", record.purchaseCount))
                table.insert(displayInfo, string.format("   累计消费: %s", gg.FormatLargeNumber(record.totalSpent or 0)))
                if record.lastPurchaseTime and record.lastPurchaseTime > 0 then
                    local timeStr = os.date("%Y-%m-%d %H:%M:%S", record.lastPurchaseTime)
                    table.insert(displayInfo, string.format("   最后购买: %s", timeStr))
                end
                table.insert(displayInfo, "")
            end
        end
        
        if recordCount == 0 then
            table.insert(displayInfo, "暂无购买记录")
        end
    else
        table.insert(displayInfo, "=== 购买记录 ===")
        table.insert(displayInfo, "暂无购买记录")
    end

    -- 显示限购状态
    table.insert(displayInfo, "")
    table.insert(displayInfo, "=== 限购状态 ===")
    local limitCount = 0
    for shopItemId, _ in pairs(purchaseRecords) do
        local limitStatus = shopInstance:GetLimitStatus(shopItemId)
        if limitStatus and limitStatus.limitType ~= "无限制" then
            limitCount = limitCount + 1
            local shopItem = ConfigLoader.GetShopItem(shopItemId)
            local itemName = shopItem and shopItem.configName or shopItemId
            
            table.insert(displayInfo, string.format("%d. %s", limitCount, itemName))
            table.insert(displayInfo, string.format("   限购类型: %s", limitStatus.limitType))
            table.insert(displayInfo, string.format("   限购次数: %d", limitStatus.limitCount))
            table.insert(displayInfo, string.format("   已购买: %d", limitStatus.currentCount))
            table.insert(displayInfo, string.format("   状态: %s", limitStatus.isReached and "已达上限" or "可购买"))
            if limitStatus.resetTime and limitStatus.resetTime > 0 then
                local timeStr = os.date("%Y-%m-%d %H:%M:%S", limitStatus.resetTime)
                table.insert(displayInfo, string.format("   重置时间: %s", timeStr))
            end
            table.insert(displayInfo, "")
        end
    end
    
    if limitCount == 0 then
        table.insert(displayInfo, "无限购商品")
    end

    -- 发送显示信息
    local fullMessage = table.concat(displayInfo, "\n")
    player:SendHoverText(fullMessage)
	gg.log("fullMessage",fullMessage)
    
    gg.log("查看玩家商城记录", "执行者:", player.name, "目标玩家:", targetPlayer.name, "UIN:", targetUin)
    return true
end

-- 中文到处理器的映射
local operationMap = {
	["补记购买数据"] = "appendPurchaseRecord",
	["新增购买记录"] = "appendPurchaseRecord",
	["修复商城数据"] = "appendPurchaseRecord",
	["模拟迷你币购买"] = "simulateMiniGrant",
	["模拟迷你币发放"] = "simulateMiniGrant",
	["查看商城记录"] = "viewShopRecords",
	["查看购买记录"] = "viewShopRecords",
	["商城记录"] = "viewShopRecords",
}

--- 指令入口
---@param params table 指令参数
---@param player MPlayer 玩家
---@return boolean 是否成功
function ShopCommand.main(params, player)
	local operationType = params["操作类型"]
	if not operationType then
		player:SendHoverText("缺少'操作类型'字段")
		return false
	end

	local handlerName = operationMap[operationType]
	if not handlerName or not ShopCommand[handlerName] then
		player:SendHoverText("未知的操作类型: " .. tostring(operationType))
		return false
	end

	gg.log("商城命令执行", "操作类型:", operationType, "参数:", params, "执行者:", player.name)
	return ShopCommand[handlerName](params, player)
end

return ShopCommand


