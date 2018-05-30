//
//  ViewController.m
//  cryptoclient_demo_ios
//
//  Created by 王昊 on 2018/5/30.
//  Copyright © 2018年 inklabsfoundation. All rights reserved.
//

#import "ViewController.h"

#import "CryptoClient.h"
@interface ViewController ()
@property (nonatomic) CryptoClient* client;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CryptoClient * manager = [CryptoClient sharedManager];
    NSString* privateKey =[manager createPrivateKey];
    NSLog(@"%@", privateKey);
    NSLog(@"%@", [manager createAddress:@"0xc87f1c343389f68b2178b5c37dd3fec1131f4711eb3ed705aa411bf840ef1f0f"]);
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
