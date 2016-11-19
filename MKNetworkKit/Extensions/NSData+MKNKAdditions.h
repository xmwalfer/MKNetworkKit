//
//  NSData+MKNKAdditions.h
//  example
//
//  Created by LouieShum on 19/11/2016.
//  Copyright © 2016 LouieShum. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (MKNKAdditions)

/**
 *  Compute the content type for an image data
 *
 *  @param data the input data
 *
 *  @return the content type as string (i.e. image/jpeg, image/gif)
 */
+ (NSString *)mk_contentTypeForImageData:(NSData *)data;
@end
