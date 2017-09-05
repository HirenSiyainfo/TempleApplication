//
//  popOverController.m
//  POSFrontEnd
//
//  Created by Minesh Purohit on 04/12/11.
//  Copyright 2011 Home. All rights reserved.
//

#import "RimPopOverVC.h"
#import "RmsDbController.h"

@interface RimPopOverVC () {
    NSNumberFormatter *currencyFormat;
}
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) ItemInfoEditVC *objAdd;
@property (nonatomic, strong) ManualItemReceiveVC *manualItemReceiveVC;

@property (nonatomic) BOOL isInvoice;
@property (nonatomic) BOOL is2decimalamt;
@property (nonatomic) BOOL isPrice;

@property (nonatomic, strong) NSMutableArray * topingListAry;

@property (nonatomic, strong) NSIndexPath * oldCell;
@property (nonatomic, strong) NSString * isFrom;
@property (nonatomic, strong) NSString * modifireId;
@property (nonatomic, strong) NSString *invoiceString;

@property (nonatomic, weak) IBOutlet UITextField * topinPrice;

@end

@implementation RimPopOverVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.rmsDbController = [RmsDbController sharedRmsDbController];
}

- (IBAction) tenderNumPadButtonAction:(id)sender
{
    [self.rmsDbController playButtonSound];
    currencyFormat = [[NSNumberFormatter alloc] init];
    currencyFormat.numberStyle = NSNumberFormatterCurrencyStyle;
    currencyFormat.maximumFractionDigits = 2;
    
    if ([sender tag] >= 0 && [sender tag] < 10)
    {
        if (_topinPrice.text==nil )
        {
            _topinPrice.text=@"";
        }
        if ([self.self.notificationName isEqual:@"EditPrice"] || [self.notificationName isEqual:@"openListPrice"])
        {
            _topinPrice.text = [_topinPrice.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
//            if ([_topinPrice.text length] > 0)
//            {
//                NSString * displyValue = [_topinPrice.text stringByAppendingFormat:@"%ld",(long)[sender tag]];
//                _topinPrice.text = displyValue;
//            }
//            else
//            {
                NSString * displyValue = [_topinPrice.text stringByAppendingFormat:@"%ld",(long)[sender tag]];
                _topinPrice.text = displyValue;
//            }
        }
        else
        {
            _topinPrice.text = [_topinPrice.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
//            if ([_topinPrice.text length] > 0)
//            {
//                NSString * displyValue = [_topinPrice.text stringByAppendingFormat:@"%d",[sender tag]];
//                _topinPrice.text = displyValue;
//            }
//            else
//            {
                NSString * displyValue = [_topinPrice.text stringByAppendingFormat:@"%ld",(long)[sender tag]];
                _topinPrice.text = displyValue;
//            }
        }
	}
    else if ([sender tag] == -98)
    {
		if (_topinPrice.text.length > 0)
        {
            _topinPrice.text = [_topinPrice.text substringToIndex:_topinPrice.text.length-1];
		}
	}
    else if ([sender tag] == -99)
    {
		if (_topinPrice.text.length > 0)
        {
            //_topinPrice.text = [_topinPrice.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
            _topinPrice.text = @"";
		}
	}
    else if ([sender tag] == 101)
    {
        _topinPrice.text = [_topinPrice.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
//		if ([_topinPrice.text length] > 0)
//        {
//			NSString * displyValue = [_topinPrice.text stringByAppendingFormat:@"00"];
//			_topinPrice.text = displyValue;
//		}
//		else {
			NSString * displyValue = [_topinPrice.text stringByAppendingFormat:@"00"];
			_topinPrice.text = displyValue;
//		}
	}
    
    if(_topinPrice.text.length > 0)
    {
        if ([self.notificationName isEqual:@"EditPrice"] || [self.notificationName isEqual:@"openListPrice"])
        {
            _topinPrice.text = [_topinPrice.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
            
            if ([_topinPrice.text  stringByReplacingOccurrencesOfString:@"." withString:@""].length >= 2)
            {
                _topinPrice.text = [_topinPrice.text stringByReplacingOccurrencesOfString:@"." withString:@""];
                _topinPrice.text = [NSString stringWithFormat:@"%@.%@",[_topinPrice.text substringToIndex:_topinPrice.text.length-2],[_topinPrice.text substringFromIndex:_topinPrice.text.length-2]];
            }
            else if ([_topinPrice.text  stringByReplacingOccurrencesOfString:@"." withString:@""].length > 1)
            {
                _topinPrice.text = [_topinPrice.text stringByReplacingOccurrencesOfString:@"." withString:@""];
                _topinPrice.text = [NSString stringWithFormat:@"%@0.0%@",[_topinPrice.text substringToIndex:_topinPrice.text.length-2],[_topinPrice.text substringFromIndex:_topinPrice.text.length-2]];
            }
            else if ([_topinPrice.text stringByReplacingOccurrencesOfString:@"." withString:@""].length == 1)
            {
                _topinPrice.text = [_topinPrice.text stringByReplacingOccurrencesOfString:@"." withString:@""];
                _topinPrice.text = [NSString stringWithFormat:@"0.0%@",_topinPrice.text];
            }
            //        else if ([[_topinPrice.text stringByReplacingOccurrencesOfString:@"." withString:@""] length] == 1)
            //        {
            //            _topinPrice.text = [_topinPrice.text stringByReplacingOccurrencesOfString:@"." withString:@""];
            //            _topinPrice.text = [NSString stringWithFormat:@"%@.%@",[_topinPrice.text substringToIndex:[_topinPrice.text length]-1],[_topinPrice.text substringFromIndex:[_topinPrice.text length]-1]];
            //        }
            NSNumber *dSales = @(_topinPrice.text.doubleValue );
            _topinPrice.text = [currencyFormat stringFromNumber:dSales];
            _topinPrice.text = [_topinPrice.text stringByReplacingOccurrencesOfString:@"," withString:@""];
        }
//        else if ([self.notificationName isEqual:@"ItemCasePackQTY"])
//        {
////            if ([[_topinPrice.text  stringByReplacingOccurrencesOfString:@"." withString:@""] length] >= 2)
////            {
////                _topinPrice.text = [_topinPrice.text stringByReplacingOccurrencesOfString:@"." withString:@""];
////                _topinPrice.text = [NSString stringWithFormat:@"%@.%@",[_topinPrice.text substringToIndex:[_topinPrice.text length]-3],[_topinPrice.text substringFromIndex:[_topinPrice.text length]-3]];
////            }
//            if ([[_topinPrice.text  stringByReplacingOccurrencesOfString:@"." withString:@""] length] > 1)
//            {
//                _topinPrice.text = [_topinPrice.text stringByReplacingOccurrencesOfString:@"." withString:@""];
//                _topinPrice.text = [NSString stringWithFormat:@"%@.%@",[_topinPrice.text substringToIndex:[_topinPrice.text length]-2],[_topinPrice.text substringFromIndex:[_topinPrice.text length]-2]];
//            }
//            else if ([[_topinPrice.text stringByReplacingOccurrencesOfString:@"." withString:@""] length] == 1)
//            {
//                _topinPrice.text = [_topinPrice.text stringByReplacingOccurrencesOfString:@"." withString:@""];
//                _topinPrice.text = [NSString stringWithFormat:@"0.0%@",_topinPrice.text];
//            }
//            NSNumber *dSales = [NSNumber numberWithDouble:[_topinPrice.text doubleValue ]];
//            _topinPrice.text = [currencyFormat stringFromNumber:dSales];
//            _topinPrice.text = [_topinPrice.text stringByReplacingOccurrencesOfString:@"," withString:@""];
//            _topinPrice.text = [_topinPrice.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
//        }
        else
        {
            _topinPrice.text = [_topinPrice.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
        }
    }
}
- (IBAction) closeBtnAction:(id)sender
{
    self.didEnterAmountBlock(@"",self.userInfo);
}
- (IBAction) enterBtnAction:(id)sender
{
    [self.rmsDbController playButtonSound];
    if (self.didEnterAmountBlock) {
        self.didEnterAmountBlock(_topinPrice.text, self.userInfo);
        return;
    }
	switch ([sender tag])
    {
		case 551:
            if ([self.notificationName isEqual:@"EditPrice"])
            {
				if (_topinPrice.text.length > 0)
                {
					[[NSNotificationCenter defaultCenter] postNotificationName:self.notificationName object:_topinPrice.text];
//                    #warning calculateSalesPrice;
//                    if(self.manualItemReceiveVC)
//                    {
//                        [self.manualItemReceiveVC calculateSalesPrice];
//                    }
//                    else
//                    {
//                        [self.objAdd calculateSalesPrice];
//                    }
				}
                else
                {
                    
				}
			}
            else if ([self.notificationName isEqual:@"ItemQTY"])
            {
				if (_topinPrice.text.length > 0)
                {
					[[NSNotificationCenter defaultCenter] postNotificationName:self.notificationName object:_topinPrice.text];
				}
                else
                {
                    
				}
			}
            else if ([self.notificationName isEqual:@"ItemReOrder"])
            {
				if (_topinPrice.text.length > 0)
                {
					[[NSNotificationCenter defaultCenter] postNotificationName:self.notificationName object:_topinPrice.text];
				}
                else
                {
                    
				}
			}
            else if ([self.notificationName isEqual:@"openListPrice"])
            {
                if (_topinPrice.text.length > 0)
                {
					[[NSNotificationCenter defaultCenter] postNotificationName:self.notificationName object:_topinPrice.text];
				}
                else
                {
                    
				}
            }
            else
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:self.notificationName object:_topinPrice.text];
            }
			break;
		case 552:
			[[NSNotificationCenter defaultCenter] postNotificationName:self.notificationName object:nil];
			break;
		default:
			break;
    }
}

- (void) addTopingwithPrice{
	NSString * priceValue = [_topinPrice.text stringByReplacingOccurrencesOfString:@"$" withString:@""];
	if (priceValue.floatValue == 0) {
	} else {
		NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:[self setUpTopingsArray:self.topingListAry atIndex:nil withPrice:priceValue]];
		[[NSNotificationCenter defaultCenter] postNotificationName:self.notificationName object:dict];
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

@end