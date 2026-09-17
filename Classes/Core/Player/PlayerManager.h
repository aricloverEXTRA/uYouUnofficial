#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "MediaInformation.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PlayerManagerDelegate <NSObject>
@optional
- (void)playerManager:(id)manager didChangeStatus:(AVPlayerStatus)status;
- (void)playerManager:(id)manager didFailWithError:(NSError *)error;
- (void)playerManagerDidFinishPlaying:(id)manager;
- (void)playerManager:(id)manager didUpdateTime:(CMTime)currentTime duration:(CMTime)duration;
@end

@interface PlayerManager : NSObject

@property (nonatomic, weak) id<PlayerManagerDelegate> delegate;
@property (nonatomic, strong, readonly) AVPlayer *player;
@property (nonatomic, strong, readonly) AVPlayerItem *currentItem;
@property (nonatomic, assign, readonly) BOOL isPlaying;
@property (nonatomic, assign, readonly) CMTime currentTime;
@property (nonatomic, assign, readonly) CMTime duration;
@property (nonatomic, strong, nullable) id currentVideo;
@property (nonatomic, copy) NSString *playerID;

+ (instancetype)sharedManager;
+ (instancetype)sharedInstance;

- (void)playWithMediaInformation:(MediaInformation *)mediaInfo;
- (void)playWithURL:(NSURL *)url;
- (void)pause;
- (void)play;
- (BOOL)isPlaying;
- (BOOL)isPaused;
- (void)setSource:(nullable id)source;
- (float)progress;
- (void)seekToTime:(CMTime)time completionHandler:(void (^)(BOOL finished))completion;
- (void)setRate:(float)rate;
- (void)setVolume:(float)volume;

@end

NS_ASSUME_NONNULL_END