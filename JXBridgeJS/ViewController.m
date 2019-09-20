//
//  ViewController.m
//  JXBridgeJS
//
//  Created by JosephXuan on 2019/9/20.
//  Copyright © 2019 JosephXuan. All rights reserved.
//

#import "ViewController.h"
#import "JXWebBridgeCtrl.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:btn];
    btn.center=self.view.center;
    btn.bounds=CGRectMake(0, 0, 200, 200);
    btn.layer.cornerRadius=4.0f;
    btn.layer.borderWidth=1.0f;
    btn.layer.borderColor=[UIColor colorWithWhite:0 alpha:0.3].CGColor;
    btn.layer.masksToBounds=YES;
    [btn setTitle:@"点击进入web页" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithWhite:0 alpha:1] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
}
-(void)btnClick:(UIButton *)btn{
    JXWebBridgeCtrl *vc=[[JXWebBridgeCtrl alloc]init];
    vc.linkUrlStr=@"https://www.baidu.com";
    UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

@end
