//
//  ViewController.m
//  Juny_playerDemo
//
//  Created by 宋俊红 on 2017/12/26.
//  Copyright © 2017年 Juny_song. All rights reserved.
//
#import "ARAvplayerContol.h"
#import "ViewController.h"
#import "DownLoadControl.h"

@interface ViewController (){

    __weak IBOutlet UIView *_playView;
    ARAvplayerContol *_playerControl;
    AVPlayerLayer* _playerLayer;
    DownLoadControl *_downLoadCotrol ;
}


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _playView.hidden = YES;
    _playerControl = [ARAvplayerContol sharePlayer];
    
   _downLoadCotrol = [DownLoadControl shared];
   [_downLoadCotrol downLoadWithURLString:@"http://image.1hucj.com/Video/20171218/20171218115334009765.mp4"];
  
    
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)creatPlayerLayer{
    if (!_playerLayer) {
        
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_playerControl.player];
        _playerLayer.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;//设置填充模式
        [_playView.layer addSublayer:_playerLayer];
        
    }
    
}
- (IBAction)btnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [_downLoadCotrol pause];
    }else{
        [_downLoadCotrol restart];
    }
 

    
    return;
    
    
    
    
    if (_playView.hidden) {
        _playView.hidden = NO;
    }
    
    [_playerControl playWithURLString:@"http://image.1hucj.com/Video/20171218/20171218115334009765.mp4"];
    [self creatPlayerLayer];
}


@end
