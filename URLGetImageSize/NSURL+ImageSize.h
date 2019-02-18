//
//  NSURL+ImageSize.h
//  URLGetImageSize
//
//  Created by kaifa on 2019/2/18.
//  Copyright © 2019 MC_MaoDou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURL (ImageSize)

/**
 get png image's size form url by get png image's head data info.
 this method is recommend if you konw the url is resouce a PNG .
 */
- (CGSize)xcs_pngImageSize;
- (CGSize)xcs_gifImageSize;

/**
 get image's size from url by download a image.
 this method is very slow, not recommend
 */
- (CGSize)xcs_imageSize;

@end

NS_ASSUME_NONNULL_END
