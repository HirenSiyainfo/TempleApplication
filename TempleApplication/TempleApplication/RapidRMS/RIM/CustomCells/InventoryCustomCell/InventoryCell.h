//
//  InventoryCell.h
//  I-RMS
//
//  Created by Siya Infotech on 09/08/13.
//  Copyright (c) 2013 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InventoryCellDelegate <NSObject>
    -(void)ActiveInactiveItemAtIndexPath:(NSIndexPath *)indexPath sender:(UIButton *)sender;
    -(void)historyItemAtIndexPath:(NSIndexPath *)indexPath sender:(UIButton *)sender;
    -(void)copyItemAtIndexPath:(NSIndexPath *)indexPath sender:(UIButton *)sender;
    -(void)deleteItemAtIndexPath:(NSIndexPath *)indexPath sender:(UIButton *)sender;
    -(void)singleItemClickedAtIndexPath:(NSIndexPath *)indexPath sender:(UIButton *)sender;
    -(void)caseClickedAtIndexPath:(NSIndexPath *)indexPath sender:(UIButton *)sender;
    -(void)packClickedAtIndexPath:(NSIndexPath *)indexPath sender:(UIButton *)sender;
@end
@interface InventoryCell : UITableViewCell

@property (nonatomic, weak) id<InventoryCellDelegate> inventoryCellDelegate;
@property (nonatomic, copy) NSIndexPath * indexPath;


@property (nonatomic, weak) IBOutlet UIView *viewOperation;
@property (nonatomic, weak) IBOutlet UIView *viewOperationInactive;
@property (nonatomic, weak) IBOutlet UIView *viewSeparetor;
@property (nonatomic, weak) IBOutlet UIImageView *imgBackGround;
@property (nonatomic, weak) IBOutlet UIImageView *imgSelected;
@property (nonatomic, weak) IBOutlet UIImageView *imgArrow;
@property (nonatomic, weak) IBOutlet UIImageView *qtyBackgroundImage;
@property (nonatomic, weak) IBOutlet UIImageView *imgIsDiscount;

@property (nonatomic, weak) IBOutlet AsyncImageView *itemImage;

@property (nonatomic, weak) IBOutlet UILabel *lblInventoryName;
@property (nonatomic, weak) IBOutlet UILabel *lblBarcode;
@property (nonatomic, weak) IBOutlet UILabel *lblItemNumber;
@property (nonatomic, weak) IBOutlet UILabel *lblDepartment;

@property (nonatomic, weak) IBOutlet UITextField *txtCost;
@property (nonatomic, weak) IBOutlet UITextField *txtPrice;
@property (nonatomic, weak) IBOutlet UITextField *txtQty;
@property (nonatomic, weak) IBOutlet UITextField *txtDiscount;
@property (nonatomic, weak) IBOutlet UITextField *txtCasePackValue;

@property (nonatomic, weak) IBOutlet UIButton *btnDelete;
@property (nonatomic, weak) IBOutlet UIButton *btnCopy;

@property (nonatomic, weak) IBOutlet UIButton *btnSingleItem;
@property (nonatomic, weak) IBOutlet UIButton *btnCase;
@property (nonatomic, weak) IBOutlet UIButton *btnPack;


//- (void)setCellDefaultBackGroundImage;
-(void)configureCellWithItem:(Item *) anItem withBarCode:(NSString *) itemBarCode withCurrentIndexPath:(NSIndexPath *) indexPath withIsBarcodeExist:(BOOL)isBarcodeExist isLablePrintSelectOr:(BOOL) isLablePrintSelect isSelectedIndex:(BOOL) isSelectedIndex;
@end
