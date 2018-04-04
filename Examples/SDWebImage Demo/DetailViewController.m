/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "DetailViewController.h"
#import <SDWebImage/FLAnimatedImageView.h>
#import <SDWebImage/FLAnimatedImageView+WebCache.h>

@interface DetailViewController ()

@property (strong, nonatomic) IBOutlet FLAnimatedImageView *imageView;


/**
 转圈，被加到imageView
 */
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

/**
 显示图片下载进度
 */
@property (strong, nonatomic) UIProgressView *progressView;

@end

@implementation DetailViewController


/**
 懒加载转圈视图

 @return <#return value description#>
 */
- (UIActivityIndicatorView *)activityIndicator
{
    if (!_activityIndicator) {
        _activityIndicator = [UIActivityIndicatorView.alloc initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicator.center = self.imageView.center;
        _activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self.imageView addSubview:_activityIndicator];
        
    }
    return _activityIndicator;
}


/**
 懒加载进度条视图

 @return <#return value description#>
 */
- (UIProgressView *)progressView
{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        [self.view addSubview:_progressView];
        // 注：progressView的frame在viewDidLayoutSubviews设置
    }
    return _progressView;
}

- (void)configureView
{
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    
    // 避免循环引用
    __weak typeof(self) weakSelf = self;
    [self.imageView sd_setImageWithURL:self.imageURL
                      placeholderImage:nil
                               // 图片从上到下边下载边显示已下载部分
                               options:SDWebImageProgressiveDownload
                              progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL *targetURL) {
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      float progress = 0;
                                      if (expectedSize != 0) {
                                          progress = (float)receivedSize / (float)expectedSize;
                                      }
                                      weakSelf.progressView.hidden = NO;
                                      [weakSelf.progressView setProgress:progress animated:YES];
                                  });
                              }
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                 weakSelf.progressView.hidden = YES;
                                 [weakSelf.activityIndicator stopAnimating];
                                 weakSelf.activityIndicator.hidden = YES;
                             }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureView];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.progressView.frame = CGRectMake(0, self.topLayoutGuide.length, CGRectGetWidth(self.view.bounds), 2.0);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
