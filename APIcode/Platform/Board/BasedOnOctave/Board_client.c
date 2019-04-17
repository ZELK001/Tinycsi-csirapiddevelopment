/*
Data transmission with sockfd for online display with Humming Board
This code is for client side, which is used to collect CSI data.

Usage: ./log_to_file_display_online server's address(e.g. 10.214.128.162) file name(e.g. 1.csi)
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <errno.h>  
#include <sys/types.h>  
#include <linux/netlink.h>
#include <netinet/in.h> 
#include <sys/types.h>
#include <ifaddrs.h>
#include <time.h>

#define MAX_PAYLOAD 2048
#define DEFAULT_PORT 8099//用与连接服务器UI

int sockfd = -1;//套接字

void check_usage(int argc, char** argv);
void findIP(char *ip);
void VS_StrTrim(char *pStr);
int main(int argc, char** argv)
{
        //获取CSI文件时间
        char get_csi_time[100]="\0";
        char csifile[300]="\0";
        char deviceid[10]="0001";
       /* 
        FILE *fp_system;
        if((fp_system=fopen("system_result","a+"))==NULL)
        {
           printf("The file can not open\n");
           exit(1);
        } 
        */
	/* Local variables */
	struct sockaddr_nl proc_addr, kern_addr;	// addrs for recv, send, bind
	struct cn_msg *cmsg;
	struct sockaddr_in servaddr;
	char buf[1024];

	/* Make sure usage is correct */
	check_usage(argc, argv);

	//建立与服务器UI相连的套接字
	/* Set network sockfd to transmit data*/
	if( (sockfd = socket(AF_INET, SOCK_STREAM, 0)) < 0){  
    		printf("create sockfd error: %s(errno: %d)\n", strerror(errno),errno);  
    		exit(0);  
    	}  
	memset(&servaddr, 0, sizeof(servaddr));  
	servaddr.sin_family = AF_INET;  
	servaddr.sin_port = htons(DEFAULT_PORT);  
	
        //设置要连接服务器的IP
    	if( inet_pton(AF_INET, argv[1], &servaddr.sin_addr) <= 0){  
    		printf("inet_pton error for %s\n",argv[1]);  
    		exit(0);  
   	}
        //连接到服务器
	if( connect(sockfd, (struct sockaddr*)&servaddr, sizeof(servaddr)) < 0){  
   		printf("connect error: %s(errno: %d)\n",strerror(errno),errno);  
    		exit(0);  
    	}
	/* Poll sockfd forever waiting for a message */

	 
           char ip[20] = {0};  
           findIP(ip); 
           char login_order[40] ="<LOGIN>0001Device";
           strcat(login_order,"|");
           strcat(login_order,ip);
           strcat(login_order,"\n");
      
           bzero(buf,sizeof(buf));
          // sprintf(buf,"%s","<DeviceLogin>0001|192.111.111.11\n");
           sprintf(buf,"%s",login_order);
           write(sockfd, buf, strlen(buf));//向服务器端发送请求登录指令
           //注意是strlen（buf），而不是sizeof(buf)，后者会在发送缓冲区中产生许多空格。。。
           int nbytes=read(sockfd, buf, sizeof(buf));//接收服务器端允许登录的指令
           buf[nbytes]='\0';
           printf("服务器端 发送的指令:%s\n",buf);
           if(nbytes==0)
           { 
             printf("连接断开\n");
             return 0;
           } 
           else if(strcmp(buf,"ok\n")==0)
           {
             printf("设备连接成功\n");

           }
           //建立新线程用来发送心跳包
           if(!fork())
           {
             while(1)
             {
               sleep(1);
               char heartbeat[30]="<HeartBeatTest>\n";
               write(sockfd,heartbeat,strlen(heartbeat));
             }
           }
        while (1)
	 {

           int result=read(sockfd,  buf, sizeof(buf));
           if(result==0)
           { 
             printf("连接断开\n");
             return 0;
           } 
           else
           {
             buf[result]='\0'; 
             printf("收到数据为:%s\n",buf);
             if(strcmp(buf,"get_csi\n")==0)
             {
                //获取当前系统时间
                time_t timep;
                time(&timep);
                printf("当前时间是%s",ctime(&timep));
                strcpy(get_csi_time,ctime(&timep));
                VS_StrTrim(get_csi_time);
                printf("当前时间是%s",get_csi_time);
                get_csi_time[strlen(get_csi_time)-1]=0;
  
                //构建CSI文件名
                sprintf(csifile,"%s_%s_csi",deviceid,get_csi_time);
                printf("CSI文件名是%s\n",csifile);
                //构建调用shell脚本命令
                char get_csi_order[300]="\0";
                sprintf(get_csi_order,"bash /root/Sever_test_Board/sh_two.sh %s &",csifile);
                //system(get_csi_order);//调用脚本执行采集CSI
                printf("start to get csi\n");
                char csifile_message[400] ="<CSIFile>";
                strcat(csifile_message,csifile);
                strcat(csifile_message,"\n");
                bzero(buf,sizeof(buf));
                //将CSI文件名发送到服务器端，服务器端进行存储到数据库
                sprintf(buf,"%s",csifile_message);
                printf("message to server : %s",buf);
                write(sockfd,buf,strlen(buf));

                FILE *fp_system;
                if((fp_system=fopen("system_result","a+"))==NULL)
                {
                  printf("The file can not open\n");
                  exit(1);
                 }

               // if(!fork())
               // {
                  int result_system;
                  result_system=system(get_csi_order);
                  fprintf(fp_system,"%d",result_system);
                  fclose(fp_system);
               // }
              
             }
             else if(strcmp(buf,"stop_get_csi\n")==0)
             {
                printf("stop to get csi\n");
                //调用脚本停止采集CSI
                char stop_get_csi_order[300]="/root/Sever_test_Board/sh_three.sh";
               // char stop_get_csi_order[300]="/root/Sever_test_Board/sh_four_stopofflinecsi.sh";
                //system(stop_get_csi_order);
                sprintf(buf,"%s","<StopCSIFile>\n");    
                write(sockfd,buf,strlen(buf));
                system(stop_get_csi_order);
             }
           }
  
	}
	return 0;
}

//获取板子的无线网卡IP地址
void findIP(char *ip)   
{  
    struct ifaddrs * ifAddrStruct=NULL;
    void * tmpAddrPtr=NULL;

    getifaddrs(&ifAddrStruct);

    while (ifAddrStruct!=NULL) {
        if (ifAddrStruct->ifa_addr->sa_family==AF_INET) { // check it is IP4
            // is a valid IP4 Address
            tmpAddrPtr=&((struct sockaddr_in *)ifAddrStruct->ifa_addr)->sin_addr;
            char addressBuffer[INET_ADDRSTRLEN];
            inet_ntop(AF_INET, tmpAddrPtr, addressBuffer, INET_ADDRSTRLEN);
            printf("%s IP Address %s\n", ifAddrStruct->ifa_name, addressBuffer); 
            if(strcmp(ifAddrStruct->ifa_name,"wlan2")==0)
            {
                printf("%s IP Address %s\n", ifAddrStruct->ifa_name, addressBuffer);
                strcpy(ip,addressBuffer);
                break;
            }
        } else if (ifAddrStruct->ifa_addr->sa_family==AF_INET6) { // check it is IP6
            // is a valid IP6 Address
            tmpAddrPtr=&((struct sockaddr_in *)ifAddrStruct->ifa_addr)->sin_addr;
            char addressBuffer[INET6_ADDRSTRLEN];
            inet_ntop(AF_INET6, tmpAddrPtr, addressBuffer, INET6_ADDRSTRLEN);
            printf("%s IP Address %s\n", ifAddrStruct->ifa_name, addressBuffer); 
        } 
        ifAddrStruct=ifAddrStruct->ifa_next;
    }
}   

void check_usage(int argc, char** argv)
{
	if (argc != 2)
	{
		fprintf(stderr, "Usage: %s <ipaddress>\n", argv[0]);
		exit(1);
	}
}

void VS_StrTrim(char *pStr)
{
  char *pTmp=pStr;
  while (*pStr != '\0')
  {
     if(*pStr != ' ')
     {
       *pTmp++=*pStr;
  
     }
     ++pStr;
  }
  *pTmp = '\0';
}
