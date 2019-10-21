//
//  AirPlayController.h
//  AirView
//
//  Created by Clément Vasseur on 12/16/10.
//  Copyright 2010 Clément Vasseur. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <AVKit/AVKit.h>
#import "AirPlayHTTPServer.h"

@interface AirPlayController : NSObject

@property(nonatomic, assign) float start_position;
@property(nonatomic, strong) AVPlayer *anAVPlayer;
@property(nonatomic, strong) AVPlayerView *anAVPlayerView;
@property(nonatomic, strong) NSWindow *window;
@property(nonatomic, strong) AirPlayHTTPServer *httpServer;
@property(nonatomic, strong) AirPlayHTTPServer *raopServer;

- (void)startServer;
- (void)stopServer;
- (void)stopPlayer;
- (void)play:(NSURL *)location atRelativePosition:(float)position;
- (void)stop;
- (void)setPosition:(float)position;
- (float)position;
- (void)setRate:(float)value;
- (NSTimeInterval)duration;
- (void)dealloc;

@end
