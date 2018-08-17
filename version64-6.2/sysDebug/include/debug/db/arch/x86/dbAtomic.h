/***************************************************************************
 *				�����������ɼ������޹�˾ ��Ȩ����
 * 	 Copyright (C) 2013 CoreTek Systems Inc. All Rights Reserved.
***************************************************************************/

/*
 *�޸���ʷ:
 *2013-06-23         ��Ԫ־�������������ɼ������޹�˾
 *                          �������ļ���
 */

/*
 * @file  dbAtomic.h
 * @brief:
 *             <li>ԭ�Ӳ����궨��</li>
 */
#ifdef CONFIG_CORE_SMP

#ifndef _DB_ATOMIC_H_
#define _DB_ATOMIC_H_

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

/************************ͷ�ļ�********************************/
#include "taTypes.h"

/************************�궨��********************************/

/* Macros to provide memory barrier */
#ifdef __X86__
#ifdef CONFIG_TA_LP64
	#define MEM_BARRIER_R()	    asm volatile("lock;addq $0,0(%%rsp)":::"memory");
	#define MEM_BARRIER_W()	    asm volatile("lock;addq $0,0(%%rsp)":::"memory");
	#define MEM_BARRIER_RW()	asm volatile("lock;addq $0,0(%%rsp)":::"memory");
	#define INSTR_BARRIER()     asm volatile("lock;addq $0,0(%%rsp)":::"memory");
#else
	#define MEM_BARRIER_R() 	asm volatile("lock;addl $0,0(%%esp)":::"memory");
	#define MEM_BARRIER_W() 	asm volatile("lock;addl $0,0(%%esp)":::"memory");
	#define MEM_BARRIER_RW()	asm volatile("lock;addl $0,0(%%esp)":::"memory");
	#define INSTR_BARRIER() 	asm volatile("lock;addl $0,0(%%esp)":::"memory");
#endif
#endif

/* ��targetָ���ֵ��oldValue�Աȣ������ȣ�����targetָ���ֵΪnewValue */
#ifdef CONFIG_TA_LP64
#define TA_MULTIOS_ATOMIC_CAS(target, oldValue, newValue)  \
	_atomic_64_cas(target, oldValue, newValue)
	
	/* ��ȡtargetָ���ֵ */
#define TA_MULTIOS_ATOMIC_GET(target)  _atomic_64_get(target)
	
	/* ��targetָ���ֵ����Ϊvalue��������targetԭ�е�ֵ */
#define TA_MULTIOS_ATOMIC_SET(target, value)  _atomic_64_set(target, value)
	
	/* ���targetָ���ֵ��������targetԭ�е�ֵ */
#define TA_MULTIOS_ATOMIC_CLEAR(target)  _atomic_64_clear(target)
	
	/* ��targetָ���ֵ��valueλ�򣬲�����targetԭ�е�ֵ */
#define TA_MULTIOS_ATOMIC_OR(target, value)  _atomic_64_or(target, value)
	
	/* ��targetָ���ֵ��valueλ�룬������targetԭ�е�ֵ */
#define TA_MULTIOS_ATOMIC_AND(target, value)  _atomic_64_and(target, value)

#else
#define TA_MULTIOS_ATOMIC_CAS(target, oldValue, newValue)  \
	_atomic_32_cas(target, oldValue, newValue)

/* ��targetָ���ֵ����value��������targetԭ�е�ֵ */
#define TA_MULTIOS_ATOMIC_ADD(target, value)  _atomic_32_add(target, value)

/* ��targetָ���ֵ��ȥvalue��������targetԭ�е�ֵ */
#define TA_MULTIOS_ATOMIC_SUB(target, value)  _atomic_32_sub(target, value)

/* ��targetָ���ֵ����1��������targetԭ�е�ֵ */
#define TA_MULTIOS_ATOMIC_INC(target)  _atomic_32_inc(target)

/* ��targetָ���ֵ��ȥ1��������targetԭ�е�ֵ */
#define TA_MULTIOS_ATOMIC_DEC(target)  _atomic_32_dec(target)

/* ��ȡtargetָ���ֵ */
#define TA_MULTIOS_ATOMIC_GET(target)  _atomic_32_get(target)

/* ��targetָ���ֵ����Ϊvalue��������targetԭ�е�ֵ */
#define TA_MULTIOS_ATOMIC_SET(target, value)  _atomic_32_set(target, value)

/* ���targetָ���ֵ��������targetԭ�е�ֵ */
#define TA_MULTIOS_ATOMIC_CLEAR(target)  _atomic_32_clear(target)

/* ��targetָ���ֵ��valueλ�򣬲�����targetԭ�е�ֵ */
#define TA_MULTIOS_ATOMIC_OR(target, value)  _atomic_32_or(target, value)

/* ��targetָ���ֵ��valueλ��򣬲�����targetԭ�е�ֵ */
#define TA_MULTIOS_ATOMIC_XOR(target, value)  _atomic_32_xor(target, value)

/* ��targetָ���ֵ��valueλ�룬������targetԭ�е�ֵ */
#define TA_MULTIOS_ATOMIC_AND(target, value)  _atomic_32_and(target, value)

#endif


/************************���Ͷ���******************************/

/************************�ӿ�����******************************/

#ifdef CONFIG_TA_LP64

/* ��targetָ���ֵ��oldValue�Աȣ������ȣ�����targetָ���ֵΪnewValue  */
BOOL _atomic_64_cas(long *target,atomic_t oldValue,atomic_t newValue);


/* ��targetָ���ֵ��valueλ�򣬲�����targetԭ�е�ֵ  */
atomic_t _atomic_64_or(atomic_t *target,atomic_t value);

/* ��targetָ���ֵ��valueλ�룬������targetԭ�е�ֵ */
atomic_t _atomic_64_and(atomic_t *target,atomic_t value);

/* ��targetָ���ֵ����Ϊvalue��������targetԭ�е�ֵ */
atomic_t _atomic_64_set(atomic_t *target, atomic_t value);

/* ��ȡtargetָ���ֵ */
atomic_t _atomic_64_get(atomic_t *target);

/* ���targetָ���ֵ��������targetԭ�е�ֵ */
atomic_t _atomic_64_clear(atomic_t *target);

#else
/* ��targetָ���ֵ��oldValue�Աȣ������ȣ�����targetָ���ֵΪnewValue  */
BOOL _atomic_32_cas(atomic_t *target,atomic_t oldValue,atomic_t newValue);


/* ��targetָ���ֵ��valueλ�򣬲�����targetԭ�е�ֵ  */
atomic_t _atomic_32_or(atomic_t *target,atomic_t value);

/* ��targetָ���ֵ��valueλ�룬������targetԭ�е�ֵ */
atomic_t _atomic_32_and(atomic_t *target,atomic_t value);

/* ��targetָ���ֵ����Ϊvalue��������targetԭ�е�ֵ */
atomic_t _atomic_32_set(atomic_t *target, atomic_t value);

/* ��targetָ���ֵ��valueλ�룬������targetԭ�е�ֵ */
atomic_t _atomic_32_and(atomic_t *target, atomic_t value);

/* ��targetָ���ֵ��valueλ�򣬲�����targetԭ�е�ֵ */
atomic_t _atomic_32_or(atomic_t *target, atomic_t value);

/* ��targetָ���ֵ��valueλ�룬������targetԭ�е�ֵ */
atomic_t _atomic_32_and(atomic_t * target, atomic_t value);

/* ��ȡtargetָ���ֵ */
extern atomic_t _atomic_32_get(atomic_t *target);

/* ���targetָ���ֵ��������targetԭ�е�ֵ */
extern atomic_t _atomic_32_clear(atomic_t *target);

/* ���Ե�ֵַ�����������ظ�FASLE�����������һظ�TRUE */
BOOL taTas(void *address);

#endif


#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* _SDA_ATOMIC_H_ */
#endif /* CONFIG_CORE_SMP */