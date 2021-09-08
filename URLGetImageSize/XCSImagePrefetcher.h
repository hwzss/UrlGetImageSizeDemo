//
//  XCSImagePrefetcher.h
//  URLGetImageSize
//
//  Created by kaifa on 2019/2/1.
//  Copyright © 2019 MC_MaoDou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface XCSImagePrefetcher : NSObject

@property (nonatomic, strong, readonly) NSMutableData *downloadData;
@property (nonatomic, strong, readonly) NSURL *imageUrl;

- (instancetype)init NS_UNAVAILABLE;

/// 初始化图片获取器
/// @param url url
/// @param timeInterval 最大等待时间，超过时间则获取失败。同步请求过程中建议设置这个时间，目前默认 1.5 秒
- (instancetype)initWithUrl:(NSURL *)url timeInterval:(NSInteger)timeInterval NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithUrl:(NSURL *)url;


/// 获取图片大小，同步方式，建议放非 main thread 线程执行
- (CGSize)fetchImageSize;

@end

NS_ASSUME_NONNULL_END
