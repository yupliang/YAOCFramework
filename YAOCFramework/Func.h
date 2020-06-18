//
//  Func.h
//  YAOCFramework
//
//  Created by app-01 on 2020/6/18.
//  Copyright © 2020 app-01 org. All rights reserved.
//

#ifndef Func_h
#define Func_h

NSString* deviceName()
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

#endif /* Func_h */
