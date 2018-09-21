/*
* �����ʷ��
* 2014-04-13  Ҷ��    0x300��0x400��ȱҳ�쳣������hash���ĸ��²���vecλ��  
* 2013-01-15  ��Ӣ��  ���ж��쳣�������������Ӹ��������ĵı�����ָ���
* 2012-04-21  ��ѧǿ  ֧��Hash����̬���£�����0x300��0x400��ȱҳ�쳣������hash���ĸ��¡�(BUG6549)
* 2012-04-21  ��ѧǿ  ���������ϵ�ṹ����д�����ƣ�����������ء�(BUG6195)
* 2010-08-30  ������  �������ļ���
*/

/*
* @file     vector.S
* @brief
*    ���ܣ�
*    <li>ʵ�ֶ�CPU�쳣���ж�ͨ�ô�������ز����Ͷ��塣</li>
*/
#define _ASMLANGUAGE

/* ͷ�ļ� */
#include "dbAsm.h"
#include "dbVector.h"

/* ���岿�� */
/* �쳣ʱ������������� */
.macro GENERAL_EXCEPTION_SAVE_BASIC_REGISTERS 

    /* ʹ��SPRG1-2����������б���ʹ�õ��ļĴ��� */
    mtspr   SPRG1, r3 
    mtspr   SPRG2, r5 

    /*��ȡ��MMUǰʹ�õ���ʱ�쳣ջ*/
    lwi     r3,EXP_TMP_STACK_BASE
    lwz     r3, 0(r3)

    mfctr   r5
    stw     r5,CTR_OFFSET(r3)

    mflr    r5
    stw     r5,LR_OFFSET(r3)

    lwi  r5,__exception_save_basic_register  
    mtctr r5
    bctrl
    
.endm 


.macro GENERAL_EXCEPTION_JMP2ASM_HANDLER vector

    /*�����쳣��*/
    li r3,\vector
    stw r3,EXCEPTION_VECTOR_OFFSET(r1)
    
    //b mslRawGeneralExpAsmHandler
    b taRawGeneralExpAsmHandler
.endm

/* �ж�ʱ������������� */
.macro GENERAL_INTERRUPT_SAVE_BASIC_REGISTERS  

    /* ʹ��SPRG1-3�������жϲ����б���ʹ�õ��ļĴ��� */
    mtspr   SPRG1, r3
    mtspr   SPRG3, r4
    mtspr   SPRG2, r5

    lwi     r3,EXP_TMP_STACK_BASE
    lwz     r3, 0(r3)
    
    mfsrr0  r5 
    stw     r5,SRR0_OFFSET(r3)

    mfsrr1  r5 
    stw     r5,SRR1_OFFSET(r3)
    

    /* ���ں���ıȽ�ָ���Ӱ��CR�Ĵ���������Ƚ�CR�Ĵ������浽R4�� */
    mfcr r4

    /* ����MSR�Ĵ����е�[PR]λ���жϲ����жϵĵط��Ƿ����û�̬�����û�̬�����ϵͳջ���л�����ǰVM��ϵͳջ��SPRG0�� */
    mfsrr1  r3 /*�õ�MSR*/
    andi.   r3,r3,0x4000 /*�ж��Ƿ����û�̬�������ж�*/
    beq 1f

    /* �û�̬�������ж�*/
    mr r5,r1
    mfspr r1,SPRG0/*�û�̬�²����쳣����Ҫ�Ѳ����쳣�ķ�����ջ�л���ϵͳջ������ϵͳ�ѵ�ǰ������ϵͳջ������sprg0��,������Ҫ�ֶ��л��¡�*/
    b 2f

/*ϵͳ̬�������ж�*/
1:
    mr r5,r1 /*���ڶ�ջ����ͳһ�ı��淽��*/

/* ���е��˴���ջ����ϵͳջ�ˣ������жϵĳ����ջ������R5�е� */
2:
    /*���жϲ���*/
    mfsrr1 r3   
    andi. r3,r3,MSR_BIT_IR_DR_RI   /* ���ﱣ֤��Ӱ��mmu�Ŀ��� */
    ori r3,r3,MSR_BIT_FP     /* ������ж� [EE=0],[PR=0],[FP=1],[ME=0],[FE0-FE1=00] */
    
    /* �ڻָ�MMUǰ��SPRG3���г���������hash���º���ʹ��. */
    mtcr r4 /* �ָ�CR */
    mfspr r4,SPRG3
    
    mtmsr r3
    sync
    isync

    /* Ϊ����������Ԥ���ռ� */
    subi r1,r1,ISR_FRAME_SIZE + ISR_FLOAT_FRAME_SIZE

    /* ����ǰ�����ڼĴ����е�ջָ��Ĵ������浽�������� */
    stw r5,GPR1_OFFSET(r1)

    /* ����r4 */
    stw r4,GPR4_OFFSET(r1)

    /* ����CR */
    mfcr r4
    stw r4,CR_OFFSET(r1)

    lwi     r3,EXP_TMP_STACK_BASE
    lwz     r3, 0(r3)

    lwz     r4, SRR0_OFFSET(r3)
    stw     r4,SRR0_OFFSET(r1)

    lwz     r4, SRR1_OFFSET(r3)
    stw     r4,SRR1_OFFSET(r1)
    
    /* �ָ�r3 r5�Ĵ����������浽�������� */
    mfspr r3,SPRG1
    mfspr r5,SPRG2
    stw r3,GPR3_OFFSET(r1)
    stw r5,GPR5_OFFSET(r1)

.endm 


.macro GENERAL_INTERRUPT_JMP2ASM_HANDLER

    /* ��ת�����жϽ�һ�������ĳ��� */
    //b taRawGeneralIsrHandler
    b taRawGeneralIsrHandler
.endm

/*ʵ��*/

.section ".vectors","ax" 
.global _vectors_table_start
_vectors_table_start:
VECTOR_BASE:
/*
************************************************************************
*                                                                      *
*     0100:  SYSTEM RESET                                              *
*                                                                      *
************************************************************************
*/
.skip    0x0100-(.-VECTOR_BASE)
.global __reset
__reset:
    lis r3, _start@h
    ori r3, r3, _start@l
    mtlr r3
    blr


/*
************************************************************************
*                                                                      *
*     0200  Machine Check                                              *
*                                                                      *
************************************************************************
*/
.skip    0x0200-(.-VECTOR_BASE)
    GENERAL_EXCEPTION_SAVE_BASIC_REGISTERS
    GENERAL_EXCEPTION_JMP2ASM_HANDLER GENERAL_MC_INT


/*
************************************************************************
*                                                                      *
*     0300:  DATA ACCESS ERROR                                         *
*                                                                      *
************************************************************************
*/
.skip    0x0300-(.-VECTOR_BASE)

    mtspr SPRG3,r1
    lwi  r1,__mmu_stack__

    stw  r3,0(r1)
    stw  r4,4(r1)
    stw  r5,8(r1)

    stw  r9,32(r1)
    stw  r10,36(r1)
    stw  r11,40(r1)

    mflr r9
    mfctr r10
    mfcr  r11

    mfspr r3,18  /* ����r3��ֵΪDSISR��ֵ */

    /* ͨ��DSISR �ж��Ƿ��ǵ�ַת�����쳣 */
    andis.	r4,r3,0x4000
    beq           1f
    mfspr r4, 19  /* ��DAR�л�ȡȱҳ��ַ */

    lwi  r5,__hash_table_update /* ���¹�ϣ�� */
    mtctr r5
    bctrl
  
1:

    lwz   r3,0(r1)
    lwz   r4,4(r1)
    lwz   r5,8(r1)


    mtlr  r9
    mtctr r10
    mtcr  r11

    lwz   r9,32(r1)
    lwz   r10,36(r1) 
    lwz   r11,40(r1)

    mfspr r1,SPRG3

    b .DAE_CONTINUE
 
/*
************************************************************************
*                                                                      *
*    0400:  INSTRUCTION ACCESS ERROR                                   *
*                                                                      *
************************************************************************
*/
.skip    0x0400-(.-VECTOR_BASE)
    mtspr SPRG3,r1
    lwi  r1,__mmu_stack__

    stw  r3,0(r1)
    stw  r4,4(r1)
    stw  r5,8(r1)
    stw  r9,32(r1)
    stw  r10,36(r1)
    stw  r11,40(r1)

    mflr r9
    mfctr r10
    mfcr  r11


    mfsrr1  r3  /* ��ȡSRR1�Ĵ��� */

    /* �ж��Ƿ��ǵ�ַת�����쳣 */
    andis.	r4,r3,0x4000
    beq           1f
    mfsrr0  r4   /* SRR0 ȱҳ�ĵ�ַ */

    lwi  r5,__hash_table_update  /* ���¹�ϣ�� */
    mtctr r5
    bctrl
 
1:

    lwz   r3,0(r1)
    lwz   r4,4(r1)
    lwz   r5,8(r1)

    mtlr  r9
    mtctr r10
    mtcr  r11

    lwz   r9,32(r1)
    lwz   r10,36(r1) 
    lwz   r11,40(r1)

    mfspr r1,SPRG3

    b .IAE_CONTINUE

/*
************************************************************************
*                                                                      *
*   0500:  EXTERNAL INTERRUPT                                          *
*                                                                      *
************************************************************************
*/
.skip    0x0500-(.-VECTOR_BASE)
	GENERAL_INTERRUPT_SAVE_BASIC_REGISTERS
	GENERAL_INTERRUPT_JMP2ASM_HANDLER	


/*
************************************************************************
*                                                                      *
*   0600:  ALIGNMENT ERROR                                             *
*                                                                      *
************************************************************************
*/
.skip    0x0600-(.-VECTOR_BASE)
    GENERAL_EXCEPTION_SAVE_BASIC_REGISTERS
    GENERAL_EXCEPTION_JMP2ASM_HANDLER GENERAL_AE_INT

    
/*
************************************************************************
*                                                                      *
*   0700:  PROGRAM ERROR                                               *
*                                                                      *
************************************************************************
*/
.skip    0x0700-(.-VECTOR_BASE)
    GENERAL_EXCEPTION_SAVE_BASIC_REGISTERS 
    
	/*��ȡ�쳣:floating-point enabled��illegal instruction��privileged instruction��trap*/
    lwz    r3,SRR1_OFFSET(r1) 
    
    /*����16λ*/
    rlwinm  r3,r3,16,16,31
    
    b .PE_CONTINUE
 
/*
************************************************************************
**                                                                     *
** 0800:  FLOATING-POINT UNAVAILABLE                                   *
**                                                                     *
************************************************************************
*/
.skip    0x0800-(.-VECTOR_BASE)
    GENERAL_EXCEPTION_SAVE_BASIC_REGISTERS 
    GENERAL_EXCEPTION_JMP2ASM_HANDLER GENERAL_UF_INT
    

/*
************************************************************************
**                                                                     *
**   0900:  DECREMENTER INTERRUPT                                      *
**                                                                     *
************************************************************************
*/
.skip    0x0900-(.-VECTOR_BASE)
    rfi

/* 0x700�ռ䲻�㲿���ƶ����� */
.PE_CONTINUE:

#ifdef __HARD_FLOAT__
    /*�ж��Ƿ��Ǹ����쳣*/
    andi. r4,r3,0x0010
    cmpwi   r4,0x0010
    beq .FLOATING_POINT
#endif

    /*�ж��Ƿ��ǷǷ�ָ���쳣*/ 
    andi. r4,r3,0x0008
    cmpwi   r4,0x0008
    beq .ILL_INSTRUCTION_POINT
    
    /*�ж��Ƿ������ȼ��쳣*/
    andi. r4,r3,0x0004
    cmpwi   r4,0x0004
    beq .PRIVILEGE_INSTRUCTION_POINT
    
    /*�ж��Ƿ���TRAP�쳣*/
    andi. r4,r3,0x0002
    cmpwi   r4,0x0002
    beq .TRAP_POINT

#ifdef __HARD_FLOAT__
/*�����쳣����*/    
.FLOATING_POINT:

    /* ����FPSCR�Ĵ��� */
    subi r1,r1,8
    stfd f15,0(r1)
    mffs f15
    stfd f15,8+FPSCR_OFFSET(r1)
    lfd  f15,0(r1)
    addi r1,r1,8
	
    mtfsfi    cr5,0
    mtfsfi    cr3,0
    mtfsfi    cr2,0
    mtfsfi    cr1,0
    mtfsfi    cr0,0
    isync 

    GENERAL_EXCEPTION_JMP2ASM_HANDLER GENERAL_MF_INT 
#endif

/*�Ƿ�ָ���쳣����*/		
.ILL_INSTRUCTION_POINT:		
    GENERAL_EXCEPTION_JMP2ASM_HANDLER GENERAL_ILLINS_INT
    
/*��Ȩָ���쳣����*/		
.PRIVILEGE_INSTRUCTION_POINT:		
    GENERAL_EXCEPTION_JMP2ASM_HANDLER GENERAL_PRIVI_INT
    
/*TRAP�쳣����*/		
.TRAP_POINT:
    GENERAL_EXCEPTION_JMP2ASM_HANDLER GENERAL_TRAP_INT

/*
************************************************************************
**                                                                     *
**  0x0C00: System Call Interrupt                                      *
**                                                                     *
************************************************************************
*/
.skip    0x0C00-(.-VECTOR_BASE)

    /*�û�̬����ϵͳ����ʱ:
    *r0��������ϵͳ���úţ�r3-r10���ܱ���������ϵͳ����ʹ�õĲ���,����֮�ⲻ����
    *ʹ�������Ĵ�������˲���ϵͳ��ϵͳ���ô�������ֱ��ʹ��volatile�Ĵ�����
    */

    mfsrr0 r12
    
    /* ����MSR�Ĵ����е�[PR]λ���жϲ����жϵĵط��Ƿ����û�̬�����û�̬�����ϵͳջ���л�����ǰVM��ϵͳջ��SPRG0�� */
    mfsrr1  r13 /*�õ������쳣��MSR*/

    mfsrr1 r11   
    andi. r11,r11,MSR_BIT_IR_DR_RI   /*���ﱣ֤��Ӱ��mmu�Ŀ���*/
    ori r11,r11,MSR_BIT_FP     /*���￪�ж� [EE=0],[PR=0],[FP=1],[ME=0],[FE0-FE1=00],[SE=0],[BE=0] */
    mtmsr r11
	
    sync
    isync
    
 
    cmpwi  r0, 0xFFFFFFEF /* CALLLIB����ʱr0������Ϊ0xFFFFFFEF */
    bne    1f
    b .taCallibHandler

1:
    andi. r11, r13, 0x4000 /*�ж��Ƿ����û�̬�������쳣(PR)*/
    beq   .SCI_CONTINUE
    /* �����ж����������ö�Ӧ���жϷ������ */
    /*Ϊ�����ܿ��ǣ��û�̬����ϵͳ����ֱ���ɲ���ϵͳ�ӹ�*/
    li r11, GENERAL_SC_INT
   
    rotlwi  r11, r11, 2
    addis   r11, r11, _Raw_Vector_table@ha
    lwz    r11, _Raw_Vector_table@l(r11)
    mtctr  r11
    bctr

/*
************************************************************************
**                                                                     *
**  0D00:  TRACE                                                       *
**                                                                     *
************************************************************************
*/
.skip    0x0D00-(.-VECTOR_BASE)
    GENERAL_EXCEPTION_SAVE_BASIC_REGISTERS 
    GENERAL_EXCEPTION_JMP2ASM_HANDLER GENERAL_DB_INT

/*
************************************************************************
**                                                                     *
**  0E00:  RESERVED                                                    *
**                                                                     *
************************************************************************
*/
.skip    0x0E00-(.-VECTOR_BASE)
    rfi

/* 0xC00ϵͳ���ÿռ䲻�㲿���ƶ����� */
.SCI_CONTINUE:
    /*��MMU��srr0��srr1��ֵ�п��ܱ�MMU�쳣���ģ��˴���Ҫ���жϡ���MMU���ָ�srr0��srr1��ֵ */
    li r11,MSR_BIT_RI 
    mtmsr r11
    sync
    isync
	
    mtsrr0 r12
    mtsrr1 r13
    
    GENERAL_EXCEPTION_SAVE_BASIC_REGISTERS
    GENERAL_EXCEPTION_JMP2ASM_HANDLER GENERAL_ILLSC_INT
/*
************************************************************************
**                                                                     *
**  0F00:  Performance Monitor                                         *
**                                                                     *
************************************************************************
*/
.skip    0x0F00-(.-VECTOR_BASE)
    GENERAL_EXCEPTION_SAVE_BASIC_REGISTERS 
    GENERAL_EXCEPTION_JMP2ASM_HANDLER GENERAL_PM_INT


/* TLB MISS EXCEPTION */
#if defined(__PPC7450__)|| defined(__PPC8640__)
/*
************************************************************************
*                                                                      *
*  1000:  INSTRUCTION TRANSLATION MISS                                 *
*                                                                      *
************************************************************************
*/
.skip    0x01000-(.-VECTOR_BASE)
    GENERAL_EXCEPTION_SAVE_BASIC_REGISTERS 
    GENERAL_EXCEPTION_JMP2ASM_HANDLER GENERAL_ITM_INT

/*
************************************************************************
**                                                                     *
**  1100:  DATA LOAD TRANSLATION MISS                                  *
**                                                                     *
************************************************************************
*/
.skip    0x1100-(.-VECTOR_BASE)
    GENERAL_EXCEPTION_SAVE_BASIC_REGISTERS 
    GENERAL_EXCEPTION_JMP2ASM_HANDLER GENERAL_DLTM_INT
    

/*
************************************************************************
**                                                                     *
**  1200:  DATA STORE TRANSLATION MISS                                 *
**                                                                     *
************************************************************************
*/
.skip    0x1200-(.-VECTOR_BASE)
    GENERAL_EXCEPTION_SAVE_BASIC_REGISTERS 
    GENERAL_EXCEPTION_JMP2ASM_HANDLER GENERAL_DSTM_INT
    

#endif /* defined(__PPC7450__)|| defined(__PPC8640__) */
/*
************************************************************************
**                                                                     *
**  1300:  INSTRUCTION ADDRESS BREAKPOINT                              *
**                                                                     *
************************************************************************
*/
.skip    0x1300-(.-VECTOR_BASE)
    GENERAL_EXCEPTION_SAVE_BASIC_REGISTERS 
    GENERAL_EXCEPTION_JMP2ASM_HANDLER GENERAL_IAB_INT

/*
************************************************************************
**                                                                     *
**  1400:  SYSTEM MANAGEMENT INTERRUPT                                 *
**                                                                     *
************************************************************************
*/
.skip    0x1400-(.-VECTOR_BASE)
    GENERAL_EXCEPTION_SAVE_BASIC_REGISTERS 
    GENERAL_EXCEPTION_JMP2ASM_HANDLER GENERAL_SM_INT


#if defined(__PPC750__)
/*
************************************************************************
**                                                                     *
**  1700:  THERMAL MANAGEMENT INTERRUPT                                *
**                                                                     *
************************************************************************
*/
.skip    0x1700-(.-VECTOR_BASE)
    GENERAL_EXCEPTION_SAVE_BASIC_REGISTERS 
    GENERAL_EXCEPTION_JMP2ASM_HANDLER GENERAL_TH_INT

#endif /* __PPC750__ */
/*
************************************************************************
**                                                                     *
**  1800:  Exception ASM Handler                                       *
**                                                                     *
************************************************************************
*/
.skip    0x1800-(.-VECTOR_BASE)
__exception_save_basic_register:
    
    /* ��SRR0��SRR1��CR��DAR��DSISR���浽��ʱջ*/
    mfsrr0  r5 
    stw     r5,SRR0_OFFSET(r3)

    mfsrr1  r5 
    stw     r5,SRR1_OFFSET(r3)

    mfcr    r5 /*����cr,���²�����Ӱ�쵽cr*/
    stw     r5,CR_OFFSET(r3)

    mfspr   r5,DAR
    stw     r5,DAR_OFFSET(r3)

    mfspr   r5,DSISR
    stw     r5,DSISR_OFFSET(r3)

    /* ����MSR�Ĵ����е�[PR]λ���жϲ����жϵĵط��Ƿ����û�̬�����û�̬�����ϵͳջ���л�����ǰ������ϵͳջ��SPRG0�� */
    mfsrr1  r3 /*�õ������쳣��MSR*/
    andi.   r3,r3,0x4000 /*�ж��Ƿ����û�̬�������쳣(PR)*/
    beq 1f
    
    /* �û�̬*/
    mr r5,r1
    mfspr r1, SPRG0 /*�û�̬�²����쳣����Ҫ�Ѳ����쳣�ķ�����ջ�л���ϵͳջ������ϵͳ�ѵ�ǰ������ϵͳջ������SPRG0��,������Ҫ�ֶ��л��¡�*/
    b 4f

1:  /*ϵͳ̬*/
    
     
    li	r5, 0
    addis	r3, 0, exceptionTwiceFlag@ha
    stw	r5, exceptionTwiceFlag@l(r3)
    
    lis r5, taExceptionStackTop@ha
    lwz r5, taExceptionStackTop@l(r5) /* ��ȡta�쳣ջ����ַ*/
    cmpw r1, r5 /* �жϵ�ǰջ��ַ�Ƿ����MSL�쳣ջ */
    bgt 2f
    lis r5, taExceptionStackBottom@ha
    lwz r5, taExceptionStackBottom@l(r5) /* ��ȡta�쳣ջ�׵�ַ*/
    cmpw r1, r5 /* �жϵ�ǰջ�Ƿ��Ƿ����MSL�쳣ջ  */
    blt 2f

    /* �쳣�����Ѿ���ta�쳣ջ��*/
    /* ��ʶ��ta�쳣ջ����ʱ�����˶����쳣*/
    li	r5, 1
    stw	r5, exceptionTwiceFlag@l(r3)

    /* �Ƿ����ж�ta �쳣ջ�����㹻��ʣ��ռ�*/
    lis r5, taExceptionStackBottom@ha
    lwz r5, taExceptionStackBottom@l(r5) /* ��ȡta�쳣ջ�׵�ַ*/
    addi r3,r5,MINIMUM_EXCHANDLE_STACK_SIZE+EXCEPTION_FRAME_SIZE
    cmpw r1, r3 /* �жϵ�ǰta�쳣ջ�Ƿ����㹻�ռ䱣���쳣*/
    bge 3f

2:
    /* 
      * ��ǰta �쳣ջ��û���㹻ʣ��ռ����
      * ��������̬ʱ�������쳣����ֱ�ӽ�ջ
      * ����Ϊta�쳣ջ��
      */
    mr r5, r1 /*���ڶ�ջ����ͳһ�ı��淽�� */
    lis r3, taExceptionStackTop@ha
    lwz r3, taExceptionStackTop@l(r3) /* ֱ�ӽ�ջ����Ϊta�쳣ջ��*/
    mr r1, r3
    b 4f

3:
    mr r5, r1

4:
    /*���жϲ���*/
    mfsrr1 r3   
    andi. r3,r3,MSR_BIT_IR_DR_RI   /*���ﱣ֤��Ӱ��mmu�Ŀ���*/
    ori r3,r3,MSR_BIT_FP     /*������ж� [EE=0],[PR=0],[FP=1],[ME=0],[FE0-FE1=00] */ 
    mtmsr r3
    sync
    isync

    /* Ϊ�쳣����������Ԥ���ռ� */
    subi r1,r1,EXCEPTION_FRAME_SIZE

    stw r4,GPR4_OFFSET(r1)
    
    /*����SRR0��SRR1��CR��CTR��LR��DAR��DSISR��R1 */
    lwi     r3,EXP_TMP_STACK_BASE
    lwz     r3, 0(r3)

    lwz     r4, SRR0_OFFSET(r3)
    stw     r4,SRR0_OFFSET(r1)

    lwz     r4, SRR1_OFFSET(r3)
    stw     r4,SRR1_OFFSET(r1)

    lwz     r4, CR_OFFSET(r3)
    stw     r4,CR_OFFSET(r1)

    lwz     r4, CTR_OFFSET(r3)
    stw     r4,CTR_OFFSET(r1)   

    lwz     r4, LR_OFFSET(r3)
    stw     r4,LR_OFFSET(r1)
        
    lwz     r4, DAR_OFFSET(r3)
    stw     r4,DAR_OFFSET(r1)
        
    lwz     r4, DSISR_OFFSET(r3)
    stw     r4,DSISR_OFFSET(r1)

    stw     r5,GPR1_OFFSET(r1)

    /*�ָ�r3��r5*/
    mfspr r3,SPRG1
    mfspr r5,SPRG2
    
    /*����r3,r5*/
    stw r3,GPR3_OFFSET(r1)
    stw r5,GPR5_OFFSET(r1)
    blr
    
taRawGeneralExpAsmHandler:

    /*����r0,r2,r6-r31*/
    stw r0,GPR0_OFFSET(r1)
    stw r2,GPR2_OFFSET(r1)

    stw r6,GPR6_OFFSET(r1)
    stw r7,GPR7_OFFSET(r1)
    stw r8,GPR8_OFFSET(r1)
    stw r9,GPR9_OFFSET(r1)
    stw r10,GPR10_OFFSET(r1)
    stw r11,GPR11_OFFSET(r1)
    stw r12,GPR12_OFFSET(r1)
    stw r13,GPR13_OFFSET(r1)
    stw r14,GPR14_OFFSET(r1)
    stw r15,GPR15_OFFSET(r1)
    stw r16,GPR16_OFFSET(r1)
    stw r17,GPR17_OFFSET(r1)
    stw r18,GPR18_OFFSET(r1)
    stw r19,GPR19_OFFSET(r1)
    stw r20,GPR20_OFFSET(r1)
    stw r21,GPR21_OFFSET(r1)
    stw r22,GPR22_OFFSET(r1)
    stw r23,GPR23_OFFSET(r1)
    stw r24,GPR24_OFFSET(r1)
    stw r25,GPR25_OFFSET(r1)
    stw r26,GPR26_OFFSET(r1)
    stw r27,GPR27_OFFSET(r1)
    stw r28,GPR28_OFFSET(r1)
    stw r29,GPR29_OFFSET(r1)
    stw r30,GPR30_OFFSET(r1)
    stw r31,GPR31_OFFSET(r1)
    
    /*����xer*/
    mfxer   r5
    stw r5,XER_OFFSET(r1)
    
    /*�ָ��쳣������*/
    lwz r3,EXCEPTION_VECTOR_OFFSET(r1)    
    
    /* �����쳣���������ö�Ӧ���쳣������� */
    addis    r6, 0, _Raw_Vector_table@ha
    rotlwi  r5, r3,2
    add     r6,r6,r5
    lwz    r7, _Raw_Vector_table@l(r6)
    mtctr  r7
    
    mr r3, r1
    lis r4, exceptionTwiceFlag@ha
    lwz r4, exceptionTwiceFlag@l(r4)
    /*����û��r1 ��8������Ҫ��������ȫ���Ի������д��ͨ����c�������û��Զ���lr���浽r1 ��8��λ�ã��Լ�д�Ļ��һ�㲻�ᱣ��lr��r1 ��8*/
    bctrl

    /* �ָ������Ĳ����� */
    lwz r3,CTR_OFFSET(r1)
    lwz r4,LR_OFFSET(r1)
    lwz r5,XER_OFFSET(r1)

    mtctr   r3
    mtlr    r4
    mtxer   r5

    lwz r0,GPR0_OFFSET(r1)
    lwz r2,GPR2_OFFSET(r1)
    lwz r5,GPR5_OFFSET(r1)
    lwz r6,GPR6_OFFSET(r1)
    lwz r7,GPR7_OFFSET(r1)
    lwz r8,GPR8_OFFSET(r1)
    lwz r9,GPR9_OFFSET(r1)
    lwz r10,GPR10_OFFSET(r1)
    lwz r11,GPR11_OFFSET(r1)
    lwz r12,GPR12_OFFSET(r1)
    lwz r13,GPR13_OFFSET(r1)
    lwz r14,GPR14_OFFSET(r1)
    lwz r15,GPR15_OFFSET(r1)
    lwz r16,GPR16_OFFSET(r1)
    lwz r17,GPR17_OFFSET(r1)
    lwz r18,GPR18_OFFSET(r1)
    lwz r19,GPR19_OFFSET(r1)
    lwz r20,GPR20_OFFSET(r1)
    lwz r21,GPR21_OFFSET(r1)
    lwz r22,GPR22_OFFSET(r1)
    lwz r23,GPR23_OFFSET(r1)
    lwz r24,GPR24_OFFSET(r1)
    lwz r25,GPR25_OFFSET(r1)
    lwz r26,GPR26_OFFSET(r1)
    lwz r27,GPR27_OFFSET(r1)
    lwz r28,GPR28_OFFSET(r1)
    lwz r29,GPR29_OFFSET(r1)
    lwz r30,GPR30_OFFSET(r1)
    lwz r31,GPR31_OFFSET(r1)

    /* ����Ĳ�����Ҫ���жϽ��� */
    mfmsr r3   
    andi. r3,r3,MSR_BIT_IR_DR_RI   /*���ﱣ֤��Ӱ��mmu�Ŀ���*/
    ori r3,r3,MSR_BIT_FP     /*������ж� [EE=0],[PR=0],[FP=1],[ME=0],[FE0-FE1=00] */ 
    mtmsr r3
    sync
    isync

    lwz r3,CR_OFFSET(r1) 
    mtcr    r3

    lwz     r3, GPR3_OFFSET(r1)
    mtspr   SPRG1, r3

    lwz     r4, GPR4_OFFSET(r1)
    mtspr   SPRG2, r4
    
    /*��ȡrfi����ʱ����srr0,srr1ʹ�õ�ջ*/
    lwi      r3,EXP_TMP_STACK_BASE
    lwz     r3, 0(r3)
    
    lwz     r4, SRR0_OFFSET(r1)
    stw     r4,SRR0_OFFSET(r3)

    lwz     r4, SRR1_OFFSET(r1)
    stw     r4,SRR1_OFFSET(r3)

    lwz     r1, GPR1_OFFSET(r1)

    /*������srr0,srr1ǰ����Ҫ���жϡ���MMU���� */
    li      r4,MSR_BIT_RI
    mtmsr   r4
    sync
    isync	
        
    lwz     r4, SRR0_OFFSET(r3)
    mtsrr0  r4

    lwz     r4, SRR1_OFFSET(r3)
    mtsrr1  r4    
    
    mfspr   r3,SPRG1
    mfspr   r4,SPRG2

    sync
    isync
    rfi

/*
************************************************************************
**                                                                     *
**  ISR ASM Handler                                       *
**                                                                     *
************************************************************************
*/
taRawGeneralIsrHandler:

 /* ����ʣ��ļĴ���  */
    stw r0,GPR0_OFFSET(r1)
    stw r2,GPR2_OFFSET(r1)
    stw r6,GPR6_OFFSET(r1)
    stw r7,GPR7_OFFSET(r1)
    stw r8,GPR8_OFFSET(r1)
    stw r9,GPR9_OFFSET(r1)
    stw r10,GPR10_OFFSET(r1)
    stw r11,GPR11_OFFSET(r1)
    stw r12,GPR12_OFFSET(r1)
    stw r13,GPR13_OFFSET(r1)
    mfctr   r3
    mflr    r4
    mfxer   r5
    stw r3,CTR_OFFSET(r1)
    stw r4,LR_OFFSET(r1)
    stw r5,XER_OFFSET(r1)

    /* ���渡��Ĵ��� f0 - f31*/
    stfd f0, (ISR_FRAME_SIZE + FP_0)(r1)
    stfd f1, (ISR_FRAME_SIZE + FP_1)(r1)
    stfd f2, (ISR_FRAME_SIZE + FP_2)(r1)
    stfd f3, (ISR_FRAME_SIZE + FP_3)(r1)
    stfd f4, (ISR_FRAME_SIZE + FP_4)(r1)
    stfd f5, (ISR_FRAME_SIZE + FP_5)(r1)
    stfd f6, (ISR_FRAME_SIZE + FP_6)(r1)
    stfd f7, (ISR_FRAME_SIZE + FP_7)(r1)
    stfd f8, (ISR_FRAME_SIZE + FP_8)(r1)
    stfd f9, (ISR_FRAME_SIZE + FP_9)(r1)
    stfd f10, (ISR_FRAME_SIZE + FP_10)(r1)
    stfd f11, (ISR_FRAME_SIZE + FP_11)(r1)
    stfd f12, (ISR_FRAME_SIZE + FP_12)(r1)
    stfd f13, (ISR_FRAME_SIZE + FP_13)(r1)
    stfd f14, (ISR_FRAME_SIZE + FP_14)(r1)
    stfd f15, (ISR_FRAME_SIZE + FP_15)(r1)
    stfd f16, (ISR_FRAME_SIZE + FP_16)(r1)
    stfd f17, (ISR_FRAME_SIZE + FP_17)(r1)
    stfd f18, (ISR_FRAME_SIZE + FP_18)(r1)
    stfd f19, (ISR_FRAME_SIZE + FP_19)(r1)
    stfd f20, (ISR_FRAME_SIZE + FP_20)(r1)
    stfd f21, (ISR_FRAME_SIZE + FP_21)(r1)
    stfd f22, (ISR_FRAME_SIZE + FP_22)(r1)
    stfd f23, (ISR_FRAME_SIZE + FP_23)(r1)
    stfd f24, (ISR_FRAME_SIZE + FP_24)(r1)
    stfd f25, (ISR_FRAME_SIZE + FP_25)(r1)
    stfd f26, (ISR_FRAME_SIZE + FP_26)(r1)
    stfd f27, (ISR_FRAME_SIZE + FP_27)(r1)
    stfd f28, (ISR_FRAME_SIZE + FP_28)(r1)
    stfd f29, (ISR_FRAME_SIZE + FP_29)(r1)
    stfd f30, (ISR_FRAME_SIZE + FP_30)(r1)
    stfd f31, (ISR_FRAME_SIZE + FP_31)(r1)

    /* ����FPSCR */
    mffs   f0
    stfd   f0, (ISR_FRAME_SIZE + FP_FPSCR)(r1)

    isync
    sync
    
    /*��ȡ������жϺš������ж��豸�Ĳ�ͬ����ȡ�жϴ�����ڶ�Ӧ�İ弶Ŀ¼��*/  
    subi r1,r1,8
    bl getVectorNum
    addi r1,r1,8
    
    cmpwi r3,0xff
    beq .isr_exit
    
    /*�жϺż����쳣���λ�����������У��쳣�����ж�ǰ�棩*/
    addi r3,r3,GENERAL_STD_IRQ_LAST   
    
    /*�����жϺ�*/
    stw r3,ISR_VECTOR_OFFSET(r1)
    
    /* �����ж����������ö�Ӧ���жϷ������ */
    /*��Ҫ���жϴ��������У����ʵ�ʱ���������жϺ���Ӧ�жϵĲ���*/
    addis    r6, 0, _Raw_Vector_table@ha
    rotlwi  r5, r3, 2
    add     r6,r6, r5
    lwz    r7, _Raw_Vector_table@l(r6)
    mtctr  r7
    
    /*����û��r1-8������Ҫ��������ȫ���Ի������д��ͨ����c�������û��Զ���lr���浽r1-8��λ�ã��Լ�д�Ļ��һ�㲻�ᱣ��lr��r1-8*/
    bctrl
       
.isr_exit:

    lwz r3,CTR_OFFSET(r1)
    lwz r4,LR_OFFSET(r1)
    lwz r5,XER_OFFSET(r1)

    mtctr   r3
    mtlr    r4
    mtxer   r5

    lwz r0,GPR0_OFFSET(r1)
    lwz r2,GPR2_OFFSET(r1)
    lwz r5,GPR5_OFFSET(r1)
    lwz r6,GPR6_OFFSET(r1)
    lwz r7,GPR7_OFFSET(r1)
    lwz r8,GPR8_OFFSET(r1)
    lwz r9,GPR9_OFFSET(r1)
    lwz r10,GPR10_OFFSET(r1)
    lwz r11,GPR11_OFFSET(r1)
    lwz r12,GPR12_OFFSET(r1)
    lwz r13,GPR13_OFFSET(r1)

    /* ����Ĳ�����Ҫ���жϽ��� */
    mfmsr r3
    andi. r3,r3,MSR_BIT_IR_DR_RI   /*���ﱣ֤��Ӱ��mmu�Ŀ���*/
    ori r3,r3,MSR_BIT_FP     /*������ж� [EE=0],[PR=0],[FP=1],[ME=0],[FE0-FE1=00] */
    mtmsr r3
    sync
    isync

    /*�ָ�FPSCR */
    lfd    f0,(ISR_FRAME_SIZE + FP_FPSCR)(r1)
    mtfsf   0xff, f0

    /*  �ָ�����Ĵ���f0-f31 */
    lfd   f0,(ISR_FRAME_SIZE + FP_0)(r1) 
    lfd   f1,(ISR_FRAME_SIZE + FP_1)(r1)
    lfd   f2,(ISR_FRAME_SIZE + FP_2)(r1)
    lfd   f3,(ISR_FRAME_SIZE + FP_3)(r1)
    lfd   f4,(ISR_FRAME_SIZE + FP_4)(r1)
    lfd   f5,(ISR_FRAME_SIZE + FP_5)(r1)
    lfd   f6,(ISR_FRAME_SIZE + FP_6)(r1)
    lfd   f7,(ISR_FRAME_SIZE + FP_7)(r1)
    lfd   f8,(ISR_FRAME_SIZE + FP_8)(r1)
    lfd   f9,(ISR_FRAME_SIZE + FP_9)(r1)
    lfd   f10,(ISR_FRAME_SIZE + FP_10)(r1)
    lfd   f11,(ISR_FRAME_SIZE + FP_11)(r1)
    lfd   f12,(ISR_FRAME_SIZE + FP_12)(r1)
    lfd   f13,(ISR_FRAME_SIZE + FP_13)(r1)
    lfd   f14,(ISR_FRAME_SIZE + FP_14)(r1)
    lfd   f15,(ISR_FRAME_SIZE + FP_15)(r1)
    lfd   f16,(ISR_FRAME_SIZE + FP_16)(r1)
    lfd   f17,(ISR_FRAME_SIZE + FP_17)(r1)
    lfd   f18,(ISR_FRAME_SIZE + FP_18)(r1)
    lfd   f19,(ISR_FRAME_SIZE + FP_19)(r1)
    lfd   f20,(ISR_FRAME_SIZE + FP_20)(r1)
    lfd   f21,(ISR_FRAME_SIZE + FP_21)(r1)
    lfd   f22,(ISR_FRAME_SIZE + FP_22)(r1)
    lfd   f23,(ISR_FRAME_SIZE + FP_23)(r1)
    lfd   f24,(ISR_FRAME_SIZE + FP_24)(r1)
    lfd   f25,(ISR_FRAME_SIZE + FP_25)(r1)
    lfd   f26,(ISR_FRAME_SIZE + FP_26)(r1)
    lfd   f27,(ISR_FRAME_SIZE + FP_27)(r1)
    lfd   f28,(ISR_FRAME_SIZE + FP_28)(r1)
    lfd   f29,(ISR_FRAME_SIZE + FP_29)(r1)
    lfd   f30,(ISR_FRAME_SIZE + FP_30)(r1)
    lfd   f31,(ISR_FRAME_SIZE + FP_31)(r1)

    isync
    sync
    
    lwz r3,CR_OFFSET(r1) 
    mtcr    r3
    
    lwz     r3, GPR3_OFFSET(r1)
    mtspr   SPRG1, r3

    lwz     r4, GPR4_OFFSET(r1)
    mtspr   SPRG2, r4

    /*��ȡrfi����ʱ����srr0,srr1ʹ�õ�ջ*/
    lwi      r3,EXP_TMP_STACK_BASE
    lwz     r3, 0(r3)
    
    lwz     r4, SRR0_OFFSET(r1)
    stw     r4,SRR0_OFFSET(r3)

    lwz     r4, SRR1_OFFSET(r1)
    stw     r4,SRR1_OFFSET(r3)

    lwz     r1, GPR1_OFFSET(r1)

    /*������srr0,srr1ǰ����Ҫ���жϡ���MMU���� */
    li      r4,MSR_BIT_RI
    mtmsr   r4
    sync
    isync
       
    lwz     r4, SRR0_OFFSET(r3)
    mtsrr0  r4

    lwz     r4, SRR1_OFFSET(r3)
    mtsrr1  r4    
    
    mfspr   r3,SPRG1
    mfspr   r4,SPRG2

    sync
    isync
    rfi
        
.p2align 4
.local .taCallibHandler
.taCallibHandler:

    cmpw r0, r3
    beq 2f
	
    /* ���浱ǰջ���л���ϵͳջ */
    mr r10, r1
	
    andi.   r11, r13, 0x4000 /*�ж��Ƿ����û�̬�������쳣(PR)*/
    beq 1f
	
    /* �л���ϵͳջ */
    mfspr r1, SPRG0

1: 
    subi r1, r1, 0x10
    stw r12, 0(r1)
    stw r13, 4(r1)
    mflr r11
    stw  r11, 8(r1)
    stw  r10, 0xC(r1)
    li	r12, GENERAL_CALLLIB_INT
    addis    r11, 0, _Raw_Vector_table@ha
    rotlwi  r12, r12, 2
    add     r11,r11, r12
    lwz    r11, _Raw_Vector_table@l(r11)
    mtctr  r11
    bctrl
    
    lwz r12, 0(r1)
    lwz r13, 4(r1)
    lwz r11, 8(r1)
    mtlr r11
    lwz r1, 0xC(r1)
    
    
    /* ���жϡ���MMU���� */
    li r11,MSR_BIT_RI 
    mtmsr r11
    sync
    isync
	
    mtsrr0 r12
    mtsrr1 r13

    sync
    isync
    rfi

2:
    /*��MMU��srr0��srr1��ֵ�п��ܱ�MMU�쳣���ģ��˴���Ҫ���жϡ���MMU���ָ�srr0��srr1��ֵ */
    li r11,MSR_BIT_RI 
    mtmsr r11
    sync
    isync
	
    mtsrr0 r12
    mtsrr1 r13
    
    GENERAL_EXCEPTION_SAVE_BASIC_REGISTERS 
    GENERAL_EXCEPTION_JMP2ASM_HANDLER GENERAL_CALLLIB_ERROR_INT


/*
************************************************************************
**                                                                     *
**  .DAE_CONTINUE   .IAE_CONTINUE                     *
**                                                                     *
************************************************************************
*/
/* 0x300�ռ䲻�㲿���ƶ����� */
.DAE_CONTINUE:

    GENERAL_EXCEPTION_SAVE_BASIC_REGISTERS

    lwz     r3, DSISR_OFFSET(r1)
    
    /*ɢ�п� ҳ�쳣�Ͷϵ��쳣*/
    rlwinm  r3,r3,16,16,31 /*����16λ*/
    andi. r3,r3,0x4840

    /*�ж��Ƿ��ǵ�ַû��ӳ���쳣*/ 
    cmpwi   r3,0x4000
    beq .DPAGE_FAULT
    
    /*�ж��Ƿ���ҳ�����쳣*/ 
    cmpwi   r3,0x0800
    beq .DPAGE_FAULT
    
    /*�ж��Ƿ��Ƕϵ��쳣*/
    cmpwi   r3,0x0040
    beq .BREAK_FAULT
    
    GENERAL_EXCEPTION_JMP2ASM_HANDLER GENERAL_DAE_INT
    
.DPAGE_FAULT:
    GENERAL_EXCEPTION_JMP2ASM_HANDLER GENERAL_PAGE_INT
    
.BREAK_FAULT:
    GENERAL_EXCEPTION_JMP2ASM_HANDLER GENERAL_HBP_INT

/* 0x400�ռ䲻�㲿���ƶ����� */
.IAE_CONTINUE:

    GENERAL_EXCEPTION_SAVE_BASIC_REGISTERS

    lwz     r3, SRR1_OFFSET(r1)
    rlwinm  r3,r3,16,16,31 /*����16λ*/
    andi. r3,r3,0x4800
    cmpwi   r3,0x4000
    beq .IPAGE_FAULT
    cmpwi   r3,0x800
    beq .IPAGE_FAULT
    
    GENERAL_EXCEPTION_JMP2ASM_HANDLER GENERAL_IAE_INT
    
.IPAGE_FAULT:
    GENERAL_EXCEPTION_JMP2ASM_HANDLER GENERAL_IPAGE_INT 

/*
************************************************************************
**                                                                     *
**  ���¹�ϣ��                                           *
**                                                                     *
************************************************************************
*/

/*  ����δ����������λ���Ǳ��ڽ�Լ�ռ� */

/* r4 �����������Ч��ַ */

__hash_table_update:

    stw  r6,12(r1)
    stw  r7,16(r1)
    stw  r8,20(r1)
    stw  r0,24(r1)
    stw  r2,28(r1)

    rlwinm	r3,r4,12,20,29  /* �õ��õ�ַ��ҳĿ¼ƫ�� */

    addis r5,0,mmPageDirBase@ha  /* �õ�ҳĿ¼����ַ */
    lwz   r5,mmPageDirBase@l(r5)

    cmpwi r5,0
    beq   1f

    rlwinm	r6,r5,0,0,19 /* �õ�ҳĿ¼��Ļ�ַ */

    add r3,r3,r6   /* �õ�ҳĿ¼��ĵ�ַ */

    lwz  r3,0(r3) /* �õ�ҳĿ¼������� */
    cmpwi r3,0  /* �жϸ�ҳĿ¼���Ƿ���Ч����Ч�������� */
    beq   1f

    rlwinm	r3,r3,0,0,19 /* �õ�ҳ���Ļ�ַ */
    rlwinm	r6,r4,22,20,29 /* �õ�ҳ�����ƫ�� */
    add           r3,r3,r6   /* �õ���Ӧ��ҳ�����ַ */

    lwz  r6,0(r3)  /* �õ�ҳ��������� */
    mr   r3,r6
    rlwinm	r3,r3,25,31,31  /* �õ�����λ��PPC�����changeλ��*/

    cmpwi r3,0  /* �жϸ�ҳ�����Ƿ���Ч����Ч������ */

    beq   1f

    rlwinm	r6,r6,0,25,22 /* ���R��Cλ R6 = PETL */

    rlwinm	r3,r4,4,28,31 /* SRn  */
    slwi       r5,r3,28
    mfsrin	r5,r5  /* SR��ֵ */
    rlwinm     r5,r5, 0,8,31  /*����״̬λ,ֻ��VSID*/

    /* �õ�PTEU */
    mr r2,r4
    mr r8,r5


    rlwinm	r2,r2,10,26,31  /*��ȡ��Ч��ַ��API ��PTEU[26-31]*/
    rlwinm	r8,r8,7,0,24     /*��ȡVSID ��PTEU[1-24]*/
    oris	r2,r2,32768      /*����PTEU Ϊ��Ч��PTEU[0]*/
    or	r2,r8,r2    /*������hash������(PTEG)�ĵ�һ��hash�����PTEU */


    /*��ȡ��PTEG�ĵ�һ��hash����PTEL*/
    mfspr  r3,25  /* ��ȡHASH���Ļ���ַ */

    rlwinm	r6,r6,0,25,22  /* ���C��Rλ */


    /* r3=sdr,r4=ea,r5=sr  : ����Hash��Primary PTEG����� */
    rlwinm	r4,r4,20,16,31   /*��ȡea[4-19]*/
    clrlwi	r5,r5,13    /*��ȡVSID[5-23]*/
    xor		r4,r4,r5   /*ea[4-19]���VSID[5-23]����19λ����PTEG��hashֵ1*/
    rlwinm	r7,r3,0,7,15    /*��ȡhash����ַ��7-15λ��SDR1[7-15]*/
    rlwinm	r8,r4,22,10,31  /*��ȡhashֵ1��0-8λ*/
    and		r8,r8,r3  /*SDR1[HTABMASK]����& hashֵ1��0-8λ����PTEG[7-15]a*/
    rlwinm	r4,r4,6,16,25  /*��ȡhashֵ1��9-18λ������6λ����PTEG[16-25]*/
    rlwinm	r8,r8,16,0,15  /*PTEG[7-15]a ����16λ����PTEG[7-15]b*/
    rlwinm	r3,r3,0,0,6 /*��ȡhash����ַ��0-6��PTEG[0-6]*/
    or		r8,r8,r7    /*PTEG[7-15]b | SDR1[7-15]����PTEG[7-15]*/

    /*PTEG�ĵ�ַ= PTEG[0-6]|PTEG[7-15]|PTEG[16-25]|000000b*/
    add		r3,r3,r8
    or		r3,r3,r4

    /* ����Hash�� */
    stw   r2,0(r3)
    stw   r6,4(r3)

    lwi   r4,0xA7FFFFFF
    mfsrr1 r3
    and.  r3,r4,r3
    mtsrr1 r3

    lwz   r3,0(r1)
    lwz   r4,4(r1)
    lwz   r5,8(r1)
    lwz   r6,12(r1)
    lwz   r7,16(r1)
    lwz   r8,20(r1)
    lwz   r0,24(r1)
    lwz   r2,28(r1)

    mtlr  r9
    mtctr r10
    mtcr  r11

    lwz   r9,32(r1)
    lwz   r10,36(r1)
    lwz   r11,40(r1)

    mfspr r1,SPRG3

    isync
    sync
    rfi

1:
    lwz   r6,12(r1)
    lwz   r7,16(r1)
    lwz   r8,20(r1)
    lwz   r0,24(r1)
    lwz   r2,28(r1)

    blr /* �ص����ó��� */

.skip   0x04000-(.-VECTOR_BASE)

_vectors_table_end:
