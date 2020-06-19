//
//  UploadDataToServer.m
//  YAOCFramework
//
//  Created by app-01 on 2020/6/18.
//  Copyright © 2020 app-01 org. All rights reserved.
//

#import "UploadDataToServer.h"
#import <UIKit/UIKit.h>
#import <sys/utsname.h>
#import "YAFunc.h"

@implementation UploadDataToServer

+ (void)upload:(NSString *)urlstr msg:(NSString *)msg {
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:urlstr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"*/*" forHTTPHeaderField:@"Accept"];
    [request setHTTPMethod:@"POST"];
    
    NSMutableDictionary *mutableDic = [NSMutableDictionary dictionary];
    [mutableDic setValue:@"voiceError" forKey:@"table"];
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *appBuildVersion = [infoDic objectForKey:@"CFBundleShortVersionString"];
    [mutableDic setValue:appBuildVersion forKey:@"version"];
    [mutableDic setValue:[UIDevice currentDevice].systemVersion forKey:@"ios"];
    [mutableDic setValue:[UIDevice currentDevice].name forKey:@"deviceName"];
    [mutableDic setValue:[YAFunc deviceName] forKey:@"model"];
    [mutableDic setValue:msg forKey:@"error"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:mutableDic
    options:0
      error:nil];
    NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSURLComponents *components = [NSURLComponents new];
    components.queryItems = @[[NSURLQueryItem queryItemWithName:@"row" value:str]];
    NSLog(@"query-- %@", components.query);
    [request setHTTPBody:[components.query dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"response %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }];
    
    [postDataTask resume];
}

@end
