//
//  PaymentGatewayResponse.m
//  RapidRMS
//
//  Created by Siya Infotech on 16/02/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "PaymentGatewayResponse.h"

@implementation PaymentGatewayResponse

-(NSDictionary *)paymentGatewayResponseDictionary{
    
    NSMutableDictionary *paymentGatewayResponseDictionary = [[NSMutableDictionary alloc]init];
    paymentGatewayResponseDictionary[@"TipsAmount"] = self.paymentGateWayName;
    paymentGatewayResponseDictionary[@"TipsAmount"] = self.paymentGateWayResponse;
    paymentGatewayResponseDictionary[@"TipsAmount"] = @(self.transactionStatus);


    
    return paymentGatewayResponseDictionary;
}
@end
