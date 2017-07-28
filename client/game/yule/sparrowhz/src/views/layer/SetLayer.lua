--
-- Author: tom
-- Date: 2017-02-27 17:26:42
--
local SetLayer = class("SetLayer", function(scene)
	local setLayer = display.newLayer()
	return setLayer
end)

local cmd = appdf.req(appdf.GAME_SRC.."yule.sparrowhz.src.models.CMD_Game")

local TAG_BT_MUSICON = 1
local TAG_BT_MUSICOFF = 2
local TAG_BT_EFFECTON = 3
local TAG_BT_EFFECTOFF = 4
local TAG_BT_EXIT = 5

function SetLayer:onInitData()
end

function SetLayer:onResetData()
end

local this
function SetLayer:ctor(scene)
	this = self
	self._scene = scene
	self:onInitData()


	self.colorLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 125))
		:setContentSize(display.width, display.height)
		:addTo(self)
	local this = self
	self.colorLayer:registerScriptTouchHandler(function(eventType, x, y)
		return this:onTouch(eventType, x, y)
	end)

	local funCallback = function(ref)
		this:onButtonCallback(ref:getTag(), ref)
	end
	--UI
	self._csbNode = cc.CSLoader:createNode(cmd.RES_PATH.."game/SetLayer.csb")
		:addTo(self, 1)
	self.btMusicOn = self._csbNode:getChildByName("bt_music_on")
		:setTag(TAG_BT_MUSICON)
	self.btMusicOn:addClickEventListener(funCallback)
	self.btMusicOff = self._csbNode:getChildByName("bt_music_off")
		:setTag(TAG_BT_MUSICOFF)
	self.btMusicOff:addClickEventListener(funCallback)
	self.btEffectOn = self._csbNode:getChildByName("bt_effect_on")
		:setTag(TAG_BT_EFFECTON)
	self.btEffectOn:addClickEventListener(funCallback)
	self.btEffectOff = self._csbNode:getChildByName("bt_effect_off")
		:setTag(TAG_BT_EFFECTOFF)
	self.btEffectOff:addClickEventListener(funCallback)
	local btnClose = self._csbNode:getChildByName("bt_close")
		:setTag(TAG_BT_EXIT)
	btnClose:addClickEventListener(funCallback)
	self.sp_layerBg = self._csbNode:getChildByName("sp_setLayer_bg")
	--声音
	self.btMusicOn:setVisible(GlobalUserItem.bVoiceAble)
	self.btMusicOff:setVisible(not GlobalUserItem.bVoiceAble)
	self.btEffectOn:setVisible(GlobalUserItem.bSoundAble)
	self.btEffectOff:setVisible(not GlobalUserItem.bSoundAble)
	if GlobalUserItem.bVoiceAble then
		AudioEngine.playMusic("sound/BACK_PLAYING.wav", true)
	end
	--版本号
	local textVersion = self._csbNode:getChildByName("Text_version")
	local mgr = self._scene._scene._scene:getApp():getVersionMgr()
	local nVersion = mgr:getResVersion(cmd.KIND_ID) or "0"
	local strVersion = "游戏版本："..appdf.BASE_C_VERSION.."."..nVersion
	textVersion:setString(strVersion)

	self:setVisible(false)
end

function SetLayer:onButtonCallback(tag, ref)
	if tag == TAG_BT_MUSICON then
		print("音乐状态本开")
		GlobalUserItem.setVoiceAble(false)
		self.btMusicOn:setVisible(false)
		self.btMusicOff:setVisible(true)
	elseif tag == TAG_BT_MUSICOFF then
		print("音乐状态本关")
		GlobalUserItem.setVoiceAble(true)
		self.btMusicOn:setVisible(true)
		self.btMusicOff:setVisible(false)
		AudioEngine.playMusic("sound/BACK_PLAYING.wav", true)
	elseif tag == TAG_BT_EFFECTON then
		print("音效状态本开")
		GlobalUserItem.setSoundAble(false)
		self.btEffectOn:setVisible(false)
		self.btEffectOff:setVisible(true)
	elseif tag == TAG_BT_EFFECTOFF then
		print("音效状态本关")
		GlobalUserItem.setSoundAble(true)
		self.btEffectOn:setVisible(true)
		self.btEffectOff:setVisible(false)
	elseif tag == TAG_BT_EXIT then
		print("离开")
		self:hideLayer()
	end
end

function SetLayer:onTouch(eventType, x, y)
	print(eventType)
	if eventType == "began" then
		return true
	end

	local pos = cc.p(x, y)
    local rectLayerBg = self.sp_layerBg:getBoundingBox()
    if not cc.rectContainsPoint(rectLayerBg, pos) then
    	self:hideLayer()
    end

    return true
end

function SetLayer:showLayer()
	self.colorLayer:setTouchEnabled(true)
	self:setVisible(true)
end

function SetLayer:hideLayer()
	self.colorLayer:setTouchEnabled(false)
	self:setVisible(false)
	self:onResetData()
end

return SetLayer