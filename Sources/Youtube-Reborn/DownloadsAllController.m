#import "DownloadsAllController.h"
#import "Localization.h"
#import <Photos/Photos.h>

@interface DownloadsAllController ()
{
    NSString *documentsDirectory;
    NSMutableArray *filePathsAllArray;
    NSMutableArray *filePathsAllArtworkArray;
    NSCache *thumbnailCache;
}
- (void)coloursView;
- (void)setupAllArrays;
- (UIImage *)generateThumbnailForVideoAtURL:(NSURL *)videoURL;
@end

@implementation DownloadsAllController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self coloursView];

    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 44)];
    self.searchBar.delegate = self;
    self.searchBar.placeholder = LOC(@"SEARCH_TEXT");

    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithCustomView:self.searchBar];
    self.navigationItem.rightBarButtonItem = searchButton;
    self.filteredItems = [NSArray array];
    self.isSearching = NO;

    UITableViewStyle style;
    if (@available(iOS 13, *)) {
        style = UITableViewStyleInsetGrouped;
    } else {
        style = UITableViewStyleGrouped;
    }

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:style];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    [self setupAllArrays];

    thumbnailCache = [[NSCache alloc] init];

    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.tableView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [self.tableView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor],
        [self.tableView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor]
    ]];
}

- (UIImage *)generateThumbnailForVideoAtURL:(NSURL *)videoURL {
    AVAsset *asset = [AVAsset assetWithURL:videoURL];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;

    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;

    CGImageRef imageRef = [generator copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *thumbnail = [[UIImage alloc] initWithCGImage:imageRef];

    CGImageRelease(imageRef);

    return thumbnail;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    self.filteredItems = [NSArray array];
    self.isSearching = NO;
    [self.tableView reloadData];
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        searchBar.text = @"";
        self.filteredItems = [NSArray array];
        self.isSearching = NO;
        [self.tableView reloadData];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    NSString *searchText = searchBar.text;

    if (searchText.length > 0) {
        NSString *cleanSearchText = [searchText stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", cleanSearchText];
        self.filteredItems = [self.allItems filteredArrayUsingPredicate:predicate];
        self.isSearching = YES;
    } else {
        self.filteredItems = [NSArray array];
        self.isSearching = NO;
    }
    [self.tableView reloadData];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.searchBar resignFirstResponder];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isSearching) {
        return self.filteredItems.count;
    } else {
        return self.allItems.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"VideoDownloadsTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.textLabel.numberOfLines = 1;
        cell.textLabel.lineBreakMode = NSLineBreakByClipping;
        cell.detailTextLabel.numberOfLines = 1;
        cell.detailTextLabel.lineBreakMode = NSLineBreakByClipping;
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
            cell.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
            cell.textLabel.textColor = [UIColor blackColor];
            cell.detailTextLabel.textColor = [UIColor blackColor];
        }
        else {
            cell.backgroundColor = [UIColor colorWithRed:0.110 green:0.110 blue:0.118 alpha:1.0];
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.textLabel.shadowColor = [UIColor blackColor];
            cell.textLabel.shadowOffset = CGSizeMake(1.0, 1.0);
            cell.detailTextLabel.textColor = [UIColor whiteColor];
        }
    }
    cell.textLabel.text = [filePathsAllArray objectAtIndex:indexPath.row];
    cell.textLabel.frame = CGRectMake(cell.textLabel.frame.origin.x, 
                                       cell.textLabel.frame.origin.y, 
                                       cell.contentView.frame.size.width - 90, 
                                       cell.textLabel.frame.size.height);

    NSString *artworkFileName = filePathsAllArtworkArray[indexPath.row];
    UIImage *thumbnail = [thumbnailCache objectForKey:artworkFileName];

    if (thumbnail) {
        cell.imageView.image = thumbnail;
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSString *filePath = [documentsDirectory stringByAppendingPathComponent:artworkFileName];
            NSURL *fileURL = [NSURL fileURLWithPath:filePath];
            UIImage *thumbnailImage = [self generateThumbnailForVideoAtURL:fileURL];

            if (thumbnailImage) {
                [thumbnailCache setObject:thumbnailImage forKey:artworkFileName];
                dispatch_async(dispatch_get_main_queue(), ^{
                    UITableViewCell *updateCell = [tableView cellForRowAtIndexPath:indexPath];
                    if (updateCell) {
                        updateCell.imageView.image = thumbnailImage;
                    }
                });
            }
        });
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSString *currentFileName = filePathsAllArray[indexPath.row];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:currentFileName];

    AVAudioSession *audioSession = [AVAudioSession sharedInstance];

    AVPlayerViewController *playerViewController = [AVPlayerViewController new];
    playerViewController.player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:filePath]];
    playerViewController.allowsPictureInPicturePlayback = NO;
    if (@available(iOS 14.2, *)) {
        playerViewController.canStartPictureInPictureAutomaticallyFromInline = NO;
    }
    [playerViewController.player play];

    [self presentViewController:playerViewController animated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSString *currentVideoFileName = filePathsAllArray[indexPath.row];
    NSString *currentArtworkFileName = filePathsAllArtworkArray[indexPath.row];

    UIAlertController *alertMenu = [UIAlertController alertControllerWithTitle:LOC(@"OPTIONS_TEXT") message:nil preferredStyle:UIAlertControllerStyleAlert];

    [alertMenu addAction:[UIAlertAction actionWithTitle:LOC(@"IMPORT_VIDEO") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            NSURL *fileURL = [NSURL fileURLWithPath:[documentsDirectory stringByAppendingPathComponent:currentVideoFileName]];
            [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:fileURL];
        } completionHandler:^(BOOL success, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:LOC(@"NOTICE_TEXT") message:LOC(@"SAVED_VIDEO") preferredStyle:UIAlertControllerStyleAlert];
                                        
                    [alert addAction:[UIAlertAction actionWithTitle:LOC(@"OKAY_TEXT") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    }]];

                    [self presentViewController:alert animated:YES completion:nil];
                } else{
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:LOC(@"NOTICE_TEXT") message:LOC(@"SAVED_VIDEO_2") preferredStyle:UIAlertControllerStyleAlert];
                                        
                    [alert addAction:[UIAlertAction actionWithTitle:LOC(@"OKAY_TEXT") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    }]];

                    [self presentViewController:alert animated:YES completion:nil];
                }
            });
        }];
    }]];

    [alertMenu addAction:[UIAlertAction actionWithTitle:LOC(@"DELETE_VIDEO") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[NSFileManager defaultManager] removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:currentVideoFileName] error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:currentArtworkFileName] error:nil];

        UIAlertController *alertDeleted = [UIAlertController alertControllerWithTitle:LOC(@"NOTICE_TEXT") message:LOC(@"VIDEO_DELETED") preferredStyle:UIAlertControllerStyleAlert];

        [alertDeleted addAction:[UIAlertAction actionWithTitle:LOC(@"OKAY_TEXT") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [filePathsAllArray removeAllObjects];
            [filePathsAllArtworkArray removeAllObjects];
            [self setupAllArrays];
            [self.tableView reloadData];
        }]];

        [self presentViewController:alertDeleted animated:YES completion:nil];
    }]];

    [alertMenu addAction:[UIAlertAction actionWithTitle:LOC(@"CANCEL_TEXT") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];

    [self presentViewController:alertMenu animated:YES completion:nil];
}

- (void)setupAllArrays {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDirectory = [paths objectAtIndex:0];

    NSArray *filePathsList = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:documentsDirectory error:nil];
    filePathsAllArray = [[NSMutableArray alloc] init];
    filePathsAllArtworkArray = [[NSMutableArray alloc] init];
    for (id object in filePathsList) {
        if ([[object pathExtension] isEqualToString:@"mp4"] || [[object pathExtension] isEqualToString:@"mp3"] || [[object pathExtension] isEqualToString:@"m4a"]){
            [filePathsAllArray addObject:object];
            NSString *cut = [object substringToIndex:[object length]-4];
            NSString *jpg = [NSString stringWithFormat:@"%@.jpg", cut];
            [filePathsAllArtworkArray addObject:jpg];
        }
    }
    self.allItems = [NSArray arrayWithArray:filePathsAllArray];
}

- (void)coloursView {
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
        self.view.backgroundColor = [UIColor colorWithRed:0.949 green:0.949 blue:0.969 alpha:1.0];
    }
    else {
        self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [self coloursView];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

@end
