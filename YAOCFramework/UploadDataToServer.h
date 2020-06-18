//
//  UploadDataToServer.h
//  YAOCFramework
//
//  Created by app-01 on 2020/6/18.
//  Copyright © 2020 app-01 org. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UploadDataToServer : NSObject
+ (void)upload:(NSString *)server msg:(NSString *)msg;
@end

NS_ASSUME_NONNULL_END
