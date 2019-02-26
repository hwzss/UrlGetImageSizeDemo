# UrlGetImageSizeDemo

文章地址：https://www.jianshu.com/p/cfc35d8546f0

# 通过 URL 获取图片宽高优化



![一张小图.png](https://raw.githubusercontent.com/hwzss/MyArticles/master/URL%E8%8E%B7%E5%8F%96%E5%9B%BE%E7%89%87%E5%AE%BD%E9%AB%98/URL%E8%8E%B7%E5%8F%96%E5%9B%BE%E7%89%87%E5%AE%BD%E9%AB%98.png)
### 前言
客户端研发时，有时会有这样的需求，需要根据图片链接地址获取图片的宽高来进行界面排版。

一般比较正规的做法，是服务端在返回数据时将图片的信息属性一起带回来，这也符合轻客户端设计规范。但是现实不是理想，有时就是会出现服务端没有返回，你却要知道图片宽高，所以本文，针对通过 URL 来获取图片宽高进行简单的介绍。

### 传统获取图片宽高方案：
最为常见也是最慢的一种方案，通过 URL 下载图片，得到图片数据后获取图片宽高。

这种方式 iOS 下有很多实现方案，可以使用三方工具进行图片下载，也可以直接自己写，该方法思想就是通过下载整个图片然后得到完整的图片数据信息，解析数据，再从中得到图片的宽高。 比如本文使用 `CGImageSource` 来通过 URL 图片信息，从而得到图片的宽高。代码如下：

``` objc
// 获取图像属性
CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSourceRef, 0, NULL);
```
返回的 `imageProperties` 就已经从整个图片数据中获取到需要的信息了，我们只需要从中通过 KEY 来取出需要的值。

```objc
// 获取宽高
CFNumberRef widthNumberRef = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelWidth);
CFNumberRef heightNumberRef = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelHeight);
```

### 改进方案：
在传统方案里，获取图片的宽高的时候，下载了整个图片数据，但这里我们的需求只是获取图片的宽高信息，此时还不需要全部的图片信息，下载完整的图片数据，导致需要获取的数据量更大，从而增加的宽高获取到的时间，减少了我们的流畅性。

如果我们通过 URL 只下载我们需要的图片中的某些信息的话（比如宽高信息），就能减少此次请求的传输的数据量，从而加快信息的获取。那如何实现呢？

在图片数据中，不管什么格式，在表示该图片的数据中都有一段数据块表示着这个图片的描述信息，其中就包含着该图片的宽高大小。所以知道这点，我们只要通过 URL 请求获取该部分段信息，就可以从中解析出我们需要的图片宽高。

让我们先看下 PNG 图片的数据格式的大概模样，如下图：

![PNG数据头数据图](https://raw.githubusercontent.com/hwzss/MyArticles/master/URL%E8%8E%B7%E5%8F%96%E5%9B%BE%E7%89%87%E5%AE%BD%E9%AB%98/PNG%E5%A4%B4.png)

图中我们只需要关注 `PNG Signature` 与标红的 `WIDTH` `HEIGHT` 段，`PNG Signature`标志着该图片是一张 PNG 图，知道它是 PNG 图数据后，如果图片数据的开头与这张图中一致，则代表该图片是一张 PNG 图。

在数据的固定位置处，即 `WIDTH` `HEIGHT` 所在的字节位置里存放的就是该图片的宽高信息，所以我们只需要从该处取出所存数据就知道图片宽高了。

同理针对其他格式的图片也是一样的，只是他们中数据的段格式以及位置有些不同，但都存在着这样一个数据段表示着图片的描述信息。(这里并不对所有的图片格式进行介绍，这里了解[资料](http://www.fastgraph.com/help/image_file_header_formats.html))

下面是 GIF 图的文件头格式图：

![GIF头格式](https://raw.githubusercontent.com/hwzss/MyArticles/master/URL%E8%8E%B7%E5%8F%96%E5%9B%BE%E7%89%87%E5%AE%BD%E9%AB%98/gif%E5%A4%B4.png)

### 代码实现：
1. 方式1：通过设置 `HTTP` 请求头 `Range` 字段来获取数据的某位置段数据；

   比如，此时有一张 PNG 图的链接地址，想要知道其宽高，代码如下：
   
   ``` objc
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"bytes=16-23" forHTTPHeaderField:@"Range"];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil
                                                     error:nil];
    CGSize size = CGSizeZero;
    if (data.length >= 8) {
        int w = 0, h = 0;
        [data getBytes:&w range:NSMakeRange(0, 4)];
        [data getBytes:&h range:NSMakeRange(4, 4)];
        w = CFSwapInt32BigToHost(w);
        h = CFSwapInt32BigToHost(h);
        size = CGSizeMake(w, h);
    }
   ```
   在`16-23`字节位置处，前4字节代表着宽，后4字节代表着高，由此我们就完成了图片的宽高获取，相对于传统方式，不管图片真实大小多大，我们只下载了仅仅 8 字节的数据，无疑加快了速度和节省了流量，其他格式图代码可见[文件](https://github.com/hwzss/UrlGetImageSizeDemo/blob/master/URLGetImageSize/NSURL%2BImageSize.m)。
2.  方式2：直接下载，在网络回调中解析数据，得到足够数据后，解析出宽高，提前停止请求。
在第一种方式中，虽然速度很快但存在一个问题，下载前必须先知道图片宽高数据存储位置，对于 PNG 和 GIF 图片来说是没有问题，但在 JPG 格式图时，由于其数据段并不是在文件的头部，也不再固定的位置，可能在中间的任何一段地方，所以通过提前指定请求头 的 `Range` 范围是无法有效获取到信息的，此时我们只能通过一边下载图片数据，一边在解析得到的数据，如果检测到了图片的描述信息段，则开始解析，解析成功后提前结束网络请求，这样在速度和流量方面相对于传统的依然是有一定的提升。下图为 JPG 图数据格式：
    ![](https://raw.githubusercontent.com/hwzss/MyArticles/master/URL%E8%8E%B7%E5%8F%96%E5%9B%BE%E7%89%87%E5%AE%BD%E9%AB%98/JPEG%E5%9B%BE.png)    
其中 `FFCO`段为描述段信息开头，我们在代码中通过While 来在一个个数据段中寻找该描述段，找到了它就找到了宽高。
    代码如下：
    
``` objc

    - (CGSize)fetchHWFromJPGData:(NSData *)data {
    CGSize size = CGSizeZero;
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
```    
    
更多详情代码，可见[DEMO](https://github.com/hwzss/UrlGetImageSizeDemo)。
    
    
#### 最后结果代码
[XCSImagePrefetcher](https://github.com/hwzss/UrlGetImageSizeDemo/blob/master/URLGetImageSize/XCSImagePrefetcher.m) 通过传入 URL 来获取图片的宽高。

```
@interface XCSImagePrefetcher : NSObject

@property (nonatomic, strong, readonly) NSMutableData *downloadData;
@property (nonatomic, strong, readonly) NSURL *imageUrl;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithUrl:(NSURL *)url NS_DESIGNATED_INITIALIZER;
- (CGSize)fetchImageSize;

@end

```

使用方式如下:

```objc

    XCSImagePrefetcher *fetcher = [[XCSImagePrefetcher alloc] initWithUrl:[NSURL URLWithString:JPG_IMG_URL]];
    NSLog(@"%@", NSStringFromCGSize([fetcher fetchImageSize]));
```

更多测试代码，可见[DEMO](https://github.com/hwzss/UrlGetImageSizeDemo)。
    
#### 总结
1. 在数据的提取过程中，需要注意大小端问题导致的数据解析出来不对（[相关知识](http://www.ruanyifeng.com/blog/2016/11/byte-order.html)）；
2. 即使通过这种方式进行优化，获取图片大小问题仍然因为需要发送网络请求而变的速度不够稳定，所以真正的解决方案，还是需要服务端配合添加上图片数据宽高的记录；
3. 实际应用中需要和缓存配合来达到最佳效果。

#### 相关资料

1. [理解字节序大小端](http://www.ruanyifeng.com/blog/2016/11/byte-order.html)
2. [各种图头信息格式汇总](http://www.fastgraph.com/help/image_file_header_formats.html)
3. [HTTP 头字段了解](https://juejin.im/post/5ab341e06fb9a028c6759ce0)
4. [国外大神文章关于SWIFT版获取图片，本文主要实现也是参考它的, 感谢](http://danielemargutti.com/2018/09/09/prefetching-images-size-without-downloading-them-entirely-in-swift/)

    




