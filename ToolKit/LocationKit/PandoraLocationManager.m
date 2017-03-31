//
//  PandoraLocationManager.m
//  PandoraBox
//
//  Created by xidee on 2017/3/9.
//  Copyright © 2017年 IntimeE-CommerceCo. All rights reserved.
//

#import "PandoraLocationManager.h"
#import <UIKit/UIKit.h>

@interface PandoraLocationManager ()

/**
    位置编码/反编码
 */
@property (nonatomic ,strong) CLGeocoder *geocoder;

/**
    扫描信号对象
 */
@property (nonatomic ,strong) CLBeaconRegion *region;

/**
    定位回调
 */
@property (copy) AuthorizationBlock authorizationBlock;
@property (copy) LocationBlock locationBlock;
@property (copy) GeocoderBlock geocoderBlock;

@property (copy) BeaconBlock beaconBlock;

@end

@implementation PandoraLocationManager

+ (instancetype)sharedManager
{
    static PandoraLocationManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[PandoraLocationManager alloc] init];
        instance.locationManager = [[CLLocationManager alloc] init];
        instance.locationManager.delegate = instance;
        instance.geocoder = [[CLGeocoder alloc] init];
        //默认精准定位
        instance.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        //默认仅前台定位
        instance.authorizationType = WhenInUseAuthorization;
    });
    return instance;
}
//获取授权信息
- (BOOL)requestAuthorization
{
    switch ([CLLocationManager authorizationStatus]) {
            //未决定
        case kCLAuthorizationStatusNotDetermined:
        {
            //根据授权类型请求授权
            if (self.authorizationType == AlwaysAuthorization) {
                if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                    [self.locationManager requestAlwaysAuthorization];
                }
            }else{
                if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                    [self.locationManager requestWhenInUseAuthorization];
                }
            }
            return NO;
        }
            break;
        case kCLAuthorizationStatusRestricted:
        {
            //受限制 非用户决定的
            return YES;
        }
            break;
        case kCLAuthorizationStatusDenied:
        {
            //拒绝 请在设置中打开定位
            return NO;
        }
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
        {
            //始终使用
            if (self.authorizationType == WhenInUseAuthorization) {
                //请到设置中修改权限
            }
            return YES;
        }
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        {
            //仅在用户使用期间
            if (self.authorizationType == AlwaysAuthorization) {
                //请到设置中修改权限
            }
            return YES;
        }
            break;
        default:
            break;
    }
}
//启动定位
- (void)startUpdatingLocationAuthorizationBlock:(AuthorizationBlock)authorizationBlock
                                  locationBlock:(LocationBlock)locationBlock
                                  geocoderBlock:(GeocoderBlock)geocoderBlock;
{
    if (authorizationBlock) {
        //返回授权状态
        authorizationBlock([CLLocationManager authorizationStatus]);
    }
    if ([self requestAuthorization]) {
        [self.locationManager startUpdatingLocation];
        self.locationBlock = locationBlock;
        self.geocoderBlock = geocoderBlock;
    }
}
//停止定位
- (void)stopUpdatingLocation
{
    [self.locationManager stopUpdatingLocation];
}

/**
 开启基站扫描
 @param UUID 基站的UUID
 */
- (void)startBeaconRangingWithUUID:(NSUUID *)UUID major:(uint16_t)major minor:(uint16_t)minor identifier:(NSString *)identifier beaconBlock:(BeaconBlock)beaconBlock;
{
    if (UUID) {
        self.region = [[CLBeaconRegion alloc] initWithProximityUUID:UUID major:major minor:minor identifier:identifier];
        self.region.notifyEntryStateOnDisplay = YES;
    }
    if ([self requestAuthorization]) {
        //查找基站
        [self.locationManager startMonitoringForRegion:self.region];
        //扫描基站（已经在基站范围内）
        [self.locationManager startRangingBeaconsInRegion:self.region];
        self.beaconBlock = beaconBlock;
    }
}

//成功获取到坐标信息
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *location = [locations lastObject];
    if (self.locationBlock) {
        self.locationBlock(location,nil);
    }
 
    if (self.geocoderBlock) {
        //获得坐标信息 进行位置反编码
        __weak __typeof__(self) weakSelf = self;
        [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            //回调位置反编码信息
            CLPlacemark *plm = [placemarks lastObject];
            weakSelf.geocoderBlock(plm,error);
        }];
    }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    //定位错误
    if (self.locationBlock) {
        self.locationBlock(nil,error);
    }
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error.localizedDescription delegate:nil cancelButtonTitle:@"嗯" otherButtonTitles:nil, nil];
//    [alert show];
}

// 发现有iBeacon设备进入扫描范围回调
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region{
    //扫描范围内的基站
    [self.locationManager startRangingBeaconsInRegion:self.region];
}

//成功扫描到基站信息
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray<CLBeacon *> *)beacons inRegion:(CLBeaconRegion *)region
{
    if ([region.proximityUUID.UUIDString isEqualToString:self.region.proximityUUID.UUIDString]) {
        //遍历扫描到的基站信息
        if (beacons.count) {
            if (self.beaconBlock) {
                self.beaconBlock(beacons);
            }
        }
    }else{
        //不是同一uuid的基站 停止扫描
        [self.locationManager stopMonitoringForRegion:self.region];
        [self.locationManager stopRangingBeaconsInRegion:self.region];
    }
}

//跳转到系统定位设置
void goSetLocationSevives()
{
    UIApplication *app = [UIApplication sharedApplication];
    NSURL *locationServices = [NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"];
    if ([app canOpenURL:locationServices]) {
        //iOS10以下兼容
        if ([app respondsToSelector:@selector(openURL:options:completionHandler:)]) {
            [app openURL:locationServices options:@{} completionHandler:nil];
        }else{
            [app openURL:locationServices];
        }
    }
}

@end
