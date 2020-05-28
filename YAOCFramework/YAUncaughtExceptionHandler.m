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
   
     NSString *url = [NSString stringWithFormat:@"=============异常崩溃报告=============\nname:\n%@\nreason:\n%@\ncallStackSymbols:\n%@",
                   name,reason,[arr componentsJoinedByString:@"\n"]];
     NSString *path = [applicationDocumentsDirectory() stringByAppendingPathComponent:@"Exception.txt"];
     [url writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

@implementation YAUncaughtExceptionHandler

//#ifdef DEBUG
+ (void)load {
    if (@available(iOS 10.0, *)) {
        [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:NO block:^(NSTimer * _Nonnull timer) {
            [YAUncaughtExceptionHandler setDefaultHandler];
        }];
    } else {
        // Fallback on earlier versions
    }
}
//#endif
   
+ (void)setDefaultHandler
{
     NSSetUncaughtExceptionHandler (&UncaughtExceptionHandler);
}
   
+ (NSUncaughtExceptionHandler*)getHandler
{
     return NSGetUncaughtExceptionHandler();
}

@end
