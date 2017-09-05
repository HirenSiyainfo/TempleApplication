//
//  TicketValidationPassDetail.m
//  RapidRMS
//
//  Created by siya-IOS5 on 6/25/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "TicketValidationPassDetail.h"
#import "RapidPass.h"
#import <CoreImage/CoreImage.h>

@implementation TicketValidationPassDetail

-(void)updateCellWithPassDetail:(RapidPass *)passDetail
{
    self.invoiceNo.text = passDetail.regInvoiceNo;
    self.passNo.text  = passDetail.passNo;
    self.typeOfPass.text  = passDetail.typeOfPass;
    self.availbleDay.text  = passDetail.availableDays.stringValue;
    self.availbleExpiryDays.text  = passDetail.availableExpiryDays;
   self.qrCodeImage.image = [self generateQRCodeWithString:passDetail.qrCode];

}

- (UIImage * )generateQRCodeWithString:(NSString *)string {
    NSData *stringData = [string dataUsingEncoding:NSUTF8StringEncoding];
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setValue:stringData forKey:@"inputMessage"];
    [filter setValue:@"M" forKey:@"inputCorrectionLevel"];
    return [UIImage imageWithCIImage:filter.outputImage];
}
@end
