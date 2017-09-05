//
//  TenderItemTableCustomCell.h
//  RapidRMS
//
//  Created by Siya Infotech on 01/07/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item+Dictionary.h"

@protocol TenderItemTableCellDelegate<NSObject>
-(void)didAddQtyAtIndxPath:(NSIndexPath *)indexpath;
-(void)didSubtractQtyAtIndxPath:(NSIndexPath *)indexpath;

@end

@class BillItem;

@interface TenderItemTableCustomCell : UITableViewCell

@property (nonatomic, strong) IBOutlet AsyncImageView *itemImage;

@property (nonatomic, weak) IBOutlet UILabel *itemBarcode;
@property (nonatomic, weak) IBOutlet UILabel *itemName;
@property (nonatomic, weak) IBOutlet UILabel *itemQty;
@property (nonatomic, weak) IBOutlet UILabel *itemSalesPrice;
@property (nonatomic, weak) IBOutlet UILabel *itemTotalPrice;
@property (nonatomic, weak) IBOutlet UILabel *itemTax;
@property (nonatomic, weak) IBOutlet UILabel *itemUnitQtyType;
@property (nonatomic, weak) IBOutlet UILabel *noPosDiscount;
@property (nonatomic, weak) IBOutlet UILabel *guestNo;
@property (nonatomic, weak) IBOutlet UILabel *itemNo;
@property (nonatomic, weak) IBOutlet UIButton *qtyUpArrow;
@property (nonatomic, weak) IBOutlet UIButton *qtyDownArrow;
@property (nonatomic, weak) IBOutlet UILabel *fee;
@property (nonatomic, weak) IBOutlet UILabel *feeAmount;
@property (nonatomic, weak) IBOutlet UILabel *lblPackageType;

@property (nonatomic, weak) IBOutlet UIView *sepratorView;


@property (nonatomic, strong) NSNumberFormatter *currencyFormatter;
@property (nonatomic, strong) NSIndexPath *indexPathForCell;

@property (nonatomic, weak) id<TenderItemTableCellDelegate> tenderItemTableCellDelegate;

-(void)updateCellWithBillItem:(NSDictionary *)billEntryDictionary withItem:(Item *)item;
-(void)updateCellWithInvoiceItem:(NSDictionary *)invoiceItemDictionary indexpath:(NSIndexPath *)index;

@end
