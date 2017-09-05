//
//  PassPrinting.h
//  RapidRMS
//
//  Created by Siya Infotech on 25/06/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrintJob.h"
#import "RmsDbController.h"
#import "BasicPrint.h"

typedef NS_ENUM(NSInteger, PrintingField) {
    PrintingFieldStoreName = 200,
    PrintingFieldAddressLine1,
    PrintingFieldAddressLine2,
    PrintingFieldEmail,
    PrintingFieldPhone,
    PrintingFieldTitle,
    PrintingFieldNoOfPassDays,
    PrintingFieldPassNo,
    PrintingFieldQRCode,
    PrintingFieldExpiryDays,
    PrintingFieldDateOfPurchase,
    PrintingFieldRegisterName,
    PrintingFieldUserName,
    PrintingFieldInvoiceNo,
    PrintingFieldPaymentType,
    PrintingFieldCCNo,
    PrintingFieldMessage,
    PrintingFieldWebsite,
};

typedef NS_ENUM(NSInteger, PrintingSection) {
    PrintingSectionStoreInfo = 500,
    PrintingSectionPassHeader,
    PrintingSectionQRCode,
    PrintingSectionPassDetails,
    PrintingSectionFooter,
};

@interface PassPrinting : BasicPrint
{
    NSArray *paymentDatailsArray;
}
@property (nonatomic,strong)    NSDictionary *_printingData;

- (PrintingSection)sectionAtSectionIndex:(NSInteger)sectionIndex;

- (void)printingWithPort:(NSString *)portName portSettings:(NSString *)portSettings withDelegate:(id)delegate;

@end
