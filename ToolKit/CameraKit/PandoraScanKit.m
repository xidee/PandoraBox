//
//  PandoraScanKit.m
//  PandoraBox
//
//  Created by xidee on 2017/3/17.
//  Copyright © 2017年 IntimeE-CommerceCo. All rights reserved.
//

#import "PandoraScanKit.h"

@interface PandoraScanKit ()

//输入输出会话
@property (nonatomic ,strong) AVCaptureSession *session;
//设备
@property (nonatomic ,strong) AVCaptureDevice *device;
//输出
@property (nonatomic ,strong) AVCaptureMetadataOutput *output;

@end

@implementation PandoraScanKit

- (instancetype)initSessionInView:(UIView *)superView
{
    self = [super init];
    //获取摄像头设备
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //检查输入流是否可用
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&error];
    if (error) {
        NSLog(@"PandoraScanKit:获取摄像头失败%@", error.localizedDescription);
        return nil;
    }
    
    // 设置输出(Metadata元数据)
    self.output = [[AVCaptureMetadataOutput alloc] init];
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];

    //初始化会话
    self.session = [[AVCaptureSession alloc] init];
    
    [self.session addInput:input];
    [self.session addOutput:self.output];
    self.session.sessionPreset = AVCaptureSessionPresetHigh;
    
    //设置输出的格式
    self.output.metadataObjectTypes = self.output.availableMetadataObjectTypes;
    
    //扫描框的大小
    CGSize size = superView.bounds.size;
    
    CGFloat sWidth = [UIScreen mainScreen].bounds.size.width;
    
    //这个rect确定了扫描框的范围 缩小扫描范围 增加识别率
    float width = 300 * sWidth / 320;
    CGRect cropRect = CGRectMake((sWidth  - width)/ 2 ,sWidth * 225/1000, width, width);
    
    CGFloat p1 = size.height/size.width;
    CGFloat p2 = 1920./1080.;  //使用了1080p的图像输 出
    if (p1 < p2) {
        CGFloat fixHeight = superView.bounds.size.width * 1920. / 1080.;
        CGFloat fixPadding = (fixHeight - size.height)/2;
        self.output.rectOfInterest = CGRectMake((cropRect.origin.y + fixPadding)/fixHeight,
                                           cropRect.origin.x/size.width,
                                           cropRect.size.height/fixHeight,
                                           cropRect.size.width/size.width);
    } else {
        CGFloat fixWidth = superView.bounds.size.height * 1080. / 1920.;
        CGFloat fixPadding = (fixWidth - size.width)/2;
        self.output.rectOfInterest = CGRectMake(cropRect.origin.y/size.height,
                                           (cropRect.origin.x + fixPadding)/fixWidth,
                                           cropRect.size.height/size.height,
                                           cropRect.size.width/fixWidth);
    }
    
    //创建预览图层
    AVCaptureVideoPreviewLayer *preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    preview.backgroundColor = [UIColor clearColor].CGColor;
    
    [preview setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [preview setFrame:superView.bounds];
    [superView.layer insertSublayer:preview atIndex:0];
    
    //设置焦距
    self.videoZoomFactor = 1.5;
    return self;
}
//设置支持的码类型
- (void)setMetadataObjectTypes:(NSArray *)metadataObjectTypes
{
    self.output.metadataObjectTypes = metadataObjectTypes;
}
//设置焦距
- (void)setVideoZoomFactor:(CGFloat)videoZoomFactor
{
    NSError *error = nil;
    //锁住设备 防止其他线程访问
    if ([self.device lockForConfiguration:&error]) {
        //拉近焦距  提高识别率
        self.device.videoZoomFactor = 1.5;
        //解锁
        [self.device unlockForConfiguration];
    }
}

- (void)startScan
{
    [self.session startRunning];
}

- (void)stopScan
{
    [self.session stopRunning];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    [self.session stopRunning];
    if(metadataObjects.count > 0)
    {
        AVMetadataMachineReadableCodeObject *obj = [metadataObjects firstObject];
        if (self.result) {
            self.result(obj.type,obj.stringValue);
        }
    }
}

@end
