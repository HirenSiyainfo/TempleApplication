//
//  ResponseHostInformation.h
//  PaxControllerApp
//
//  Created by siya info on 31/07/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PaxResponse.h"

@interface ResponseHostInformation : NSObject
@property (nonatomic, strong, readonly) NSString *transactionResponseCode;
@property (nonatomic, strong, readonly) NSString *transactionResponseMessage;
@property (nonatomic, strong, readonly) NSString *authCode;
@property (nonatomic, strong, readonly) NSString *hostReferenceNumber;
@property (nonatomic, strong, readonly) NSString *traceNumber;
@property (nonatomic, strong, readonly) NSString *batchNumber;
- (void)hostInformation:(NSData *)data;

- (instancetype)initWithData:(NSData*)data NS_DESIGNATED_INITIALIZER;
@end
