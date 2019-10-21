//
//  AirPlayHTTPDataResponse.h
//  jairserver
//
//  Created by jiangjie on 2019/10/15.
//  Copyright © 2019 app. All rights reserved.
//

#import "HTTPDataResponse.h"

NS_ASSUME_NONNULL_BEGIN

@interface AirPlayHTTPDataResponse : HTTPDataResponse

@property(nonatomic, strong, readonly) NSMutableDictionary *httpHeadersDict;


@end

NS_ASSUME_NONNULL_END
