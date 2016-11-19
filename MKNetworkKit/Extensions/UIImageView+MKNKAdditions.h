//
//  UIImageView+MKNKAdditions.h
//  Tokyo
//
//  Created by Mugunth on 30/6/14.
//  Copyright (c) 2014 LifeOpp Pte Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKImageCache.h"


@class MKNetworkRequest;

@interface UIImageView (MKNKAdditions)
- (NSString *)imageUrl;
-(MKNetworkRequest*) imageFetchRequest;
// 图片是否有缓存
+ (BOOL)isImageCached:(NSString*) imageUrlString;
// 缓存在磁盘中的图片
+ (UIImage *)cachedImagewithURLString:(NSString*) imageUrlString;
// 更新本地缓存
+(void)updateCacheImage:(NSData *)data withURLString:(NSString*) imageUrlString;
// 预下载
+ (MKNetworkRequest *)preloadFromURLString:(NSString*) imageUrlString onComplete:(MKNKHandler) completionHandler;

// 加载图片

-(MKNetworkRequest *)loadImageFromURLString:(NSString*) imageUrlString onProgress:(MKNKHandler)progressHandler andComplete:(void(^)(UIImage *image, MKImageCacheType cacheType, NSString *imageUrl, NSError *error)) completionHandlerInMainThread;
-(MKNetworkRequest*) loadImageFromURLString:(NSString*) imageUrlString placeHolderImage:(UIImage*) placeHolderImage animated:(BOOL) animated;
-(MKNetworkRequest*) loadImageFromURLString:(NSString*) imageUrlString;
@end
