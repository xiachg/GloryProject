local GameModel = appdf.req(appdf.CLIENT_SRC.."gamemodel.GameModel")
local GameLayer = class("GameLayer", GameModel)

local module_pre = "game.yule.redninebattle.src";
require("cocos.init")
local ExternalFun =  appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local cmd = module_pre .. ".models.CMD_Game"
local game_cmd = appdf.HEADER_SRC .. "CMD_GameServer"
local GameLogic = module_pre .. ".models.GameLogic";
local GameViewLayer = appdf.req(module_pre .. ".views.layer.GameViewLayer")
local bjlDefine = appdf.req(module_pre .. ".models.bjlGameDefine")
local QueryDialog   = require("app.views.layer.other.QueryDialog")
local g_var = ExternalFun.req_var
local GameFrame = appdf.req(module_pre .. ".models.GameFrame")

function GameLayer:ctor( frameEngine,scene )
    ExternalFun.registerNodeEvent(self)
    self.m_bLeaveGame = false
    self.m_bOnGame = false
    self._dataModle = GameFrame:create()    
    GameLayer.super.ctor(self,frameEngine,scene)
    self._roomRule = self._gameFrame._dwServerRule
end

--创建场景
function GameLayer:CreateView()
    return GameViewLayer:create(self)
        :addTo(self)
end

function GameLayer:getParentNode( )
    return self._scene
end

function GameLayer:getFrame( )
    return self._gameFrame
end

function GameLayer:getUserList(  )
    return self._gameFrame._UserList
end

function GameLayer:sendNetData( cmddata )
    return self:getFrame():sendSocketData(cmddata)
end

function GameLayer:getDataMgr( )
    return self._dataModle
end

function GameLayer:logData(msg)
    if nil ~= self._scene.logData then
        self._scene:logData(msg)
    end
end

---------------------------------------------------------------------------------------
------继承函数

--获取gamekind
function GameLayer:getGameKind()
    return g_var(cmd).KIND_ID
end

function GameLayer:onExit()
    self:KillGameClock()
    self:dismissPopWait()
    GameLayer.super.onExit(self)
end

-- 重置游戏数据
function GameLayer:OnResetGameEngine()
    self.m_bOnGame = false
    self._gameView.m_enApplyState = self._gameView._apply_state.kCancelState
    self._dataModle:removeAllUser()
    self._dataModle:initUserList(self:getUserList())
    self._gameView:refreshApplyList()
    self._gameView:cleanJettonArea()
end

--强行起立、退出(用户切换到后台断网处理)
function GameLayer:standUpAndQuit()
    self:sendCancelOccupy()
    GameLayer.super.standUpAndQuit(self)
end

--退出桌子
function GameLayer:onExitTable()
    self:KillGameClock()
    local MeItem = self:GetMeUserItem()
    if MeItem and MeItem.cbUserStatus > yl.US_FREE then
        self:showPopWait()
        self:runAction(cc.Sequence:create(
            cc.CallFunc:create(
                function () 
                    self:sendCancelOccupy()
                    self._gameFrame:StandUp(1)
                end
                ),
            cc.DelayTime:create(10),
            cc.CallFunc:create(
                function ()
                    --强制离开游戏(针对长时间收不到服务器消息的情况)
                    print("delay leave")
                    self:onExitRoom()
                end
                )
            )
        )
        return
    end

   self:onExitRoom()
end

--离开房间
function GameLayer:onExitRoom()
    self:getFrame():onCloseSocket()

    self._scene:onKeyBack()    
end

-- 计时器响应
function GameLayer:OnEventGameClockInfo(chair,time,clockId)
    if nil ~= self._gameView and nil ~= self._gameView.updateClock then
        self._gameView:updateClock(clockId, time)
    end
end

-- 设置计时器
function GameLayer:SetGameClock(chair,id,time)
    GameLayer.super.SetGameClock(self,chair,id,time)
    --[[if nil ~= self._gameView and nil ~= self._gameView.showTimerTip then
        self._gameView:showTimerTip(id,time)
    end]]
end

------网络发送
--玩家下注
function GameLayer:sendUserBet( cbArea, lScore )
    local cmddata = ExternalFun.create_netdata(g_var(cmd).CMD_C_PlaceJetton)
    cmddata:pushbyte(cbArea)
    cmddata:pushscore(lScore)

    self:SendData(g_var(cmd).SUB_C_PLACE_JETTON, cmddata)
end

--申请上庄
function GameLayer:sendApplyBanker(  )
    local cmddata = CCmd_Data:create(0)
    self:SendData(g_var(cmd).SUB_C_APPLY_BANKER, cmddata)
end

--取消申请
function GameLayer:sendCancelApply(  )
    local cmddata = CCmd_Data:create(0)
    self:SendData(g_var(cmd).SUB_C_CANCEL_BANKER, cmddata)
end

--申请取消占位
function GameLayer:sendCancelOccupy(  )
    if nil ~= self._gameView.m_nSelfSitIdx then 
        local cmddata = CCmd_Data:create(0)
        self:SendData(g_var(cmd).SUB_C_QUIT_OCCUPYSEAT, cmddata)
    end 
end

------网络接收

-- 场景信息
function GameLayer:onEventGameScene(cbGameStatus,dataBuffer)
    print("场景数据:" .. cbGameStatus);
    if self.m_bOnGame then
        return
    end
    self.m_bOnGame = true
    
    self._gameView.m_cbGameStatus = cbGameStatus;
	if cbGameStatus == g_var(cmd).GAME_SCENE_FREE	then                        --空闲状态
        self:onEventGameSceneFree(dataBuffer);
	elseif cbGameStatus == g_var(cmd).GS_PLACE_JETTON	then                        --下注状态
        self:onEventGameSceneJetton(dataBuffer);
	elseif cbGameStatus == g_var(cmd).GS_GAME_END	then                            --游戏状态
        self:onEventGameSceneEnd(dataBuffer);
	end
    self:dismissPopWait()
end

function GameLayer:onEventGameSceneFree( dataBuffer )
    --self._gameView:reSetForNewGame()

    local cmd_table = ExternalFun.read_netdata(g_var(cmd).CMD_S_StatusFree, dataBuffer)

    self._gameView.m_llBankerConsume = cmd_table.lApplyBankerCondition

    self._gameView:SetBankerInfo(cmd_table.wBankerUser, cmd_table.lBankerScore)

    --从申请列表移除
    self._dataModle:removeApplyUser(cmd_table.wBankerUser)
end

function GameLayer:onEventGameSceneJetton( dataBuffer )
    local cmd_table = ExternalFun.read_netdata(g_var(cmd).CMD_S_StatusPlay, dataBuffer);
    
    self._gameView.m_llBankerConsume = cmd_table.lApplyBankerCondition

    self._gameView:SetBankerInfo(cmd_table.wBankerUser, cmd_table.lBankerScore)

    --玩家最大下注
    self._gameView.m_llMaxJetton = cmd_table.lUserMaxScore;

    --界面下注信息
    local lScore = 0;
    local ll = 0;
    for i=1,(g_var(cmd).AREA_COUNT+1) do
        --界面已下注
        ll = cmd_table.lAllJettonScore[1][i];
        self._gameView:reEnterGameBet(i-1, ll);

        --玩家下注
        ll = cmd_table.lUserJettonScore[1][i];
        self._gameView:reEnterUserBet(i-1, ll);
        lScore = lScore + ll;
    end

    --从申请列表移除
    self._dataModle:removeApplyUser(cmd_table.wBankerUser)

    --游戏开始
    self._gameView:reEnterStart(lScore)
end

function GameLayer:onEventGameSceneEnd( dataBuffer )
    local cmd_table = ExternalFun.read_netdata(g_var(cmd).CMD_S_StatusPlay, dataBuffer)

    self._gameView.m_llBankerConsume = cmd_table.lApplyBankerCondition

    --保存游戏结果
    self._dataModle.m_tabGameSceneEndCmd = cmd_table

    self._gameView:SetBankerInfo(cmd_table.wBankerUser, cmd_table.lBankerScore)

    --玩家最大下注
    self._gameView.m_llMaxJetton = cmd_table.lUserMaxScore;
    --界面下注信息
    local ll = 0;
    local lScore = 0;
    for i=1,(g_var(cmd).AREA_COUNT+1) do
        --界面已下注
        ll = cmd_table.lAllJettonScore[1][i]        
        self._gameView:reEnterGameBet(i-1, ll)

        --玩家下注
        ll = cmd_table.lUserJettonScore[1][i]        
        self._gameView:reEnterUserBet(i-1, ll)
        lScore = lScore + ll
    end
    self._gameView.m_lHaveJetton = lScore

    --从申请列表移除
    self._dataModle:removeApplyUser(cmd_table.wBankerUser)

    --[[--设置游戏结果
    local res = bjlDefine.getEmptyGameResult()
    res.m_llTotal = cmd_table.lPlayAllScore
    res.m_pAreaScore = cmd_table.lPlayScore[1]
    self._dataModle.m_tabGameResult = res
    local bJoin = false
    local nWinCount = 0
    local nLoseCount = 0
    for i = 1, (g_var(cmd).AREA_COUNT+1) do
        if cmd_table.lPlayScore[1][i] > 0 then
            bJoin = true
            nWinCount = nWinCount + 1
        elseif cmd_table.lPlayScore[1][i] < 0 then
            bJoin = true
            nLoseCount = nLoseCount + 1
        end
    end
    --self._dataModle.m_bJoin = bJoin

    --成绩
    self._dataModle.m_llTotalScore = cmd_table.lPlayAllScore
    self._dataModle:calcuteRata(nWinCount, nLoseCount)

    --显示扑克界面
    local tabRes = bjlDefine.getEmptyCardsResult()
    for i = 1, cmd_table.cbCardCount[1][1] do
        tabRes.m_idleCards[i] = cmd_table.cbTableCardArray[1][i]
    end
    for i=1,cmd_table.cbCardCount[1][2] do
        tabRes.m_masterCards[i] = cmd_table.cbTableCardArray[2][i]
    end]]

    self._gameView:onEventGameSceneEnd()
end

-- 游戏消息
function GameLayer:onEventGameMessage(sub,dataBuffer)  
    if self.m_bLeaveGame or nil == self._gameView then
        return
    end 

	if sub == g_var(cmd).SUB_S_GAME_FREE then 
        self._gameView.m_cbGameStatus = g_var(cmd).GAME_SCENE_FREE

		self:onSubGameFree(dataBuffer);
	elseif sub == g_var(cmd).SUB_S_GAME_START then 
        self._gameView.m_cbGameStatus = g_var(cmd).GAME_START

		self:onSubGameStart(dataBuffer);
	elseif sub == g_var(cmd).SUB_S_PLACE_JETTON then 
        self._gameView.m_cbGameStatus = g_var(cmd).GAME_PLAY

		self:onSubPlaceJetton(dataBuffer)
	elseif sub == g_var(cmd).SUB_S_GAME_END then 
        self._gameView.m_cbGameStatus = g_var(cmd).GAME_PLAY

		self:onSubGameEnd(dataBuffer);
	elseif sub == g_var(cmd).SUB_S_APPLY_BANKER then
		self:onSubApplyBanker(dataBuffer);
	elseif sub == g_var(cmd).SUB_S_CHANGE_BANKER then 
		self:onSubChangeBanker(dataBuffer);
    elseif sub == g_var(cmd).SUB_S_CANCEL_BANKER then
        self:onSubCancelBanker(dataBuffer);
	elseif sub == g_var(cmd).SUB_S_CHANGE_USER_SCORE then 
		self:onSubChangeUserScore(dataBuffer);
    elseif sub == g_var(cmd).SUB_S_SEND_RECORD then
        self:onSubSendRecord(dataBuffer);
    elseif sub == g_var(cmd).SUB_S_PLACE_JETTON_FAIL then
        self:onSubJettonFail(dataBuffer);
    elseif sub == g_var(cmd).SUB_S_CHEAT then
        self:OnSubCheat(dataBuffer);
    elseif sub == g_var(cmd).SUB_S_AMDIN_COMMAND then
        self:onSubAdminCmd(dataBuffer);
    elseif sub == g_var(cmd).SUB_S_TIME_STATUS then
        self:onSubTimeStatus(dataBuffer);
    elseif sub == g_var(cmd).SUB_S_UPDATE_STORAGE then
        self:onSubUpdateStorage(dataBuffer);
    elseif sub == g_var(cmd).SUB_S_SCORE_RESULT then
        self:OnSubScoreResult(dataBuffer);
    elseif sub == g_var(cmd).SUB_S_ACCOUNT_RESULT then
        self:OnSubAccountResult(dataBuffer);
	else
		print("unknow gamemessage sub is ==>"..sub)
	end
end

function GameLayer:onSocketInsureEvent( sub,dataBuffer )
    self:dismissPopWait()
    if sub == g_var(game_cmd).SUB_GR_USER_INSURE_SUCCESS then
        local cmd_table = ExternalFun.read_netdata(g_var(game_cmd).CMD_GR_S_UserInsureSuccess, dataBuffer)
        self.bank_success = cmd_table

        self._gameView:onBankSuccess()
    elseif sub == g_var(game_cmd).SUB_GR_USER_INSURE_FAILURE then
        local cmd_table = ExternalFun.read_netdata(g_var(game_cmd).CMD_GR_S_UserInsureFailure, dataBuffer)
        self.bank_fail = cmd_table

        self._gameView:onBankFailure()
    elseif sub == g_var(game_cmd).SUB_GR_USER_INSURE_INFO then --银行资料
        local cmdtable = ExternalFun.read_netdata(g_var(game_cmd).CMD_GR_S_UserInsureInfo, dataBuffer)
        dump(cmdtable, "cmdtable", 6)

        self._gameView:onGetBankInfo(cmdtable)
    else
        print("unknow gamemessage sub is ==>"..sub)
    end
end

--游戏空闲
function GameLayer:onSubGameFree( dataBuffer )
    print("game free")

    self._gameView:onGameFree()
end

--游戏开始
function GameLayer:onSubGameStart( dataBuffer )
    print("game start");
    self.cmd_gamestart = ExternalFun.read_netdata(g_var(cmd).CMD_S_GameStart,dataBuffer);

    --庄家信息
    self._gameView:SetBankerInfo(self.cmd_gamestart.wBankerUser, self.cmd_gamestart.lBankerScore)

	--玩家信息
	self.m_lMeMaxScore = self.cmd_gamestart.lUserMaxScore
	self._gameView:SetMeMaxScore(self.m_lMeMaxScore)

    self._cbGameStatus = g_var(cmd).GS_PLACE_JETTON

    --玩家最大下注
    self._gameView.m_llMaxJetton = self.cmd_gamestart.lUserMaxScore;

	--更新控制
	--UpdateButtonContron();

	--设置提示
	--m_GameClientView.SetDispatchCardTip(pGameStart->bContiueCard ? enDispatchCardTip_Continue : enDispatchCardTip_Dispatch);

	--播放声音
    ExternalFun.playSoundEffect("GAME_START.wav")

	--m_GameClientView.SetMeUserScore();

	--[[if (m_GameClientView.m_pClientControlDlg->GetSafeHwnd())
	{
		m_GameClientView.m_pClientControlDlg->ResetUserBet();
	}]]

    self._gameView:onGameStart()
end

--用户下注
function GameLayer:onSubPlaceJetton( dataBuffer )
    print("game bet");
    self.cmd_placebet = ExternalFun.read_netdata(g_var(cmd).CMD_S_PlaceJetton, dataBuffer);
    --ExternalFun.playSoundEffect("ADD_SCORE.wav")
    self._gameView:onGetUserBet();
end

--游戏结束
function GameLayer:onSubGameEnd( dataBuffer )
    print("game end");
    local cmd_table = ExternalFun.read_netdata(g_var(cmd).CMD_S_GameEnd,dataBuffer)

    --保存游戏结果
    self._dataModle.m_tabGameEndCmd = cmd_table

    --[[--游戏倒计时
    --self._gameView:startCountDown(cmd_table.cbTimeLeave, g_var(cmd).kGAMEOVER_COUNTDOWN);
    --self:SetGameClock(self:GetMeChairID(), g_var(cmd).kGAMEOVER_COUNTDOWN, cmd_table.cbTimeLeave)
    
    --设置游戏结果
    local res = bjlDefine.getEmptyGameResult()
    res.m_llTotal = cmd_table.lPlayAllScore
    res.m_pAreaScore = cmd_table.lPlayScore[1]
    self._dataModle.m_tabGameResult = res
    local bJoin = false
    local nWinCount = 0
    local nLoseCount = 0
    for i = 1, (g_var(cmd).AREA_COUNT+1) do
        if cmd_table.lPlayScore[1][i] > 0 then
            bJoin = true
            nWinCount = nWinCount + 1
        elseif cmd_table.lPlayScore[1][i] < 0 then
            bJoin = true
            nLoseCount = nLoseCount + 1
        end
    end
    self._dataModle.m_bJoin = bJoin

    --成绩
    self._dataModle.m_llTotalScore = cmd_table.lPlayAllScore
    self._dataModle:calcuteRata(nWinCount, nLoseCount)

    --显示扑克界面
    local tabRes = bjlDefine.getEmptyCardsResult()
    for i = 1, cmd_table.cbCardCount[1][1] do
        tabRes.m_idleCards[i] = cmd_table.cbTableCardArray[1][i]
    end
    for i = 1, cmd_table.cbCardCount[1][2] do
        tabRes.m_masterCards[i] = cmd_table.cbTableCardArray[2][i]
    end]]

    self._gameView:onGetGameEnd()
end

--申请庄家
function GameLayer:onSubApplyBanker( dataBuffer )
    local cmd_table = ExternalFun.read_netdata(g_var(cmd).CMD_S_ApplyBanker,dataBuffer);
    self.cmd_applybanker = cmd_table;
    self._dataModle:addApplyUser(cmd_table.wApplyUser) 

    self._gameView:onGetApplyBanker()
    print("apply banker ==>" .. cmd_table.wApplyUser)
end

--切换庄家
function GameLayer:onSubChangeBanker( dataBuffer )
    print("change banker")
    local cmd_table = ExternalFun.read_netdata(g_var(cmd).CMD_S_ChangeBanker,dataBuffer);

    self.cmd_changebanker = cmd_table

    --从申请列表移除
    self._dataModle:removeApplyUser(cmd_table.wBankerUser)

    self._gameView:SetBankerInfo(cmd_table.wBankerUser, cmd_table.lBankerScore)

    --申请列表更新
    self._gameView:refreshApplyList()

    --刷新申请按钮状态
    self._gameView:refreshCondition()
end

--更新积分
function GameLayer:onSubChangeUserScore( dataBuffer )
    
end

--游戏记录
function GameLayer:onSubSendRecord( dataBuffer )
    local len = dataBuffer:getlen();
    local recordcount = math.floor(len / g_var(cmd).RECORDER_LEN);
    if (len - recordcount * g_var(cmd).RECORDER_LEN) ~= 0 then
        print("record_len_error" .. len);
        return;
    end
    
    self._gameView.m_nRecordLast = 1
    self._gameView.m_nRecordFirst = 1
    self._gameView.m_GameRecordArrary = {}

    --读取记录列表
    for i=1,recordcount do
        local  pServerGameRecord = {}
        pServerGameRecord.bWinShunMen = dataBuffer:readint()
        pServerGameRecord.bWinDuiMen = dataBuffer:readint()
        pServerGameRecord.bWinDaoMen = dataBuffer:readint()
        self._gameView:SetGameHistory(pServerGameRecord.bWinShunMen, pServerGameRecord.bWinDaoMen, pServerGameRecord.bWinDuiMen)
    end

    self._gameView:updateRecord()
end

--下注失败
function GameLayer:onSubJettonFail( dataBuffer )
    self.cmd_jettonfail = ExternalFun.read_netdata(g_var(cmd).CMD_S_PlaceJettonFail, dataBuffer)
    
    self._gameView:onGetUserBetFail()
end

function GameLayer:OnSubCheat( dataBuffer )

end

--取消申请
function GameLayer:onSubCancelBanker( dataBuffer )
    print("cancel banker")
    self.cmd_cancelbanker = ExternalFun.read_netdata(g_var(cmd).CMD_S_CancelBanker, dataBuffer)
    
    --从申请列表移除
    local removeChairId = self._dataModle:removeApplyUserByNickname(self.cmd_cancelbanker.szCancelUser)
    self.cmd_cancelbanker.wCancelUser = removeChairId

    self._gameView:onGetCancelBanker()
end

--管理员命令
function GameLayer:onSubAdminCmd( dataBuffer )
    
end

--时间状态
function GameLayer:onSubTimeStatus( dataBuffer )
    local cmd_table = ExternalFun.read_netdata(g_var(cmd).SUB_S_TimeStatus, dataBuffer)
    local nStatus = cmd_table.btStatus
    local nTime = cmd_table.btTime

    print("### GameLayer:onSubTimeStatus status="..nStatus.."   time="..nTime)

    local id = nil
    local status = nil
    if nStatus == 1 then
        id = g_var(cmd).IDI_FREE
        status = g_var(cmd).GAME_SCENE_FREE
    elseif nStatus == 2 then
        id = g_var(cmd).IDI_PLACE_JETTON
        status = g_var(cmd).GS_PLACE_JETTON
    elseif nStatus == 3 then
        id = g_var(cmd).IDI_DISPATCH_CARD
        status = g_var(cmd).GS_GAME_END
    end

    if id ~= nil then
        self._gameView:showTimerTip(id,nTime) --SetGameClock

        --设置时间
        --self:SetGameClock(self:GetMeChairID(), g_var(cmd).IDI_PLACE_JETTON, self.cmd_gamestart.cbTimeLeave)

	    --设置状态
        self._cbGameStatus = status
    end
end

--更新库存
function GameLayer:onSubUpdateStorage( dataBuffer )
    
end

--积分结果
function GameLayer:OnSubScoreResult( dataBuffer )

end

--帐号结果
function GameLayer:OnSubAccountResult( dataBuffer )

end

function GameLayer:onEventUserEnter( wTableID,wChairID,useritem )
    print("add user " .. useritem.wChairID .. "; nick " .. useritem.szNickName)
    --缓存用户
    self._dataModle:addUser(useritem)
end

function GameLayer:onEventUserStatus(useritem,newstatus,oldstatus)
    print("change user " .. useritem.wChairID .. "; nick " .. useritem.szNickName)
    if newstatus.cbUserStatus == yl.US_FREE then
        print("删除")
        self._dataModle:removeUser(useritem)
    else
        --刷新用户信息
        self._dataModle:updateUser(useritem)
    end
end

function GameLayer:onEventUserScore( item )
    self._dataModle:updateUser(item)    
    self._gameView:onGetUserScore(item)
end
---------------------------------------------------------------------------------------
return GameLayer