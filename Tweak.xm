#import <UIKit/UIKit.h>
#import <substrate.h>
#import <HBLog.h>
#import <rootless.h>
#import <dlfcn.h>
#import <YouTubeHeader/YTIPivotBarRenderer.h>
#import <YouTubeHeader/YTIPivotBarSupportedRenderers.h>
#import <YouTubeHeader/YTIPivotBarItemRenderer.h>
#import <YouTubeHeader/YTCommonColorPalette.h>
#import <YouTubeHeader/YTSettingsSectionItem.h>
#import <YouTubeHeader/YTSettingsCell.h>
#import "Classes/UI/ViewControllers/DownloadsPagerVC.h"
#import "Classes/Core/Player/PlayerManager.h"
#import "Classes/Core/Utils/Statistics.h"
#import "Classes/Core/Settings/SettingsVC.h"


@class YTInlineMutedPlaybackWatchController;
@class YTRefactoredHeaderContentComboViewController;
@class GOODialogView;
@class HAMPlayerInternal;
@class SSBouncyButton;
@class YTSettingsViewController;
@class YTIPivotBarView;

static BOOL UYouIsEnabled(NSString *key) {
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}

%group gMain

%hook YTPivotBarView
- (void)setRenderer:(YTIPivotBarRenderer *)renderer {
    if (renderer) {
        NSMutableArray *items = [renderer itemsArray];
        if (items) {
            NSDictionary *hideMap = @{
                @"hideShortsTab": @"FEshorts",
                @"hideCreateTab": @"FEuploads",
                @"hideExploreTab": @"FEexplore",
                @"hideSubscriptionsTab": @"FEsubscriptions",
                @"hideLibraryTab": @"FElibrary",
                @"hideTrendingTab": @"FEtrending"
            };
            for (NSString *key in hideMap) {
                if (UYouIsEnabled(key)) {
                    NSString *pid = hideMap[key];
                    NSUInteger idx = [items indexOfObjectPassingTest:^BOOL(YTIPivotBarSupportedRenderers *obj, NSUInteger idx, BOOL *stop) {
                        NSString *a = [[obj pivotBarItemRenderer] pivotIdentifier];
                        NSString *b = [[obj pivotBarIconOnlyItemRenderer] pivotIdentifier];
                        return [a isEqualToString:pid] || [b isEqualToString:pid];
                    }];
                    if (idx != NSNotFound) [items removeObjectAtIndex:idx];
                }
            }
            if (!UYouIsEnabled(@"hideUYouTab")) {
                BOOL alreadyHasUYou = NO;
                for (YTIPivotBarSupportedRenderers *obj in items) {
                    NSString *a = [[obj pivotBarItemRenderer] pivotIdentifier];
                    NSString *b = [[obj pivotBarIconOnlyItemRenderer] pivotIdentifier];
                    if ([a isEqualToString:@"com.miro.uyouunofficial"] || [b isEqualToString:@"com.miro.uyouunofficial"]) { alreadyHasUYou = YES; break; }
                }
                if (!alreadyHasUYou) {
                    YTIPivotBarSupportedRenderers *uYouTab = [%c(YTIPivotBarRenderer) pivotSupportedRenderersWithBrowseId:@"com.miro.uyouunofficial" title:@"uYou" iconType:2];
                    if (uYouTab) [items addObject:uYouTab];
                }
            }
        }
    }
    %orig(
        renderer
    );
}
%end

%hook YTSettingsViewController
- (void)setSectionItems:(NSMutableArray *)sectionItems forCategory:(NSInteger)category title:(NSString *)title icon:(YTIIcon *)icon titleDescription:(NSString *)titleDescription headerHidden:(BOOL)headerHidden {
    NSMutableArray *origItems = sectionItems;
    if ((category == 1 || category == 4) && sectionItems) {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"uYouLocalization" ofType:@"bundle"];
        NSBundle *locBundle = bundlePath ? [NSBundle bundleWithPath:bundlePath] : nil;
        NSString *uYouTitle = locBundle ? [locBundle localizedStringForKey:@"uYouSettings" value:@"Show uYou settings" table:@"Localizable"] : @"Show uYou settings";
        YTSettingsSectionItem *uYouItem = nil;
        if (category == 1) {
            uYouItem = [%c(YTSettingsSectionItem) itemWithTitle:uYouTitle accessibilityIdentifier:nil detailTextBlock:nil selectBlock:^BOOL(id cell, NSUInteger arg1) {
                UIViewController *vc = [[%c(SettingsVC) alloc] init];
                if (vc) [(UINavigationController *)[(id)self navigationController] pushViewController:vc animated:YES];
                return YES;
            }];
        } else {
            uYouItem = [%c(YTSettingsSectionItem) itemWithTitle:uYouTitle titleDescription:nil accessibilityIdentifier:nil detailTextBlock:nil selectBlock:^BOOL(id cell, NSUInteger arg1) {
                UIViewController *vc = [[%c(SettingsVC) alloc] init];
                if (vc) [(UINavigationController *)[(id)self navigationController] pushViewController:vc animated:YES];
                return YES;
            }];
        }
        if (uYouItem) {
            NSMutableArray *newItems = [sectionItems mutableCopy];
            [newItems addObject:uYouItem];
            origItems = newItems;
        }
    }
    %orig(
        origItems,
        category,
        title,
        icon,
        titleDescription,
        headerHidden
    );
}
%end

%hook YTHeaderContentComboViewController
- (void)viewDidLoad {
    %orig;
    @try {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"hideUYouButton"]) {
            UIView *rootView = [(UIViewController *)self view];
            if (rootView) {
                for (UIView *v in rootView.subviews) {
                    if ([v.accessibilityIdentifier containsString:@"uYou"] || [NSStringFromClass(v.class) containsString:@"uYou"]) v.hidden = YES;
                }
            }
        }
    } @catch (id e) {}
}
%end

%hook YTRefactoredHeaderContentComboViewController
- (void)viewDidLoad {
    %orig;
    @try {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"hideUYouButton"]) {
            UIView *rootView = [(UIViewController *)self view];
            if (rootView) {
                for (UIView *v in rootView.subviews) {
                    if ([v.accessibilityIdentifier containsString:@"uYou"] || [NSStringFromClass(v.class) containsString:@"uYou"]) v.hidden = YES;
                }
            }
        }
    } @catch (id e) {}
}
%end

%hook YTAppViewController
- (void)closeMiniPlayer {
    @try { id pm = [%c(PlayerManager) sharedInstance]; if ([pm respondsToSelector:@selector(setSource:)]) [pm performSelector:@selector(setSource:) withObject:nil]; } @catch (id e) {}
    %orig;
}
%end

%group gPlayer

%hook YTPageStyleController

+ (void)updatePageStyles {
    %orig;
}

%end

%end // gPlayer


%group gPlayer2

%hook YTInlineMutedPlaybackWatchController

- (void)startPlayback {
    %orig;
}

%end

%end // gPlayer2


%group gPlayer3

%hook YTPlaybackConfig

- (void)setStartPlayback:(id)arg1 {
    %orig(arg1);
}

%end

%end // gPlayer3


%group gPlayer4

%hook YTPlayerViewController

- (void)updatePlayerViewWithActivePlayerOverlay {
    %orig;
}

%end

%end // gPlayer4


%group gPlayer5

%hook YTMainAppVideoPlayerOverlayViewController

- (void)mediaTime {
    %orig;
}

- (void)setMediaTime:(id)arg1 {
    %orig(arg1);
}

%end

%end // gPlayer5


%group gMain2

%hook YTAppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)options {

    BOOL r = %orig(application, options);

    @try {
        [[NSUserDefaults standardUserDefaults] setBool:YES
                                               forKey:@"showedWelcomeVC"];

        [[NSUserDefaults standardUserDefaults] setBool:NO
                                               forKey:@"automaticallyCheckForUpdates"];
    } @catch (id e) {}

    return r;
}

%end


%hook YTLocalPlaybackController

- (NSString *)currentVideoID {
    return %orig;
}

%end


%hook Statistics

+ (void)update:(id)arg1 {

    %orig(arg1);

    @try {
        [[%c(Statistics) sharedStatistics] recordDownloadStarted];
    } @catch (id e) {}
}

%end


%hook UIViewController

- (UITraitCollection *)traitCollection {

    @try {
        return %orig;
    } @catch (NSException *e) {
        return [UITraitCollection currentTraitCollection];
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)prev {

    %orig(prev);

    @try {
        if (%c(DownloadsPagerVC)) {
            void (*fn)(void) = (void (*)(void))dlsym(
                RTLD_DEFAULT,
                "UYouRefreshAppearance"
            );

            if (fn) {
                fn();
            }
        }
    } @catch (id e) {}
}

%end


%hook HAMPlayerInternal

- (void)play {

    @try {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[%c(PlayerManager) sharedInstance] pause];
        });
    } @catch (id e) {}

    %orig;
}

%end


%hook SSBouncyButton

- (void)beginShrinkAnimation {
}

- (void)beginEnlargeAnimation {
}

%end


%hook YTCommonColorPalette

- (UIColor *)brandBackgroundSolid {

    BOOL dark = NO;

    if ([self respondsToSelector:@selector(pageStyle)]) {
        dark = (self.pageStyle == 1);
    } else {
        dark =
            (UITraitCollection.currentTraitCollection.userInterfaceStyle
             == UIUserInterfaceStyleDark);
    }

    return dark
        ? [UIColor colorWithRed:0.05882352941176471
                          green:0.05882352941176471
                           blue:0.05882352941176471
                          alpha:1.0]
        : %orig;
}

%end


%hook YTPlayerViewController

- (id)varispeedController {

    id c = %orig;

    if (!c &&
        [(id)self respondsToSelector:@selector(overlayManager)]) {

        @try {
            id mgr =
                [(id)self performSelector:@selector(overlayManager)];

            if (mgr &&
                [mgr respondsToSelector:@selector(varispeedController)]) {

                c =
                    [mgr performSelector:@selector(varispeedController)];
            }
        } @catch (id e) {}
    }

    return c;
}

%end


%hook GOODialogView

- (UIImageView *)imageView {

    UIImageView *iv = %orig;

    @try {

        UILabel *lab =
            [(id)self valueForKey:@"titleLabel"];

        if (lab &&
            [lab.text containsString:@"uYou\n"]) {

            NSString *bp =
                [[NSBundle mainBundle]
                    pathForResource:@"uYouUnofficial"
                    ofType:@"bundle"];

            if (!bp) {
                bp =
                    [[NSBundle mainBundle]
                        pathForResource:@"uYouBundle"
                        ofType:@"bundle"];
            }

            NSBundle *b =
                bp ? [NSBundle bundleWithPath:bp] : nil;

            if (b) {

                NSString *ip =
                    [b pathForResource:@"icon_clipped"
                                ofType:@"png"];

                UIImage *icon =
                    ip ? [UIImage imageWithContentsOfFile:ip] : nil;

                if (icon) {

                    CGSize sz = CGSizeMake(30, 30);

                    UIGraphicsBeginImageContextWithOptions(
                        sz,
                        NO,
                        0
                    );

                    [icon drawInRect:CGRectMake(
                        0,
                        0,
                        sz.width,
                        sz.height
                    )];

                    UIImage *resized =
                        UIGraphicsGetImageFromCurrentImageContext();

                    UIGraphicsEndImageContext();

                    if (iv) {
                        [iv setImage:resized];
                    }
                }
            }
        }

    } @catch (id e) {}

    return iv;
}


- (UILabel *)titleLabel {

    UILabel *lab = %orig;

    @try {

        if (lab &&
            [lab.text containsString:@"uYou\n"] &&
            ![lab.text containsString:@"uYou\n\n"]) {

            lab.text =
                [lab.text
                    stringByReplacingOccurrencesOfString:@"uYou\n"
                                              withString:@"uYou\n\n"];
        }

    } @catch (id e) {}

    return lab;
}

%end

%end // gMain2

%ctor {
    %init(gMain);
    %init(gPlayer);
    %init(gPlayer2);
    %init(gPlayer3);
    %init(gPlayer4);
    %init(gPlayer5);
    %init(gMain2);
}