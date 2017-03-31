//
//  PandoraShareManager.m
//  PandoraBox
//
//  Created by xidee on 2017/3/10.
//  Copyright © 2017年 IntimeE-CommerceCo. All rights reserved.
//

#import "PandoraShareManager.h"

#define WeChatAccessTokenAPI @"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code"
#define WeChatUserInfoAPI @"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@"
#define WeChatRefreshTokenAPI @"https://api.weixin.qq.com/sns/oauth2/refresh_token?appid=%@&grant_type=refresh_token&refresh_token=%@"

#define WeiboUserInfoAPI @"https://api.weibo.com/2/users/show.json"

#define AliPayGatewayURL @"https://openapi.alipay.com/gateway.do"

#define PandoraAuthInfo @"Documents/PandoraAuthInfo.archiver"

@implementation PandoraShareItem

@end

@interface PandoraShareManager()

/**
    分享的结果回调
 */
@property(copy) PandoraShareComplete shareComplete;

/**
    授权之后的回调
 */
@property(copy) PandoraAuthComplete authComplete;

/**
    微博回调地址
 */
@property(nonatomic,copy) NSString *weiboRedirectURI;

/**
    腾讯QQ授权对象
 */
@property (nonatomic ,strong) TencentOAuth *tencentOauth;

/**
    微信appkey
 */
@property (nonatomic ,copy) NSString *weChatAPPKey;

/**
    微信APP secret
 */
@property (nonatomic ,copy) NSString *weChatSecret;

/**
    支付宝appid
 */
@property (nonatomic ,copy) NSString *aliPayAPPID;

/**
    支付宝商户ID
 */
@property (nonatomic ,copy) NSString *aliPayPID;

/**
    支付宝回调URL
 */
@property (nonatomic ,copy) NSString *aliPayRedirectURL;

@end

@implementation PandoraShareManager

+ (instancetype)sharedManager
{
    static PandoraShareManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[PandoraShareManager alloc] init];
    });
    return instance;
}

#pragma mark - 注册平台
- (void)registerWeChatWithAPPKey:(NSString *)weChatAPPkey
{
    [WXApi registerApp:weChatAPPkey];
    self.weChatAPPKey = weChatAPPkey;
}

- (void)registerWeChatWithAPPKey:(NSString *)weChatAPPkey andAppSecret:(NSString *)secret
{
    [WXApi registerApp:weChatAPPkey];
    self.weChatAPPKey = weChatAPPkey;
    self.weChatSecret = secret;
}

- (void)registerWeiboWithAPPKey:(NSString *)weiboAPPkey redirectURI:(NSString *)redirectURI
{
    [WeiboSDK registerApp:weiboAPPkey];
    self.weiboRedirectURI = redirectURI;
}

- (void)registerQQWithAPPID:(NSString *)APPID
{
    self.tencentOauth = [[TencentOAuth alloc] initWithAppId:APPID andDelegate:self];
}

- (void)registerAliPayWithAPPID:(NSString *)APPID andPID:(NSString *)pID andRedirectURL:(NSString *)redirectURL
{
    self.aliPayAPPID = APPID;
    self.aliPayPID = pID;
    self.aliPayRedirectURL = redirectURL;
}

- (BOOL)handleOpenURL:(NSURL *)url
{
    if ([url.absoluteString hasPrefix:@"wx"]) {
        return [WXApi handleOpenURL:url delegate:self];
    }else if ([url.absoluteString hasPrefix:@"wb"])
    {
        return [WeiboSDK handleOpenURL:url delegate:self];
    }else if ([url.absoluteString hasPrefix:@"tencent"]){
        if ([TencentOAuth CanHandleOpenURL:url]) {
            return [TencentOAuth HandleOpenURL:url];
        }else{
            return [QQApiInterface handleOpenURL:url delegate:self];
        }
    }else if ([url.absoluteString hasPrefix:self.aliPayRedirectURL]){
        [[AlipaySDK defaultService]processAuthResult:url standbyCallback:^(NSDictionary *resultDic) {
            
        }];
    }
    return YES;
}

//系统分享
- (void)systemShareItems:(NSArray *)items inViewController:(UIViewController *)viewController complete:(void(^)(BOOL completed,NSError *activityError))complete
{
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    UIActivityViewControllerCompletionWithItemsHandler completionBlock = ^(UIActivityType activityType, BOOL completed, NSArray *returnedItems, NSError *activityError)
    {
        //回调结果
        if (complete) {
            complete(completed,activityError);
        }
    };
    activityVC.completionWithItemsHandler = completionBlock;
    [viewController presentViewController:activityVC animated:YES completion:nil];
}

//三方平台分享
- (void)openPlatformsShareWithShareItem:(PandoraShareItem *)shareItem complete:(PandoraShareComplete)complete
{
    self.shareComplete = complete;
    switch (shareItem.sharePlatform) {
        case PandoraSharePlatform_WechatSession:
            [self shareToWeChatWithShareItem:shareItem scene:WXSceneSession];
            break;
        case PandoraSharePlatform_WechatTimeline:
            [self shareToWeChatWithShareItem:shareItem scene:WXSceneTimeline];
            break;
        case PandoraSharePlatform_WechatFavorite:
            [self shareToWeChatWithShareItem:shareItem scene:WXSceneFavorite];
            break;
        case PandoraSharePlatform_SinaWeibo:
            [self shareToWeiboWithShareItem:shareItem];
            break;
        case PandoraSharePlatform_QQ:
            [self shareToQQWithShareItem:shareItem];
            break;
        case PandoraSharePlatform_QZone:
            [self shareToQQWithShareItem:shareItem];
            break;
        default:
            break;
    }
}

#pragma mark - WXApiDelegate / QQApiInterfaceDelegate
-(void) onReq:(id)req
{
    
}

-(void) onResp:(id)resp
{
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        //微信授权回调
        SendAuthResp *res = (SendAuthResp *)resp;
        if (res.errCode == WXSuccess) {
            [self getWeChatAccessTokenWithCode:res.code];
        }else if (res.errCode == WXErrCodeUserCancel){
            if (self.authComplete) {
                self.authComplete(nil,YES,nil);
            }
        }else{
            if (self.authComplete) {
                self.authComplete(nil,NO,res.state);
            }
        }
    }else if ([resp isKindOfClass:[SendMessageToWXResp class]]){
        //微信分享回调
        if (self.shareComplete) {
            SendMessageToWXResp *res = (SendMessageToWXResp *)resp;
            //回调微信分享结果
            if (res.errCode == WXSuccess) {
                self.shareComplete(YES,NO,nil);
            }else if(res.errCode == WXErrCodeUserCancel){
                self.shareComplete(NO,YES,nil);
            }else{
                self.shareComplete(NO,NO,res.errStr);
            }
        }
    }
    
    if (self.shareComplete) {
        if ([resp isKindOfClass:[QQBaseResp class]]) {
            QQBaseResp *res = (QQBaseResp *)resp;
            if ([res.result isEqualToString:@"0"]) {
                self.shareComplete(YES,NO,nil);
            }else if ([res.result isEqualToString:@"-4"]){
                self.shareComplete(NO,YES,nil);
            }else{
                self.shareComplete(NO,NO,res.errorDescription);
            }
        }
    }
}

- (void)tencentDidLogin
{   //授权成功 拉取用户信息
    [self.tencentOauth getUserInfo];
}
- (void)tencentDidNotLogin:(BOOL)cancelled
{   //用户取消
    if(self.authComplete){
        self.authComplete(nil,YES,nil);
    }
}
- (void)tencentDidNotNetWork
{   //网络错误
    if(self.authComplete){
        self.authComplete(nil,NO,@"QQ授权网络错误");
    }
}

- (void)getUserInfoResponse:(APIResponse*) response
{   //获取QQ用户信息
    if (response.errorMsg) {
        if(self.authComplete){
            self.authComplete(nil,NO,response.errorMsg);
        }
    }else{
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:response.jsonResponse];
        [dic setObject:self.tencentOauth.openId forKey:@"openID"];
        if (self.authComplete) {
            self.authComplete(dic,NO,nil);
        }
    }
}

#pragma mark - WeiboDelegate
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    
}
- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if ([response isKindOfClass:WBAuthorizeResponse.class]) {
        //授权回调
        if (response.statusCode == WeiboSDKResponseStatusCodeSuccess) {
            WBAuthorizeResponse *authRes = (WBAuthorizeResponse *)response;
            NSDictionary *authInfo = [self getLocalAuthInfo];
            NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithDictionary:authInfo];
            [mDic setObject:authRes.userID forKey:@"weiboUserID"];
            [mDic setObject:authRes.expirationDate forKey:@"weiboExpirationDate"];
            [mDic setObject:authRes.accessToken forKey:@"weiboAccessToken"];
            [mDic setObject:authRes.refreshToken forKey:@"weiboRefreshToken"];
            [self saveAuthInfo:mDic];
            [self requestToGetWeiboUserInfoWithAccessToken:authRes.accessToken andUserID:authRes.userID];
        }else if (response.statusCode == WeiboSDKResponseStatusCodeUserCancel){
            if (self.authComplete) {
                self.authComplete(nil,YES,nil);
            }
        }else{
            if (self.authComplete) {
                self.authComplete(nil,NO,[NSString stringWithFormat:@"statusCode:%ld",response.statusCode]);
            }
        }
    }else if ([response isKindOfClass:WBSendMessageToWeiboResponse.class])
    {   //分享回调
        if (self.shareComplete) {
            if (response.statusCode == WeiboSDKResponseStatusCodeSuccess) {
                self.shareComplete(YES,NO,nil);
            }else if(response.statusCode == WeiboSDKResponseStatusCodeUserCancel){
                self.shareComplete(NO,YES,nil);
            }else{
                self.shareComplete(NO,NO,[NSString stringWithFormat:@"statusCode:%ld",response.statusCode]);
            }
        }
    }
}

- (void)request:(WBHttpRequest *)request didFailWithError:(NSError *)error
{
    if ([request.tag isEqualToString:WeiboUserInfoAPI]) {
        //获取微博用户信息的回调
        if (self.authComplete) {
            self.authComplete(nil,NO,error.localizedDescription);
        }
    }
}

#pragma mark - shareCode
/**
 分享到微信
 @param shareItem 分享对象
 @param scene 分享目标 （会话/朋友圈/收藏）
 */
- (void)shareToWeChatWithShareItem:(PandoraShareItem *)shareItem scene:(int)scene
{
    if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
        SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
        //根据类型实例化分享内容
        switch (shareItem.shareType) {
            case PandoraShareType_Text:
            {
                req.text = shareItem.shareDes;
                req.bText = YES;
            }
                break;
            case PandoraShareType_Image:
            {
                WXMediaMessage *message = [WXMediaMessage message];
                [message setThumbImage:shareItem.thumbnailImage];
                WXImageObject *imageObject = [WXImageObject object];
                imageObject.imageData = shareItem.shareImage;
                message.mediaObject = imageObject;
                req.bText = NO;
                req.message = message;
            }
            case PandoraShareType_Webpage:
            {
                WXMediaMessage *message = [WXMediaMessage message];
                message.title = shareItem.shareTitle;
                message.description = shareItem.shareDes;
                [message setThumbImage:shareItem.thumbnailImage];
                
                WXWebpageObject *webpageObject = [WXWebpageObject object];
                webpageObject.webpageUrl = shareItem.shareLink;
                message.mediaObject = webpageObject;
                req.bText = NO;
                req.message = message;
            }
                break;
            default:
                break;
        }
        
        req.scene = scene;
        [WXApi sendReq:req];
    }else{
        if (self.shareComplete) {
            self.shareComplete(NO,NO,@"没有安装微信或者微信版本过低");
        }
    }
}

/**
 分享到微博
 @param shareItem 分享对象
 */
- (void)shareToWeiboWithShareItem:(PandoraShareItem *)shareItem
{
    WBMessageObject *message = [WBMessageObject message];
    message.text = shareItem.shareDes;

    WBImageObject *imageObject = [WBImageObject object];
    imageObject.imageData = shareItem.shareImage;
    message.imageObject = imageObject;
    
    WBAuthorizeRequest *authoRequest = [WBAuthorizeRequest request];
    authoRequest.redirectURI = self.weiboRedirectURI;
    authoRequest.scope = @"all";
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message authInfo:authoRequest access_token:nil];
    [WeiboSDK sendRequest:request];
}

/**
 分享到QQ/Q ZONE
 @param shareItem 分享对象
 */
- (void)shareToQQWithShareItem:(PandoraShareItem *)shareItem
{
    if ([QQApiInterface isQQInstalled] && [QQApiInterface isQQSupportApi]) {
        QQApiNewsObject *newsObj = [QQApiNewsObject objectWithURL:[NSURL URLWithString:shareItem.shareLink] title:shareItem.shareTitle description:shareItem.shareDes previewImageData:shareItem.thumbnailImageData];
        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
        
        if (shareItem.sharePlatform == PandoraSharePlatform_QQ) {
            [QQApiInterface sendReq:req];
        }else{
            [QQApiInterface SendReqToQZone:req];
        }
    }else{
        if (self.shareComplete) {
            self.shareComplete(NO,NO,@"没有安装QQ或者QQ版本过低");
        }
    }
}

#pragma mark - authCode
- (void)loginWithPlatform:(PandoraLoginType)platfrom complete:(PandoraAuthComplete)authComplete
{
    switch (platfrom) {
        case PandoraLoginType_WeChat:
            [self weChatLoginComplete:authComplete];
            break;
        case PandoraLoginType_SinaWeibo:
            [self weiboLoginComplete:authComplete];
            break;
        case PandoraLoginType_AliPay:
            [self aliPayLoginComplete:authComplete];
            break;
        case PandoraLoginType_QQ:
            [self QQLoginComplete:authComplete];
            break;
        default:
            break;
    }
}

/**
 微信登录
 @param authComplete 回调登录结果
 */
- (void)weChatLoginComplete:(PandoraAuthComplete)authComplete
{
    self.authComplete = authComplete;
    
    NSDictionary *authInfo = [self getLocalAuthInfo];
    NSString *accessToken = [authInfo objectForKey:@"wechatAccessToken"];
    NSString *openID = [authInfo objectForKey:@"wechatOpenid"];
    //本地存在授权信息 直接请求
    if (accessToken.length && openID.length) {
        [self requestToGetWeChatUserInfoWithAccessToken:accessToken andOpenid:openID];
    }else{
        [self weChatAuth];
    }
}

/**
    微信授权
 */
- (void)weChatAuth
{
    SendAuthReq* req =[[SendAuthReq alloc ] init];
    req.scope = @"snsapi_userinfo,snsapi_base";
    req.state = @"pandora_wx" ;
    [WXApi sendReq:req];
}

/**
 根据code 请求token
 @param code 授权后获取的code
 */
- (void)getWeChatAccessTokenWithCode:(NSString *)code
{
    __weak __typeof__(self) weakSelf = self;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:WeChatAccessTokenAPI,self.weChatAPPKey,self.weChatSecret,code]];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            weakSelf.authComplete(nil,NO,error.localizedDescription);
        }else{
            NSError *parseError;
            NSDictionary *resDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&parseError];
            if (parseError) {
                weakSelf.authComplete(nil,NO,parseError.localizedDescription);
            }else{
//                NSLog(@"%@",resDic);
                NSString *access_token = [resDic objectForKey:@"access_token"];
                NSString *openid = [resDic objectForKey:@"openid"];
                NSString *refresh_token = [resDic objectForKey:@"refresh_token"];
                
                NSDictionary *dic = [self getLocalAuthInfo];
                NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithDictionary:dic];
                [mDic setObject:access_token forKey:@"wechatAccessToken"];
                [mDic setObject:openid forKey:@"wechatOpenid"];
                [mDic setObject:refresh_token forKey:@"wechatRefreshToken"];
                [self saveAuthInfo:mDic];
                //请求用户信息
                [self requestToGetWeChatUserInfoWithAccessToken:access_token andOpenid:openid];
            }
        }
    }];
    [task resume];
}

/**
 刷新微信toekn有效期
 @param refreshToken  refreshToken
 */
- (void)requestToRefreshToken:(NSString *)refreshToken
{
    __weak __typeof__(self) weakSelf = self;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:WeChatRefreshTokenAPI,self.weChatAPPKey,refreshToken]];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (weakSelf.authComplete) {
            if (error) {
                weakSelf.authComplete(nil,NO,error.localizedDescription);
            }else{
                NSError *parseError;
                NSDictionary *resDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&parseError];
                if (parseError) {
                    weakSelf.authComplete(nil,NO,parseError.localizedDescription);
                }else{
                    NSString *access_token = [resDic objectForKey:@"access_token"];
                    NSString *openid = [resDic objectForKey:@"openid"];
                    NSString *refresh_token = [resDic objectForKey:@"refresh_token"];
                    
                    if(access_token.length && openid.length && refreshToken.length){
                        NSDictionary *dic = [self getLocalAuthInfo];
                        NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithDictionary:dic];
                        [mDic setObject:access_token forKey:@"wechatAccessToken"];
                        [mDic setObject:openid forKey:@"wechatOpenid"];
                        [mDic setObject:refresh_token forKey:@"wechatRefreshToken"];
                        [weakSelf saveAuthInfo:mDic];
                        //请求用户信息
                        [weakSelf requestToGetWeChatUserInfoWithAccessToken:access_token andOpenid:openid];
                    }else{
                        NSInteger errCode = [[resDic objectForKey:@"errcode"] integerValue];
                        if (errCode == 42002) {
                            //refresh_token过期重新授权
                            [weakSelf clearWeChatAuthInfo];
                            [weakSelf weChatAuth];
                        }else{
                            weakSelf.authComplete(nil,NO,[resDic objectForKey:@"errmsg"]);
                        }
                    }
                }
            }
        }
    }];
    [task resume];
}

/**
 根据token 和 openID 请求用户信息
 @param token AccessToken
 @param openID openID
 */
- (void)requestToGetWeChatUserInfoWithAccessToken:(NSString *)token andOpenid:(NSString *)openID
{
    __weak __typeof__(self) weakSelf = self;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:WeChatUserInfoAPI,token,openID]];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (weakSelf.authComplete) {
            if (error) {
                weakSelf.authComplete(nil,NO,error.localizedDescription);
            }else{
                NSError *parseError;
                NSDictionary *resDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&parseError];
                if (parseError) {
                    weakSelf.authComplete(nil,NO,parseError.localizedDescription);
                }else{
//                    NSLog(@"%@",resDic);
                    NSString * unionid = [resDic objectForKey:@"unionid"];
                    if (unionid) {
                        weakSelf.authComplete(resDic,NO,nil);
                    }else{
                        NSInteger errCode = [[resDic objectForKey:@"errcode"] integerValue];
                        if (errCode == 42001) {
                            //access_token过期刷新有效期
                            NSDictionary *authInfo = [weakSelf getLocalAuthInfo];
                            NSString *refreshToken = [authInfo objectForKey:@"wechatRefreshToken"];
                            [weakSelf requestToRefreshToken:refreshToken];
                        }else if (errCode == 42002){
                            //refresh_token过期重新授权
                            [weakSelf clearWeChatAuthInfo];
                            [weakSelf weChatAuth];
                        }else{
                            weakSelf.authComplete(nil,NO,[resDic objectForKey:@"errmsg"]);
                        }
                    }
                }
            }
        }
    }];
    [task resume];
}

/**
 微博登录
 @param authComplete 回调登录结果
 */
- (void)weiboLoginComplete:(PandoraAuthComplete)authComplete
{   //先从本地获取授权信息
    self.authComplete = authComplete;
    NSDictionary *authInfo = [self getLocalAuthInfo];
    NSDate *date = [authInfo objectForKey:@"weiboExpirationDate"];
    if(date && [date laterDate:[NSDate date]])
    {   //存在授权信息而且不过期 直接取用户信息
        NSString *accessToken = [authInfo objectForKey:@"weiboAccessToken"];
        NSString *userID = [authInfo objectForKey:@"weiboUserID"];
        [self requestToGetWeiboUserInfoWithAccessToken:accessToken andUserID:userID];
    }else if (date && [date earlierDate:[NSDate date]]){
        //存在但是过期
        NSString *refreshToken = [authInfo objectForKey:@"weiboRefreshToken"];
        [self requestToRenewWeiboAccessTokenWithRefreshToken:refreshToken];
    }else{
        //不存在 请求授权
        WBAuthorizeRequest *request = [WBAuthorizeRequest request];
        request.redirectURI = self.weiboRedirectURI;
        request.scope = @"all";
        [WeiboSDK sendRequest:request];
    }
}

/**
 请求微博用户信息
 @param accessToken 授权标识
 @param userID 用户ID
 */
- (void)requestToGetWeiboUserInfoWithAccessToken:(NSString *)accessToken andUserID:(NSString *)userID
{   //请求微博用户信息
    __weak __typeof__(self) weakSelf = self;
    [WBHttpRequest requestForUserProfile:userID withAccessToken:accessToken andOtherProperties:nil queue:nil withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
        //获取微博用户信息的回调
        if (weakSelf.authComplete) {
            if (error) {
                if (error.code == 21315) {
                    //token过期  刷新token有效期
                    NSDictionary *authInfo = [weakSelf getLocalAuthInfo];
                    NSString *refreshToken = [authInfo objectForKey:@"weiboRefreshToken"];
                    [weakSelf requestToRenewWeiboAccessTokenWithRefreshToken:refreshToken];
                }else{
                    self.authComplete(nil,NO,error.localizedDescription);
                }
            }else{
                self.authComplete(result,NO,nil);
            }
        }
    }];
}

/**
 刷新微博token有效期
 @param refreshToken refreshToken
 */
- (void)requestToRenewWeiboAccessTokenWithRefreshToken:(NSString *)refreshToken
{
    __weak __typeof__(self) weakSelf = self;
    [WBHttpRequest requestForRenewAccessTokenWithRefreshToken:refreshToken queue:nil withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
        if(!error && result)
        {
            NSString *token = [result objectForKey:@"access_token"];
            NSString *userID = [result objectForKey:@"uid"];
            [weakSelf requestToGetWeiboUserInfoWithAccessToken:token andUserID:userID];
        }else{
            //错误就清除本地信息
            [weakSelf clearWeiboAuthInfo];
            if (self.authComplete) {
                self.authComplete(nil,NO,error.localizedDescription);
            }
        }
    }];
}


/**
 支付宝授权
 @param complete 返回授权结果
 */
- (void)aliPayLoginComplete:(PandoraAuthComplete)complete
{
    self.authComplete = complete;
    
    __weak __typeof__(self) weakSelf = self;
    APayAuthInfo *auth = [[APayAuthInfo alloc] initWithAppID:self.aliPayAPPID pid:@"" redirectUri:self.aliPayRedirectURL];
    [[AlipaySDK defaultService] authWithInfo:auth callback:^(NSDictionary *resultDic) {
        
        NSString *resultCode = [resultDic objectForKey:@"resultCode"];
        if (weakSelf.authComplete) {
            if ([resultCode isEqualToString:@"200"]) {
                self.authComplete(resultDic,NO,nil);
            }else if([resultCode isEqualToString:@"203"]){
                self.authComplete(resultDic,YES,nil);
            }
            else{
                if (self.authComplete) {
                    self.authComplete(nil,NO,resultCode);
                }
            }
        }
    }];
}

/**
 QQ授权登录
 @param complete 登录回调
 */
- (void)QQLoginComplete:(PandoraAuthComplete)complete
{
    self.authComplete = complete;
    NSArray* permissions = [NSArray arrayWithObjects:
                            kOPEN_PERMISSION_GET_USER_INFO,
                            kOPEN_PERMISSION_ADD_SHARE,
                            nil];
    [self.tencentOauth authorize:permissions inSafari:NO];
}

/**
 获取本地保存的授权信息
 @return 返回plist
 */
- (NSDictionary *)getLocalAuthInfo
{
    NSString *homeDictionary = NSHomeDirectory();//获取根目录
    NSString *filePath  = [homeDictionary stringByAppendingPathComponent:PandoraAuthInfo];//添加储存的文件名
    NSDictionary *authInfo = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    return authInfo ? authInfo : @{};
}

/**
 保存授权信息到本地
 @param authInfo 授权信息
 @return 结果
 */
- (BOOL)saveAuthInfo:(NSMutableDictionary *)authInfo
{
    NSString *homeDictionary = NSHomeDirectory();//获取根目录
    NSString *filePath  = [homeDictionary stringByAppendingPathComponent:PandoraAuthInfo];//添加储存的文件名
    return [NSKeyedArchiver archiveRootObject:authInfo toFile:filePath];
}

/**
    清除本地保存的微博授权信息
 */
- (void)clearWeiboAuthInfo
{
    NSDictionary *dic = [self getLocalAuthInfo];
    NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    [mDic removeObjectForKey:@"weiboExpirationDate"];
    [mDic removeObjectForKey:@"weiboAccessToken"];
    [mDic removeObjectForKey:@"weiboUserID"];
    [mDic removeObjectForKey:@"weiboRefreshToken"];
    [self saveAuthInfo:mDic];
}

/**
    清除本地微信授权信息
 */
- (void)clearWeChatAuthInfo
{
    NSDictionary *dic = [self getLocalAuthInfo];
    NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    [mDic removeObjectForKey:@"wechatAccessToken"];
    [mDic removeObjectForKey:@"wechatOpenid"];
    [mDic removeObjectForKey:@"wechatRefreshToken"];
    [self saveAuthInfo:mDic];
}

@end
