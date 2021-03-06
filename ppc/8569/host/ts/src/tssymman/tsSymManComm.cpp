/*
* 更改历史：
* 2008-09-23  zhangxu  北京科银技术有限公司
*                           创建该文件。
*/

/**
* @file  tsSymManComm.cpp
* @brief
*       功能：
*       <li>tssymman的公共宏定义及公共函数实现</li>
*/



/************************头文件********************************/
#include <afx.h>
#include "windows.h"
#include "Shlwapi.h"
#include "stdio.h"
#include "stdlib.h"
#include "string.h"
#include "tsSymManComm.h"


/************************宏定义********************************/
/************************类型定义******************************/
/************************全局变量******************************/
/************************模块变量******************************/
/************************外部声明******************************/
/************************前向声明******************************/



/************************实现*********************************/

/**
* 功能: 将单个的16进制ASCII字符转换成对应的数字。
* @param ch    单个的16进制ASCII字符
* @return 返回16进制字符对应的ASCII码
*/
int hex2num(unsigned char ch)
{
    if (ch >= 'a' && ch <= 'f')
    {
        return ch-'a'+10;
    }

    if (ch >= '0' && ch <= '9')
    {
        return ch-'0';
    }

    if (ch >= 'A' && ch <= 'F')
    {
        return ch-'A'+10;
    }

    return -1;
}

/**
* 功能: 将16进制字符串转换成对应的32位整数。
* @param ptr[OUT] 输入指向16进制字符串的指针，转换过程中指针同步前
*        进。输出转换结束时的指针。
* @param intValue[OUT]   转换后的32位整数
* @return 返回转换的16进制字符串长度。
*/
unsigned int hex2int(char **ptr, int *intValue)
{
    int numChars = 0;
    int hexValue;

    *intValue = 0;

    if((NULL == ptr) || (NULL == intValue))
    {
        return 0;
    }

    while (**ptr)
    {
        hexValue = hex2num(**ptr);

        if (hexValue < 0)
        {
            break;
        }

        *intValue = (*intValue << 4) | hexValue;
        numChars ++;

        (*ptr)++;
    }

    return (numChars);
}

/**
* 功能: 把int转换成16进制的字符串,必须保证size大小大于转换后的字符串大小
* @param ptr 保存16进制字符串的缓冲区
* @param size   缓冲区的大小
* @param intValue   要转换的整形
* @return 转换的大小
*/
unsigned int int2hex(char *ptr, int size,int intValue)
{
    if(NULL == ptr)
    {
        return 0;
    }

    memset(ptr, '\0',size);    //设置大小,最大缓冲区的大小
    sprintf(ptr,"%x",intValue);
    return (unsigned int)strlen(ptr);
}

/**
 * @Funcname: CheckFolderExist
 * @brief        : 检查目录是否存在
 * @para[IN]   : strPath目录名
 * @return      : 目录存在与否
 * @Author     : zhangxu
 *
 * @History: 1.  Created this function on 2008年9月24日 13:34:11
 *
**/
int  CheckFolderExist(char* strPath)
{
    WIN32_FIND_DATA  wfd;
    HANDLE hFind;
    bool ret = FALSE;

    hFind = FindFirstFile(strPath, &wfd);

    if ((hFind != INVALID_HANDLE_VALUE) && (wfd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY))
    {
        ret = TRUE;
        FindClose(hFind);
    }

    return ret;
}

/**
 * @Funcname: CheckFileExist
 * @brief        : 检查文件是否存在
 * @para[IN]   : strFile文件名
 * @return      : 文件存在与否
 * @Author     : zhangxu
 *
 * @History: 1.  Created this function on 2008年9月24日 13:34:11
 *
**/
int CheckFileExist(char *strFile)
{
    WIN32_FIND_DATA FindFileData;
    HANDLE hFind;
    bool ret = FALSE;

    hFind = FindFirstFile(strFile, &FindFileData);

    if (hFind != INVALID_HANDLE_VALUE)
    {
        ret = TRUE;
        FindClose(hFind);
    }

    return ret;
}

/**
 * @Funcname: DeleteDirectory
 * @brief        : 删除目录(包括空目录和非空目录)
 * @para[IN]   : strPath目录名
 * @return      : 删除是否成功
 * @Author     : zhangxu
 *
 * @History: 1.  Created this function on 2008年9月24日 13:34:11
 *
**/
int DeleteDirectory(char *strPath)
{
    CFileFind fileFind;
    char fileFindName[260] = "\0";
    char foundFileName[260] = "\0";
    char tempDir[260] = "\0";
    char tempFileName[260] = "\0";
    int isFound;

    sprintf(fileFindName,"%s\\*.*",strPath);
    isFound=fileFind.FindFile(fileFindName);

    while(isFound)
    {
        isFound=fileFind.FindNextFile();

        if(!fileFind.IsDots())
        {

            strcpy(foundFileName,(char*)fileFind.GetFileName().GetBuffer(260));

            if(fileFind.IsDirectory())
            {

                sprintf(tempDir,"%s\\%s",strPath,foundFileName);
                DeleteDirectory(tempDir);
            }

            else
            {

                sprintf(tempFileName,"%s\\%s",strPath,foundFileName);
                DeleteFile(tempFileName);
            }
        }
    }

    fileFind.Close();

    if(!RemoveDirectory(strPath))//此时应该只是一个空目录了
    {
        return FALSE;
    }

    return TRUE;
}

/**
 * @Funcname: DeleteFolderAllFile
 * @brief        : 删除文件夹下所有文件
 * @para[IN]   : strPath目录名
 * @return      : 删除是否成功
 * @Author     : zhangxu
 *
 * @History: 1.  Created this function on 2008年9月24日 13:34:11
 *
**/
int DeleteFolderAllFile(char *strPath)
{
    CFileFind fileFind;
    char fileFindName[260] = "\0";
    char foundFileName[260] = "\0";
    char tempDir[260] = "\0";
    char tempFileName[260] = "\0";
    int isFound;

    sprintf(fileFindName,"%s\\*.*",strPath);
    isFound=fileFind.FindFile(fileFindName);

    while(isFound)
    {
        isFound=fileFind.FindNextFile();

        if(!fileFind.IsDots())
        {

            strcpy(foundFileName,(char*)fileFind.GetFileName().GetBuffer(260));

            if(fileFind.IsDirectory())
            {

                sprintf(tempDir,"%s\\%s",strPath,foundFileName);
                DeleteFolderAllFile(tempDir);
            }

            else
            {

                sprintf(tempFileName,"%s\\%s",strPath,foundFileName);
                DeleteFile(tempFileName);
            }
        }
    }

    fileFind.Close();
    return TRUE;
}

