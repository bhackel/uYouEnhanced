#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FFMpegDownloader.h"

#define STYLE_LIGHT_TEXT 15
#define SIZE_DEFAULT 1

@interface UIView (NearestViewController)
- (UIViewController *)nearestViewController;
@end

@implementation UIView (NearestViewController)
- (UIViewController *)nearestViewController {
    UIResponder *responder = self.nextResponder;
    while (responder) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        } responder = responder.nextResponder;
    } return nil;
}
@end

@interface YTIFormatStream : NSObject
@property (nonatomic, copy, readwrite) NSString *URL;
@end

@interface YTIStreamingData : NSObject
@property (nonatomic, copy, readwrite) NSString *hlsManifestURL;
@property (nonatomic, copy, readwrite) NSMutableArray *adaptiveFormatsArray;
@end

@interface YTIThumbnailDetails_Thumbnail : NSObject
@property (nonatomic, copy, readwrite) NSString *URL;
@property (nonatomic, assign, readwrite) unsigned int width;
@end

@interface YTIThumbnailDetails : NSObject
@property (nonatomic, strong, readwrite) NSMutableArray *thumbnailsArray;
@end

@interface YTIVideoDetails : NSObject
@property (nonatomic, copy, readwrite) NSString *title;
@property (nonatomic, copy, readwrite) NSString *author;
@property (nonatomic, strong, readwrite) YTIThumbnailDetails *thumbnail;
@end

@interface YTIPlayerResponse : NSObject
@property (nonatomic, assign, readonly) YTIStreamingData *streamingData;
@property (nonatomic, assign, readonly) YTIVideoDetails *videoDetails;
@end

@interface YTPlayerResponse : NSObject
@property (nonatomic, assign, readonly) YTIPlayerResponse *playerData;
@end

@interface YTPlayerViewController : UIViewController
@property (nonatomic, assign, readonly) YTPlayerResponse *playerResponse;
@property (readonly, nonatomic) NSString *contentVideoID;
@property (nonatomic, assign, readonly) CGFloat currentVideoTotalMediaTime;
@end

@interface YTPlayerView : UIView
@property (nonatomic, strong) FFMpegDownloader *ffmpeg;
@property (nonatomic, assign, readwrite) UIViewController *viewDelegate;
- (void)prepareForDownloading:(UILongPressGestureRecognizer *)sender;
@end

@interface YTMWatchViewController : UIViewController
@property (nonatomic, weak, readwrite) YTPlayerViewController *playerViewController;
@end

@interface YTMNowPlayingViewController : UIViewController
@property (nonatomic, weak, readwrite) YTMWatchViewController *parentViewController;
@end

@interface YTAlertView : UIView
@property (nonatomic, copy, readwrite) NSString *title;
@property (nonatomic, copy, readwrite) NSString *subtitle;
+ (instancetype)infoDialog;
+ (instancetype)confirmationDialogWithAction:(void (^)(void))action actionTitle:(NSString *)actionTitle;
- (void)show;
@end

@interface YTPageStyleController : NSObject
+ (YTCommonColorPalette *)currentColorPalette;
+ (NSInteger)pageStyle;
@property (nonatomic, assign, readwrite) NSInteger appThemeSetting;
@property (nonatomic, assign, readonly) NSInteger pageStyle;
@end

@interface QTMIcon: NSObject
+ (UIImage *)imageWithName:(NSString *)name color:(UIColor *)color;
+ (UIImage *)tintImage:(UIImage *)image color:(UIColor *)color;
@end
