local LogonView = class("LogonView",function()
		local logonView =  display.newLayer()
    return logonView
end)
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local MultiPlatform = appdf.req(appdf.EXTERNAL_SRC .. "MultiPlatform")

LogonView.BT_LOGON = 1
LogonView.BT_REGISTER = 2
LogonView.CBT_RECORD = 3
LogonView.CBT_AUTO = 4
LogonView.BT_VISITOR = 5
LogonView.BT_WEIBO = 6
LogonView.BT_QQ	= 7
LogonView.BT_THIRDPARTY	= 8
LogonView.BT_WECHAT	= 9
LogonView.BT_FGPW = 10 	-- 忘记密码
LogonView.BT_SHOWPW = 11 -- 显示密码
LogonView.BT_HIDEPW = 12 -- 隐藏密码

function LogonView:ctor(serverConfig)
	local this = self
	self:setContentSize(yl.WIDTH,yl.HEIGHT)
	--ExternalFun.registerTouchEvent(self)

	local  btcallback = function(ref, type)
        if type == ccui.TouchEventType.ended then
         	this:onButtonClickedEvent(ref:getTag(),ref)
        end
    end
	local cbtlistener = function (sender,eventType)
    	this:onSelectedEvent(sender,eventType)
    end

    local editHanlder = function ( name, sender )
		self:onEditEvent(name, sender)
	end

	--帐号提示
	self.m_spAccount = display.newSprite("Logon/account_text.png")
		:move(366,381)
		:addTo(self)

	--账号输入
	self.edit_Account = ccui.EditBox:create(cc.size(490,67), "Logon/text_field_frame.png")
		:move(yl.WIDTH/2,381)
		:setAnchorPoint(cc.p(0.5,0.5))
		:setFontName("fonts/round_body.ttf")
		:setPlaceholderFontName("fonts/round_body.ttf")
		:setFontSize(24)
		:setPlaceholderFontSize(24)
		:setMaxLength(31)
		:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)		
		:addTo(self)
	self.edit_Account:registerScriptEditBoxHandler(editHanlder)

	--密码提示
	self.m_spPasswd = display.newSprite("Logon/password_text.png")
		:move(366,280)
		:addTo(self)

	--密码输入	
	self.edit_Password = ccui.EditBox:create(cc.size(490,67), "Logon/text_field_frame.png")
		:move(yl.WIDTH/2,280)
		:setAnchorPoint(cc.p(0.5,0.5))
		:setFontName("fonts/round_body.ttf")
		:setPlaceholderFontName("fonts/round_body.ttf")
		:setFontSize(24)
		:setPlaceholderFontSize(24)
		:setMaxLength(26)
		:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
		:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)		
		:addTo(self)

	-- 查看密码
	self.m_btnShowPasswd = ccui.Button:create("Logon/login_btn_hidepw_0.png", "Logon/login_btn_hidepw_1.png", "Logon/login_btn_hidepw_0.png")
		:setTag(LogonView.BT_SHOWPW)
		:move(850,275)
		:addTo(self)
	self.m_btnShowPasswd:addTouchEventListener(btcallback)
	self.m_btnShowPasswd:setSwallowTouches(true)
	self.m_btnShowPasswd:setLocalZOrder(1)

	-- 忘记密码
	self.m_btnFgPasswd = ccui.Button:create("Logon/btn_login_fgpw.png")
		:setTag(LogonView.BT_FGPW)
		:move(1000,280)
		:addTo(self)
	self.m_btnFgPasswd:addTouchEventListener(btcallback)

	--记住密码
	self.cbt_Record = ccui.CheckBox:create("Logon/rem_password_button.png","","Logon/choose_button.png","","")
		:move(515,165)
		:setSelected(GlobalUserItem.bSavePassword)
		:setTag(LogonView.CBT_RECORD)
		:addTo(self)

	-- --自动登录
	-- self.cbt_Auto = ccui.CheckBox:create("cbt_auto_0.png","","cbt_auto_1.png","","")
	-- 	:move(700-93,245)
	-- 	:setSelected(GlobalUserItem.bAutoLogon)
	-- 	:setTag(LogonView.CBT_AUTO)
	-- 	:addTo(self)

	--账号登录
	ccui.Button:create("Logon/logon_button_0.png", "Logon/logon_button_1.png", "Logon/logon_button_2.png")
		:setTag(LogonView.BT_LOGON)
		:move(cc.p(0,0))
		:setName("btn_1")
		:addTo(self)
		:addTouchEventListener(btcallback)

	--注册按钮
	self.m_btnRegister = ccui.Button:create("Logon/regist_button.png","")
		:setTag(LogonView.BT_REGISTER)
		:move(766,165)
		:addTo(self)
	self.m_btnRegister:addTouchEventListener(btcallback)

	--游客登录
	ccui.Button:create("Logon/visitor_button_0.png", "Logon/visitor_button_1.png", "Logon/visitor_button_2.png")
		:setTag(LogonView.BT_VISITOR)
		:move(cc.p(0,0))
		:setEnabled(false)
		:setVisible(false)
		:setName("btn_2")
		:addTo(self)
		:addTouchEventListener(btcallback)

	--微信登陆
	ccui.Button:create("Logon/thrid_part_wx_0.png", "Logon/thrid_part_wx_1.png", "Logon/thrid_part_wx_2.png")
		:setTag(LogonView.BT_WECHAT)
		:move(cc.p(0,0))
		:setVisible(false)
		:setEnabled(false)
		:setName("btn_3")
		:addTo(self)
		:addTouchEventListener(btcallback)

	self.m_serverConfig = serverConfig or {}
	self:refreshBtnList()
end

function LogonView:refreshBtnList( )
	for i = 1, 3 do
		local btn = self:getChildByName("btn_" .. i)
		if btn ~= nil then
			btn:setVisible(false)
			btn:setEnabled(false)
		end
	end

	local btnpos = 
	{
		{cc.p(667, 70), cc.p(0, 0), cc.p(0, 0)},
		{cc.p(463, 70), cc.p(868, 70), cc.p(0, 0)},
		{cc.p(222, 70), cc.p(667, 70), cc.p(1112, 70)}
	}	

	-- 登陆限定
	local loginConfig = 7--self.m_serverConfig.moblieLogonMode or 0
	-- 1:帐号 2:游客 3:微信
	local btnlist = {}
	if (1 == bit:_and(loginConfig, 1)) then
		table.insert(btnlist, "btn_1")
	else
		-- 隐藏帐号输入信息
		self:hideAccountInfo()
	end
	
	if false == GlobalUserItem.getBindingAccount() and (2 == bit:_and(loginConfig, 2)) then
		table.insert(btnlist, "btn_2")
	end

	local enableWeChat = self.m_serverConfig["wxLogon"] or 1
	if 4 == bit:_and(loginConfig, 4) then
		table.insert(btnlist, "btn_3")
	end

	local poslist = btnpos[#btnlist]
	for k,v in pairs(btnlist) do
		local tmp = self:getChildByName(v)
		if nil ~= tmp then
			tmp:setEnabled(true)
			tmp:setVisible(true)

			local pos = poslist[k]
            if nil ~= pos then
            	tmp:setPosition(pos)
            end
		end
	end
end

function LogonView:onEditEvent(name, editbox)
	--print(name)
	if "changed" == name then
		if editbox:getText() ~= GlobalUserItem.szAccount then
			self.edit_Password:setText("")
		end		
	end
end

function LogonView:onReLoadUser()
	if GlobalUserItem.szAccount ~= nil and GlobalUserItem.szAccount ~= "" then
		self.edit_Account:setText(GlobalUserItem.szAccount)
	else
		self.edit_Account:setPlaceHolder("请输入您的游戏帐号")
	end

	if GlobalUserItem.szPassword ~= nil and GlobalUserItem.szPassword ~= "" then
		self.edit_Password:setText(GlobalUserItem.szPassword)
	else
		self.edit_Password:setPlaceHolder("请输入您的游戏密码")
	end
end

function LogonView:onButtonClickedEvent(tag,ref)
	if tag == LogonView.BT_REGISTER then
		GlobalUserItem.bVisitor = false
		self:getParent():getParent():onShowRegister()
	elseif tag == LogonView.BT_VISITOR then
		GlobalUserItem.bVisitor = true
		self:getParent():getParent():onVisitor()
	elseif tag == LogonView.BT_LOGON then
		GlobalUserItem.bVisitor = false
		local szAccount = string.gsub(self.edit_Account:getText(), " ", "")
		local szPassword = string.gsub(self.edit_Password:getText(), " ", "")
		local bAuto = self:getChildByTag(LogonView.CBT_RECORD):isSelected()
		local bSave = self:getChildByTag(LogonView.CBT_RECORD):isSelected()
		self:getParent():getParent():onLogon(szAccount,szPassword,bSave,bAuto)
	elseif tag == LogonView.BT_THIRDPARTY then
		self.m_spThirdParty:setVisible(true)
	elseif tag == LogonView.BT_WECHAT then
		--平台判定
		local targetPlatform = cc.Application:getInstance():getTargetPlatform()
		if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_ANDROID == targetPlatform) then
			self:getParent():getParent():thirdPartyLogin(yl.ThirdParty.WECHAT)
		else
			showToast(self, "不支持的登录平台 ==> " .. targetPlatform, 2)
		end
	elseif tag == LogonView.BT_FGPW then
		MultiPlatform:getInstance():openBrowser(yl.HTTP_URL .. "/Mobile/RetrievePassword.aspx")
	elseif tag == LogonView.BT_SHOWPW then
		self.m_btnShowPasswd:loadTextureDisabled("Logon/login_btn_showpw_0.png")
    	self.m_btnShowPasswd:loadTextureNormal("Logon/login_btn_showpw_0.png")
    	self.m_btnShowPasswd:loadTexturePressed("Logon/login_btn_showpw_1.png")
    	self.m_btnShowPasswd:setTag(LogonView.BT_HIDEPW)

		--[[self.edit_Password:setInputFlag(cc.EDITBOX_INPUT_FLAG_NO_PASSWORD)
		self.edit_Password:setText(self.edit_Password:getText())]]

		local txt = self.edit_Password:getText()
		self.edit_Password:removeFromParent()
		--密码输入	
		self.edit_Password = ccui.EditBox:create(cc.size(490,67), "Logon/text_field_frame.png")
			:move(yl.WIDTH/2,280)
			:setAnchorPoint(cc.p(0.5,0.5))
			:setFontName("fonts/round_body.ttf")
			:setPlaceholderFontName("fonts/round_body.ttf")
			:setFontSize(24)
			:setPlaceholderFontSize(24)
			:setMaxLength(26)
			:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)		
			:addTo(self)
			:setText(txt)
	elseif tag == LogonView.BT_HIDEPW then
		self.m_btnShowPasswd:loadTextureDisabled("Logon/login_btn_hidepw_0.png")
    	self.m_btnShowPasswd:loadTextureNormal("Logon/login_btn_hidepw_0.png")
    	self.m_btnShowPasswd:loadTexturePressed("Logon/login_btn_hidepw_1.png")
    	self.m_btnShowPasswd:setTag(LogonView.BT_SHOWPW)

		--[[self.edit_Password:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
		self.edit_Password:setText(self.edit_Password:getText())]]

		local txt = self.edit_Password:getText()
		self.edit_Password:removeFromParent()
		--密码输入	
		self.edit_Password = ccui.EditBox:create(cc.size(490,67), "Logon/text_field_frame.png")
			:move(yl.WIDTH/2,280)
			:setAnchorPoint(cc.p(0.5,0.5))
			:setFontName("fonts/round_body.ttf")
			:setPlaceholderFontName("fonts/round_body.ttf")
			:setFontSize(24)
			:setPlaceholderFontSize(24)
			:setMaxLength(26)
			:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
			:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)		
			:addTo(self)
			:setText(txt)
	end
end

function LogonView:onTouchBegan(touch, event)
	return self:isVisible()
end

function LogonView:onTouchEnded(touch, event)
	local pos = touch:getLocation();
	local m_spBg = self.m_spThirdParty
    pos = m_spBg:convertToNodeSpace(pos)
    local rec = cc.rect(0, 0, m_spBg:getContentSize().width, m_spBg:getContentSize().height)
    if false == cc.rectContainsPoint(rec, pos) then
        self.m_spThirdParty:setVisible(false)
    end
end

function LogonView:hideAccountInfo()
	self.m_spAccount:setVisible(false)
	--账号输入
	self.edit_Account:setVisible(false)
	self.edit_Account:setEnabled(false)

	self.m_spPasswd:setVisible(false)
	-- 密码输入
	self.edit_Password:setVisible(false)
	self.edit_Password:setEnabled(false)

	-- 查看密码
	self.m_btnShowPasswd:setVisible(false)
	self.m_btnShowPasswd:setEnabled(false)

	-- 忘记密码
	self.m_btnFgPasswd:setVisible(false)
	self.m_btnFgPasswd:setEnabled(false)

	-- 记住密码
	self.cbt_Record:setVisible(false)
	self.cbt_Record:setEnabled(false)

	-- 注册账号
	self.m_btnRegister:setVisible(false)
	self.m_btnRegister:setEnabled(false)

	-- 自动登录
	yl.AUTO_LOGIN = false
end

return LogonView