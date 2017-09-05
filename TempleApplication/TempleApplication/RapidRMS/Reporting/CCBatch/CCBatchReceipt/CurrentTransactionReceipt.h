//
//  CurrentTransactionReceipt.h
//  RapidRMS
//
//  Created by Siya-mac5 on 29/08/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "CCBatchReceipt.h"

@interface CurrentTransactionReceipt : CCBatchReceipt

- (instancetype)initWithPortName:(NSString *)portName portSetting:(NSString *)portSettings receiptData:(NSArray *)receiptDataArray paymentGateWay:(PaymentGateWay)selectedPaymentGateWay receiptTitle:(NSString *)title cCBatchTrnxDetail:(CCBatchTrnxDetailStruct*)cCBatchTrnxDetail isTipsApplicable:(NSNumber *)isTipsApplicable  filterDetails:(NSDictionary *)filterDetailsDictionary;

- (NSString *)htmlForTransactionDetailsField:(NSString *)field className:(NSString *)className status:(NSString *)status align:(NSString *)align;
- (NSString *)getTransationType:(TRANSACTIONTYPE)transationType;

@end
