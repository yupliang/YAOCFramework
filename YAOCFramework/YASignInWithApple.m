//
//  YASignInWithApple.m
//  YAOCFramework
//
//  Created by app-01 on 2020/11/17.
//  Copyright © 2020 app-01 org. All rights reserved.
//

#import "YASignInWithApple.h"
#import <AuthenticationServices/AuthenticationServices.h>

typedef void (^CleanAction) (void);

API_AVAILABLE(ios(13.0))
@interface YASignInWithApple ()<ASAuthorizationControllerDelegate,ASAuthorizationControllerPresentationContextProviding> {
    ASAuthorizationController *authorizationController;
    UIWindow *window;
}

@property (nonatomic,copy) YASignInWithAppleAction completeAction;
@property (nonatomic,copy) CleanAction cleanAction;

@end

@implementation YASignInWithApple

- (instancetype)init
{
    self = [super init];
    if (self) {
        window = nil;
        for (int i=0; i<[UIApplication sharedApplication].windows.count; i++) {
            if ([UIApplication sharedApplication].windows[i].isKeyWindow) {
                window = [UIApplication sharedApplication].windows[i];
            }
        }
        NSParameterAssert(window);
        [window.rootViewController.view addSubview:self.view];
        [window.rootViewController addChildViewController:self];
        NSLog(@"parent %@", self.parentViewController);
        __weak YASignInWithApple *weakself = self;
        self.cleanAction = ^{
            [weakself removeFromParentViewController];
            [weakself.view removeFromSuperview];
        };
    }
    return self;
}

- (void)loadView {
    [super loadView];
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)perfomExistingAccountSetupFlows:(YASignInWithAppleAction)completeAction API_AVAILABLE(ios(13.0))
{
    NSLog(@"%s", __FUNCTION__);
    self.completeAction = completeAction;
    ASAuthorizationAppleIDProvider *appleIDProvider = [ASAuthorizationAppleIDProvider new];
    ASAuthorizationAppleIDRequest *authAppleIDRequest = [appleIDProvider createRequest];
    authAppleIDRequest.requestedScopes = @[ASAuthorizationScopeFullName, ASAuthorizationScopeEmail];
//    ASAuthorizationPasswordRequest *passwordRequest = [[ASAuthorizationPasswordProvider new] createRequest];
    NSMutableArray <ASAuthorizationRequest *>* array = [NSMutableArray arrayWithCapacity:2];
    if (authAppleIDRequest) {
        [array addObject:authAppleIDRequest];
    }
//    if (passwordRequest) {
//        [array addObject:passwordRequest];
//    }
    NSArray <ASAuthorizationRequest *>* requests = [array copy];
    
    authorizationController = [[ASAuthorizationController alloc] initWithAuthorizationRequests:requests];
    authorizationController.delegate = self;
    authorizationController.presentationContextProvider = self;
    [authorizationController performRequests];
}

#pragma mark - ASAuthorizationControllerDelegate

- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithAuthorization:(ASAuthorization *)authorization API_AVAILABLE(ios(13.0))
{
    NSLog(@"%s", __FUNCTION__);
//    if ([authorization.credential isKindOfClass:[ASPasswordCredential class]]) {
//        ASPasswordCredential *passwordCredential = authorization.credential;
//        NSString *userIdentifier = passwordCredential.user;
//        NSString *password = passwordCredential.password;
//
//        NSLog(@"userIdentifier: %@", userIdentifier);
//        NSLog(@"password: %@", password);
//    } else
    NSDictionary *dic = @{@"success":@"0"};
    if ([authorization.credential isKindOfClass:[ASAuthorizationAppleIDCredential class]])       {
        ASAuthorizationAppleIDCredential *credential = authorization.credential;
        
        NSString *state = credential.state;
        NSString *userID = credential.user;
        NSString *fullName = credential.fullName.givenName;
        NSString *email = credential.email;
        NSString *authorizationCode = [[NSString alloc] initWithData:credential.authorizationCode encoding:NSUTF8StringEncoding]; // refresh token
        NSString *identityToken = [[NSString alloc] initWithData:credential.identityToken encoding:NSUTF8StringEncoding]; // access token
        ASUserDetectionStatus realUserStatus = credential.realUserStatus;
        
        NSLog(@"state: %@", state);
        NSLog(@"userID: %@", userID);
        NSLog(@"fullName: %@", fullName);
        NSLog(@"email: %@", email);
        NSLog(@"authorizationCode: %@", authorizationCode);
        NSLog(@"identityToken: %@", identityToken);
        NSLog(@"realUserStatus: %@", @(realUserStatus));
        if (fullName == nil) fullName = @"";
        if (email == nil) email = @"";
        dic = @{@"name":fullName, @"email":email,@"success":@"1",@"userid":userID};
    }
    self.cleanAction();
    self.completeAction(true, dic);
}

#pragma mark - ASAuthorizationControllerDelegate

- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithError:(NSError *)error API_AVAILABLE(ios(13.0))
{
    NSLog(@"%s", __FUNCTION__);
    NSString *errorMsg = nil;
    switch (error.code) {
        case ASAuthorizationErrorCanceled:
            errorMsg = @"用户取消了授权请求";
            break;
        case ASAuthorizationErrorFailed:
            errorMsg = @"授权请求失败";
            break;
        case ASAuthorizationErrorInvalidResponse:
            errorMsg = @"授权请求响应无效";
            break;
        case ASAuthorizationErrorNotHandled:
            errorMsg = @"未能处理授权请求";
            break;
        case ASAuthorizationErrorUnknown:
            errorMsg = @"授权请求失败未知原因";
            break;
    }
    NSLog(@"%@", errorMsg);
    NSDictionary *dic = @{@"success":@"0"};
    self.cleanAction();
    self.completeAction(false, dic);
}

- (nonnull ASPresentationAnchor)presentationAnchorForAuthorizationController:(nonnull ASAuthorizationController *)controller  API_AVAILABLE(ios(13.0)){
    NSLog(@"window %@", window);
    return window;
}

@end
