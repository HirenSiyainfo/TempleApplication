//
//  WeightScaleVC.m
//  RapidRMS
//
//  Created by siya-IOS5 on 8/29/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "WeightScaleVC.h"
#import "Item.h"
@interface WeightScaleVC ()
{
    NSNumberFormatter *currencyFormatter;
}

@property (nonatomic, weak) IBOutlet UILabel *itemNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *barcodeLabel;
@property (nonatomic, weak) IBOutlet UILabel *weightQtyLabel;
@property (nonatomic, weak) IBOutlet UITextField *weightScaleTextField;

@end

@implementation WeightScaleVC

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
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setWeightScaleDictionary];
    _itemNameLabel.text = (self.weightScaleDictionary)[@"ItemName"];
    _barcodeLabel.text = (self.weightScaleDictionary)[@"Barcode"];
    _weightQtyLabel.text = (self.weightScaleDictionary)[@"WeightQty"];
}

-(void)setWeightScaleDictionary
{
    self.weightScaleDictionary = [[NSMutableDictionary alloc]init];
    (self.weightScaleDictionary)[@"ItemName"] = self.weightScaleItem.item_Desc;
    if (self.weightScaleItem.barcode) {
        (self.weightScaleDictionary)[@"Barcode"] = self.weightScaleItem.barcode;
    }
    else
    {
        (self.weightScaleDictionary)[@"Barcode"] = @"";
    }
    if (![self.weightScaleItem.pricescale isEqualToString:@""] || ![self.weightScaleItem.pricescale isEqual:[NSNull null]])
    {
        if (![self.weightScaleItem.pricescale isEqualToString:@"APPPRICE"])
        {
            (self.weightScaleDictionary)[@"WeightQty"] = [NSString stringWithFormat:@"%.2f",self.weightScaleItem.weightqty.floatValue];
        //    [self.weightScaleDictionary setObject:self.weightScaleItem.weightype forKey:@"WeightType"];
        }
    }
    
}
-(IBAction) weightScaleNumPad:(id)sender
{
//    [self.rmsDbController playButtonSound];
    NSNumberFormatter * currencyFormat = [[NSNumberFormatter alloc] init];
    currencyFormat.numberStyle = NSNumberFormatterCurrencyStyle;
    currencyFormat.maximumFractionDigits = 2;
    
    if ([sender tag] >= 0 && [sender tag] < 10)
    {
        if (_weightScaleTextField.text==nil )
        {
            _weightScaleTextField.text=@"";
        }
        
        _weightScaleTextField.text = [_weightScaleTextField.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
        
        NSString * displyValue = [_weightScaleTextField.text stringByAppendingFormat:@"%ld",(long)[sender tag]];
        _weightScaleTextField.text = displyValue;
	}
    else if ([sender tag] == -98)
    {
		if (_weightScaleTextField.text.length > 0)
        {
            _weightScaleTextField.text = [_weightScaleTextField.text substringToIndex:_weightScaleTextField.text.length-1];
		}
	}
    else if ([sender tag] == -99)
    {
		if (_weightScaleTextField.text.length > 0)
        {
            _weightScaleTextField.text = [_weightScaleTextField.text substringToIndex:_weightScaleTextField.text.length-1];
		}
	}
    else if ([sender tag] == 101)
    {
        _weightScaleTextField.text = [_weightScaleTextField.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
        
        NSString * displyValue = [_weightScaleTextField.text stringByAppendingFormat:@"00"];
        _weightScaleTextField.text = displyValue;
	}
    
    if(_weightScaleTextField.text.length > 0)
    {
        
        _weightScaleTextField.text = [_weightScaleTextField.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
        
        if ([_weightScaleTextField.text  stringByReplacingOccurrencesOfString:@"." withString:@""].length >= 2)
        {
            _weightScaleTextField.text = [_weightScaleTextField.text stringByReplacingOccurrencesOfString:@"." withString:@""];
            _weightScaleTextField.text = [NSString stringWithFormat:@"%@.%@",[_weightScaleTextField.text substringToIndex:_weightScaleTextField.text.length-2],[_weightScaleTextField.text substringFromIndex:_weightScaleTextField.text.length-2]];
        }
        else if ([_weightScaleTextField.text  stringByReplacingOccurrencesOfString:@"." withString:@""].length > 1)
        {
            _weightScaleTextField.text = [_weightScaleTextField.text stringByReplacingOccurrencesOfString:@"." withString:@""];
            _weightScaleTextField.text = [NSString stringWithFormat:@"%@0.0%@",[_weightScaleTextField.text substringToIndex:_weightScaleTextField.text.length-2],[_weightScaleTextField.text substringFromIndex:_weightScaleTextField.text.length-2]];
        }
        else if ([_weightScaleTextField.text stringByReplacingOccurrencesOfString:@"." withString:@""].length == 1)
        {
            _weightScaleTextField.text = [_weightScaleTextField.text stringByReplacingOccurrencesOfString:@"." withString:@""];
            _weightScaleTextField.text = [NSString stringWithFormat:@"0.0%@",_weightScaleTextField.text];
        }
        
        NSNumber *dSales = @(_weightScaleTextField.text.doubleValue );
        _weightScaleTextField.text = [currencyFormat stringFromNumber:dSales];
        _weightScaleTextField.text = [_weightScaleTextField.text stringByReplacingOccurrencesOfString:@"," withString:@""];
    }
    _weightScaleTextField.text = [_weightScaleTextField.text stringByReplacingOccurrencesOfString:@"$" withString:@""];
}
-(IBAction)enterWeightScale:(id)sender
{
    [self.weightScaleDelegate didAddItemWithWeightQty:self.weightScaleItem.weightqty withCostPrice:self.weightScaleItem.costPrice withItemStatus:self.isInserted WithItem:self.weightScaleItem];
}
-(IBAction)cancelWeightScale:(id)sender
{
    [self.weightScaleDelegate didCancelWeightScale];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
