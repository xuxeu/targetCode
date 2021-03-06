/*
* 更改历史：
* 2004-12-6 彭宏  北京科银技术有限公司
*                    创建该文件。
*/

/**
* @file  serveragent.h
* @brief
*       功能：
*       <li> server代理的实现</li>
*/
/************************头文件********************************/
#include "ServerAgent.h"
#include "Config.h"
#include "Device.h"
#include "Protocol.h"
#include "common.h"
#include "router.h"
//#include "Log.h"
#include "tcpDevice.h"
#include "DeviceUdp.h"
#include "PacketProtocol.h"
#include "DeviceUart.h"

/************************宏定义********************************/
/************************类型定义******************************/
/************************全局变量******************************/
/************************模块变量******************************/
/************************外部声明******************************/
/************************前向声明******************************/
/************************实现*********************************/
////////////////////////////////////////ServerAgent
ServerAgent::ServerAgent(unsigned short aid) : AgentWithQueue(aid)
{
    state = SASTATE_INACTIVE;
    pConfig = NULL;
    pThreadRX = NULL;
    pThreadTX = NULL;
    pProtocol = NULL;
    //pPacketLogger = NULL;
    type = AgentBase::SERVER_AGENT;
    timeout = 2000;
}

ServerAgent::~ServerAgent()
{
    if (pConfig != NULL )
    {
        delete pConfig;
        pConfig = NULL;
    }

    //释放关联的设备
    if (pProtocol != NULL)
    {
        if (pProtocol->getDevice()!= NULL)
        {
            delete  pProtocol->getDevice();
        }

        delete pProtocol;
        pProtocol = NULL;
    }
}

/**
* 功能：向router注册,运行server接收和发送线程
* @return true表示成功
*/
bool ServerAgent::run()
{
    if (pProtocol != NULL)
    {
        if (pProtocol->getDevice()!= NULL)
        {
            pProtocol->getDevice()->close();

            delete  pProtocol->getDevice();
        }

        delete pProtocol;
    }

    //创建设备
    if (!initDevice())
    {
        sysLoger(LWARNING, "ServerAgent::run: Initalize device for Agent %s failure!",
                 getName().toAscii().data());
        return false;
    }

    Router::getInstance()->registerAgent(this->getAID(),this);    //注册到router

    /*Modified by tangxp for BUG NO.0002803 on 2008.2.29 [begin]*/
    /*  Modified brief: 运行SA时关闭日志*/
    if (this->getLogFlag())
    {
        pPacketLogger->open((this->getName() + QString(".log")).toAscii().data());
    }

    /*Modified by tangxp for BUG NO.0002803 on 2008.2.29 [end]*/
    if (pThreadRX == NULL)
    {
        pThreadRX = new RXThread(this);

        if (pThreadRX == NULL)
        {
            return false;
        }

        /*Modifed by tangxp for BUG NO. 0002430 on 2008.1.4 [begin]*/
        /*  Modifed brief:用单独写的线程类优先级替换QT线程类优先级*/
        pThreadRX->start(baseThread::HighPriority);
        /*Modifed by tangxp for BUG NO. 0002430 on 2008.1.4 [end]*/
    }

    if (pThreadTX == NULL)
    {
        pThreadTX = new TXThread(this);

        if (pThreadTX == NULL)
        {
            return false;
        }

        pThreadTX->start();
    }

    return true;
}

/**
* 功能：停止server线程
*/
void ServerAgent::stop()
{
    this->setState(SASTATE_INACTIVE);

    if (pThreadTX != NULL)
    {
        pThreadTX->stop();
        pThreadTX->wait();
        delete  pThreadTX;
        pThreadTX = NULL;
    }

    if (pThreadRX != NULL)
    {
        pThreadRX->stop();

        pThreadRX->wait();    //等待线程退出
        delete  pThreadRX;
        pThreadRX = NULL;
    }

    close();

    /*Modified by tangxp for BUG NO.0002803 on 2008.2.29 [begin]*/
    /*  Modified brief: 停止SA时关闭日志*/
    //关闭日志文件
    if(pPacketLogger != NULL)
    {
        pPacketLogger->close();
    }

    /*Modified by tangxp for BUG NO.0002803 on 2008.2.29 [end]*/

}
/**
* 功能：关闭sa对应资源
*/
void ServerAgent::close()
{
    /*Modified by tangxp for BUG NO.0002555 on 2008.1.26 [begin]*/
    /*  Modified brief: 增加发送互斥*/
    TMutexLocker locker(&sendMutex);

    /*Modified by tangxp for BUG NO.0002555 on 2008.1.26 [end]*/
    //关闭线程对应的设备
    if (pProtocol != NULL)
    {
        DeviceBase* pDevice = pProtocol->getDevice();
        //释放协议在发送时,有可能堵塞的信号量
        pProtocol->close();

        //关闭协议对应的设备,并释放资源
        if (pDevice != NULL)
        {
            pDevice->close();
            delete pDevice;
            pDevice = NULL;
        }

        //释放协议对应的资源
        delete pProtocol;
        pProtocol = NULL;
    }
}
/**
* 功能：发送数据
*/
int ServerAgent::sendPacket(Packet* packet)
{
    /*Modified by tangxp for BUG NO.0002555 on 2008.1.26 [begin]*/
    /*  Modified brief: 增加发送互斥*/
    TMutexLocker sendLocker(&sendMutex);

    /*Modified by tangxp for BUG NO.0002555 on 2008.1.26 [end]*/
    if (pProtocol != NULL)
    {
        if(NULL == packet)
        {
            sysLoger(LWARNING, "ServerAgent::sendPacket: Bad pointer of packet!");
            return 0;
        }

        /*Modified by tangxp for BUG NO.0002550 on 2008.3.17 [begin]*/
        /*  Modified brief: 将记录消息日志集成到发送数据中
        调整记录位置到发送以后,可记录发送序列号*/
        int size = pProtocol->putpkt(packet);

        //记录消息日志
        if(getLogFlag() && getPacketLogger())
        {
            getPacketLogger()->write(SEND_PACK, *packet);
        }

        return size;
        /*Modified by tangxp for BUG NO.0002550 on 2008.3.17[end]*/
    }

    else
    {
        sysLoger(LWARNING, "ServerAgent::sendPacket: No Protocol for using, SA name:%s",
                 getName().toAscii().data());
        return 0;
    }
}
/**
* 功能：发送数据
* @return 接收包的大小
*/
int ServerAgent::receivePacket(Packet* packet)
{
    if (pProtocol != NULL)
    {
        if(NULL == packet)
        {
            sysLoger(LWARNING, "ServerAgent::receivePacket: Bad pointer of packet!");
            return -1;
        }

        int recvSize = pProtocol->getpkt(packet);

        /*Modified by tangxp for BUG NO.0002550 on 2008.1.8 [begin]*/
        /*  Modified brief: 将记录消息日志集成到接收数据中*/
        //记录消息日志
        if(getLogFlag() && getPacketLogger() && recvSize > 0)
        {
            getPacketLogger()->write(RECV_PACK, *packet);
        }

        /*Modified by tangxp for BUG NO.0002550 on 2008.1.8 [end]*/
        return recvSize;
    }

    else
    {
        sysLoger(LWARNING, "ServerAgent::receivePacket: No Protocol for using, SA name:%s",
                 getName().toAscii().data());
        return -1;
    }
}

/**
* 功能：将配置信息序列化到OwnerArchive对象
*/
void ServerAgent::serialize(OwnerArchive& ar)
{
    QTextCodec::setCodecForCStrings(QTextCodec::codecForLocale());
    AgentWithQueue::serialize(ar);
}

/**
* 功能：打开设备和初始化协议
* @return true表示成功
*/
bool ServerAgent::initDevice()
{
    //创建设备
    DeviceBase* pDevice = NULL;

    if((pConfig != NULL) && (pConfig->getDeviceConfig() != NULL)\
            && (DeviceManage::getInstance() != NULL))
    {
        pDevice = DeviceManage::getInstance()->createDevice(
                      pConfig->getDeviceConfig()->getDeviceType());
    }

    else
    {
        sysLoger(LWARNING, "ServerAgent::initDevice: No usable device config or server config for SA:%s",
                 name.toAscii().data());
        return false;
    }

    if (pDevice == NULL)
    {
        sysLoger(LWARNING, "ServerAgent::initDevice: Created device for Agent %s failure!",
                 getName().toAscii().data());
        return false;
    }

    if (!pDevice->open(pConfig))
    {
        //打开设备
        delete  pDevice;
        pDevice = NULL;
        sysLoger(LWARNING, "ServerAgent::initDevice: Open device for Agent %s failure!",
                 getName().toAscii().data());
        return false;
    }

    //创建sa关联的协议
    pProtocol = ProtocolManage::getInstance()->createProtocol(pConfig->getProtocolType(), pDevice);

    if(NULL == pProtocol)
    {
        sysLoger(LWARNING, "ServerAgent::initDevice: Created protocol for Agent %s failure!",
                 getName().toAscii().data());
        delete pDevice;
        pDevice = NULL;
        return false;
    }

    return true;
}
