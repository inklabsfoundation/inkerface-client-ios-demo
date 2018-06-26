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
#import <ASKSecp256k1/secp256k1/secp256k1_recovery.h>
#import <NSHash/NSData+NSHash.h>
#import "NSData+HexString.h"
#import "Chaincode.pbobjc.h"
@implementation CryptoClient
// static int BytesUnit = 32;
static int BitsUnit  = 64;
static CryptoClient* manager = nil;
static NSString* addressPrefix = @"TX";
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
    
    unsigned char *newPublicKey = (unsigned char *)malloc(sizeof(unsigned char)*BitsUnit);
    NSMutableData* dataPrivate = [NSMutableData data];
    for (int idx = 0; idx +2 <= privateKey.length; idx += 2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [privateKey substringWithRange:range];
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
    int32_t size = BitsUnit;
    int32_t *psize = &size;
    NSString *addressString = addressPrefix;
    uint8_t *newmessage = (unsigned char *)malloc(sizeof(unsigned char)*200);
    newmessage = sponge(newPublicKey,*psize);
    for (int32_t i = 12; i < 32; i++) {
        addressString = [NSString stringWithFormat:@"%@%.2x",addressString,*(newmessage+i)];
    }
    return addressString;
}

-(NSArray *)createAccount {
    NSString *prvkey = [self createPrivateKey];
    NSString *address = [self createAddress:prvkey];
    return [NSArray arrayWithObjects:address, prvkey,nil];
}

-(NSString *)signTxWithCCId:(NSString*)ccId Fcn:(NSString*)fcn Args: (NSArray *)args Msg:(NSString*)msg Counter:(uint64_t)counter FeeLimit:(NSString*)feeLimit PrivKey:(NSString*)privateKey {

    SignContent *pSignContent = [SignContent new];

    ChaincodeSpec *pInvokeSpec = [[ChaincodeSpec alloc] init];
    pInvokeSpec.type = ChaincodeSpec_Type_Golang;
    
    ChaincodeID *pCcId = [[ChaincodeID alloc] init];
    pCcId.name = ccId;
    pInvokeSpec.chaincodeId = pCcId;

    ChaincodeInput *pInput = [[ChaincodeInput alloc] init];
    NSMutableArray *nsarr = [[NSMutableArray alloc] init];
    [nsarr addObject:[fcn.length == 0 ? @"invoke":fcn dataUsingEncoding:NSASCIIStringEncoding]];
    for (NSString * str in args) {
        [nsarr addObject:[str dataUsingEncoding:NSASCIIStringEncoding]];
    }
    pInput.argsArray = nsarr;
    pInvokeSpec.input = pInput;
  
    pSignContent.chaincodeSpec = pInvokeSpec;
    SenderSpec *pSenderSpec = [[SenderSpec alloc] init];
    pSenderSpec.sender = [[self createAddress:privateKey] dataUsingEncoding:NSASCIIStringEncoding];
    pSenderSpec.counter = counter;
    pSenderSpec.inkLimit = [feeLimit dataUsingEncoding:NSASCIIStringEncoding];
    pSenderSpec.msg = [msg dataUsingEncoding:NSASCIIStringEncoding];
    pSignContent.senderSpec = pSenderSpec;

    ChaincodeInvocationSpec *pCciSpec = [[ChaincodeInvocationSpec alloc] init];
    pSignContent.idGenerationAlg = pCciSpec.idGenerationAlg;
    
    NSData *msgData = [pSignContent data];
    
    NSData *signData = [self recoverableSignData:[msgData SHA256] withPrivateKey:[NSData hexStringToData:privateKey]];
    
    return [signData dataToHexString];
}

- (NSData *)recoverableSignData:(NSData *)msgData withPrivateKey:(NSData *)privateKeyData
{
    secp256k1_context *context = secp256k1_context_create(SECP256K1_CONTEXT_SIGN);
    
    const unsigned char *prvKey = (const unsigned char *)privateKeyData.bytes;
    const unsigned char *msg = (const unsigned char *)msgData.bytes;
    
    secp256k1_ecdsa_recoverable_signature sig;
    
    int result = secp256k1_ecdsa_sign_recoverable(context, &sig, msg, prvKey, secp256k1_nonce_function_rfc6979, NULL);
    int recid;
    secp256k1_ecdsa_recoverable_signature sigOut;
    unsigned char * outPointer = sigOut.data;
    result = secp256k1_ecdsa_recoverable_signature_serialize_compact(context, outPointer, &recid, &sig);
    sigOut.data[64] = (Byte)recid;
    if (result != 1) {
        return nil;
    }
    secp256k1_context_destroy(context);
    NSMutableData *data = [NSMutableData dataWithBytes:sigOut.data length:65];
    return data;
}

- (PrvkeyValidity)prvKeyVerify:(NSString *)privateKey
{
    secp256k1_context *context = secp256k1_context_create(SECP256K1_CONTEXT_VERIFY);
    NSData *privateKeyData = [NSData hexStringToData:privateKey];
    // seckey ECDSA Secret key, 32 bytes
    NSUInteger keyLen = [privateKeyData length];
    if ( keyLen != 32) {
        return PrvkeyLengthIllegal;
    }
    // check is hex number
    const char * pBuf =[privateKey UTF8String];
    for (int i = 0; i < keyLen; ++i) {
        if (('0' > pBuf[i] || '9' < pBuf[i])
            && ('A' > pBuf[i] || 'F' < pBuf[i])
            && ('a' > pBuf[i] || 'f' < pBuf[i]))
        {
            return PrvkeyContainsIllegalChars;
        }
    }
    // libsecp256k1 Seckey Verify - returns 1 if valid, 0 if invalid
    const unsigned char *prvKey = (const unsigned char *)[privateKeyData bytes];
    int result = secp256k1_ec_seckey_verify(context, prvKey);
    secp256k1_context_destroy(context);
    if (result != 1) {
        return PrvkeyInvalid;
    }
    return PrvkeyValid;
}

@end




