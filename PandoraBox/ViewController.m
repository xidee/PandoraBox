//
//  ViewController.m
//  PandoraBox
//
//  Created by xidee on 2017/2/28.
//  Copyright © 2017年 IntimeE-CommerceCo. All rights reserved.
//

#import "ViewController.h"
#import "PandoraShareManager.h"
#import "PandoraScanKit.h"
#import "PandoraCameraKit.h"
#import "PandoraLocationManager.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "BeaconViewController.h"

@interface ViewController ()

@property (nonatomic ,strong) PandoraScanKit *scanKit;
@property (nonatomic ,strong) PandoraCameraKit *cameraKit;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    self.scanKit = [[PandoraScanKit alloc] initSessionInView:self.view];
//    self.scanKit.result = ^(NSString *type,NSString*result){
//        NSLog(@"ScanResult:%@",result);
//    };
    self.cameraKit = [[PandoraCameraKit alloc] init];
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 375, 64)];
    titleView.backgroundColor = [UIColor redColor];
    self.navigationItem.titleView = titleView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIImage *image = [UIImage imageNamed:@"homePage_saoyisao"];
    NSURL *url = [NSURL URLWithString:@"http://www.baidu.com"];
#pragma mark - share
//    [[PandoraShareManager sharedManager] systemShareItems:@[@"标题",url,image] inViewController:self complete:^(BOOL completed, NSError *activityError) {
//        
//    }];
//    [[PandoraShareManager sharedManager] loginWithPlatform:PandoraLoginType_AliPay complete:^(id userInfo, BOOL canceled, NSString *errorDes) {
//        
//    }];
    
#pragma mark - Scan
    
//    [self.scanKit startScan];
    
    [[PandoraLocationManager sharedManager] startBeaconRangingWithUUID:[[NSUUID alloc] initWithUUIDString:@"9903C9E8-CF93-4BC4-AE73-255F7EA4F416"] major:1 minor:20 identifier:@"银泰网基站" beaconBlock:^(NSArray<CLBeacon *> *beacons) {
        
    }];
}

- (IBAction)cameraAciton:(UIButton *)sender {
#pragma mark - Camera
    __weak __typeof__(self) weakSelf = self;
    [self.cameraKit showImagePickerControllerWithSourceType:UIImagePickerControllerSourceTypeCamera inViewController:self completion:^(UIImage *image) {
        weakSelf.view.backgroundColor = [UIColor colorWithPatternImage:image];
    }];
}
- (IBAction)photoLiblaryAction:(UIButton *)sender {
#pragma mark - Camera
    __weak __typeof__(self) weakSelf = self;
    [self.cameraKit showImagePickerControllerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary inViewController:self completion:^(UIImage *image) {
        weakSelf.view.backgroundColor = [UIColor colorWithPatternImage:image];
    }];
}
- (IBAction)scanAction:(UIButton *)sender {
    [self.scanKit startScan];
}

- (IBAction)pooGesture:(UIButton *)sender {
    self.navigationController.fd_viewControllerBasedNavigationBarAppearanceEnabled = YES;
//    ViewController *pushVC = [[ViewController alloc] init];
//    pushVC.fd_interactivePopMaxAllowedInitialDistanceToLeftEdge = 200;
//    [self.navigationController pushViewController:pushVC animated:YES];
    
    BeaconViewController *beaconVC = [[BeaconViewController alloc] init];
//    beaconVC.fd_prefersNavigationBarHidden = YES;
    beaconVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:beaconVC animated:YES];
    
}

@end
