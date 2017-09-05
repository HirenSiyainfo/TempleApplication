//
//  DiscountDetailCell.h
//  RapidRMS
//
//  Created by Siya Infotech on 17/07/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
//typedef NS_ENUM(NSInteger, ItemDiscountTextFields) {
//    ItemDiscountTextFieldsQty,
//    ItemDiscountTextFieldsPrice,
//};
@protocol ItemDiscountPriceDetailDelegate <NSObject>
-(void)didChangeItemQty:(NSIndexPath *)indexpath fromSender:(UIView *)sender;
-(void)didChangeItemQtyNewQTY:(NSString *)qty atIndex:(int)Index;
-(void)didChangeItemPrice:(NSIndexPath *)indexpath fromSender:(UIView *)sender;
-(void)didChangeItemPriceNewPrice:(NSString *)price atIndex:(int)Index;
-(void)didItemDelete:(NSIndexPath *)indexpath;
-(void)didItemChangeApplyTax:(UISwitch *)sender forIndexPath:(NSIndexPath *)indexpath;
@end

@interface DiscountDetailCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIButton * deleteDiscount;
@property (nonatomic, weak) IBOutlet UISwitch * applyTax;
@property (nonatomic, weak) IBOutlet UITextField * itemDisQty;
@property (nonatomic, weak) IBOutlet UITextField * itemDisPrice;
@property (nonatomic, weak) IBOutlet UITextField * itemPriceWithTax;
@property (nonatomic, strong) NSNumberFormatter *currencyFormatter;

@property (nonatomic ,strong) NSIndexPath * indexPath;
@property (nonatomic, weak) id<ItemDiscountPriceDetailDelegate> ItemDiscountPriceDetailDelegate;
-(void)configureItemDetailWithDictionary:(NSDictionary *)itemDictionary;
@end
