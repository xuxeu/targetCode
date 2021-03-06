/*
* 更改历史：
* 2004-12-6 彭宏  北京科银技术有限公司
*                    创建该文件。
*/

/**
* @file  ClientAgent.cpp
* @brief
*       功能：
*       <li>处理与客户端通信</li>
*/

/************************头文件********************************/
#include "ClientAgent.h"
#include "common.h"
#include "Protocol.h"
#include "Router.h"
#include "tcpDevice.h"
#include "../include/wsocket.h"

/************************宏定义********************************/
/************************类型定义******************************/
/************************全局变量******************************/
/************************模块变量******************************/
/************************外部声明******************************/
/************************前向声明******************************/



/************************实现*********************************/
ClientAgent::ClientAgent(ProtocolBase* pProtocol, short aid) : AgentBase(aid)
{

    this->pProtocol = pProtocol;
    runFlag = true;
    type = AgentBase::CLIENT_AGENT;
    exitState = Initialized;
#ifdef CLIENT_AGENT_DEBUG
    char tmp[50] = "\0";
    _itoa(aid, tmp, 10);
    strcat(tmp, "clientAgent.log");
    PacketLogger.open(tmp);
#endif
}

ClientAgent::~ClientAgent()
{
    while (exitState == Started)
    {
        Sleep(10);
    }

#ifdef CLIENT_AGENT_DEBUG
    PacketLogger.deleteLogFile();
#endif
}

void ClientAgent::close()
{
    try
    {
        if (pProtocol != NULL)
        {
            DeviceTcp* pDevice = dynamic_cast<DeviceTcp*>(pProtocol->getDevice());

            if(pDevice != NULL)
            {
                delete pDevice;
                pDevice = NULL;
            }

            delete pProtocol;
            pProtocol = NULL;
        }
    }

    catch(...)
    {
        sysLoger(LERROR, "ClientAgent::close: delete protocol or device failure!");
        return;
    }
}

void ClientAgent::putpkt(Packet* pack, bool isRelease)
{
    TMutexLocker lock(&mutex);
    int ret = 0;

    if (pProtocol == NULL)
    {
        runFlag = false;
    }

    else if (runFlag)
    {
        if(NULL == pack)
        {
            sysLoger(LWARNING, "ClientAgent::putpkt: Bad pointer of pack!");
            return;
        }

        ret = pProtocol->putpkt(pack);
#ifdef CLIENT_AGENT_DEBUG

        if(ret > 0 )
        {
            PacketLogger.write(SEND_PACK, *pack);
        }

        else
        {
            sysLoger(LWARNING, "ClientAgent::putpkt:Put the packet to client failure!");
        }

#endif

    }

    //释放分配的包
    if (isRelease)
    {
        PacketManager::getInstance()->free(pack);
    }
}

void ClientAgent::stop()
{
    TMutexLocker lock(&mutex);
    runFlag = false;
    Router::getInstance()->unRegisterAgent(getAID());    //注销ca在router的注册
    close();
}

void ClientAgent::run()
{
    exitState = Started;

    //需要注意socket的创建必须在同一个线程中,否则有些消息不能收到
    while (runFlag)
    {
        Packet* pack = PacketManager::getInstance()->alloc();

        if(NULL == pack)
        {
            sysLoger(LWARNING, "ClientAgent::run:Alloc pack failure!");
            continue;
        }

        pack->clearData();

        if((NULL == pProtocol) || (pProtocol->getpkt(pack) < 0))
        {
            //出现异常或连接断开时，停止运行，向Manager发包，通知Manager删除CA自己
            /*Modified by tangxp for BUG NO.3666 on 2008年7月17日 [begin]*/
            /*  Modified brief: 增加出现异常时的系统日志记录*/
            sysLoger(LWARNING, "ClientAgent::run:ClientAgent %d recieved packet fail, pProtocol:0x%x",
                     getAID(), pProtocol);
            /*Modified by tangxp for BUG NO.3666 on 2008年7月17日 [end]*/
            stop();

            char* pBuf = pack->getData();
            pack->clearData();
            __store(CURDID(getAID()), pBuf, DIDLEN);
            pBuf += DIDLEN;
            memcpy(pBuf, CONTROL_FLAG, CONTROL_FLAG_LEN);
            pBuf += CONTROL_FLAG_LEN;
            memcpy(pBuf, &DELETE_SERVER, CONTROL_COMMAND_LEN);                                //deleteServer的控制包标志符
            pBuf += CONTROL_COMMAND_LEN;
            pBuf += int2hex(pBuf, 10, this->getAID());
            memcpy(pBuf, CONTROL_FLAG, CONTROL_FLAG_LEN);
            pBuf += CONTROL_FLAG_LEN;

            pack->setSize(pBuf - pack->getData());
            pack->setDes_aid(0);    //向manger发送控制命令包
            pack->setSrc_aid(getAID());
            pack->setDes_said(0);    //向manger发送控制命令包
            pack->setSrc_said(0);
            Router::getInstance()->putpkt(pack);    //派发包
        }

        else
        {
            pack->setSrc_aid(getAID());                //设置源AID号
            Router::getInstance()->putpkt(pack);    //派发包
#ifdef CLIENT_AGENT_DEBUG
            PacketLogger.write(RECV_PACK, *pack);
#endif

            sysLoger(LDEBUG, "ClientAgent::run:ClientAgent %d recieved a packet, size:%d",
                     getAID(), pack->getSize());
        }
    }

    exitState = Finished;
}

