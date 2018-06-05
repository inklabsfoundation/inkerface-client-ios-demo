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

typedef NS_ENUM(NSInteger, PrvkeyValidity)
{
    PrvkeyValid = 0,
    PrvkeyLengthIllegal,
    PrvkeyContainsIllegalChars,
    PrvkeyInvalid
};

@interface CryptoClient : NSObject
+(CryptoClient*)sharedManager;
-(NSString *)createPrivateKey;
-(NSString *)createAddress:(NSString*) privateKey;
-(NSArray *)createAccount;
-(PrvkeyValidity)prvKeyVerify:(NSString *)privateKey;
-(NSString *)signTxWithCCId:(NSString*)ccId Fcn:(NSString*)fcn Args:(NSArray*)args Msg:(NSString*)msg Counter:(uint64_t)counter FeeLimit:(NSString*)feeLimit PrivKey:(NSString*)privateKey;
@end
#endif /* CryptoClient_h */
