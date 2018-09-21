/***************************************************************************
 *				�����������ɼ������޹�˾ ��Ȩ����
 * 	 Copyright (C) 2013 CoreTek Systems Inc. All Rights Reserved.
***************************************************************************/

/*
 * �޸���ʷ:
 * 2013-11-07         ��Ԫ־�������������ɼ������޹�˾
 *                          �������ļ���
 */

/*
 * @file:dbDbgALib.S
 * @brief:
 *             <li>�ϵ㡢�����쳣����</li>
 */

/************************ͷ �� ��*****************************/
#define ASM_USE
#define _ASMLANGUAGE
#include <dbAsm.h>
#ifdef CONFIG_DELTAOS
#include <objLibP.h>
#include <delta.h>
#include <coreSmpI86P.h>
#endif

/************************�� �� ��******************************/

#define CORE_OBJ_CORE_SIZE 0x40

/************************���Ͷ���*****************************/

/************************�ⲿ����*****************************/

/************************ǰ������*****************************/

/************************ģ�����*****************************/

/************************ȫ�ֱ���*****************************/

/************************����ʵ��*****************************/
.data

.globl	FUNC(taAachExceptionHandler)/* �쳣�������� */
.globl	GTEXT(taBpExceptionStub)	/* �ϵ�����쳣��ں��� */
.globl	GTEXT(taTraceExceptionStub)	/* ���ݵ����쳣��ں��� */

.text
.balign 16

/* �ϵ��쳣������ں��� */
FUNC_LABEL(taBpExceptionStub)
	cli
	pushl	eax	         /* ����eax */

#ifdef _TA_CONFIG_RTP
	movl	FUNC(sysCsUser), eax/* �Ƿ����û�ģʽ  */
	cmpl	eax, 0x8(esp)
	jne	taStubSuper
taStubUser:

#ifdef CONFIG_DELTAOS
	pushl	edx	 /* ����edx */
	_IA32_PER_CPU_VALUE_GET(eax,edx,threadIdCurrent) /* ��ȡ��ǰ�߳̿��ƿ��ַ */
	popl    edx  /* �ָ�edx */

	incl CORE_TCB_EXC_CNT(eax) /* �쳣������һ��������ǰ���쳣ջ�� */
#endif
	/* �����Ҫִ�е��쳣�������̽�С����Ҫ����ջ�л����������ѱ��жϵ����̵�ջ��ѡ���Ӻ�ջָ��ѹջ��
	        ��Ȩ��δ�ı��ѹջ����ΪEFLAGS, CS, EIP������ΪSS, ESP, EFLAGS, CS, EIP*/
	popl	eax     /* �ָ�eax */
	pushal		     /* �Ĵ�����ͨ�üĴ��������ΰ�eax->ecx->edx->ebx->esp->ebp->esi->ediѹ��ջ�� */
	movl	0x2c(esp), eax	/* ��ȡ�û�ģʽ��SP */
	movl	eax, 0x0c(esp)	/* ����û�̬��SP��ջ�ϣ�REG_ESPΪREG_SET�ṹ���ƫ��  */

	movl	FUNC(sysDsSuper), eax /* ���öμĴ��� */
	movw    ax,ds
	movw    ax,es
	movw    ax,fs
	movw    ax,gs
	jmp	taStubCont
#endif
taStubSuper:
	popl    eax        /* �ָ�eax */
	pushal             /* �Ĵ�����ͨ�üĴ��������ΰ�eax->ecx->edx->ebx->esp->ebp->esi->ediѹ��ջ�� */

taStubCont:
	movl	esp,eax
	pushl	ebp
	movl	esp,ebp
	decl	0x20+0x4(ebp) /* ��������Ĵ���ֵ�����ڶϵ��쳣�����������쳣��ָ����һ��ָ�������Ҫ����PCֵ */
	pushl	$3			  /* ѹջvector,�ϵ��쳣��Ϊ3 */
	pushl	eax	          /* ��ESP�Ĵ���ֵѹջ,ջ�ϱ������쳣������  */
	leal	0x20+0x4(ebp),eax
	pushl	eax		      /* ѹջinfo */
	call	FUNC(taAachExceptionHandler) /* C�����쳣�������� */

	addl	$0x10,esp  /* ջָ���16����Ϊ ����taExceptionHandler����ʱѹջ����������+ebp */
	popal			   /* �ָ�����ͨ�üĴ��� */

	pushl	eax		   /* ����EAX�Ĵ���������������Ҫ�õ��üĴ��� */

#ifdef _TA_CONFIG_RTP
	movl	0x08(esp), eax	     /* ��ȡCS�Ĵ�������ǰջ�ϵļĴ���ΪSS, ESP, EFLAGS, CS, EIP, EAX */
	cmpl	eax, FUNC(sysCsUser) /* �Ƿ����û�ģʽ  */
	jne	    taExitSuper 	     /* ���� */
taExitUser:
#ifdef CONFIG_DELTAOS
	pushl	edx	 /* ����edx */
	_IA32_PER_CPU_VALUE_GET(eax,edx,threadIdCurrent) /* ��ȡ��ǰ�߳̿��ƿ��ַ */
	popl    edx  /* �ָ�edx */

	decl CORE_TCB_EXC_CNT(eax) /* �쳣������һ��������ǰ���쳣ջ�� */
#endif
	movl	FUNC(sysDsUser), eax /* ����Ϊϵͳ̬��ѡ���� */
	movw	ax,ds
	movw	ax,es
	movw	ax,fs
	movw	ax,gs
#endif
taExitSuper:
	popl	eax		/* �ָ�eax */
	iret			/* ���ص����� */

/* Ӳ���ϵ�������쳣��ڴ���
 *  (1) �����쳣	Trap(�������쳣) DR6�Ĵ�����        BS=1
 *  (2) Ӳ��ָ���쳣(ָ��ϵ�) Falt(�������쳣) Bn=1
 *  (3) ���ݶϵ�	Trap(�������쳣)  DR6�Ĵ�����      Bn=1
*/
	.balign 16,0x90
FUNC_LABEL(taTraceExceptionStub)
	cli
	andl	$0xfffffeff,0x8(esp) /* ���ջ�ϵ�EFLAGS������־��ϵͳ̬ջ�ϼĴ���ΪEFLAGS, CS, EIP��
									   ����ΪSS, ESP, EFLAGS, CS, EIP */
	pushl	eax			      /* ����EAX�Ĵ��� */
#ifdef _TA_CONFIG_RTP
	movl	FUNC(sysCsUser), eax /* �Ƿ����û�ģʽ  */
	cmpl	eax, 0x8(esp)

	jne	taTraceStubSuper /* �����û�̬��ת��taTraceStubSuperִ�� */

taTraceStubUser:
#ifdef CONFIG_DELTAOS
	pushl	edx	 /* ����edx */
	_IA32_PER_CPU_VALUE_GET(eax,edx,threadIdCurrent) /* ��ȡ��ǰ�߳̿��ƿ��ַ */
	popl    edx  /* �ָ�edx */

	incl CORE_TCB_EXC_CNT(eax) /* �쳣������һ��������ǰ���쳣ջ�� */
#endif
	popl    eax             /* �ָ�EAX�Ĵ��� */
	pushal                  /* �Ĵ�����ͨ�üĴ��������ΰ�eax->ecx->edx->ebx->esp->ebp->esi->ediѹ��ջ�� */
	movl	0x2c(esp), eax	/* ��ȡ�û�ģʽ��SP */
	movl	eax, 0x0c(esp)	/* ����û�̬��SP��ջ�ϣ�REG_ESPΪREG_SET�ṹ���ƫ��  */

	movl	FUNC(sysDsSuper), eax /* ���öμĴ��� */
	movw    ax,ds
	movw    ax,es
	movw    ax,fs
	movw    ax,gs

	jmp	taTraceStubCont /* ̬��ת��taTraceStubContִ�� */
#endif
taTraceStubSuper:
	popl    eax   /* �ָ�EAX�Ĵ��� */
	pushal        /* �Ĵ�����ͨ�üĴ��������ΰ�eax->ecx->edx->ebx->esp->ebp->esi->ediѹ��ջ�� */

taTraceStubCont:
	movl	esp,eax
	pushl	ebp
	movl	esp,ebp
	pushl	$1	    /* ѹջvector,�����������쳣��Ϊ1 */
	pushl	eax	    /* ��ESP�Ĵ���ֵѹջ,ջ�ϱ������쳣������  */
	leal	0x20+0x4(ebp),eax
	pushl	eax		/* ѹջinfo */

	movl    db6,eax	/* ����DR6�Ĵ�����EAX */
	btl	$14,eax		/* �Ƿ��������쳣 */
	jc	taTrace0	/* �������ת��taTrace0 */
	orl	$0x00010000, 0x28+0x10(ebp) /* ����RF��־����ʾ�쳣����ִ�е�һ��ָ������쳣,ָ��ϵ�Ϊ�������쳣��CPU������ȡָʱ
								            �Ա����õĶϵ��ַ�����Բ����쳣ʱָ�δִ�У����Իָ�ʱ����RF��־������ �쳣����ִ�е�һ��ָ������쳣*/
	.balign 16,0x90
taTrace0:
	call	FUNC(taAachExceptionHandler) /* C�����쳣���� */

	addl	$0x10,esp /* ջָ���16����Ϊ ����taExceptionHandler����ʱѹջ����������+ebp */

	xorl	eax,eax
	movl	eax,db6	  /* ���DR6״̬λ */

	popal			  /* �ָ�����ͨ�üĴ��� */

#ifdef _TA_CONFIG_RTP
	pushl	eax	      /* ����EAX�Ĵ���������������Ҫ�õ��üĴ��� */
	movl	0x08(esp), eax	  /* ��ȡCS�Ĵ�������ǰջ�ϵļĴ���ΪSS, ESP, EFLAGS, CS, EIP��EAX */
	cmpl	eax, FUNC(sysCsUser) /* �Ƿ����û�ģʽ  */
	jne	taTraceExitSuper	      /* ���� */

taTraceExitUser:
#ifdef CONFIG_DELTAOS
	pushl	edx	 /* ����edx */
	_IA32_PER_CPU_VALUE_GET(eax,edx,threadIdCurrent) /* ��ȡ��ǰ�߳̿��ƿ��ַ */
	popl    edx  /* �ָ�edx */

	decl CORE_TCB_EXC_CNT(eax) /* �쳣������һ��������ǰ���쳣ջ�� */
#endif
	movl	FUNC(sysDsUser), eax /* �ָ�Ϊ�û�̬��ѡ���� */
	movw    ax,ds
	movw    ax,es
	movw    ax,fs
	movw    ax,gs
taTraceExitSuper:
	popl	eax	/* �ָ� eax�Ĵ��� */
#endif
	iret	    /* ���ص����� */

.global taTrap
taTrap:
    int3
    ret
