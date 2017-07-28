//
//  AudioRecorder.h
//  GloryProject
//
//  Created by zhong on 16/11/24.
//
//
#ifndef AudioRecorder_h
#define AudioRecorder_h

#include <stdio.h>
#include "cocos2d.h"
#include "../CMD_Data.h"

int register_all_recorder();

static const int MAXT_VOICE_LENGTH = 15000;
// 语音包
struct tagRecordPackage
{
    // 发送用户id
    DWORD dwSendUser;
    // 语音包索引
    DWORD dwPackgeIdx;
    // 语音长度
    DWORD dwVoiceLength;
    // 语音数据
    BYTE byVoiceData[MAXT_VOICE_LENGTH];
};

class AudioRecorder
{
private:
    AudioRecorder();
    ~AudioRecorder();
    
public:
    static AudioRecorder* getInstance();
    
    static void destroy();
    
    /*
     * @brief 初始化
     * @param[recordPath]   录音文件存储路径
     * @param[downloadPath] 录音文件下载路径
     */
    void init(const std::string &recordPath, const std::string &downloadPath);
    
    /*
     * @brief 开始录音
     */
    void startRecord(const std::string &filename = "record.mp3");
    
    /*
     * @brief 结束录音
     */
    void endRecord();

    /*
     * @brief 取消录音
     */
    void cancelRecord();
    
    /*
     * @brief 清理缓存
     */
    void clear();
    
    /*
     * @brief 组包
     * @param[pPackage] 单个录音包
     * @param[dwStart] 第一个录音包下标
     * @param[dwCount] 录音包总数
     * @param[szFilepath] 录音文件存储
     */
    bool attachPackage(tagRecordPackage* pPackage, DWORD dwStart, DWORD dwCount, std::string &szFilepath);
    
    std::string m_strRecordPath;
    std::string m_strDownloadPath;
    std::string m_strRecordFile;
    DWORD m_dwStartIdx;
private:
    bool m_bInit;
    std::map<DWORD, std::vector<tagRecordPackage*>> m_mapRecordPackages;
};
#endif /* AudioRecorder_h */