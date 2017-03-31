//
//  PandoraShareManager.h
//  PandoraBox
//
//  Created by xidee on 2017/3/10.
//  Copyright © 2017年 IntimeE-CommerceCo. All rights reserved.
//  分享工具类

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WXApi.h"
#import "WeiboSDK.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/QQApiInterfaceObject.h>
#import <AlipaySDK/AlipaySDK.h>

//分享类型
typedef enum {
    PandoraShareType_Text,      //文本
    PandoraShareType_Image,     //图片
    PandoraShareType_Webpage    //网页
}PandoraShareType;

//登录类型
typedef enum {
    PandoraLoginType_WeChat,     //微信
    PandoraLoginType_SinaWeibo,  //新浪微博
    PandoraLoginType_QQ,         //QQ
    PandoraLoginType_AliPay      //支付宝
}PandoraLoginType;

//分享平台
typedef enum {
    PandoraSharePlatform_WechatSession,     //微信会话
    PandoraSharePlatform_WechatTimeline,    //微信朋友圈
    PandoraSharePlatform_WechatFavorite,    //微信收藏
    PandoraSharePlatform_SinaWeibo,         //新浪微博
    PandoraSharePlatform_QQ,                //腾讯QQ
    PandoraSharePlatform_QZone              //QQ空间
}PandoraSharePlatform;

/**
    分享模型 (仅用于三方分享)
 */
@interface PandoraShareItem : NSObject

@property (nonatomic ,copy) NSString *shareTitle;       //分享标题
@property (nonatomic ,copy) NSString *shareDes;         //分享描述
@property (nonatomic ,copy) NSString *shareLink;        //分享链接
@property (nonatomic ,strong) NSData *shareImage;       //分享图片
@property (nonatomic ,strong) UIImage *thumbnailImage;   //缩略图
@property (nonatomic ,strong) NSData *thumbnailImageData;//缩略图data
@property (nonatomic ,copy) NSString *thumbnailImageURL; //缩略图URL
@property (nonatomic ,assign) PandoraShareType shareType;//分享类型
@property (nonatomic ,assign) PandoraSharePlatform sharePlatform;//分享类型

@end

/**
    分享工具类
 */
typedef void (^PandoraShareComplete)(BOOL completed,BOOL canceled,NSString *errorDes);
typedef void (^PandoraAuthComplete)(id userInfo,BOOL canceled,NSString *errorDes);

@interface PandoraShareManager : NSObject <WXApiDelegate,WeiboSDKDelegate,WBHttpRequestDelegate,QQApiInterfaceDelegate,TencentSessionDelegate>

/**
 @return 获取分享工具类 单例
 */
+ (instancetype)sharedManager;

/**
 注册微信平台APPKEY
 @param weChatAPPkey APPKEY
 */
- (void)registerWeChatWithAPPKey:(NSString *)weChatAPPkey;

/**
 注册微博平台APPkey
 @param weChatAPPkey appkey
 @param secret 需要授权必须传入
 */
- (void)registerWeChatWithAPPKey:(NSString *)weChatAPPkey andAppSecret:(NSString *)secret;

/**
 注册微博平台
 @param weiboAPPkey APPKEY
 @param redirectURI 回调URL (必须和申请的时候一致)
 */
- (void)registerWeiboWithAPPKey:(NSString *)weiboAPPkey redirectURI:(NSString *)redirectURI;

/**
 注册腾讯QQ平台
 @param APPID APPID
 */
- (void)registerQQWithAPPID:(NSString *)APPID;


/**
 注册支付宝平台
 @param APPID appkey
 @param pID 商户ID
 @param redirectURL 回调URL
 */
- (void)registerAliPayWithAPPID:(NSString *)APPID andPID:(NSString *)pID andRedirectURL:(NSString *)redirectURL;

/**
 调用系统分享
 @param items 分享的内容
 @param viewController 分享视图弹出的子视图
 @param complete 完成回调 （completed:是否完成 activityError:错误信息）
 */
- (void)systemShareItems:(NSArray *)items inViewController:(UIViewController *)viewController complete:(void(^)(BOOL completed,NSError *activityError))complete;

/**
 开放平台分享
 @param shareItem 分享项目
 @param complete 完成回调 (completed:是否完成 canceled:用户取消 error：错误)
 */
- (void)openPlatformsShareWithShareItem:(PandoraShareItem *)shareItem complete:(PandoraShareComplete)complete;

/**
 三方APP回调
 @param url 回调URL
 @return 返回给appdelegate的结果
 */
- (BOOL)handleOpenURL:(NSURL *)url;

/**
 三方平台授权登录
 @platfrom 登录平台
 @param authComplete 登录结果回调
 */
- (void)loginWithPlatform:(PandoraLoginType)platfrom complete:(PandoraAuthComplete)authComplete;


@end
