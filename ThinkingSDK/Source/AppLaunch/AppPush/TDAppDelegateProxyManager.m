
#import "TDAppDelegateProxyManager.h"
#import "TDApplicationDelegateProxy.h"
#import "TDNewSwizzle.h"
#import "UIApplication+TDPushClick.h"
#import "TDMethodHelper.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import "TDUNUserNotificationCenterDelegateProxy.h"
#endif

@implementation TDAppDelegateProxyManager

+ (instancetype)defaultManager {
    static dispatch_once_t onceToken;
    static TDAppDelegateProxyManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[TDAppDelegateProxyManager alloc] init];
    });
    return manager;
}

- (void)proxyNotifications {

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [TDMethodHelper swizzleRespondsToSelector];
        
        [TDApplicationDelegateProxy resolveOptionalSelectorsForDelegate:[UIApplication sharedApplication].delegate];
        [TDApplicationDelegateProxy proxyDelegate:[UIApplication sharedApplication].delegate selectors:[NSSet setWithArray:@[@"application:didReceiveLocalNotification:",
                                                                                                                             @"application:didReceiveRemoteNotification:fetchCompletionHandler:",
                                                                                                                             @"application:handleOpenURL:",
                                                                                                                             @"application:openURL:options:",
                                                                                                                             @"application:continueUserActivity:restorationHandler:",
                                                                                                                             @"application:performActionForShortcutItem:completionHandler:"]]];
        if (@available(iOS 10.0, *)) {
            if ([UNUserNotificationCenter currentNotificationCenter].delegate) {
                [TDUNUserNotificationCenterDelegateProxy proxyDelegate:[UNUserNotificationCenter currentNotificationCenter].delegate selectors:[NSSet setWithArray:@[@"userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:"]]];
            }
            NSError *error = NULL;
            [UNUserNotificationCenter td_new_swizzleMethod:@selector(setDelegate:) withMethod:@selector(thinkingdata_setDelegate:) error:&error];
            if (error) {
                NSLog(@"proxy notification delegate error: %@", error);
            }
        }
    });
}

@end
