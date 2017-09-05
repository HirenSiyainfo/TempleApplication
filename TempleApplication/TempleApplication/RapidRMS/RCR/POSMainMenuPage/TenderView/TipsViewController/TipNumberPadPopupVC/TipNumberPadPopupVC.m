//
//  popOverController.m
//  POSFrontEnd
//
//  Created by Minesh Purohit on 04/12/11.
//  Copyright 2011 Home. All rights reserved.
//

#import "TipNumberPadPopupVC.h"
#import "RmsDbController.h"

@interface TipNumberPadPopupVC ()
{
    NSNumberFormatter *currencyFormat;
}

@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, weak) IBOutlet UITextField * topinPrice;

@end

@implementation TipNumberPadPopupVC

@synthesize topinPrice;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.rmsDbController = [RmsDbController sharedRmsDbController];
}

// tender keypad action
- (IBAction) tenderNumPadButtonAction:(id)sender
{
    [self.rmsDbController playButtonSound];
    currencyFormat = [[NSNumberFormatter alloc] init];
    currencyFormat.numberStyle = NSNumberFormatterCurrencyStyle;
    currencyFormat.maximumFractionDigits = 2;
    
    if ([sender tag] >= 0 && [sender tag] < 10)
    {
        if (topinPrice.text==nil )
        {
            topinPrice.text=@"";
        }
        topinPrice.text = [topinPrice.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
        NSString * displyValue = [topinPrice.text stringByAppendingFormat:@"%ld",(long)[sender tag]];
        topinPrice.text = displyValue;
	}
    else if ([sender tag] == -98)
    {
		if (topinPrice.text.length > 0)
        {
            topinPrice.text = [topinPrice.text substringToIndex:topinPrice.text.length-1];
		}
	}
    else if ([sender tag] == -99)
    {
		if (topinPrice.text.length > 0)
        {
            topinPrice.text = @"";
		}
	}
    else if ([sender tag] == 101)
    {
        topinPrice.text = [topinPrice.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
        NSString * displyValue = [topinPrice.text stringByAppendingFormat:@"00"];
        topinPrice.text = displyValue;
	}
    
    if(topinPrice.text.length > 0)
    {
        topinPrice.text = [topinPrice.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
        if ([topinPrice.text  stringByReplacingOccurrencesOfString:@"." withString:@""].length >= 2)
        {
            topinPrice.text = [topinPrice.text stringByReplacingOccurrencesOfString:@"." withString:@""];
            topinPrice.text = [NSString stringWithFormat:@"%@.%@",[topinPrice.text substringToIndex:topinPrice.text.length-2],[topinPrice.text substringFromIndex:topinPrice.text.length-2]];
        }
        else if ([topinPrice.text  stringByReplacingOccurrencesOfString:@"." withString:@""].length > 1)
        {
            topinPrice.text = [topinPrice.text stringByReplacingOccurrencesOfString:@"." withString:@""];
            topinPrice.text = [NSString stringWithFormat:@"%@0.0%@",[topinPrice.text substringToIndex:topinPrice.text.length-2],[topinPrice.text substringFromIndex:topinPrice.text.length-2]];
        }
        else if ([topinPrice.text stringByReplacingOccurrencesOfString:@"." withString:@""].length == 1)
        {
            topinPrice.text = [topinPrice.text stringByReplacingOccurrencesOfString:@"." withString:@""];
            topinPrice.text = [NSString stringWithFormat:@"0.0%@",topinPrice.text];
        }
        NSNumber *dSales = @(topinPrice.text.doubleValue);
        topinPrice.text = [currencyFormat stringFromNumber:dSales];
        topinPrice.text = [topinPrice.text stringByReplacingOccurrencesOfString:@"," withString:@""];
    }
}

- (IBAction)enterClicked:(id)sender
{
    NSString *inputValue = [topinPrice.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
    [self.tipsInputDelegate didEnterTip:inputValue.floatValue];
}

- (IBAction)cancelClicked:(id)sender
{
//	[self.priceInputDelegate didCancel];
    [self.tipsInputDelegate didCancelTip];
}
@end