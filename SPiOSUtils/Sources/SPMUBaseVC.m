
#import "SPMobileUtils.h"

@implementation SPMUBaseVC

COMMON_BASE_VC_METHODS_IMPLEMENTATION

+(void)pushViewController:(UIViewController *)vc onVC:(UIViewController *)onVC animated:(BOOL)animated
{
    UINavigationController *navVC = onVC.navigationController;
    UIViewController *currVC = onVC;
    while (navVC == nil && currVC != nil)
    {
        if ([currVC respondsToSelector:@selector(eventualNavigationController)])
        {
            navVC = [currVC performSelector:@selector(eventualNavigationController) withObject:nil];
        }
        else if (!navVC)
        {
            currVC = currVC.parentViewController;
            navVC = currVC.navigationController;
        }
    }
    __weak UINavigationController *eventualNavVC = nil;
    if ([onVC respondsToSelector:@selector(eventualNavigationController)])
    {
        eventualNavVC = [onVC performSelector:@selector(eventualNavigationController) withObject:nil];
        if ([vc respondsToSelector:@selector(setEventualNavigationController:)])
            [vc performSelector:@selector(setEventualNavigationController:)
                     withObject:eventualNavVC];
    }
    [navVC pushViewController:vc animated:YES];
}

@end
