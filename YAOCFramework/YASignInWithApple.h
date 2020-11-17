//
//  YASignInWithApple.h
//  YAOCFramework
//
//  Created by app-01 on 2020/11/17.
//  Copyright © 2020 app-01 org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^YASignInWithAppleAction)(bool flag, NSDictionary * _Nullable dic);

@interface YASignInWithApple : UIViewController

- (void)perfomExistingAccountSetupFlows:(YASignInWithAppleAction)completeAction;

@end

NS_ASSUME_NONNULL_END
