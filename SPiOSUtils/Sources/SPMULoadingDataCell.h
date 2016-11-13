//
//  SPMULoadingDataCell.h
//
//  Created by Sri Panyam on 17/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPMUFwdDefs.h"

@interface SPMULoadingDataCell : UITableViewCell

@property (nonatomic) BOOL isLoadingData;
@property (nonatomic, retain) IBOutlet UILabel *statusLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

