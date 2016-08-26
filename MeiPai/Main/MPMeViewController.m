//
//  MPMeViewController.m
//  MeiPai
//
//  Created by xwmedia01 on 16/8/4.
//  Copyright © 2016年 xwmedia01. All rights reserved.
//

#import "MPMeViewController.h"
#import "UIImage+CutImage.h"
@interface MPMeViewController ()

@end

@implementation MPMeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor cyanColor];
    
    
    UIImage *im = [UIImage imageNamed:@"777"];
    UIImage *ppp = [UIImage processImage:im];
//    NSLog(@"%@", NSStringFromCGPoint(ppp));
    double p = im.size.width/im.size.height;
    CGFloat w = 250;
    CGFloat h =w/p;
    
    
//    UIImageWriteToSavedPhotosAlbum(ppp, nil, nil, nil);
    NSLog(@"%@", NSHomeDirectory());
    [UIImagePNGRepresentation(ppp) writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:@"111dd.png"] atomically:YES];
    
    UIImageView *imageVIew = [[UIImageView alloc] init];
    imageVIew.image = ppp;
    imageVIew.frame = CGRectMake(0, 100, w, h);
    [self.view addSubview:imageVIew];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
