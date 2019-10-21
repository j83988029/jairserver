//
//  DDViewLogger
//  jairserver
//
//  Created by jiangjie on 2019/10/16.
//  Copyright © 2019 app. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaLumberjack/CocoaLumberjack.h>

NS_ASSUME_NONNULL_BEGIN

@interface DDViewLogger : DDAbstractLogger<DDLogger>

+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
