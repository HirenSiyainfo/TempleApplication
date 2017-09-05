//
//  CL_InvoiceListCell.h
//  RapidRMS
//
//  Created by Siya Infotech on 02/12/15.
//  Copyright © 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,InvoiceProcess)
{
    InvoiceViewProcess,
    InvoiceEmailProcess,
    InvoicePrintProcess,
};

@protocol CL_InvoiceListCellDelegate <NSObject>

-(void)didPerformInvoiceProcess:(InvoiceProcess)invoiceProcess atIndexPath:(NSIndexPath *)indexPath;

@end


@interface CL_InvoiceListCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UILabel *lblDateTime;
@property (nonatomic,weak) IBOutlet UILabel *lblInvoice;
@property (nonatomic,weak) IBOutlet UILabel *lblQTY;
@property (nonatomic,weak) IBOutlet UILabel *lblTotal;
@property (nonatomic,weak) IBOutlet UILabel *lblPaymentType;
@property (nonatomic,weak) IBOutlet UIButton *btnTags;

@property (nonatomic,strong) NSIndexPath *currentCellIndexpath;

@property (nonatomic, weak) id<CL_InvoiceListCellDelegate> cl_InvoiceListCellDelegate;

@end
