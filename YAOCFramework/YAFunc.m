//
//  YAFunc.m
//  YAOCFramework
//
//  Created by app-01 on 2020/6/19.
//  Copyright © 2020 app-01 org. All rights reserved.
//

#import "YAFunc.h"
#import <sys/utsname.h>

NSString* deviceName()
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

@implementation YAFunc
+ (NSString *)deviceName {
    return deviceName();
}
@end
