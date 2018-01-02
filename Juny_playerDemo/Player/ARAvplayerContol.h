//
//  ARAvplayerContol.h
//  ARS
//
//  Created by 宋俊红 on 17/8/5.
//  Copyright © 2017年 liujie. All rights reserved.
//
/**
 打算实现的功能，是一个单例类
 根据URL，播放视频音频，暂停，播放，
 下一首
 
 */


#import <Foundation/Foundation.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
/**
 播放器的控制类
 */
@interface ARAvplayerContol : NSObject
@property (nonatomic, assign) UIBackgroundTaskIdentifier bgTaskId;//
@property (nonatomic, strong) NSString *urlStirng;//正在播放的URL
@property (nonatomic, assign) BOOL isPlaying;//是否正在播放，默认为No
/**
 播放器
 */
@property (nonatomic, strong) AVPlayer *player;//

- (BOOL)hasInitPlayer;

/**
 初始化方法

 @return 当前类对象
 */
+(instancetype)sharePlayer;

/**
 播放
 */
- (void)play;

/**
 暂停
 */
- (void)pause;

/**
 播放当前URL下的内容

 @param string string description
 */
- (void)playWithURLString:(NSString *)string;

/**
 释放当前player
 */
- (void)releasePlayer;

/**
 跳转到指定进度

 @param scale scale description
 */
- (void)seekToScale:(CGFloat)scale;


@end
