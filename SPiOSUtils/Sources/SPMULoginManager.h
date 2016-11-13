//
//  SPMULoginManager.h
//  TrackMyBattery
//
//  Created by Panyam, Sriram on 12/3/13.
//  Copyright (c) 2013 Panyam. All rights reserved.
//

#import "SPMUFwdDefs.h"

#define SPMU_LOGINTYPE_EMAIL        @"email"
#define SPMU_LOGINTYPE_FACEBOOK     @"facebook"
#define SPMU_LOGINTYPE_TWITTER      @"twitter"

extern const NSString *SPMU_DID_LOGIN;
extern const NSString *SPMU_LOGIN_FAILED;
extern const NSString *SPMU_DID_LOGOUT;
extern const NSString *SPMU_LOGOUT_FAILED;
extern const NSString *SPMU_READ_PERMISSIONS_GRANTED;
extern const NSString *SPMU_READ_PERMISSIONS_DECLINED;
extern const NSString *SPMU_WRITE_PERMISSIONS_GRANTED;
extern const NSString *SPMU_WRITE_PERMISSIONS_DECLINED;

@protocol SPMULoginDelegate

-(BOOL)isLoggedInWithPermissions:(NSArray *)permissions;
-(void)ensureLoginWithPermissions:(NSArray *)permissions onCompletion:(SPMUCallbackHandler)handler;
-(void)ensureReadPermissions:(NSArray *)permissions onCompletion:(SPMUCallbackHandler)handler;
-(void)ensureWritePermissions:(NSArray *)permissions onCompletion:(SPMUCallbackHandler)handler;
-(void)logout:(SPMUCallbackHandler)handler;
-(SPMUUser *)loggedInUser;
-(void)setLoggedInUser:(SPMUUser *)user;

@end

@interface SPMULoginManager : NSObject

-(void)setLoginDelegate:(id<SPMULoginDelegate>)loginDelegate forType:(NSString *)type;
-(id<SPMULoginDelegate>)loginDelegateForType:(NSString *)type;

-(SPMUUser *)loggedInUserForType:(NSString *)type;
-(void)setLoggedInUser:(SPMUUser *)user forType:(NSString *)type;

-(void)ensureLoginForType:(NSString *)loginType
          withPermissions:(NSArray *)permissions
             onCompletion:(SPMUCallbackHandler)handler;
-(BOOL)isLoggedInForType:(NSString *)loginType
        withPermissions:(NSArray *)permissions;
-(void)logoutForType:(NSString *)type
        onCompletion:(SPMUCallbackHandler)handler;
-(void)ensureReadPermissions:(NSArray *)permissions
                     forType:(NSString *)loginType
                onCompletion:(SPMUCallbackHandler)handler;
-(void)ensureWritePermissions:(NSArray *)permissions
                      forType:(NSString *)loginType
                 onCompletion:(SPMUCallbackHandler)handler;

@end
