//
//  NSData+HexString.h
//  cryptoclient_demo_ios
//
//  Created by 张泰林 on 2018/6/1.
//  Copyright © 2018年 inklabsfoundation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (HexString)
- (NSString *)dataToHexString;
+ (NSData *)hexStringToData:(NSString *)hexString;
@end
