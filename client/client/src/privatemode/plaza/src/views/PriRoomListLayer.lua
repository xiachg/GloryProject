--
-- Author: zhong
-- Date: 2016-12-21 15:21:11
--
-- 私人房模式 房间列表
local PriRoomListLayer = class("PriRoomListLayer", cc.Layer)
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")

local BTN_NORMAL_ROOMLIST   = 101               -- 普通房间列表
local BTN_JOIN_PRIROOM      = 102               -- 加入房间
local BTN_CREATE_PRIROOM    = 103               -- 创建房间
local BTN_BACK_GAME         = 104               -- 返回游戏
function PriRoomListLayer:ctor( scene )
    ExternalFun.registerNodeEvent(self)
    GlobalUserItem.nCurRoomIndex = -1

    self._scene = scene
    -- 加载csb资源
    local rootLayer, csbNode = ExternalFun.loadRootCSB("room/PriRoomListLayer.csb", self)

    local touchFunC = function(ref, tType)
        if tType == ccui.TouchEventType.ended then
            self:onButtonClickedEvent(ref:getTag(), ref)            
        end
    end
    -- 无普通房间
    local bHaveNormalRoom = (0 ~= GlobalUserItem.GetGameRoomCount())
    -- 普通房间列表
    local btn = csbNode:getChildByName("btn_roomlist")
    btn:setTag(BTN_NORMAL_ROOMLIST)
    btn:setVisible(bHaveNormalRoom)
    btn:setEnabled(bHaveNormalRoom)
    btn:addTouchEventListener(touchFunC)

    -- 加入房间
    btn = csbNode:getChildByName("btn_joinroom")
    btn:setTag(BTN_JOIN_PRIROOM)
    btn:addTouchEventListener(touchFunC)
    local joinBtn = btn

    -- 创建房间
    btn = csbNode:getChildByName("btn_createroom")
    btn:setTag(BTN_CREATE_PRIROOM)
    btn:addTouchEventListener(touchFunC)
    local createBtn = btn
    if not bHaveNormalRoom then
        joinBtn:setPositionX(392)
        createBtn:setPositionX(940)
    end
    --[[self.m_szBackGameRoomId = nil
    -- 是否暂离了房间
    local joinGame = PriRoom:getInstance().m_tabJoinGameRecord[GlobalUserItem.nCurGameKind]
    dump(joinGame, "joinGame", 6)
    if nil ~= joinGame then
        local szRoomID = joinGame["roomid"]
        if type(szRoomID) == "string" and string.len(szRoomID) == 6 then
            createBtn:loadTextureDisabled("pri_btn_back.png", UI_TEX_TYPE_PLIST)
            createBtn:loadTextureNormal("pri_btn_back.png", UI_TEX_TYPE_PLIST)
            createBtn:setTag(BTN_BACK_GAME)
            self.m_szBackGameRoomId = szRoomID
        end
    end]]

    self._scene:showPopWait()
    -- 请求私人房配置
    PriRoom:getInstance():getNetFrame():onGetRoomParameter()
end

function PriRoomListLayer:onButtonClickedEvent( tag, sender )
    if BTN_NORMAL_ROOMLIST == tag then
        -- 重置搜索路径
        PriRoom:getInstance():exitRoom()
        self._scene:onChangeShowMode(yl.SCENE_ROOMLIST)
    elseif BTN_JOIN_PRIROOM == tag then
        PriRoom:getInstance():getTagLayer(PriRoom.LAYTAG.LAYER_ROOMID)
    elseif BTN_CREATE_PRIROOM == tag then
        self._scene:onChangeShowMode(PriRoom.LAYTAG.LAYER_CREATEPRIROOME)
    elseif BTN_BACK_GAME == tag then
        PriRoom:getInstance():showPopWait()
        PriRoom:getInstance():getNetFrame():onSearchRoom(self.m_szBackGameRoomId)
    end
end

function PriRoomListLayer:onEnterTransitionFinish()
end

return PriRoomListLayer