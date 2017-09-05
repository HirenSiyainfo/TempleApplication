//
//  DeviceBatchReceipt.h
//  RapidRMS
//
//  Created by Siya-mac5 on 29/08/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "CurrentTransactionReceipt.h"

@interface DeviceBatchReceipt : CurrentTransactionReceipt

- (instancetype)initWithPortName:(NSString *)portName portSetting:(NSString *)portSettings receiptData:(NSArray *)receiptDataArray paymentGateWay:(PaymentGateWay)selectedPaymentGateWay receiptTitle:(NSString *)title cCBatchTrnxDetail:(CCBatchTrnxDetailStruct*)cCBatchTrnxDetail isTipsApplicable:(NSNumber *)isTipsApplicable filterDetails:(NSDictionary *)filterDetailsDictionary;

@end
