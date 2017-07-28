local GameViewLayer = class("GameViewLayer",function(scene)
		local gameViewLayer =  display.newLayer()
    return gameViewLayer
end)
local module_pre = "game.yule.redninebattle.src"

--external
--
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local g_var = ExternalFun.req_var
local ClipText = appdf.EXTERNAL_SRC .. "ClipText"
local PopupInfoHead = appdf.EXTERNAL_SRC .. "PopupInfoHead"
--

local cmd = module_pre .. ".models.CMD_Game"
local game_cmd = appdf.HEADER_SRC .. "CMD_GameServer"
local QueryDialog   = require("app.views.layer.other.QueryDialog")

--utils
--
local LyGameResult = module_pre .. ".views.layer.GameResult"
local LyApplyList = module_pre .. ".views.layer.ApplyListLayer"
local SpCard = module_pre .. ".views.layer.CardSprite"
--

GameViewLayer.TAG_START				= 100
local enumTable = 
{
    "BT_AUDIO",
    "BT_HELP",
	"BT_EXIT",
    "BT_REQBANKER",
}
local TAG_ENUM = ExternalFun.declarEnumWithTable(GameViewLayer.TAG_START, enumTable);

local zorders = 
{
	"GAMERS_ZORDER",
    "USERLIST_ZORDER"
}
local TAG_ZORDER = ExternalFun.declarEnumWithTable(1, zorders);

local enumApply =
{
	"kCancelState",
	"kApplyState",
	"kApplyedState"
}
GameViewLayer._apply_state = ExternalFun.declarEnumWithTable(0, enumApply)
local APPLY_STATE = GameViewLayer._apply_state

--默认选中的筹码
local DEFAULT_BET = 1
--筹码运行时间
local BET_ANITIME = 0.2

--操作结果
local enOperateResult =
{
	"enOperateResult_NULL",
	"enOperateResult_Win",
	"enOperateResult_Lost"
}
local OPERATE_RESULT = ExternalFun.declarEnumWithTable(1, enOperateResult)


function GameViewLayer:ctor(scene)
	--注册node事件
	ExternalFun.registerNodeEvent(self)
	
	self._scene = scene
	self:gameDataInit();

	--初始化csb界面
	self:initCsbRes();
	--初始化通用动作
	self:initAction();
end

function GameViewLayer:loadRes(  )
	--加载卡牌纹理
	cc.Director:getInstance():getTextureCache():addImage("game_res/redNine_card.png");

    for i=1,9 do
        cc.Director:getInstance():getTextureCache():addImage("chip_res/chip"..i..".png");
    end

    cc.Director:getInstance():getTextureCache():addImage("res/BT_APPLY_BANKER.png");
    cc.Director:getInstance():getTextureCache():addImage("res/BT_CANCEL_APPLY.png");
end

function GameViewLayer:gameDataReset(  )
	--资源释放
	cc.Director:getInstance():getTextureCache():removeTextureForKey("game/redNine_card.png")

	--cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("setting/setting.plist")
	--cc.Director:getInstance():getTextureCache():removeTextureForKey("setting/setting.png")
	cc.Director:getInstance():getTextureCache():removeUnusedTextures()
	cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()


	--播放大厅背景音乐
	ExternalFun.playPlazzBackgroudAudio()

	--变量释放
	self.m_actDropIn:release();
	self.m_actDropOut:release();

	self:getDataMgr():removeAllUser()
	self:getDataMgr():clearRecord()
end

---------------------------------------------------------------------------------------
--界面初始化
function GameViewLayer:initCsbRes(  )
	local rootLayer, csbNode = ExternalFun.loadRootCSB("MainScene.csb", self);
	self.m_rootLayer = rootLayer

    --战绩层
    self.m_lyRecord = csbNode:getChildByName("ly_record")
    self:initRecords()

	--筹码
    self.m_lyChips = csbNode:getChildByName("chips")
    self:initChips()

    --时钟
    self.m_lyTimer = csbNode:getChildByName("timer")
    self:initTimer()

    --玩家信息
    self.m_lyUserInfo = csbNode:getChildByName("bottom")
    self:initUserInfo()
    
    --庄家信息
    self.m_lyBankerInfo = csbNode:getChildByName("face")
    self:initBankerInfo()
    
    --筹码区
    self:initDeskChips(csbNode)

    --发牌区
    self:initCard(csbNode)

    --Tips
    self.m_lyCenterTips = csbNode:getChildByName("center_tip")
    self.m_lyCenterTips:setVisible(false)

	--初始化按钮
	self:initBtn(csbNode)
end

function GameViewLayer:reSetForNewGame(  )
	--重置下注区域
	self:cleanJettonArea()

    --关闭结果UI
    self:showGameResult(false)

    self:reSetCard()
end

--初始化战绩
function GameViewLayer:initRecords()
    for i=0,9 do
        for j=0,2 do
            local node = self.m_lyRecord:getChildByName("s_" .. i .. "_" .. j)
            node:setProperty(str, "game_res/WIN_FLAGS.png", 26, 24, "0")
            node:setString("1")
            node:setVisible(false)
        end
    end
end

--初始化下注区
function GameViewLayer:initChips()
    local clip_layout = self.m_lyChips;

	local function clipEvent( sender, eventType )
		if eventType == ccui.TouchEventType.ended then
			self:onJettonButtonClicked(sender:getTag(), sender);
		end
	end

	for i=1,#self.m_pJettonNumber do
		local tag = i - 1
		local str = string.format("Btn_%d", tag)
		local btn = clip_layout:getChildByName(str)
		btn:setTag(i)
		btn:addTouchEventListener(clipEvent)
		self.m_tableJettonBtn[i] = btn
		self.m_tabJettonAnimate[i] = btn:getChildByName("effect")
	end

	self:reSetJettonBtnInfo(false);
end

--初始化时钟
function GameViewLayer:initTimer()
    local timer_layout = self.m_lyTimer
	--倒计时
	self.m_lyTimer.m_lbNum = timer_layout:getChildByName("lbNum")
	self.m_lyTimer.m_lbNum:setString("")

	--提示
	self.m_lyTimer.m_spTip = timer_layout:getChildByName("spTips")
    self.m_lyTimer.m_spTip:setTexture("res/green_edit.png")

    self.m_lyTimer.m_actRun = timer_layout:getChildByName("actRun")

    local rotate1 = cc.RotateTo:create(1.5, 180.0)
    local rotate2 = cc.RotateTo:create(1.5, 360.0)
    local seq = cc.Sequence:create(rotate1, rotate2)
    local repeatForever = cc.RepeatForever:create(seq)
    self.m_lyTimer.m_actRun:runAction(repeatForever)
    --self.m_lyTimer.m_actRun:stopAllActions()
end

--初始化按钮
function GameViewLayer:initBtn( csbNode )
    local function btnEvent( sender, eventType )
		if eventType == ccui.TouchEventType.ended then
			self:onButtonClickedEvent(sender:getTag(), sender);
		end
	end	

    -- 音效
	self.m_btnAudio = csbNode:getChildByName("Btn_Audio");
	self.m_btnAudio:setTag(TAG_ENUM.BT_AUDIO);
	self.m_btnAudio:addTouchEventListener(btnEvent);

    -- 帮助
	btn = csbNode:getChildByName("Btn_Help");
	btn:setTag(TAG_ENUM.BT_HELP);
	btn:addTouchEventListener(btnEvent);

    -- 退出
	btn = csbNode:getChildByName("Btn_Exit");
	btn:setTag(TAG_ENUM.BT_EXIT);
	btn:addTouchEventListener(btnEvent);

    self:refreshMusicBtnState();
end

function GameViewLayer:refreshMusicBtnState(  )
	local str = nil
	if GlobalUserItem.bVoiceAble then
		str = "res/sound_on.png"
	else
		str = "res/sound_off.png"
	end
	if nil ~= str then
		self.m_btnAudio:loadTextureDisabled(str)--,UI_TEX_TYPE_PLIST)
		self.m_btnAudio:loadTextureNormal(str)--,UI_TEX_TYPE_PLIST)
		self.m_btnAudio:loadTexturePressed(str)--,UI_TEX_TYPE_PLIST)
	end
end

--初始化庄家信息
function GameViewLayer:initBankerInfo( )
	local banker_layout = self.m_lyBankerInfo

    --庄家头像
    self.m_spBankerIcon = banker_layout:getChildByName("face_icon")
    --庄家昵称
    self.m_textBankerNickname = banker_layout:getChildByName("face_nickname")
    --庄家金币
    self.m_textBankerCoint = banker_layout:getChildByName("face_gold")

    --申请坐庄按钮
    local function btnEvent( sender, eventType )
		if eventType == ccui.TouchEventType.ended then
			self:onButtonClickedEvent(sender:getTag(), sender);
		end
	end	

    self.m_btnReqBanker = banker_layout:getChildByName("btn_reqZhuang")
    self.m_btnReqBanker:setTag(TAG_ENUM.BT_REQBANKER);
	self.m_btnReqBanker:addTouchEventListener(btnEvent)

	self:reSetBankerInfo()
end

function GameViewLayer:reSetBankerInfo(  )
    --self.m_spBankerIcon:setVisible(false)
	self.m_textBankerNickname:setString("")
	self.m_textBankerCoint:setString("")
end

--初始化玩家信息
function GameViewLayer:initUserInfo(  )	
    local bottom_layout = self.m_lyUserInfo

    --玩家昵称
    self.m_textUseNickName = bottom_layout:getChildByName("nickname"):getChildByName("text")
    --玩家金币
    self.m_textUserCoint = bottom_layout:getChildByName("gold"):getChildByName("text")
    --玩家已下注
    self.m_textUserJetton = bottom_layout:getChildByName("jetton"):getChildByName("text")
    --玩家成绩
    self.m_textUserScore = bottom_layout:getChildByName("score"):getChildByName("text")

	self:reSetUserInfo()
end

function GameViewLayer:SetCurGameScore()
    local Jetton = 0
    for i=1,3 do
        Jetton = Jetton + self.m_lUserJettonScore[i]
    end

    local str = ExternalFun.numberThousands(Jetton)
	if string.len(str) > 11 then
		str = string.sub(str,1,11) .. "..."
	end
    self.m_textUserJetton:setString(str)

    local Score = self.m_lMeCurGameScore

    str = ExternalFun.numberThousands(Score)
	if string.len(str) > 11 then
		str = string.sub(str,1,11) .. "..."
	end
    self.m_textUserScore:setString(str)
end

function GameViewLayer:reSetUserInfo(  )
	self.m_scoreUser = 0
	local myUser = self:getMeUserItem()
	if nil ~= myUser then
		self.m_scoreUser = myUser.lScore
        self.m_nicknameUser = myUser.szNickName
	end	
	
    self.m_textUseNickName:setString(self.m_nicknameUser)
    
	local str = ExternalFun.numberThousands(self.m_scoreUser)
	if string.len(str) > 11 then
		str = string.sub(str,1,7) .. "..."
	end
	self.m_textUserCoint:setString(str)
end

--初始化桌面筹码区
function GameViewLayer:initDeskChips(csbNode)
	--按钮列表
	local function btnEvent( sender, eventType )
		if eventType == ccui.TouchEventType.ended then
			self:onJettonAreaClicked(sender:getTag(), sender);
		end
	end

	for i=1,3 do
		local tag = i - 1;
		local str = string.format("deskChip%d", tag)
		local tag_btn = csbNode:getChildByName(str);
		tag_btn:setTag(i);
		tag_btn:addTouchEventListener(btnEvent);
        tag_btn.m_llMyTotal = 0
	    tag_btn.m_llAreaTotal = 0
		self.m_tableJettonArea[i] = tag_btn

        str = string.format("lbScore%d", tag)
        local area_score = csbNode:getChildByName(str)
        area_score:setString("0")
        self.m_tableJettonScore[i] = area_score

        str = string.format("lbNum%d", tag)
        local area_num = csbNode:getChildByName(str)
        area_num:setString("0")
        self.m_tableJettonNum[i] = area_num
	end

    self:reSetJettonArea(false)
end

function GameViewLayer:reSetJettonArea( var )
	for i=1,#self.m_tableJettonArea do
		self.m_tableJettonArea[i]:setEnabled(var);
	end
end

--初始化发牌区
function GameViewLayer:initCard(csbNode)
    --上边Card
    self.m_lyCardUp = csbNode:getChildByName("card_up")
    --下边Card
    self.m_lyCardDown = csbNode:getChildByName("card_down")
    --左边Card
    self.m_lyCardLeft = csbNode:getChildByName("card_left")
    --右边Card
    self.m_lyCardRight = csbNode:getChildByName("card_right")
    --中间Card
    self.m_lyCardStart = csbNode:getChildByName("card_start_index")

    self:reSetCard(false)
end

function GameViewLayer:reSetCard(var)
    self.m_lyCardUp:setVisible(var)
    self.m_lyCardDown:setVisible(var)
    self.m_lyCardLeft:setVisible(var)
    self.m_lyCardRight:setVisible(var)
    self.m_lyCardStart:setVisible(var)

    self.m_lyCardStart:removeAllChildren()
end

function GameViewLayer:enableJetton( var )
	--下注按钮
	self:reSetJettonBtnInfo(var);

	--下注区域
	self:reSetJettonArea(var);
end

function GameViewLayer:reSetJettonBtnInfo( var )
    for i=1,#self.m_tableJettonBtn do
		self.m_tableJettonBtn[i]:setTag(i)
		self.m_tableJettonBtn[i]:setEnabled(var)

		self.m_tabJettonAnimate[i]:stopAllActions()
		self.m_tabJettonAnimate[i]:setVisible(false)
	end
end

function GameViewLayer:adjustJettonBtn(  )
	--可以下注的数额
	local lCanJetton = self.m_llMaxJetton - self.m_lHaveJetton;
	local lCondition = math.min(self.m_scoreUser, lCanJetton);

	for i=1,#self.m_tableJettonBtn do
		local enable = false
		if self.m_bOnGameRes then
			enable = false
		else
			enable = self.m_bOnGameRes or (lCondition >= self.m_pJettonNumber[i].k)
		end
		self.m_tableJettonBtn[i]:setEnabled(enable);
	end

	if self.m_nJettonSelect > self.m_scoreUser then
		self.m_nJettonSelect = -1;
	end

	--筹码动画
	local enable = lCondition >= self.m_pJettonNumber[self.m_nSelectBet].k;
	if false == enable then
		self.m_tabJettonAnimate[self.m_nSelectBet]:stopAllActions()
		self.m_tabJettonAnimate[self.m_nSelectBet]:setVisible(false)
	end
end

function GameViewLayer:switchJettonBtnState( idx )
	for i=1,#self.m_tabJettonAnimate do
		self.m_tabJettonAnimate[i]:stopAllActions()
		self.m_tabJettonAnimate[i]:setVisible(false)
	end

	--可以下注的数额
	local lCanJetton = self.m_llMaxJetton - self.m_lHaveJetton;
	local lCondition = math.min(self.m_scoreUser, lCanJetton);
	if nil ~= idx and nil ~= self.m_tabJettonAnimate[idx] then
		local enable = lCondition >= self.m_pJettonNumber[idx].k;
		if enable then
			--local blink = cc.Blink:create(1.0,1)
			local rotate1 = cc.RotateTo:create(1.0, 180.0)
            local rotate2 = cc.RotateTo:create(1.0, 360.0)
            local seq = cc.Sequence:create(rotate1, rotate2)
            self.m_tabJettonAnimate[idx]:runAction(cc.RepeatForever:create(seq))
            self.m_tabJettonAnimate[idx]:setVisible(true)
		end		
	end
end

function GameViewLayer:cleanJettonArea(  )
	--移除界面已下注
    for i=1,#self.m_tableJettonArea do
        self.m_tableJettonArea[i]:removeAllChildren()
        self.m_tableJettonArea[i].m_llMyTotal = 0
	    self.m_tableJettonArea[i].m_llAreaTotal = 0
	    self.m_tableJettonScore[i]:setString("0")
        self.m_tableJettonNum[i]:setString("0")
	end

    self.m_lUserJettonScore = {0,0,0}
    self.m_textUserJetton:setString("0")
end

function GameViewLayer:initAction(  )
	local dropIn = cc.ScaleTo:create(0.2, 1.0);
	dropIn:retain();
	self.m_actDropIn = dropIn;

	local dropOut = cc.ScaleTo:create(0.2, 1.0, 0.0000001);
	dropOut:retain();
	self.m_actDropOut = dropOut;
end
---------------------------------------------------------------------------------------

function GameViewLayer:onButtonClickedEvent(tag,ref)
	ExternalFun.playClickEffect()
	if tag == TAG_ENUM.BT_EXIT then
		self:getParentNode():onQueryExitGame()
    elseif tag == TAG_ENUM.BT_AUDIO then
        local music = not GlobalUserItem.bVoiceAble;
	    GlobalUserItem.setVoiceAble(music)
	    self:refreshMusicBtnState()
	    if GlobalUserItem.bVoiceAble == true then
		    ExternalFun.playBackgroudAudio("GAME_BLACKGROUND.wav")
	    end
    elseif tag == TAG_ENUM.BT_HELP then
        self:getParentNode():getParentNode():popHelpLayer2(122, 0, yl.ZORDER.Z_HELP_BUTTON)
    elseif tag == TAG_ENUM.BT_REQBANKER then
        --self:applyBanker( state )
		if nil == self.m_applyListLayer then
			self.m_applyListLayer = g_var(LyApplyList):create(self)
			self:addToRootLayer(self.m_applyListLayer, TAG_ZORDER.USERLIST_ZORDER)
		end
		local userList = self:getDataMgr():getApplyBankerUserList()		
		self.m_applyListLayer:refreshList(userList)
	else
		showToast(self,"功能尚未开放！",1)
	end
end

function GameViewLayer:onJettonButtonClicked( tag, ref )
	if tag >= 1 and tag <= 6 then
		self.m_nJettonSelect = self.m_pJettonNumber[tag].k;
	else
		self.m_nJettonSelect = -1;
	end

	self.m_nSelectBet = tag
	self:switchJettonBtnState(tag)
	print("click jetton:" .. self.m_nJettonSelect);
end

function GameViewLayer:onJettonAreaClicked( tag, ref )
	local m_nJettonSelect = self.m_nJettonSelect;

	if m_nJettonSelect < 0 then
		return;
	end

	local area = tag-- - 1;	
	if self.m_lHaveJetton > self.m_llMaxJetton then
		showToast(self,"已超过最大下注限额",1)
		self.m_lHaveJetton = self.m_lHaveJetton - m_nJettonSelect;
		return;
	end

	--下注
	self:getParentNode():sendUserBet(area, m_nJettonSelect);	
end

function GameViewLayer:showGameResult( bShow )
	if true == bShow then
		if nil == self.m_gameResultLayer then
			self.m_gameResultLayer = g_var(LyGameResult):create()
			self:addToRootLayer(self.m_gameResultLayer, TAG_ZORDER.GAMERS_ZORDER)
		end

        local cmd_gameend = self:getDataMgr().m_tabGameEndCmd
        local rs = self:getDataMgr().m_tabGameResult

        if nil ~= cmd_gameend then
            dump(cmd_gameend, "   &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&   ")
            rs.lEndUserScore = cmd_gameend.lUserScore
            rs.lEndUserReturnScore = cmd_gameend.lUserReturnScore
            rs.lEndBankerScore = cmd_gameend.lBankerScore
        else
            return
        end

		self.m_gameResultLayer:showGameResult(rs)
	else
		if nil ~= self.m_gameResultLayer then
			self.m_gameResultLayer:hideGameResult()
		end
	end
end

function GameViewLayer:onResetView()
	self:stopAllActions()
	self:gameDataReset()
end

function GameViewLayer:onExit()
	self:onResetView()
end

--上庄状态
function GameViewLayer:applyBanker( state )
	if state == APPLY_STATE.kCancelState then
		self:getParentNode():sendApplyBanker()		
	elseif state == APPLY_STATE.kApplyState then
		self:getParentNode():sendCancelApply()
	elseif state == APPLY_STATE.kApplyedState then
		self:getParentNode():sendCancelApply()		
	end
end

---------------------------------------------------------------------------------------
--网络消息

------
--网络接收
function GameViewLayer:onGetUserScore( item )
	--自己
	if item.dwUserID == GlobalUserItem.dwUserID then
       self:reSetUserInfo()
    end

    --庄家
    if self.m_wBankerUser == item.wChairID then
    	--庄家金币
		local str = string.formatNumberThousands(item.lScore);
		if string.len(str) > 11 then
			str = string.sub(str, 1, 9) .. "...";
		end
		self.m_textBankerCoint:setString(str);
    end
end

function GameViewLayer:refreshCondition(  )
    if true == self:isMeChair(self.m_wBankerUser) then
        self.m_btnReqBanker:loadTextureNormal("res/BT_CANCEL_APPLY.png")
        self.m_btnReqBanker:loadTexturePressed("res/BT_CANCEL_APPLY.png")
        self.m_btnReqBanker:loadTextureDisabled("res/BT_CANCEL_APPLY.png")
    else
        self.m_btnReqBanker:loadTextureNormal("res/BT_APPLY_BANKER.png")
        self.m_btnReqBanker:loadTexturePressed("res/BT_APPLY_BANKER.png")
        self.m_btnReqBanker:loadTextureDisabled("res/BT_APPLY_BANKER.png")
	    
		local useritem = self:getMeUserItem()
		ExternalFun.enableBtn(self.m_btnReqBanker, useritem.lScore >= self.m_llBankerConsume)
    end
end

--游戏free
function GameViewLayer:onGameFree( )
	self:reSetForNewGame()

	--上庄条件刷新
	self:refreshCondition()
end

--游戏开始
function GameViewLayer:onGameStart( )
	self.m_nJettonSelect = self.m_pJettonNumber[DEFAULT_BET].k;
	self.m_lHaveJetton = 0;

	--获取玩家携带游戏币	
	self:reSetUserInfo();

	self.m_bOnGameRes = false

	--不是自己庄家,且有庄家
	if false == self:isMeChair(self.m_wBankerUser) then
		--下注
		self:enableJetton(true);
		--调整下注按钮
		self:adjustJettonBtn();

		--默认选中的筹码
		self:switchJettonBtnState(DEFAULT_BET)
	end	

	math.randomseed(tostring(os.time()):reverse():sub(1, 6))
end

--游戏进行
function GameViewLayer:reEnterStart( lUserJetton )
	self.m_nJettonSelect = self.m_pJettonNumber[DEFAULT_BET].k;
	self.m_lHaveJetton = lUserJetton;

	--获取玩家携带游戏币
	self.m_scoreUser = 0
	self:reSetUserInfo();

	self.m_bOnGameRes = false

	--不是自己庄家
	if false == self:isMeChair(self.m_wBankerUser) then
		--下注
		self:enableJetton(true);
		--调整下注按钮
		self:adjustJettonBtn();

		--默认选中的筹码
		self:switchJettonBtnState(DEFAULT_BET)
	end		
end

--更新用户下注
function GameViewLayer:onGetUserBet( )
	local data = self:getParentNode().cmd_placebet;
	if nil == data then
		return
	end

	local area = data.cbJettonArea
	local wUser = data.wChairID
	local llScore = data.lJettonScore

	local nIdx = self:getJettonIdx(llScore);
	local str = string.format("chip_res/chip%d.png", nIdx);
	local sp = nil
	--[[local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(str)
    if nil ~= frame then
		sp = cc.Sprite:createWithSpriteFrame(frame);
	end]]
    sp = cc.Sprite:create(str)
	local btn = self.m_tableJettonArea[area];
	if nil == sp then
		print("sp nil");
	end

	if nil == btn then
		print("btn nil");
	end
	if nil ~= sp and nil ~= btn then
		--下注
		sp:setScale(3.0);
		sp:setTag(wUser);
		local name = string.format("%d", area) --ExternalFun.formatScore(data.lBetScore);
		sp:setName(name)
		
		--筹码飞行起点位置
		--local pos = self.m_betAreaLayout:convertToNodeSpace(self:getBetFromPos(wUser))
        --local pos = self.m_betAreaLayout:convertToNodeSpace(self:getBetFromPos(wUser))
        --sp:setPosition(self.m_tableJettonBtn[nIdx-1]:getPosition())
		sp:setPosition(self:getBetRandomPos(btn))
        btn:addChild(sp)

		self:refreshJettonNode(btn, llScore, llScore, self:isMeChair(wUser))
	end

	if self:isMeChair(wUser) then
		self.m_scoreUser = self.m_scoreUser - self.m_nJettonSelect;
		self.m_lHaveJetton = self.m_lHaveJetton + llScore;
		
		--调整下注按钮
		self:adjustJettonBtn();
	end
end

--更新用户下注失败
function GameViewLayer:onGetUserBetFail(  )
	local data = self:getParentNode().cmd_jettonfail;
	if nil == data then
		return;
	end

	--下注玩家
	local wUser = data.wPlaceUser;
	--下注区域
	local cbArea = data.lJettonArea;
	--下注数额
	local llScore = data.lPlaceScore;

	if self:isMeChair(wUser) then
		--提示下注失败
		local str = string.format("下注 %s 失败", ExternalFun.formatScore(llScore))
		showToast(self,str,1)

		--自己下注失败
		self.m_scoreUser = self.m_scoreUser + llScore
		self.m_lHaveJetton = self.m_lHaveJetton - llScore
		self:adjustJettonBtn()

		--
		if 0 ~= self.m_lHaveJetton then
            local btnArea = self.m_tableJettonArea[cbArea]
			self:refreshJettonNode(btnArea,-llScore, -llScore, true)
			--移除界面下注元素
			local name = string.format("%d", cbArea)
			btnArea:removeChildByName(name)
		end
	end
end

--断线重连更新界面已下注
function GameViewLayer:reEnterGameBet( cbArea, llScore )
	local btn = self.m_tableJettonArea[cbArea];
	if nil == btn or 0 == llSocre then
		return;
	end

	local vec = self:getDataMgr().calcuteJetton(llScore, false);
	for k,v in pairs(vec) do
		local info = v;
		for i=1,info.m_cbCount do
			local str = string.format("chip_res/chip%d.png", info.m_cbIdx);
			local sp = cc.Sprite:create(str)--WithSpriteFrameName(str);
			if nil ~= sp then
				sp:setScale(3.0)--0.35);
				sp:setTag(yl.INVALID_CHAIR);
				local name = string.format("%d", cbArea) --ExternalFun.formatScore(info.m_llScore);
				sp:setName(name);

				self:randomSetJettonPos(btn, sp);
				btn:addChild(sp);
			end
		end
	end

	self:refreshJettonNode(btn, llScore, llScore, false)
end

--断线重连更新玩家已下注
function GameViewLayer:reEnterUserBet( cbArea, llScore )
	local btn = self.m_tableJettonArea[cbArea];
	if nil == btn or 0 == llSocre then
		return;
	end

	self:refreshJettonNode(btn, llScore, 0, true)
end

function GameViewLayer:onEventGameSceneEnd(  )
    local cmd_gameend = self:getDataMgr().m_tabGameSceneEndCmd
	if nil == cmd_gameend or cmd_gameend.cbTableCardArray == nil then
		return
	end

    self.m_lyCardStart:stopAllActions()

    self:initHandCard(self.m_lyCardUp, cmd_gameend.cbTableCardArray[1])
    self:initHandCard(self.m_lyCardLeft, cmd_gameend.cbTableCardArray[2])
    self:initHandCard(self.m_lyCardDown, cmd_gameend.cbTableCardArray[3])
    self:initHandCard(self.m_lyCardRight, cmd_gameend.cbTableCardArray[4])

    self:showCardEnd(self.m_lyCardUp)
    self:showCardEnd(self.m_lyCardDown)
    self:showCardEnd(self.m_lyCardLeft)
    self:showCardEnd(self.m_lyCardRight)

    self.m_bOnGameRes = false

    self:enableJetton(false)
end

function GameViewLayer:showCardEnd(node)
    local card1 = node:getChildByTag(1)
    card1:setVisible(true)
    card1:getChildByTag(1):showCardBack(false)

    local card2 = node:getChildByTag(2)
    card2:setVisible(true)
    card2:getChildByTag(1):showCardBack(false)
end

--游戏结束
function GameViewLayer:onGetGameEnd(  )
    local cmd_gameend = self:getDataMgr().m_tabGameEndCmd
	if nil == cmd_gameend then
		return
	end

    self.m_lMeCurGameScore = self.m_lMeCurGameScore + cmd_gameend.lUserScore

    local cbCardData = cmd_gameend.cbLeftCardCount
    local spCard = g_var(SpCard):createCard(cbCardData)
    spCard:setTag(1)
    self.m_lyCardStart:addChild(spCard)
    self.m_lyCardStart:setVisible(true)

    local callfunc = cc.CallFunc:create(function()
        local callfunc1 = cc.CallFunc:create(function()
            self.m_lyCardStart:setVisible(false)
            self:showCard()
        end)

        local spCard = self.m_lyCardStart:getChildByTag(1)
        spCard:showCardBack(true)

        local act = cc.Sequence:create(cc.DelayTime:create(0.5), callfunc1)
        self.m_lyCardStart:runAction(act)
	end)
    local act = cc.Sequence:create(cc.DelayTime:create(0.5), callfunc)
    self.m_lyCardStart:runAction(act)

	self.m_bOnGameRes = true

	--不可下注
	self:enableJetton(false)
end

function GameViewLayer:showCard()
    local cmd_gameend = self:getDataMgr().m_tabGameEndCmd
    if nil == cmd_gameend or cmd_gameend.cbTableCardArray == nil then
		return
	end

    self:showTipsAnimate("game_res/WAITING.png")

    self:initHandCard(self.m_lyCardUp, cmd_gameend.cbTableCardArray[1])
    self:initHandCard(self.m_lyCardLeft, cmd_gameend.cbTableCardArray[2])
    self:initHandCard(self.m_lyCardDown, cmd_gameend.cbTableCardArray[3])
    self:initHandCard(self.m_lyCardRight, cmd_gameend.cbTableCardArray[4])

    self.m_dealCardIdx = 0

    self:dealCard()

    local callfunc = cc.CallFunc:create(function()
        self.m_dealCardIdx = 0

        self:dealCard1()
    end)

    local callfunc1 = cc.CallFunc:create(function()
        self:showGameResult(true)

        --推断赢家
	    local bWinShunMen,bWinDuiMen,bWinDaoMen = self:getDataMgr():DeduceWinner()
	
        --读取记录列表
        self:SetGameHistory(bWinShunMen, bWinDaoMen, bWinDuiMen)

        self:updateRecord()

        self:SetCurGameScore()
    end)

    local act = cc.Sequence:create(cc.DelayTime:create(4), callfunc, cc.DelayTime:create(8), callfunc1)
    self.m_lyCardStart:runAction(act)
end

function GameViewLayer:initHandCard(node, cbTableCardArray)
    node:setVisible(true)

    local card1 = node:getChildByName("card1")
    card1:setTag(1)
    card1:setVisible(false)
    local card2 = node:getChildByName("card2")
    card2:setTag(2)
    card2:setVisible(false)
    local hand_l = node:getChildByName("hand_l")
    hand_l:setTag(3)
    hand_l:setVisible(false)
    local hand_r = node:getChildByName("hand_r")
    hand_r:setTag(4)
    hand_r:setVisible(false)
    local ndStart = node:getChildByName("nd_start")
    ndStart:setTag(5)

    card1:removeAllChildren()
    local cbCardData1 = cbTableCardArray[1]
    local spCard1 = g_var(SpCard):createCard(cbCardData1)
    spCard1:setTag(1)
    spCard1:showCardBack(true)
    card1:addChild(spCard1)

    card2:removeAllChildren()
    local cbCardData2 = cbTableCardArray[2]
    local spCard2 = g_var(SpCard):createCard(cbCardData2)
    spCard2:setTag(1)
    spCard2:showCardBack(true)
    card2:addChild(spCard2)
end

function GameViewLayer:dealCard()
    if self.m_dealCardIdx >= 4 or self.m_bOnGameRes == false then
        return
    end

    local cmd_gameend = self:getDataMgr().m_tabGameEndCmd
    if cmd_gameend.cbLeftCardCount == nil then
        return
    end

    local seatNum = (cmd_gameend.cbLeftCardCount + self.m_dealCardIdx) % 4
    local node = self.m_lyCardRight
    if seatNum == 1 then
        node = self.m_lyCardUp
    elseif seatNum == 2 then
        node = self.m_lyCardLeft
    elseif seatNum == 3 then
        node = self.m_lyCardDown
    end

    local ndStart = node:getChildByTag(5)

    local card1 = node:getChildByTag(1)
    local p1X,p1Y = card1:getPosition()
    card1:setPosition(ndStart:getPosition())
    card1:setVisible(true)
    local act1 = cc.MoveTo:create(0.4, cc.p(p1X,p1Y))

    local callfunc = cc.CallFunc:create(function()
        local card2 = node:getChildByTag(2)
        local p2X,p2Y = card2:getPosition()
        card2:setPosition(ndStart:getPosition())
        card2:setVisible(true)
        local act2 = cc.MoveTo:create(0.4, cc.p(p2X,p2Y))
        
        local callfunc1 = cc.CallFunc:create(function()
            local card2 = node:getChildByTag(2)
            card2:getChildByTag(1):showCardBack(false)
            
            self.m_dealCardIdx = self.m_dealCardIdx + 1

            self:dealCard()
        end)

        local act = cc.Sequence:create(act2, callfunc1)
        card2:runAction(act)
    end)

    local act = cc.Sequence:create(act1,callfunc)
    card1:runAction(act)
end

function GameViewLayer:dealCard1(seatNum)
    if self.m_dealCardIdx >= 4 or self.m_bOnGameRes == false then
        return
    end

    local cmd_gameend = self:getDataMgr().m_tabGameEndCmd
    if cmd_gameend.cbLeftCardCount == nil then
        return
    end

    local seatNum = (cmd_gameend.cbLeftCardCount + self.m_dealCardIdx) % 4
    local node = self.m_lyCardRight
    if seatNum == 1 then
        node = self.m_lyCardUp
    elseif seatNum == 2 then
        node = self.m_lyCardLeft
    elseif seatNum == 3 then
        node = self.m_lyCardDown
    end

    local card1 = node:getChildByTag(1)
    card1:getChildByTag(1):showCardBack(false)
    local card2 = node:getChildByTag(2)
    local hand_l = node:getChildByTag(3)
    hand_l:setVisible(true)
    local hand_r = node:getChildByTag(4)
    hand_r:setVisible(true)

    local callfunc = cc.CallFunc:create(function()
        node:getChildByTag(3):setVisible(false)
        node:getChildByTag(4):setVisible(false)

        self.m_dealCardIdx = self.m_dealCardIdx + 1

        self:dealCard1()
    end)

    local act = cc.Sequence:create(cc.MoveBy:create(1, cc.p(50,0)), cc.MoveBy:create(1, cc.p(-50,0)))
    local act_1 = cc.Sequence:create(cc.MoveBy:create(1, cc.p(50,0)), cc.MoveBy:create(1, cc.p(-50,0)), callfunc)

    card2:runAction(act)
    hand_r:runAction(act_1)
end

--刷新列表
function GameViewLayer:refreshApplyList(  )
	if nil ~= self.m_applyListLayer and self.m_applyListLayer:isVisible() then
		local userList = self:getDataMgr():getApplyBankerUserList()		
		self.m_applyListLayer:refreshList(userList)
	end
end
---------------------------------------------------------------------------------------
function GameViewLayer:getParentNode( )
	return self._scene;
end

function GameViewLayer:getMeUserItem(  )
	if nil ~= GlobalUserItem.dwUserID then
		return self:getDataMgr():getUidUserList()[GlobalUserItem.dwUserID];
	end
	return nil;
end

function GameViewLayer:isMeChair( wchair )
	local useritem = self:getDataMgr():getChairUserList()[wchair + 1];
	if nil == useritem then
		return false
	else 
		return useritem.dwUserID == GlobalUserItem.dwUserID
	end
end

function GameViewLayer:addToRootLayer( node , zorder)
	if nil == node then
		return
	end
    local contentSize = self.m_rootLayer:getContentSize()
    node:setPosition(cc.p(contentSize.width/2,contentSize.height/2))
	self.m_rootLayer:addChild(node)
	node:setLocalZOrder(zorder)
end

function GameViewLayer:getDataMgr( )
	return self:getParentNode():getDataMgr()
end

function GameViewLayer:logData(msg)
	local p = self:getParentNode()
	if nil ~= p.logData then
		p:logData(msg)
	end	
end

function GameViewLayer:showPopWait( )
	self:getParentNode():showPopWait()
end

function GameViewLayer:dismissPopWait( )
	self:getParentNode():dismissPopWait()
end

function GameViewLayer:gameDataInit( )
    --播放背景音乐
    ExternalFun.playBackgroudAudio("GAME_BLACKGROUND.wav")

    --用户列表
	self:getDataMgr():initUserList(self:getParentNode():getUserList())

    --加载资源
	self:loadRes()

	--变量声明
    self.m_nRecordLast = 1
    self.m_nRecordFirst = 1
    self.m_GameRecordArrary = {}

    self.m_lUserJettonScore = {0,0,0}
    self.m_lMeCurGameScore = 0

    --筹码面额
    self.m_pJettonNumber = 
	{
		{k = 1000, i = 2},
		{k = 10000, i = 3}, 
		{k = 50000, i = 4}, 
		{k = 100000, i = 5}, 
		{k = 500000, i = 6},
		{k = 1000000, i = 7},
        {k = 5000000, i = 8} 
	}

    --下注信息
	self.m_tableJettonBtn = {};
    self.m_tabJettonAnimate = {}

    --下注区信息
    self.m_tableJettonArea = {}
    self.m_tableJettonScore = {}
    self.m_tableJettonNum = {}

    --庄家信息
    self.m_wBankerUser = yl.INVALID_CHAIR
	self.m_wBankerTime = 0
	self.m_lBankerWinScore = 0
	self.m_lTmpBankerWinScore = 0
	self.m_lBankerScore = 0

    --上庄消耗金币
    self.m_llBankerConsume = 0

    self.m_applyListLayer = nil
    --申请状态
	self.m_enApplyState = APPLY_STATE.kCancelState

	self.m_nJettonSelect = -1
	self.m_lHaveJetton = 0;
	self.m_llMaxJetton = 0;
	self.m_scoreUser = self:getMeUserItem().lScore or 0

	self.m_gameResultLayer = nil
	self.m_pClock = nil

	--自己坐下
	self.m_nSelfSitIdx = nil

	--选中的筹码
	self.m_nSelectBet = DEFAULT_BET

	--是否结算状态
	self.m_bOnGameRes = false
end

function GameViewLayer:getJettonIdx( llScore )
	local idx = 2;
	for i=1,#self.m_pJettonNumber do
		if llScore == self.m_pJettonNumber[i].k then
			idx = self.m_pJettonNumber[i].i;
			break;
		end
	end
	return idx;
end

function GameViewLayer:randomSetJettonPos( nodeArea, jettonSp )
	if nil == jettonSp then
		return;
	end

	local pos = self:getBetRandomPos(nodeArea)
	jettonSp:setPosition(cc.p(pos.x, pos.y));
end

function GameViewLayer:getBetRandomPos(nodeArea)
	if nil == nodeArea then
		return {x = 0, y = 0}
	end

	local nodeSize = cc.size(nodeArea:getContentSize().width - 100, nodeArea:getContentSize().height - 100);
	local xOffset = math.random(0, nodeSize.width)
	local yOffset = math.random(0, nodeSize.height)

	local posX = xOffset + 50--nodeArea:getPositionX() - nodeArea:getAnchorPoint().x * nodeSize.width
	local posY = yOffset + 50--nodeArea:getPositionY() - nodeArea:getAnchorPoint().y * nodeSize.height
	--return cc.p(xOffset * nodeSize.width + posX, yOffset * nodeSize.height + posY)
    return cc.p(posX, posY)
end

------
function GameViewLayer:updateClock(tag, left)

end

function GameViewLayer:showTimerTip(tag,time)
    self.m_lyTimer.m_spTip:setTexture("game_res/time"..tag..".png")

    local str = string.format("%02d", time)
	self.m_lyTimer.m_lbNum:setString(str)
end
------

------
--下注节点
function GameViewLayer:createJettonNode()
	local jettonNode = cc.Node:create()
	--加载csb资源
	local csbNode = ExternalFun.loadCSB("game/JettonNode.csb", jettonNode)

	local m_imageBg = csbNode:getChildByName("jetton_bg")
	local m_textMyJetton = m_imageBg:getChildByName("jetton_my")
	local m_textTotalJetton = m_imageBg:getChildByName("jetton_total")

	jettonNode.m_imageBg = m_imageBg
	jettonNode.m_textMyJetton = m_textMyJetton
	jettonNode.m_textTotalJetton = m_textTotalJetton
	jettonNode.m_llMyTotal = 0
	jettonNode.m_llAreaTotal = 0

	return jettonNode
end

function GameViewLayer:refreshJettonNode( node, my, total, bMyJetton )	
	if true == bMyJetton then
		node.m_llMyTotal = node.m_llMyTotal + my
	end

	node.m_llAreaTotal = node.m_llAreaTotal + total
	node:setVisible( true )--node.m_llAreaTotal > 0)

    local tag = node:getTag()

	--自己下注数额
	local str = ExternalFun.numberThousands(node.m_llMyTotal);
	if string.len(str) > 15 then
		str = string.sub(str,1,12)
		str = str .. "...";
	end
    self.m_tableJettonNum[tag]:setString(str)
	--node.m_textMyJetton:setString(str);

    self.m_lUserJettonScore[tag] = node.m_llMyTotal

	--总下注
	str = ExternalFun.numberThousands(node.m_llAreaTotal)
	str = " " .. str;
	if string.len(str) > 15 then
		str = string.sub(str,1,12)
		str = str .. "..."
	else
		local strlen = string.len(str)
		local l = 15 + strlen
		if strlen > l then
			str = string.sub(str, 1, l - 3);
			str = str .. "...";
		end
	end
    self.m_tableJettonScore[tag]:setString(str)

    self:SetCurGameScore()
end
------

------
--银行节点
function GameViewLayer:SetGameHistory( bWinShunMen, bWinDaoMen, bWinDuiMen )
    local lastIdx = self.m_nRecordLast
    
    --设置数据
    if self.m_GameRecordArrary[lastIdx] == nil then
        self.m_GameRecordArrary[lastIdx] = {}
    end

    local gameRecord = self.m_GameRecordArrary[lastIdx]

	gameRecord.bWinShunMen = bWinShunMen
	gameRecord.bWinDuiMen = bWinDuiMen
	gameRecord.bWinDaoMen = bWinDaoMen

	--操作类型
    local userJettonScore_ShunMen = self.m_lUserJettonScore[g_var(cmd).ID_SHUN_MEN]
	if 0 == userJettonScore_ShunMen then
        gameRecord.enOperateShunMen = OPERATE_RESULT.enOperateResult_NULL
	elseif userJettonScore_ShunMen > 0 and 1 == bWinShunMen then
        gameRecord.enOperateShunMen = OPERATE_RESULT.enOperateResult_Win
	elseif userJettonScore_ShunMen > 0 and -1 == bWinShunMen then
        gameRecord.enOperateShunMen = OPERATE_RESULT.enOperateResult_Lost
    end

    local userJettonScore_DiMen = self.m_lUserJettonScore[g_var(cmd).ID_DI_MEN]
	if 0 == userJettonScore_DiMen then
        gameRecord.enOperateDaoMen = OPERATE_RESULT.enOperateResult_NULL
	elseif userJettonScore_DiMen > 0 and 1 == bWinDaoMen then
        gameRecord.enOperateDaoMen = OPERATE_RESULT.enOperateResult_Win
	elseif userJettonScore_DiMen > 0 and -1 == bWinDaoMen then
        gameRecord.enOperateDaoMen = OPERATE_RESULT.enOperateResult_Lost
    end

    local userJettonScore_TianMen = self.m_lUserJettonScore[g_var(cmd).ID_TIAN_MEN]
	if 0 == userJettonScore_TianMen then
        gameRecord.enOperateDuiMen = OPERATE_RESULT.enOperateResult_NULL
	elseif userJettonScore_TianMen > 0 and 1 == bWinDuiMen then
        gameRecord.enOperateDuiMen = OPERATE_RESULT.enOperateResult_Win
	elseif userJettonScore_TianMen > 0 and -1 == bWinDuiMen then
        gameRecord.enOperateDuiMen = OPERATE_RESULT.enOperateResult_Lost
    end

    self.m_GameRecordArrary[lastIdx] = gameRecord 

	--移动下标
    local maxFlagCount = g_var(cmd).MAX_SCORE_HISTORY
	self.m_nRecordLast = (self.m_nRecordLast + 1) % maxFlagCount
    if self.m_nRecordLast == 0 then
        self.m_nRecordLast = maxFlagCount
    end
	if self.m_nRecordLast == self.m_nRecordFirst then
		self.m_nRecordFirst = (self.m_nRecordFirst + 1) % maxFlagCount
	end
end

function GameViewLayer:updateRecord()
    --非空判断
	if self.m_nRecordLast == self.m_nRecordFirst then
        return
    end

    local nIdx = (self.m_nRecordLast - 2 + g_var(cmd).MAX_SCORE_HISTORY) % g_var(cmd).MAX_SCORE_HISTORY + 1

    for i=9,0,-1 do
        --胜利标识
        local ClientGameRecord = self.m_GameRecordArrary[nIdx]
        if ClientGameRecord == nil then
            for j=0,2 do
                local node = self.m_lyRecord:getChildByName("s_" .. i .. "_" .. j)
                node:setVisible(false)
            end
            return
        end

		local bWinMen = {}
		bWinMen[0] = ClientGameRecord.bWinShunMen
		bWinMen[1] = ClientGameRecord.bWinDaoMen
		bWinMen[2] = ClientGameRecord.bWinDuiMen

        --操作结果
		local OperateResult = {}
		OperateResult[0] = ClientGameRecord.enOperateShunMen
		OperateResult[1] = ClientGameRecord.enOperateDaoMen
		OperateResult[2] = ClientGameRecord.enOperateDuiMen

        for j=0,2 do
            --胜利标识
			local nFlagsIndex = "0"
			if -1 == bWinMen[j] then
				nFlagsIndex = "1"
            end

            local node = self.m_lyRecord:getChildByName("s_" .. i .. "_" .. j)
            
            if OperateResult[j] == OPERATE_RESULT.enOperateResult_NULL then
                node:setProperty(str, "game_res/WIN_FLAGS.png", 26, 24, "0")
                node:setString(nFlagsIndex)
            else
                node:setProperty(str, "game_res/ME_WIN_FLAGS.png", 26, 24, "0")
                node:setString(nFlagsIndex)
            end

            node:setVisible(true)
        end
        --移动下标
        nIdx = (nIdx - 2 + g_var(cmd).MAX_SCORE_HISTORY) % g_var(cmd).MAX_SCORE_HISTORY + 1
    end
end

--庄家信息
function GameViewLayer:SetBankerInfo(dwBankerUserID, lBankerScore) 
    local wBankerUser = dwBankerUserID
    local pUserData = self:getDataMgr():getChairUserList()[wBankerUser+1]

	--切换判断
	if pUserData ~= nil and self.m_wBankerUser ~= wBankerUser then
		self.m_wBankerTime = 0
		self.m_lBankerWinScore = 0
		self.m_lTmpBankerWinScore = 0

        self.m_textBankerNickname:setString(pUserData.szNickName)

        --更新头像
	    if nil ~= self.m_spBankerIcon and nil ~= self.m_spBankerIcon:getParent() then
		    self.m_spBankerIcon:removeFromParent()
		    self.m_spBankerIcon = nil
	    end
	    self.m_spBankerIcon = g_var(PopupInfoHead):createNormal(pUserData, 48*6)
        self.m_spBankerIcon:setPosition(181.00,458.56)
	    self.m_lyBankerInfo:addChild(self.m_spBankerIcon)
	    --self.m_spBankerIcon:enableInfoPop(true, cc.p(350,220), cc.p(1.0, yPer))

        lBankerScore = pUserData.lScore
	end
    if yl.INVALID_CHAIR == wBankerUser then
        self.m_textBankerNickname:setString("系统坐庄")
        if nil ~= self.m_spBankerIcon and nil ~= self.m_spBankerIcon:getParent() then
		    self.m_spBankerIcon:removeFromParent()
		    self.m_spBankerIcon = nil
	    end
    end

    local str = string.formatNumberThousands(lBankerScore);
	if string.len(str) > 11 then
		str = string.sub(str, 1, 7) .. "...";
	end
    self.m_textBankerCoint:setString(str)
	self.m_lBankerScore = lBankerScore

    self:refreshCondition()

    print("更新庄家数据:" .. wBankerUser .. "; coin =>" .. lBankerScore.."   ###"..self.m_wBankerUser)

	--上一个庄家是自己，且当前庄家不是自己，标记自己的状态
	if self.m_wBankerUser ~= wBankerUser and self:isMeChair(self.m_wBankerUser) then
		self.m_enApplyState = APPLY_STATE.kCancelState
	end

    if self.m_wBankerUser ~= wBankerUser then
        self.m_wBankerUser = wBankerUser

        if self:isMeChair(self.m_wBankerUser) then
            self:showTipsAnimate("game_res/redNine_me_banker.png")
        else
            self:showTipsAnimate("game_res/redNine_change_banker.png")
        end
    end

    self:refreshCondition()
end

--设置信息
function GameViewLayer:SetMeMaxScore(lMeMaxScore)
	if self.m_lMeMaxScore ~= lMeMaxScore then
		self.m_lMeMaxScore = lMeMaxScore
	end
end

--申请庄家
function GameViewLayer:onGetApplyBanker( )
	if self:isMeChair(self:getParentNode().cmd_applybanker.wApplyUser) then
		self.m_enApplyState = APPLY_STATE.kApplyState
	end

	self:refreshApplyList()
end

--取消申请庄家
function GameViewLayer:onGetCancelBanker(  )
	if self:isMeChair(self:getParentNode().cmd_cancelbanker.wCancelUser) then
		self.m_enApplyState = APPLY_STATE.kCancelState
	end
	
	self:refreshApplyList()
end

function GameViewLayer:getApplyState(  )
	return self.m_enApplyState
end

--获取能否上庄
function GameViewLayer:getApplyable(  )
	local userItem = self:getMeUserItem();
	if nil ~= userItem then
		return userItem.lScore > self.m_llBankerConsume
	else
		return false
	end
end

--获取能否取消上庄
function GameViewLayer:getCancelable(  )
	return self.m_cbGameStatus == g_var(cmd).GAME_SCENE_FREE
end

function GameViewLayer:showTipsAnimate(pngFile)
    self.m_lyCenterTips:stopAllActions()
    self.m_lyCenterTips:setTexture(pngFile)
    self.m_lyCenterTips:setVisible(true)
    self.m_lyCenterTips:setPosition( cc.p(666.0, 256.0) )
    self.m_lyCenterTips:setOpacity(255)
    local spawn = cc.Spawn:create(cc.FadeOut:create(3.0), cc.MoveBy:create(3.0, cc.p(0,1000)))
    self.m_lyCenterTips:runAction(spawn)
end
------
return GameViewLayer