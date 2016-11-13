//
//  SPMUActivityIndicator.h
//
//  Created by Panyam, Sriram on 8/14/13.
//  Copyright (c) 2013 Sri. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define SPMU_ACTIVITY_INDICATOR [SPMUActivityIndicator sharedInstance]

@interface SPMUDefaultActivityIndicatorView : UIView

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) IBOutlet UIView *activityIndicatorBGView;
@property (nonatomic, strong) IBOutlet UILabel *messageLabel;

@end

@interface SPMUActivityIndicator : NSObject

+(SPMUActivityIndicator *)sharedInstance;
-(void)show;
-(void)hide;
-(void)showWithMessage:(NSString *)message;
-(void)showWithView:(UIView *)view;

@end

