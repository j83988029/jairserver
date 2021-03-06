//
//  AirPlayHTTPConnection.m
//  AirView
//
//  Created by Clément Vasseur on 12/15/10.
//  Copyright 2010 Clément Vasseur. All rights reserved.
//

#import <Foundation/NSCharacterSet.h>
#import "AirPlayHTTPConnection.h"
#import "HTTPMessage.h"
#import "HTTPDataResponse.h"
#import "HTTPReverseResponse.h"
#import "HTTPLogging.h"
#import "AirPlayHTTPDataResponse.h"

// Log levels : off, error, warn, info, verbose
// Other flags: trace
static const int httpLogLevel = HTTP_LOG_LEVEL_VERBOSE; // | HTTP_LOG_FLAG_TRACE;

@implementation AirPlayHTTPConfig

@synthesize airplay;

- (id)initWithServer:(HTTPServer *)aServer
        documentRoot:(NSString *)aDocumentRoot
               queue:(dispatch_queue_t)q
             airplay:(AirPlayController *)airplayController
{
	if ((self = [super init]))
	{
		server = aServer;
    
		documentRoot = [aDocumentRoot stringByStandardizingPath];
		if ([documentRoot hasSuffix:@"/"]) {
			documentRoot = [documentRoot stringByAppendingString:@"/"];
		}
    
		if (q) {
			queue = q;
		}
    
		airplay = airplayController;
	}
	return self;
}
@end

@implementation AirPlayHTTPConnection

- (AirPlayController *)airplay
{
	AirPlayHTTPConfig *cfg = [config isKindOfClass:[AirPlayHTTPConfig class]] ? (id)config : nil;
	return cfg.airplay;
}

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path
{
	HTTPLogTrace();
  
	// Add support for GET
  
	if ([method isEqualToString:@"GET"])
	{
		if ([path isEqualToString:@"/scrub"])
			return YES;
    
    if ([path isEqualToString:@"/server-info"])
			return YES;

    if ([path isEqualToString:@"/slideshow-features"])
			return YES;

  }
  
	// Add support for POST
  
	if ([method isEqualToString:@"POST"])
	{
		if ([path isEqualToString:@"/reverse"] ||
		    [path isEqualToString:@"/play"] ||
		    [path isEqualToString:@"/stop"] ||
			  [path hasPrefix:@"/scrub?position="] ||
            [path hasPrefix:@"/rate?value="]||
            [path hasPrefix:@"/getProperty?playbackAccessLog"]||
            [path hasPrefix:@"/getProperty?playbackErrorLog"])
			return YES;
	}
  
	// Add support for PUT
  
	if ([method isEqualToString:@"PUT"])
	{
		if ([path isEqualToString:@"/photo"]||
            [path hasPrefix:@"/setProperty?forwardEndTime"]||
            [path hasPrefix:@"/setProperty?reverseEndTime"])
			return YES;
	}
  
	return [super supportsMethod:method atPath:path];
}

/**
 * This method is called after receiving all HTTP headers, but before reading any of the request body.
 **/
- (void)prepareForBodyWithSize:(UInt64)contentLength
{
	HTTPLogTrace();
  
	HTTPLogVerbose(@"prepareForBodyWithSize %qu", contentLength);
}


- (void)processDataChunk:(NSData *)postDataChunk
{
	HTTPLogTrace();
  
	// Remember: In order to support LARGE POST uploads, the data is read in chunks.
	// This prevents a 50 MB upload from being stored in RAM.
	// The size of the chunks are limited by the POST_CHUNKSIZE definition.
	// Therefore, this method may be called multiple times for the same POST request.
  
	BOOL result = [request appendData:postDataChunk];
	if (!result)
		HTTPLogError(@"%@[%p]: %@ - Couldn't append bytes!", THIS_FILE, self, THIS_METHOD);
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
	HTTPLogTrace();
	HTTPLogVerbose(@"%@[%p]: %@ (%qu) %@", THIS_FILE, self, method, requestContentLength, path);
  
	AirPlayController *airplay = [self airplay];
  
	if ([method isEqualToString:@"GET"] && [path isEqualToString:@"/scrub"])
	{
		NSString *str = [NSString stringWithFormat:@"duration: %f\nposition: %f\n",
                     airplay.duration, airplay.position];
		NSData *response = [str dataUsingEncoding:NSUTF8StringEncoding];
		AirPlayHTTPDataResponse *res = [[AirPlayHTTPDataResponse alloc] initWithData:response];
		[res.httpHeadersDict setObject:@"text/parameters" forKey:@"Content-Type"];
		return res ;
	}
  
  if ([method isEqualToString:@"GET"] && [path isEqualToString:@"/server-info"])
	{
		NSString *str = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?><!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\"><plist version=\"1.0\"><dict><key>deviceid</key><string>58:55:CA:06:BD:9E</string><key>features</key><integer>119</integer><key>model</key><string>AppleTV2,1</string><key>protovers</key><string>1.0</string><key>srcvers</key><string>101.10</string></dict></plist>";
    
		NSData *response = [str dataUsingEncoding:NSUTF8StringEncoding];
		AirPlayHTTPDataResponse *res = [[AirPlayHTTPDataResponse alloc] initWithData:response];
		[res.httpHeadersDict setObject:@"text/x-apple-plist+xml" forKey:@"Content-Type"];
		return res ;
	}

  if ([method isEqualToString:@"GET"] && [path isEqualToString:@"/slideshow-features"])
	{
		NSString *str = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?><!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\"><plist version=\"1.0\"><dict><key>themes</key><array>    <dict>    <key>key</key>    <string>KenBurns</string>    <key>name</key>    <string>Ken Burns</string>    <key>transitions</key>    <array> <dict> <key>key</key> <string>None</string> <key>name</key> <string>None</string> </dict> <dict> <key>directions</key> <array> <string>up</string> <string>down</string> <string>left</string> <string>down</string> </array> <key>key</key> <string>Cube</string> <key>name</key> <string>Cube</string> </dict> <dict> <key>key</key> <string>Dissolve</string> <key>name</key> <string>Dissolve</string> </dict> <dict> <key>key</key> <string>Droplet</string> <key>name</key> <string>Droplet</string> </dict> <dict> <key>key</key> <string>FadeThruColor</string> <key>name</key> <string>Fade Through White</string> </dict> <dict> <key>directions</key> <array> <string>up</string> <string>down</string> <string>left</string> <string>down</string> </array> <key>key</key> <string>Flip</string> <key>name</key> <string>Flip</string> </dict> <dict> <key>key</key> <string>TileFlip</string> <key>name</key> <string>Mosaic Flip</string> </dict> <dict> <key>directions</key> <array> <string>up</string> <string>down</string> <string>left</string> <string>down</string> </array> <key>key</key> <string>MoveIn</string> <key>name</key> <string>Move In</string> </dict> <dict> <key>directions</key> <array> <string>left</string> <string>down</string> </array> <key>key</key> <string>PageFlip</string> <key>name</key> <string>Page Flip</string> </dict> <dict> <key>directions</key> <array> <string>up</string> <string>down</string> <string>left</string> <string>down</string> </array> <key>key</key> <string>Push</string> <key>name</key> <string>Push</string> </dict> <dict> <key>directions</key> <array> <string>up</string> <string>down</string> <string>left</string> <string>down</string> </array> <key>key</key> <string>Reveal</string> <key>name</key> <string>Reveal</string> </dict> <dict> <key>key</key> <string>Twirl</string> <key>name</key> <string>Twirl</string> </dict> <dict> <key>directions</key> <array> <string>up</string> <string>down</string> <string>left</string> <string>down</string> </array> <key>key</key> <string>Wipe</string> <key>name</key> <string>Wipe</string> </dict>    </array>    </dict>    <dict>    <key>key</key>    <string>Origami</string>    <key>name</key>    <string>Origami</string>    </dict>    <dict>    <key>key</key>    <string>Reflections</string>    <key>name</key>    <string>Reflections</string>    </dict>    <dict>    <key>key</key>    <string>Snapshots</string>    <key>name</key>    <string>Snapshots</string>    </dict>    <dict>    <key>key</key>    <string>Classic</string>    <key>name</key>    <string>Classic</string>    <key>transitions</key>    <array> <dict> <key>key</key> <string>None</string> <key>name</key> <string>None</string> </dict> <dict> <key>directions</key> <array> <string>up</string> <string>down</string> <string>left</string> <string>down</string> </array> <key>key</key> <string>Cube</string> <key>name</key> <string>Cube</string> </dict> <dict> <key>key</key> <string>Dissolve</string> <key>name</key> <string>Dissolve</string> </dict> <dict> <key>key</key> <string>Droplet</string> <key>name</key> <string>Droplet</string> </dict> <dict> <key>key</key> <string>FadeThruColor</string> <key>name</key> <string>Fade Through White</string> </dict> <dict> <key>directions</key> <array> <string>up</string> <string>down</string> <string>left</string> <string>down</string> </array> <key>key</key> <string>Flip</string> <key>name</key> <string>Flip</string> </dict> <dict> <key>key</key> <string>TileFlip</string> <key>name</key> <string>Mosaic Flip</string> </dict> <dict> <key>directions</key> <array> <string>up</string> <string>down</string> <string>left</string> <string>down</string> </array> <key>key</key> <string>MoveIn</string> <key>name</key> <string>Move In</string> </dict> <dict> <key>directions</key> <array> <string>left</string> <string>down</string> </array> <key>key</key> <string>PageFlip</string> <key>name</key> <string>Page Flip</string> </dict> <dict> <key>directions</key> <array> <string>up</string> <string>down</string> <string>left</string> <string>down</string> </array> <key>key</key> <string>Push</string> <key>name</key> <string>Push</string> </dict> <dict> <key>directions</key> <array> <string>up</string> <string>down</string> <string>left</string> <string>down</string> </array> <key>key</key> <string>Reveal</string> <key>name</key> <string>Reveal</string> </dict> <dict> <key>key</key> <string>Twirl</string> <key>name</key> <string>Twirl</string> </dict> <dict> <key>directions</key> <array> <string>up</string> <string>down</string> <string>left</string> <string>down</string> </array> <key>key</key> <string>Wipe</string> <key>name</key> <string>Wipe</string> </dict>    </array>    </dict></array></dict></plist>";
    
		NSData *response = [str dataUsingEncoding:NSUTF8StringEncoding];
		AirPlayHTTPDataResponse *res = [[AirPlayHTTPDataResponse alloc] initWithData:response];
		[res.httpHeadersDict setObject:@"text/x-apple-plist+xml" forKey:@"Content-Type"];
		return  res  ;
	}
  
  	if ([method isEqualToString:@"PUT"])
    {
        if ([path isEqualToString:@"/photo"])
        {
            HTTPLogVerbose(@"%@[%p]: PUT (%qu) %@", THIS_FILE, self, requestContentLength, path);
            
            return [ [AirPlayHTTPDataResponse alloc] initWithData:nil ];
        }
        else if ([path isEqualToString:@"/setProperty?forwardEndTime"])
        {
            NSError *error;
            NSDictionary *dict = (NSDictionary *)[NSPropertyListSerialization propertyListWithData:[request body] options:NSPropertyListImmutable format:nil error:&error];
            HTTPLogVerbose(@"%@[%p]: PUT (%qu) %@\n%@\n%@\n", THIS_FILE, self, requestContentLength, path, [dict description], error);
            return [ [AirPlayHTTPDataResponse alloc] initWithData:nil ];
        }
        else if ([path isEqualToString:@"/setProperty?reverseEndTime"])
        {
            // In iOS 5 this command is accompanied by a dictionary 
            //{
            //  value =     {
            //    epoch = 0;
            //    flags = 0;
            //    timescale = 0;
            //    value = 0;
            //};}
            
            NSError *error;
            NSDictionary *dict = (NSDictionary *)[NSPropertyListSerialization propertyListWithData:[request body] options:NSPropertyListImmutable format:nil error:&error];
            HTTPLogVerbose(@"%@[%p]: PUT (%qu) %@\n%@\n%@\n", THIS_FILE, self, requestContentLength, path, [dict description], error);
            return [ [AirPlayHTTPDataResponse  alloc] initWithData:nil ];
        }
        
    }
  
	if (![method isEqualToString:@"POST"])
		return [super httpResponseForMethod:method URI:path];
  
	if ([path isEqualToString:@"/reverse"])
	{
		return [ [AirPlayHTTPDataResponse alloc] init]  ;
	}
	else if ([path hasPrefix:@"/scrub?position="])
	{
		NSString *str = [path substringFromIndex:16];
		float value = [str floatValue];
		[airplay setPosition:value];
    
		return [ [AirPlayHTTPDataResponse alloc] initWithData:nil]  ;
	}
	else if ([path hasPrefix:@"/rate?value="])
	{
		NSString *str = [path substringFromIndex:12];
		float value = [str floatValue];
		[airplay setRate:value];
    
		return [ [AirPlayHTTPDataResponse alloc] initWithData:nil]  ;
	}
    else if ([path isEqualToString:@"/getProperty?playbackAccessLog"])
    {
        HTTPLogVerbose(@"%@[%p]: POST (%qu) %@", THIS_FILE, self, requestContentLength, path);
        return [ [AirPlayHTTPDataResponse alloc] initWithData:nil] ;
    }
    else if ([path isEqualToString:@"/getProperty?playbackErrorLog"])
    {
        HTTPLogVerbose(@"%@[%p]: POST (%qu) %@", THIS_FILE, self, requestContentLength, path);
        return [ [AirPlayHTTPDataResponse alloc] initWithData:nil]  ;
    }
	else if ([path isEqualToString:@"/stop"])
	{
		[airplay stop];
    
		return [[ AirPlayHTTPDataResponse alloc] initWithData:nil]  ;
	}
	else if ([path isEqualToString:@"/play"])
	{
		NSString *postStr = nil;
		NSData *postData = [request body];
		NSArray *headers;
		NSURL *url = nil;
		float start_position = 0;
    
		if (postData)
			postStr =  [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding ];
    
		headers = [postStr componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
		for (id h in headers) {
			NSArray *a = [h componentsSeparatedByString:@": "];
      
			if ([a count] >= 2) {
				NSString *key = [a objectAtIndex:0];
				NSString *value = [a objectAtIndex:1];
        
				if ([key isEqualToString:@"Content-Location"])
					url = [NSURL URLWithString:value];
				else if ([key isEqualToString:@"Start-Position"])
					start_position = [value floatValue];
			}
		}
    
		if (url)
			[airplay play:url atRelativePosition:start_position];
    
		return  [[AirPlayHTTPDataResponse alloc] initWithData:nil]  ;
	}
  
	return [super httpResponseForMethod:method URI:path];
}

@end
