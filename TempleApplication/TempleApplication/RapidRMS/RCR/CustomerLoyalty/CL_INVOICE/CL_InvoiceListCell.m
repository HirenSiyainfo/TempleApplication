//
//  CL_InvoiceListCell.m
//  RapidRMS
//
//  Created by Siya Infotech on 02/12/15.
//  Copyright © 2015 Siya Infotech. All rights reserved.
//

#import "CL_InvoiceListCell.h"

@implementation CL_InvoiceListCell
@synthesize lblDateTime , lblInvoice , lblPaymentType , lblQTY , lblTotal , btnTags;

- (void)awakeFromNib {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(IBAction)btnInvoiceViewClick:(id)sender
{
    [self.cl_InvoiceListCellDelegate didPerformInvoiceProcess:InvoiceViewProcess atIndexPath:self.currentCellIndexpath];
}

-(IBAction)btnInvoiceEmailClick:(id)sender
{
    [self.cl_InvoiceListCellDelegate didPerformInvoiceProcess:InvoiceEmailProcess atIndexPath:self.currentCellIndexpath];
}
-(IBAction)btnInvoicePrintClick:(id)sender
{
    [self.cl_InvoiceListCellDelegate didPerformInvoiceProcess:InvoicePrintProcess atIndexPath:self.currentCellIndexpath];
}

@end
