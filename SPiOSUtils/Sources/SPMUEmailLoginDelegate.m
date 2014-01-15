//
//  SPMUEmailLoginDelegate.m
//  TrackMyBattery
//
//  Created by Panyam, Sriram on 12/3/13.
//  Copyright (c) 2013 Panyam. All rights reserved.
//

#import "SPMobileUtils.h"

#define AUTH_FIRSTNAME_KEY   @"auth_firstname"
#define AUTH_LASTNAME_KEY   @"auth_lastname"
#define AUTH_EMAIL_KEY   @"auth_email"
#define AUTH_PASSWORD_KEY   @"auth_password"
#define AUTH_SESSIONID_KEY   @"auth_sessionid"
#define AUTH_USERID_KEY   @"auth_userid"

@interface SPMUEmailLoginDelegate()

@property (nonatomic, strong) SPMUDefaultEmailLoginView *defaultLoginView;
@property (nonatomic, strong) SPMUWindow *holderWindow;
@property (nonatomic, copy) SPMUCallbackHandler currentLoginHandler;

@end

@implementation SPMUEmailUser : SPMUUser

-(NSString *)password { return [self objectForKey:@"password"]; };
-(void)setPassword:(NSString *)password { [self setObject:password forKey:@"password"]; };
-(NSString *)sessiondId { return [self objectForKey:@"sessionId"]; };
-(void)setSessionId:(NSString *)sessionId { [self setObject:sessionId forKey:@"sessionId"]; };

@end

@implementation SPMUEmailLoginDelegate

@synthesize loggedInUser;

@synthesize defaultLoginView;
@synthesize holderWindow;
@synthesize currentLoginHandler;

-(id)init
{
    if ((self = [super init]))
    {
        if (self.holderWindow == nil)
            self.holderWindow = [[SPMUWindow alloc] initWithFrame:CGRectZero];
        self.defaultLoginView = [[[NSBundle mainBundle] loadNibNamed:@"SPMUDefaultEmailLoginView"
                                                               owner:self options:nil] objectAtIndex:0];
        self.defaultLoginView.loginDelegate = self;
    }
    return self;
}

-(void)dealloc
{
    self.holderWindow = nil;
    self.defaultLoginView = nil;
}

-(BOOL)isLoggedInWithPermissions:(NSArray *)permissions;
{
    if (self.loggedInUser == nil)
    {
        NSString *email = [[NSUserDefaults standardUserDefaults] stringForKey:AUTH_EMAIL_KEY];
        NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:AUTH_PASSWORD_KEY];
        NSString *sessiondId = [[NSUserDefaults standardUserDefaults] stringForKey:AUTH_SESSIONID_KEY];
        NSString *userId = [[NSUserDefaults standardUserDefaults] stringForKey:AUTH_USERID_KEY];
        if (email.length > 0 && password.length > 0 && sessiondId.length > 0 && userId.length > 0)
        {
            SPMUEmailUser *user = [[SPMUEmailUser alloc] init];
            user.domain = @"email";
            user.password = password;
            user.sessionId = sessiondId;
            user.userid = userId;
            user.email = email;
            self.loggedInUser = user;
        }
    }
    return self.loggedInUser != nil;
}

-(void)ensureLoginWithPermissions:(NSArray *)permissions onCompletion:(SPMUCallbackHandler)handler
{
    // See if we have a user associated with this
    if (self.loggedInUser == nil)
    {
        // see if can load and login a user from user preferences
        NSString *email = [[NSUserDefaults standardUserDefaults] stringForKey:AUTH_EMAIL_KEY];
        NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:AUTH_PASSWORD_KEY];
        if (email.length > 0 && password.length > 0)
        {
            handler = [handler copy];
            [SPMU_ACTIVITY_INDICATOR showWithMessage:@"Logging In..."];
            [self loginWithEmail:email
                    withPassword:password
                         newUser:NO
                     withHandler:
             ^(id result, NSError *error)
             {
                 self.loggedInUser = result;
                 [SPMU_ACTIVITY_INDICATOR hide];
                 if (error.domain == SPMUUserErrorDomain)
                 {
                     [self kickOffLoginWithEmail:email
                                       withPassword:password
                                         withStatus:nil
                                        withHandler:handler];
                 }
                 else
                 {
                     handler(result, error);
                 }
             }];
        }
        else
        {
            [self kickOffLoginWithEmail:email
                           withPassword:password
                             withStatus:nil
                            withHandler:handler];
        }
    }
    else
    {
        handler(self.loggedInUser, nil);
    }
}

-(void)loginWithEmail:(NSString *)email
         withPassword:(NSString *)password
              newUser:(BOOL)newuser
          withHandler:(SPMUCallbackHandler)handler
{
}

-(void)ensureReadPermissions:(NSArray *)permissions onCompletion:(SPMUCallbackHandler)handler
{
    if (handler)
        handler(nil, nil);
}

-(void)ensureWritePermissions:(NSArray *)permissions onCompletion:(SPMUCallbackHandler)handler
{
    {
        if (handler)
            handler(nil, nil);
    }
}

-(void)logout:(SPMUCallbackHandler)handler
{
    self.loggedInUser = nil;
    commitToStandardUserDefaults(^(NSUserDefaults *user_defaults) {
        [user_defaults setValue:@"" forKey:AUTH_FIRSTNAME_KEY];
        [user_defaults setValue:@"" forKey:AUTH_LASTNAME_KEY];
        [user_defaults setValue:@"" forKey:AUTH_SESSIONID_KEY];
        [user_defaults setValue:@"" forKey:AUTH_USERID_KEY];
        [user_defaults setValue:@"" forKey:AUTH_EMAIL_KEY];
        [user_defaults setValue:@"" forKey:AUTH_PASSWORD_KEY];
    });
    if (handler)
        handler(nil, nil);
}

-(void)kickOffLoginWithEmail:(NSString *)email
                withPassword:(NSString *)password
                  withStatus:(NSString *)status
                 withHandler:(SPMUCallbackHandler)handler
{
    // show the login window (if not already visible) and populate with email/password
    if (email == nil) email = @"";
    if (password == nil) password = @"";
    self.defaultLoginView.emailField.text = email;
    self.defaultLoginView.passwordField.text = password;
    self.defaultLoginView.statusLabel.text = @"";
    self.currentLoginHandler = handler;
    [self.holderWindow presentView:self.defaultLoginView];
}


-(void)hideWithResult:(id)result withError:(NSError *)error
{
    [self.holderWindow dismissViewAnimated:NO];
    if (self.currentLoginHandler != nil)
        self.currentLoginHandler(result, error);
    self.currentLoginHandler = nil;
}

-(void)loginView:(UIView *)loginView
    stateChanged:(SPMUEmailLoginViewState)loginState
        withData:(id)data
       withError:(NSError *)error
{
    if (loginState == SPMUEmailLoginViewStateCancelled)
    {
        [self hideWithResult:data withError:error];
    }
    else if (loginState == SPMUEmailLoginViewStateLogInSucceeded)
    {
        // save the login details and dismiss
        self.loggedInUser = data;
        [self hideWithResult:data withError:error];
    }
}

@end
