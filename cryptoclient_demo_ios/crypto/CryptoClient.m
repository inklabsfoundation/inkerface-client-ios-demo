//
//  CryptoClient.m
//  cryptoclient_demo_ios
//
//  Created by 王昊 on 2018/5/30.
//  Copyright © 2018年 inklabsfoundation. All rights reserved.
//

#import "CryptoClient.h"
#import "sponge.h"
#import <ASKSecp256k1/CKSecp256k1.h>
@implementation CryptoClient
static int BytesUnit = 32;
static int BitsUnit  = 64;
static CryptoClient* manager = nil;
+(CryptoClient*)sharedManager
{
    if (manager == nil) {
        manager = [[CryptoClient alloc] init];
    }
    return manager;
}

-(id)init
{
    if (self = [super init]) {

    }
    return self;
}

#pragma mark privatekey
-(NSString *)createPrivateKey {
    char element[16] = {'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'};
    char c_private[BitsUnit + 1];
    //随机生成一个数字
    for (int i = 0; i<BitsUnit; i++) {
        int random = arc4random()%16;
        c_private[i] = element[random];
        //NSLog(@"%s",c_private);
    }
    c_private[BitsUnit] = '\0';
    NSString *privateKey = [NSString stringWithFormat:@"%s",c_private];
    return privateKey;
}
-(NSString *)createAddress:(NSString*) privateKey {
    if(privateKey == nil) {
        return nil;
    }
    NSString *addressString = @"i";
    unsigned char *newPublicKey = (unsigned char *)malloc(sizeof(unsigned char)*BitsUnit);
    NSString *no0xPrivateString = [privateKey substringFromIndex:2];
    NSMutableData* dataPrivate = [NSMutableData data];
    for (int idx = 0; idx +2 <= no0xPrivateString.length; idx += 2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [no0xPrivateString substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [dataPrivate appendBytes:&intValue length:1];
    }
    NSData* pubData = [CKSecp256k1 generatePublicKeyWithPrivateKey:dataPrivate compression:false];
    Byte * pubByte = (Byte *)[pubData bytes];
    for (int i = 0; i < BitsUnit; i++) {
        newPublicKey[i] = pubByte[i+1];
    }
    
    //int32_t size = (int)strlen((char *)newPublicKey);
    int32_t size = BitsUnit;
    int32_t *psize = &size;
    uint8_t *newmessage = (unsigned char *)malloc(sizeof(unsigned char)*200);
    newmessage = sponge(newPublicKey,*psize);
    for (int32_t i = 12; i < 32; i++) {
        addressString = [NSString stringWithFormat:@"%@%.2x",addressString,*(newmessage+i)];
    }
    return addressString;
}

-(NSString *)signTxWithCCId:(NSString*)ccId Fcn:(NSString*)fcn Args:(NSArray*)args Msg:(NSString*)msg Counter:(NSString*)counter FeeLimit:(NSString*)feeLimit PrivKey:(NSString*)privateKey {
    return @"need to be implemented";
}

@end




