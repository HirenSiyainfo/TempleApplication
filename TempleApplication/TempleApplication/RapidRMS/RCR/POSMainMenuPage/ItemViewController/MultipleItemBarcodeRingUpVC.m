//
//  MultipleItemBarcodeRingUpVC.m
//  RapidRMS
//
//  Created by siya-IOS5 on 9/15/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "MultipleItemBarcodeRingUpVC.h"
#import "MultipleItemBarcodeRingUpCell.h"
#import "Item+Dictionary.h"
#import "Department+Dictionary.h"
#import "ItemBarCode_Md+Dictionary.h"
#import  "Item_Price_MD+Dictionary.h"
#import "RmsDbController.h"
#import "CommonLabel.h"

@interface MultipleItemBarcodeRingUpVC ()<NSFetchedResultsControllerDelegate>
{
    NSIndexPath *selectedItemIndexpath;
    
}
@property (nonatomic, weak) IBOutlet UITableView *multipleItemBarcodeTableview;
@property (nonatomic, weak) IBOutlet UILabel *barcodeLabel;

@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic,strong) NSFetchedResultsController *itemBarcodeResultController;


@end

@implementation MultipleItemBarcodeRingUpVC
@synthesize multipleItemArray;
@synthesize itemBarcodeResultController = _itemBarcodeResultController;
@synthesize managedObjectContext = __managedObjectContext;

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
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    selectedItemIndexpath = 0;
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    [self departmentResultController];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //    [self removeNilPrice_MdObjectFromArray];
    _barcodeLabel.text = self.itemBarcode;
    [_multipleItemBarcodeTableview reloadData];
}

-(void)removeNilPrice_MdObjectFromArray
{
    for (int i = 0; i < self.multipleItemArray.count; i++)
    {
        ItemBarCode_Md *item_barcode_md = (self.multipleItemArray)[i];
        if (!item_barcode_md.barcodePrice_MD)
        {
            [self.multipleItemArray removeObjectAtIndex:i];
        }
    }
    [_multipleItemBarcodeTableview reloadData];
}

#pragma mark - Fetched Department results controller

- (NSFetchedResultsController *)departmentResultController {
    
    if (_itemBarcodeResultController != nil) {
        return _itemBarcodeResultController;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item_Price_MD" inManagedObjectContext:__managedObjectContext];
    fetchRequest.entity = entity;

  /*  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"barCode == %@ AND barcodePrice_MD.qty != 0 AND ((barcodePrice_MD.applyPrice == %@ AND barcodePrice_MD.priceA != 0) OR (barcodePrice_MD.applyPrice == %@ AND barcodePrice_MD.priceB != 0) OR (barcodePrice_MD.applyPrice == %@ AND barcodePrice_MD.priceC != 0) OR (barcodePrice_MD.applyPrice == %@ AND barcodePrice_MD.unitPrice != 0))",self.itemBarcode,@"PriceA",@"PriceB",@"PriceC",@"UnitPrice"];*/

//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"barCode == %@ AND((packageType == %@ OR barcodePrice_MD.isPackCaseAllow == %@))",self.itemBarcode,@"Single Item",@1];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF IN %@ ",self.multipleItemArray];
    fetchRequest.predicate = predicate;
    // Create the sort descriptors array.
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"priceToItem.item_Desc" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    
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

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *headerView = [[UIView alloc]init];
//    headerView.frame = CGRectMake(0, 0, tableView.frame.size.width, 58);
//    [headerView setBackgroundColor:[UIColor clearColor]];
//    CommonLabel *cardName = [[CommonLabel alloc]init];
//    [cardName configureLable:CGRectMake(10, 20, 250, 25) withFontName:@"Helvetica" withFontSize:14.00 withTextAllignment:NSTextAlignmentLeft withTextColor:[UIColor blackColor]];
//    cardName.text = [[[self.itemBarcodeResultController sections] objectAtIndex:section] name];
//    [headerView addSubview:cardName];
//    return headerView;
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
        NSArray *sections = self.itemBarcodeResultController.sections;
        return sections.count;
 }
 - (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.itemBarcodeResultController.sections[section].name;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 73;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   NSArray *sections = self.itemBarcodeResultController.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
    return sectionInfo.numberOfObjects;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MultipleItemBarcodeRingUpCell *cell = (MultipleItemBarcodeRingUpCell*)[tableView dequeueReusableCellWithIdentifier:@"MultipleItemBarcodeCell" forIndexPath:indexPath];

    Item_Price_MD *item_Price_MD = [self.itemBarcodeResultController objectAtIndexPath:indexPath];

   // ItemBarCode_Md *item_barcode_md = [self.multipleItemArray objectAtIndex:indexPath.row];
    Item *anitem = item_Price_MD.priceToItem;
   // Item *anitem = [self.multipleItemArray objectAtIndex:indexPath.row];
//    cell.itemName.text = anitem.item_Desc;
    cell.itemPrice.text = [NSString stringWithFormat:@"%@",item_Price_MD.priceqtytype];
    if (item_Price_MD.qty) {
        cell.itemQty.text = [NSString stringWithFormat:@"%@",item_Price_MD.qty];
    }
    else
    {
        cell.itemQty.text = @"1";
    }
    
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
        cell.department.text = [self.rmsDbController applyCurrencyFomatter:[NSString stringWithFormat:@"%@",anitem.salesPrice]];
    }

   /* if ([anitem.deptId integerValue]>0)
    {
        int deptCheck=[anitem.itemDepartment.deptId integerValue];
        if (deptCheck==0)
        {
           
        }
       else
        {
            cell.department.text = [NSString stringWithFormat:@"%@",anitem.itemDepartment.deptName];
        }
    }*/
        
    NSString *itemImageURL = anitem.item_ImagePath;

    if ([[itemImageURL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""])
    {
        NSString *imgString = @"noimage.png";
        cell.itemImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", imgString]];
    }
    else if ([[itemImageURL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@"<null>"])
    {
        NSString *imgString = @"noimage.png";
        cell.itemImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", imgString]];
    }
    else
    {
        [cell.itemImage loadImageFromURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",itemImageURL]]];
    }
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor colorWithRed:0.086 green:0.075 blue:0.141 alpha:1.000];
    selectionColor.layer.cornerRadius = 8.0;
    cell.selectedBackgroundView = selectionColor;
    
    UIView *backColor = [[UIView alloc] init];
    backColor.backgroundColor = [UIColor colorWithRed:(241/255.f) green:(238/255.f) blue:(239/255.f) alpha:1.0];
    backColor.layer.cornerRadius = 8.0;
    cell.backgroundView = backColor;

    return cell;

}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedItemIndexpath = indexPath;
    
//    [self.multipleItemBarcodeRingUpDelegate didRingUpItemFormMultipleItemForDuplicateBarcode:[self.multipleItemArray objectAtIndex:indexPath.row]];
}
-(IBAction)DoneMultipeBarcodeVC:(id)sender
{
    if (selectedItemIndexpath == nil)
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"please select the item first" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];

        return;
    }
    Item_Price_MD *item_Price_MD = [self.itemBarcodeResultController objectAtIndexPath:selectedItemIndexpath];
    Item *anitem = item_Price_MD.priceToItem;
    
    if (item_Price_MD.qty.integerValue == 0)
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Invalid values in this item" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        
        return;
    }
    
    [self.multipleItemBarcodeRingUpDelegate didRingUpItemFormMultipleItemForDuplicateBarcode:anitem withItemQty:item_Price_MD.qty withPackageType:item_Price_MD.priceqtytype];
    
    
}
-(IBAction)cancelMultipeBarcodeVC:(id)sender
{
    [self.multipleItemBarcodeRingUpDelegate didCanceMultipleItemBarcodeCustomerVC];
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
