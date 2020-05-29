//
//  YAUncaughtExceptionHandler.m
//  YAOCFramework
//
//  Created by app-01 on 2020/5/28.
//  Copyright © 2020 app-01 org. All rights reserved.
//

#import "YAUncaughtExceptionHandler.h"

NSString *applicationDocumentsDirectory() {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}
   
void UncaughtExceptionHandler(NSException *exception) {
     NSArray *arr = [exception callStackSymbols];
     NSString *reason = [exception reason];
     NSString *name = [exception name];
   
//     NSString *url = [NSString stringWithFormat:@"=============异常崩溃报告=============\nname:\n%@\nreason:\n%@\ncallStackSymbols:\n%@",
//                   name,reason,[arr componentsJoinedByString:@"\n"]];
     NSDictionary *dic  = @{@"name":name,@"reson":reason,@"callStackSymbols":[arr componentsJoinedByString:@"\n"]};
     NSString *path = [applicationDocumentsDirectory() stringByAppendingPathComponent:@"Exception.txt"];
//     [ writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [[NSJSONSerialization dataWithJSONObject:dic options:0 error:nil] writeToFile:path atomically:YES];
}

@implementation YAUncaughtExceptionHandler

//#if POD_CONFIGURATION_DEBUG
//+ (void)load {
//    if (@available(iOS 10.0, *)) {
//        [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:NO block:^(NSTimer * _Nonnull timer) {
//            [YAUncaughtExceptionHandler setDefaultHandler];
//        }];
//
//    } else {
//        // Fallback on earlier versions
//    }
//}
//#endif
   
+ (void)setDefaultHandler:(NSString *)urlstr
{
     NSSetUncaughtExceptionHandler (&UncaughtExceptionHandler);
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *path = [applicationDocumentsDirectory() stringByAppendingPathComponent:@"Exception.txt"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            NSData *data = [NSData dataWithContentsOfFile:path];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            NSURLSession *session = [NSURLSession sharedSession];
            NSURL *url = [NSURL URLWithString:urlstr];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                                   cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                               timeoutInterval:60.0];
            
            [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            [request addValue:@"*/*" forHTTPHeaderField:@"Accept"];
            
            [request setHTTPMethod:@"POST"];
            //        NSDictionary *myDictionary = @{@"version":@"1.1.2",@"table":@"iosException"};
            NSString *str = [NSString stringWithFormat:@"{\"version\":\"%@\",\"table\":\"iosException\",\"name\":\"%@\",\"callStackSymbols\":\"%@\"}", @"1.1.2", dic[@"name"],dic[@"callStackSymbols"]];
            NSURLComponents *components = [NSURLComponents new];
            components.queryItems = @[[NSURLQueryItem queryItemWithName:@"row" value:str]];
            NSLog(@"query-- %@", components.query);
            [request setHTTPBody:[components.query dataUsingEncoding:NSUTF8StringEncoding]];
            
            NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                NSLog(@"response %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                //            NSLog(@"response %@ error %@", response,error);
            }];
            
            [postDataTask resume];
            
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }

    });
}
   
+ (NSUncaughtExceptionHandler*)getHandler
{
     return NSGetUncaughtExceptionHandler();
}

@end
