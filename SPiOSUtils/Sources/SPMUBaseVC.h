//
//  SPMUBaseVC.h
//  TrackMyBattery
//
//  Created by Panyam, Sriram on 11/25/13.
//  Copyright (c) 2013 Panyam. All rights reserved.
//

#import "SPMUFwdDefs.h"

#ifndef __SPMU_BASE_VC_H__
#define __SPMU_BASE_VC_H__



#define COMMON_BASE_VC_METHODS_INTERFACE        \
@property (nonatomic, weak) IBOutlet UINavigationController *eventualNavigationController;  \
@property (nonatomic, readonly) int appearCount;                                            \
-(void)releaseResources;                                                                    \
-(void)pushViewController:(UIViewController *)vc animated:(BOOL)animated;                   \
-(void)viewDidSelect;                                                                       \


#define COMMON_BASE_VC_METHODS_IMPLEMENTATION                       \
@synthesize eventualNavigationController;                           \
@synthesize appearCount;                                            \
-(int)appearCount { return appearCount; }                           \
-(void)releaseResources                                             \
{                                                                   \
    self.eventualNavigationController = nil;                        \
}                                                                   \
- (void)didReceiveMemoryWarning                                     \
{                                                                   \
    [super didReceiveMemoryWarning];                                \
    [self releaseResources];                                        \
}                                                                   \
-(void)viewDidUnload                                                \
{                                                                   \
    [self releaseResources];                                        \
}                                                                   \
-(void)viewDidAppear:(BOOL)animated                                 \
{                                                                   \
    [super viewDidAppear:animated];                                 \
    appearCount++;                                                  \
}                                                                   \
-(void)viewDidSelect {}                                             \
-(void)pushViewController:(UIViewController *)vc                    \
                 animated:(BOOL)animated                            \
{                                                                   \
    [SPMUBaseVC pushViewController:vc onVC:self animated:YES];      \
}

@interface SPMUBaseVC : UIViewController

COMMON_BASE_VC_METHODS_INTERFACE

+(void)pushViewController:(UIViewController *)vc
                     onVC:(UIViewController *)onVC
                 animated:(BOOL)animated;

@end

#endif
