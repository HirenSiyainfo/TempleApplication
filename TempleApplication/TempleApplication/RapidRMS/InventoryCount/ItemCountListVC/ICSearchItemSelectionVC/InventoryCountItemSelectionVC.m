//
//  MultipleItemBarcodeRingUpVC.m
//  RapidRMS
//
//  Created by siya-IOS5 on 9/15/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "InventoryCountItemSelectionVC.h"
#import "InventoryCountItemSelectionCell.h"
#import "Item+Dictionary.h"
#import "Department+Dictionary.h"

#import "RmsDbController.h"
#import "CommonLabel.h"
#import "Item_Price_MD.h"
#import  "Item_Price_MD+Dictionary.h"

@interface InventoryCountItemSelectionVC ()<NSFetchedResultsControllerDelegate>
{
    IBOutlet UITableView *multipleItemBarcodeTableview;
    NSIndexPath *selectedItemIndexpath;
    IBOutlet UILabel *barcodeLabel;
    
}
@property (nonatomic, strong) NSFetchedResultsController *itemBarcodeResultController;
@property (nonatomic, strong) RcrController *crmController;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@end

@implementation InventoryCountItemSelectionVC
@synthesize multipleItemArray;
@synthesize itemBarcodeResultController = _itemBarcodeResultController;
@synthesize managedObjectContext = __managedObjectContext;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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

    self.crmController = [RcrController sharedCrmController];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    selectedItemIndexpath = 0;
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    [self departmentResultController];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    barcodeLabel.text = self.itemBarcode;
    [multipleItemBarcodeTableview reloadData];
}

#pragma mark - Fetched Department results controller

- (NSFetchedResultsController *)departmentResultController {
    
    if (_itemBarcodeResultController != nil) {
        return _itemBarcodeResultController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item_Price_MD" inManagedObjectContext:__managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF IN %@ ",self.multipleItemArray];
    [fetchRequest setPredicate:predicate];
    // Create the sort descriptors array.
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"priceToItem.item_Desc" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[aSortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Create and initialize the fetch results controller.
    _itemBarcodeResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:__managedObjectContext sectionNameKeyPath:@"priceToItem.item_Desc" cacheName:nil];
    
    [_itemBarcodeResultController performFetch:nil];
    _itemBarcodeResultController.delegate = self;
    
    return _itemBarcodeResultController;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 45;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSArray *sections = [self.itemBarcodeResultController sections];
    return sections.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.itemBarcodeResultController.sections[section].name;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 73;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sections = [self.itemBarcodeResultController sections];
    id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    InventoryCountItemSelectionCell *cell = (InventoryCountItemSelectionCell *)[tableView dequeueReusableCellWithIdentifier:@"InventoryCountItemSelectionCell" forIndexPath:indexPath];
    
//    Item *anItem = [self.itemBarcodeResultController objectAtIndexPath:indexPath];
    Item_Price_MD *item_Price_MD = [self.itemBarcodeResultController objectAtIndexPath:indexPath];
    
    // ItemBarCode_Md *item_barcode_md = [self.multipleItemArray objectAtIndex:indexPath.row];
    Item *anItem = item_Price_MD.priceToItem;

//    cell.itemName.text = @"";
//    if (anItem.itemDepartment) {
//        cell.itemName.text = [NSString stringWithFormat:@"%@",anItem.itemDepartment.deptName];
//    }
//    
//    cell.itemPrice.text = [NSString stringWithFormat:@"%@",anItem.salesPrice];
//    if (anItem.item_InStock) {
//        cell.itemQty.text = [NSString stringWithFormat:@"%@",anItem.item_InStock];
//    }
//    else
//    {
//        cell.itemQty.text = @"0";
//    }
    
    cell.itemPrice.text = [NSString stringWithFormat:@"%@",item_Price_MD.priceqtytype];
    if (item_Price_MD.qty) {
        cell.itemQty.text = [NSString stringWithFormat:@"%@",item_Price_MD.qty];
    }
    else
    {
        cell.itemQty.text = @"1";
    }
//
    if (item_Price_MD)
    {
        NSString *priceType = [NSString stringWithFormat:@"%@",item_Price_MD.applyPrice];
        NSNumber *priceValue = 0;
        
        if ([priceType isEqualToString:@"PriceA"])
        {
            priceValue = item_Price_MD.priceA;
        }
        else if ([priceType isEqualToString:@"PriceB"])
        {
            priceValue = item_Price_MD.priceB;
            
        }
        else if ([priceType isEqualToString:@"PriceC"])
        {
            priceValue = item_Price_MD.priceC;
        }
        else
        {
            priceValue = item_Price_MD.unitPrice;
        }
        
        cell.department.text = [self.rmsDbController applyCurrencyFomatter:[NSString stringWithFormat:@"%f",priceValue.floatValue]];
    }
    else
    {
        cell.department.text = [self.rmsDbController applyCurrencyFomatter:[NSString stringWithFormat:@"%@",anItem.salesPrice]];
    }

    NSString *itemImageURL = anItem.item_ImagePath;
    
    if ([[itemImageURL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""])
    {
        NSString *imgString = @"noimage.png";
        [cell.itemImage setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@", imgString]]];
    }
    else if ([[itemImageURL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@"<null>"])
    {
        NSString *imgString = @"noimage.png";
        [cell.itemImage setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@", imgString]]];
    }
    else
    {
        [cell.itemImage loadImageFromURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",itemImageURL]]];
    }
    
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor colorWithRed:(196/255.f) green:(237/255.f) blue:(224/255.f) alpha:1.0];
    cell.selectedBackgroundView = selectionColor;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedItemIndexpath = indexPath;
}

-(IBAction)DoneMultipeBarcodeVC:(id)sender
{
    if (selectedItemIndexpath == nil)
    {
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"please select the item first." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        return;
    }
    Item_Price_MD *item_Price_MD = [self.itemBarcodeResultController objectAtIndexPath:selectedItemIndexpath];
    Item *anitem = item_Price_MD.priceToItem;

    [self.inventoryCountItemSelectionVCDelegate didSelectItemFromMultipleDuplicateBarcode:anitem];
}

-(IBAction)cancelMultipeBarcodeVC:(id)sender
{
    [self.inventoryCountItemSelectionVCDelegate didCanceMultipleItemBarcodeCustomerVC];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end