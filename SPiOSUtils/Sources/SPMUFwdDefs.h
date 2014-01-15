
#ifndef __SPMU_FWD_DEFS_H__
#define __SPMU_FWD_DEFS_H__

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#define SECONDS_IN_A_MINUTE     60
#define MINUTES_IN_AN_HOUR      60
#define HOURS_IN_A_DAY          24

@class SPMUBaseVC;
@class SPMUBaseTableVC;
@class SPMUBaseTabBarVC;
@class SPMULoadingDataCell;
@class SPMURequest;
@class SPMUWindow;
@class SPMUDefaultActivityIndicatorView;
@class SPMUActivityIndicator;
@class SPMUUser;
@class SPMULoginManager;
@class SPMUEmailLoginDelegate;
@class SPMUFacebookLoginDelegate;
@class SPMUDefaultEmailLoginView;
@class SPMUEmailLoginView;
@class SPMUAlertView;

@protocol SPMULoginDelegate;
@protocol SPMUEmailLoginViewDelegate;

typedef void (^SPMUCallbackHandler)(id result, NSError *error);

#endif

