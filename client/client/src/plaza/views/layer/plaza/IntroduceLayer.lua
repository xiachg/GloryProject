--
-- Author: zhong
-- Date: 2017-01-05 10:22:19
--
-- 玩法介绍
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local IntroduceLayer = class("IntroduceLayer", cc.Layer)

local TAG_MASK = 101
local BTN_CLOSE = 102
function IntroduceLayer:ctor( scene, url )
    self._scene = scene
    url = url or yl.HTTP_URL
    -- 加载csb资源
    local rootLayer, csbNode = ExternalFun.loadRootCSB("plaza/IntroduceLayer.csb", self )

    local touchFunC = function(ref, tType)
        if tType == ccui.TouchEventType.ended then
            self:onButtonClickedEvent(ref:getTag(), ref)            
        end
    end

    -- 遮罩
    local mask = csbNode:getChildByName("panel_mask")
    mask:setTag(TAG_MASK)
    mask:addTouchEventListener( touchFunC )

    local image_bg = csbNode:getChildByName("image_bg")
    image_bg:setTouchEnabled(true)
    image_bg:setSwallowTouches(true)

    -- 退出按钮
    local btn = image_bg:getChildByName("btn_close")
    btn:setTag(BTN_CLOSE)
    btn:addTouchEventListener(touchFunC)

    -- 界面
    local tmp = image_bg:getChildByName("content")
    --平台判定
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        --介绍页面
        self.m_webView = ccexp.WebView:create()
        self.m_webView:setPosition(tmp:getPosition())
        self.m_webView:setContentSize(tmp:getContentSize())
        
        self.m_webView:setScalesPageToFit(true)        
        self.m_webView:loadURL(url)
        ExternalFun.visibleWebView(self.m_webView, false)
        self._scene:showPopWait()

        self.m_webView:setOnJSCallback(function ( sender, url )
                    
        end)

        self.m_webView:setOnDidFailLoading(function ( sender, url )
            self._scene:dismissPopWait()
            print("open " .. url .. " fail")
        end)
        self.m_webView:setOnShouldStartLoading(function(sender, url)
            print("onWebViewShouldStartLoading, url is ", url)          
            return true
        end)
        self.m_webView:setOnDidFinishLoading(function(sender, url)
            self._scene:dismissPopWait()
            ExternalFun.visibleWebView(self.m_webView, true)
        end)
        image_bg:addChild(self.m_webView)
    end
    tmp:removeFromParent()
end

function IntroduceLayer:onButtonClickedEvent(tag, ref)
    if TAG_MASK == tag or BTN_CLOSE == tag then
        self._scene:dismissPopWait()
        self:removeFromParent()
    end
end

-- scrollview 创建
function IntroduceLayer:createLayer(scene, nKindId, nType)
    if nil == nKindId or nil == nType then
        return nil
    end
    self._scene = scene
    local parent = ccui.Layout:create()
    parent:setTouchEnabled(false)
    -- 加载csb资源
    local rootLayer, csbNode = ExternalFun.loadRootCSB("plaza/IntroduceLayer.csb", parent )

    local touchFunC = function(ref, tType)
        if tType == ccui.TouchEventType.ended then
            self._scene:dismissPopWait()
            parent:removeFromParent()    
        end
    end

    -- 遮罩
    local mask = csbNode:getChildByName("panel_mask")
    mask:setTag(TAG_MASK)
    mask:addTouchEventListener( touchFunC )

    local image_bg = csbNode:getChildByName("image_bg")
    image_bg:setTouchEnabled(true)
    image_bg:setSwallowTouches(true)

    -- 退出按钮
    local btn = image_bg:getChildByName("btn_close")
    btn:setTag(BTN_CLOSE)
    btn:addTouchEventListener(touchFunC)

    -- 界面
    local tmp = image_bg:getChildByName("content")
    -- 读取文本
    self._scrollView = ccui.ScrollView:create()
                          :setContentSize(tmp:getContentSize())
                          :setPosition(tmp:getPosition())
                          :setAnchorPoint(tmp:getAnchorPoint())
                          :setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
                          :setBounceEnabled(true)
                          :setScrollBarEnabled(false)
                          :addTo(image_bg)
    tmp:removeFromParent()

    local tabKindList = GlobalUserItem.tabIntroduceCache[nKindId]
    local szIntroduce = nil
    if type(tabKindList) == "table" then
        local tips = tabKindList[nType]
        if type(tips) == "string" then
            szIntroduce = tips
        end
    else
        GlobalUserItem.tabIntroduceCache[nKindId] = {}
    end
    if nil == szIntroduce then
        if type(scene.showPopWait) == "function" then
            scene:showPopWait()
        end
        local url = yl.HTTP_URL .. "/WS/MobileInterface.ashx?action=getgameintroduce&kindid=" .. nKindId .. "&typeid=" .. nType            
        appdf.onHttpJsionTable(url ,"GET","",function(jstable,jsdata)
            if type(jstable) == "table" then
                local data = jstable["data"]
                local msg = jstable["msg"]
                if type(data) == "table" then
                    local content = data["Content"]
                    if type(content) == "string" then
                        msg = nil
                        self:refreshIntroduce(content)
                        GlobalUserItem.tabIntroduceCache[nKindId][nType] = content
                    end
                end
            end
            if type(scene.dismissPopWait) == "function" then
                scene:dismissPopWait()
            end
            if type(msg) == "string" and "" ~= msg then
                showToast(image_bg, msg, 2)
            end
        end)
    else
        self:refreshIntroduce(szIntroduce)
    end
    return parent
end

function IntroduceLayer:refreshIntroduce( szTips )
    local viewSize = self._scrollView:getContentSize()
    self._strLabel = cc.Label:createWithTTF(szTips, "fonts/round_body.ttf", 25)
                             :setLineBreakWithoutSpace(true)
                             :setMaxLineWidth(viewSize.width)
                             :setTextColor(cc.c4b(0,0,0,255))
                             :setAnchorPoint(cc.p(0.5, 1.0))
                             :addTo(self._scrollView)
    local labelSize = self._strLabel:getContentSize()
    local fHeight = labelSize.height > viewSize.height and labelSize.height or viewSize.height
    self._strLabel:setPosition(cc.p(viewSize.width * 0.5, fHeight))
    self._scrollView:setInnerContainerSize(cc.size(viewSize.width, labelSize.height))
end

return IntroduceLayer