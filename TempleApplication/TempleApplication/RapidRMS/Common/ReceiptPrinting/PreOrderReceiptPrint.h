//
//  PreOrderReceiptPrint.h
//  RapidRMS
//
//  Created by Siya7 on 5/27/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "InvoiceReceiptPrint.h"

@interface PreOrderReceiptPrint : InvoiceReceiptPrint

- (instancetype)initWithPortName:(NSString *)portName portSetting:(NSString *)portSettings printData:(NSArray *)printData receiptDate:(NSString *)reciptDate;


@end
