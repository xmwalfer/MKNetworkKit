//
//  UIImage+MKNKAdditions.h
//  example
//
//  Created by LouieShum on 19/11/2016.
//  Copyright © 2016 LouieShum. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (MKNKAdditions)

+ (UIImage *)mk_imageWithData:(NSData *)data;

+ (UIImage *)mk_decodedImageWithImage:(UIImage *)image;
@end
