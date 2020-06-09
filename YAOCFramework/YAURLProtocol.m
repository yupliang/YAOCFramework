//
//  YAURLProtocol.m
//  YAOCFramework
//
//  Created by app-01 on 2020/6/9.
//  Copyright © 2020 app-01 org. All rights reserved.
//

#import "YAURLProtocol.h"

@implementation YAURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    request = [self handlePostRequestBodyWithRequest:request];
    NSLog(@"YAURLProtocol - %@- body: %@", [[request URL] absoluteString], request.HTTPBody);
    id obj = [NSJSONSerialization JSONObjectWithData:request.HTTPBody options:nil error:nil];
    NSLog(@"obj - %@", obj);
    return false;
}

#pragma mark -
#pragma mark 处理POST请求相关POST  用HTTPBodyStream来处理BODY体
+ (NSMutableURLRequest *)handlePostRequestBodyWithRequest:(NSMutableURLRequest *)request {
    NSMutableURLRequest * req = [request mutableCopy];
    NSLog(@"-- %@", req.HTTPMethod);
    if ([request.HTTPMethod isEqualToString:@"POST"]) {
        if (!request.HTTPBody) {
            uint8_t d[1024] = {0};
            NSInputStream *stream = request.HTTPBodyStream;
            NSMutableData *data = [[NSMutableData alloc] init];
            [stream open];
            while ([stream hasBytesAvailable]) {
                NSInteger len = [stream read:d maxLength:1024];
                if (len > 0 && stream.streamError == nil) {
                    [data appendBytes:(void *)d length:len];
                }
            }
            req.HTTPBody = [data copy];
            [stream close];
        }
    }
    return req;
}


@end
