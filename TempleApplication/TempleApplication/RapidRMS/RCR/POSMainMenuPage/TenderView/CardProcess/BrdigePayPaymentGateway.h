//
//  BrdigePayPaymentGateway.h
//  RapidRMS
//
//  Created by siya-IOS5 on 4/29/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "PaymentGateway.h"


@interface BrdigePayPaymentGateway : PaymentGateway <NSURLConnectionDataDelegate,NSXMLParserDelegate,NSStreamDelegate>
@property (nonatomic,strong)NSDictionary *PaymentGatewayDictionary;
@property (nonatomic,strong)NSMutableArray *PaymentGatewayArray;

- (instancetype)initDictionary:(NSDictionary*)cardData withDelegate:(id<PaymentGatewayDelegate>)delegate NS_DESIGNATED_INITIALIZER;


@end
