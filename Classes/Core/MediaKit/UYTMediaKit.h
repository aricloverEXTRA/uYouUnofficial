// UYTMediaKit — FFmpegKitNext wrapper for the download pipeline.
//
// Backend: FFmpegKitNext (ffmpegkit.framework embedded in the app — dlopen'd)
// All calls are synchronous and safe from background queues.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// Backend identifiers used internally by UYTMediaKit.m.
typedef NS_ENUM(NSInteger, UYTFFBackend) {
    UYTFFBackendNone = 0,
    UYTFFBackendKitNext = 1,
};

#ifdef __cplusplus
extern "C" {
#endif

/// Returns the currently available FFmpeg backend.
NSInteger UYTFFActiveBackend(void);

/// Run an ffmpeg command via FFmpegKitNext. Returns YES when the exit code is 0.
BOOL UYTFFRun(NSArray<NSString *> *arguments);

/// Convert a .webm audio track to .m4a (AAC).
BOOL UYTFFConvertWebmAudioToM4a(NSString *webmPath, NSString *m4aPath);

/// Stream-copy remux video+audio into an mp4 at outputPath.
BOOL UYTFFRemuxVideoAudioToMP4(
    NSString *videoPath,
    NSString *audioPath,
    NSString *outputPath
);

/// Re-encode a .webm (VP9/Opus) video to .mp4 (H.264/AAC).
/// Uses libx264 first and falls back to VideoToolbox.
BOOL UYTFFConvertWebmVideoToMp4(
    NSString *webmPath,
    NSString *mp4Path
);

/// Remux video+audio into mp4, converting WebM streams when necessary.
BOOL UYTFFSmartRemuxToMP4(
    NSString *videoPath,
    NSString *audioPath,
    NSString *outputPath
);

#ifdef __cplusplus
} // extern "C"
#endif

NS_ASSUME_NONNULL_END
