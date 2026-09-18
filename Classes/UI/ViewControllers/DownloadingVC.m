#import "DownloadingVC.h"
#import "DownloadsManager.h"
#import "DownloadItem.h"

@interface DownloadingCell : UITableViewCell
@property (nonatomic, strong) UIImageView *thumbnailImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UIButton *cancelButton;
@end

@implementation DownloadingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor systemBackgroundColor];
        self.contentView.backgroundColor = [UIColor systemBackgroundColor];

        _thumbnailImageView = [[UIImageView alloc] init];
        _thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbnailImageView.clipsToBounds = YES;
        _thumbnailImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_thumbnailImageView];

        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.numberOfLines = 2;
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_titleLabel];

        _progressLabel = [[UILabel alloc] init];
        _progressLabel.font = [UIFont systemFontOfSize:12];
        _progressLabel.textColor = [UIColor secondaryLabelColor];
        _progressLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_progressLabel];

        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_progressView];

        _cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        _cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_cancelButton];

        [NSLayoutConstraint activateConstraints:@[
            [_thumbnailImageView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
            [_thumbnailImageView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
            [_thumbnailImageView.widthAnchor constraintEqualToConstant:80],
            [_thumbnailImageView.heightAnchor constraintEqualToConstant:45],

            [_titleLabel.leadingAnchor constraintEqualToAnchor:_thumbnailImageView.trailingAnchor constant:12],
            [_titleLabel.trailingAnchor constraintEqualToAnchor:_cancelButton.leadingAnchor constant:-8],
            [_titleLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:12],

            [_progressLabel.leadingAnchor constraintEqualToAnchor:_titleLabel.leadingAnchor],
            [_progressLabel.topAnchor constraintEqualToAnchor:_titleLabel.bottomAnchor constant:4],

            [_progressView.leadingAnchor constraintEqualToAnchor:_titleLabel.leadingAnchor],
            [_progressView.trailingAnchor constraintEqualToAnchor:_cancelButton.leadingAnchor constant:-8],
            [_progressView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-8],
            [_progressView.heightAnchor constraintEqualToConstant:2],

            [_cancelButton.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
            [_cancelButton.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
            [_cancelButton.widthAnchor constraintEqualToConstant:60],
            [_cancelButton.heightAnchor constraintEqualToConstant:30],
        ]];
    }
    return self;
}

@end

@interface DownloadingVC () <UITableViewDataSource, UITableViewDelegate, DownloadsManagerDelegate>

@property (nonatomic, strong) NSArray *downloads;

@end

@implementation DownloadingVC

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = @"Downloading";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView registerClass:[DownloadingCell class] forCellReuseIdentifier:@"DownloadingCell"];
    [self.view addSubview:_tableView];

    [[DownloadsManager sharedManager] setDelegate:self];
    [self loadDownloads];
}

- (void)loadDownloads {
    _downloads = [[DownloadsManager sharedManager] activeDownloads];
    [_tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _downloads.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DownloadingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DownloadingCell" forIndexPath:indexPath];
    DownloadItem *download = _downloads[indexPath.row];
    cell.titleLabel.text = download.title;
    cell.progressLabel.text = [NSString stringWithFormat:@"%.0f%%", download.progress * 100];
    cell.progressView.progress = download.progress;
    return cell;
}

- (void)downloadsManager:(id)manager didAddDownload:(DownloadItem *)download {
    [self loadDownloads];
}

- (void)downloadsManager:(id)manager didUpdateDownload:(DownloadItem *)download {
    [self loadDownloads];
}

- (void)downloadsManager:(id)manager didRemoveDownload:(DownloadItem *)download {
    [self loadDownloads];
}

- (void)downloadsManager:(id)manager didChangeStatus:(DownloadItem *)download {
    [self loadDownloads];
}

- (void)updatePageStyles {
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    _tableView.backgroundColor = [UIColor systemBackgroundColor];
    [_tableView reloadData];
}

@end