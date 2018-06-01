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
    NSArray* account =[manager createAccount];
    for(id obj in account) {
        NSLog(@"obj = %@", obj);
    }
    NSLog(@"%@", [manager signTxWithCCId:@"token" Fcn:@"transfer" Args:[NSArray arrayWithObjects:@"i02eecc33111a7a770c6fd295cca99e72ead5e764", @"TAB", @"100000000",nil] Msg:@"hello world" Counter:2847 FeeLimit:@"100000000000" PrivKey:@"23c9f7f355b36ab268ce9580f2388769dcfbdb74622e3db02f31b802f3f88ba4"]);
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
