//
//  AddPaymentMasterButtonCell.h
//  RapidRMS
//
//  Created by Siya Infotech on 26/09/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RapidPaymentMaster.h"
//typedef NS_ENUM(NSInteger,AddPaymentField)
//{
//    PaymentNameField,
//    PaymentCodeField,
//    PaymentTypeField,
//    SurchargeCheckBox,
//    SurchargeDollorType,
//    SurchargePercentageType,
//    SurchargeAmount,
//    DropCheckBox
//};


@protocol AddPaymentMasterButtonCellDelegate <NSObject>

-(void)addSurchargeAtIndexPath:(NSIndexPath *)indexpath;

@end

@interface AddPaymentMasterButtonCell : UITableViewCell

@property (nonatomic,strong) IBOutlet UILabel *lblName;
@property (nonatomic,strong) IBOutlet UIButton *btnCheckBox;
@property (nonatomic,strong) IBOutlet UILabel *lblValue;
@property (nonatomic,strong) IBOutlet UIImageView *imgBg;

@property (nonatomic,strong) NSIndexPath *currentCellIndexpath;

@property (nonatomic, strong) id<AddPaymentMasterButtonCellDelegate> addPaymentMasterButtonCellDelegate;

-(IBAction)btnCheckBoxClick:(id)sender;
-(void)updatePaymentMasterButtonCell:(RapidPaymentMaster *)rapidPaymentmaster addPaymentField:(AddPaymentField)addPaymentField;

@end
