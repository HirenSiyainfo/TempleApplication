//
//  ItemSwipeEditPriceDetail.h
//  RapidRMS
//
//  Created by siya-IOS5 on 4/27/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, RCR_EDIT_PRICE_DETAIL_TEXTFIELD) {
    RCR_EDIT_MEMO_TEXTFIELD,
    RCR_EDIT_PRICE_TEXTFIELD,
    RCR_EDIT_QTY_TEXTFIELD,
    RCR_EDIT_NOT_APPLICABLE_TEXTFIELD = -1,
};


typedef NS_ENUM(NSInteger, RCR_EDIT_TAX_PROCESS) {
    RCR_TAX_INITIAL_STEP,
    RCR_TAX_REMOVE_STEP,
    RCR_TAX_ADD_STEP,
};

@protocol ItemSwipeEditPriceDetailDelegate<NSObject>

-(void)didShowPopOverControllerForTextField:(RCR_EDIT_PRICE_DETAIL_TEXTFIELD )textField withTextField:(UITextField *)editedTextField;
-(void)didRemoveItemDiscount;
-(void)didUpdateStateOfTaxProcess;
-(void)didUpdateEBTStatus;

@end

@interface ItemSwipeEditPriceDetail : UITableViewCell

@property (nonatomic,weak) IBOutlet UITextField *qtyEditTextField;
@property (nonatomic,weak) IBOutlet UITextField *priceEditTextField;
@property (nonatomic,weak) IBOutlet UITextField *memoEditTextField;
@property (nonatomic,weak) IBOutlet UILabel *discountLabel;
@property (nonatomic,weak) IBOutlet UIButton *addRemoveItemTax;
@property (nonatomic,weak) IBOutlet UILabel *taxPercentage;
@property (nonatomic,weak) IBOutlet UIImageView *imgRemoveItemTax;
@property (nonatomic,weak) IBOutlet UIButton *addRemoveItemEBT;
@property (nonatomic,weak) IBOutlet UIImageView *imgRemoveItemEBT;

@property (nonatomic, weak) id<ItemSwipeEditPriceDetailDelegate> itemSwipeEditPriceDetailDelegate;

-(void)configureItemPriceDetail:(NSDictionary *)itemSwipeDictionary;

@end
