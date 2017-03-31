//
//  PandoraLocationManager.h
//  PandoraBox
//
//  Created by xidee on 2017/3/9.
//  Copyright © 2017年 IntimeE-CommerceCo. All rights reserved.
//  定位工具类

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

//授权类型枚举
typedef enum
{
    AlwaysAuthorization,    //始终请求授权
    WhenInUseAuthorization  //仅在应用使用时
}RequestAuthorizationType;

typedef void (^AuthorizationBlock)(CLAuthorizationStatus authorizationStatus);
typedef void (^LocationBlock)(CLLocation *location,NSError *error);
typedef void (^GeocoderBlock)(CLPlacemark *placemark, NSError *error);
typedef void (^BeaconBlock) (NSArray<CLBeacon *> *beacons);

@interface PandoraLocationManager : NSObject <CLLocationManagerDelegate>

/**
    定位管理器
 */
@property (nonatomic ,strong) CLLocationManager *locationManager;

/**
    授权类型
 */
@property (nonatomic ,assign) RequestAuthorizationType authorizationType;

/**
    获取定位管理工具类
 @return 返回定位单例工具类
 */
+ (instancetype)sharedManager;

/**
    开始定位
 @param authorizationBlock 授权结果的回调
 @param locationBlock 获取定位信息后的回调
 @param geocoderBlock 位置反编码回调
 */
- (void)startUpdatingLocationAuthorizationBlock:(AuthorizationBlock)authorizationBlock
                                  locationBlock:(LocationBlock)locationBlock
                                  geocoderBlock:(GeocoderBlock)geocoderBlock;

/**
    停止定位
 */
- (void)stopUpdatingLocation;


/**
 开启低耗蓝牙基站扫描
 @param UUID 基站的UUID （理解成一家公司）
 @param major 基站主值  （公司的不同部门）
 @param minor 基站次要值 （部门人员 即一个基站）
 @param identifier 基站标识符
 @param beaconBlock 扫描到的基站信息的回调
 */
- (void)startBeaconRangingWithUUID:(NSUUID *)UUID major:(uint16_t)major minor:(uint16_t)minor identifier:(NSString *)identifier beaconBlock:(BeaconBlock)beaconBlock;

/**
    跳出APP并跳转到手机 设置-定位
 */
void goSetLocationSevives();


@end
