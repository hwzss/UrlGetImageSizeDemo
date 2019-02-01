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
#import "UIImage+ImgSize.h"
#import "XCSImagePrefetcher.h"

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
    
    for (int i = 0; i < 1000; i++) {
        XCSImagePrefetcher *fetcher = [[XCSImagePrefetcher alloc] initWithUrl:[NSURL URLWithString:@"http://pic1.win4000.com/wallpaper/0/5864b91f1ef63.jpg"]];
        NSLog(@"%@", NSStringFromCGSize([fetcher fetchImageSize]));
    }

}
- (IBAction)downloadJPG:(id)sender {
    NSLog(@"%@", NSStringFromCGSize([self jpgImageSizeFormUrl:[NSURL URLWithString:@"http://pic1.win4000.com/wallpaper/0/5864b91f1ef63.jpg"]]));
}

- (IBAction)downloadJPEG:(id)sender {
    XCSImagePrefetcher *fetcher = [[XCSImagePrefetcher alloc] initWithUrl:[NSURL URLWithString:@"http://pic1.win4000.com/wallpaper/0/5864b91f1ef63.jpg"]];
    NSLog(@"%@", NSStringFromCGSize([fetcher fetchImageSize]));
    
//    NSLog(@"%@", NSStringFromCGSize([self jpegImageSizeFromUrl:[NSURL URLWithString:@"http://pic1.win4000.com/wallpaper/0/5864b91f1ef63.jpg"]]));
//    NSLog(@"%@", NSStringFromCGSize([self jpegImageSizeFromUrl:[NSURL URLWithString:@"https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=1022687199,8493043&fm=26&gp=0.jpg"]]));
}
- (IBAction)downloadPNG:(id)sender {
//    NSLog(@"%@", NSStringFromCGSize([self pngImageSizeFromUrl:[NSURL URLWithString:@"https://raw.githubusercontent.com/hwzss/sketch_learning/master/%E6%9E%81%E6%81%B6%E4%B8%96%E4%BB%A3.png"]]));
    
    XCSImagePrefetcher *fetcher = [[XCSImagePrefetcher alloc] initWithUrl:[NSURL URLWithString:@"https://raw.githubusercontent.com/hwzss/sketch_learning/master/%E6%9E%81%E6%81%B6%E4%B8%96%E4%BB%A3.png"]];
    NSLog(@"%@", NSStringFromCGSize([fetcher fetchImageSize]));
}
- (IBAction)downloadBMP:(id)sender {
   
    XCSImagePrefetcher *fetcher = [[XCSImagePrefetcher alloc] initWithUrl:[NSURL URLWithString:@"https://ssl.gstatic.com/gb/images/v1_051523630.png"]];
    NSLog(@"%@", NSStringFromCGSize([fetcher fetchImageSize]));
}

- (IBAction)downloadGif:(id)sender {
//    NSLog(@"%@", NSStringFromCGSize([self gifSizeFormUrl:[NSURL URLWithString:@"https://raw.githubusercontent.com/hwzss/MyArticles/master/iOS%20%E7%A8%8B%E5%BA%8F%E5%91%98%E7%9A%84%20Ruby%20%E5%88%9D%E4%BD%93%E9%AA%8C/2018-02-15%2019_16_29.gif"]]));
    XCSImagePrefetcher *fetcher = [[XCSImagePrefetcher alloc] initWithUrl:[NSURL URLWithString:@"https://raw.githubusercontent.com/hwzss/MyArticles/master/iOS%20%E7%A8%8B%E5%BA%8F%E5%91%98%E7%9A%84%20Ruby%20%E5%88%9D%E4%BD%93%E9%AA%8C/2018-02-15%2019_16_29.gif"]];
    NSLog(@"%@", NSStringFromCGSize([fetcher fetchImageSize]));
}

- (IBAction)useImageSizeToDownLoadJpeg:(id)sender {
    NSLog(@"%@", NSStringFromCGSize([UIImage getImageSizeWithURL:@"https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=1022687199,8493043&fm=26&gp=0.jpg"]));
}

- (IBAction)useIMageSizeToDownloadJpg:(id)sender {
    NSLog(@"%@", NSStringFromCGSize([UIImage getImageSizeWithURL:@"http://pic1.win4000.com/wallpaper/0/5864b91f1ef63.jpg"]));
}

- (IBAction)useImageSizeToDownLoadPng:(id)sender {
    NSLog(@"%@", NSStringFromCGSize([UIImage getImageSizeWithURL:@"https://raw.githubusercontent.com/hwzss/sketch_learning/master/%E6%9E%81%E6%81%B6%E4%B8%96%E4%BB%A3.png"]));
}

- (IBAction)useImageSizeToDownBmp:(id)sender {

    NSLog(@"%@", NSStringFromCGSize([self pngImageSizeFromUrl:[NSURL URLWithString:@"https://ssl.gstatic.com/gb/images/v1_051523630.png"]]));
}
- (IBAction)useImageSizeToDownloadGif:(id)sender {
     NSLog(@"%@", NSStringFromCGSize([UIImage getImageSizeWithURL:@"https://raw.githubusercontent.com/hwzss/MyArticles/master/iOS%20%E7%A8%8B%E5%BA%8F%E5%91%98%E7%9A%84%20Ruby%20%E5%88%9D%E4%BD%93%E9%AA%8C/2018-02-15%2019_16_29.gif"]));
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

- (CGSize)jpegImageSizeFromUrl:(NSURL *)url {
    CGSize size = CGSizeZero;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:NSURLSessionConfiguration.defaultSessionConfiguration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
    _imageData = [[NSMutableData alloc] init];
    [task resume];

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



#pragma -mark NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    NSLog(@"%s",__func__);
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    NSLog(@"%s",__func__);
    [_imageData appendData:data];
    if (_imageData.length > 2) {
        // jpeg 文件格式头中有JFTF也有EXIF，EXIF相对复杂，具体头部结构可以见https://blog.csdn.net/ryfdizuo/article/details/41250775
        // FF D8 FF E0 (XX XX 这两字节为长度) ('JF' 'TF' 转为ascll码值)
        UInt8 word0 = 0x0, word1 = 0x0, word2 = 0x0, word3 = 0x0;
        [_imageData getBytes:&word0 range:NSMakeRange(0, 1)];
        [_imageData getBytes:&word1 range:NSMakeRange(1, 1)];
        [_imageData getBytes:&word2 range:NSMakeRange(2, 1)];
        [_imageData getBytes:&word3 range:NSMakeRange(3, 1)];
        if (word0 == 0xFF && word1 == 0xD8 && word2 == 0xFF && word3 == 0xE0) {
            NSLog(@"抓到了0xFFD8FFE0");
            UInt8 c0 = 0, c1 = 0, c2 = 0, c3 = 0;
            [_imageData getBytes:&c0 range:NSMakeRange(6, 1)];
            [_imageData getBytes:&c1 range:NSMakeRange(7, 1)];
            [_imageData getBytes:&c2 range:NSMakeRange(8, 1)];
            [_imageData getBytes:&c3 range:NSMakeRange(9, 1)];
            if (c0 == 'J' && c1 == 'F' && c2 == 'I' && c3 == 'F') {
                NSLog(@"进入识别");
                UInt16 block_length = 0;
                [_imageData getBytes:&block_length range:NSMakeRange(4, 2)];
                if (NSHostByteOrder() == CFByteOrderBigEndian) {
                    block_length = CFSwapInt16HostToBig(block_length);
                }else {
                    block_length = XCSSwapWebIntToInt16(block_length);
                }
                int i = 4;
                do {
                    i += block_length;
                    if (i > data.length) {
                        return;
                    }
                    UInt8 aW = 0x0;
                    [_imageData getBytes:&aW range:NSMakeRange(i, 1)];
                    if (aW != 0xFF) {
                        return;
                    }
                    
                    UInt8 ca = 0x0;
                    [_imageData getBytes:&ca range:NSMakeRange(i+1, 1)];
                    if (ca >= 0xC0 && ca<= 0xC3) {
                        /**
                         图片信息段 FF CO (xx xx 该段长度) XX(抛弃字节，不用) (HH HH 高度) (WW WW 宽度) ...后面是其他信息。
                         这里宽高段和 png gif 等都不一样，jpg 是高在前
                         */
                        UInt16 w = 0, h = 0;
                        [_imageData getBytes:&h range:NSMakeRange(i + 5, 2)];
                        [_imageData getBytes:&w range:NSMakeRange(i + 7, 2)];
                        w = XCSSwapWebIntToInt16(w);
                        h = XCSSwapWebIntToInt16(h);
                        NSLog(@"size:%@", NSStringFromCGSize(CGSizeMake(w, h)));
                        [dataTask cancel];
                        return;
                    }else {
                        i += 2;
                        [_imageData getBytes:&block_length range:NSMakeRange(i, 2)];
                        if (NSHostByteOrder() == CFByteOrderBigEndian) {
                            block_length = CFSwapInt16HostToBig(block_length);
                        }else {
                            block_length = XCSSwapWebIntToInt16(block_length);
                        }
                    }
                } while (i < _imageData.length);
                NSLog(@"结束。。。。。。");
            }
            
        }
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
    NSLog(@"%s",__func__);
}


@end

#pragma clang diagnostic pop
