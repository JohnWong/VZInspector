//
//  ViewController.m
//  VZInspector
//
//  Created by moxin.xt on 14-9-23.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import "ViewController.h"
#import "VZHeapInspector.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong) UITableView* tableView;
@property(nonatomic,strong) NSMutableArray* items;

@end

@implementation ViewController

- (UIView* )loadingFooterView
{
    UIView* v = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44)];
    UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake((CGRectGetWidth(self.view.bounds)-20)/2, 11, 20, 20)];
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [indicator startAnimating];
    [v addSubview:indicator];
   
    return v;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(load)];
    
    self.items = [NSMutableArray new];
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)-64)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    [self load];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CABasicAnimation *anim = [self rotationAnimation];
    anim.delegate = self;
    [window.layer addAnimation:anim forKey:@"vzanimate"];
    
    
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIViewController *rootVC = window.rootViewController;
    for (UIView *view in rootVC.view.subviews) {
        [self formatView:view];
        for (UIView *view1 in view.subviews) {
            [self formatView:view1];
            for (UIView *view2 in view1.subviews) {
                [self formatView:view2];
            }
        }
    }
}

- (void)formatView:(UIView *)view {
    view.alpha = 0.9;
    view.layer.borderColor = [UIColor grayColor].CGColor;
    view.layer.borderWidth = 1;
    view.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.95];
    [view.layer addAnimation:[self zoominAnimation] forKey:@"sub"];
}

- (CABasicAnimation *)zoominAnimation {
    CATransform3D transform = CATransform3DIdentity;
    // 拉近
    transform.m34 = - 1.0 / 600.0;
    transform = CATransform3DTranslate(transform, 10, 10, 1);
//    transform = CATransform3DScale(transform, 0.8, 0.8, 1);
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.toValue= [NSValue valueWithCATransform3D:transform];
    animation.duration= 1;
    animation.autoreverses= NO;
    animation.fillMode = @"forwards";
    animation.removedOnCompletion = NO;
    return animation;
}

- (CABasicAnimation *) rotationAnimation{
    CATransform3D transform = CATransform3DIdentity;
    // 应用透视
    transform.m34 = - 1.0 / 600.0;
    // 绕Y轴旋转45度
    transform = CATransform3DRotate(transform, M_PI / 8, 0, 1.0 / 2, 0);
    transform = CATransform3DScale(transform, 0.8, 0.8, 1);
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.toValue= [NSValue valueWithCATransform3D:transform];
    animation.duration= 1;
    animation.autoreverses= NO;
    animation.fillMode = @"forwards";
    animation.removedOnCompletion = NO;
    return animation;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UITableViewCell* )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"vzline"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"vzline"];
    }
    
    NSDictionary* info = self.items[indexPath.row];
    
    
    cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = info[@"text"];
    [cell.textLabel sizeToFit];
    
    return cell;

}

- (void)load
{
    [self.items removeAllObjects];
    [self.tableView reloadData];
    self.tableView.tableFooterView = [self loadingFooterView];
    
    NSString* url = @"https://api.app.net/stream/0/posts/stream/global";
    [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSDictionary* JSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        for (NSDictionary* dict in JSON[@"data"]) {
            [self.items addObject:dict];
            
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.tableView.tableFooterView = nil;
            [self.tableView reloadData];
            
        });
        
    }] resume];
    
}


@end
