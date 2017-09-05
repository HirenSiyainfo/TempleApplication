//
//  DeviceSummaryReceipt.h
//  RapidRMS
//
//  Created by Siya-mac5 on 05/08/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "CCBatchReceipt.h"

@interface DeviceSummaryReceipt : CCBatchReceipt

- (instancetype)initWithPortName:(NSString *)portName portSetting:(NSString *)portSettings receiptData:(NSArray *)receiptDataArray paymentGateWay:(PaymentGateWay)selectedPaymentGateWay receiptTitle:(NSString *)title filterDetails:(NSDictionary *)filterDetailsDictionary;

@end
