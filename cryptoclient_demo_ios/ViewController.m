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
    NSLog(@"%@", [manager createAddress:privateKey]);
    NSLog(@"%@", [manager signTxWithCCId:@"token" Fcn:@"transfer" Args:[NSArray arrayWithObjects:@"id4b8977c8f3b100c5a047353eac7d06923159477", @"TAB", @"100000000",nil] Msg:@"hello world" Counter:@"0" FeeLimit:@"100000000000" PrivKey:privateKey]);
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
