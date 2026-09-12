#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "../LiveContainer/LCSharedUtils.h"
#import "../LiveContainer/utils.h"

@interface NCOverlayRootView : UIView
@property(nonatomic, weak) UIView *handleView;
@property(nonatomic, weak) UIView *panelView;
@end

@implementation NCOverlayRootView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hit = [super hitTest:point withEvent:event];
    if (hit == self || !hit) {
        return nil;
    }
    if (hit == self.handleView || hit == self.panelView ||
        [hit isDescendantOfView:self.handleView] || [hit isDescendantOfView:self.panelView]) {
        return hit;
    }
    return nil;
}

@end

@interface NCAppSwitcherOverlay : NSObject
@property(nonatomic, strong) UIWindow *window;
@property(nonatomic, strong) NCOverlayRootView *rootView;
@property(nonatomic, strong) UIButton *handle;
@property(nonatomic, strong) UIView *panel;
@property(nonatomic, strong) NSArray<NSDictionary *> *apps;
@property(nonatomic) BOOL expanded;
@end

@implementation NCAppSwitcherOverlay

- (void)install {
    if (![NSUserDefaults.lcUserDefaults boolForKey:@"NCPlugin.AppSwitcherOverlay"]) {
        return;
    }
    if (NSUserDefaults.isSideStore || NSUserDefaults.isLiveProcess) {
        return;
    }

    UIWindowScene *scene = (UIWindowScene *)UIApplication.sharedApplication.connectedScenes.anyObject;
    if (!scene) {
        return;
    }

    self.window = [[UIWindow alloc] initWithWindowScene:scene];
    self.window.frame = scene.coordinateSpace.bounds;
    self.window.backgroundColor = UIColor.clearColor;
    self.window.windowLevel = UIWindowLevelAlert - 2;
    self.rootView = [[NCOverlayRootView alloc] initWithFrame:self.window.bounds];
    self.rootView.backgroundColor = UIColor.clearColor;
    self.window.rootViewController = [UIViewController new];
    self.window.rootViewController.view = self.rootView;

    self.handle = [UIButton buttonWithType:UIButtonTypeSystem];
    self.handle.frame = CGRectMake(self.window.bounds.size.width - 66,
                                   self.window.bounds.size.height * 0.45,
                                   50,
                                   50);
    self.handle.layer.cornerRadius = 25;
    self.handle.backgroundColor = [UIColor colorWithRed:0.08 green:0.42 blue:0.95 alpha:0.94];
    [self.handle setImage:[UIImage systemImageNamed:@"rectangle.stack.badge.person.crop"] forState:UIControlStateNormal];
    self.handle.tintColor = UIColor.whiteColor;
    self.handle.accessibilityLabel = @"NContainer AppSwitcher";
    [self.handle addTarget:self action:@selector(togglePanel) forControlEvents:UIControlEventTouchUpInside];
    [self.handle addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)]];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveHandle:)];
    [self.handle addGestureRecognizer:pan];

    self.panel = [[UIView alloc] initWithFrame:CGRectZero];
    self.panel.backgroundColor = [UIColor colorWithWhite:0.08 alpha:0.92];
    self.panel.layer.cornerRadius = 18;
    self.panel.hidden = YES;
    self.panel.clipsToBounds = YES;
    self.rootView.handleView = self.handle;
    self.rootView.panelView = self.panel;
    [self.rootView addSubview:self.panel];
    [self.rootView addSubview:self.handle];
    [self reloadApps];
    self.window.hidden = NO;
}

- (void)reloadApps {
    NSString *home = [NSUserDefaults.lcUserDefaults stringForKey:@"LC_HOME_PATH"];
    if (home.length == 0) {
        home = [NSString stringWithUTF8String:getenv("LC_HOME_PATH") ?: ""];
    }
    if (home.length == 0) {
        return;
    }

    NSMutableArray *found = [NSMutableArray array];
    NSMutableArray<NSString *> *roots = [NSMutableArray arrayWithObject:
        [home stringByAppendingPathComponent:@"Documents/Applications"]];
    NSURL *group = LCSharedUtils.appGroupPath;
    if (group.path.length > 0) {
        [roots addObject:[group.path stringByAppendingPathComponent:@"LiveContainer/Applications"]];
    }

    NSFileManager *fm = NSFileManager.defaultManager;
    for (NSString *root in roots) {
        NSArray<NSString *> *names = [fm contentsOfDirectoryAtPath:root error:nil];
        for (NSString *name in names) {
            if (![name.pathExtension.lowercaseString isEqualToString:@"app"]) {
                continue;
            }
            NSString *bundlePath = [root stringByAppendingPathComponent:name];
            NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"LCAppInfo.plist"]];
            NSString *displayName = info[@"LCDisplayName"];
            if (displayName.length == 0) {
                NSDictionary *bundleInfo = [NSDictionary dictionaryWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"Info.plist"]];
                displayName = bundleInfo[@"CFBundleDisplayName"] ?: bundleInfo[@"CFBundleName"] ?: name.stringByDeletingPathExtension;
            }
            if (![found filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"bundle == %@", name]].count) {
                [found addObject:@{ @"bundle": name, @"name": displayName ?: name }];
            }
        }
    }
    self.apps = found;
}

- (void)togglePanel {
    self.expanded = !self.expanded;
    self.panel.hidden = !self.expanded;
    [self rebuildPanel];
    [self.handle setImage:[UIImage systemImageNamed:self.expanded ? @"xmark" : @"rectangle.stack.badge.person.crop"] forState:UIControlStateNormal];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan && !self.expanded) {
        [self togglePanel];
    }
}

- (void)moveHandle:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self.rootView];
    CGPoint center = self.handle.center;
    center.x += translation.x;
    center.y += translation.y;
    CGFloat margin = 12;
    center.x = MAX(margin + self.handle.bounds.size.width / 2, MIN(self.rootView.bounds.size.width - margin - self.handle.bounds.size.width / 2, center.x));
    center.y = MAX(margin + self.handle.bounds.size.height / 2, MIN(self.rootView.bounds.size.height - margin - self.handle.bounds.size.height / 2, center.y));
    self.handle.center = center;
    [gesture setTranslation:CGPointZero inView:self.rootView];
    [self rebuildPanel];
}

- (void)rebuildPanel {
    [self.panel.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (!self.expanded) {
        return;
    }
    CGFloat size = 44;
    CGFloat gap = 8;
    CGFloat height = self.apps.count * (size + gap) + gap;
    self.panel.frame = CGRectMake(self.handle.frame.origin.x - 6,
                                  self.handle.frame.origin.y - height - 8,
                                  size + 12,
                                  MAX(height, size + gap));
    CGFloat y = gap;
    for (NSDictionary *app in self.apps) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = CGRectMake(6, y, size, size);
        button.layer.cornerRadius = 12;
        button.backgroundColor = [UIColor colorWithWhite:0.28 alpha:1.0];
        NSString *name = app[@"name"] ?: @"App";
        [button setTitle:name.length ? [name substringToIndex:MIN((NSUInteger)1, name.length)] : @"A" forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
        button.tintColor = UIColor.whiteColor;
        button.accessibilityLabel = name;
        button.accessibilityValue = app[@"bundle"];
        [button addTarget:self action:@selector(selectApp:) forControlEvents:UIControlEventTouchUpInside];
        [self.panel addSubview:button];
        y += size + gap;
    }
}

- (void)selectApp:(UIButton *)button {
    NSString *bundle = button.accessibilityValue;
    if (bundle.length == 0) {
        return;
    }
    NSString *container = [LCSharedUtils findDefaultContainerWithBundleId:bundle];
    if (container.length > 0) {
        [NSUserDefaults.lcUserDefaults setObject:container forKey:@"selectedContainer"];
    } else {
        [NSUserDefaults.lcUserDefaults removeObjectForKey:@"selectedContainer"];
    }
    [NSUserDefaults.lcUserDefaults setObject:bundle forKey:@"selected"];
    [self togglePanel];
    [LCSharedUtils launchToGuestAppWithClassicMode:0];
}

@end

__attribute__((constructor))
static void NCInstallAppSwitcherOverlay(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        NCAppSwitcherOverlay *overlay = [NCAppSwitcherOverlay new];
        [overlay install];
        objc_setAssociatedObject(UIApplication.sharedApplication, @"NCAppSwitcherOverlay", overlay, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    });
}
