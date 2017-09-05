//
//  CreditCardPopOverVC.m
//  RapidRMS
//
//  Created by siya-IOS5 on 8/18/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "CreditCardPopOverVC.h"
#import "RmsDbController.h"
/// test code for svn update
@interface CreditCardPopOverVC ()
{
    NSNumberFormatter *currencyFormatter;
}
@property (nonatomic, weak) IBOutlet UITextField * creditTextField;

@property (nonatomic, strong) RmsDbController *rmsDbController;
@end

@implementation CreditCardPopOverVC

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    self.rmsDbController = [RmsDbController sharedRmsDbController];

    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
-(IBAction) creditCardNumpad:(id)sender
{
    [self.rmsDbController playButtonSound];
    currencyFormatter = [[NSNumberFormatter alloc] init];
    currencyFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    currencyFormatter.maximumFractionDigits = 0;
	if ([sender tag] >= 0 && [sender tag] < 10) {
		if (_creditTextField.text.length > 0) {
			NSString * displyValue = [_creditTextField.text stringByAppendingFormat:@"%ld",(long)[sender tag]];
			_creditTextField.text = displyValue;
		} else {
			NSString * displyValue = [_creditTextField.text stringByAppendingFormat:@"%ld",(long)[sender tag]];
            NSNumber *sPrice = @(displyValue.floatValue);
            NSString *iAmount = [currencyFormatter stringFromNumber:sPrice];
            
			_creditTextField.text = iAmount;
		}
	}
    else if ([sender tag] == -98)
    {
		if (_creditTextField.text.length > 0)
        {
            _creditTextField.text = [_creditTextField.text substringToIndex:_creditTextField.text.length-1];
		}
	}
    else if ([sender tag] == -99) {
		if (_creditTextField.text.length > 0) {
            _creditTextField.text = @"";
		}
	} else if ([sender tag] == 101)
    {
		if (_creditTextField.text.length > 0) {
			NSString * displyValue = [_creditTextField.text stringByAppendingFormat:@"00"];
			_creditTextField.text = displyValue;
		}
		else {
            
			NSString * displyValue = [_creditTextField.text stringByAppendingFormat:@"00"];
            NSNumber *sPrice = [NSNumber numberWithFloat:displyValue.integerValue];
            NSString *iAmount = [currencyFormatter stringFromNumber:sPrice];
			_creditTextField.text = iAmount;
		}
	}
    _creditTextField.text = [_creditTextField.text stringByReplacingOccurrencesOfString:@"$" withString:@""];
}

-(IBAction)enterCreditCardValue:(id)sender
{
    if (_creditTextField.text.length > 0)
    {
        [self.creditCardPopOverDelegate didEnterCreditCardValue:_creditTextField.text];
    }
    else
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please fill field." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    }
}
-(IBAction)cancelCreditCardPopover:(id)sender
{
     [self.creditCardPopOverDelegate didCancelCreditcardPopOver];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
