/***************************************************************************
 *                �����������ɼ������޹�˾ ��Ȩ����
 *      Copyright (C) 2013 CoreTek Systems Inc. All Rights Reserved.
***************************************************************************/

/*
 *�޸���ʷ:
 *2013-06-27         ��Ԫ־�������������ɼ������޹�˾
 *                           �������ļ���
 */

/*
 * @file:taArchInfo.c
 * @brief:
 *             <li>��ϵ�ṹ��Ϣ��ѯ</li>
 */

/************************ͷ �� ��******************************/
#include <string.h>
#include "taTypes.h"

/************************�� �� ��******************************/

/************************���Ͷ���*****************************/

/************************�ⲿ����*****************************/

/************************ǰ������*****************************/

/************************ģ�����*****************************/

/************************ȫ�ֱ���*****************************/

/************************����ʵ��*****************************/

/*
 * @brief:
 *     ��ѯx86��ϵ�ṹ�µ���ϵ�ṹ��Ϣ
 * @param[out]:outbuf: ������ݻ��壬�������Ϊ"x86"
 * @param[out]:outsize: ������ݳ���
 * @return:
 *      ��
 */
void taArchInfoGet(UINT8 *outbuf, UINT32 *outSize)
{
    /* ����Ŀ�����ϵ�ṹΪx86 */
    strcpy((char *)outbuf, "x86");

    /* ������������е��ַ������� */
    *outSize = strlen((const char *)outbuf);
}

/*
 * @brief:
 *     ��ѯx86��ϵ�ṹ�Ĵ�С��
 * @param[out]:outbuf: ������ݻ��壬�������Ϊ"little"
 * @param[out]:outsize: ������ݳ���
 * @return:
 *      ��
 */
void taEndianInfoGet(UINT8 *outbuf, UINT32 *outSize)
{
    /* ����ΪС�� */
    strcpy((char *)outbuf, "little");

    /* ������������е��ַ������� */
    *outSize = strlen((const char *)outbuf);
}