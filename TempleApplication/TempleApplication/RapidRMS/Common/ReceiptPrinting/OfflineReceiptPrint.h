//
//  OfflineReceiptPrint.h
//  RapidRMS
//
//  Created by Siya Infotech on 29/06/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "InvoiceReceiptPrint.h"

@interface OfflineReceiptPrint : InvoiceReceiptPrint

- (instancetype)initWithPortName:(NSString *)portName portSetting:(NSString *)portSettings printData:(NSArray *)printData withPaymentDatail:(NSArray *)paymentDatail tipSetting:(NSNumber *)tipSetting tipsPercentArray:(NSArray *)tipsPercentArray receiptDate:(NSString *)reciptDate;
@end
