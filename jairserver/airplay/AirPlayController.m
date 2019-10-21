//
//  AirPlayController.m
//  AirView
//
//  Created by Clément Vasseur on 12/16/10.
//  Copyright 2010 Clément Vasseur. All rights reserved.
//

#import "AirPlayController.h"
#import "AirPlayHTTPConnection.h"
#import "DeviceInfo.h"
#import "DDLog.h"

// Log levels: off, error, warn, info, verbose
static const int ddLogLevel = LOG_LEVEL_INFO;

@implementation AirPlayController

- (instancetype)init
{
    self = [super init];
    if (self) {
        DDLogVerbose(@"AirPlayController: init");
        
        // Create server using our custom AirPlayHTTPServer class
        _httpServer = [[AirPlayHTTPServer alloc] init];
        _httpServer.airplay = self;
        
        // Tell the server to broadcast its presence via Bonjour.
        [_httpServer setType:@"_airplay._tcp."];
        [_httpServer setName:@"jiangjiesmbp"];
        NSDictionary *typeTXT = @{
                                  @"features":@"0x4A7FFFF7,0xE",
                                  @"flags":@"0x44",
                                  @"srcvers":@"220.68",
                                  @"vv":@"2",
                                  @"pi":@"fad7d0c8-b455-4d94-97e9-8f7829208e82",
                                  @"pk":@"6b589171628bf0e052aedd517fbb751164a4e3f0ecd33fb37c4e956475da24a6",
                                  @"model":@"AppleTV5,3",
                                  @"deviceid":[DeviceInfo deviceId]
                                  };
        [_httpServer setTXTRecordDictionary:typeTXT];
        
        // We're going to extend the base HTTPConnection class with our AirPlayHTTPConnection class.
        [_httpServer setConnectionClass:[AirPlayHTTPConnection class]];
        
        // Set a dummy document root
        [_httpServer setDocumentRoot:@"/dummy"];


		_raopServer = [[AirPlayHTTPServer alloc] init];
		_raopServer.airplay = self;
		[_raopServer setType:@"_raop._tcp."];
		[_raopServer setName:@"0C54A5569D80@jiangjiesmbp"];
		NSDictionary *raopTypeTxt = @{
				@"tp": @"UDP",
                @"vs": @"220.68",
                @"vv": @"2",
                @"da": @"true",
				@"et": @"0,3,5",
                @"ft": @"0x4A7FFFF7,0xE",
                @"md": @"0,1,2",
				@"cn": @"0,1,2,3",
                @"am": @"AppleTV5,3",
				@"vn": @"65537",
                @"sf": @"0x4"
		};
		[_raopServer setTXTRecordDictionary:raopTypeTxt];
		[_raopServer setConnectionClass:[AirPlayHTTPConnection class]];

	}
    return self;
}


- (void)startServer
{
	NSError *error;
	NSError *raopError;

	DDLogVerbose(@"AirPlayController: startServer");

	// Start the server (and check for problems)
    if(![self.httpServer start:&error] || ![self.raopServer start:&raopError])
//    if(![self.httpServer start:&error])
		DDLogError(@"Error starting HTTP Server: %@", error);
}

- (void)stopServer
{
	DDLogVerbose(@"AirPlayController: stopServer");

	[self.httpServer stop];
	[self.raopServer stop];

}

- (NSWindow *)window{
    if (_window) {
        _window = [[NSWindow alloc] init];
        [_window center];
        [_window makeKeyWindow];
    }
    return _window;
}

- (void)play:(NSURL *)location atRelativePosition:(float)position
{
	DDLogVerbose(@"AirPlayController: play %@", location);

	dispatch_async(dispatch_get_main_queue(), ^{
		if (self.anAVPlayerView == nil) {
            self.anAVPlayerView = [[AVPlayerView alloc] init];
            
		}
        
        self.anAVPlayer = [[AVPlayer alloc] initWithURL:location];
        self.anAVPlayerView.player = self.anAVPlayer;
		self.start_position = position;
        self.window.contentView = self.anAVPlayerView;
		
		[self.anAVPlayer play];
	});
}



- (void)stopPlayer
{
	DDLogVerbose(@"AirPlayController: stop player");

	[self.anAVPlayer pause];
    [self.window close];
    self.start_position = 0;
}

- (void)stop
{
	DDLogVerbose(@"AirPlayController: stop");

	dispatch_sync(dispatch_get_main_queue(), ^{
		[self stopPlayer];
	});
}

- (void)setPosition:(float)position
{
    DDLogWarn(@"AirPlayController: set position %f", position);
}

- (float)position
{
	__block float position;

	dispatch_sync(dispatch_get_main_queue(), ^{
		position = (float) CMTimeGetSeconds(self.anAVPlayer.currentTime);
	});

	return position;
}

- (NSTimeInterval)duration
{
	__block NSTimeInterval duration;

	if (_anAVPlayer == nil)
		return 0;

	dispatch_sync(dispatch_get_main_queue(), ^{
		duration = CMTimeGetSeconds(self.anAVPlayer.currentItem.duration);
	});

	return duration;
}

- (void)setRate:(float)value
{
    DDLogVerbose(@"AirPlayController: rate %f", value);

	dispatch_async(dispatch_get_main_queue(), ^{
		self.anAVPlayer.rate = value;
	});
}

- (void)dealloc
{
	DDLogVerbose(@"AirPlayController: release");
}

@end
