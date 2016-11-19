//
//  UIImageView+MKNKAdditions.m
//  Tokyo
//
//  Created by Mugunth on 30/6/14.
//  Copyright (c) 2014 LifeOpp Pte Ltd. All rights reserved.
//

#import <objc/runtime.h>

#import "MKNetworkKit.h"

#import "UIImageView+MKNKAdditions.h"
#import "MKImageCache.h"

@interface MKNetworkRequest (/*Private Methods*/)
@property (readwrite) NSHTTPURLResponse *response;
@property (readwrite) NSData *responseData;
@property (readwrite) NSError *error;
@property (readwrite) MKNKRequestState state;
@property (readwrite) NSURLSessionTask *task;
-(void) setProgressValue:(CGFloat) updatedValue;
@end

static MKNetworkHost *imageHost;
static char imageFetchRequestKey;
static char imageFetchUrlKey;

const float kFromCacheAnimationDuration = 0.0f;
const float kFreshLoadAnimationDuration = 0.25f;

@implementation UIImageView (MKNKAdditions)

+(void) initialize {
    imageHost = [[MKNetworkHost alloc] init];
    [imageHost enableCache];
}

-(MKNetworkRequest*) imageFetchRequest {
    return (MKNetworkRequest*) objc_getAssociatedObject(self, &imageFetchRequestKey);
}

-(void) setImageFetchRequest:(MKNetworkRequest *)imageFetchRequest {
    [[self imageFetchRequest] cancel];
    objc_setAssociatedObject(self, &imageFetchRequestKey, imageFetchRequest, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSString *)imageUrl{
    return (NSString *) objc_getAssociatedObject(self, &imageFetchUrlKey);
}
- (void)setImageUrl:(NSString *)url{
    objc_setAssociatedObject(self, &imageFetchUrlKey, url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (BOOL)isImageCached:(NSString*) imageUrlString{
    if (!imageUrlString)
        return NO;
    return [[MKImageCache sharedImageCache] diskImageExistsWithKey:imageUrlString];
}
+ (UIImage *)cachedImagewithURLString:(NSString*) imageUrlString{
    if (!imageUrlString)
        return nil;
    return [[MKImageCache sharedImageCache] imageFromDiskCacheForKey:imageUrlString];
}
+(void)updateCacheImage:(NSData *)data withURLString:(NSString*) imageUrlString{
    if (!data || !imageUrlString)
        return;
//    UIImage *image = [UIImage imageWithData:data];
//    [[MKImageCache sharedImageCache] storeImage:image forKey:imageUrlString toDisk:YES];
    [[MKImageCache sharedImageCache] storeImageDataToDisk:data forKey:imageUrlString];
}
+ (MKNetworkRequest *)preloadFromURLString:(NSString*) imageUrlString onComplete:(MKNKHandler) completionHandler{
    if ([self isImageCached:imageUrlString])
        return nil;
    
    NSString *cachePath = [[MKImageCache sharedImageCache] defaultCachePathForKey:imageUrlString];
    MKNetworkRequest *req = [imageHost requestWithURLString:imageUrlString];
    req.downloadPath = cachePath;
    [req addCompletionHandler:^(MKNetworkRequest *completedRequest) {
        BOOL bDictinary = NO;
        BOOL bExist = NO;
        bExist = [[NSFileManager defaultManager] fileExistsAtPath:cachePath isDirectory:&bDictinary];
        if (!bExist && !bDictinary && completedRequest.responseData)
            [[MKImageCache sharedImageCache] storeImageDataToDisk:completedRequest.responseData forKey:imageUrlString onComplete:^(NSString *key, UIImage *image) {
                if (completionHandler)
                    completionHandler(completedRequest);
            }];
        else{
            if (completionHandler)
                completionHandler(completedRequest);
        }
    }];
    req.doNotCache = YES;
    if (req)
        [imageHost startRequest:req];
    return req;
}

-(MKNetworkRequest *)loadImageFromURLString:(NSString*) imageUrlString onProgress:(MKNKHandler)progressHandler andComplete:(void(^)(UIImage *image, MKImageCacheType cacheType, NSString *imageUrl, NSError *error)) completionHandlerInMainThread{
    if ([imageUrlString isEqualToString:[self imageUrl]]){
        if (self.image || self.imageFetchRequest.state == MKNKRequestStateStarted) {
            return [self imageFetchRequest];
        }
    }
    
    [self.imageFetchRequest cancel];
    WS(pself);
    @synchronized (self) {
        [self setImageUrl:imageUrlString];
    }
    
    if ([UIImageView isImageCached:imageUrlString]) {
        [[MKImageCache sharedImageCache] queryDiskCacheForKey:imageUrlString done:^(UIImage *image, MKImageCacheType cacheType) {
            if (![[pself imageUrl] isEqualToString:imageUrlString])
                return;
            if (image) {
                pself.image = image;
                if (completionHandlerInMainThread)
                    completionHandlerInMainThread(image, cacheType, imageUrlString, nil);
            }else{
                [pself loadImageFromURLString:imageUrlString onProgress:progressHandler andComplete:completionHandlerInMainThread];
            }
        }];
        return nil;
    }else{
        MKNetworkRequest *req = [imageHost requestWithURLString:imageUrlString];
        [req addDownloadProgressChangedHandler:^(MKNetworkRequest *completedRequest) {
            if (![[pself imageUrl] isEqualToString:imageUrlString])
                return;
            if (progressHandler)
                progressHandler(completedRequest);
        }];
        [req addCompletionHandler:^(MKNetworkRequest *completedRequest) {
            if (![[pself imageUrl] isEqualToString:imageUrlString])
                return;
            if (!completedRequest.error && completedRequest.responseData)
                [[MKImageCache sharedImageCache] storeImageDataToDisk:completedRequest.responseData
                                                               forKey:imageUrlString
                                                           onComplete:^(NSString *key, UIImage *image) {
                    if (completionHandlerInMainThread)
                        completionHandlerInMainThread(image, MKImageCacheTypeNetwork, imageUrlString, completedRequest.error);
                    [pself setImageFetchRequest:nil];
                }];
            else{
                [[MKImageCache sharedImageCache] queryDiskCacheForKey:imageUrlString done:^(UIImage *image, MKImageCacheType cacheType) {
                    if (completionHandlerInMainThread)
                        completionHandlerInMainThread(image, MKImageCacheTypeNetwork, imageUrlString, completedRequest.error);
                    [pself setImageFetchRequest:nil];
                }];
            }
        }];
        req.doNotCache = YES;
        if (req)
            [imageHost startImageRequest:req];
        [self setImageFetchRequest:req];
        return req;
    }
}

-(MKNetworkRequest*) loadImageFromURLString:(NSString*) imageUrlString placeHolderImage:(UIImage*) placeHolderImage animated:(BOOL) animated {
    if([UIImageView isImageCached:imageUrlString])
        self.image = placeHolderImage;
    
    return [self loadImageFromURLString:imageUrlString onProgress:^(MKNetworkRequest *completedRequest) {
        
    } andComplete:^(UIImage *image, MKImageCacheType cacheType, NSString *imageUrl, NSError *error) {
        if(image) {
            CGFloat animationDuration = (cacheType == MKImageCacheTypeNetwork)?kFreshLoadAnimationDuration:kFromCacheAnimationDuration;
            if(animated) {
                [UIView transitionWithView:self.superview
                                  duration:animationDuration
                                   options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionAllowUserInteraction
                                animations:^{
                                    self.image = image;
                                } completion:nil];
            } else {
                self.image = image;
            }
        } else {
            NSLog(@"Request: %@ failed with error: %@", imageUrlString, error);
        }
    }];
}

-(MKNetworkRequest*) loadImageFromURLString:(NSString*) imageUrlString {
    WS(pself);
    return [self loadImageFromURLString:imageUrlString onProgress:^(MKNetworkRequest *completedRequest) {
        [completedRequest responseAsProgressImage:^(UIImage *image) {
            pself.image = image;
        }];
    } andComplete:^(UIImage *image, MKImageCacheType cacheType, NSString *imageUrl, NSError *error) {
        pself.image = image;
    }];
}
@end
