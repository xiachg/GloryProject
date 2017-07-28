--
-- Author: luo
-- Date: 2016年12月30日 17:50:01
--
--设置界面
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")

local SettingLayer = class("SettingLayer", cc.Layer)

SettingLayer.BT_EFFECT = 1
SettingLayer.BT_MUSIC = 2
SettingLayer.BT_CLOSE = 3
--构造
function SettingLayer:ctor( verstr )
    --注册触摸事件
    ExternalFun.registerTouchEvent(self, true)
    --加载csb资源
    self._csbNode = ExternalFun.loadCSB("SHZ_GameSetting.csb", self)
    local cbtlistener = function (sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            self:OnButtonClickedEvent(sender:getTag(),sender)
        end
    end
    local sp_bg = self._csbNode:getChildByName("bg")
    local bgSize = sp_bg:getContentSize()
    self.m_spBg = sp_bg
    --关闭按钮
    local btn = self._csbNode:getChildByName("closeBtn")
    btn:setTag(SettingLayer.BT_CLOSE)
    btn:addTouchEventListener(function (ref, eventType)
        if eventType == ccui.TouchEventType.ended then
            ExternalFun.playClickEffect()
            self:removeFromParent()
        end
    end)
    --音效
    self.m_btnEffect = self._csbNode:getChildByName("soundBtn")
    self.m_btnEffect:setTag(SettingLayer.BT_EFFECT)
    self.m_btnEffect:addTouchEventListener(cbtlistener)
    --音乐
    self.m_btnMusic = self._csbNode:getChildByName("musicBtn")
    self.m_btnMusic:setTag(SettingLayer.BT_MUSIC)
    self.m_btnMusic:addTouchEventListener(cbtlistener)
    if GlobalUserItem.bVoiceAble == true then 
        self.m_btnMusic:loadTextureNormal("open_1.png",ccui.TextureResType.plistType)
        self.m_btnMusic:loadTexturePressed("open_2.png",ccui.TextureResType.plistType)
    else
        self.m_btnMusic:loadTextureNormal("close_1.png",ccui.TextureResType.plistType)
        self.m_btnMusic:loadTexturePressed("close_2.png",ccui.TextureResType.plistType)
    end
    if GlobalUserItem.bSoundAble == true then 
        self.m_btnEffect:loadTextureNormal("open_1.png",ccui.TextureResType.plistType)
        self.m_btnEffect:loadTexturePressed("open_2.png",ccui.TextureResType.plistType)
    else
        self.m_btnEffect:loadTextureNormal("close_1.png",ccui.TextureResType.plistType)
        self.m_btnEffect:loadTexturePressed("close_2.png",ccui.TextureResType.plistType)
    end
    dump(verstr)  --verText


    self.m_TextVer = self._csbNode:getChildByName("verText")
    self.m_TextVer:setString(verstr)


end
--
function SettingLayer:showLayer( var )
    self:setVisible(var)
end

function SettingLayer:OnButtonClickedEvent( tag, sender )
    if SettingLayer.BT_MUSIC == tag then
        local music = not GlobalUserItem.bVoiceAble
        GlobalUserItem.setVoiceAble(music)
        if GlobalUserItem.bVoiceAble == true then 
            ExternalFun.playBackgroudAudio("xiongdiwushu.mp3")
            sender:loadTextureNormal("open_1.png",ccui.TextureResType.plistType)
            sender:loadTexturePressed("open_2.png",ccui.TextureResType.plistType)
        else
            AudioEngine.stopMusic()
            sender:loadTextureNormal("close_1.png",ccui.TextureResType.plistType)
            sender:loadTexturePressed("close_2.png",ccui.TextureResType.plistType)
        end
    elseif SettingLayer.BT_EFFECT == tag then
        local effect = not GlobalUserItem.bSoundAble
        GlobalUserItem.setSoundAble(effect)
        if GlobalUserItem.bSoundAble == true then 
            sender:loadTextureNormal("open_1.png",ccui.TextureResType.plistType)
            sender:loadTexturePressed("open_2.png")
        else
            sender:loadTextureNormal("close_1.png",ccui.TextureResType.plistType)
            sender:loadTexturePressed("close_2.png",ccui.TextureResType.plistType)
        end
    end
end

function SettingLayer:onTouchBegan(touch, event)
    return self:isVisible()
end

function SettingLayer:onTouchEnded(touch, event)
    dump(event)
    local pos = touch:getLocation() 
    local m_spBg = self.m_spBg
    pos = m_spBg:convertToNodeSpace(pos)
    local rec = cc.rect(0, 0, m_spBg:getContentSize().width, m_spBg:getContentSize().height)
    if false == cc.rectContainsPoint(rec, pos) then
        self:removeFromParent()
        -- local parent = self:getParent()
        -- parent.m_AreaMenu:setVisible(false)
        -- parent.m_bShowMenu = not parent.m_bShowMenu
    end
end

return SettingLayer