//
//  UIImage+ImgSize.h
//  CleverParents
//
//  Created by Candy on 2017/11/13.
//  Copyright © 2017年 com.zhiweism. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface UIImage (ImgSize)

/**
 get png image's size form url by get png image's head data info.
 this method is recommend if you konw the url is resouce a PNG .
 */
+ (CGSize)xcs_pngImageSizeWithUrl:(id )url;
+ (CGSize)xcs_gifImageSizeWithUrl:(id )url;

/**
 get image's size from url by download a image.
 this method is very slow, not recommend
 */
+ (CGSize)xcs_getImageSizeWithUrl:(id)URL;

@end
