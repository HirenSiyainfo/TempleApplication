//
//  AddPaymentMasterButtonCell.h
//  RapidRMS
//
//  Created by Siya Infotech on 26/09/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RapidPaymentMaster.h"

@protocol AddPaymentMasterButtonCellDelegate <NSObject>

-(void)addSurchargeAtIndexPath:(NSIndexPath *)indexpath;

@end

@interface AddPaymentMasterButtonCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *lblName;
@property (nonatomic, weak) IBOutlet UIButton *btnCheckBox;
//@property (nonatomic, weak) IBOutlet UILabel *lblValue;
//@property (nonatomic, weak) IBOutlet UIImageView *imgBg;

@property (nonatomic, strong) NSIndexPath *currentCellIndexpath;

@property (nonatomic, weak) id<AddPaymentMasterButtonCellDelegate> addPaymentMasterButtonCellDelegate;

-(void)updatePaymentMasterButtonCell:(RapidPaymentMaster *)rapidPaymentmaster addPaymentField:(AddPaymentField)addPaymentField;

@end
