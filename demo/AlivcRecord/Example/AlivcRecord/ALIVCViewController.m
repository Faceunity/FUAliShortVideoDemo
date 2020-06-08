//
//  ALIVCViewController.m
//  AlivcRecord
//
//  Created by 孙震 on 11/06/2019.
//  Copyright (c) 2019 孙震. All rights reserved.
//

#import "ALIVCViewController.h"
#import "AliyunRecordParamViewController.h"

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
    
    AliyunRecordParamViewController *vc = [[AliyunRecordParamViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
