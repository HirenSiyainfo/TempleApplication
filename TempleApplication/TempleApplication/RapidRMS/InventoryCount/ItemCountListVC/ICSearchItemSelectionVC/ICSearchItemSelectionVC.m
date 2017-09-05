//
//  ICSearchItemSelectionVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 05/01/15.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "ICSearchItemSelectionVC.h"
#import "Item+Dictionary.h"
#import "RmsDbController.h"
#import "RimsController.h"
#import "POmenuListVC.h"
#import "GenerateOrderView.h"

@interface ICSearchItemSelectionVC ()
{
}

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;

@end

@implementation ICSearchItemSelectionVC

@synthesize btn_Done;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setButtonProperty:(UIButton *)selectedButton setTitle:(NSString *)title
{
    selectedButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    [selectedButton setImage:nil forState:UIControlStateNormal];
    [selectedButton setImage:nil forState:UIControlStateHighlighted];
    [selectedButton setTitle:title forState:UIControlStateNormal];
    [selectedButton setTitle:title forState:UIControlStateHighlighted];
    [selectedButton setBackgroundImage:[UIImage imageNamed:@"GlobalWhite.png"] forState:UIControlStateNormal];
    [selectedButton setBackgroundImage:[UIImage imageNamed:@"globalgreen.png"] forState:UIControlStateHighlighted];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    
    self.tblviewInventory.delegate = self;
    self.tblviewInventory.dataSource = self;
    
    self.checkSearchRecord = TRUE;
    self.footerView.backgroundColor = [UIColor lightGrayColor];
    
    self.btnAddItem.frame = CGRectMake(0, 1, 160, 48);
    [self setButtonProperty:self.btnAddItem setTitle:@"Done"];
    self.lblAddItem.text = @"";
    [self.btnAddItem setEnabled:NO];
    
    self.btn_ItemInfo.frame = CGRectMake(161, 1, 160, 48);
    [self setButtonProperty:self.btn_ItemInfo setTitle:@"Cancel"];
    self.lblItemInfo.text = @"";
    
    self.btnSelectMode.hidden = YES;
    self.lblSelectMode.hidden = YES;
    
    self.btnLabelPrint.hidden = YES;
    self.lblLabelPrint.hidden = YES;
    
    self.btnMenu.hidden = YES;
    self.lblMenu.hidden = YES;
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.tblviewInventory)
    {
        Item *anItem = [self.itemResultsController objectAtIndexPath:indexPath];
        if (anItem.is_Selected.boolValue) {
            anItem.is_Selected = @(NO);
        } else {
            anItem.is_Selected = @(YES);
        }
        
        NSMutableDictionary *dictItemClicked = [anItem.itemRMSDictionary mutableCopy];
        
        if([dictItemClicked[@"selected"] isEqualToString:@"0"])
        {
            for(int isfnd = 0 ; isfnd < self.arrTempSelected.count ; isfnd++)
            {
                NSMutableDictionary *dictSelected = [(self.arrTempSelected)[isfnd] mutableCopy ];
                if([[dictSelected valueForKey:@"ItemId"] isEqualToString:[dictItemClicked valueForKey:@"ItemId"]])
                {
                    [self.arrTempSelected removeObjectAtIndex:isfnd];
                    break;
                }
            }
            if(self.arrTempSelected.count > 0) {
                flgDonebutton=TRUE;
            } else {
                flgDonebutton = FALSE;
            }
        } else {
            [self.arrTempSelected addObject:dictItemClicked];
            flgDonebutton=TRUE;
        }
        self.itemSelectModeArray = self.arrTempSelected;
        NSArray *indexpaths = @[indexPath];
        [self.tblviewInventory reloadRowsAtIndexPaths:indexpaths withRowAnimation:UITableViewRowAnimationAutomatic];
        
        if(flgDonebutton)
        {
            btn_Done.hidden = YES;
            [self.btnAddItem setEnabled:YES];
            [self.lblAddItem setEnabled:YES];
        }
        else
        {
            btn_Done.hidden = YES;
            [self.btnAddItem setEnabled:NO];
            [self.lblAddItem setEnabled:NO];
        }
    }
//    else if (tableView == self.filterTypeTable)
//    {
//        self.filterIndxPath = nil;
//        self.filterIndxPath = [NSIndexPath indexPathForRow:-1 inSection:-1];
//        self.filterIndxPath = indexPath;
//        [self.rmsDbController playButtonSound];
//        if(indexPath.row == 0)
//        {
//            self.rmsDbController.rimSelectedFilterType = @"ABC Shorting";
//            self.isKeywordFilter = FALSE;
//            self.isAbcShortingFilter = TRUE;
//            self.txtUniversalSearch.placeholder = @"ABC Shorting";
//            self.filterTypeTable.hidden = YES;
//        }
//        else if (indexPath.row == 1)
//        {
//            self.rmsDbController.rimSelectedFilterType = @"Keyword";
//            self.isKeywordFilter = TRUE;
//            self.isAbcShortingFilter = FALSE;
//            self.txtUniversalSearch.placeholder = @"UPC, Item Number, Description, Department, etc..";
//            self.filterTypeTable.hidden = YES;
//        }
//        if((self.txtUniversalSearch.text.length > 0) || (self.searchText.length > 0))
//        {
//            self.txtUniversalSearch.text = @"";
//            self.searchText = @"";
//            _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
//            NSIndexPath *topIndexpath = [NSIndexPath indexPathForRow:0 inSection:0];
//            [self.tblviewInventory scrollToRowAtIndexPath:topIndexpath atScrollPosition:UITableViewScrollPositionNone animated:NO];
//            [self reloadInventoryMgmtTable];
//        }
//    }
}

- (void)resetIsSelectedItem
{
    for(int isfnd = 0 ; isfnd < self.arrTempSelected.count ; isfnd++)
    {
        NSMutableDictionary *dictSelected = [(self.arrTempSelected)[isfnd] mutableCopy];
        Item *anItem = [self fetchAllItems:[dictSelected valueForKey:@"ItemId"]];
        anItem.is_Selected = @(NO);
    }
}

-(IBAction)btn_New:(id)sender
{
    [self.rmsDbController playButtonSound];
    [self resetIsSelectedItem];
    [self.tblviewInventory reloadData];
    
    btn_Done.hidden=YES;
    flgDonebutton = NO;
    self.checkSearchRecord = FALSE;
    
    [self.icSearchItemSelectionVC didSelectItems:self.arrTempSelected];
    [self.navigationController popViewControllerAnimated:YES];
}



-(IBAction)btn_ItemInfoClicked:(id)sender
{
    [self.rmsDbController playButtonSound];
    [self resetIsSelectedItem];
    [self.arrTempSelected removeAllObjects];
    self.checkSearchRecord = FALSE;
    [self.navigationController popViewControllerAnimated:YES];
}

- (Item*)fetchAllItems :(NSString *)itemId
{
    Item *item=nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemCode==%d", itemId.integerValue];
    fetchRequest.predicate = predicate;
    NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
    if (resultSet.count>0)
    {
        item=resultSet.firstObject;
    }
    return item;
}

@end
