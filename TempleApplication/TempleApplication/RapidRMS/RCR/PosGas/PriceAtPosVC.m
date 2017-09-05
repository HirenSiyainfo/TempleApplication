//
//  PriceAtPosVC.m
//  RapidRMS
//
//  Created by siya-IOS5 on 8/5/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "PriceAtPosVC.h"
#import "RmsDbController.h"
@interface PriceAtPosVC ()
{
    
}
@property (nonatomic, weak) IBOutlet UITextField *priceAtposValue;
@property (nonatomic, weak) IBOutlet UILabel *itemNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *barcodeLabel;
@property (nonatomic, weak) IBOutlet UILabel *departmentNameLabel;

@property (nonatomic, strong) RmsDbController *rmsDbController;

@end

@implementation PriceAtPosVC

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
    _itemNameLabel.text = (self.priceAtPosDictionary)[@"ItemName"];
    _barcodeLabel.text = (self.priceAtPosDictionary)[@"Barcode"];
    _departmentNameLabel.text = (self.priceAtPosDictionary)[@"Department"];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)PriceAtPosAction:(id)sender
{
    [self.rmsDbController playButtonSound];
    NSNumberFormatter * currencyFormat = [[NSNumberFormatter alloc] init];
    currencyFormat.numberStyle = NSNumberFormatterCurrencyStyle;
    currencyFormat.maximumFractionDigits = 2;
    
    if ([sender tag] >= 0 && [sender tag] < 10)
    {
        if (_priceAtposValue.text==nil )
        {
            _priceAtposValue.text=@"";
        }
        
        _priceAtposValue.text = [_priceAtposValue.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
        
        NSString * displyValue = [_priceAtposValue.text stringByAppendingFormat:@"%ld",(long)[sender tag]];
        _priceAtposValue.text = displyValue;
	}
    else if ([sender tag] == -98)
    {
		if (_priceAtposValue.text.length > 0)
        {
            _priceAtposValue.text = [_priceAtposValue.text substringToIndex:_priceAtposValue.text.length-1];
		}
	}
    else if ([sender tag] == -99)
    {
		if (_priceAtposValue.text.length > 0)
        {
            _priceAtposValue.text = [_priceAtposValue.text substringToIndex:_priceAtposValue.text.length-1];
		}
	}
    else if ([sender tag] == 101)
    {
        _priceAtposValue.text = [_priceAtposValue.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
        
        NSString * displyValue = [_priceAtposValue.text stringByAppendingFormat:@"00"];
        _priceAtposValue.text = displyValue;
	}
    
    if(_priceAtposValue.text.length > 0)
    {
        
        _priceAtposValue.text = [_priceAtposValue.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
        
        if ([_priceAtposValue.text  stringByReplacingOccurrencesOfString:@"." withString:@""].length >= 2)
        {
            _priceAtposValue.text = [_priceAtposValue.text stringByReplacingOccurrencesOfString:@"." withString:@""];
            _priceAtposValue.text = [NSString stringWithFormat:@"%@.%@",[_priceAtposValue.text substringToIndex:_priceAtposValue.text.length-2],[_priceAtposValue.text substringFromIndex:_priceAtposValue.text.length-2]];
        }
        else if ([_priceAtposValue.text  stringByReplacingOccurrencesOfString:@"." withString:@""].length > 1)
        {
            _priceAtposValue.text = [_priceAtposValue.text stringByReplacingOccurrencesOfString:@"." withString:@""];
            _priceAtposValue.text = [NSString stringWithFormat:@"%@0.0%@",[_priceAtposValue.text substringToIndex:_priceAtposValue.text.length-2],[_priceAtposValue.text substringFromIndex:_priceAtposValue.text.length-2]];
        }
        else if ([_priceAtposValue.text stringByReplacingOccurrencesOfString:@"." withString:@""].length == 1)
        {
            _priceAtposValue.text = [_priceAtposValue.text stringByReplacingOccurrencesOfString:@"." withString:@""];
            _priceAtposValue.text = [NSString stringWithFormat:@"0.0%@",_priceAtposValue.text];
        }
        
        NSNumber *dSales = @(_priceAtposValue.text.doubleValue );
        _priceAtposValue.text = [currencyFormat stringFromNumber:dSales];
        _priceAtposValue.text = [_priceAtposValue.text stringByReplacingOccurrencesOfString:@"," withString:@""];
    }
}

-(IBAction)cancelPriceAtPos:(id)sender
{
    [self.rmsDbController playButtonSound];
    [self.priceAtPosDelegate didCancelPriceAtPos];
}

-(IBAction)enterPriceAtPos:(id)sender
{
    [self.rmsDbController playButtonSound];
    if (_priceAtposValue.text.length >0)
    {
        [self.priceAtPosDelegate didAddItemWithPosPrice:_priceAtposValue.text];
    }
    else
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please fill the price." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    }
}

-(IBAction)cleatxtIsItemPosFeild:(id)sender
{
    _priceAtposValue.text = @"";
}


@end
