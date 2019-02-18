//
//  NSURL+ImageSize.m
//  URLGetImageSize
//
//  Created by kaifa on 2019/2/18.
//  Copyright © 2019 MC_MaoDou. All rights reserved.
//

#import "NSURL+ImageSize.h"

@implementation NSURL (ImageSize)

- (CGSize)xcs_pngImageSize {
    __block CGSize size = CGSizeZero;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self];
    if (!request) return size;
    
    [request setValue:@"bytes=16-23" forHTTPHeaderField:@"Range"];
    
    dispatch_semaphore_t lock = dispatch_semaphore_create(1);
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    NSURLSession *session = [NSURLSession sessionWithConfiguration:NSURLSessionConfiguration.defaultSessionConfiguration];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data.length >= 8) {
            int w = 0, h = 0;
            [data getBytes:&w range:NSMakeRange(0, 4)];
            [data getBytes:&h range:NSMakeRange(4, 4)];
            w = CFSwapInt32(w);
            h = CFSwapInt32(h);
            size = CGSizeMake(w, h);
        }
        dispatch_semaphore_signal(lock);
    }];
    [task resume];
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    dispatch_semaphore_signal(lock);
    return size;
}

- (CGSize)xcs_gifImageSize {
    __block CGSize size = CGSizeZero;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self];
    if (!request) return size;
    
    [request setValue:@"bytes=6-9" forHTTPHeaderField:@"Range"];
    
    dispatch_semaphore_t lock = dispatch_semaphore_create(1);
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    NSURLSession *session = [NSURLSession sessionWithConfiguration:NSURLSessionConfiguration.defaultSessionConfiguration];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data.length == 4) {
            UInt16 w = 0, h = 0;
            [data getBytes:&w range:NSMakeRange(0, 2)];
            [data getBytes:&h range:NSMakeRange(2, 2)];
            size = CGSizeMake(w, h);
        }
        dispatch_semaphore_signal(lock);
    }];
    [task resume];
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    dispatch_semaphore_signal(lock);
    return size;
}

- (CGSize)xcs_imageSize {
    CGImageSourceRef imageSourceRef = CGImageSourceCreateWithURL((CFURLRef)self, NULL);
    CGFloat width = 0, height = 0;
    
    if (imageSourceRef) {        
        // 获取图像属性
        CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSourceRef, 0, NULL);
        //以下是对手机32位、64位的处理
        if (imageProperties != NULL) {            
            CFNumberRef widthNumberRef = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelWidth);
            
#if defined(__LP64__) && __LP64__
            if (widthNumberRef != NULL) {
                CFNumberGetValue(widthNumberRef, kCFNumberFloat64Type, &width);
            }
            
            CFNumberRef heightNumberRef = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelHeight);
            
            if (heightNumberRef != NULL) {
                CFNumberGetValue(heightNumberRef, kCFNumberFloat64Type, &height);
            }
#else
            if (widthNumberRef != NULL) {
                CFNumberGetValue(widthNumberRef, kCFNumberFloat32Type, &width);
            }
            
            CFNumberRef heightNumberRef = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelHeight);
            
            if (heightNumberRef != NULL) {
                CFNumberGetValue(heightNumberRef, kCFNumberFloat32Type, &height);
            }
#endif
            /********************** 此处解决返回图片宽高相反问题 **********************/
            // 图像旋转的方向属性
            NSInteger orientation = [(__bridge NSNumber *)CFDictionaryGetValue(imageProperties, kCGImagePropertyOrientation) integerValue];
            CGFloat temp = 0;
            switch (orientation) {
                case UIImageOrientationLeft: // 向左逆时针旋转90度
                case UIImageOrientationRight: // 向右顺时针旋转90度
                case UIImageOrientationLeftMirrored: // 在水平翻转之后向左逆时针旋转90度
                case UIImageOrientationRightMirrored: { // 在水平翻转之后向右顺时针旋转90度
                    temp = width;
                    width = height;
                    height = temp;
                }
                    break;
                default:
                    break;
            }
            /********************** 此处解决返回图片宽高相反问题 **********************/
            
            CFRelease(imageProperties);
        }
        CFRelease(imageSourceRef);
    }
    return CGSizeMake(width, height);
}


@end
