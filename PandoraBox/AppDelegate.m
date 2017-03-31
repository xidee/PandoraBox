//
//  AppDelegate.m
//  PandoraBox
//
//  Created by xidee on 2017/2/28.
//  Copyright © 2017年 IntimeE-CommerceCo. All rights reserved.
//

#import "AppDelegate.h"

#import "PandoraNetWork.h"
#import "AFNetworkingAdapter.h"
#import "NetWorkEventRespond.h"
#import "PandoraTabBarViewController.h"
#import "PandoraLocationManager.h"
#import "ViewController.h"
#import "PandoraShareManager.h"
#import "BeaconViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
#pragma mark - 自定义tabbar
    PandoraTabBarViewController *tabbar = [[PandoraTabBarViewController alloc] init];
    NSArray *titles = @[@"one",@"two",@"three",@"four"];
    NSArray *images = @[[UIImage imageNamed:@"homePage_tab1_N"],
                        [UIImage imageNamed:@"homePage_tab2_N"],
                        [UIImage imageNamed:@"homePage_tab3_N"],
                        [UIImage imageNamed:@"homePage_tab4_N"]];
    NSArray *imagesS = @[[UIImage imageNamed:@"homePage_tab1_S"],
                        [UIImage imageNamed:@"homePage_tab2_S"],
                        [UIImage imageNamed:@"homePage_tab3_S"],
                        [UIImage imageNamed:@"homePage_tab4_S"]];
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    NSMutableArray *tabbarItems = [[NSMutableArray alloc] init];
    for (int i = 0; i < titles.count ; i ++) {
        ViewController *vc = [[ViewController alloc] init];
        vc.title = titles[i];
        vc.tabBarItem.badgeValue = @"1000";
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        vc.view.backgroundColor = [UIColor whiteColor];
        [arr addObject:nav];
        
        PandoraTabbarItem *item = [[PandoraTabbarItem alloc] init];
        item.title = titles[i];
        item.unselectedImage = images[i];
        item.selectedImage = imagesS[i];
        item.badgeValue = @"99";
        item.badgeBackgroundColor = [UIColor blackColor];
        item.selectedTitleAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[UIColor orangeColor]};
        [tabbarItems addObject:item];
    }
    tabbar.customTabbar.items = tabbarItems;
    tabbar.customTabbar.backgroundImage = [UIImage imageNamed:@"homePage_tabbar"];
    
    tabbar.viewControllers = arr;
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = tabbar;
    [self.window makeKeyAndVisible];
    
#pragma mark - NetWorkTool URLCache
    [[PandoraNetWork sharedNetWork] registerNetAdapter:[AFNetworkingAdapter class]];
    [[PandoraNetWork sharedNetWork] registerEventRespond:[NetWorkEventRespond class]];
    //缓存策略 (设置缓存池大小 直接就可以使用系统默认的缓存)
    [[PandoraNetWork sharedNetWork] setCachePoolWithMemoryCapacity:Megabyte(4) diskCapacity:Megabyte(20)];
    
    PandoraNetWorkConfiguration *config = [[PandoraNetWorkConfiguration alloc] init];
//    config.sessionConfiguration.requestCachePolicy = NSURLRequestReturnCacheDataElseLoad; //使用缓存
    
    NSURLSessionDataTask *task = [[PandoraNetWork sharedNetWork] GET:@"https://alpha-api.app.net/stream/0/posts/stream/global" parameters:nil configuration:config success:^(NSURLSessionDataTask *task, id responseObject) {
      
//        NSLog(@"%@",responseObject);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
    
//    ViewController *vc = [[ViewController alloc] init];
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
//    UIImage *image = [UIImage imageNamed:@"homePage_saoyisao"];
//    UIImage *imageS = [UIImage imageNamed:@"homePage_saoyisao"];
//    [tabbar setChildViewController:nav withTitle:@"" normalImage:image selectedImage:imageS];
//    [tabbar addViewController:nav atIndex:2];
    //修改缓存数据 用来验证是否使用缓存
//    [[NSURLCache sharedURLCache] getCachedResponseForDataTask: task completionHandler:^(NSCachedURLResponse * _Nullable cachedResponse) {
//        NSURLResponse *res = cachedResponse.response;
//        NSCachedURLResponse *cache = [[NSCachedURLResponse alloc] initWithResponse:res data:[NSJSONSerialization dataWithJSONObject:@{@"dd":@"dd"} options:NSJSONWritingPrettyPrinted error:nil]];
//        [[NSURLCache sharedURLCache] storeCachedResponse:cache forDataTask:task];
//        
//        NSLog(@"%@",[NSJSONSerialization JSONObjectWithData:cache.data options:NSJSONReadingMutableContainers error:nil]);
//    }];
    
    PandoraNetWorkConfiguration *config1 = [[PandoraNetWorkConfiguration alloc] init];
    config1.responseSerializer = ResponseSerializer_XML; //配置相应格式为XML
    
    [[PandoraNetWork sharedNetWork] GET:@"http://www.webxml.com.cn/WebServices/WeatherWebService.asmx/getWeatherbyCityName?theCityName=59287" parameters:nil configuration:config1 success:^(NSURLSessionDataTask *task, id responseObject) {
       
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
    
#pragma mark - locationManager
//    [[PandoraLocationManager sharedManager] startUpdatingLocationAuthorizationBlock:^(CLAuthorizationStatus authorizationStatus) {
//        NSLog(@"当前授权信息: %d",authorizationStatus);
//    } locationBlock:^(CLLocation *location, NSError *error) {
//        if (!error) {
//            NSLog(@"获取坐标成功");
//        }
//    } geocoderBlock:^(CLPlacemark *placemark, NSError *error) {
//        if (!error) {
//            NSLog(@"位置反编码成功 %@",placemark.name);
//        }
//        [[PandoraLocationManager sharedManager] stopUpdatingLocation];
////        goSetLocationSevives();
//    }];
    
    
#pragma mark - sharekit
    [[PandoraShareManager sharedManager] registerWeChatWithAPPKey:@"wxad71d4edfc5a2a45"andAppSecret:@"5762b42a1a224c76e73e6d655b8336e9"];
    [[PandoraShareManager sharedManager] registerWeiboWithAPPKey:@"63011809" redirectURI:@"https://sns.whalecloud.com"];
    [[PandoraShareManager sharedManager] registerQQWithAPPID:@"213798"];
    [[PandoraShareManager sharedManager] registerAliPayWithAPPID:@"2015010900024361" andPID:@"2088301724202537" andRedirectURL:@"com.yintai.iphone://"];
    
    PandoraShareItem *item = [[PandoraShareItem alloc] init];
    item.shareTitle = @"标题";
    item.shareDes = @"描述";
    item.thumbnailImage = [UIImage imageNamed:@"homePage_saoyisao"];
    item.thumbnailImageData = UIImagePNGRepresentation([UIImage imageNamed:@"homePage_saoyisao"]);
    item.shareLink = @"http://www.baidu.com";
    item.sharePlatform = PandoraSharePlatform_QQ;
    
//    [[PandoraShareManager sharedManager] openPlatformsShareWithShareItem:item complete:^(BOOL completed, BOOL canceled, NSString *errorDes) {
//        
//    }];
    
//    BeaconViewController *beaconVC = [[BeaconViewController alloc] init];
//    UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:beaconVC];
//    UIImage *image1 = [UIImage imageNamed:@"homePage_saoyisao"];
//    UIImage *imageS1 = [UIImage imageNamed:@"homePage_saoyisao"];
//    [tabbar setChildViewController:nav1 withTitle:@"大傻蛋" normalImage:image1 selectedImage:imageS1];
//    [tabbar addViewController:nav1 atIndex:0];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [[PandoraShareManager sharedManager] handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(nonnull id)annotation
{
    return [[PandoraShareManager sharedManager] handleOpenURL:url];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
