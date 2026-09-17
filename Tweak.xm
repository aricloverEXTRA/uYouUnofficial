#import <UIKit/UIKit.h>
#import <substrate.h>
#import <HBLog.h>
#import <rootless.h>
#import <dlfcn.h>
#import <objc/message.h>

#import <YouTubeHeader/YTIPivotBarRenderer.h>
#import <YouTubeHeader/YTIPivotBarSupportedRenderers.h>
#import <YouTubeHeader/YTIPivotBarItemRenderer.h>
#import <YouTubeHeader/YTCommonColorPalette.h>
#import <YouTubeHeader/YTSettingsSectionItem.h>
#import <YouTubeHeader/YTSettingsCell.h>
#import <YouTubeHeader/YTMainAppControlsOverlayView.h>
#import <YouTubeHeader/YTReelWatchPlaybackOverlayView.h>

#import "Classes/UI/ViewControllers/DownloadsPagerVC.h"
#import "Classes/Core/Player/PlayerManager.h"
#import "Classes/Core/Utils/Statistics.h"
#import "Classes/Core/Settings/SettingsVC.h"
#import "Classes/Core/Downloads/UYTSABR.h"


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

static const NSInteger UYouDownloadButtonTag = 9842;

static UIViewController *UYouTopViewController(UIViewController *controller) {
    UIViewController *top = controller;
    while (top.presentedViewController) top = top.presentedViewController;
    return top;
}

static UIViewController *UYouViewControllerForView(UIView *view) {
    UIResponder *responder = view;
    while (responder) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        }
        responder = [responder nextResponder];
    }
    return nil;
}

static NSString *UYouStringFromObject(id object, SEL selector) {
    if (!object || ![object respondsToSelector:selector]) return nil;
    @try {
        id value = ((id (*)(id, SEL))objc_msgSend)(object, selector);
        return [value isKindOfClass:[NSString class]] ? value : nil;
    } @catch (__unused NSException *exception) {
        return nil;
    }
}

static void UYouStartSABRDownload(UIView *sender) {
    UIViewController *presenter = UYouTopViewController(UYouViewControllerForView(sender));
    id player = presenter;
    while (player && !UYouStringFromObject(player, @selector(currentVideoID))) {
        player = [player parentViewController];
    }
    NSString *videoID = UYouStringFromObject(player, @selector(currentVideoID));
    if (!videoID.length) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"uYou Download" message:@"Open a video before downloading." preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [presenter presentViewController:alert animated:YES completion:nil];
        return;
    }

    NSString *title = UYouStringFromObject(player, @selector(title));
    if (!title.length) title = videoID;
    UYTSABRFallbackDownloadForVideoID(videoID, title, NO, ^(BOOL success, NSString *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *message = success ? @"Saved to the uYouDownloads folder." : (error ?: @"Download failed.");
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:success ? @"Download complete" : @"Download failed" message:message preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [presenter presentViewController:alert animated:YES completion:nil];
        });
    });
}

%group gDownloadButtons

static UIButton *UYouMakeDownloadButton(id target, SEL action) {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.tag = UYouDownloadButtonTag;
    button.accessibilityIdentifier = @"uYou.download.button";
    button.accessibilityLabel = @"Download";
    UIImageSymbolConfiguration *configuration = [UIImageSymbolConfiguration configurationWithPointSize:20 weight:UIImageSymbolWeightMedium];
    UIImage *image = [UIImage systemImageNamed:@"arrow.down.circle" withConfiguration:configuration];
    [button setImage:image forState:UIControlStateNormal];
    button.tintColor = UIColor.whiteColor;
    button.backgroundColor = UIColor.clearColor;
    button.exclusiveTouch = YES;
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

%hook YTMainAppControlsOverlayView
- (void)layoutSubviews {
    %orig;
    UIButton *button = (UIButton *)[self viewWithTag:UYouDownloadButtonTag];
    if (!button) {
        button = UYouMakeDownloadButton(self, @selector(uYouDownloadButtonTapped:));
        [self addSubview:button];
    }
    CGFloat side = 44.0;
    button.frame = CGRectMake(CGRectGetWidth(self.bounds) - side - 12.0, 12.0, side, side);
    [self bringSubviewToFront:button];
}

%new - (void)uYouDownloadButtonTapped:(UIButton *)sender {
    UYouStartSABRDownload(sender);
}
%end

%hook YTReelWatchPlaybackOverlayView
- (void)layoutSubviews {
    %orig;
    UIButton *button = (UIButton *)[self viewWithTag:UYouDownloadButtonTag];
    if (!button) {
        button = UYouMakeDownloadButton(self, @selector(uYouDownloadButtonTapped:));
        [self addSubview:button];
    }
    CGFloat side = 44.0;
    button.frame = CGRectMake(CGRectGetWidth(self.bounds) - side - 10.0, CGRectGetHeight(self.bounds) * 0.5 - side * 0.5, side, side);
    [self bringSubviewToFront:button];
}

%new - (void)uYouDownloadButtonTapped:(UIButton *)sender {
    UYouStartSABRDownload(sender);
}
%end

%end // gDownloadButtons


/*
 * ============================================================
 * gMain
 * ============================================================
 */

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

                    NSUInteger idx =
                        [items indexOfObjectPassingTest:
                            ^BOOL(YTIPivotBarSupportedRenderers *obj,
                                  NSUInteger idx,
                                  BOOL *stop) {

                                NSString *a =
                                    [[obj pivotBarItemRenderer]
                                        pivotIdentifier];

                                NSString *b =
                                    [[obj pivotBarIconOnlyItemRenderer]
                                        pivotIdentifier];

                                return [a isEqualToString:pid] ||
                                       [b isEqualToString:pid];
                            }];

                    if (idx != NSNotFound) {
                        [items removeObjectAtIndex:idx];
                    }
                }
            }


            if (!UYouIsEnabled(@"hideUYouTab")) {

                BOOL alreadyHasUYou = NO;

                for (YTIPivotBarSupportedRenderers *obj in items) {

                    NSString *a =
                        [[obj pivotBarItemRenderer] pivotIdentifier];

                    NSString *b =
                        [[obj pivotBarIconOnlyItemRenderer]
                            pivotIdentifier];

                    if ([a isEqualToString:@"com.miro.uyouunofficial"] ||
                        [b isEqualToString:@"com.miro.uyouunofficial"]) {

                        alreadyHasUYou = YES;
                        break;
                    }
                }


                if (!alreadyHasUYou) {

                    YTIPivotBarSupportedRenderers *uYouTab =
                        [%c(YTIPivotBarRenderer)
                            pivotSupportedRenderersWithBrowseId:
                                @"com.miro.uyouunofficial"
                            title:@"uYou"
                            iconType:2];

                    if (uYouTab) {
                        [items addObject:uYouTab];
                    }
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

- (void)setSectionItems:(NSMutableArray *)sectionItems
           forCategory:(NSInteger)category
                 title:(NSString *)title
                  icon:(YTIIcon *)icon
        titleDescription:(NSString *)titleDescription
          headerHidden:(BOOL)headerHidden {

    NSMutableArray *origItems = sectionItems;


    if ((category == 1 || category == 4) && sectionItems) {

        NSString *bundlePath =
            [[NSBundle mainBundle]
                pathForResource:@"uYouLocalization"
                ofType:@"bundle"];

        NSBundle *locBundle =
            bundlePath
                ? [NSBundle bundleWithPath:bundlePath]
                : nil;


        NSString *uYouTitle =
            locBundle
                ? [locBundle
                    localizedStringForKey:@"uYouSettings"
                                    value:@"Show uYou settings"
                                    table:@"Localizable"]
                : @"Show uYou settings";


        YTSettingsSectionItem *uYouItem = nil;


        if (category == 1) {

            uYouItem =
                [%c(YTSettingsSectionItem)
                    itemWithTitle:uYouTitle
                    accessibilityIdentifier:nil
                    detailTextBlock:nil
                    selectBlock:^BOOL(id cell, NSUInteger arg1) {

                        UIViewController *vc =
                            [[%c(SettingsVC) alloc] init];

                        if (vc) {

                            [(UINavigationController *)
                                [(id)self navigationController]
                                    pushViewController:vc
                                    animated:YES];
                        }

                        return YES;
                    }];

        } else {

            uYouItem =
                [%c(YTSettingsSectionItem)
                    itemWithTitle:uYouTitle
                    titleDescription:nil
                    accessibilityIdentifier:nil
                    detailTextBlock:nil
                    selectBlock:^BOOL(id cell, NSUInteger arg1) {

                        UIViewController *vc =
                            [[%c(SettingsVC) alloc] init];

                        if (vc) {

                            [(UINavigationController *)
                                [(id)self navigationController]
                                    pushViewController:vc
                                    animated:YES];
                        }

                        return YES;
                    }];
        }


        if (uYouItem) {

            NSMutableArray *newItems =
                [sectionItems mutableCopy];

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

        if ([[NSUserDefaults standardUserDefaults]
                boolForKey:@"hideUYouButton"]) {

            UIView *rootView =
                [(UIViewController *)self view];

            if (rootView) {

                for (UIView *v in rootView.subviews) {

                    if ([v.accessibilityIdentifier
                            containsString:@"uYou"] ||
                        [NSStringFromClass(v.class)
                            containsString:@"uYou"]) {

                        v.hidden = YES;
                    }
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

        if ([[NSUserDefaults standardUserDefaults]
                boolForKey:@"hideUYouButton"]) {

            UIView *rootView =
                [(UIViewController *)self view];

            if (rootView) {

                for (UIView *v in rootView.subviews) {

                    if ([v.accessibilityIdentifier
                            containsString:@"uYou"] ||
                        [NSStringFromClass(v.class)
                            containsString:@"uYou"]) {

                        v.hidden = YES;
                    }
                }
            }
        }

    } @catch (id e) {}
}

%end


%hook YTAppViewController

- (void)closeMiniPlayer {

    @try {

        id pm = [%c(PlayerManager) sharedInstance];

        if ([pm respondsToSelector:@selector(setSource:)]) {

            [pm performSelector:@selector(setSource:)
                     withObject:nil];
        }

    } @catch (id e) {}

    %orig;
}

%end


%end // gMain



/*
 * ============================================================
 * gPlayer
 * ============================================================
 */

%group gPlayer

%hook YTPageStyleController

+ (void)updatePageStyles {
    %orig;
}

%end

%end // gPlayer



/*
 * ============================================================
 * gPlayer2
 * ============================================================
 */

%group gPlayer2

%hook YTInlineMutedPlaybackWatchController
+ (void)updatePageStyles {
    %orig;
}
- (void)startPlayback {
    %orig;
}

%end

%end // gPlayer2



/*
 * ============================================================
 * gPlayer3
 * ============================================================
 */

%group gPlayer3

%hook YTPlaybackConfig
- (void)startPlayback {
    %orig;
}
- (void)setStartPlayback:(id)arg1 {
    %orig(
        arg1
    );
}

%end

%end // gPlayer3



/*
 * ============================================================
 * gPlayer4
 * ============================================================
 */

%group gPlayer4

%hook YTPlayerViewController

- (void)updatePlayerViewWithActivePlayerOverlay {
    %orig;
}

%end

%end // gPlayer4



/*
 * ============================================================
 * gPlayer5
 * ============================================================
 */

%group gPlayer5

%hook YTMainAppVideoPlayerOverlayViewController
- (void)updatePlayerViewWithActivePlayerOverlay {
    %orig;
}
- (void)mediaTime {
    %orig;
}

- (void)setMediaTime:(id)arg1 {
    %orig(
        arg1
    );
}

%end

%end // gPlayer5



/*
 * ============================================================
 * gMain2
 * ============================================================
 */

%group gMain2


%hook YTAppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)options {

    BOOL r =
        %orig(
            application,
            options
        );


    @try {

        [[NSUserDefaults standardUserDefaults]
            setBool:YES
            forKey:@"showedWelcomeVC"];

        [[NSUserDefaults standardUserDefaults]
            setBool:NO
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

    %orig(
        arg1
    );


    @try {

        [[%c(Statistics) sharedStatistics]
            recordDownloadStarted];

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

    %orig(
        prev
    );


    @try {

        if (%c(DownloadsPagerVC)) {

            void (*fn)(void) =
                (void (*)(void))
                    dlsym(
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

        dispatch_async(
            dispatch_get_main_queue(),
            ^{

                [[%c(PlayerManager) sharedInstance]
                    pause];
            }
        );

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
            (UITraitCollection
                .currentTraitCollection
                .userInterfaceStyle
             == UIUserInterfaceStyleDark);
    }


    return dark
        ? [UIColor
            colorWithRed:0.05882352941176471
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
        [(id)self
            respondsToSelector:@selector(overlayManager)]) {

        @try {

            id mgr =
                [(id)self
                    performSelector:@selector(overlayManager)];


            if (mgr &&
                [mgr
                    respondsToSelector:
                        @selector(varispeedController)]) {

                c =
                    [mgr
                        performSelector:
                            @selector(varispeedController)];
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
                bp
                    ? [NSBundle bundleWithPath:bp]
                    : nil;


            if (b) {

                NSString *ip =
                    [b pathForResource:@"icon_clipped"
                                ofType:@"png"];


                UIImage *icon =
                    ip
                        ? [UIImage
                            imageWithContentsOfFile:ip]
                        : nil;


                if (icon) {

                    CGSize sz =
                        CGSizeMake(30, 30);


                    UIGraphicsBeginImageContextWithOptions(
                        sz,
                        NO,
                        0
                    );


                    [icon
                        drawInRect:
                            CGRectMake(
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
                    stringByReplacingOccurrencesOfString:
                        @"uYou\n"
                    withString:
                        @"uYou\n\n"];
        }

    } @catch (id e) {}


    return lab;
}

%end


%end // gMain2



/*
 * ============================================================
 * Constructor
 * ============================================================
 */

%ctor {

    %init(gDownloadButtons);

    %init(gMain);

    %init(gPlayer);

    %init(gPlayer2);

    %init(gPlayer3);

    %init(gPlayer4);

    %init(gPlayer5);

    %init(gMain2);
}