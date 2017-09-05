//
//  popOverController.m
//  POSFrontEnd
//
//  Created by Minesh Purohit on 04/12/11.
//  Copyright 2011 Home. All rights reserved.
//

#import "PopOverController.h"
#import "RmsDbController.h"


@interface PopOverController ()

{
    NSNumberFormatter *currencyFormatterPop;
}



@property (nonatomic, weak) IBOutlet UILabel *lblTitleName;
@property (nonatomic, weak) IBOutlet UITextField * topinPrice;

@property (nonatomic, strong) RmsDbController *rmsDbController;

@end

@implementation PopOverController

@synthesize  invoiceString,isInvoice ,itemHeaderTitle , isFrom , isPrice , notificationName;

- (void)viewDidLoad {
    [super viewDidLoad];
	
    self.rmsDbController = [RmsDbController sharedRmsDbController];

}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _lblTitleName.text = itemHeaderTitle;
}
-(void)updateHeaderTitleLabelWithText:(NSString *)titleLabelText
{
    _topinPrice.text = @"";
    [self animateText:titleLabelText forLabel:_lblTitleName];
}
-(void)animateText:(NSString *)text forLabel:(UILabel *)label
{
    CATransition *animation = [CATransition animation];
    animation.duration = 1.0;
    animation.type = kCATransitionFade;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [label.layer addAnimation:animation forKey:@"changeTextTransition"];
    label.text = text;
}

// tender keypad action
- (IBAction) tenderNumPadButtonAction:(id)sender {
    [self.rmsDbController playButtonSound];
    currencyFormatterPop = [[NSNumberFormatter alloc] init];
    currencyFormatterPop.numberStyle = NSNumberFormatterCurrencyStyle;
    currencyFormatterPop.maximumFractionDigits = 0;
	if ([sender tag] >= 0 && [sender tag] < 10) {
		if (_topinPrice.text.length > 0) {
			NSString * displyValue = [_topinPrice.text stringByAppendingFormat:@"%ld",(long)[sender tag]];
			_topinPrice.text = displyValue;
		} else {
			NSString * displyValue = [_topinPrice.text stringByAppendingFormat:@"%ld",(long)[sender tag]];
            NSNumber *sPrice = @(displyValue.floatValue);
            NSString *iAmount = [currencyFormatterPop stringFromNumber:sPrice];
            
			_topinPrice.text = iAmount;
		}
	}
    else if ([sender tag] == -98)
    {
		if (_topinPrice.text.length > 0)
        {
            _topinPrice.text = [_topinPrice.text substringToIndex:_topinPrice.text.length-1];
		}
	}
    else if ([sender tag] == -99) {
		if (_topinPrice.text.length > 0) {
			//_topinPrice.text = [_topinPrice.text substringToIndex:[_topinPrice.text length]-1];
			//if ([_topinPrice.text isEqual:@"$"] || [_topinPrice.text isEqual:@"$."] || [_topinPrice.text isEqual:@"$."])
				_topinPrice.text = @"";
		}
	} else if ([sender tag] == 101)
    {
		if (_topinPrice.text.length > 0) {
			NSString * displyValue = [_topinPrice.text stringByAppendingFormat:@"00"];
			_topinPrice.text = displyValue;
		}
		else {
            
			NSString * displyValue = [_topinPrice.text stringByAppendingFormat:@"00"];
            NSNumber *sPrice = [NSNumber numberWithFloat:displyValue.integerValue];
            NSString *iAmount = [currencyFormatterPop stringFromNumber:sPrice];
			_topinPrice.text = iAmount;
		}
	}
    
    if ([invoiceString isEqual:@"Invoice"])
    {
        if (isInvoice)
        {
            if ([_topinPrice.text stringByReplacingOccurrencesOfString:@"." withString:@""].length > 1) {
                _topinPrice.text = [_topinPrice.text stringByReplacingOccurrencesOfString:@"." withString:@""];
                _topinPrice.text = [NSString stringWithFormat:@"%@.%@",[_topinPrice.text substringToIndex:_topinPrice.text.length-2],[_topinPrice.text substringFromIndex:_topinPrice.text.length-2]];
            } else if ([_topinPrice.text stringByReplacingOccurrencesOfString:@"." withString:@""].length == 1) {
                _topinPrice.text = [_topinPrice.text stringByReplacingOccurrencesOfString:@"." withString:@""];
                _topinPrice.text = [NSString stringWithFormat:@"%@.%@",[_topinPrice.text substringToIndex:_topinPrice.text.length-1],[_topinPrice.text substringFromIndex:_topinPrice.text.length-1]];
            }
        } else
        {
            _topinPrice.text = [_topinPrice.text stringByReplacingOccurrencesOfString:@"$" withString:@""];
        }
    }
    else
    {
        if (isPrice)
        {
            if ([_topinPrice.text  stringByReplacingOccurrencesOfString:@"." withString:@""].length > 1) {
                _topinPrice.text = [_topinPrice.text stringByReplacingOccurrencesOfString:@"." withString:@""];
                _topinPrice.text = [NSString stringWithFormat:@"%@.%@",[_topinPrice.text substringToIndex:_topinPrice.text.length-2],[_topinPrice.text substringFromIndex:_topinPrice.text.length-2]];
            } else if ([_topinPrice.text stringByReplacingOccurrencesOfString:@"." withString:@""].length == 1) {
                _topinPrice.text = [_topinPrice.text stringByReplacingOccurrencesOfString:@"." withString:@""];
                _topinPrice.text = [NSString stringWithFormat:@"%@.%@",[_topinPrice.text substringToIndex:_topinPrice.text.length-1],[_topinPrice.text substringFromIndex:_topinPrice.text.length-1]];
            }
        } else {
            _topinPrice.text = [_topinPrice.text stringByReplacingOccurrencesOfString:@"$" withString:@""];
        }
        
    }
    
}


- (IBAction) enterBtnAction:(id)sender
{
    
    switch ([sender tag]) {
        case 551:
            if (self.isPriceEdited) {
                if (_topinPrice.text.length>0)
                {
                [self.popOverControllerDelegate didEditItemWithItemPrice:_topinPrice.text];
                }
            }
            else
            {
                if (_topinPrice.text.length>0 && _topinPrice.text.integerValue>0)
                {
                    _topinPrice.text = [NSString stringWithFormat:@"%ld",(long)_topinPrice.text.integerValue];
                    [self.popOverControllerDelegate didEditItemWithItemQty:_topinPrice.text];
                }
            }
        case 552:
            [self.popOverControllerDelegate didCancelEditItemPopOver];
            
    }
}


- (NSMutableDictionary *) setUpTopingsArray:(NSMutableArray *) topingData  atIndex:(NSIndexPath *)index withPrice:(NSString *)price {
	NSMutableDictionary * tempDict = [[NSMutableDictionary alloc] init];
	tempDict[@"CalcPricePOS"] = [topingData valueForKey:@"CalcPricePOS"];
	tempDict[@"ModifireItemId"] = [topingData valueForKey:@"ModifireItemId"];
	tempDict[@"Names"] = [topingData valueForKey:@"Names"];
	return tempDict;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
//    [popItem CalculateProfit];
    return YES;
   
}
#pragma mark -



@end
