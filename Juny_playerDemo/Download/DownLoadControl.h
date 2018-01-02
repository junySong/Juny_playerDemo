//
//  DownLoadControl.h
//  Juny_playerDemo
//
//  Created by 宋俊红 on 2018/1/2.
//  Copyright © 2018年 Juny_song. All rights reserved.
//
/*
 大文件的下载，断点续传
 
 */
#import <Foundation/Foundation.h>
@class DownLoadControl;





@interface DownLoadControl : NSObject<NSURLConnectionDelegate>

/**
 获取统一的单例类

 @return return value description
 */
+ (DownLoadControl*)shared;


/**
 暂停下载
 */
- (void)pause;

/**
 重新开始下载
 */
- (void)restart;

/**
 Description

 @param urlString urlString description
 */
- (void)downLoadWithURLString:(NSString*)urlString;

@end
