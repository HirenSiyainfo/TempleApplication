//
//  PaymentGatewayResponse.h
//  RapidRMS
//
//  Created by Siya Infotech on 16/02/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PaymentGatewayResponse : NSObject

@property (nonatomic , strong) NSString *paymentGateWayName;
@property (nonatomic , strong) NSString *paymentGateWayResponse;
@property (nonatomic) BOOL transactionStatus;


@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *paymentGatewayResponseDictionary;

@end
