//
//  SPMUFacebookLoginDelegate.h
//
//  Created by Panyam, Sriram on 12/3/13.
//  Copyright (c) 2013 Panyam. All rights reserved.
//

#import "SPMUFwdDefs.h"
#import <FacebookSDK/FacebookSDK.h>

extern const NSString *SPMUFacebookErrorDomain;

typedef enum {
    SPMUFacebookErrorLoginFailed
} SPMUFacebookError;

@interface SPMUFacebookUser : SPMUUser<FBGraphUser>

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *link;
@property (nonatomic, strong) NSString *birthday;
@property (nonatomic, strong) FBSession *session;

-(id)initWithFBUser:(id<FBGraphUser>)user;

@end

@interface SPMUFacebookLoginDelegate : NSObject<SPMULoginDelegate>

@property (nonatomic, strong) SPMUFacebookUser *loggedInUser;

@end

