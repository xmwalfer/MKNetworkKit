//
//  ViewController.m
//  example
//
//  Created by LouieShum on 19/11/2016.
//  Copyright © 2016 LouieShum. All rights reserved.
//

#import "ViewController.h"
#import "MKNetworkKit.h"
#import "UIImageView+MKNKAdditions.h"

@interface ViewController (){
    UIImageView *image1;
    UIImageView *image2;
    
    NSString *url1;
    NSString *url2;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    image1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, (self.view.bounds.size.height-50)/2)];
    image1.contentMode = UIViewContentModeScaleAspectFill;
    image1.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:image1];
    
    image2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, image1.frame.size.height, self.view.bounds.size.width, (self.view.bounds.size.height-50)/2)];
    image2.contentMode = UIViewContentModeScaleAspectFill;
    image2.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:image2];
    
    UIButton *btn1 = [[UIButton alloc] initWithFrame:CGRectMake(0, image1.frame.size.height*2, self.view.bounds.size.width/2, 50)];
    [btn1 setTitle:@"Load Image" forState:UIControlStateNormal];
    [btn1 setBackgroundColor:[UIColor purpleColor]];
    [btn1 addTarget:self action:@selector(actionLoadImage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
    
    UIButton *btn2 = [[UIButton alloc] initWithFrame:CGRectMake(btn1.frame.size.width, image1.frame.size.height*2, self.view.bounds.size.width/2, 50)];
    [btn2 setTitle:@"Cancel" forState:UIControlStateNormal];
    [btn2 setBackgroundColor:[UIColor grayColor]];
    [btn2 addTarget:self action:@selector(actionCancelLoad) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
    
    url1 = @"http://bbsimage.res.meizu.com/forum/201408/22/130514h9yk23t6xxwmwfz2.jpg";
    url2 = @"http://bbsimage.res.meizu.com/forum/201408/22/130618aam66m8k8a7ym6mn.jpg";
}

- (void)actionLoadImage{
    image1.image = nil;
    [image1 loadImageFromURLString:url1];
    
    image2.image = nil;
    [image2 loadImageFromURLString:url2];
}
- (void)actionCancelLoad{
    [image1.imageFetchRequest cancel];
    [image2.imageFetchRequest cancel];
    image1.image = nil;
    image2.image = nil;
    [[MKImageCache sharedImageCache] removeImageForKey:url1];
    [[MKImageCache sharedImageCache] removeImageForKey:url2];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
