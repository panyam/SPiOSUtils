//
//  SPMULoadingDataCell.m
//
//  Created by Sri Panyam on 17/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPMobileUtils.h"

@implementation SPMULoadingDataCell

@synthesize isLoadingData;
@synthesize statusLabel;
@synthesize activityIndicator;

-(void)dealloc
{
    self.activityIndicator = nil;
    self.statusLabel = nil;
}

-(void)setIsLoadingData:(BOOL)loading
{
    isLoadingData = loading;
    ensure_main_queue(^{
        self.statusLabel.text = loading ? @"Loading ..." : @"Load more data";
        self.activityIndicator.hidden = !loading;
        if (loading)
        {
            [self.activityIndicator startAnimating];
        }
        else
        {
            [self.activityIndicator stopAnimating];
        }
    });
}

@end

