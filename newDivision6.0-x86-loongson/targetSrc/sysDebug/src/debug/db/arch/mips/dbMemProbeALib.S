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
 * @file:dbMemProbeALib.S
 * @brief:
 *             <li>�ڴ�̽�������֧��</li>
 */

/************************ͷ �� ��*****************************/
#define ASM_USE

#include <dbAsm.h>
/************************�� �� ��******************************/

/************************���Ͷ���*****************************/
#define OK	0
#define ERROR -1

/************************�ⲿ����*****************************/

/************************ǰ������*****************************/

/************************ģ�����*****************************/

/************************ȫ�ֱ���*****************************/
.globl  taMemProbeSup
.globl	taMemProbeByteRead
.globl	taMemProbeByteWrite
.globl	taMemProbeShortRead
.globl	taMemProbeShortWrite
.globl	taMemProbeWordRead
.globl	taMemProbeWordWrite
.globl	taMemProbeErrorRtn

/************************����ʵ��*****************************/
.text
.set	reorder

/*
 * �ú�����ͼ��д�ڴ棬���һ���쳣�����ڴ�̽���쳣��������taMemProbeTrapHandle��
 * ��PC����ΪtaMemProbeErrorRtn��ʹ��taMemProbeSup��������һ������ţ���ʾ�ڴ��д
 * ʧ�ܣ����ڴ��ַ�޷���д������ԭ�����£�
 * STATUS taMemProbeSup(length, src, dest)
 *     int length: length of cell to test (1, 2, 4)
 *     char *src : address to read
 *     char *dest: address to write
 */
.ent	taMemProbeSup
FUNC_LABEL(taMemProbeSup)
	li	v0, OK		/* default return to OK */
	li	t0,1		/* byte length operation */
	beq	a0,t0,taMemProbeByteRead
	li	t0,2		/* short length operation */
	beq	a0,t0,taMemProbeShortRead
	li	t0,4		/* word length operation */
	beq	a0,t0,taMemProbeWordRead
	b	taMemProbeErrorRtn	/* invalid length specified */

	.set noreorder
taMemProbeByteRead:
	lbu	t0,0(a1)
taMemProbeByteWrite:
	sb	t0,0(a2)
	sync
	b	passRtn
	nop
taMemProbeShortRead:
	lhu	t0,0(a1)
taMemProbeShortWrite:
	sh	t0,0(a2)
	sync
	b	passRtn
	nop
taMemProbeWordRead:
	lw	t0,0(a1)
taMemProbeWordWrite:
	sw	t0,0(a2)
	sync
	b	passRtn
	nop
	.set reorder

taMemProbeErrorRtn:
	li	v0, ERROR
passRtn:
	j	ra
	FUNC_END(taMemProbeSup)
	.end	taMemProbeSup