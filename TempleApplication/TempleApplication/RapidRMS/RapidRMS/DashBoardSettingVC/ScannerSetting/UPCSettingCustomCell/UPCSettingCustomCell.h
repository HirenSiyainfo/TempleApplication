//
//  UPCSettingCustomCell.h
//  RapidRMS
//
//  Created by Siya Infotech on 25/11/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RmsDbController.h"

@protocol UPCSettingCustomCellDelegate
@optional
-(void)launchPopUp:(id)priceInputDelegate forTextField:(UITextField *)textField isQty:(BOOL)isQty sourceRect:(CGRect)sourceRect sourceView:(UIView *)view;
-(void)showInputPriceingView:(UITextField *)textField;
-(void)dismissPopUp;
@end

@interface UPCSettingCustomCell : UITableViewCell <UIPopoverControllerDelegate,UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UILabel *lblupcType;

@property (nonatomic, weak) IBOutlet UITextField *txtupcDigit;

@property (nonatomic, weak) IBOutlet UISwitch *upcSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *leadingSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *checkSwitch;

@property (nonatomic, strong) NSMutableDictionary *updSettingDict;
@property(nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, weak) id <UPCSettingCustomCellDelegate> uPCSettingCustomCellDelegate;

-(void)refreshUpcSettingCell;
-(void)didEnter:(id)inputControl inputValue:(CGFloat)inputValue;
-(void)didCancel;


@end