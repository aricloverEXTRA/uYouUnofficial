#import "DownloadingVC.h"
#import "DownloadsManager.h"
#import "DownloadItem.h"

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