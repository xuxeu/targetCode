/***************************************************************************
 *				北京科银京成技术有限公司 版权所有
 * 	 Copyright (C) 2013 CoreTek Systems Inc. All Rights Reserved.
***************************************************************************/

/*
 *修改历史:
 *2013-06-27         彭元志，北京科银京成技术有限公司
 *                         创建该文件。
 */

/*
 * @file:taPrintk.c
 * @brief:
 *             <li>调试打印输出</li>
 */
 
/************************头 文 件******************************/
#include "ta.h"

/************************宏 定 义********************************/

/************************类型定义*******************************/

/************************外部声明*******************************/

/************************前向声明*******************************/

/************************模块变量*******************************/

/************************全局变量*******************************/

/************************函数实现*******************************/

/*
 * @brief:
 *    向printk设备打印单个字符
 * @param[in]: ch: 需要输出的字符
 * @return: 
 *    无
 */ 
void taPrintChar(T_CHAR ch)
{
    taDisplayDeviceOutputChar(ch);
    if (ch == '\n')
    {
    	/* 注：这里是为了调试时，在串口助手上显示的方便 */
        ch = '\r';
        taDisplayDeviceOutputChar(ch);
    }
}
