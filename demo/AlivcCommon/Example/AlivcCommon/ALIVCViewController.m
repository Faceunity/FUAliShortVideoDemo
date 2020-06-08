//
//  ALIVCViewController.m
//  AlivcCore
//
//  Created by 孙震 on 11/08/2019.
//  Copyright (c) 2019 孙震. All rights reserved.
//

#import "ALIVCViewController.h"
//#import "AliyunEffectPrestoreManager.h"

@interface ALIVCViewController ()

@end

@implementation ALIVCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[AlivcImage imageNamed:@"import_edit"]];
                              
    
    [self.view addSubview:imageView];
    
    imageView.frame = CGRectMake(100, 100, 100, 100);
    
//    [[[AliyunEffectPrestoreManager  alloc] init]  insertInitialData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
