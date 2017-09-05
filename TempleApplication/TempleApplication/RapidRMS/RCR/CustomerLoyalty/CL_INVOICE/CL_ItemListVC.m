//
//  CL_ItemListVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 02/12/15.
//  Copyright © 2015 Siya Infotech. All rights reserved.
//

#import "CL_ItemListVC.h"
#import "CL_ItemListCell.h"
#import "RmsDbController.h"
#import "RmsActivityIndicator.h"
#import "CS_Item.h"

@interface CL_ItemListVC ()<UITableViewDataSource , UITableViewDelegate>
{
    RapidCustomerLoyalty *rapidCustomerLoyaltyItemListObject;
}

@property (nonatomic, weak) IBOutlet UITableView *tblItemList;

@property (nonatomic,strong) RmsDbController *rmsDbController;
@property (nonatomic,strong) CS_Item *cs_Item;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;

@property (nonatomic,strong) NSMutableArray *itemListArray;


@end

@implementation CL_ItemListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rmsDbController = [RmsDbController sharedRmsDbController];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)updateItemListViewWithRapidCustomerLoyaltyObject:(NSMutableArray *)itemList
{
    self.itemListArray = itemList;
    [self.tblItemList reloadData];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    return 55;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.itemListArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CL_ItemListCell";
    CL_ItemListCell *itemListCell = (CL_ItemListCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    _cs_Item = (self.itemListArray)[indexPath.row];

    itemListCell.backgroundColor = [UIColor clearColor];
    
    itemListCell.lblItemNameAndNo.text = [NSString stringWithFormat:@"%@",_cs_Item.itemName];
    itemListCell.lblItemNo.text = [NSString stringWithFormat:@"%@",_cs_Item.itemNo];
    itemListCell.lblItemUPC.text = [NSString stringWithFormat:@"%@",_cs_Item.barcode];
    itemListCell.lblItemVendor.text = [NSString stringWithFormat:@"%@",_cs_Item.departmentName];
    itemListCell.lblItemPrice.text = [NSString stringWithFormat:@"$ %.2f",_cs_Item.price];
    itemListCell.lblItemInvoiceNo.text = [NSString stringWithFormat:@"%@",_cs_Item.invoice];
    
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor colorWithRed:(246/255.f) green:(246/255.f) blue:(246/255.f) alpha:0.1];
    itemListCell.selectedBackgroundView = selectionColor;
    return itemListCell;
    
}

-(void)searchItemListData:(NSString*)itemListSearchString arrItemList:(NSMutableArray *)itemListSearchArray
{
    NSPredicate *predicate = [self searchPredicateForText:itemListSearchString];
    NSArray *filteredArray = [itemListSearchArray filteredArrayUsingPredicate:predicate];
    if (filteredArray.count>0)
    {
        self.itemListArray = [filteredArray mutableCopy];
    }
    else
    {
        if ([itemListSearchString isEqualToString:@""])
        {
            self.itemListArray = itemListSearchArray;
        }
        else
        {
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
                self.itemListArray = itemListSearchArray;
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"No record found." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        }
    }
    [self.tblItemList reloadData];
}

-(NSMutableArray *)itemListArray:(NSString*)itemListSearchString arrInvoicelListdata:(NSMutableArray *)itemListSearchArray
{
    NSPredicate *predicate = [self searchPredicateForText:itemListSearchString];
    NSArray *filteredArray = [itemListSearchArray filteredArrayUsingPredicate:predicate];
    NSMutableArray *arrayFilterItem ;

    if (filteredArray.count>0)
    {
        arrayFilterItem = [filteredArray mutableCopy];
    }
    else
    {
        arrayFilterItem = itemListSearchArray;
    }
    return arrayFilterItem;
}

-(NSPredicate *)searchPredicateForText:(NSString *)searchData
{
    NSMutableArray *textArray=[[searchData componentsSeparatedByString:@","] mutableCopy];
    NSMutableArray *fieldWisePredicates = [NSMutableArray array];
    NSArray *dbFields = nil;
    
    dbFields = @[ @"SELF.barcode contains[cd] %@",@"SELF.itemName contains[cd] %@"];
    
    for (int i=0; i<textArray.count; i++)
    {
        NSString *str=textArray[i];
        str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        NSMutableArray *searchTextPredicates = [NSMutableArray array];
        for (NSString *dbField in dbFields)
        {
            if (![str isEqualToString:@""])
            {
                [searchTextPredicates addObject:[NSPredicate predicateWithFormat:dbField, str]];
            }
        }
        NSPredicate *compoundpred = [NSCompoundPredicate orPredicateWithSubpredicates:searchTextPredicates];
        [fieldWisePredicates addObject:compoundpred];
    }
    NSPredicate *finalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:fieldWisePredicates];
    return finalPredicate;
}



@end
