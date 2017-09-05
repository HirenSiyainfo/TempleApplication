//
//  AddPaymentMasterCommonCustomCell.h
//  RapidRMS
//
//  Created by siya-IOS5 on 9/25/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RapidPaymentMaster.h"
#import "RIMNumberPadPopupVC.h"

@protocol AddPaymentMasterCommonCustomCellDelegate <NSObject>
    -(void)addTextFieldAtIndexPath:(NSIndexPath *)indexPath withValue:(NSString*)strValue;
@end

@interface AddPaymentMasterCommonCustomCell : UITableViewCell<UITextFieldDelegate>
{
    AddPaymentField currentField;
}

@property (nonatomic, weak) IBOutlet UILabel *name;
@property (nonatomic, weak) IBOutlet UITextField *txtValue;
@property (nonatomic, weak) IBOutlet UIImageView *imgBg;

@property (nonatomic, strong) NSIndexPath *currentCellIndexpath;
@property (nonatomic) NumberPadPickerTypes pickerType;

@property (nonatomic, weak) id<AddPaymentMasterCommonCustomCellDelegate> addPaymentMasterCommonCustomCellDelegate;

-(void)updatePaymentMasterCustomCell:(RapidPaymentMaster *)rapidPaymentmaster addPaymentField:(AddPaymentField)addPaymentField;

@end
