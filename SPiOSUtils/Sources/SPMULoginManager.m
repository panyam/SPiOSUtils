//
//  SPMULoginManager.m
//  TrackMyBattery
//
//  Created by Panyam, Sriram on 12/3/13.
//  Copyright (c) 2013 Panyam. All rights reserved.
//

#import "SPMobileUtils.h"

const NSString *SPMU_DID_LOGIN = @"SPMU_DID_LOGIN";
const NSString *SPMU_LOGIN_FAILED = @"SPMU_LOGIN_FAILED";
const NSString *SPMU_DID_LOGOUT = @"SPMU_DID_LOGOUT_";
const NSString *SPMU_LOGOUT_FAILED = @"SPMU_DID_LOGOUT_FAILED";
const NSString *SPMU_READ_PERMISSIONS_GRANTED = @"SPMU_READ_PERMISSIONS_GRANTED";
const NSString *SPMU_READ_PERMISSIONS_DECLINED = @"SPMU_READ_PERMISSIONS_DECLINED";
const NSString *SPMU_WRITE_PERMISSIONS_GRANTED = @"SPMU_WRITE_PERMISSIONS_GRANTED";
const NSString *SPMU_WRITE_PERMISSIONS_DECLINED = @"SPMU_WRITE_PERMISSIONS_DECLINED";

@interface SPMULoginManager()

@property (nonatomic, strong) NSMutableDictionary *loginDelegatesByType;

@end

@implementation SPMULoginManager

@synthesize loginDelegatesByType;

-(id)init
{
    if ((self = [super init]))
    {
        self.loginDelegatesByType = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [[SPMUEmailLoginDelegate alloc] init], SPMU_LOGINTYPE_EMAIL,
                                     [[SPMUFacebookLoginDelegate alloc] init], SPMU_LOGINTYPE_FACEBOOK,
                                     nil];
    }
    return self;
}

-(void)setLoginDelegate:(id<SPMULoginDelegate>)loginDelegate forType:(NSString *)type
{
    [loginDelegatesByType setObject:loginDelegate forKey:type];
}

-(id<SPMULoginDelegate>)loginDelegateForType:(NSString *)type
{
    return [loginDelegatesByType objectForKey:type];
}

-(BOOL)isLoggedInForType:(NSString *)loginType withPermissions:(NSArray *)permissions
{
    return [[self loginDelegateForType:loginType] isLoggedInWithPermissions:permissions];
}
            
-(SPMUUser *)loggedInUserForType:(NSString *)type
{
    return [[self loginDelegateForType:type] loggedInUser];
}

-(void)setLoggedInUser:(SPMUUser *)user forType:(NSString *)type
{
    [[self loginDelegateForType:type] setLoggedInUser:user];
}

-(void)ensureLoginForType:(NSString *)loginType
          withPermissions:(NSArray *)permissions
             onCompletion:(SPMUCallbackHandler)handler
{
    if ([self isLoggedInForType:loginType withPermissions:permissions])
    {
        if (handler)
            handler([self loggedInUserForType:loginType], nil);
    }
    else
    {
        id<SPMULoginDelegate> loginDelegate = [self loginDelegateForType:loginType];
        handler = [handler copy];
        [loginDelegate ensureLoginWithPermissions:permissions onCompletion:
         ^(id result, NSError *error) {
             NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                       (result ? result : [NSNull null]), @"user",
                                       (error ? error : [NSNull null]), @"error",
                                       loginType, @"loginType",
                                       permissions, @"permissions",
                                       nil];
             NSString *message = (NSString *)(error ? SPMU_LOGIN_FAILED : SPMU_DID_LOGIN);
             [[NSNotificationCenter defaultCenter] postNotificationName:message
                                                                 object:self
                                                               userInfo:userInfo];
             if (handler)
                 handler(result, error);
         }];
    }
}

-(void)ensureReadPermissions:(NSArray *)permissions
                     forType:(NSString *)loginType
                onCompletion:(SPMUCallbackHandler)handler
{
    handler = [handler copy];
    [[self loginDelegateForType:loginType] ensureReadPermissions:permissions
                                                    onCompletion:
     ^(id result, NSError *error) {
         NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                   (result ? result : [NSNull null]), @"user",
                                   (error ? error : [NSNull null]), @"error",
                                   loginType, @"loginType",
                                   permissions, @"permissions",
                                   nil];
         NSString *message = (NSString *)(error ?
                                          SPMU_READ_PERMISSIONS_DECLINED :
                                          SPMU_READ_PERMISSIONS_GRANTED);
         [[NSNotificationCenter defaultCenter] postNotificationName:message
                                                             object:self
                                                           userInfo:userInfo];
         if (handler)
             handler(result, error);
     }];
}

-(void)ensureWritePermissions:(NSArray *)permissions
                      forType:(NSString *)loginType
                 onCompletion:(SPMUCallbackHandler)handler
{
    handler = [handler copy];
    [[self loginDelegateForType:loginType] ensureWritePermissions:permissions
                                                     onCompletion:
     ^(id result, NSError *error) {
         NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                   (result ? result : [NSNull null]), @"user",
                                   (error ? error : [NSNull null]), @"error",
                                   loginType, @"loginType",
                                   permissions, @"permissions",
                                   nil];
         NSString *message = (NSString *)(error ?
                                          SPMU_WRITE_PERMISSIONS_DECLINED :
                                          SPMU_WRITE_PERMISSIONS_GRANTED);
         [[NSNotificationCenter defaultCenter] postNotificationName:message
                                                             object:self
                                                           userInfo:userInfo];
         if (handler)
             handler(result, error);
     }];
}

-(void)logoutForType:(NSString *)type onCompletion:(SPMUCallbackHandler)handler
{
    handler = [handler copy];
    [[self loginDelegateForType:type] logout:^(id result, NSError *error) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  (result ? result : [NSNull null]), @"user",
                                  (error ? error : [NSNull null]), @"error",
                                  type, @"loginType",
                                  nil];
        NSString *message = (NSString *)(error ? SPMU_LOGOUT_FAILED : SPMU_DID_LOGOUT);
        [[NSNotificationCenter defaultCenter] postNotificationName:message
                                                            object:self
                                                          userInfo:userInfo];
        if (handler)
            handler(result, error);
    }];
}

@end
