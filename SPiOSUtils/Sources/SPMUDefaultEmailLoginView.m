//
//  SPMULoginView.m
//
//  Created by Panyam, Sriram on 9/5/13.
//  Copyright (c) 2013 Sriram Panyam. All rights reserved.
//

#import "SPMobileUtils.h"

#define AUTH_EMAIL_KEY   @"auth_email"
#define AUTH_PASSWORD_KEY   @"auth_password"

@implementation SPMUDefaultEmailLoginView

@synthesize emailField;
@synthesize passwordField;
@synthesize cancelButton;
@synthesize loginButton;
@synthesize userIsNewSwitch;
@synthesize statusLabel;
@synthesize loginHandler;
@synthesize loginDelegate;

-(void)dealloc
{
    self.emailField = nil;
    self.passwordField = nil;
    self.cancelButton = nil;
    self.loginButton = nil;
    self.userIsNewSwitch = nil;
    self.statusLabel = nil;
    self.loginHandler = nil;
    self.loginDelegate = nil;
}

-(void)validateFieldsAndSave
{
    if (self.email.length > 0)
        [[NSUserDefaults standardUserDefaults] setValue:NONULL(emailField.text)
                                                 forKey:AUTH_EMAIL_KEY];
    if (self.password.length > 0)
        [[NSUserDefaults standardUserDefaults] setValue:NONULL(passwordField.text)
                                                 forKey:AUTH_PASSWORD_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    loginButton.enabled = self.email.length > 0 && self.password.length > 0;
}

-(NSString *)email
{
    return [emailField.text.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(void)setEmail:(NSString *)email
{
    emailField.text = NONULL(email);
}

-(NSString *)password
{
    return [passwordField.text.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(void)setPassword:(NSString *)password
{
    passwordField.text = NONULL(password);
}

-(void)reset
{
    self.email = @"";
    self.password = @"";
    self.statusLabel.text = @"";
}

-(IBAction)loginButtonClicked
{
    self.loginButton.enabled = NO;
    self.cancelButton.enabled = NO;
    [SPMU_ACTIVITY_INDICATOR showWithMessage:@"Logging in"];
    [self.loginDelegate loginWithEmail:self.email
                          withPassword:self.password
                               newUser:self.userIsNewSwitch.on
                           withHandler:
     ^(id result, NSError *error)
     {
         ensure_main_queue(^{
             self.loginButton.enabled = YES;
             self.cancelButton.enabled = YES;
             if (error.domain == SPMUUserErrorDomain)
             {
                 self.statusLabel.text = @"Login failed";
                 if (self.loginHandler)
                     self.loginHandler(self, SPMUEmailLoginViewStateLogInFailed, result, error);
                 else if ([self.loginDelegate respondsToSelector:@selector(loginView:stateChanged:withData:withError:)])
                     [self.loginDelegate loginView:self
                                      stateChanged:SPMUEmailLoginViewStateLogInFailed
                                          withData:result
                                         withError:error];
             }
             else if (!error)
             {
                 // save the credentials to user defaults
                 if (loginHandler)
                     loginHandler(self, SPMUEmailLoginViewStateLogInSucceeded, result, error);
                 else if ([loginDelegate respondsToSelector:@selector(loginView:stateChanged:withData:withError:)])
                     [loginDelegate loginView:self
                                 stateChanged:SPMUEmailLoginViewStateLogInSucceeded
                                     withData:result
                                    withError:error];
             }
             [SPMU_ACTIVITY_INDICATOR hide];
         });
     }];
}

-(IBAction)cancelButtonClicked
{
    if (loginHandler)
        loginHandler(self, SPMUEmailLoginViewStateCancelled, nil, nil);
    else if ([loginDelegate respondsToSelector:@selector(loginView:stateChanged:withData:withError:)])
        [loginDelegate loginView:self
                    stateChanged:SPMUEmailLoginViewStateCancelled
                        withData:nil
                       withError:nil];
}

-(IBAction)userSwitchClicked
{
    [loginButton setTitle:userIsNewSwitch.on ? @"Register" : @"Login"
                 forState:UIControlStateNormal];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.emailField) {
        [self.passwordField becomeFirstResponder];
    }
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [self validateFieldsAndSave];
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

@end
