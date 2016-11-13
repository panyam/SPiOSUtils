//
//  SPMUFacebookLoginDelegate.m
//
//  Created by Panyam, Sriram on 12/3/13.
//  Copyright (c) 2013 Panyam. All rights reserved.
//

#import "SPMobileUtils.h"

const NSString *SPMUFacebookErrorDomain = @"SPMUFacebookErrorDomain";

@implementation SPMUFacebookUser : SPMUUser

@synthesize session;

-(id)initWithFBUser:(id<FBGraphUser>)user
{
    if ((self = [super init]))
    {
        self.id = self.userid = user.id;
        self.username = user.username;
        self.name = user.name;
        self.first_name = user.first_name;
        self.middle_name = user.middle_name;
        self.last_name = user.last_name;
        self.link = user.link;
        self.birthday = user.birthday;
    }
    return self;
}

-(NSUInteger)count
{
    return self.propertyCount;
}

-(NSString *)id { return [self objectForKey:@"id"]; };
-(NSString *)link { return [self objectForKey:@"link"]; };
-(NSString *)birthday { return [self objectForKey:@"birthday"]; };

-(void)setId:(NSString *)id { [self setObject:id forKey:@"id"]; };
-(void)setLink:(NSString *)link { [self setObject:link forKey:@"link"]; };
-(void)setBirthday:(NSString *)birthday { [self setObject:birthday forKey:@"birthday"]; };

@end

@implementation SPMUFacebookLoginDelegate

@synthesize loggedInUser;

-(void)dealloc
{
    self.loggedInUser = nil;
}

-(BOOL)isLoggedInWithPermissions:(NSArray *)permissions;
{
    if (self.loggedInUser == nil ||
        (FBSession.activeSession.state != FBSessionStateCreatedTokenLoaded &&
         FBSession.activeSession.state != FBSessionStateOpen))
        return false;

    __block BOOL loggedin = YES;
    [permissions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![self.loggedInUser.readPermissions containsObject:obj] &&
            ![self.loggedInUser.writePermissions containsObject:obj])
        {
            *stop = YES;
            loggedin = NO;
        }
    }];
    return loggedin;
}

-(void)logout:(SPMUCallbackHandler)handler
{
    self.loggedInUser = nil;
    [FBSession.activeSession setStateChangeHandler:
     ^(FBSession *session, FBSessionState status, NSError *error) {
         // set to an empty handler as NIL is not allowed and we dont
         // want the handler that is set in openActiveSessionWithReadPermissions below
         // to be called!
     }];
    [FBSession.activeSession closeAndClearTokenInformation];
    [FBSession.activeSession close];
    [FBSession setActiveSession:nil];
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies])
    {
        NSString* domainName = [cookie domain];
        NSRange domainRange = [domainName rangeOfString:@"facebook"];
        if(domainRange.length > 0)
        {
            [storage deleteCookie:cookie];
        }
    }
    if (handler)
        handler(nil, nil);
}

-(void)ensureLoginWithPermissions:(NSArray *)permissions
                     onCompletion:(SPMUCallbackHandler)handler
{
    handler = [handler copy];
    [FBSession openActiveSessionWithReadPermissions:permissions
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session, FBSessionState state, NSError *error) {
         NSAssert(session.state == state, @"Dang session.state and state are not the same");
         if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed)
         {
             if (error == nil)
             {
                 NSString *message = @"Facebook login failed";
                 error = [NSError errorWithDomain:(NSString *)SPMUFacebookErrorDomain
                                             code:SPMUFacebookErrorLoginFailed
                                         userInfo:[NSDictionary dictionaryWithObject:message
                                                                              forKey:NSLocalizedDescriptionKey]];
             }
             if (handler)
                 handler(session, error);
         }
         else
         {
             // create the loggedInUser object by querying the user details
             // TODO: need to find if we can do this in one step instead of
             // requiring a second call
             self.loggedInUser = [[SPMUFacebookUser alloc] init];
             [[FBRequest requestForMe] startWithCompletionHandler:
              ^(FBRequestConnection *connection,
                NSDictionary<FBGraphUser> *user,
                NSError *error)
              {
                  presentErrorRateLimited(error, 30);
                  if (!error)
                  {
                      self.loggedInUser = [[SPMUFacebookUser alloc] initWithFBUser:user];
                      self.loggedInUser.session = session;
                      [self.loggedInUser.readPermissions removeAllObjects];
                      [self.loggedInUser.readPermissions addObjectsFromArray:self.loggedInUser.session.permissions];
                  }
                  if (handler)
                      handler(self.loggedInUser, error);
              }];
         }
     }];
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

@end
