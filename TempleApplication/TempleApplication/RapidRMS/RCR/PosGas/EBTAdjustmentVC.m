//
//  EBTAdjustmentVC.m
//  RapidRMS
//
//  Created by Siya-ios5 on 7/7/17.
//  Copyright © 2017 Siya Infotech. All rights reserved.
//

#import "EBTAdjustmentVC.h"
#import "TenderItemTableCustomCell.h"
#import "RmsDbController.h"

@interface EBTAdjustmentVC ()<TenderItemTableCellDelegate>
{
    NSNumber *totalEBTAmount;
}
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) RcrController *crmController;
@property (nonatomic, weak) IBOutlet UITableView *ebtAdjustmentVCTable;
@property (nonatomic, weak) IBOutlet UILabel *ebtAmount;

@end

@implementation EBTAdjustmentVC

- (void)viewDidLoad {
    
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.crmController = [RcrController sharedCrmController];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    [self updateEBTAmount:self.reciptDataAry];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    for (int i = 0; i <self.reciptDataAry.count; i++) {
        [_ebtAdjustmentVCTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:TRUE scrollPosition:UITableViewScrollPositionNone];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return  1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   return  self.reciptDataAry.count;
}

-(CGFloat)tableHeaderHeight
{
    return 75.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float headerHeight = [self tableHeaderHeight];
    
    NSDictionary *billDictionaryAtIndexPath  = [self.reciptDataAry objectAtIndex:indexPath.row];
    
    if ([[billDictionaryAtIndexPath[@"item"] valueForKey:@"isCheckCash"] boolValue] ==YES) {
        headerHeight += 20.0;
    }
    if([[billDictionaryAtIndexPath[@"item"]valueForKey:@"isExtraCharge"]boolValue]==YES)
    {
        headerHeight+=20.0;
    }
    if(billDictionaryAtIndexPath[@"InvoiceVariationdetail"])
    {
        headerHeight+= [billDictionaryAtIndexPath[@"InvoiceVariationdetail"] count ] *  20.0;
    }
    if([[billDictionaryAtIndexPath valueForKey:@"itemName"] isEqualToString:@"GAS"])
    {
        headerHeight = 140.0;
    }
    
    return headerHeight;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"TenderItemTableViewCell";
    TenderItemTableCustomCell *tenderItemCell = (TenderItemTableCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    tenderItemCell.currencyFormatter = self.crmController.currencyFormatter;
    tenderItemCell.indexPathForCell = indexPath;
    tenderItemCell.tenderItemTableCellDelegate = self;
    
    NSDictionary *billDictionaryAtIndexPath  = [self.reciptDataAry objectAtIndex:indexPath.row];
    
    Item *item = [self fetchItemFromItemId:[billDictionaryAtIndexPath valueForKey:@"itemId"]];
    [tenderItemCell updateCellWithBillItem:billDictionaryAtIndexPath withItem:item];
    
    return tenderItemCell;
}

-(BOOL)isIndexPathSelected:(NSIndexPath *)indexPath
{
    BOOL isIndexPathSelected = FALSE;
    NSArray *selectedIndexPath = [_ebtAdjustmentVCTable indexPathsForSelectedRows];
    if ([selectedIndexPath containsObject:indexPath]) {
        isIndexPathSelected = YES;
    }
    return isIndexPathSelected;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *receiptDictionaryAtIndex = self.reciptDataAry[indexPath.row];
    
   totalEBTAmount = @(totalEBTAmount.floatValue + [receiptDictionaryAtIndex[@"EbtAmount"] floatValue]);
    self.ebtAmount.text = [NSString stringWithFormat:@"EBT Amount %.2f",totalEBTAmount.floatValue];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *receiptDictionaryAtIndex = self.reciptDataAry[indexPath.row];
    
    totalEBTAmount = @(totalEBTAmount.floatValue - [receiptDictionaryAtIndex[@"EbtAmount"] floatValue]);
    self.ebtAmount.text = [NSString stringWithFormat:@"EBT Amount %.2f",totalEBTAmount.floatValue];
}


-(void)updateEBTAmount:(NSMutableArray *)receiptArray
{
    for (NSMutableDictionary *receiptDictionary in receiptArray) {
        BOOL isEBTApplicable = [receiptDictionary[@"EBTApplicable"] boolValue];
        if (isEBTApplicable) {
            BOOL isEBTApplied = [receiptDictionary[@"EBTApplied"] boolValue];
            if (isEBTApplicable == TRUE && isEBTApplied == TRUE) {
                NSNumber *itemVariationCost = 0;
                if([receiptDictionary valueForKey:@"InvoiceVariationdetail"])
                {
                    CGFloat itemVariation = [[(NSArray *)receiptDictionary[@"InvoiceVariationdetail"] valueForKeyPath:@"@sum.Price"] floatValue]*[[receiptDictionary valueForKey:@"itemQty"] floatValue];
                    itemVariationCost = @(itemVariation);
                }
               CGFloat ebtAmount = [[receiptDictionary valueForKey:@"itemPrice"] floatValue] * [[receiptDictionary valueForKey:@"itemQty"] floatValue] +itemVariationCost.floatValue ;
                receiptDictionary[@"EbtAmount"] =  @(ebtAmount);
                totalEBTAmount = @(totalEBTAmount.floatValue + ebtAmount);
            }
        }
    }
    self.ebtAmount.text = [NSString stringWithFormat:@"EBT Amount %.2f",totalEBTAmount.floatValue];
}

-(IBAction)applyButton:(id)sender
{
    NSMutableArray *removeEbtItems = [[NSMutableArray alloc]init];
    
    for (int i = 0; i <self.reciptDataAry.count; i++) {
        NSIndexPath *indexPathForItem = [NSIndexPath indexPathForRow:i inSection:0];
        if ([self isIndexPathSelected:indexPathForItem] == FALSE) {
            NSDictionary *receiptDictionaryAtIndex = self.reciptDataAry[indexPathForItem.row];
            [removeEbtItems addObject:receiptDictionaryAtIndex];
        }
    }
    
    [self.ebtAdjustmentVCDelegate didRemoveEbtForItems:removeEbtItems];
    [self dismissViewControllerAnimated:TRUE completion:^{
    }];

}

- (Item*)fetchItemFromItemId :(NSString *)itemId
{
    Item *item = nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Item" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemCode==%d", itemId.integerValue];
    fetchRequest.predicate = predicate;
    
    // NSError *error;
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count>0)
    {
        item=resultSet.firstObject;
    }
    return item;
}


-(void)didAddQtyAtIndxPath:(NSIndexPath *)indexpath
{
    
}
-(void)didSubtractQtyAtIndxPath:(NSIndexPath *)indexpath
{
    
}
-(IBAction)cancelButton:(id)sender
{
    [self dismissViewControllerAnimated:TRUE completion:^{
        
    }];
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
