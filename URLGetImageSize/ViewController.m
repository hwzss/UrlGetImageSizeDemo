//
//  ViewController.m
//  URLGetImageSize
//
//  Created by kaifa on 2019/1/31.
//  Copyright © 2019 MC_MaoDou. All rights reserved.
//

/**
 https://raw.githubusercontent.com/hwzss/sketch_learning/master/%E6%9E%81%E6%81%B6%E4%B8%96%E4%BB%A3.png
 https://raw.githubusercontent.com/hwzss/MyArticles/master/iOS%20%E7%A8%8B%E5%BA%8F%E5%91%98%E7%9A%84%20Ruby%20%E5%88%9D%E4%BD%93%E9%AA%8C/2018-02-15%2019_16_29.gif
 // jpeg
 https://raw.githubusercontent.com/hwzss/MyArticles/master/konw_fastlane/%E7%9B%AE%E5%BD%95%E6%88%AA%E5%9B%BE.jpg
 // jpg
 https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=1022687199,8493043&fm=26&gp=0.jpg
 http://pic1.win4000.com/wallpaper/0/5864b91f1ef63.jpg
 // BMP
 https://ssl.gstatic.com/gb/images/v1_051523630.png
 */

#import "ViewController.h"
#import "NSURL+ImageSize.h"
#import "XCSImagePrefetcher.h"

static NSString  *PNG_IMG_URL = @"https://raw.githubusercontent.com/hwzss/sketch_learning/master/%E6%9E%81%E6%81%B6%E4%B8%96%E4%BB%A3.png";
static NSString  *JPG_IMG_URL = @"https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=1022687199,8493043&fm=26&gp=0.jpg";
static NSString  *JPEG_IMG_URL = @"https://raw.githubusercontent.com/hwzss/MyArticles/master/konw_fastlane/%E7%9B%AE%E5%BD%95%E6%88%AA%E5%9B%BE.jpg";
static NSString  *GIF_IMG_URL = @"https://raw.githubusercontent.com/hwzss/MyArticles/master/iOS%20%E7%A8%8B%E5%BA%8F%E5%91%98%E7%9A%84%20Ruby%20%E5%88%9D%E4%BD%93%E9%AA%8C/2018-02-15%2019_16_29.gif";
static NSString  *BMP_IMG_URL = @"https://ssl.gstatic.com/gb/images/v1_051523630.png";

CF_INLINE uint16_t XCSSwapWebIntToInt16(uint16_t arg) {
    if (NSHostByteOrder() == CFByteOrderBigEndian) return arg;
    return CFSwapInt16(arg);
}
CF_INLINE uint16_t XCSSwapWebIntToInt32(uint32_t arg) {
    if (NSHostByteOrder() == CFByteOrderBigEndian) return arg;
    return CFSwapInt32(arg);
}

@interface ViewController ()<NSURLSessionDataDelegate>

@property (nonatomic, strong) NSMutableData *imageData;

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

#pragma -mark >>XCSImagePrefetcher<<
- (IBAction)downloadJPG:(id)sender {
    XCSImagePrefetcher *fetcher = [[XCSImagePrefetcher alloc] initWithUrl:[NSURL URLWithString:JPG_IMG_URL]];
    NSLog(@"%@", NSStringFromCGSize([fetcher fetchImageSize]));
}
- (IBAction)downloadJPEG:(id)sender {
    XCSImagePrefetcher *fetcher = [[XCSImagePrefetcher alloc] initWithUrl:[NSURL URLWithString:JPEG_IMG_URL]];
    NSLog(@"%@", NSStringFromCGSize([fetcher fetchImageSize]));
}
- (IBAction)downloadPNG:(id)sender {
    XCSImagePrefetcher *fetcher = [[XCSImagePrefetcher alloc] initWithUrl:[NSURL URLWithString:PNG_IMG_URL]];
    NSLog(@"%@", NSStringFromCGSize([fetcher fetchImageSize]));
}
- (IBAction)downloadBMP:(id)sender {
    XCSImagePrefetcher *fetcher = [[XCSImagePrefetcher alloc] initWithUrl:[NSURL URLWithString:BMP_IMG_URL]];
    NSLog(@"%@", NSStringFromCGSize([fetcher fetchImageSize]));
}

- (IBAction)downloadGif:(id)sender {
    XCSImagePrefetcher *fetcher = [[XCSImagePrefetcher alloc] initWithUrl:[NSURL URLWithString:GIF_IMG_URL]];
    NSLog(@"%@", NSStringFromCGSize([fetcher fetchImageSize]));
}

#pragma -mark >>UIImage+ImagSize<<
- (IBAction)useImageSizeToDownLoadJpeg:(id)sender {
    
    NSLog(@"%@", NSStringFromCGSize([[NSURL URLWithString:JPEG_IMG_URL] xcs_imageSize]));
}

- (IBAction)useIMageSizeToDownloadJpg:(id)sender {
    NSLog(@"%@", NSStringFromCGSize([[NSURL URLWithString:JPG_IMG_URL] xcs_imageSize]));
}

- (IBAction)useImageSizeToDownLoadPng:(id)sender {
    NSLog(@"%@", NSStringFromCGSize([[NSURL URLWithString:PNG_IMG_URL] xcs_imageSize]));
}

- (IBAction)useImageSizeToDownBmp:(id)sender {
    NSLog(@"%@", NSStringFromCGSize([self pngImageSizeFromUrl:[NSURL URLWithString:BMP_IMG_URL]]));
}

- (IBAction)useImageSizeToDownloadGif:(id)sender {
     NSLog(@"%@", NSStringFromCGSize([[NSURL URLWithString:GIF_IMG_URL] xcs_imageSize]));
}

#pragma -mark >>DownloadSomeBytes by Range<<

- (IBAction)downJPG:(id)sender {
     NSLog(@"%@", NSStringFromCGSize([self jpgImageSizeFormUrl:[NSURL URLWithString:JPG_IMG_URL]]));
}

- (IBAction)downPng:(id)sender {
     NSLog(@"%@", NSStringFromCGSize([[NSURL URLWithString:PNG_IMG_URL] xcs_pngImageSize]));
}

- (IBAction)downBMP:(id)sender {
}

- (IBAction)downGIF:(id)sender {
    NSLog(@"%@", NSStringFromCGSize([self gifSizeFormUrl:[NSURL URLWithString:GIF_IMG_URL]]));
}

- (IBAction)downJPEG:(id)sender {
    
}

- (CGSize)gifSizeFormUrl:(NSURL *)url {
    CGSize size = CGSizeZero;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"bytes=6-9" forHTTPHeaderField:@"Range"];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil
                                                     error:nil];
    
    if (data.length == 4) {
        UInt16 w = 0, h = 0;
        [data getBytes:&w range:NSMakeRange(0, 2)];
        [data getBytes:&h range:NSMakeRange(2, 2)];
        size = CGSizeMake(w, h);
    }
    return size;
}


- (CGSize)jpgImageSizeFormUrl:(NSURL *)url {
    CGSize size = CGSizeZero;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"bytes=0-209" forHTTPHeaderField:@"Range"];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil
                                                     error:nil];
    if ([data length] <= 0x58) {
        return CGSizeZero;
    }

    if ([data length] < 210) {// 肯定只有一个DQT字段
        short w1 = 0, w2 = 0;
        [data getBytes:&w1 range:NSMakeRange(0x60, 0x1)];
        [data getBytes:&w2 range:NSMakeRange(0x61, 0x1)];
        short w = (w1 << 8) + w2;
        short h1 = 0, h2 = 0;
        [data getBytes:&h1 range:NSMakeRange(0x5e, 0x1)];
        [data getBytes:&h2 range:NSMakeRange(0x5f, 0x1)];
        short h = (h1 << 8) + h2;
        return CGSizeMake(w, h);
    } else {
        short word = 0x0;
        [data getBytes:&word range:NSMakeRange(0x15, 0x1)];
        if (word == 0xdb) {
            [data getBytes:&word range:NSMakeRange(0x5a, 0x1)];
            if (word == 0xdb) {// 两个DQT字段
                short w1 = 0, w2 = 0;
                [data getBytes:&w1 range:NSMakeRange(0xa5, 0x1)];
                [data getBytes:&w2 range:NSMakeRange(0xa6, 0x1)];
                short w = (w1 << 8) + w2;
                short h1 = 0, h2 = 0;
                [data getBytes:&h1 range:NSMakeRange(0xa3, 0x1)];
                [data getBytes:&h2 range:NSMakeRange(0xa4, 0x1)];
                short h = (h1 << 8) + h2;
                return CGSizeMake(w, h);
            } else {// 一个DQT字段
                short w1 = 0, w2 = 0;
                [data getBytes:&w1 range:NSMakeRange(0x60, 0x1)];
                [data getBytes:&w2 range:NSMakeRange(0x61, 0x1)];
                short w = (w1 << 8) + w2;
                short h1 = 0, h2 = 0;
                [data getBytes:&h1 range:NSMakeRange(0x5e, 0x1)];
                [data getBytes:&h2 range:NSMakeRange(0x5f, 0x1)];
                short h = (h1 << 8) + h2;
                return CGSizeMake(w, h);
            }
        } else {
            return CGSizeZero;
        }
    }
    
    
    return size;
}

- (CGSize)pngImageSizeFromUrl:(NSURL *)url {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"bytes=16-23" forHTTPHeaderField:@"Range"];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil
                                                     error:nil];
    
    CGSize size = CGSizeZero;
    if (data.length >= 8) {
        int w = 0, h = 0;
        [data getBytes:&w range:NSMakeRange(0, 4)];
        [data getBytes:&h range:NSMakeRange(4, 4)];
        w = XCSSwapWebIntToInt32(w);
        h = XCSSwapWebIntToInt32(h);
        size = CGSizeMake(w, h);
    }
    return size;
}

@end

#pragma clang diagnostic pop
