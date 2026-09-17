#import "DownloadsManager.h"
#import "DownloadItem.h"
#import "MediaKit/UYTMediaKit.h"
#import <sqlite3.h>
#import <HBLog.h>

@protocol UYouLegacyDownloadItem <NSObject>
@optional
- (NSString *)tmpAudioPath;
- (NSString *)cachedAudioPath;
- (NSString *)tmpVideoPath;
- (NSString *)cachedVideoPath;
- (NSString *)filePath;
- (void)setTmpAudioPath:(NSString *)path;
@end

@protocol UYouLegacyDownloadContainer <NSObject>
@optional
- (id<UYouLegacyDownloadItem>)uYouItem;
@end

// Baked-in fixes from uYouPatches.xm — no external patch dylib needed.
// This file augments DownloadsManager with webm→m4a conversion, ffmpeg remux,
// stall watchdog, and DB finalization. The original DownloadsManager.m stays
// untouched except for calling these helpers at the right points.

static BOOL UYouPathIsWebm(NSString *path) {
    return path.length > 0 && [path.pathExtension.lowercaseString isEqualToString:@"webm"];
}

static NSString *UYouAudioPathForItem(id ui) {
    if (!ui) return nil;
    id<UYouLegacyDownloadItem> item = ui;
    if ([item respondsToSelector:@selector(tmpAudioPath)]) {
        NSString *p = [item tmpAudioPath];
        if (p.length) return p;
    }
    if ([item respondsToSelector:@selector(cachedAudioPath)]) return [item cachedAudioPath];
    return nil;
}

static BOOL UYouConvertWebmToM4a(NSString *webm, NSString *m4a) {
    if (!webm || !m4a) return NO;
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:webm]) return NO;
    if ([fm fileExistsAtPath:m4a]) [fm removeItemAtPath:m4a error:nil];
    if (UYTFFActiveBackend() == UYTFFBackendNone) return NO;
    BOOL ok = UYTFFConvertWebmAudioToM4a(webm, m4a);
    if (ok && [fm fileExistsAtPath:m4a]) {
        unsigned long long sz = [[fm attributesOfItemAtPath:m4a error:nil] fileSize];
        if (sz > 0) return YES;
    }
    return NO;
}

@implementation DownloadsManager (UYouFixes)

- (BOOL)uyou_ensureMergeableAudioForItem:(id)item phase:(NSString *)phase {
    @try {
        id ui = item;
        id<UYouLegacyDownloadContainer> container = item;
        if ([container respondsToSelector:@selector(uYouItem)]) {
            @try { ui = [container uYouItem]; } @catch (id e) {}
        }
        NSString *audioPath = UYouAudioPathForItem(ui);
        if (!audioPath.length) return YES;
        if (!UYouPathIsWebm(audioPath)) return YES;
        NSString *m4a = [[audioPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"m4a"];
        if (UYouConvertWebmToM4a(audioPath, m4a)) {
            @try {
                id<UYouLegacyDownloadItem> legacy = ui;
                if ([legacy respondsToSelector:@selector(setTmpAudioPath:)]) {
                    [legacy setTmpAudioPath:m4a];
                } else {
                    [ui setValue:m4a forKey:@"tmpAudioPath"];
                }
            } @catch (id e) {}
            HBLogInfo(@"[uYou] %@: webm→m4a done", phase);
            return YES;
        }
        HBLogWarn(@"[uYou] %@: webm→m4a failed", phase);
        return NO;
    } @catch (NSException *e) { return NO; }
}

- (BOOL)uyou_remuxWithFFmpegForItem:(id)item phase:(NSString *)phase {
    @try {
        id ui = item;
        id<UYouLegacyDownloadContainer> container = item;
        if ([container respondsToSelector:@selector(uYouItem)]) { @try { ui = [container uYouItem]; } @catch (id e) {} }
        NSFileManager *fm = [NSFileManager defaultManager];
        id<UYouLegacyDownloadItem> legacy = ui;
        NSString *vPath = nil, *aPath = nil;
        if ([legacy respondsToSelector:@selector(tmpVideoPath)]) vPath = [legacy tmpVideoPath];
        if (!vPath.length && [legacy respondsToSelector:@selector(cachedVideoPath)]) vPath = [legacy cachedVideoPath];
        if ([legacy respondsToSelector:@selector(tmpAudioPath)]) aPath = [legacy tmpAudioPath];
        if (!aPath.length && [legacy respondsToSelector:@selector(cachedAudioPath)]) aPath = [legacy cachedAudioPath];
        NSString *final = [legacy respondsToSelector:@selector(filePath)] ? [legacy filePath] : nil;
        if (!vPath.length || !aPath.length || !final.length) return NO;
        if (![fm fileExistsAtPath:vPath] || ![fm fileExistsAtPath:aPath]) return NO;
        if (UYTFFActiveBackend() == UYTFFBackendNone) return NO;
        NSString *tmpOut = [final stringByAppendingString:@".merging.mp4"];
        if ([fm fileExistsAtPath:tmpOut]) [fm removeItemAtPath:tmpOut error:nil];
        BOOL ok = UYTFFSmartRemuxToMP4(vPath, aPath, tmpOut);
        NSDictionary *attrs = [fm attributesOfItemAtPath:tmpOut error:nil];
        if (ok && attrs && [attrs fileSize] > 0) {
            if ([fm fileExistsAtPath:final]) [fm removeItemAtPath:final error:nil];
            NSError *err = nil;
            if ([fm moveItemAtPath:tmpOut toPath:final error:&err]) return YES;
            HBLogWarn(@"[uYou] %@: remux move failed %@", phase, err);
        } else {
            [fm removeItemAtPath:tmpOut error:nil];
        }
    } @catch (NSException *e) {}
    return NO;
}

@end
