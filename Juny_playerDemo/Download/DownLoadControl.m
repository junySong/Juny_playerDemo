//
//  DownLoadControl.m
//  Juny_playerDemo
//
//  Created by 宋俊红 on 2018/1/2.
//  Copyright © 2018年 Juny_song. All rights reserved.
//http://image.1hucj.com/Video/20171218/20171218115334009765.mp4



#import "DownLoadControl.h"
@interface DownLoadControl(){
    
}


@property (nonatomic, copy) NSString *url;//URL
@property (nonatomic, assign) long long currentLength;//
@property (nonatomic, assign) long long totalLength;
@property (nonatomic, strong) NSFileHandle *writeHandle;//文件助理
@property (nonatomic, strong) NSURLConnection *connection;//

@end




@implementation DownLoadControl
+ (DownLoadControl*)shared{
    
    static DownLoadControl *_control;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _control = [[DownLoadControl alloc]init];
       
    });
    return _control;
}
#pragma mark- ------------------------private------------------------------------

- (void)downLoadFilesWithURLString:(NSString*)string{
    if (string) {
        self.url = string;
        // 2.请求
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:string]];
        
        // 设置请求头
        NSString *range = [NSString stringWithFormat:@"bytes=%lld-", self.currentLength];
        [request setValue:range forHTTPHeaderField:@"Range"];
        
        // 3.下载
        self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    }
 
}


#pragma mark- ------------------------public------------------------------------


- (void)downLoadWithURLString:(NSString*)urlString{
    [self downLoadFilesWithURLString:urlString];
}

- (void)pause{
    [self.connection cancel];
    self.connection = nil;
}

- (void)restart{
  
    [self downLoadFilesWithURLString:self.url];
 
}

#pragma mark- ------------------------connectionDelegate------------------------------------
/**
 *  请求失败时调用（请求超时、网络异常）
 *
 *  @param error      错误原因
 */
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
     NSLog(@"-----%@----",error);
}
/**
 *  1.接收到服务器的响应就会调用
 *
 *  @param response   响应
 */
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
    // 获得文件的总大小
    self.totalLength = response.expectedContentLength;
    self.currentLength = 0;
    
    // 文件路径
    NSString* ceches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString* filepath = [ceches stringByAppendingPathComponent:response.suggestedFilename];
    
    // 如果文件已经存在，就判断大小，如果满了
    NSFileManager* mgr = [NSFileManager defaultManager];
    
    if ([mgr fileExistsAtPath:filepath]) {
        
        long long nowFileSize = [mgr attributesOfItemAtPath:filepath error:nil].fileSize;
        if (nowFileSize == response.expectedContentLength) {
            [self pause];
            return;
        }else{
            self.currentLength = nowFileSize;
        }
    }else{
        [mgr createFileAtPath:filepath contents:nil attributes:nil];
    }
    
    
    
    // 创建一个用来写数据的文件句柄对象
    self.writeHandle = [NSFileHandle fileHandleForWritingAtPath:filepath];
    
  
  
   
}
/**
 *  2.当接收到服务器返回的实体数据时调用（具体内容，这个方法可能会被调用多次）
 *
 *  @param data       这次返回的数据
 */
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // 移动到文件的最后面
    [self.writeHandle seekToEndOfFile];
    
    // 将数据写入沙盒
    [self.writeHandle writeData:data];
    
    // 累计写入文件的长度
    self.currentLength += data.length;
    

    
    NSLog(@"-----%.4f----",self.currentLength *(1.0)/ self.totalLength);

}
/**
 *  3.加载完毕后调用（服务器的数据已经完全返回后）
 */
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.currentLength = 0;
    self.totalLength = 0;
    
    // 关闭文件
    [self.writeHandle closeFile];
    self.writeHandle = nil;
    
  
    
}


@end
