//
//  SPMUActivityIndicator.m
//
//  Created by Panyam, Sriram on 8/14/13.
//  Copyright (c) 2013 Sri Panyam. All rights reserved.
//

#import "SPMobileUtils.h"
#import <QuartzCore/QuartzCore.h>

#define DEFAULT_WIDTH 200

@implementation SPMUDefaultActivityIndicatorView

-(void)dealloc
{
    self.activityIndicator = nil;
    self.activityIndicatorBGView = nil;
    self.messageLabel = nil;
}

@end

@interface SPMUActivityIndicator()

@property (nonatomic, strong) SPMUDefaultActivityIndicatorView *defaultLoadingView;
@property (nonatomic, strong) SPMUWindow *holderWindow;

@end

@implementation SPMUActivityIndicator

@synthesize defaultLoadingView;
@synthesize holderWindow;

+(SPMUActivityIndicator *)sharedInstance
{
    static SPMUActivityIndicator *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SPMUActivityIndicator alloc] init];
    });
    return instance;
}

-(id)init
{
    if ((self = [super init]))
    {
        if (self.holderWindow == nil)
            self.holderWindow = [[SPMUWindow alloc] initWithFrame:CGRectZero];
        NSURL *bundleURL = [[NSBundle bundleForClass:self.class] URLForResource:@"SPiOSUtils" withExtension:@"bundle"];
        NSBundle *bundle = [NSBundle bundleWithURL:bundleURL];
        self.defaultLoadingView = [[bundle loadNibNamed:@"SPMUDefaultActivityIndicatorView" owner:self options:nil] objectAtIndex:0];
        self.defaultLoadingView.layer.cornerRadius = 10;
    }
    return self;
}

-(void)dealloc
{
    self.holderWindow = nil;
    self.defaultLoadingView = nil;
}

-(void)showWithView:(UIView *)view
{
    [self.holderWindow presentView:view];
}

-(void)showWithMessage:(NSString *)message
{
    ensure_main_queue(^{
        self.defaultLoadingView.messageLabel.text = message;
        [self showWithView:self.defaultLoadingView];
    });
}

-(void)show
{
    return [self showWithMessage:nil];
}

-(void)hide
{
    [self.holderWindow dismissViewAnimated:NO];
}

@end
