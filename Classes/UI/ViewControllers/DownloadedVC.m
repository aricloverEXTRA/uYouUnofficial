#import "DownloadedVC.h"
#import "DownloadsManager.h"
#import "DownloadItem.h"

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