//
//  BeaconViewController.m
//  PandoraBox
//
//  Created by xidee on 2017/3/21.
//  Copyright © 2017年 IntimeE-CommerceCo. All rights reserved.
//  创建基站样例

#import "BeaconViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>
#import "PandoraTabBarViewController.h"

@interface BeaconViewController ()<CBPeripheralManagerDelegate>

@property (nonatomic ,strong) CBPeripheralManager *peripheraManager;

@end

@implementation BeaconViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.peripheraManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        NSDictionary *peripheralData = nil;
//        NSUUID *UUID = [[UIDevice currentDevice] identifierForVendor];
        NSUUID *UUID = [[NSUUID alloc] initWithUUIDString:@"9903C9E8-CF93-4BC4-AE73-255F7EA4F416"];
        CLBeaconRegion * region = [[CLBeaconRegion alloc] initWithProximityUUID:UUID major:1 minor:20 identifier:@"银泰网基站"];
        peripheralData = [region peripheralDataWithMeasuredPower:nil];
        if(peripheralData)
        {
            //开始广播
            [self.peripheraManager startAdvertising:peripheralData];
        }
    }
    
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(nullable NSError *)error
{
    
}  


@end
