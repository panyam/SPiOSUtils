//
//  SPMUWindow.h
//
//  Created by Panyam, Sriram on 9/5/13.
//  Copyright (c) 2013 Sri Panyam. All rights reserved.
//

#import "SPMUFwdDefs.h"

@protocol SPMUViewPresenter

-(void)presentView:(UIView *)view;
-(void)dismissViewAnimated:(BOOL)animated;

@end

@interface SPMUWindow : UIWindow<SPMUViewPresenter>

@end

