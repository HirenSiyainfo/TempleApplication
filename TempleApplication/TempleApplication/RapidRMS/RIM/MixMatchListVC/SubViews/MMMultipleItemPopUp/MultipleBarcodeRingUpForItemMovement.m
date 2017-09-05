//
//  MultipleBarcodeRingUpForItemMovement.m
//  RapidRMS
//
//  Created by siya8 on 17/04/17.
//  Copyright © 2017 Siya Infotech. All rights reserved.
//

#import "MultipleBarcodeRingUpForItemMovement.h"
#import "RmsDbController.h"
#import "RimsController.h"
#import "MultipleBarcodeCustomCell.h"
#import "Item+CoreDataProperties.h"
#import "NSString+Validation.h"
#import "MultipleItemBarcodeRingUpCell.h"

@interface MultipleBarcodeRingUpForItemMovement ()<NSFetchedResultsControllerDelegate
#ifdef LINEAPRO_SUPPORTED
,DTDeviceDelegate
#endif
>
{
#ifdef LINEAPRO_SUPPORTED
    DTDevices *dtdev;
#endif
}
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, weak) IBOutlet UITableView *multipleItemBarcodeTableview;
@property (nonatomic, weak) IBOutlet UILabel *barcodeLabel;

@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) RimsController *rimsController;

@property (nonatomic,strong) NSFetchedResultsController *itemBarcodeResultController;

@end

@implementation MultipleBarcodeRingUpForItemMovement

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    if (!self.multipleItemArray) {
        self.multipleItemArray = [NSMutableArray array];
    }
#ifdef LINEAPRO_SUPPORTED
    dtdev=[DTDevices sharedDevice];
    [dtdev addDelegate:self];
    [dtdev connect];
#endif
    
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    [self departmentResultController];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _barcodeLabel.text = self.itemBarcode;
    [_multipleItemBarcodeTableview reloadData];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.rimsController.scannerButtonCalled=@"";
}
-(void)removeNilPrice_MdObjectFromArray
{
    for (int i = 0; i < self.multipleItemArray.count; i++)
    {
        Item *item_barcode = (self.multipleItemArray)[i];
        if (!item_barcode.itemBarcodes)
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
                                   entityForName:@"Item" inManagedObjectContext:_managedObjectContext];
    fetchRequest.entity = entity;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF IN %@ ",self.multipleItemArray];
    fetchRequest.predicate = predicate;
    // Create the sort descriptors array.
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"item_Desc" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    
    // Create and initialize the fetch results controller.
    _itemBarcodeResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_managedObjectContext sectionNameKeyPath:@"item_Desc" cacheName:nil];
    
    [_itemBarcodeResultController performFetch:nil];
    _itemBarcodeResultController.delegate = self;
    
    return _itemBarcodeResultController;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSArray *sections = self.itemBarcodeResultController.sections;
    return sections.count;
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
    
    Item *anItem = [self.itemBarcodeResultController objectAtIndexPath:indexPath];
    
    cell.itemName.text = anItem.item_Desc;
    cell.itemPrice.text = [NSString stringWithFormat:@"%@",anItem.costPrice];
    if (anItem.item_InStock) {
        cell.itemQty.text = [NSString stringWithFormat:@"%@",anItem.item_InStock];
    }
    else
    {
        cell.itemQty.text = @"1";
    }
    
    cell.itemPrice.text = [self.rmsDbController applyCurrencyFomatter:[NSString stringWithFormat:@"%@",anItem.salesPrice]];
    
    NSString *itemImageURL = anItem.item_ImagePath;
    
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
}

-(IBAction)DoneMultipeBarcodeVC:(id)sender
{
    NSArray *selectedRows = self.multipleItemBarcodeTableview.indexPathsForSelectedRows;
    if (!selectedRows || selectedRows.count == 0)
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"please select the item first" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    }
    else {
        NSMutableArray *selectedItemsArray = [[NSMutableArray alloc] init];
        for (NSIndexPath *indexPath in selectedRows) {
            Item *anitem = [self.itemBarcodeResultController objectAtIndexPath:indexPath];
            [selectedItemsArray addObject:anitem];
        }
        [self.multipleBarcodePopUpForIMVCDelegate didSelectItemsForScanningItemForDuplicateBarcode:selectedItemsArray];
    }
}

-(IBAction)cancelMultipeBarcodeVC:(id)sender
{
    [self.multipleBarcodePopUpForIMVCDelegate didCanceItemsSelection];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
