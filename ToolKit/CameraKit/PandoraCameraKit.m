//
//  PandoraCameraKit.m
//  PandoraBox
//
//  Created by xidee on 2017/3/17.
//  Copyright © 2017年 IntimeE-CommerceCo. All rights reserved.
//

#import "PandoraCameraKit.h"
#import <Photos/Photos.h>

@interface PandoraCameraKit ()

@property(copy) PandoraCameraResult result;

@end

@implementation PandoraCameraKit

- (UIImagePickerController *)showImagePickerControllerWithSourceType:(UIImagePickerControllerSourceType)sourceType inViewController:(UIViewController *)viewController completion:(PandoraCameraResult)result
{
    UIImagePickerController * picker;
    
    if (sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            picker = [[UIImagePickerController alloc] init];
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            picker.delegate = self;
            [viewController presentViewController:picker animated:YES completion:nil];
            self.result = result;
        }else{
            NSLog(@"PandoraCameraKit 不支持访问相册");
        }
    }else if(sourceType == UIImagePickerControllerSourceTypeCamera){
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            picker = [[UIImagePickerController alloc] init];
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            picker.delegate = self;
            [viewController presentViewController:picker animated:YES completion:nil];
            self.result = result;
        }else{
            NSLog(@"PandoraCameraKit 不支持访问相机");
        }   
    }
    return picker;
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage * image =info[UIImagePickerControllerOriginalImage];
    if (self.result) {
        self.result(image);
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
