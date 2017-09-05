//
//  WieghtScalePriceAtPosVC.m
//  RapidRMS
//
//  Created by siya-IOS5 on 11/11/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "WieghtScalePriceAtPosVC.h"
#import "Item+Dictionary.h"
#import "Item_Price_MD+Dictionary.h"
#import "WeightScaleUnit+Dictionary.h"
#import "RmsDbController.h"
#import "UnitConversion+Dictionary.h"

@interface WieghtScalePriceAtPosVC ()<NSFetchedResultsControllerDelegate,UITableViewDelegate,UITableViewDataSource>
{
    NSString *itemSelectedUnitType;
    NSString *ItemDbUnitType;
    
    CGFloat ItemDbUnitQty;
    CGFloat calculatedQty ;
    CGFloat conversionFactor;
}

@property (nonatomic, weak) IBOutlet UILabel * leftSideunitLabel;
@property (nonatomic, weak) IBOutlet UILabel * rightSideUnitlabel;
@property (nonatomic, weak) IBOutlet UILabel * itemNameLabel;
@property (nonatomic, weak) IBOutlet UILabel * itemUnitQty;
@property (nonatomic, weak) IBOutlet UILabel * itemCalculatedPrice;
@property (nonatomic, weak) IBOutlet UILabel * itemUnitPrice;
@property (nonatomic, weak) IBOutlet UITextField *itemRequiredQty;
@property (nonatomic, weak) IBOutlet UILabel * itemSelectedUnitTypelabel;
@property (nonatomic, weak) IBOutlet UITableView * unitScaleTableview;

@property (nonatomic, strong) NSFetchedResultsController *itemWeightScaleResultsController;
@property (nonatomic, strong) RmsDbController *rmsDbController;

@end

@implementation WieghtScalePriceAtPosVC
@synthesize qty,itemforWeightScale;
@synthesize managedObjectContext = __managedObjectContext;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setLayerAndBorderWidth
{
    _unitScaleTableview.hidden = YES;
    _unitScaleTableview.layer.borderWidth=1.0;
    _unitScaleTableview.layer.borderColor=[UIColor blackColor].CGColor;
}

- (void)configurePrice_MDWithItem
{
    Item_Price_MD * priceMd = [self configureItemArrayWithPrice_MD];
    if (priceMd == nil)
    {
        return;
    }
    ItemDbUnitType = priceMd.unitType;
    ItemDbUnitQty = priceMd.unitQty.floatValue;
    _itemNameLabel.text = self.itemforWeightScale.item_Desc;
    _itemUnitQty.text = [NSString stringWithFormat:@"%.2f %@",ItemDbUnitQty,ItemDbUnitType];
    _itemUnitPrice.text = [self getApplyUnitPriceForPrice_Md:priceMd];
    itemSelectedUnitType = ItemDbUnitType;
    _itemSelectedUnitTypelabel.text = itemSelectedUnitType;
    conversionFactor = [self conversionFactorForFromItem:ItemDbUnitType toItem:itemSelectedUnitType];
    [self calculateItemPrice];
}

- (void)viewDidLoad
{
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    [self setLayerAndBorderWidth];
    [self configurePrice_MDWithItem];
//    self.itemWeightScaleResultsController = nil;
//    [self itemWeightScaleResultsController];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
#pragma mark - CoreData Methods
- (NSFetchedResultsController *)itemWeightScaleResultsController {
    
    if (_itemWeightScaleResultsController != nil) {
        return _itemWeightScaleResultsController;
    }
    
    //   NSString *sortColumn=@"item_Desc";
    if (!itemSelectedUnitType) {
        return nil ;
    }
    
    NSFetchRequest *unitTypefetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *unitFetchentity = [NSEntityDescription entityForName:@"WeightScaleUnit" inManagedObjectContext:self.managedObjectContext];
    unitTypefetchRequest.entity = unitFetchentity;
    
    NSPredicate *unitTypepredicate = [NSPredicate predicateWithFormat:@"unitType==%@",itemSelectedUnitType];
    unitTypefetchRequest.predicate = unitTypepredicate;
    
    NSArray *unitTypeArray = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:unitTypefetchRequest];
    WeightScaleUnit * weightscaleunitType ;
    NSString * unitType = @"";
    if (unitTypeArray.count > 0) {
        weightscaleunitType = unitTypeArray.firstObject;
        unitType = weightscaleunitType.weightScaleType;
    }
   
    
    
    
    // Create and configure a fetch request with the Book entity.
    //   NSString *sortColumn=@"item_Desc";
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"WeightScaleUnit" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"weightScaleType==%@",unitType];
    fetchRequest.predicate = predicate;
    
    NSSortDescriptor *aSortDescriptor   = [[NSSortDescriptor alloc] initWithKey:@"unitType" ascending:YES];
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    
    
    // Create and initialize the fetch results controller.
    _itemWeightScaleResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:__managedObjectContext sectionNameKeyPath:@"unitScale" cacheName:nil];
    
    [_itemWeightScaleResultsController performFetch:nil];
    _itemWeightScaleResultsController.delegate = self;
    
    return _itemWeightScaleResultsController;
}
-(IBAction)btnDropDown:(id)sender
{
    _unitScaleTableview.hidden = NO;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSArray *sections = self.itemWeightScaleResultsController.sections;
    return sections.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sections = self.itemWeightScaleResultsController.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
    return sectionInfo.numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    UITableViewCellStyle style =  UITableViewCellStyleDefault;
    cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"];
    cell.textLabel.text = [[self.itemWeightScaleResultsController objectAtIndexPath:indexPath] valueForKey:@"unitType"];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:14.0];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _itemSelectedUnitTypelabel.text = [[self.itemWeightScaleResultsController objectAtIndexPath:indexPath] valueForKey:@"unitType"];
    itemSelectedUnitType = [[self.itemWeightScaleResultsController objectAtIndexPath:indexPath] valueForKey:@"unitType"];
    _unitScaleTableview.hidden = YES;
    conversionFactor = [self conversionFactorForFromItem:itemSelectedUnitType toItem:ItemDbUnitType];
    [self calculateItemPrice];

}

-(Item_Price_MD *)configureItemArrayWithPrice_MD
{
    NSString *qtyForRingUp = @"1";
    if (self.qty != nil) {
        qtyForRingUp = self.qty;
    }
    NSArray *itemPriceArray = self.itemforWeightScale.itemToPriceMd.allObjects;
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"qty == %d",qtyForRingUp.integerValue];
    NSArray *filterItemarray = [itemPriceArray filteredArrayUsingPredicate:predicate];
    return filterItemarray.firstObject;
}

-(NSString *)getApplyUnitPriceForPrice_Md :(Item_Price_MD *)price_md
{
    NSString *priceType = [NSString stringWithFormat:@"%@",price_md.applyPrice];
    NSNumber *priceValue = 0;
    
    if ([priceType isEqualToString:@"PriceA"])
    {
        priceValue = price_md.priceA;
    }
    else if ([priceType isEqualToString:@"PriceB"])
    {
        priceValue = price_md.priceB;
        
    }
    else if ([priceType isEqualToString:@"PriceC"])
    {
        priceValue = price_md.priceC;
    }
    else
    {
        priceValue = price_md.unitPrice;
    }
    
    return priceValue.stringValue;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(CGFloat)conversionFactorForFromItem :(NSString *)fromItem toItem:(NSString *)toItem
{
    CGFloat factor = 1.0;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"UnitConversion" inManagedObjectContext:__managedObjectContext];
    fetchRequest.entity = entity;
    
    NSPredicate *FactorItemPredicate = [NSPredicate predicateWithFormat:@"fromUnitType == %@ AND toUnitType == %@",fromItem,toItem];
    fetchRequest.predicate = FactorItemPredicate;
    
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
      if (resultSet.count>0)
     {
        UnitConversion *unitConversion = resultSet.firstObject;
         factor = unitConversion.factor.floatValue;
     }
    return factor;
}

-(void)calculateItemPrice
{
    NSNumberFormatter * currencyFormat = [[NSNumberFormatter alloc] init];
    currencyFormat.numberStyle = NSNumberFormatterCurrencyStyle;
    currencyFormat.maximumFractionDigits = 2;
    Item_Price_MD * priceMd = [self configureItemArrayWithPrice_MD];
    
     calculatedQty = conversionFactor * _itemRequiredQty.text.floatValue;
    CGFloat itemcalculatedPrice = calculatedQty * (_itemUnitPrice.text.floatValue/priceMd.unitQty.floatValue );
    
    NSNumber *dSales = [NSNumber numberWithFloat:itemcalculatedPrice];
    _itemCalculatedPrice.text = [currencyFormat stringFromNumber:dSales];
    
    _rightSideUnitlabel.text = [NSString stringWithFormat:@"%.2f %@",calculatedQty,ItemDbUnitType];
    _leftSideunitLabel.text = [NSString stringWithFormat:@"%.2f %@",_itemRequiredQty.text.floatValue,itemSelectedUnitType];

}

- (IBAction)WeightScaleAction:(id)sender
{
    if ([sender tag] >= 0 && [sender tag] < 10)
    {
        if (_itemRequiredQty.text==nil )
        {
            _itemRequiredQty.text=@"";
        }
        
        _itemRequiredQty.text = [_itemRequiredQty.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
        NSString * displyValue = [_itemRequiredQty.text stringByAppendingFormat:@"%ld",(long)[sender tag]];
        _itemRequiredQty.text = displyValue;
	}
    else if ([sender tag] == -98)
    {
		if (_itemRequiredQty.text.length > 0)
        {
            _itemRequiredQty.text = [_itemRequiredQty.text substringToIndex:_itemRequiredQty.text.length-1];
		}
	}
    else if ([sender tag] == -99)
    {
		if (_itemRequiredQty.text.length > 0)
        {
            _itemRequiredQty.text = [_itemRequiredQty.text substringToIndex:_itemRequiredQty.text.length-1];
		}
	}
    else if ([sender tag] == 101)
    {
        _itemRequiredQty.text = [_itemRequiredQty.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
        
        NSString * displyValue = [_itemRequiredQty.text stringByAppendingFormat:@"00"];
        _itemRequiredQty.text = displyValue;
	}
    
    if(_itemRequiredQty.text.length > 0)
    {
        
        _itemRequiredQty.text = [_itemRequiredQty.text stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
        if ([_itemRequiredQty.text  stringByReplacingOccurrencesOfString:@"." withString:@""].length >= 2)
        {
            _itemRequiredQty.text = [_itemRequiredQty.text stringByReplacingOccurrencesOfString:@"." withString:@""];
            _itemRequiredQty.text = [NSString stringWithFormat:@"%@.%@",[_itemRequiredQty.text substringToIndex:_itemRequiredQty.text.length-2],[_itemRequiredQty.text substringFromIndex:_itemRequiredQty.text.length-2]];
        }
        else if ([_itemRequiredQty.text  stringByReplacingOccurrencesOfString:@"." withString:@""].length > 1)
        {
            _itemRequiredQty.text = [_itemRequiredQty.text stringByReplacingOccurrencesOfString:@"." withString:@""];
            _itemRequiredQty.text = [NSString stringWithFormat:@"%@.%@",[_itemRequiredQty.text substringToIndex:_itemRequiredQty.text.length-2],[_itemRequiredQty.text substringFromIndex:_itemRequiredQty.text.length-2]];
        }
        else if ([_itemRequiredQty.text stringByReplacingOccurrencesOfString:@"." withString:@""].length == 1)
        {
            _itemRequiredQty.text = [_itemRequiredQty.text stringByReplacingOccurrencesOfString:@"." withString:@""];
            _itemRequiredQty.text = [NSString stringWithFormat:@".%@",_itemRequiredQty.text];
        }
        _itemRequiredQty.text = [_itemRequiredQty.text stringByReplacingOccurrencesOfString:@"," withString:@""];
    }
    [self calculateItemPrice];
}

- (void)calculatePerItemPriceForThisWeight
{
    NSNumberFormatter * currencyFormat = [[NSNumberFormatter alloc] init];
    currencyFormat.numberStyle = NSNumberFormatterCurrencyStyle;
    currencyFormat.maximumFractionDigits = 6;
    NSString *sPOSAmount=[NSString stringWithFormat:@"%f",[currencyFormat numberFromString:_itemCalculatedPrice.text].floatValue];
    CGFloat itemCalcultedPrice = sPOSAmount.floatValue /1.0;
    NSNumber *dSales = [NSNumber numberWithFloat:itemCalcultedPrice];
    _itemCalculatedPrice.text = [currencyFormat stringFromNumber:dSales];
}

-(IBAction)doneWeightScale:(id)sender
{
    [self calculatePerItemPriceForThisWeight];
    [self.weightScalePriceAtPosDelegate didWeightScalePriceAtPosRingupItemWithItemUnitPrice:_itemCalculatedPrice.text  withItemUnitQty:calculatedQty withItemUnitType:ItemDbUnitType];
}

-(IBAction)cancelWeightScale:(id)sender
{
    [self.weightScalePriceAtPosDelegate didWeightScalePriceAtPosCancel];
}


@end
