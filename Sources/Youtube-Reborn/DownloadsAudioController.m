#import "DownloadsAudioController.h"
#import "Localization.h"

@interface DownloadsAudioController ()
{
    NSString *documentsDirectory;
    NSMutableArray *filePathsAudioArray;
    NSMutableArray *filePathsAudioArtworkArray;
}
- (void)coloursView;
- (void)setupAudioArrays;
@end

@implementation DownloadsAudioController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self coloursView];

    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *error = nil;
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:&error];
    if (error) {
        NSLog(@"Failed to set audio session category: %@", error);
    }

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
    self.tableView.interactions = @[ [[UIDropInteraction alloc] initWithDelegate:self] ];
    [self.view addSubview:self.tableView];
    [self setupAudioArrays];

    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.tableView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [self.tableView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor],
        [self.tableView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor]
    ]];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    NSString *fileName = self.isSearching ? self.filteredItems[indexPath.row] : self.allItems[indexPath.row];

    if (indexPath.section == 0 && indexPath.row < filePathsAudioArray.count) {
        cell.textLabel.text = [filePathsAudioArray[indexPath.row] stringByDeletingPathExtension];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", [fileName pathExtension], [self getFileCreationDateAtIndex:indexPath.row]];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.25];
        documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];

        NSString *imageName = [NSString stringWithFormat:@"%@.png", [filePathsAudioArray[indexPath.row] stringByDeletingPathExtension]];
        UIImage *image = [UIImage imageWithContentsOfFile:[documentsDirectory stringByAppendingPathComponent:imageName]];
        CGFloat targetSize = 37.5;
        CGFloat scaleFactor = targetSize / MAX(image.size.width, image.size.height);
        CGSize scaledSize = CGSizeMake(image.size.width * scaleFactor, image.size.height * scaleFactor);
        UIGraphicsBeginImageContextWithOptions(scaledSize, NO, 0.0);
        [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, scaledSize.width, scaledSize.height) cornerRadius:6] addClip];
        [image drawInRect:CGRectMake(0, 0, scaledSize.width, scaledSize.height)];
        UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        roundedImage = [roundedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        cell.imageView.image = roundedImage;
    }

    return cell;
}

- (NSString *)getFileCreationDateAtIndex:(NSInteger)index {
    NSString *fileName = filePathsAudioArray[index];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
    NSDate *creationDate = [attributes objectForKey:NSFileCreationDate];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [formatter stringFromDate:creationDate];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSString *currentFileName = filePathsAudioArray[indexPath.row];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:currentFileName];

    AVPlayerViewController *playerViewController = [AVPlayerViewController new];
    playerViewController.player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:filePath]];
    playerViewController.allowsPictureInPicturePlayback = NO;
    if (@available(iOS 14.2, *)) {
        playerViewController.canStartPictureInPictureAutomaticallyFromInline = NO;
    }
    [playerViewController.player play];

    [self presentViewController:playerViewController animated:YES completion:nil];
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    UIContextualAction *moreAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal
                                                                             title:LOC(@"MORE_TEXT")
                                                                           handler:^(UIContextualAction *action, __kindof UIView *sourceView, void (^completionHandler)(BOOL)) {
        NSString *currentAudioFileName = filePathsAudioArray[indexPath.row];
        NSString *currentArtworkFileName = filePathsAudioArtworkArray[indexPath.row];

        UIAlertController *alertMenu = [UIAlertController alertControllerWithTitle:LOC(@"OPTIONS_TEXT") message:nil preferredStyle:UIAlertControllerStyleAlert];

        [alertMenu addAction:[UIAlertAction actionWithTitle:LOC(@"EDIT_FILE_NAME") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

            UIAlertController *editAlert = [UIAlertController alertControllerWithTitle:LOC(@"EDIT_FILE_NAME") message:nil preferredStyle:UIAlertControllerStyleAlert];

            [editAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.placeholder = currentAudioFileName;
                textField.text = [currentAudioFileName stringByDeletingPathExtension];
            }];

            [editAlert addAction:[UIAlertAction actionWithTitle:LOC(@"SAVE_TEXT") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                UITextField *textField = editAlert.textFields.firstObject;
                NSString *newFileName = textField.text;

                NSString *newAudioFileName = [[newFileName stringByAppendingString:@"."] stringByAppendingString:[currentAudioFileName pathExtension]];
                NSString *newArtworkFileName = [[newFileName stringByAppendingString:@"."] stringByAppendingString:[currentArtworkFileName pathExtension]];

                [[NSFileManager defaultManager] moveItemAtPath:[documentsDirectory stringByAppendingPathComponent:currentAudioFileName] toPath:[documentsDirectory stringByAppendingPathComponent:newAudioFileName] error:nil];
                [[NSFileManager defaultManager] moveItemAtPath:[documentsDirectory stringByAppendingPathComponent:currentArtworkFileName] toPath:[documentsDirectory stringByAppendingPathComponent:newArtworkFileName] error:nil];

                [filePathsAudioArray replaceObjectAtIndex:indexPath.row withObject:newAudioFileName];
                [filePathsAudioArtworkArray replaceObjectAtIndex:indexPath.row withObject:newArtworkFileName];
                [self.tableView reloadData];
            }];

            [editAlert addAction:[UIAlertAction actionWithTitle:LOC(@"CANCEL_TEXT") style:UIAlertActionStyleCancel handler:nil]];

            [self presentViewController:editAlert animated:YES completion:nil];
        }];

        [alertMenu addAction:[UIAlertAction actionWithTitle:LOC(@"EXPORT_FILE") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSString *currentAudioFileName = filePathsAudioArray[indexPath.row];

            UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.audio"] inMode:UIDocumentPickerModeExportToService];
            documentPicker.delegate = self;
            documentPicker.title = currentAudioFileName.lastPathComponent;
            [self presentViewController:documentPicker animated:YES completion:nil];
        }];

        [alertMenu addAction:[UIAlertAction actionWithTitle:LOC(@"DELETE_AUDIO") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[NSFileManager defaultManager] removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:currentAudioFileName] error:nil];
            [[NSFileManager defaultManager] removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:currentArtworkFileName] error:nil];

            UIAlertController *alertDeleted = [UIAlertController alertControllerWithTitle:LOC(@"NOTICE_TEXT") message:LOC(@"AUDIO_DELETED") preferredStyle:UIAlertControllerStyleAlert];

            [alertDeleted addAction:[UIAlertAction actionWithTitle:LOC(@"OKAY_TEXT") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [filePathsAudioArray removeAllObjects];
                [filePathsAudioArtworkArray removeAllObjects];
                [self setupAudioArrays];
                [self.tableView reloadData];
            }];

            [self presentViewController:alertDeleted animated:YES completion:nil];
        }];

        [alertMenu addAction:[UIAlertAction actionWithTitle:LOC(@"CANCEL_TEXT") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        }];

        [self presentViewController:alertMenu animated:YES completion:nil];
    }];
    moreAction.image = [UIImage systemImageNamed:@"ellipsis"];
    moreAction.backgroundColor = self.view.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ? [UIColor systemBlueColor] : [[UIColor systemBlueColor] colorWithAlphaComponent:0.8];

    UISwipeActionsConfiguration *configuration = [UISwipeActionsConfiguration configurationWithActions:@[moreAction]];
    configuration.performsFirstActionWithFullSwipe = NO;

    return configuration;
}

- (void)setupAudioArrays {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDirectory = [paths objectAtIndex:0];

    NSArray *filePathsList = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:documentsDirectory error:nil];
    filePathsAudioArray = [[NSMutableArray alloc] init];
    filePathsAudioArtworkArray = [[NSMutableArray alloc] init];
    for (id object in filePathsList) {
        if ([[object pathExtension] isEqualToString:@"m4a"] || [[object pathExtension] isEqualToString:@"mp3"]){
            [filePathsAudioArray addObject:object];
            NSString *cut = [object substringToIndex:[object length]-4];
            NSString *jpg = [NSString stringWithFormat:@"%@.jpg", cut];
            [filePathsAudioArtworkArray addObject:jpg];
        }
    }
    self.allItems = [NSArray arrayWithArray:filePathsAudioArray];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    for (NSURL *url in urls) {
        NSString *importedFileName = [url lastPathComponent];
        NSString *newAudioFilePath = [documentsDirectory stringByAppendingPathComponent:importedFileName];

        if ([[NSFileManager defaultManager] fileExistsAtPath:newAudioFilePath]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:LOC(@"IMPORT_ERROR") message:LOC(@"FILE_ALREADY_IMPORTED") preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:LOC(@"OKAY_TEXT") style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            [[NSFileManager defaultManager] copyItemAtURL:url toURL:[NSURL fileURLWithPath:newAudioFilePath] error:nil];

            UIAlertController *alert = [UIAlertController alertControllerWithTitle:LOC(@"SUCCESSFULLY_IMPORTED_FILE") message:@"" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:LOC(@"OKAY_TEXT") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self setupAudioArrays];
                [self.tableView reloadData];
            }];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}

- (void)exportFile {
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    if (selectedIndexPath) {
        [self exportFileAtIndexPath:selectedIndexPath];
    }
}

- (void)exportFileAtIndexPath:(NSIndexPath *)indexPath {
    NSString *currentAudioFileName = filePathsAudioArray[indexPath.row];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:currentAudioFileName];

    UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithURL:[NSURL fileURLWithPath:filePath] inMode:UIDocumentPickerModeExportToService];
    documentPicker.delegate = self;
    documentPicker.title = currentAudioFileName.lastPathComponent;
    documentPicker.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:documentPicker animated:YES completion:nil];
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

@end
