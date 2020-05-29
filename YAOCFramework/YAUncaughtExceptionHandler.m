//
//  YAUncaughtExceptionHandler.m
//  YAOCFramework
//
//  Created by app-01 on 2020/5/28.
//  Copyright © 2020 app-01 org. All rights reserved.
//

#import "YAUncaughtExceptionHandler.h"
#import <sys/utsname.h>

NSString *applicationDocumentsDirectory() {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}
   
void UncaughtExceptionHandler(NSException *exception) {
     NSArray *arr = [exception callStackSymbols];
     NSString *reason = [exception reason];
     NSString *name = [exception name];
   
    NSDictionary *dic  = @{@"name":name,@"reason":reason,@"callStackSymbols":[arr componentsJoinedByString:@"\n"]};
    NSString *path = [applicationDocumentsDirectory() stringByAppendingPathComponent:@"Exception.txt"];
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
   NSString* deviceName()
      {
          struct utsname systemInfo;
          uname(&systemInfo);

          return [NSString stringWithCString:systemInfo.machine
                                    encoding:NSUTF8StringEncoding];
      }

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
            
            NSMutableDictionary *mutableDic = [NSMutableDictionary dictionaryWithDictionary:dic];
            [mutableDic setValue:@"iosException" forKey:@"table"];
            NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
            NSString *appBuildVersion = [infoDic objectForKey:@"CFBundleShortVersionString"];
            [mutableDic setValue:appBuildVersion forKey:@"version"];
            [mutableDic setValue:[UIDevice currentDevice].systemVersion forKey:@"ios"];
            [mutableDic setValue:[UIDevice currentDevice].name forKey:@"deviceName"];
            [mutableDic setValue:deviceName() forKey:@"model"];
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
            
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }

    });
}
   
+ (NSUncaughtExceptionHandler*)getHandler
{
     return NSGetUncaughtExceptionHandler();
}

@end
