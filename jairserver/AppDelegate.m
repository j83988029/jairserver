//
//  AppDelegate.m
//  jairserver
//
//  Created by jiangjie on 2019/10/12.
//  Copyright © 2019 app. All rights reserved.
//

#import "AppDelegate.h"
#import <CocoaLumberjack/CocoaLumberjack.h>
#import "DDViewLogger.h"

@interface AppDelegate ()

@end


@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
#if DEBUG
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
#endif
    [DDLog addLogger:[DDViewLogger sharedInstance]];
    
    if (self.airplay == nil) self.airplay = [[AirPlayController alloc] init];
    
    [self.airplay startServer];
    
    
}

- (void)applicationDidBecomeActive:(NSNotification *)notification{
    
   
    
}

-(void)applicationWillResignActive:(NSNotification *)notification{
    [self.airplay stopPlayer];
    [self.airplay stopServer];
    self.airplay = nil;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
