//
//  XCSImagePrefetcher.m
//  URLGetImageSize
//
//  Created by kaifa on 2019/2/1.
//  Copyright © 2019 MC_MaoDou. All rights reserved.
//

#import "XCSImagePrefetcher.h"

CF_INLINE uint16_t XCSSwapWebIntToInt16(uint16_t arg) {
    return CFSwapInt16BigToHost(arg);
}
CF_INLINE uint16_t XCSSwapWebIntToInt32(uint32_t arg) {
    return CFSwapInt32BigToHost(arg);
}

typedef enum : NSUInteger {
    XCSImagePrefetcherImageType_PNG,
    XCSImagePrefetcherImageType_GIF,
    XCSImagePrefetcherImageType_JPG,
    XCSImagePrefetcherImageType_BMP,
    XCSImagePrefetcherImageType_UNKOWN
} XCSImagePrefetcherImageType;

#define UN_FETCHED_IMAGE_SIZE CGSizeZero

@interface XCSImagePrefetcher ()<NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSMutableData *downloadData;
@property (nonatomic, assign) XCSImagePrefetcherImageType imageType;
@property (nonatomic, assign) CGSize imageSize;

@end

@implementation XCSImagePrefetcher {
    dispatch_semaphore_t _lock;
}

-(instancetype)initWithUrl:(NSURL *)url{
    if (!url) return nil;
    self=[super init];
    if (self) {
        _imageUrl = url;
        _imageSize = UN_FETCHED_IMAGE_SIZE;
        _imageType = XCSImagePrefetcherImageType_UNKOWN;
    }
    return self;
}

- (NSOperationQueue *)queue {
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
        _queue.name = @"com.xcs.image.prefetcher.queue";
    }
    return _queue;
}

- (CGSize)fetchImageSize {
    return [self downloadDataWithUrl:_imageUrl];
}

- (CGSize )downloadDataWithUrl:(NSURL *)url {
    if (!_session) {
        NSURLSessionConfiguration *config = NSURLSessionConfiguration.defaultSessionConfiguration;
        config.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:self.queue];
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *task = [_session dataTaskWithRequest:request];
    _lock = dispatch_semaphore_create(1);
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    [task resume];
   
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    dispatch_semaphore_signal(_lock);
    return _imageSize;
}

#pragma -mark NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    if (!data) return;
    if (!_downloadData) {
        _downloadData = [[NSMutableData alloc] init];
    }
    [_downloadData appendData:data];
    if (_downloadData.length < 2) return;
    
    if (_imageType == XCSImagePrefetcherImageType_UNKOWN) {
        self.imageType = [self fetchImageTtypeFormData:_downloadData];
    }
    
    // 解析数据
    switch (_imageType) {
        case XCSImagePrefetcherImageType_JPG:
        {
            _imageSize = [self fetchHWFromJPGData:_downloadData];
        }
            break;
        case XCSImagePrefetcherImageType_PNG:
        {
            _imageSize = [self fetchHWFromPNGData:_downloadData];
        }
            break;
        case XCSImagePrefetcherImageType_BMP:
        {
            _imageSize = [self fetchHWFromGIFData:_downloadData];
        }
            break;
        case XCSImagePrefetcherImageType_GIF:
        {
            _imageSize = [self fetchHWFromGIFData:_downloadData];
        }
            break;
            
        default:
            break;
    }
    
    // 获取到提前数据结束
    if (!CGSizeEqualToSize(self.imageSize, UN_FETCHED_IMAGE_SIZE)) {
        [dataTask cancel];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
    if (CGSizeEqualToSize(self.imageSize, UN_FETCHED_IMAGE_SIZE)) {
        if (_downloadData) {
            UIImage *image = [UIImage imageWithData:_downloadData];
            if (image) _imageSize = image.size;
        }
    }
        
    dispatch_semaphore_signal(_lock);
}

- (XCSImagePrefetcherImageType)fetchImageTtypeFormData:(NSData *)data {
    if(data.length < 2) return XCSImagePrefetcherImageType_UNKOWN;

    UInt8 word0 = 0x0, word1 = 0x0;
    [data getBytes:&word0 range:NSMakeRange(0, 1)];
    [data getBytes:&word1 range:NSMakeRange(1, 1)];
    
    if (word0 == 0xFF && word1 == 0xD8) {
        return XCSImagePrefetcherImageType_JPG;
    }else if (word0 == 0x89 && word1 == 0x50) {
        return XCSImagePrefetcherImageType_PNG;
    }else if (word0 == 0x47 && word1 == 0x49) {
        return XCSImagePrefetcherImageType_GIF;
    }else if (word0 == 0x42 && word1 == 0x4D) {
        return XCSImagePrefetcherImageType_BMP;
    }
    return XCSImagePrefetcherImageType_UNKOWN;
}

- (CGSize)fetchHWFromJPGData:(NSData *)data {
    CGSize size = CGSizeZero;
    // jpeg 文件格式头中有JFTF也有EXIF，EXIF相对复杂，具体头部结构可以见https://blog.csdn.net/ryfdizuo/article/details/41250775
    // FF D8 FF E0 (XX XX 这两字节为长度) ('JF' 'TF' 转为ascll码值)
    UInt8 word0 = 0x0, word1 = 0x0, word2 = 0x0, word3 = 0x0;
    [data getBytes:&word0 range:NSMakeRange(0, 1)];
    [data getBytes:&word1 range:NSMakeRange(1, 1)];
    [data getBytes:&word2 range:NSMakeRange(2, 1)];
    [data getBytes:&word3 range:NSMakeRange(3, 1)];
    if (word0 == 0xFF && word1 == 0xD8 && word2 == 0xFF && word3 == 0xE0) {
        UInt8 c0 = 0, c1 = 0, c2 = 0, c3 = 0;
        [data getBytes:&c0 range:NSMakeRange(6, 1)];
        [data getBytes:&c1 range:NSMakeRange(7, 1)];
        [data getBytes:&c2 range:NSMakeRange(8, 1)];
        [data getBytes:&c3 range:NSMakeRange(9, 1)];
        if (c0 == 'J' && c1 == 'F' && c2 == 'I' && c3 == 'F') {
            UInt16 block_length = 0;
            [data getBytes:&block_length range:NSMakeRange(4, 2)];
            block_length = XCSSwapWebIntToInt16(block_length);
            int i = 4;
            do {
                i += block_length;
                if (i > data.length) {
                    break;
                }
                UInt8 aW = 0x0;
                [data getBytes:&aW range:NSMakeRange(i, 1)];
                if (aW != 0xFF) {
                    break;
                }
                
                UInt8 ca = 0x0;
                [data getBytes:&ca range:NSMakeRange(i+1, 1)];
                if (ca >= 0xC0 && ca<= 0xC3) {
                    /**
                     图片信息段 FF CO (xx xx 该段长度) XX(抛弃字节，不用) (HH HH 高度) (WW WW 宽度) ...后面是其他信息。
                     这里宽高段和 png gif 等都不一样，jpg 是高在前
                     */
                    UInt16 w = 0, h = 0;
                    [data getBytes:&h range:NSMakeRange(i + 5, 2)];
                    [data getBytes:&w range:NSMakeRange(i + 7, 2)];
                    w = XCSSwapWebIntToInt16(w);
                    h = XCSSwapWebIntToInt16(h);
                    size = CGSizeMake(w, h);
                    break;
                }else {
                    i += 2;
                    [data getBytes:&block_length range:NSMakeRange(i, 2)];
                    block_length = XCSSwapWebIntToInt16(block_length);
                }
            } while (i < data.length);
        }
        
    }
    return size;
}

- (CGSize)fetchHWFromPNGData:(NSData *)data {
    /**
        png 头格式
        89 50 4E 47 0D 0A 1A 0A (4byte IDHR) (4Byte CHUNKTYPE) (4Byte WIDTH) (4Byte HEIGHT) ....
        至少需要24bytes
     */
    if (data.length < 24) return CGSizeZero;
    UInt32 w = 0, h = 0;
    [data getBytes:&w range:NSMakeRange(16, 4)];
    [data getBytes:&h range:NSMakeRange(20, 4)];
    w = XCSSwapWebIntToInt32(w);
    h = XCSSwapWebIntToInt32(h);
    return CGSizeMake(w, h);
}

- (CGSize)fetchHWFromGIFData:(NSData *)data {
    /**
     GIF 头格式
     47 49 46 38 39 61 (2Byte WIDTH) (2Byte HEIGHT) ....
     至少需要10bytes
     */
    if (data.length < 10) return CGSizeZero;
    UInt16 w = 0, h = 0;
    [data getBytes:&w range:NSMakeRange(6, 2)];
    [data getBytes:&h range:NSMakeRange(8, 2)];
    return CGSizeMake(w, h);
}

- (CGSize)fetchHWFromBMPData:(NSData *)data {
    /**
     BMP 头格式可见http://www.fastgraph.com/help/bmp_os2_header_format.html
     */
    if (data.length < 29) return CGSizeZero;
    UInt32 length = 0;
    [data getBytes:&length range:NSMakeRange(14, 4)];
    length = XCSSwapWebIntToInt32(length);
    
    if (length == 12) {
        UInt16 w = 0, h = 0;
        [data getBytes:&w range:NSMakeRange(18, 2)];
        [data getBytes:&h range:NSMakeRange(820, 2)];
        w = XCSSwapWebIntToInt16(w);
        h = XCSSwapWebIntToInt16(h);
        return CGSizeMake(w, h);
    }else {
        UInt32 w = 0, h = 0;
        [data getBytes:&w range:NSMakeRange(18, 4)];
        [data getBytes:&h range:NSMakeRange(22, 4)];
        w = XCSSwapWebIntToInt32(w);
        h = XCSSwapWebIntToInt32(h);
        return CGSizeMake(w, h);
    }

    return CGSizeZero;
}

@end
