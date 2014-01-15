//
//  SPMUAlertView.h
//  SangeethaPriya
//
//  Created by Panyam, Sriram on 12/10/13.
//
//

#import "SPMUFwdDefs.h"

typedef void (^SPMUAlertViewHandler)(SPMUAlertView *alertView, int buttonClicked);

@interface SPMUAlertView : UIAlertView<UIAlertViewDelegate>

@property (nonatomic, copy) SPMUAlertViewHandler alertViewHandler;

@end
