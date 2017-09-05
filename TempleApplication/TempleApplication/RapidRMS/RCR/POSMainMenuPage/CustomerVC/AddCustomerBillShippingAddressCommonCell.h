//
//  AddCustomerBillShippingAddressCommonCell.h
//  RapidRMS
//
//  Created by siya-IOS5 on 10/14/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddCustomerBillShippingAddressCommonCelldelegate <NSObject>
- (void)didUpdateCustomerAddressTextFieldAtIndexPath:(NSIndexPath *)indexPath withValue:(NSString *)customerDetail inTextField:(UITextField *)textField;
-(void)didStartEditingInAddressTextField:(UITextField *)textField withIndexPath:(NSIndexPath *)indexpath;


- (void)didUpdateCustomerAddressTextViewAtIndexPath:(NSIndexPath *)indexPath withValue:(NSString *)customerDetail inTextView:(UITextView *)textView;
-(void)didStartEditingInAddressTextView:(UITextView *)textView withIndexPath:(NSIndexPath *)indexpath;

@end


@interface AddCustomerBillShippingAddressCommonCell : UITableViewCell

@property (nonatomic , weak) IBOutlet UILabel *firstKey;
@property (nonatomic , weak) IBOutlet UITextField *firstValue;
@property (nonatomic , weak) IBOutlet UILabel *secondKey;
@property (nonatomic , weak) IBOutlet UITextField *secondValue;
@property (nonatomic , weak) IBOutlet UITextView *firstValueTextView;
@property (nonatomic , weak) IBOutlet UITextView *secondValueTextView;

@property (nonatomic , strong) NSIndexPath *currentIndexPath;

@property (nonatomic , weak) id <AddCustomerBillShippingAddressCommonCelldelegate>addCustomerBillShippingAddressCommonCelldelegate;

@end
