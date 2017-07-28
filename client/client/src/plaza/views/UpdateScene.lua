--
-- Author: zhong
-- Date: 2017-03-15 16:05:02
--
-- 单游戏模式更新场景
local UpdateScene = class("UpdateScene", cc.load("mvc").ViewBase)
local Update = appdf.req(appdf.BASE_SRC.."app.controllers.ClientUpdate")
local QueryDialog = appdf.req("base.src.app.views.layer.other.QueryDialog")

-- 初始化界面
function UpdateScene:onCreate( )
    print("UpdateScene:onCreate")
    local this = self
    self.m_tabUpdateGame = self:getApp()._updategame

    --背景
    local newbasepath = cc.FileUtils:getInstance():getWritablePath() .. "/baseupdate/"
    local bgfile = newbasepath .. "base/res/background.jpg" 
    local sp = cc.Sprite:create(bgfile)
    if nil == sp then
        sp = cc.Sprite:create("background.jpg")
    end
    if nil ~= sp then
        sp:setPosition(appdf.WIDTH/2,appdf.HEIGHT/2)
        self:addChild(sp)
    end

    --标签
    local tipfile = newbasepath .. "base/res/logo_name_00.png"
    if false == cc.FileUtils:getInstance():isFileExist(tipfile) then
        tipfile = "logo_name_00.png"
    end
    sp = cc.Sprite:create(tipfile)
    if nil == sp then
        sp = cc.Sprite:create("logo_name_00.png")
    end
    if nil ~= sp then
        sp:setPosition(appdf.WIDTH/2,appdf.HEIGHT/2+100)
        self:addChild(sp)
        sp:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(2,255),cc.FadeTo:create(2,128))))
    end
    
    --slogan
    local sloganfile = newbasepath .. "base/res/logo_text_00.png"
    if false == cc.FileUtils:getInstance():isFileExist(sloganfile) then
        sloganfile = "logo_text_00.png"
    end
    sp = cc.Sprite:create(sloganfile)
    if nil == sp then
        sp = cc.Sprite:create("logo_text_00.png")
    end
    if nil ~= sp then
        sp = cc.Sprite:create(sloganfile)
        sp:setPosition(appdf.WIDTH/2, 200)
        self:addChild(sp)
    end

    --提示文本
    self._txtTips = cc.Label:createWithTTF("", "fonts/round_body.ttf", 24)
        :setTextColor(cc.c4b(0,250,0,255))
        :setAnchorPoint(cc.p(1,0))
        :enableOutline(cc.c4b(0,0,0,255), 1)
        :move(appdf.WIDTH,0)
        :addTo(self)

    self.m_progressLayer = display.newLayer(cc.c4b(0, 0, 0, 0))
    self:addChild(self.m_progressLayer)
    self.m_progressLayer:setVisible(false)
    --总进度
    local total_bg = cc.Sprite:create("wait_frame_0.png")
    self.m_spTotalBg = total_bg
    self.m_progressLayer:addChild(total_bg)
    total_bg:setPosition(appdf.WIDTH/2, 80)
    self.m_totalBar = ccui.LoadingBar:create()
    self.m_totalBar:loadTexture("wait_frame_3.png") 
    self.m_progressLayer:addChild(self.m_totalBar)
    self.m_totalBar:setPosition(appdf.WIDTH/2, 80)
    self._totalTips = cc.Label:createWithTTF("", "fonts/round_body.ttf", 20)
        --:setTextColor(cc.c4b(0,250,0,255))
        :setName("text_tip")
        :enableOutline(cc.c4b(0,0,0,255), 1)
        :move(self.m_totalBar:getContentSize().width * 0.5, self.m_totalBar:getContentSize().height * 0.5)
        :addTo(self.m_totalBar)
    self.m_totalThumb = cc.Sprite:create("thumb_1.png")
    self.m_totalBar:addChild(self.m_totalThumb)
    self.m_totalThumb:setPositionY(self.m_totalBar:getContentSize().height * 0.5)
    self:updateBar(self.m_totalBar, self.m_totalThumb, 0)

    --单文件进度
    local file_bg = cc.Sprite:create("wait_frame_0.png")
    self.m_spFileBg = file_bg
    self.m_progressLayer:addChild(file_bg)
    file_bg:setPosition(appdf.WIDTH/2, 120)
    self.m_fileBar = ccui.LoadingBar:create()
    self.m_fileBar:loadTexture("wait_frame_2.png")
    self.m_fileBar:setPercent(0)
    self.m_progressLayer:addChild(self.m_fileBar)
    self.m_fileBar:setPosition(appdf.WIDTH/2, 120)
    self._fileTips = cc.Label:createWithTTF("", "fonts/round_body.ttf", 20)
        --:setTextColor(cc.c4b(0,250,0,255))
        :setName("text_tip")
        :enableOutline(cc.c4b(0,0,0,255), 1)
        :move(self.m_fileBar:getContentSize().width * 0.5, self.m_fileBar:getContentSize().height * 0.5)
        :addTo(self.m_fileBar)
    self.m_fileThumb = cc.Sprite:create("thumb_0.png")
    self.m_fileBar:addChild(self.m_fileThumb)
    self.m_fileThumb:setPositionY(self.m_fileBar:getContentSize().height * 0.5)
    self:updateBar(self.m_fileBar, self.m_fileThumb, 0)
end

-- 进入场景而且过渡动画结束时候触发。
function UpdateScene:onEnterTransitionFinish()
    self:goUpdate()
end

function UpdateScene:goUpdate()
    self.m_progressLayer:setVisible(true)
    updategame = self.m_tabUpdateGame

    --更新参数
    local newfileurl = self:getApp()._updateUrl .. "/game/".. updategame._Module.."/res/filemd5List.json"
    local dst = device.writablePath .. "game/" .. updategame._Type .. "/"
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if cc.PLATFORM_OS_WINDOWS == targetPlatform then
        dst = device.writablePath .. "download/game/" .. updategame._Type .. "/"
    end
    
    local src = device.writablePath.."game/" .. updategame._Module.."/res/filemd5List.json"
    local downurl = self:getApp()._updateUrl .. "/game/" .. updategame._Type .. "/"

    --创建更新
    Update:create(newfileurl,dst,src,downurl)
        :upDateClient(self)
end

--更新进度
function UpdateScene:updateProgress(sub, msg, mainpersent)
    self:updateBar(self.m_fileBar, self.m_fileThumb, sub)
    self:updateBar(self.m_totalBar, self.m_totalThumb, mainpersent)
end

--更新结果
function UpdateScene:updateResult(result,msg)
    if nil ~= self.m_spDownloadCycle then
        self.m_spDownloadCycle:stopAllActions()
        self.m_spDownloadCycle:setVisible(false)
    end
    
    if result == true then
        self._txtTips:setString("OK")
        self:getApp()._version:setResVersion(self.m_tabUpdateGame._ServerResVersion, self.m_tabUpdateGame._KindID)
        --进入游戏列表
        self:getApp():enterSceneEx(appdf.CLIENT_SRC.."plaza.views.ClientScene","FADE",1)
        FriendMgr:getInstance():reSetAndLogin()
    else
        self.m_progressLayer:setVisible(false)
        self:updateBar(self.m_fileBar, self.m_fileThumb, 0)
        self:updateBar(self.m_totalBar, self.m_totalThumb, 0)

        --重试询问
        self._txtTips:setString("")
        QueryDialog:create(msg .. "\n是否重试？",function(bReTry)
                if bReTry == true then
                    self:goUpdate()
                else
                    os.exit(0)
                end
            end)
            :setCanTouchOutside(false)
            :addTo(self)     
    end
end

function UpdateScene:updateBar(bar, thumb, percent)
    if nil == bar or nil == thumb then
        return
    end
    local text_tip = bar:getChildByName("text_tip")
    if nil ~= text_tip then
        local str = string.format("%d%%", percent)
        text_tip:setString(str)
    end

    bar:setPercent(percent)
    local size = bar:getVirtualRendererSize()
    thumb:setPositionX(size.width * percent / 100)
end

return UpdateScene