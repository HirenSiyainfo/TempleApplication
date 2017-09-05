//
//  ItemPackageTypeRingUpVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 2/27/17.
//  Copyright © 2017 Siya Infotech. All rights reserved.
//

#import "ItemPackageTypeRingUpVC.h"
#import "Item+Dictionary.h"
#import "Department+Dictionary.h"
#import "ItemBarCode_Md+Dictionary.h"
#import  "Item_Price_MD+Dictionary.h"
#import "RmsDbController.h"
#import "CommonLabel.h"
#import "ItemPackageTypeCell.h"

@interface ItemPackageTypeRingUpVC ()<NSFetchedResultsControllerDelegate>
{
    NSIndexPath *selectedItemIndexpath;
    
}
@property (nonatomic, weak) IBOutlet UITableView *itemPackeTypeTableview;
@property (nonatomic, weak) IBOutlet UILabel *lblItenName;

@property (nonatomic, strong) RmsDbController *rmsDbController;



@end

@implementation ItemPackageTypeRingUpVC

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
    _lblItenName.text = [NSString stringWithFormat:@"Name : %@" , _strItemName];

    [_itemPackeTypeTableview reloadData];

}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_itemPackeTypeTableview reloadData];
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 45;
//}

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
//    NSArray *sections = self.itemPackeTypeResultController.sections;
//    id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
   // return sectionInfo.numberOfObjects;
    return _arrayItem.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ItemPackageTypeCell *cell = (ItemPackageTypeCell*)[tableView dequeueReusableCellWithIdentifier:@"ItemPackageTypeCell" forIndexPath:indexPath];
    
    Item_Price_MD *item_Price_MD = [_arrayItem objectAtIndex:indexPath.row];
    Item *anitem = item_Price_MD.priceToItem;
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
    
    Item_Price_MD *item_Price_MD = [_arrayItem objectAtIndex:selectedItemIndexpath.row];
    Item *anitem = item_Price_MD.priceToItem;
    
    [self.itemPackageTypeRingUpDelegate didRingUpItemFormPackageTypeDetail:anitem withItemQty:item_Price_MD.qty withPackageType:item_Price_MD.priceqtytype];
    
    
}
-(IBAction)cancelMultipeBarcodeVC:(id)sender
{
    [self.itemPackageTypeRingUpDelegate didCancelPackageTypeCustomeVC];
}



@end
