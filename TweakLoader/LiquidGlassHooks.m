#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#include <stdlib.h>
#include <string.h>

static void (*NC_originalViewDidAppear)(UIViewController *self, SEL selector, BOOL animated);

static void NC_applyOpaqueAppearance(UIView *view) {
    if ([view isKindOfClass:UINavigationBar.class]) {
        UINavigationBar *bar = (UINavigationBar *)view;
        UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundEffect = nil;
        bar.standardAppearance = appearance;
        bar.scrollEdgeAppearance = appearance;
        if (@available(iOS 15.0, *)) {
            bar.compactAppearance = appearance;
        }
    } else if ([view isKindOfClass:UITabBar.class]) {
        UITabBar *bar = (UITabBar *)view;
        UITabBarAppearance *appearance = [UITabBarAppearance new];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundEffect = nil;
        bar.standardAppearance = appearance;
        if (@available(iOS 15.0, *)) {
            bar.scrollEdgeAppearance = appearance;
        }
    } else if ([view isKindOfClass:UIVisualEffectView.class]) {
        ((UIVisualEffectView *)view).effect = nil;
        view.backgroundColor = UIColor.systemBackgroundColor;
    }

    for (UIView *subview in view.subviews) {
        NC_applyOpaqueAppearance(subview);
    }
}

static void NC_viewDidAppear(UIViewController *self, SEL selector, BOOL animated) {
    NC_originalViewDidAppear(self, selector, animated);
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = self.view.window;
        if (window) {
            NC_applyOpaqueAppearance(window);
        }
    });
}

__attribute__((constructor))
static void NC_installLiquidGlassHooks(void) {
    const char *disabled = getenv("NC_DISABLE_LIQUID_GLASS");
    if (!disabled || strcmp(disabled, "1") != 0) {
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        Method method = class_getInstanceMethod(UIViewController.class, @selector(viewDidAppear:));
        if (!method) {
            return;
        }
        NC_originalViewDidAppear = (void (*)(UIViewController *, SEL, BOOL))method_getImplementation(method);
        method_setImplementation(method, (IMP)NC_viewDidAppear);
    });
}
