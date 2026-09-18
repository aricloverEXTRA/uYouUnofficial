#import "DownloadedVC.h"
#import "DownloadsManager.h"
#import "DownloadItem.h"

@interface DownloadedCell : UITableViewCell
@property (nonatomic, strong) UIImageView *thumbnailImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIProgressView *progressView;
@end

@implementation DownloadedCell

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

        _statusLabel = [[UILabel alloc] init];
        _statusLabel.font = [UIFont systemFontOfSize:12];
        _statusLabel.textColor = [UIColor secondaryLabelColor];
        _statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_statusLabel];

        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_progressView];

        [NSLayoutConstraint activateConstraints:@[
            [_thumbnailImageView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
            [_thumbnailImageView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
            [_thumbnailImageView.widthAnchor constraintEqualToConstant:80],
            [_thumbnailImageView.heightAnchor constraintEqualToConstant:45],

            [_titleLabel.leadingAnchor constraintEqualToAnchor:_thumbnailImageView.trailingAnchor constant:12],
            [_titleLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
            [_titleLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:12],

            [_statusLabel.leadingAnchor constraintEqualToAnchor:_titleLabel.leadingAnchor],
            [_statusLabel.trailingAnchor constraintEqualToAnchor:_titleLabel.trailingAnchor],
            [_statusLabel.topAnchor constraintEqualToAnchor:_titleLabel.bottomAnchor constant:4],

            [_progressView.leadingAnchor constraintEqualToAnchor:_titleLabel.leadingAnchor],
            [_progressView.trailingAnchor constraintEqualToAnchor:_titleLabel.trailingAnchor],
            [_progressView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-8],
            [_progressView.heightAnchor constraintEqualToConstant:2],
        ]];
    }
    return self;
}

@end

@interface DownloadedVC () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *downloads;

@end

@implementation DownloadedVC

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = @"Downloaded";
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
    [_tableView registerClass:[DownloadedCell class] forCellReuseIdentifier:@"DownloadedCell"];
    [self.view addSubview:_tableView];

    [self loadDownloads];
}

- (void)loadDownloads {
    _downloads = [[DownloadsManager sharedManager] completedDownloads];
    [_tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _downloads.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DownloadedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DownloadedCell" forIndexPath:indexPath];
    DownloadItem *download = _downloads[indexPath.row];
    cell.titleLabel.text = download.title;
    cell.statusLabel.text = download.filePath ? @"Ready to play" : @"Processing";
    cell.progressView.progress = download.progress;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)updatePageStyles {
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    _tableView.backgroundColor = [UIColor systemBackgroundColor];
    [_tableView reloadData];
}

@end