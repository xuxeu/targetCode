/***************************************************************************
 *                北京科银京成技术有限公司 版权所有
 *      Copyright (C) 2011 CoreTek Systems Inc. All Rights Reserved.
***************************************************************************/

/**
 * @file  dbArchLib.c
 * @brief:
 *             <li>ARCH相关的异常处理</li>
 */
/************************头文件******************************/
#include "dbAtom.h"
#include "taUtil.h"
#include "ta.h"

/************************宏定义******************************/

/************************类型定义****************************/
#if 0

/* 核心态异常产生时CPU压栈信息 */
typedef struct
{
    UINT32 pc;
    UINT16 cs;
    UINT16 pad0;
    UINT32 eflags;
} ESF0;

/* 用户态异常产生时CPU压栈信息 */
typedef struct
{
	UINT32 pc;
	UINT16 cs;
	UINT16 pad0;
	UINT32 eflags;
	UINT32 esp;
	UINT32 ss;
} ESF2;

#endif




/************************全局变量****************************/

/************************前向声明****************************/

/* 用户态CS寄存器值 */
extern int sysCsUser;

/************************模块变量****************************/

/************************函数实现*****************************/

/*
 * @brief:
 *      获取异常上下文
 * @param[in]: info: 异常产生时CPU压栈的上下文，包括EFLAGS, CS, EIP等
 * @param[in]: regs: 栈上保存的异常上下文
 * @param[out]: context: 上下文指针
 * @return:
 *     无
 */
static void taDebugGetExceptionContext(ESF0 *info, int *regs, T_DB_ExceptionContext *context)
{
	/* 保存通用寄存器 */
	context->registers[EDI] = *regs++;
	context->registers[ESI] = *regs++;
	context->registers[EBP] = *regs++;
	context->registers[ESP] = *regs++;
	context->registers[EBX] = *regs++;
	context->registers[EDX] = *regs++;
	context->registers[ECX] = *regs++;
	context->registers[EAX] = *regs++;

#ifdef _TA_CONFIG_RTP
    ESF2 *userInfo = (ESF2 *)info;

    if(info->cs == sysCsUser)
    {
    	context->registers[ESP] = userInfo->esp;
    }
    else
    {
    	context->registers[ESP] = (UINT32)((char *)info + sizeof(ESF0));
    }
#else
    context->registers[ESP] = (UINT32)((char *)info + sizeof(ESF0));
#endif /* _TA_CONFIG_RTP */

    /* 保存PC、EFLAGS寄存器 */
    context->registers[PC] = (UINT32)info->pc;
    context->registers[EFLAGS] = info->eflags;
    
}


static void taDebugGetAllExceptionContext(ESF0 *info,EXC_INFO *pExcInfo, int *regs, T_DB_ExceptionContext *context)
{
	/* 保存通用寄存器 */
	context->registers[EDI] = *regs++;
	context->registers[ESI] = *regs++;
	context->registers[EBP] = *regs++;
	context->registers[ESP] = *regs++;
	context->registers[EBX] = *regs++;
	context->registers[EDX] = *regs++;
	context->registers[ECX] = *regs++;
	context->registers[EAX] = *regs++;

    context->registers[ESP] = pExcInfo->esp0;

    /* 保存PC、EFLAGS寄存器 */
    context->registers[PC] = (int) pExcInfo->pc;
    context->registers[EFLAGS] = pExcInfo->eflags;
    context->vector = pExcInfo->vecNum;
    
    
}


/*
 * @brief:
 *      设置异常上下文
 * @param[in]: info: 异常产生时CPU压栈的上下文，包括EFLAGS, CS, EIP等
 * @param[in]: regs: 栈上保存的异常上下文
 * @param[in]: context: 上下文指针
 * @return:
 *     无
 */
static void taDebugSetExceptionContext(ESF0 *info, int *regs, T_DB_ExceptionContext *context)
{
	/* 恢复通用寄存器 */
    *regs++ = context->registers[EDI];
    *regs++ = context->registers[ESI];
    *regs++ = context->registers[EBP];
     regs++;
    *regs++ = context->registers[EBX];
    *regs++ = context->registers[EDX];
    *regs++ = context->registers[ECX];
    *regs++ = context->registers[EAX];

    /* 设置PC、EFLAGS寄存器 */
    info->pc = context->registers[PC];
    info->eflags = context->registers[EFLAGS];
}

/*
 * @brief:
 *      体系结构相关的异常处理入口函数
 * @param[in]: info: 异常产生时CPU压栈的上下文，包括EFLAGS, CS, EIP等
 * @param[in]: regs: 栈上保存的异常上下文，包括eax->ecx->edx->ebx->esp->ebp->esi->edi等寄存器
 * @param[in]: vector: 异常号
 * @return:
 *     无
 */
void taAachExceptionHandler(ESF0 *info, int *regs, UINT32 vector)
{
	T_DB_ExceptionContext context;

    /* 清空异常上下文  */
    ZeroMemory((void *)&context, sizeof(T_DB_ExceptionContext));

    /* 获取异常上下文 */
	taDebugGetExceptionContext(info, regs, &context);

    /* 调用通用异常处理函数  */
	taExceptionHandler(vector, &context);

    /* 设置异常上下文 */
    taDebugSetExceptionContext(info, regs, &context);
}


#ifdef EXCEPTAKE

void taOsExceptionHandler
(
UINT32 vector,   /*异常向量号*/

ESF0 *info,   /*CPU保存异常信息的栈地址，异常返回时会使用此信息返回到异常点。
                   根据是否存在错误码、是否存在特权级别切换，pEsf的数据类型可能是ESF0-ESF3中的一种。*/
                   
UINT32 *regs, /*保存的寄存信息，异常返回时会使用此信息恢复寄存器。*/

BOOL error,/*1表示有错误码，0表示没有错误码。*/

EXC_INFO *pExcInfo /*封装后的异常信息*/
)
{
	int ret = 11;

	ret = intCpuLock();


	T_DB_ExceptionContext context;

    /* 清空异常上下文  */
    ZeroMemory((void *)&context, sizeof(T_DB_ExceptionContext));

    /* 获取异常上下文 */
	taDebugGetAllExceptionContext(info,pExcInfo, regs, &context);

    /* 调用异常接管处理函数  */
	taExceptionTake(vector, &context);

    /* 设置异常上下文 */
    taDebugSetExceptionContext(info, regs, &context);

	intCpuUnlock(ret);


}

#endif

