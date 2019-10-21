//
//  DDViewLog.m
//  jairserver
//
//  Created by jiangjie on 2019/10/16.
//  Copyright © 2019 app. All rights reserved.
//

#import "DDViewLogger.h"

@implementation DDViewLogger
static DDViewLogger *sharedInstance;

+ (instancetype)sharedInstance {
    static dispatch_once_t DDOSLoggerOnceToken;
    
    dispatch_once(&DDOSLoggerOnceToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    
    return sharedInstance;
}

- (void)logMessage:(DDLogMessage *)logMessage{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"APLogNotification" object:nil userInfo:@{@"log":logMessage.message?:@""}];
}


@end
