//
//  AudioRecorder.cpp
//  GloryProject
//
//  Created by zhong on 16/11/24.
//
//

#include "AudioRecorder.h"
#include "audio/include/AudioEngine.h"

static const int AUDIO_BUFFER_SIZE = 100;
static int m_nAudioCount = 0;
//用户语音
struct CMD_GF_C_UserVoice
{
    DWORD                           dwTargetUserID;                     //目标用户
    DWORD                           dwVoiceLength;                      //语音长度
    BYTE                            byVoiceData[MAXT_VOICE_LENGTH];     //语音数据
};

//用户语音
struct CMD_GF_S_UserVoice
{
    DWORD                           dwSendUserID;                       //发送用户
    DWORD                           dwTargetUserID;                     //目标用户
    DWORD                           dwVoiceLength;                      //语音长度
    BYTE                            byVoiceData[MAXT_VOICE_LENGTH];     //语音数据
};

#include "RecorderHelper.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include <jni.h>
#include "platform/android/jni/JniHelper.h"
static const char* JAVA_CLASS = "org/cocos2dx/lua/AppActivity";
#endif

USING_NS_CC;
using namespace experimental;

#if CC_ENABLE_SCRIPT_BINDING
#include "CCLuaEngine.h"
#include "tolua_fix.h"
#endif

static AudioRecorder* _recorderInstance = nullptr;
AudioRecorder::AudioRecorder():
m_bInit(false)
{
    m_strRecordPath = FileUtils::getInstance()->getWritablePath();
    m_strDownloadPath = FileUtils::getInstance()->getWritablePath();
    m_dwStartIdx = 0;
}

AudioRecorder::~AudioRecorder()
{
    
}

AudioRecorder* AudioRecorder::getInstance()
{
    if (nullptr == _recorderInstance)
    {
        _recorderInstance = new AudioRecorder();
        
    }
    return _recorderInstance;
}

void AudioRecorder::destroy()
{
    CC_SAFE_DELETE(_recorderInstance);
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    destroyRecordHelper();
#endif
}

void AudioRecorder::init(const std::string &recordPath, const std::string &downloadPath)
{
    m_bInit = true;
    if (recordPath.length() > 0)
    {
        m_strRecordPath = recordPath;
        if (recordPath[recordPath.length()-1] != '/')
        {
            m_strRecordPath = recordPath + "/";
        }
    }
    if (!FileUtils::getInstance()->isDirectoryExist(m_strRecordPath))
    {
        FileUtils::getInstance()->createDirectory(m_strRecordPath);
    }
    if (downloadPath.length() > 0)
    {
        m_strDownloadPath = downloadPath;
        if (downloadPath[downloadPath.length()-1] != '/')
        {
            m_strDownloadPath = downloadPath + "/";
        }
    }
    if (!FileUtils::getInstance()->isDirectoryExist(m_strDownloadPath))
    {
        FileUtils::getInstance()->createDirectory(m_strDownloadPath);
    }
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    initRecordHelper(m_strRecordPath);
#endif
}

void AudioRecorder::startRecord(const std::string &filename /*= "record.mp3"*/)
{
    if (false == m_bInit)
    {
        log(" do not init AudioRecorder ");
        return;
    }
    m_strRecordFile = filename;
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    startRecordHelper(filename);
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    JniMethodInfo minfo;
    std::string fullPath = m_strRecordPath + filename;
    if (JniHelper::getStaticMethodInfo(minfo, JAVA_CLASS, "startRecord", "(Ljava/lang/String;)V"))
    {
        jstring jFullPath = minfo.env->NewStringUTF(fullPath.c_str());
        minfo.env->CallStaticVoidMethod(minfo.classID,minfo.methodID,jFullPath);
        minfo.env->DeleteLocalRef(jFullPath);
        minfo.env->DeleteLocalRef(minfo.classID);
    }
#endif
}

void AudioRecorder::endRecord()
{
    if (false == m_bInit)
    {
        log(" do not init AudioRecorder ");
        return;
    }
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    endRecordHelper();
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    JniMethodInfo minfo;
    if (JniHelper::getStaticMethodInfo(minfo, JAVA_CLASS, "stopRecord", "()V"))
    {
        minfo.env->CallStaticVoidMethod(minfo.classID,minfo.methodID);
        minfo.env->DeleteLocalRef(minfo.classID);
    }
#endif
}

void AudioRecorder::cancelRecord()
{
    if (false == m_bInit)
    {
        log(" do not init AudioRecorder ");
        return;
    }
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    endRecordHelper();
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    JniMethodInfo minfo;
    if (JniHelper::getStaticMethodInfo(minfo, JAVA_CLASS, "cancelRecord", "()V"))
    {
        minfo.env->CallStaticVoidMethod(minfo.classID,minfo.methodID);
        minfo.env->DeleteLocalRef(minfo.classID);
    }
#endif
}

bool AudioRecorder::attachPackage(tagRecordPackage* pPackage, DWORD dwStart, DWORD dwCount, std::string &szFilepath)
{
    DWORD dwUser = pPackage->dwSendUser;
    // 录音玩家
    auto ite = m_mapRecordPackages.find(dwUser);
    std::vector<tagRecordPackage*> vecRec = std::vector<tagRecordPackage*>();
    if (m_mapRecordPackages.end() == ite)
    {
        vecRec.push_back(pPackage);
        m_mapRecordPackages.insert(std::make_pair(pPackage->dwSendUser, vecRec));
    }
    else
    {
        ite->second.push_back(pPackage);
        vecRec = ite->second;
    }
    
    bool bRes = false;
    // 录音组包
    if (dwStart + dwCount == (pPackage->dwPackgeIdx + 1))
    {
        // 排序
        std::sort(vecRec.begin(), vecRec.end(), [](tagRecordPackage *a, tagRecordPackage *b)
                  {
                      return a->dwPackgeIdx < b->dwPackgeIdx;
                  });
        // 存储
        ++m_nAudioCount;
        std::string fileFullPath = m_strDownloadPath + StringUtils::format("audio%d.mp3",m_nAudioCount % AUDIO_BUFFER_SIZE);
        FILE *fp = fopen(fileFullPath.c_str(), "wb+");
        if(fp)
        {
            szFilepath = fileFullPath;
            for (ssize_t i = 0; i < vecRec.size(); ++i)
            {
                tagRecordPackage *p = vecRec[i];
                fwrite(p->byVoiceData, sizeof(unsigned char), p->dwVoiceLength, fp);
                delete vecRec[i];
            }
            std::vector<tagRecordPackage*>().swap(vecRec);
            fclose(fp);
            bRes = true;
        }
        m_mapRecordPackages.erase(dwUser);
    }
    return bRes;
}

void AudioRecorder::clear()
{
    auto ite = m_mapRecordPackages.begin();
    for (; ite != m_mapRecordPackages.end(); ++ite)
    {
        auto rec = ite->second;
        for (ssize_t i = 0; i < rec.size(); ++i)
        {
            delete rec[i];
        }
        std::vector<tagRecordPackage*>().swap(rec);
    }
    m_mapRecordPackages.clear();
}

#if CC_ENABLE_SCRIPT_BINDING
static int toLua_AudioRecorder_getInstance(lua_State *tolua_S)
{
    int argc = lua_gettop(tolua_S);
    if (1 == argc)
    {
        AudioRecorder *ret = AudioRecorder::getInstance();
        object_to_luaval<AudioRecorder>(tolua_S, "cc.AudioRecorder", (AudioRecorder*)ret);
        return 1;
    }
    return 0;
}

static int toLua_AudioRecorder_init(lua_State *tolua_S)
{
    AudioRecorder *ret = (AudioRecorder*)tolua_tousertype(tolua_S, 1, nullptr);
    if (nullptr != ret)
    {
        int argc = lua_gettop(tolua_S);
        if (argc == 3)
        {
            std::string rPath = lua_tostring(tolua_S, 2);
            std::string dPath = lua_tostring(tolua_S, 3);
            ret->init(rPath, dPath);
            return 1;
        }
    }
    log(" init AudioRecorder error ");
    return 0;
}

static int toLua_AudioRecorder_startRecord(lua_State *tolua_S)
{
    AudioRecorder *ret = (AudioRecorder*)tolua_tousertype(tolua_S, 1, nullptr);
    if (nullptr != ret)
    {
        int argc = lua_gettop(tolua_S);
        if (argc == 1)
        {
            ret->startRecord();
            return 1;
        }
        else if (argc == 2)
        {
            std::string filename = lua_tostring(tolua_S, 2);
            ret->startRecord(filename);
            return 1;
        }
    }
    return 0;
}

static int toLua_AudioRecorder_endRecord(lua_State *tolua_S)
{
    AudioRecorder *ret = (AudioRecorder*)tolua_tousertype(tolua_S, 1, nullptr);
    if (nullptr != ret)
    {
        ret->endRecord();
        return 1;
    }
    return 0;
}

static int toLua_AudioRecorder_cancelRecord(lua_State *tolua_S)
{
    AudioRecorder *ret = (AudioRecorder*)tolua_tousertype(tolua_S, 1, nullptr);
    if (nullptr != ret)
    {
        ret->cancelRecord();
        return 1;
    }
    return 0;
}

static int toLua_AudioRecorder_createSendBuffer(lua_State *tolua_S)
{
    AudioRecorder *ret = (AudioRecorder*)tolua_tousertype(tolua_S, 1, nullptr);
    if (nullptr != ret)
    {
        std::string fileFullPath = ret->m_strRecordPath + ret->m_strRecordFile;
        if (FileUtils::getInstance()->isFileExist(fileFullPath))
        {
            Data pData = FileUtils::getInstance()->getDataFromFile(fileFullPath);
            ssize_t size = pData.getSize();
            if (0 != pData.getSize())
            {
                int nPackage = MAXT_VOICE_LENGTH - 12;
                // 分包发送
                ssize_t nCount = size / nPackage;
                ssize_t nLeft = size - nCount * nPackage;
                size_t nSendCount = (nLeft > 0) ? nCount + 1 : nCount;
                BYTE *pBuffer = pData.getBytes();
                DWORD dwStart = ret->m_dwStartIdx;
                
                for (auto i = 0; i < nCount; ++i)
                {
                    CMD_GF_C_UserVoice cmd;
                    cmd.dwTargetUserID = INVALID_USERID;
                    cmd.dwVoiceLength = (DWORD)nPackage + 12;
                    memcpy(cmd.byVoiceData, pBuffer, nPackage);
                    pBuffer += nPackage;
                    int nSize = sizeof(cmd) - sizeof(cmd.byVoiceData) + cmd.dwVoiceLength;
                    
                    CCmd_Data *buffer = CCmd_Data::create(nSize);
                    buffer->PushByteData((BYTE*)&cmd.dwTargetUserID, 4);
                    buffer->PushByteData((BYTE*)&cmd.dwVoiceLength, 4);
                    // test
                    buffer->PushByteData((BYTE*)&dwStart, 4);
                    buffer->PushByteData((BYTE*)&nSendCount, 4);
                    DWORD dwIdx = i + dwStart;
                    buffer->PushByteData((BYTE*)&dwIdx, 4);
                    // test
                    buffer->PushByteData((BYTE*)&cmd.byVoiceData, nPackage);
                    object_to_luaval<CCmd_Data>(tolua_S, "cc.CCmd_Data", (CCmd_Data*)buffer);
                }
                if (nLeft > 0)
                {
                    CMD_GF_C_UserVoice cmd;
                    cmd.dwTargetUserID = INVALID_USERID;
                    cmd.dwVoiceLength = (DWORD)nLeft + 12;
                    memcpy(cmd.byVoiceData, pBuffer, nLeft);
                    int nSize = sizeof(cmd) - sizeof(cmd.byVoiceData) + cmd.dwVoiceLength;
                    
                    CCmd_Data *buffer = CCmd_Data::create(nSize);
                    buffer->PushByteData((BYTE*)&cmd.dwTargetUserID, 4);
                    buffer->PushByteData((BYTE*)&cmd.dwVoiceLength, 4);
                    
                    // test
                    buffer->PushByteData((BYTE*)&dwStart, 4);
                    buffer->PushByteData((BYTE*)&nSendCount, 4);
                    DWORD dwIdx = (DWORD)(nCount + dwStart);
                    buffer->PushByteData((BYTE*)&dwIdx, 4);
                    // test
                    
                    buffer->PushByteData((BYTE*)&cmd.byVoiceData, nLeft);
                    object_to_luaval<CCmd_Data>(tolua_S, "cc.CCmd_Data", (CCmd_Data*)buffer);
                    ++nCount;
                }
                ++ret->m_dwStartIdx;
                return (int)nCount;
            }
        }
    }
    return 0;
}

static int toLua_AudioRecorder_saveRecordFile(lua_State *tolua_S)
{
    AudioRecorder *ret = (AudioRecorder*)tolua_tousertype(tolua_S, 1, nullptr);
    if (nullptr != ret)
    {
        int argc = lua_gettop(tolua_S);
        if (argc == 3)
        {
            CCmd_Data *buffer = (CCmd_Data*)tolua_tousertype(tolua_S, 2, nullptr);
            if (nullptr != buffer)
            {
                WORD idx = buffer->GetCurrentIndex();
                if (idx + 4 > buffer->GetBufferLenght())
                {
                    return 0;
                }
                // CMD_GF_S_UserVoice
                BYTE tmp[4] = {0};
                memcpy(tmp, (void*)(buffer->m_pBuffer+idx), 4);
                buffer->SetCurrentIndex(idx + 4);
                DWORD dwSendUerId = *(DWORD*)tmp;
                
                idx = buffer->GetCurrentIndex();
                if (idx + 4 > buffer->GetBufferLenght())
                {
                    return 0;
                }
                memset(tmp, 0, 4);
                memcpy(tmp, (void*)(buffer->m_pBuffer+idx), 4);
                buffer->SetCurrentIndex(idx + 4);
                DWORD dwTargetUserID = *(DWORD*)tmp;
                
                idx = buffer->GetCurrentIndex();
                if (idx + 4 > buffer->GetBufferLenght())
                {
                    return 0;
                }
                memset(tmp, 0, 4);
                memcpy(tmp, (void*)(buffer->m_pBuffer+idx), 4);
                buffer->SetCurrentIndex(idx + 4);
                DWORD dwVoiceLength = *(DWORD*)tmp - 12;
                
                // test
                idx = buffer->GetCurrentIndex();
                if (idx + 4 > buffer->GetBufferLenght())
                {
                    return 0;
                }
                memset(tmp, 0, 4);
                memcpy(tmp, (void*)(buffer->m_pBuffer+idx), 4);
                buffer->SetCurrentIndex(idx + 4);
                DWORD dwStart = *(DWORD*)tmp;
                
                idx = buffer->GetCurrentIndex();
                if (idx + 4 > buffer->GetBufferLenght())
                {
                    return 0;
                }
                memset(tmp, 0, 4);
                memcpy(tmp, (void*)(buffer->m_pBuffer+idx), 4);
                buffer->SetCurrentIndex(idx + 4);
                DWORD dwPackageCount = *(DWORD*)tmp;
                
                idx = buffer->GetCurrentIndex();
                if (idx + 4 > buffer->GetBufferLenght())
                {
                    return 0;
                }
                memset(tmp, 0, 4);
                memcpy(tmp, (void*)(buffer->m_pBuffer+idx), 4);
                buffer->SetCurrentIndex(idx + 4);
                DWORD dwPackageIndex = *(DWORD*)tmp;
                // test
                
                idx = buffer->GetCurrentIndex();
                if (idx + dwVoiceLength > buffer->GetBufferLenght())
                {
                    return 0;
                }
                
                tagRecordPackage* p = new tagRecordPackage();
                memset(p, 0, sizeof(tagRecordPackage));
                p->dwSendUser = dwSendUerId;
                p->dwPackgeIdx = dwPackageIndex;
                p->dwVoiceLength = dwVoiceLength;
                memcpy(p->byVoiceData, buffer->m_pBuffer, dwVoiceLength);
                
                buffer->SetCurrentIndex(idx + dwVoiceLength);
                std::string fileFullPath = "";
                // 组包
                if (ret->attachPackage(p, dwStart, dwPackageCount, fileFullPath))
                {
                    auto nHandler = toluafix_ref_function(tolua_S, 3, 0);
                    lua_pushinteger(tolua_S, dwSendUerId);
                    lua_pushinteger(tolua_S, dwTargetUserID);
                    lua_pushstring(tolua_S, fileFullPath.c_str());
                    return LuaEngine::getInstance()->getLuaStack()->executeFunctionByHandler(nHandler, 3);
                }
                
                
                return 0;
            }
        }
    }
    return 0;
}

static int toLua_AudioRecorder_setFinishCallBack(lua_State *tolua_S)
{
    AudioRecorder *ret = (AudioRecorder*)tolua_tousertype(tolua_S, 1, nullptr);
    if (nullptr != ret)
    {
        int argc = lua_gettop(tolua_S);
        if (argc == 3)
        {
            int audioId = (int)lua_tointeger(tolua_S, 2);
            auto nHandler = toluafix_ref_function(tolua_S, 3, 0);
            AudioEngine::setFinishCallback(audioId,[nHandler, tolua_S](int aid, const std::string & name)
                                                         {
                                                             lua_pushinteger(tolua_S, aid);
                                                             lua_pushstring(tolua_S, name.c_str());
                                                             LuaEngine::getInstance()->getLuaStack()->executeFunctionByHandler(nHandler, 3);
                                                         });
            return 1;
        }
    }
    return 0;
}

static int toLua_AudioRecorder_clear(lua_State *tolua_S)
{
    AudioRecorder *ret = (AudioRecorder*)tolua_tousertype(tolua_S, 1, nullptr);
    if (nullptr != ret)
    {
        ret->clear();
        return 1;
    }
    return 0;
}
#endif

int register_all_recorder()
{
#if CC_ENABLE_SCRIPT_BINDING
    lua_State* tolua_S = LuaEngine::getInstance()->getLuaStack()->getLuaState();
    
    tolua_usertype(tolua_S, "cc.AudioRecorder");
    tolua_cclass(tolua_S,"AudioRecorder","cc.AudioRecorder","",nullptr);
    
    tolua_beginmodule(tolua_S,"AudioRecorder");
    tolua_function(tolua_S,"getInstance",toLua_AudioRecorder_getInstance);
    tolua_function(tolua_S,"init",toLua_AudioRecorder_init);
    tolua_function(tolua_S,"startRecord",toLua_AudioRecorder_startRecord);
    tolua_function(tolua_S,"endRecord",toLua_AudioRecorder_endRecord);
    tolua_function(tolua_S,"cancelRecord",toLua_AudioRecorder_cancelRecord);
    tolua_function(tolua_S,"createSendBuffer",toLua_AudioRecorder_createSendBuffer);
    tolua_function(tolua_S,"saveRecordFile",toLua_AudioRecorder_saveRecordFile);
    tolua_function(tolua_S,"setFinishCallBack",toLua_AudioRecorder_setFinishCallBack);
    tolua_function(tolua_S,"clear",toLua_AudioRecorder_clear);
    tolua_endmodule(tolua_S);
    
    std::string typeName = typeid(AudioRecorder).name();
    g_luaType[typeName] = "cc.AudioRecorder";
    g_typeCast["AudioRecorder"] = "cc.AudioRecorder";
#endif
    return 1;
}