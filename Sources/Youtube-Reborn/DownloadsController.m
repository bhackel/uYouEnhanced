#import "DownloadsController.h"
#import "DownloadsAllController.h"
#import "DownloadsVideoController.h"
#import "DownloadsAudioController.h"
#import "Localization.h"

@interface DownloadsController ()
- (void)configureUI;
- (void)doneButtonTapped;
@end

@implementation DownloadsController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUI];
}

- (void)configureUI {
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    UINavigationBarAppearance *navigationBarAppearance = [[UINavigationBarAppearance alloc] init];
    navigationBarAppearance.backgroundColor = [UIColor systemBackgroundColor];
    navigationBarAppearance.backgroundEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterial];

    [self.navigationController.navigationBar setStandardAppearance:navigationBarAppearance];
    [self.navigationController.navigationBar setScrollEdgeAppearance:navigationBarAppearance];

    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor labelColor], NSFontAttributeName:[UIFont systemFontOfSize:18]}];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;

    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonTapped)];
    self.navigationItem.leftBarButtonItem = doneButton;

    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.delegate = self;

    DownloadsAllController *allDownloadsViewController = [[DownloadsAllController alloc] init];
    allDownloadsViewController.title = LOC(@"ALL_TAB");
    allDownloadsViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:LOC(@"ALL_TAB") image:[UIImage systemImageNamed:@"folder.fill"] tag:0];
    UINavigationController *allDownloadsNavViewController = [[UINavigationController alloc] initWithRootViewController:allDownloadsViewController];

    DownloadsVideoController *videoViewController = [[DownloadsVideoController alloc] init];
    videoViewController.title = LOC(@"VIDEO_TAB");
    videoViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:LOC(@"VIDEO_TAB") image:[UIImage systemImageNamed:@"video.circle.fill"] tag:1];
    UINavigationController *videoNavViewController = [[UINavigationController alloc] initWithRootViewController:videoViewController];

    DownloadsAudioController *audioViewController = [[DownloadsAudioController alloc] init];
    audioViewController.title = LOC(@"AUDIO_TAB");
    audioViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:LOC(@"AUDIO_TAB") image:[UIImage systemImageNamed:@"music.note"] tag:2];
    UINavigationController *audioNavViewController = [[UINavigationController alloc] initWithRootViewController:audioViewController];

    self.tabBarController.viewControllers = @[allDownloadsNavViewController, videoNavViewController, audioNavViewController];
    [self addChildViewController:self.tabBarController];
    self.tabBarController.view.frame = self.view.bounds;
    [self.view addSubview:self.tabBarController.view];
    [self.tabBarController didMoveToParentViewController:self];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    UIView *selectedItemView = [tabBarController.tabBar.subviews objectAtIndex:tabBarController.selectedIndex + 1];
    selectedItemView.backgroundColor = [UIColor systemBlueColor];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [self configureUI];
}

- (void)doneButtonTapped {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
