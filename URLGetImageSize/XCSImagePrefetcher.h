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
- (instancetype)initWithUrl:(NSURL *)url NS_DESIGNATED_INITIALIZER;
- (CGSize)fetchImageSize;

@end

NS_ASSUME_NONNULL_END
