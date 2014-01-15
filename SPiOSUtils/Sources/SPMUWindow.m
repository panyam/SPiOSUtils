//
//  SPMUWindow.m
//
//  Created by Panyam, Sriram on 9/5/13.
//  Copyright (c) 2013 Sri Panyam. All rights reserved.
//

#import "SPMobileUtils.h"
#import <QuartzCore/QuartzCore.h>

@interface SPMUWindow ()

// Current parent of the view that is being displayed in this window
// if any
@property (nonatomic, strong) UIView *oldViewParent;

// The frame of the view in the previous parent
@property (nonatomic) CGRect oldViewFrame;

// Index of the view in its original parent.
@property (nonatomic) int oldViewIndex;

@end

@implementation SPMUWindow

@synthesize oldViewFrame;
@synthesize oldViewParent;
@synthesize oldViewIndex;

-(void)dealloc
{
    self.oldViewParent = nil;
}

-(CGSize)holderSize
{
    UIScreen *mainscreen = [UIScreen mainScreen];
    CGRect mainBounds = mainscreen.bounds;
    return mainBounds.size;
}

-(void)presentView:(UIView *)view
{
    // if we are already showing
    ensure_main_queue(^{
        self.oldViewParent = view.superview;
        self.oldViewFrame = view.frame;
        self.oldViewIndex = [[self.oldViewParent subviews] indexOfObject:view];

        CGFloat margin = 0.0f;
        CGFloat statusBarHeight = 0;
        if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
        {
            CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
            statusBarHeight = statusBarFrame.size.height;
        }
        UIScreen *mainscreen = [UIScreen mainScreen];
        CGRect mainBounds = mainscreen.bounds;
        CGRect windowRect = mainBounds;
        windowRect.origin.x += margin;
        windowRect.origin.y += margin + statusBarHeight;
        windowRect.size.width -= (margin * 2);
        windowRect.size.height -= ((margin * 2) + statusBarHeight);

        self.frame = windowRect;
        self.layer.cornerRadius = 5;

        self.rootViewController = [[SPMUBaseVC alloc] init];
        [self.rootViewController.view addSubview:view];

        [self makeKeyAndVisible];
        
        __block CGRect viewFrame = view.frame;
        NSLog(@"");
        NSLog(@"Old View Parent: %@", oldViewParent);
        NSLog(@"Root View: %@", self.rootViewController.view);
        NSLog(@"");
        if (self.oldViewParent)
        {
            CGPoint globalLocation = [self.oldViewParent convertPoint:view.frame.origin
                                                               toView:nil];
            view.frame = CGRectMake(globalLocation.x, globalLocation.y,
                                    viewFrame.size.width, viewFrame.size.height);
            self.backgroundColor = [UIColor colorWithRed:0.1 green:0.2 blue:0.05 alpha:0.0];
            [UIView animateWithDuration:0.5 animations:^{
                self.backgroundColor = [UIColor colorWithRed:0.1 green:0.2 blue:0.05 alpha:0.5];
                // center the view
                viewFrame.origin.x = (windowRect.size.width - viewFrame.size.width) / 2;
                viewFrame.origin.y = (windowRect.size.height - viewFrame.size.height) / 2;
                view.frame = viewFrame;
            }];
        }
        else
        {
            self.backgroundColor = [UIColor colorWithRed:0.1 green:0.2 blue:0.05 alpha:0.5];
            // center the view
            viewFrame.origin.x = (windowRect.size.width - viewFrame.size.width) / 2;
            viewFrame.origin.y = (windowRect.size.height - viewFrame.size.height) / 2;
            view.frame = viewFrame;
        }
    });
}

-(void)dismissViewAnimated:(BOOL)animated
{
    ensure_main_queue(^{
        [self resignKeyWindow];
        self.hidden = YES;
        NSArray *subviews = [self.rootViewController.view subviews];
        if (subviews.count > 0)
        {
            UIView *view = [subviews objectAtIndex:0];
            if (self.oldViewParent && self.oldViewParent != view.superview)
            {
                [self.oldViewParent insertSubview:view atIndex:oldViewIndex];
                view.frame = oldViewFrame;
                self.oldViewParent = nil;
            }
        }
    });
}

@end

