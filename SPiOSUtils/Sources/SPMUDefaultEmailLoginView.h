//
//  SPMUDefaultEmailLoginView.h
//
//  Created by Panyam, Sriram on 9/5/13.
//  Copyright (c) 2013 Sriram Panyam. All rights reserved.
//

#import "SPMUEmailLoginView.h"

@interface SPMUDefaultEmailLoginView : UIView<UITextFieldDelegate, SPMUEmailLoginViewDelegate>

@property (nonatomic, strong) IBOutlet UITextField *emailField;
@property (nonatomic, strong) IBOutlet UITextField *passwordField;
@property (nonatomic, strong) IBOutlet UIButton *cancelButton;
@property (nonatomic, strong) IBOutlet UIButton *loginButton;

@property (nonatomic, strong) IBOutlet UISwitch *userIsNewSwitch;
@property (nonatomic, strong) IBOutlet UILabel *statusLabel;
@property (nonatomic, copy) SPMUEmailLoginViewHandler loginHandler;
@property (nonatomic, assign) id<SPMUEmailLoginViewDelegate> loginDelegate;

@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *password;

-(IBAction)loginButtonClicked;
-(IBAction)cancelButtonClicked;
-(IBAction)userSwitchClicked;

@end
