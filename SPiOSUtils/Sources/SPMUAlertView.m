//
//  SPMUAlertView.m
//  SangeethaPriya
//
//  Created by Panyam, Sriram on 12/10/13.
//
//

#import "SPMobileUtils.h"

@implementation SPMUAlertView

@synthesize alertViewHandler;

-(void)dealloc
{
    self.alertViewHandler = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = nil;
    }
    return self;
}

-(id)initWithTitle:(NSString *)title
           message:(NSString *)message
          delegate:(id)delegate
 cancelButtonTitle:(NSString *)cancelButtonTitle
 otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    self = [super initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
    if (otherButtonTitles)
    {
        CREATE_VA_LIST(args, otherButtonTitles);
        [self addButtonWithTitle:otherButtonTitles];
        NSString *nextTitle = nil;
        while ((nextTitle = ns_va_arg(args, NSString*)) != nil)
        {
            [self addButtonWithTitle:nextTitle];
        }
    }
    return self;
}

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertViewHandler && self == alertView)
        alertViewHandler(self, buttonIndex);
}

// Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button
- (void)alertViewCancel:(UIAlertView *)alertView
{
    if (alertViewHandler && self == alertView)
        alertViewHandler(self, -1);
}

@end
