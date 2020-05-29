//
//  YAUncaughtExceptionHandler.h
//  YAOCFramework
//
//  Created by app-01 on 2020/5/28.
//  Copyright © 2020 app-01 org. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YAUncaughtExceptionHandler : NSObject
+ (void)setDefaultHandler:(NSString *)url;
+ (NSUncaughtExceptionHandler*)getHandler;
@end

NS_ASSUME_NONNULL_END
