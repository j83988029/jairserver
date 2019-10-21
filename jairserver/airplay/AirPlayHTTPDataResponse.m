//
//  AirPlayHTTPDataResponse.m
//  jairserver
//
//  Created by jiangjie on 2019/10/15.
//  Copyright © 2019 app. All rights reserved.
//

#import "AirPlayHTTPDataResponse.h"

@interface AirPlayHTTPDataResponse ()

@property(nonatomic, strong) NSMutableDictionary *httpHeadersDict;

@end

@implementation AirPlayHTTPDataResponse

- (NSDictionary *)httpHeaders{
    return self.httpHeadersDict;
}

- (NSMutableDictionary *)httpHeadersDict{
    if (!_httpHeadersDict) {
        _httpHeadersDict = @{}.mutableCopy;
    }
    return _httpHeadersDict;
}


@end
