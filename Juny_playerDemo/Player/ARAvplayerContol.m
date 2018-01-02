
//
//  ARAvplayerContol.m
//  ARS
//
//  Created by 宋俊红 on 17/8/5.
//  Copyright © 2017年 liujie. All rights reserved.
//

#import "ARAvplayerContol.h"

//#import "AppDelegate.h"

/*关于播放器解耦的思考
 需要解决的问题：
 1、别的页面需要调用播放器的时间（在别的页面有同一个URL的判断，（音频和视频））
 2、播放器的通知
 3、播放和暂停时候调用后台接口
 4、播放器当前正在播放，点击播放按钮，换一个播放（每次点击播放按钮和暂停，判断，需要播放的URL和当前的播放器的URL是不是同一个，是，就调用播放和暂停；不是的话，如果是播放就播放新的，暂停就不管他，按钮回复之前的播放状态）
 
 播放器打算做的事
 1、有一个时间的属性，在本播放器中调用时间观察者，一直给时间属性赋值
 2、有一个总时间的属性，在播放器准备好的时候，给这个属性付值
 3、有一个缓冲时间的属性，用鱼缓冲进度条（在本播放器添加观察者，随时观察状态）
 
 */




/*
 AVPlayerItemStatus类型的属性进行监听
 */
static NSString * const PlayerItemStatusContext = @"PlayerItemStatusContext";
/*
 ,获取缓冲进度
 */
static NSString * const PlayerPreloadObserverContext = @"PlayerPreloadObserverContext";

static ARAvplayerContol *_playerControl;

/**
 对自己的弱引用，一般用在block里面，避免造成循环引用
 
 @param weakSelf self
 @return 对自己弱引用的指针
 */
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

/**
 打印日志相关
 */
#ifdef DEBUG
#define CLog(format, ...)  NSLog(format, ## __VA_ARGS__)
#else
#define CLog(format,...)
#endif

@interface ARAvplayerContol(){
   id _timeObserver;
}
@property (nonatomic, assign) BOOL hasEnterbackground;//



@end


@implementation ARAvplayerContol


/**
 初始化方法
 
 @return 当前类对象
 */
+(instancetype)sharePlayer{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _playerControl = [[ARAvplayerContol alloc]init];
        [_playerControl addAllNotic];
    });
    return _playerControl;
}


- (void)dealloc{
    [self removeAllObserverAboutPlayer];
    [self removeAllNotic];
}

#pragma mark- ------------------------private------------------------------------

//
/**
 获取时间

 @param seconds seconds description
 @return return value description
 */
- (NSString *)getTimeBySeconds:(CGFloat)seconds {
    
    
    NSString *time;
    NSInteger hour = seconds/60/60;
    //    NSInteger day = hour/24;
    NSInteger minute = (seconds-hour*60*60)/60;
    NSInteger cur=seconds;
    NSInteger second = cur%60;
    if (hour>0) {
        time = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",(long)hour,(long)minute,(long)second];
        
    }else{
        time = [NSString stringWithFormat:@"%02ld:%02ld",(long)minute,(long)second];
        
    }
    return time;
}




#pragma mark - 播放器播放状态相关的通知
- (void)addVideoNotic {
    
    //Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieJumped:) name:AVPlayerItemTimeJumpedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieStalle:) name:AVPlayerItemPlaybackStalledNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backGroundPauseMoive) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
}
- (void)removeVideoNotic {
    //
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemPlaybackStalledNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemTimeJumpedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - 播放器当前状态的观察者
- (void)addVideoKVO
{
    if (_playerControl.player) {
        //视频状态
        [_playerControl.player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        
        //缓存状体啊
        [_playerControl.player.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        
        //
        [_playerControl.player.currentItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    }
    //KVO
    
}
- (void)removeVideoKVO {
    @try {
        
        [_playerControl.player.currentItem removeObserver:self forKeyPath:@"status"];
        [_playerControl.player.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [_playerControl.player.currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    } @catch (NSException *exception) {
        
    } @finally {
        NSLog(@"statusAVPlayerItem  释放的时候报错了");
    }
    
}

#pragma mark - 播放器时间的观察者
- (void)addVideoTimerObserver {
    
    WS(weakSelf);
    
    if (!_playerControl.player) {
        _timeObserver = nil;
        return;
    }
    _timeObserver = [_playerControl.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        
//
//        CMTime currentTime = weakSelf.playerControl.player.currentItem.currentTime;
//        //  转化成秒数
//        CGFloat currentPlayTime = (CGFloat)currentTime.value / currentTime.timescale;
//        //  总时间
//        CMTime totalTime = weakSelf.playerControl.player.currentItem.duration;
//
//        CGFloat totalPlayTime = (CGFloat)totalTime.value/totalTime.timescale;
//
//
//
//        NSString *currentTimeSting = [weakSelf getTimeBySeconds:currentPlayTime];
//        NSString *totalTimeString = [weakSelf getTimeBySeconds:totalPlayTime];

//        //         weakSelf.totalTimeLabel.text = totalTimeString;
//
//
//
//        [weakSelf.loadingView stopAnimating];
        
    }];
}
- (void)removeVideoTimerObserver {
    NSLog(@"%@",NSStringFromSelector(_cmd));
    @try {
        if (_timeObserver) {
            [_playerControl.player removeTimeObserver:_timeObserver];
            _timeObserver = nil;
        }
        
    } @catch (NSException *exception) {
        
    } @finally {
        NSLog(@"释放timer observer的时候报错了");
    }
    
}

#pragma mark-------播放器的所有观察者
- (void)removeAllObserverAboutPlayer{
    
    NSLog(@"%@",NSStringFromSelector(_cmd));
        [self removeVideoTimerObserver];
        [self removeVideoKVO];
}



- (void)addAllOberverAboutPlayer{
    NSLog(@"%@",NSStringFromSelector(_cmd));
    [self addVideoKVO];
    [self addVideoTimerObserver];
    
}

#pragma mark-------播放器的所有通知

- (void)addAllNotic{
    [self addVideoNotic];
}

- (void)removeAllNotic{
    [self removeVideoNotic];
 
}
#pragma mark------------------观察者对应的方法----------------------

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    
    //视频播放状态的监听
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = _playerControl.player.currentItem.status;
        switch (status) {
            case AVPlayerItemStatusReadyToPlay:
            {
                CLog(@"AVPlayerItemStatusReadyToPlay");
                if ((!_playerControl.isPlaying)&&_hasEnterbackground) {
                    [_playerControl pause];

                }else{
                    [_playerControl play];
    
                  
                }
                
                
            }
                break;
            case AVPlayerItemStatusUnknown:
            {
                CLog(@"AVPlayerItemStatusUnknown");
            }
                break;
            case AVPlayerItemStatusFailed:
            {
                CLog(@"AVPlayerItemStatusFailed");
                CLog(@"%@",_playerControl.player.currentItem.error);
                dispatch_async(dispatch_get_main_queue(), ^{
//                    [TLToastTool makeToastMessage:@"当前资源无法播放"];
                
                });
            }
                break;
                
            default:
                break;
        }
        
        
        
    }
    
    
    
    
    //视频缓冲进度的监听
    if (context == (__bridge void * _Nullable)(PlayerPreloadObserverContext)){
        if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
            NSArray *timeRanges = (NSArray *)[change objectForKey:NSKeyValueChangeNewKey];
//            [self updateLoadedTimeRanges:timeRanges];
        }
    }
    
    
    
    //缓冲进度监听
    if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
//            [_loadingView startAnimating];
        });
    }
}

#pragma mark- ------------------------通知相关的方法------------------------------------
- (void)movieToEnd:(NSNotification *)notic{
    [self pause];
    [self seekToScale:0.0];
   
}

- (void)movieJumped:(NSNotification *)notic{
    
}


- (void)movieStalle:(NSNotification *)notic{
    
}

- (void)backGroundPauseMoive{
    _hasEnterbackground = YES;
}
#pragma mark- ------------------------public------------------------------------
/**
 播放
 */
- (void)play{
    NSLog(@"playercontrol ---play");
    if (_player) {
        [_player play];
        self.isPlaying = YES;

    }
}

/**
 暂停
 */
- (void)pause{
    NSLog(@"playercontrol ---pause");
    if (_player) {
        [_player pause];
        self.isPlaying = NO;
    }
}

/**
 播放当前URL下的内容
 
 @param string string description
 */
- (void)playWithURLString:(NSString *)string{
    
    _urlStirng = string;
    if (_urlStirng) {//这里有个判空，记得喔
        NSURL  *URL = [NSURL URLWithString:string];
        AVAsset *Asset = [AVAsset assetWithURL:URL];
        
        AVPlayerItem *playItem= [AVPlayerItem playerItemWithAsset:Asset];
        if (_player) {
            //更换播放内容前的时候释放旧的观察者
            [self removeAllObserverAboutPlayer];
            
            [_player replaceCurrentItemWithPlayerItem:playItem];
            //更换后，添加新的观察者
            [self addAllOberverAboutPlayer];
            
        }else{
            
            _player = [AVPlayer playerWithPlayerItem:playItem];
            [self addAllOberverAboutPlayer];
        }
        

        
    }
    
}


- (BOOL)hasInitPlayer{
    return _player ? YES : NO;
}

- (void)releasePlayer{
    if (_player) {
       //释放旧的观察者
        [self removeAllObserverAboutPlayer];
        [self.player replaceCurrentItemWithPlayerItem:nil];
        self.player = nil;
    }
    
    self.isPlaying = NO;
    _urlStirng = nil;
}

- (void)seekToScale:(CGFloat)scale{
    if (self.player.currentItem) {
        CGFloat seekToScale = 0.0;
        if (scale<0) {
            seekToScale = 0.0;
        }else if (scale>1.0) {
            seekToScale = 1.0;
        }else{
            seekToScale = scale;
        }
        
        CMTime totalTime = _playerControl.player.currentItem.duration;
        
        
        CMTime seekToTime = CMTimeMake(totalTime.value*seekToScale, totalTime.timescale);
        [_playerControl.player seekToTime: seekToTime toleranceBefore:CMTimeMake(1, 30) toleranceAfter:CMTimeMake(1, 30)];
//        if (self.isPlaying) {
//            [self pause];
//            [self play];
//        }else{
//            [self pause];
//        }
    }
}


#pragma mark- ------------------------下载相关------------------------------------
//- (void)checkWithURLString:(NSString*)str{
//    NSString *documentDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
//    NSString *myPathDocument = [documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",[_source.videoUrl MD5]]];
//
//
//    NSURL *fileUrl = [NSURL fileURLWithPath:myPathDocument];
//
//    if (asset != nil) {
//        AVMutableComposition *mixComposition = [[AVMutableComposition alloc]init];
//        AVMutableCompositionTrack *firstTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
//        [firstTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:[[asset tracksWithMediaType:AVMediaTypeVideo]objectAtIndex:0] atTime:kCMTimeZero error:nil];
//
//        AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
//        [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:[[asset tracksWithMediaType:AVMediaTypeAudio]objectAtIndex:0] atTime:kCMTimeZero error:nil];
//
//        AVAssetExportSession *exporter = [[AVAssetExportSession alloc]initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
//        exporter.outputURL = fileUrl;
//        if (exporter.supportedFileTypes) {
//            exporter.outputFileType = [exporter.supportedFileTypes objectAtIndex:0] ;
//            exporter.shouldOptimizeForNetworkUse = YES;
//            [exporter exportAsynchronouslyWithCompletionHandler:^{
//
//            }];
//
//        }
//    }
//}
//
////在系统不知道如何处理URLAsset资源时回调
//- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
//    return YES;
//}
//
////在取消加载资源后回调
//- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
//}







@end
