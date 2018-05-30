//
//  CryptoClient.h
//  cryptoclient_demo_ios
//
//  Created by 王昊 on 2018/5/30.
//  Copyright © 2018年 inklabsfoundation. All rights reserved.
//

#ifndef CryptoClient_h
#define CryptoClient_h
#import <Foundation/Foundation.h>

@interface CryptoClient : NSObject
+(CryptoClient*)sharedManager;
-(NSString *)createPrivateKey;
-(NSString *)createAddress:(NSString*) privateKey;
-(NSString *)signTx:(NSString*) privateKey;
@end
#endif /* CryptoClient_h */
