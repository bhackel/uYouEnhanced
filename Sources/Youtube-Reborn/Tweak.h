// #import <LocalAuthentication/LocalAuthentication.h>
// #import <Foundation/Foundation.h>
// #import <CaptainHook/CaptainHook.h>
// #import <objc/runtime.h>
// #import <UIKit/UIKit.h>
// #import <YouTubeExtractor/YouTubeExtractor.h>
// #import <dlfcn.h>
// #import <rootless.h>
// #import "Controllers/RootOptionsController.h"
// #import "Controllers/PictureInPictureController.h"
// #import "Controllers/YouTubeDownloadController.h"
// #import "Controllers/ReorderPivotBarController.h"
// // YT Headers
// #import "YouTubeHeader/ASCollectionElement.h"
// #import "YouTubeHeader/ASCollectionView.h"
// #import "YouTubeHeader/ELMCellNode.h"
// #import "YouTubeHeader/ELMContainerNode.h"
// #import "YouTubeHeader/ELMNodeController.h"
// #import "YouTubeHeader/QTMIcon.h"
// #import "YouTubeHeader/YTColor.h"
// #import "YouTubeHeader/YTColorPalette.h"
// #import "YouTubeHeader/YTCommonColorPalette.h"
// #import "YouTubeHeader/YTPageStyleController.h"
// #import "YouTubeHeader/YTHotConfig.h"
// #import "YouTubeHeader/YTVideoQualitySwitchOriginalController.h"
// #import "YouTubeHeader/YTVideoWithContextNode.h"
// #import "YouTubeHeader/YTIElementRenderer.h"
// #import "YouTubeHeader/YTISectionListRenderer.h"
// #import "YouTubeHeader/YTWatchNextResultsViewController.h"
// #import "YouTubeHeader/YTIMenuConditionalServiceItemRenderer.h"
// #import "YouTubeHeader/YTPlaybackStrippedWatchController.h"
// #import "YouTubeHeader/YTSlimVideoDetailsActionView.h"
// #import "YouTubeHeader/YTSlimVideoScrollableActionBarCellController.h"
// #import "YouTubeHeader/YTSlimVideoScrollableDetailsActionsView.h"
// #import "YouTubeHeader/YTTouchFeedbackController.h"
// #import "YouTubeHeader/YTWatchViewController.h"
// // YT Headers - snackbar
// #import "YouTubeHeader/YTHUDMessage.h"
// #import "YouTubeHeader/GOOHUDManagerInternal.h"

// @interface YTPlaybackButton : UIControl
// @end

// @interface ABCSwitch : UISwitch
// @end

// @interface YTTopAlignedView : UIView
// @end

// @interface YTCommentDetailHeaderCell : UIView
// @end

@interface ASCollectionView (Reborn)
- (id)_viewControllerForAncestor;
@property (retain, nonatomic) UIButton *rebornOverlayButton;
@property (retain, nonatomic) YTTouchFeedbackController *rebornTouchController;
- (id)playPauseButton;
- (void)didPressPause:(id)button;
- (void)didPressReborn:(UIButton *)button event:(UIEvent *)event;
- (void)rebornOptionsAction;
- (void)rebornVideoDownloader :(NSString *)videoID;
- (void)rebornAudioDownloader :(NSString *)videoID;
- (void)rebornPictureInPicture :(NSString *)videoID;
- (void)rebornPlayInExternalApp :(NSString *)videoID;
@end

// @interface ASCollectionView (YP) // YouPiP
// @property (retain, nonatomic) UIButton *pipButton;
// - (void)didPressPiP:(id)arg;
// - (UIImage *)pipImage;
// @end

// @interface _ASCollectionViewCell : UICollectionViewCell
// - (id)node;
// @end

// @interface YTAsyncCollectionView : UICollectionView
// - (void)removeCellsAtIndexPath:(NSIndexPath *)indexPath;
// @end

// @interface YTITopbarLogoRenderer : NSObject // Enable Premium logo - @bhackel
// @property(readonly, nonatomic) YTIIcon *iconImage;
// @end

// @interface YTRightNavigationButtons : UIView
// - (id)_viewControllerForAncestor;
// @property(readonly, nonatomic) YTQTMButton *MDXButton;
// @property(readonly, nonatomic) YTQTMButton *searchButton;
// @property(readonly, nonatomic) YTQTMButton *notificationButton;
// @property(strong, nonatomic) YTQTMButton *youtubeRebornButton;
// - (void)setLeadingPadding:(CGFloat)arg1;
// - (void)rebornRootOptionsAction;
// @end

// @interface YTMainAppControlsOverlayView : UIView
// - (id)_viewControllerForAncestor;
// @property(readonly, nonatomic) YTQTMButton *playbackRouteButton;
// @property(readonly, nonatomic) YTQTMButton *previousButton;
// @property(readonly, nonatomic) YTQTMButton *nextButton;
// @property(readonly, nonatomic) ABCSwitch *autonavSwitch;
// @property(readonly, nonatomic) YTQTMButton *closedCaptionsOrSubtitlesButton;
// @property(strong, nonatomic) UIButton *rebornOverlayButton;
// - (id)playPauseButton;
// - (void)didPressPause:(id)button;
// - (void)rebornOptionsAction;
// - (void)rebornVideoDownloader :(NSString *)videoID;
// - (void)rebornAudioDownloader :(NSString *)videoID;
// - (void)rebornPictureInPicture :(NSString *)videoID;
// - (void)rebornPlayInExternalApp :(NSString *)videoID;
// @end

// @interface YTMainAppSkipVideoButton
// @property(readonly, nonatomic) UIImageView *imageView;
// @end

// @interface YTPlayerView (Reborn)
// - (void)downloadVideo;
// @end

// @interface YTLocalPlaybackController : NSObject
// - (NSString *)currentVideoID;
// @end

// @interface YTMainAppVideoPlayerOverlayViewController : UIViewController
// - (CGFloat)mediaTime;
// - (int)playerViewLayout;
// - (NSInteger)playerState;
// @end

// @interface YTUserDefaults : NSObject
// - (long long)appThemeSetting;
// @end

// @interface YTWatchController : NSObject
// - (void)showFullScreen;
// @end

// @interface YTSingleVideoTime : NSObject
// @end

// @interface MLHAMQueuePlayer : NSObject
// @property id playerEventCenter;
// -(void)setRate:(float)rate;
// @end

// @interface YTVarispeedSwitchControllerOption : NSObject
// - (id)initWithTitle:(id)title rate:(float)rate;
// @end

// @interface HAMPlayerInternal : NSObject
// - (void)setRate:(float)rate;
// @end

// @interface MLPlayerEventCenter : NSObject
// - (void)broadcastRateChange:(float)rate;
// @end

// @interface YTPivotBarView : UIView
// @end

// @interface YTPivotBarIndicatorView : UIView
// @end

// @interface YTPivotBarViewController : UIViewController
// - (void)selectItemWithPivotIdentifier:(id)pivotIndentifier;
// @end

// @interface YTPivotBarItemView : UIView
// @property(readonly, nonatomic) YTQTMButton *navigationButton;
// @end

// @interface YTReelHeaderView : UIView
// - (id)_viewControllerForAncestor;
// - (void)rebornOptionsAction;
// - (void)rebornVideoDownloader :(NSString *)videoID;
// - (void)rebornAudioDownloader :(NSString *)videoID;
// - (void)rebornPictureInPicture :(NSString *)videoID;
// - (void)rebornPlayInExternalApp :(NSString *)videoID;
// @end

// @interface YTReelPlayerMoreButton : YTQTMButton
// @end

// @interface YTReelPlayerButton : UIButton
// @end

// @interface YTReelWatchPlaybackOverlayView : UIView
// @end

// @interface YTReelTransparentStackView : UIView
// @end

// @interface YTTransportControlsButtonView : UIView
// @end

// @interface SSOConfiguration : NSObject
// @end

// @interface _ASDisplayView : UIView
// @end

// @interface YTLabel : UILabel
// @end

// @interface YTInlinePlayerBarContainerView : UIView
// @property(readonly, nonatomic) YTLabel *durationLabel;
// @property(readonly, nonatomic) YTLabel *currentTimeLabel;
// @end

// // YouTube Reborn Settings
// @interface FRPreferences : UITableViewController
// @end

// @interface FRPSelectListTable : UITableViewController
// @end

// @interface settingsReorderTable : UIViewController
// @property(nonatomic, strong) UITableView *tableView;
// @end

// @interface SponsorBlockSettingsController : UITableViewController
// @end

// @interface SponsorBlockViewController : UIViewController
// @end
