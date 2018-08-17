/***************************************************************************
 *                �����������ɼ������޹�˾ ��Ȩ����
 *      Copyright (C) 2011 CoreTek Systems Inc. All Rights Reserved.
***************************************************************************/

/**
 * @file: taArchLib.c
 * @brief:
 *             <li>ʵ�ֶ�CPU�жϺ��쳣ͨ�ô�������ز���</li>
 */

/************************ͷ �� ��******************************/

/************************�� �� ��******************************/

/************************���Ͷ���*****************************/

/************************�ⲿ����*****************************/

/************************ǰ������*****************************/

/************************ģ�����*****************************/

/************************ȫ�ֱ���*****************************/

/************************����ʵ��*****************************/

/* �����쳣����ڶ��� */
.macro IDT_EXCEPTION_WITH_FAULTCODE_ENTRY vector 
.p2align 4       
.global exceptionEntry_\vector
exceptionEntry_\vector :	
	pushl	$\vector	
	jmp  taGeneralExpAsmHandler
.endm

.macro IDT_EXCEPTION_WITHOUT_FAULTCODE_ENTRY vector 
.p2align 4 
.global exceptionEntry_\vector	
exceptionEntry_\vector :
	pushl	$0	
	pushl	$\vector	
	jmp   taGeneralExpAsmHandler
.endm

.macro IDT_FLOAT_EXCEPTION_WITHOUT_FAULTCODE_ENTRY vector 
.p2align 4 
.global exceptionEntry_\vector	
exceptionEntry_\vector :	
	fnclex
	pushl	$0	
	pushl	$\vector	
	jmp   taGeneralExpAsmHandler
.endm

/* ������� */
IDT_EXCEPTION_WITHOUT_FAULTCODE_ENTRY 0

/* �����쳣�����ݣ�*/
IDT_EXCEPTION_WITHOUT_FAULTCODE_ENTRY 1

/* �������ж� */
IDT_EXCEPTION_WITHOUT_FAULTCODE_ENTRY 2

/* �ϵ� */
IDT_EXCEPTION_WITHOUT_FAULTCODE_ENTRY 3

/* ������� */
IDT_EXCEPTION_WITHOUT_FAULTCODE_ENTRY 4

/* Boundָ�ΧԽ�� */
IDT_EXCEPTION_WITHOUT_FAULTCODE_ENTRY 5

/* ��Чָ�� */
IDT_EXCEPTION_WITHOUT_FAULTCODE_ENTRY 6

/* û����ѧЭ������ */
IDT_EXCEPTION_WITHOUT_FAULTCODE_ENTRY 7

/* �����쳣 */
IDT_EXCEPTION_WITH_FAULTCODE_ENTRY    8

/* Э�������δ��� */
IDT_EXCEPTION_WITHOUT_FAULTCODE_ENTRY 9

/* TSS��Ч */
IDT_EXCEPTION_WITH_FAULTCODE_ENTRY 10

/* �β����� */
IDT_EXCEPTION_WITH_FAULTCODE_ENTRY 11

/* ջ���쳣 */
IDT_EXCEPTION_WITH_FAULTCODE_ENTRY 12

/* �����쳣 */
IDT_EXCEPTION_WITH_FAULTCODE_ENTRY 13

/* ҳ�쳣 */
IDT_EXCEPTION_WITH_FAULTCODE_ENTRY 14

/* �����쳣(15����Intel�����ģ�����Թ�) */

/* ������������쳣 */
IDT_FLOAT_EXCEPTION_WITHOUT_FAULTCODE_ENTRY 16

/* �����쳣 */
IDT_EXCEPTION_WITH_FAULTCODE_ENTRY 17

/* Machine Check�쳣 */
IDT_EXCEPTION_WITHOUT_FAULTCODE_ENTRY 18

/* SIMD �����쳣 */
IDT_EXCEPTION_WITHOUT_FAULTCODE_ENTRY 19