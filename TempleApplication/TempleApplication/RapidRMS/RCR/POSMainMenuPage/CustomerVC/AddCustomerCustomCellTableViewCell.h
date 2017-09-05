//
//  AddCustomerCustomCellTableViewCell.h
//  RapidRMS
//
//  Created by siya-IOS5 on 8/21/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol AddCustomerCustomCelldelegate <NSObject>

-(void)didUpdateCustomerValueAtIndexPath:(NSIndexPath *)indexPath withValue:(NSString *)customerDetail;
-(BOOL)didStartEditingInTextField:(UITextField *)textField withIndexPath:(NSIndexPath *)indexpath;
-(void)didSetSameAddressOfShippingAddress;
-(void)autoGenerateCustomerNumber;

@end


@interface AddCustomerCustomCellTableViewCell : UITableViewCell<UITextFieldDelegate>

@property (nonatomic , weak) IBOutlet UILabel *key;
@property (nonatomic , weak) IBOutlet UITextField *value;
@property (nonatomic , weak) IBOutlet UIButton *sameAsAddressButton;
@property (nonatomic , weak) IBOutlet UIButton *autoGenerateCustomerNumberButton;

@property (nonatomic , strong) NSIndexPath *currentIndexPath;

@property (nonatomic , weak) id <AddCustomerCustomCelldelegate>addCustomerCustomCelldelegate;


@end
