//
//  ALIVCViewController.m
//  AlivcRecord
//
//  Created by 孙震 on 11/06/2019.
//  Copyright (c) 2019 孙震. All rights reserved.
//

#import "ALIVCViewController.h"
#import "AlivcBase_ConfigureViewController.h"
#import "AlivcShortVideoRoute.h"

@interface ALIVCViewController ()

@end

@implementation ALIVCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)gotoRecord:(id)sender {
    NSLog(@"进入录制");
//    self.navigationController.hidesBottomBarWhenPushed = YES;
//    AlivcBase_ConfigureViewController *vc = [[AlivcBase_ConfigureViewController alloc] init];
//    [self.navigationController pushViewController:vc animated:YES];
//
    //专业版
//    UIViewController *cropParam = [[AlivcShortVideoRoute shared] alivcViewControllerWithType:AlivcViewControlCropParam];
     UIViewController *cropParam = [[AlivcShortVideoRoute shared] alivcViewControllerWithType:AlivcViewControlCropBasicParam];
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController pushViewController:cropParam animated:YES];
    
    
}

@end
