/*
* �����ʷ��
* 2010-08-30  ������  �������ļ���
*/

/*
* @file  archLib.S
* @brief
*       ���ܣ�
*       <li> �ṩCPU�Ĵ���������</li>
*/

#define _ASMLANGUAGE
#include <dbAsm.h>

/*
* @brief
*       ����SDR1�Ĵ���������Ϊsdr��
* @param[in]  sdr: Ҫ���õ�SDR1�Ĵ�������
* @return
*       none
* @implements  DM.1.2.73,DM.1.3.73,DM.1.4.73
*/ 
PUBLIC(_msl_arch_set_sdr1)
SYM (_msl_arch_set_sdr1):
	mtspr 25,r3
	blr

/*
* @brief
*       ����DBAT0L�Ĵ���Ϊbatl������DBAT0U�Ĵ���Ϊbatu��
* @param[in]  batl: Ҫ���õ�DBAT0L�Ĵ�������
* @param[in]  batu: Ҫ���õ�DBAT0U�Ĵ�������
* @return
*       none
* @implements  DM.1.2.57,DM.1.3.57,DM.1.4.57
*/
PUBLIC(_msl_arch_set_dbat0)
SYM (_msl_arch_set_dbat0):
	mtdbatl 0,3
	mtdbatu 0,4
	blr

/*
* @brief
*       ����DBAT1L�Ĵ���Ϊbatl������DBAT1U�Ĵ���Ϊbatu��
* @param[in]  batl: Ҫ���õ�DBAT1L�Ĵ�������
* @param[in]  batu: Ҫ���õ�DBAT1U�Ĵ�������
* @return
*      none
* @implements  DM.1.2.58,DM.1.3.58,DM.1.4.58
*/
PUBLIC(_msl_arch_set_dbat1)
SYM (_msl_arch_set_dbat1):
	mtdbatl 1,3
	mtdbatu 1,4
	blr

/*
* @brief
*       ����DBAT2L�Ĵ���Ϊbatl������DBAT2U�Ĵ���Ϊbatu��
* @param[in]  batl: Ҫ���õ�DBAT2L�Ĵ�������
* @param[in]  batu: Ҫ���õ�DBAT2U�Ĵ�������
* @return
*       none
* @implements  DM.1.2.59,DM.1.3.59,DM.1.4.59
*/
PUBLIC(_msl_arch_set_dbat2)
SYM (_msl_arch_set_dbat2):
	mtdbatl 2,3
	mtdbatu 2,4
	blr

/*
* @brief
*       ����DBAT3L�Ĵ���Ϊbatl������DBAT3U�Ĵ���Ϊbatu��
* @param[in]  batl: Ҫ���õ�DBAT3L�Ĵ�������
* @param[in]  batu: Ҫ���õ�DBAT3U�Ĵ�������
* @return
*       none
* @implements  DM.1.2.60,DM.1.3.60,DM.1.4.60
*/
PUBLIC(_msl_arch_set_dbat3) 
SYM (_msl_arch_set_dbat3):
	mtdbatl 3,3
	mtdbatu 3,4
	blr

/*
* @brief
*       ����IBAT0L�Ĵ���Ϊbatl������IBAT0U�Ĵ���Ϊbatu��
* @param[in]  batl: Ҫ���õ�IBAT0L�Ĵ�������
* @param[in]  batu: Ҫ���õ�IBAT0U�Ĵ�������
* @return
*       none
* @implements  DM.1.2.65,DM.1.3.65,DM.1.4.65
*/
PUBLIC(_msl_arch_set_ibat0)
SYM (_msl_arch_set_ibat0):
	mtibatl 0,3
	mtibatu 0,4
	blr
    
/*
* @brief
*       ����IBAT1L�Ĵ���Ϊbatl������IBAT1U�Ĵ���Ϊbatu��
* @param[in]  batl: Ҫ���õ�IBAT1L�Ĵ�������
* @param[in]  batu: Ҫ���õ�IBAT1U�Ĵ�������
* @return
*      none
* @implements  DM.1.2.66,DM.1.3.66,DM.1.4.66
*/
PUBLIC(_msl_arch_set_ibat1)
SYM (_msl_arch_set_ibat1):
	mtibatl 1,3
	mtibatu 1,4
	blr

/*
* @brief
*       ����IBAT2L�Ĵ���Ϊbatl������IBAT2U�Ĵ���Ϊbatu��
* @param[in]  batl: Ҫ���õ�IBAT2L�Ĵ�������
* @param[in]  batu: Ҫ���õ�IBAT2U�Ĵ�������
* @return
*       none
* @implements  DM.1.2.67,DM.1.3.67,DM.1.4.67
*/
PUBLIC(_msl_arch_set_ibat2)
SYM (_msl_arch_set_ibat2):
	mtibatl 2,3
	mtibatu 2,4
	blr

/* 
* @brief
*       ����IBAT3L�Ĵ���Ϊbatl������IBAT3U�Ĵ���Ϊbatu��
* @param[in]  batl: Ҫ���õ�IBAT3L�Ĵ�������
* @param[in]  batu: Ҫ���õ�IBAT3U�Ĵ�������
* @return
*       none
* @implements  DM.1.2.68,DM.1.3.68,DM.1.4.68
*/
PUBLIC(_msl_arch_set_ibat3)
SYM (_msl_arch_set_ibat3):
	mtibatl 3,3
	mtibatu 3,4
	blr

#if defined(__PPC7450__) || defined(__PPC8640__)

/*
* @brief
*       ����DBAT4L�Ĵ���Ϊbatl������DBAT4U�Ĵ���Ϊbatu��
* @param[in]  batl: Ҫ���õ�DBAT4L�Ĵ�������
* @param[in]  batu: Ҫ���õ�DBAT4U�Ĵ�������
* @return
*      none
* @implements  DM.1.2.61,DM.1.4.61
*/
PUBLIC(_msl_arch_set_dbat4)
SYM (_msl_arch_set_dbat4):
	mtspr 569,3
	mtspr 568,4
	blr

/*
* @brief
*       ����DBAT5L�Ĵ���Ϊbatl������DBAT5U�Ĵ���Ϊbatu��
* @param[in]  batl: Ҫ���õ�DBAT5L�Ĵ�������
* @param[in]  batu: Ҫ���õ�DBAT5U�Ĵ�������
* @return
*       none
* @implements  DM.1.2.62,DM.1.4.62
*/
PUBLIC(_msl_arch_set_dbat5)
SYM (_msl_arch_set_dbat5):
	mtspr 571,3
	mtspr 570,4
	blr

/*
* @brief
*       ����DBAT6L�Ĵ���Ϊbatl������DBAT6U�Ĵ���Ϊbatu��
* @param[in]  batl: Ҫ���õ�DBAT6L�Ĵ�������
* @param[in]  batu: Ҫ���õ�DBAT6U�Ĵ�������
* @return
*       none
* @implements  DM.1.2.63,DM.1.4.63
*/
PUBLIC(_msl_arch_set_dbat6)
SYM (_msl_arch_set_dbat6):
	mtspr 573,3
	mtspr 572,4
	blr

/*
* @brief
*       ����DBAT7L�Ĵ���Ϊbatl������DBAT7U�Ĵ���Ϊbatu��
* @param[in]  batl: Ҫ���õ�DBAT7L�Ĵ�������
* @param[in]  batu: Ҫ���õ�DBAT7U�Ĵ�������
* @return
*       none
* @implements  DM.1.2.64,DM.1.4.64
*/
PUBLIC(_msl_arch_set_dbat7) 
SYM (_msl_arch_set_dbat7):
	mtspr 575,3
	mtspr 574,4
	blr

/*
* @brief
*       ����IBAT4L�Ĵ���Ϊbatl������IBAT4U�Ĵ���Ϊbatu��
* @param[in]  batl: Ҫ���õ�IBAT4L�Ĵ�������
* @param[in]  batu: Ҫ���õ�IBAT4U�Ĵ�������
* @return
*       none
* @implements  DM.1.2.69,DM.1.4.69
*/
PUBLIC(_msl_arch_set_ibat4)
SYM (_msl_arch_set_ibat4):
	mtspr 561,3
	mtspr 560,4
	blr
    
/*
* @brief
*       ����IBAT5L�Ĵ���Ϊbatl������IBAT5U�Ĵ���Ϊbatu��
* @param[in]  batl: Ҫ���õ�IBAT5L�Ĵ�������
* @param[in]  batu: Ҫ���õ�IBAT5U�Ĵ�������
* @return
*       none
* @implements  DM.1.2.70,DM.1.4.70
*/
PUBLIC(_msl_arch_set_ibat5)
SYM (_msl_arch_set_ibat5):
	mtspr 563,3
	mtspr 562,4
	blr

/*
* @brief
*       ����IBAT6L�Ĵ���Ϊbatl������IBAT6U�Ĵ���Ϊbatu��
* @param[in]  batl: Ҫ���õ�IBAT6L�Ĵ�������
* @param[in]  batu: Ҫ���õ�IBAT6U�Ĵ�������
* @return
*      none
* @implements  DM.1.2.71,DM.1.4.71
*/
PUBLIC(_msl_arch_set_ibat6)
SYM (_msl_arch_set_ibat6):
	mtspr 565,3
	mtspr 564,4
	blr

/*
* @brief
*       ����IBAT7L�Ĵ���Ϊbatl������IBAT7U�Ĵ���Ϊbatu��
* @param[in]  batl: Ҫ���õ�IBAT7L�Ĵ�������
* @param[in]  batu: Ҫ���õ�IBAT7U�Ĵ�������
* @return
*       none
* @implements  DM.1.2.72,DM.1.4.72
*/
PUBLIC(_msl_arch_set_ibat7)
SYM (_msl_arch_set_ibat7):
	mtspr 567,3
	mtspr 566,4
	blr
#endif

/*
* @brief
*       ʹeaָ����ָ��TLB������TLB��Ч��
* @param[in]  ea: ָ�����߼���ַ
* @return
*       none
* @implements  DM.1.2.56,DM.1.3.56,DM.1.4.56
*/
PUBLIC(_msl_arch_invalidate_tlb)
SYM (_msl_arch_invalidate_tlb):
	tlbie 3
	blr
 
/*
* @brief
*       ��ʼ��BAT�Ĵ�����
* @param[in]  value: Ҫд��ĳ�ֵ��
* @return
*       none
* @implements  DM.1.2.74,DM.1.3.74,DM.1.4.74
*/
PUBLIC(taArchInitializeBat)
SYM (taArchInitializeBat):
    mtibatu 0,3
    mtibatu 1,3
    mtibatu 2,3
    mtibatu 3,3
    mtdbatu 0,3
    mtdbatu 1,3
    mtdbatu 2,3
    mtdbatu 3,3
#if defined(__PPC7450__) || defined(__PPC8640__)

    /*����������mtdbatuָ���ǣ�bat�Ĵ���������ֻ��Ϊ0-3�����ֻ��ʹ��mtspr��ʼ����չ��bat�Ĵ���*/
    mtspr 560,3
    mtspr 562,3
    mtspr 564,3
    mtspr 566,3
    mtspr 568,3
    mtspr 570,3
    mtspr 572,3
    mtspr 574,3
#endif
    blr
	
/*
* @brief
*       ͨ������MSR�Ĵ�����IRλ��DRλΪ1ʹ��MMU��
* @return
*       none
* @implements  DM.1.2.54,DM.1.3.54,DM.1.4.54
*/
PUBLIC(taArchEnableMMU)
SYM (taArchEnableMMU):
    mfmsr 3
    ori 3,3,0x30
    sync
    isync
    mtmsr 3
    sync
    isync
    blr

/*
* @brief
*       ͨ������MSR�Ĵ�����IRλ��DRλΪ0��ֹMMU��
* @return
*       none
* @implements  DM.1.2.94,DM.1.3.94,DM.1.4.94
*/
PUBLIC(taArchDisableMMU)
SYM (taArchDisableMMU):
    mfmsr 3
    li  4, 0x30
    andc 3,3,4
    sync
    isync
    mtmsr 3
    sync
    isync
    blr
 
/*
* @brief
*       ��ȡhid0�Ĵ�����ֵ��
* @return
*       ��ȡ����hid0�Ĵ�����ֵ
* @implements  DM.1.2.48,DM.1.3.48,DM.1.4.48
*/
PUBLIC(taArchCacheGetHid0)
SYM (taArchCacheGetHid0):
	mfspr 3, 1008
	blr

/*
* @brief
*       ����hid0�Ĵ�����ֵ��
* @param[in]  hid0: д��hid0�Ĵ�����ֵ
* @return
*       none
* @implements  DM.1.2.53,DM.1.3.53,DM.1.4.53
*/ 
PUBLIC(taArchCacheSetHid0)
SYM (taArchCacheSetHid0):
	sync
	mtspr 1008,3
	sync
	isync
	blr

/*
* @brief
*       ���ݴ���Ĳ�������hid0�Ĵ�����
* @param[in]  first: д��hid0�Ĵ�����ֵ
* @param[in]  second: д��hid0�Ĵ�����ֵ
* @return
*       none
* @implements  DM.1.2.52,DM.1.3.52,DM.1.4.52
*/ 
PUBLIC(taArchCacheInvalidByhid0)
SYM (taArchCacheInvalidByhid0):
	sync
	mtspr 1008,3 /* ����first��ֵ����hid0�Ĵ��� */
	mtspr 1008,4 /* ����second��ֵ����hid0�Ĵ��� */
	sync
	isync
	blr


/*
* @brief
*       ˢ�´�ָ����ʼ��ַ��ʼ,ָ����С�ڴ���cache�е����ݡ�
* @param[in]  startAddr: ˢ����ʼ��ַ
* @param[in]  cnt: cache���ܿ���
* @param[in]  lineSize: ÿ��cache��Ĵ�С
* @return
*      none
* @implements  DM.1.2.46,DM.1.3.46,DM.1.4.46
*/
PUBLIC(taArchCacheFlush)
SYM (taArchCacheFlush):

cache_flush_loop:
	addic.  4,4,-1 /* ��cnt�Լ�1�ٴ���cnt */
	dcbst   0,3   /* ˢ����start_addr��ʼ��cache�� */
	sync
	add     3,3,5  /* ��start_addr����line_size�ٴ���start_addr */
	bgt     cache_flush_loop /* ���cnt����0����ת��cache_flush_loop����ִ�� */  
	blr


/*
* @brief
*       ˢ������cache
* @param[in]  startAddr: ˢ����ʼ��ַ
* @param[in]  cnt: cache���ܿ���
* @param[in]  lineSize: ÿ��cache��Ĵ�С
* @param[in]  null: ��ǰ��ַ��Ӧ�ڴ������
* @return
*       none
* @implements  DM.1.2.47,DM.1.3.47,DM.1.4.47
*/ 
PUBLIC(tarchCacheFlushAll)
SYM (tarchCacheFlushAll):

cache_flush_all_loop:
	addic.  4,4,-1 /* ��cnt�Լ�1�ٴ���cnt */
	lwz     6,0(3) /* ����ǰ��ַ��Ӧ�ڴ��е����ݴ���null */
	sync
	dcbst   0,3  /* ˢ����start_addr��ʼ��cache�� */
	sync
	add     3,3,5  /* ��start_addr����line_size�ٴ���start_addr */
	bgt     cache_flush_all_loop  /* ���cnt����0����ת��cache_flush_loop����ִ�� */
	blr

/*
* @brief
*       ��Ч��ָ����ʼ��ַ��ʼ,ָ����С������cache��
* @param[in]  startAddr: ��Ч��ʼ��ַ
* @param[in]  cnt: cache���ܿ���
* @param[in]  lineSize: ÿ��cache��Ĵ�С
* @return
*       none
* @implements  DM.1.2.49,DM.1.3.49,DM.1.4.49
*/ 
PUBLIC(taArchCacheInvalidateData)
SYM (taArchCacheInvalidateData):

cache_invalidate_data_loop:
	addic.  4,4,-1 /* ��cnt�Լ�1�ٴ���cnt */
	dcbi    0,3  /* ��Ч��start_addr��ʼ������cache�� */
	sync
	isync
	add     3,3,5  /* ��start_addr����line_size�ٴ���start_addr */
	bgt     cache_invalidate_data_loop  /* ���cnt����0����ת��cache_invalidate_data_loop����ִ�� */  
	blr

/*
* @brief
*       ��Ч��ָ����ʼ��ַ��ʼ,ָ����С��ָ��cache��
* @param[in]  startAddr: ��Ч��ʼ��ַ
* @param[in]  cnt: cache���ܿ���
* @param[in]  lineSize: ÿ��cache��Ĵ�С
* @return
*       none
* @implements  DM.1.2.50,DM.1.3.50,DM.1.4.50
*/
PUBLIC(taArchCacheInvalidateInst)
SYM (taArchCacheInvalidateInst):

cache_invalidate_inst_loop:
	addic.  4,4,-1  /* ��cnt�Լ�1�ٴ���cnt */
	icbi    0,3   /* ��Ч��start_addr��ʼ��ָ��cache�� */
	isync
	add     3,3,5  /* ��start_addr����line_size�ٴ���start_addr */
	bgt     cache_invalidate_inst_loop  /* ���cnt����0����ת��cache_invalidate_inst_loop����ִ�� */
	blr

/*
* @brief 
*       ��Ч��ָ����ʼ��ַ��ʼ,ָ����С���������͵�cache��
* @param[in]  startAddr: ��Ч��ʼ��ַ
* @param[in]  cnt: cache���ܿ���
* @param[in]  lineSize: ÿ��cache��Ĵ�С
* @return
*       none
* @implements  DM.1.2.51,DM.1.3.51,DM.1.4.51
*/
PUBLIC(taArchCacheInvalidateInstdata)
SYM (taArchCacheInvalidateInstdata):

cache_invalidate_inst_and_loop:
	addic.  4,4,-1  /* ��cnt�Լ�1�ٴ���cnt */
	dcbi    0,3    /* ��Ч��start_addr��ʼ������cache�� */
	sync
	icbi    0,3    /* ��Ч��start_addr��ʼ��ָ��cache�� */
	sync
	isync
	add     3,3,5  /* ��start_addr����line_size�ٴ���start_addr */
	bgt     cache_invalidate_inst_and_loop  /* ���cnt����0����ת��cache_invalidate_inst_and_loop����ִ�� */ 
	blr
    
/*
* @brief 
*       ����ϵͳջ��
* @param[in]  sysStack: ϵͳջ�ռ��ַ��
* @returns
*       none
* @implements  DM.1.2.77,DM.1.3.77,DM.1.4.77
*/
/* T_VOID setSysStack(T_VOID *sysStack)*/
.text
.p2align  4
PUBLIC(taArchSetSysstack)
SYM (taArchSetSysstack):
	subi r3,r3,16
	rlwinm  r3,r3,0,0,28 /* r3 & 0xfffffff8 */
	mtspr SPRG0,r3		/* spgr0 ���浱ǰVM��ϵͳջ */
	blr

/*
* @brief 
*       ���ö������ġ�
* @param[in]  srBase: �������Ŀռ����ַ��
* @return
*       none
* @implements  DM.1.2.76,DM.1.3.76,DM.1.4.76
*/
/* void setSegmentContext(T_VOID *srBase)*/
.text
.p2align  4
PUBLIC(taArchSetSegmentContext)
SYM (taArchSetSegmentContext):
	li	r0,16		
	mtctr	r0
	li	r4,0
1:
	lwz r5,0(r3)
	mtsrin	r5,r4
	sync
	isync
	addi	r3,r3,4			/* next sr */
	addis	r4,r4,0x1000	/* address of next segment */
	bdnz	1b
	blr

/*
* @brief 
*       RAW VectorĬ�ϴ���������
* @return
*       none 
* @implements  DM.1.2.75,DM.1.3.75,DM.1.4.75
*/
.text
.p2align 4
PUBLIC(taNullRawHandler)
SYM (taNullRawHandler):
	blr


/*
 * @brief 
 *    �ж�mmu�Ƿ�ʹ�ܡ�
 * @return
 *     TRUE:mmu��ʹ��
 *     FALSE:mmuδʹ��
 * @implements  DM.1.2.90,DM.1.3.90,DM.1.4.90
 */
.text
.p2align 4
PUBLIC(taArchMMUIsEnabled)
SYM (taArchMMUIsEnabled):
    mfmsr r3
    andi. r3,r3,0x30 /* ���[IR][DR]λ */
	beq .mmuDisabled
	li	r3,1
	blr
.mmuDisabled:
    li	r3,0
    blr