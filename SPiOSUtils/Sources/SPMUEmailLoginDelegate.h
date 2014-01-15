//
//  SPMUEmailLoginDelegate.h
//  TrackMyBattery
//
//  Created by Panyam, Sriram on 12/3/13.
//  Copyright (c) 2013 Panyam. All rights reserved.
//

#import "SPMUFwdDefs.h"

typedef enum {
    SPMUEmailLoginViewStateCancelled,
    SPMUEmailLoginViewStateLogInFailed,
    SPMUEmailLoginViewStateLogInSucceeded,
} SPMUEmailLoginViewState;

typedef void (^SPMUEmailLoginViewHandler)(UIView *loginview, SPMUEmailLoginViewState state, id data, NSError *error);

@interface SPMUEmailUser : SPMUUser

@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *sessionId;

@end

@protocol SPMUEmailLoginViewDelegate<NSObject>

@optional

-(void)loginWithEmail:(NSString *)email
         withPassword:(NSString *)password
              newUser:(BOOL)newuser
          withHandler:(SPMUCallbackHandler)handler;

-(void)loginView:(UIView *)loginView
    stateChanged:(SPMUEmailLoginViewState)loginState
        withData:(id)data
       withError:(NSError *)error;

@end

@interface SPMUEmailLoginDelegate : NSObject<SPMULoginDelegate, SPMUEmailLoginViewDelegate>

@property (nonatomic, strong) SPMUUser *loggedInUser;

@end
