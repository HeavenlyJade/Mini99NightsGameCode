local MainStorage = game:GetService("MainStorage")
local ClassMgr = require(MainStorage.Code.Untils.ClassMgr) ---@type ClassMgr
local ViewBase = require(MainStorage.Code.Client.UI.ViewBase) ---@type ViewBase
local ViewButton = require(MainStorage.Code.Client.UI.ViewButton) ---@type ViewButton
local ViewList = require(MainStorage.Code.Client.UI.ViewList) ---@type ViewList
local ClientEventManager = require(MainStorage.Code.Client.Event.ClientEventManager) ---@type ClientEventManager
local ConfigLoader = require(MainStorage.Code.Common.ConfigLoader) ---@type ConfigLoader
local gg = require(MainStorage.Code.Untils.MGlobal) ---@type gg

local uiConfig = {
    uiName = "RoleUi",
    layer = 3,
    hideOnInit = true,
}

---@class RoleUi:ViewBase
local RoleUi = ClassMgr.Class("RoleUi", ViewBase)

function RoleUi:OnInit(node, config)
    -- 初始化UI组件
    self:InitUIComponents()
    
    -- 注册事件
    self:RegisterEvents()
    
    -- 装载角色数据
    self:LoadRoleData()
end

---初始化UI组件
function RoleUi:InitUIComponents()
    -- 关闭按钮
    self.CloseButton = self:Get("右边底图/关闭按钮", ViewButton) ---@type ViewButton
    
    -- 角色选择列表
    self.RoleSelectList = self:Get("左边底图/角色选择列表", ViewList) ---@type ViewList
    self.RoleSelectList:SetVisible(true)
    
    -- 角色模板（用于克隆）
    self.RoleTemplate = self:Get("左边底图/角色选择列表模版/角色模板", ViewButton) ---@type ViewButton
    self.RoleTemplate:SetVisible(false)
    
    -- 中间展示区域
    self.RoleModel = self:Get("中间/展示模型/职业模型") ---@type any
    self.RoleImg = self:Get("中间/展示立绘") ---@type any
    self.RoleName = self:Get("职业名称") ---@type any
    self.EquipButton = self:Get("中间/装备", ViewButton) ---@type ViewButton
    self.UnloadButton = self:Get("中间/卸下装备", ViewButton) ---@type ViewButton
    self.BuyButton = self:Get("中间/购买", ViewButton) ---@type ViewButton
    self.BuyPrice = self:Get("中间/购买/购买价格") ---@type any
    
    -- 右边天赋区域
    self.LevelList = self:Get("右边底图/级别列表", ViewList) ---@type ViewList
    self.GameEquipList = self:Get("右边底图/开局工具列表", ViewList) ---@type ViewList
    self.AttrList = self:Get("属性内容", ViewList) ---@type ViewList
    
    -- 天赋相关
    self.UnlockedTalent = self:Get("右边底图/天赋/未解锁") ---@type any
    self.LockedTalent = self:Get("右边底图/天赋/解锁") ---@type any
    self.TalentRoleHead = self:Get("右边底图/天赋/解锁/职业头像") ---@type any
    
    -- 存储角色按钮列表
    self.RoleButtons = {} ---@type ViewButton[]
    
    -- 当前选中的角色ID
    self.currentRoleId = nil ---@type string|nil
end

---装载角色数据
function RoleUi:LoadRoleData()
    -- 获取所有职业配置
    local professions = ConfigLoader.GetAllProfessions()
    
    -- 清空现有角色列表
    self.RoleSelectList:SetElementSize(0)
    self.RoleButtons = {}
    
    -- 遍历所有职业，创建角色按钮
    local index = 1
    for professionId, profession in pairs(professions) do
        -- 克隆角色模板
        local roleTemplate = self.RoleTemplate.node:Clone()
        roleTemplate.Name = "Role_" .. professionId
        roleTemplate.Parent = self.RoleSelectList.node
        
        -- 创建ViewButton包装器
        local roleButton = ViewButton.New(roleTemplate, self, roleTemplate.Name)
        
        -- 存储到数组中
        self.RoleButtons[index] = roleButton
        
        -- 设置角色数据
        self:LoadProfessionDataToUI(roleTemplate, profession, index)
        
        -- 注册点击事件
        roleButton.clickCb = function(ui, button)
            self:OnRoleSelected(profession, index)
        end
        
        index = index + 1
    end
    
    -- 设置列表大小
    self.RoleSelectList:SetElementSize(#self.RoleButtons)
    
    -- 默认选择第一个角色
    if #self.RoleButtons > 0 then
        self:OnRoleSelected(ConfigLoader.GetAllProfessions()[next(ConfigLoader.GetAllProfessions())], 1)
    end
end

---将职业数据装载到UI
---@param roleTemplate any 角色模板节点
---@param profession ProfessionType 职业数据
---@param index number 角色索引
function RoleUi:LoadProfessionDataToUI(roleTemplate, profession, index)
    -- 设置职业头像
    if roleTemplate["职业头像"] then
        roleTemplate["职业头像"].Icon = profession.icon
    end
    
    -- 设置职业名称
    if roleTemplate["职业名称"] then
        roleTemplate["职业名称"].Title = profession.displayName
    end
    
    -- 设置星级
    if roleTemplate["星星列表"] then
        self:SetStarLevel(roleTemplate["星星列表"], profession.star)
    end
    
    -- 设置价格（如果有购买选择）
    if roleTemplate["购买选择"] and roleTemplate["购买选择"]["价格"] then
        -- 这里可以根据实际需求设置价格
        roleTemplate["购买选择"]["价格"].Title = "免费"
    end
    
    -- 设置拥有状态（这里需要根据实际游戏逻辑判断）
    if roleTemplate["已拥有"] then
        roleTemplate["已拥有"].Visible = true -- 假设都拥有
    end
    
    if roleTemplate["勾选"] then
        roleTemplate["勾选"].Visible = true -- 假设都拥有
    end
end

---设置星级显示
---@param starList any 星星列表节点
---@param starLevel number 星级
function RoleUi:SetStarLevel(starList, starLevel)
    if not starList then return end
    
    -- 遍历星星节点，设置可见性
    for i = 1, 5 do
        local starNode = nil
        if starList.GetChild then
            starNode = starList:GetChild(i - 1)
        else
            starNode = starList[i]
        end
        if starNode then
            starNode.Visible = (i <= starLevel)
        end
    end
end

---角色选择事件处理
---@param profession ProfessionType 选中的职业
---@param index number 角色索引
function RoleUi:OnRoleSelected(profession, index)
    gg.log(string.format("选中职业: %s", profession.displayName))
    
    -- 更新当前选中的角色ID
    self.currentRoleId = profession.name
    
    -- 更新中间展示区域
    self:UpdateRoleDisplay(profession)
    
    -- 更新右边天赋区域
    self:UpdateTalentDisplay(profession)
    
    -- 更新装备列表
    self:UpdateEquipmentList(profession)
    
    -- 更新属性显示
    self:UpdateAttributeDisplay(profession)
end

---更新角色展示
---@param profession ProfessionType 职业数据
function RoleUi:UpdateRoleDisplay(profession)
    -- 更新职业名称
    if self.RoleName then
        self.RoleName.Title = profession.displayName
    end
    
    -- 更新职业立绘
    if self.RoleImg then
        self.RoleImg.Image = profession.icon
    end
    
    -- 更新职业模型（如果有的话）
    if self.RoleModel and profession.model ~= "" then
        -- 这里需要根据实际需求加载3D模型
        -- self.RoleModel:LoadModel(profession.model)
    end
end

---更新天赋显示
---@param profession ProfessionType 职业数据
function RoleUi:UpdateTalentDisplay(profession)
    -- 获取天赋数据
    local talents = profession:GetTalentsEn()
    
    -- 更新天赋区域显示
    if self.TalentRoleHead then
        self.TalentRoleHead.Image = profession.icon
    end
    
    -- 这里可以根据实际需求更新天赋列表
    -- 例如：显示天赋名称、效果、解锁条件等
end

---更新装备列表
---@param profession ProfessionType 职业数据
function RoleUi:UpdateEquipmentList(profession)
    -- 获取装备数据
    local equipments = profession:GetOwnedEquipmentsEn()
    
    -- 更新开局工具列表
    if self.GameEquipList then
        self.GameEquipList:SetElementSize(#equipments)
        
        for i, equipment in ipairs(equipments) do
            local equipItem = self.GameEquipList:GetChild(i - 1)
            if equipItem then
                -- 设置装备名称
                if equipItem["名称"] then
                    equipItem["名称"].Title = equipment.item
                end
                
                -- 设置装备数量
                if equipItem["数量"] then
                    equipItem["数量"].Title = tostring(equipment.count)
                end
            end
        end
    end
end

---更新属性显示
---@param profession ProfessionType 职业数据
function RoleUi:UpdateAttributeDisplay(profession)
    -- 获取属性数据
    local attributes = profession.attributes
    
    -- 更新属性列表
    if self.AttrList then
        local attrCount = 0
        for attrName, attrValue in pairs(attributes) do
            attrCount = attrCount + 1
        end
        
        self.AttrList:SetElementSize(attrCount)
        
        local index = 1
        for attrName, attrValue in pairs(attributes) do
            local attrItem = self.AttrList:GetChild(index - 1)
            if attrItem then
                -- 设置属性名称
                if attrItem["属性"] then
                    attrItem["属性"].Title = attrName
                end
                
                -- 设置属性值
                if attrItem["数值"] then
                    attrItem["数值"].Title = tostring(attrValue)
                end
            end
            index = index + 1
        end
    end
end

---注册事件
function RoleUi:RegisterEvents()
    -- 关闭按钮事件
    if self.CloseButton then
        self.CloseButton.clickCb = function(ui, button)
            self:Close()
        end
    end
    
    -- 装备按钮事件
    if self.EquipButton then
        self.EquipButton.clickCb = function(ui, button)
            self:OnEquipRole()
        end
    end
    
    -- 卸下装备按钮事件
    if self.UnloadButton then
        self.UnloadButton.clickCb = function(ui, button)
            self:OnUnloadRole()
        end
    end
    
    -- 购买按钮事件
    if self.BuyButton then
        self.BuyButton.clickCb = function(ui, button)
            self:OnBuyRole()
        end
    end
end

---装备角色
function RoleUi:OnEquipRole()
    gg.log("装备角色")
    -- 发送装备角色请求
    ClientEventManager.SendToServer("EquipRole", {
        roleId = self.currentRoleId
    })
end

---卸下角色
function RoleUi:OnUnloadRole()
    gg.log("卸下角色")
    -- 发送卸下角色请求
    ClientEventManager.SendToServer("UnloadRole", {
        roleId = self.currentRoleId
    })
end

---购买角色
function RoleUi:OnBuyRole()
    gg.log("购买角色")
    -- 发送购买角色请求
    ClientEventManager.SendToServer("BuyRole", {
        roleId = self.currentRoleId
    })
end

return RoleUi.New(script.Parent, uiConfig)