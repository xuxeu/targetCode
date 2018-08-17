/************************************************************************
 *				�����������ɼ������޹�˾ ��Ȩ����
 * 	 Copyright (C) 2011 CoreTek Systems Inc. All Rights Reserved.
 ***********************************************************************/

/*
 * �޸���ʷ��
 * 2011-02-23         ���࣬�����������ɼ������޹�˾
 *                               �������ļ���
 * 2011-04-15	  ���£������������ɼ������޹�˾
 * 				  ����PDL���������������ʽ���޸�GBJ5369Υ���
*/

/*
 * @file: strncmp.c
 * @brief:
 *	   <li> ʵ���ַ���ģ�����strncmp��</li>
 * @implements: DR.1
 */

/* @<MODULE */ 

/************************ͷ �� ��******************************/

/* @<MOD_HEAD */
#include <string.h>
/* @MOD_HEAD> */

/************************�� �� ��******************************/
/************************���Ͷ���******************************/
/************************�ⲿ����******************************/
/************************ǰ������******************************/
/************************ģ�����******************************/
/************************ȫ�ֱ���******************************/
/************************ʵ    ��******************************/

/* @MODULE> */


/**
 * @req
 * @brief:
 *    ��ָ���������αȽ�ָ���������ַ������ַ���	
 * @param[in]: s1: ��һ���ַ�����ʼ��ַ
 * @param[in]: s2: �ڶ����ַ�����ʼ��ַ
 * @param[in]: n: �Ƚϳ��� 
 * @return: 
 *    0: �����ַ���ǰn�����ȵ�ÿ���ַ�����ȡ�
 *    ��ֵ: s1ǰn�����ȵ��ַ������ַ���ASCII��С��s2ǰn�����ȵ��ַ����ж�Ӧ
 *          �ַ���ASCII�롣
 *    ��ֵ: s1ǰn�����ȵ��ַ������ַ���ASCII�����s2ǰn�����ȵ��ַ����ж�Ӧ
 *          �ַ���ASCII�롣
 * @qualification method: ����
 * @derived requirement: ��
 * @function location: API
 * @notes: 
 *    �����в�����һ���ַ����͵ڶ����ַ�����ʼ��ַ����Ч�ԡ�<br>
 *    �ֳ�������ο�RR.1ע�͡�<br>
 * @implements: DR.1.10 
 */
int strncmp(const char *s1, const char *s2, size_t n)
{
    unsigned long *a1 = NULL;
    unsigned long *a2 = NULL;

    /*
     * @brief:
     *    ���<n>����0������0��<br>
     * @qualification method: ����
     * @derived requirement: ��
     * @implements: 1 
     */
    /* @REPLACE_BRACKET: <n>����0 */
    if (0 == n)
    {
        /* @REPLACE_BRACKET: 0 */
        return(0);
    }

    /*
     * @brief:
     *    ���<s1>��<s2>���ֳ����룬�����ֳ�Ϊ��λ���бȽϣ�����ĩβ�����ֳ�����
     *    �����ֽ�Ϊ��λ���бȽϣ����αȽ�<s1>��<s2>ָ���������ַ�����ǰ<n>����
     *    �������<n>��������һ���ַ����ĳ��ȣ���ֻ�ȽϽ϶��ַ�����ȫ���ַ���<br>
     *    (1)��<n>С�������ַ��������������ַ�����ǰ<n>���ַ�����ȣ�����<n>����
     *       �����ַ��������������ַ���ÿ���ַ�����ȣ�����0��<br>
     *    (2)��<n>���������ַ��������������ַ������Ȳ�һ�»��������ַ�����ǰ<n>
     *       ���ַ��в�����ַ�ʱ������c1-c2��<br>
     * @qualification method: ����
     * @derived requirement: ��
     * @notes: 
     *    c1Ϊ<s1>ָ�����ַ����е�һ������ȵ��ַ���<br>
     *    c2Ϊ<s2>ָ�����ַ�������<s1>�ж�Ӧ����ȵ��ַ���<br>
     * @implements: 1 
     */
    /* ���s1��s2û�а��ֶ��룬���ֽڽ��бȽ� */
    /* @REPLACE_BRACKET: <s1>��<s2>���ֶ��� */
    if (0 == UNALIGNED_2(s1, s2))
    {
        a1 = (unsigned long*)s1;
        a2 = (unsigned long*)s2;

        /* @REPLACE_BRACKET: <n>���ڵ����ֳ� && <s1>��<s2>��ǰ�ֳ��Ƚ�������� */       
        while ((n >= LBLOCKSIZE) && ((*a1) == (*a2)))
        {
            /* @KEEP_COMMENT: ����<n>Ϊ<n>-�ֳ� */
            n -= (size_t)LBLOCKSIZE;

            /* @REPLACE_BRACKET: (<n>����0) || <s1>��ǰ�ֳ��Ƚ��������н����� */
            if ((n == 0) || (0 != DETECTNULL(*a1)))
            {
                /* @REPLACE_BRACKET: 0 */
                return(0);
            }

            /* @KEEP_COMMENT: ���ֳ������ƶ�<s1>��<s2>�Ƚ�λ�� */
            a1++;
            a2++;
        }

        /* @KEEP_COMMENT: ���浱ǰ�Ƚ�λ��<s1>��<s2> */
        s1 = (const char*)a1;
        s2 = (const char*)a2;
    }

    /*
     * @brief:
     *    ���<s1>��<s2>�����ֳ����룬�����ֽ�Ϊ��λ���бȽϣ����αȽ�<s1>��<s2>
     *    ָ���������ַ�����ǰ<n>���ַ������<n>��������һ���ַ����ĳ��ȣ���ֻ��
     *    �Ͻ϶��ַ�����ȫ���ַ���<br>
     *    (1)��<n>С�������ַ��������������ַ�����ǰ<n>���ַ�����ȣ�����<n>����
     *       �����ַ��������������ַ���ÿ���ַ�����ȣ�����0��<br>
     *    (2)��<n>���������ַ��������������ַ������Ȳ�һ�»��������ַ�����ǰ<n>
     *       ���ַ��в�����ַ�ʱ������c1-c2��<br>
     * @qualification method: ����
     * @derived requirement: ��
     * @notes: 
     *    c1Ϊ<s1>ָ�����ַ����е�һ������ȵ��ַ���<br>
     *    c2Ϊ<s2>ָ�����ַ�������<s1>�ж�Ӧ����ȵ��ַ���<br>
     * @implements: 2 
     */
    /* ���ֽڽ��бȽ� */
    /* @REPLACE_BRACKET: <s1>��<s2>��ǰ�ֽڱȽ�������� */
    while ((*s1) == (*s2))
    {
        /* @KEEP_COMMENT: <n>-- */
        n--;

        /* @REPLACE_BRACKET: <n>����0 || <s1>��ǰ�ֽڱȽ������ǽ����� */
        if ((0 == n) || ('\0' == (*s1)))
        {
            /* @REPLACE_BRACKET: 0 */
            return(0);
        }

        /* @KEEP_COMMENT: ���ֽ������ƶ�<s1>��<s2>�Ƚ�λ�� */
        s1++;
        s2++;
    }

    /* @REPLACE_BRACKET: <s1>�Ƚ����ݼ�ȥ<s2>�Ƚ����� */
    return((*(unsigned char *)s1)-(*(unsigned char *)s2));
}
