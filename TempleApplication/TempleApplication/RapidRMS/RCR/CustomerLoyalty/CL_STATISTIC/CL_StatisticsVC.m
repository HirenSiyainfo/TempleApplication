//
//  CL_StatisticsVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 27/11/15.
//  Copyright © 2015 Siya Infotech. All rights reserved.
//

#import "CL_StatisticsVC.h"
#import "CL_StatisticItemCell.h"
#import "CL_StatisticDetailCell.h"
#import "RmsDbController.h"
#import "CL_StatisticInfoCollectionVC.h"
#import "Item+Dictionary.h"
#import "CL_CustomerSearchVC.h"
#import "CL_StatisticTagCell.h"

@interface CL_StatisticsVC ()<UICollectionViewDelegate , UICollectionViewDataSource>
{
    NSMutableArray *customerItemsArray;
    NSMutableArray *customerTagsArray;
    NSMutableArray *customerdepartmentArray;

}

@property (nonatomic, weak) IBOutlet UICollectionView *itemCollectionView;
@property (nonatomic, weak) IBOutlet UICollectionView *tagCollectionView;
@property (nonatomic, weak) IBOutlet UIImageView *imgBG;
@property (nonatomic, weak) IBOutlet UILabel *lblCustomerName;
@property (nonatomic, weak) IBOutlet UILabel *lblEmail;
@property (nonatomic, weak) IBOutlet UILabel *lblDOB;
@property (nonatomic, weak) IBOutlet UILabel *lblMobileNo;
@property (nonatomic, weak) IBOutlet UILabel *lblCustomerNo;
@property (nonatomic, weak) IBOutlet UILabel *lblFirstDepartmentName;
@property (nonatomic, weak) IBOutlet UILabel *lblSecondDepartmentName;
@property (nonatomic, weak) IBOutlet UILabel *lblFirstDepartmentvalue;
@property (nonatomic, weak) IBOutlet UILabel *lblSecondDepartmentValue;
@property (nonatomic, weak) IBOutlet UILabel *lblMonthlyInfo;
@property (nonatomic, weak) IBOutlet UIView *itemView;
@property (nonatomic, weak) IBOutlet UIView *tagView;
@property (nonatomic, weak) IBOutlet UIView *preferenceView;

@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) CL_StatisticInfoCollectionVC *cl_StatisticInfoCollectionVC;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation CL_StatisticsVC
@synthesize managedObjectContext = _managedObjectContext;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;

    [self setCornerRadiusForView:_itemView withCornerRadius:5.0 withBorderWidth:1.0 withBorderColor:[UIColor colorWithRed:66.0/255.0 green:66.0/255.0 blue:74.0/255.0 alpha:1.0]];
    [self setCornerRadiusForView:_tagView withCornerRadius:5.0 withBorderWidth:1.0 withBorderColor:[UIColor colorWithRed:66.0/255.0 green:66.0/255.0 blue:74.0/255.0 alpha:1.0]];
    [self setCornerRadiusForView:_preferenceView withCornerRadius:5.0 withBorderWidth:1.0 withBorderColor:[UIColor colorWithRed:66.0/255.0 green:66.0/255.0 blue:74.0/255.0 alpha:1.0]];

}

-(void)setCornerRadiusForView:(id)view1 withCornerRadius:(CGFloat)cornerRadius withBorderWidth:(CGFloat )borderWidth withBorderColor:(UIColor *)borderColor
{
    UIView *view = (UIView*)view1;
    view.layer.borderWidth = borderWidth;
    view.layer.borderColor = borderColor.CGColor;
    view.layer.cornerRadius = cornerRadius;
}


-(void)setCustomerStatisticInformation:(CS_Statistics *)statisticdetail strdateTimeSet:(NSString *)strMonthlyDate
{
    _lblCustomerName.text = [NSString stringWithFormat:@"%@ %@",self.rapidCustomerLoyaltyStatisticObject.firstName , self.rapidCustomerLoyaltyStatisticObject.lastName];
    _lblEmail.text = [NSString stringWithFormat:@"%@ ",self.rapidCustomerLoyaltyStatisticObject.email];
    _lblCustomerNo.text = [NSString stringWithFormat:@"%@",self.rapidCustomerLoyaltyStatisticObject.customerNo];
 
    //// Convert Json To Date
//    NSDateFormatter *format = [[NSDateFormatter alloc] init];
//    [format setDateFormat:@"MM/dd/yyyy"];
//    NSDate *now = [self.rmsDbController getDateFromJSONDate:statisticdetail.dob];
//    NSString *dateString = [format stringFromDate:now];
    
    if (self.rapidCustomerLoyaltyStatisticObject.dateOfBirth)
    {
        _lblDOB.text = [NSString stringWithFormat:@"%@",self.rapidCustomerLoyaltyStatisticObject.dateOfBirth];
    }
    else
    {
        _lblDOB.text = [NSString stringWithFormat:@"%@",@"-"];
    }
    
    _lblMobileNo.text = [NSString stringWithFormat:@"%@",self.rapidCustomerLoyaltyStatisticObject.contactNo];
    
    _lblMonthlyInfo.text = strMonthlyDate;
    
    [self configureDepartmentDetail:statisticdetail.departmentArray];
    customerItemsArray = [self configureCoustomerItemsArrayWith:statisticdetail];
    customerTagsArray = [self configureCoustomerTagsArrayWith:statisticdetail];
    [self.cl_StatisticInfoCollectionVC setStatisticInfoDetail:statisticdetail];
    [self.itemCollectionView reloadData];
    [self.tagCollectionView reloadData];
}

-(NSMutableArray *)configureCoustomerItemsArrayWith:(CS_Statistics *)statisticdetail
{
    NSMutableArray *customerArray = [[NSMutableArray alloc] init];
    NSInteger cutomerItemDisplayLimit = 5;
    NSInteger totalItemOfCustomer = statisticdetail.topItems.count;
    NSInteger needToAddDefaultItem = cutomerItemDisplayLimit - totalItemOfCustomer;
    if (statisticdetail.topItems.count > 0) {
        customerArray = [statisticdetail.topItems mutableCopy];
    }
    if (needToAddDefaultItem > 0) {
        for (int i = 0; i < needToAddDefaultItem ; i++) {
            [customerArray addObject:@""];
        }
    }
    return customerArray;
}

-(NSMutableArray *)configureCoustomerTagsArrayWith:(CS_Statistics *)statisticdetail
{
    NSMutableArray *customerArray = [[NSMutableArray alloc] init];
    NSInteger cutomerTagDisplayLimit = 5;
    NSInteger totalItemOfCustomer = statisticdetail.topTags.count;
    NSInteger needToAddDefaultItem = cutomerTagDisplayLimit - totalItemOfCustomer;
    if (statisticdetail.topTags.count > 0) {
        customerArray = [statisticdetail.topTags mutableCopy];
    }
    if (needToAddDefaultItem > 0) {
        for (int i = 0; i < needToAddDefaultItem ; i++) {
            [customerArray addObject:@""];
        }
    }
    return customerArray;
}

-(void)configureDepartmentDetail:(NSMutableArray*)departmentArray
{
    if (departmentArray.count == 0) {
        return;
    }
    _lblFirstDepartmentName.text = [departmentArray.firstObject valueForKey:@"DeptName"];
    _lblFirstDepartmentvalue.text = [NSString stringWithFormat:@"%.2f %%",[[departmentArray.firstObject valueForKey:@"DeptPer"] floatValue]];
    
    if (departmentArray.count > 1)
    {
    _lblSecondDepartmentName.text = [departmentArray.lastObject valueForKey:@"DeptName"];
    _lblSecondDepartmentValue.text =[NSString stringWithFormat:@"%.2f %%",[[departmentArray.lastObject valueForKey:@"DeptPer"] floatValue]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger intNumberOfRows;
    if (collectionView.tag ==2)
    {
        intNumberOfRows = customerTagsArray.count;
    }
    else
    {
        intNumberOfRows = customerItemsArray.count;
    }
    return intNumberOfRows;
}



- (CGPoint)centerForMenuAtPoint:(NSIndexPath *)selectedMenuIndexpath {
    CGPoint centerPoint = CGPointZero;
    
    return centerPoint;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell ;
    if (collectionView.tag ==1)
    {
    CL_StatisticItemCell *statisticItemCell = (CL_StatisticItemCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"CL_StatisticItemCell" forIndexPath:indexPath];
    statisticItemCell.layer.cornerRadius = 10.0f;

    Item *item = [self fetchItemForItemId:customerItemsArray[indexPath.row]];
    if (item)
    {
        statisticItemCell.imgNonItemBG.hidden = YES;
        statisticItemCell.imgItemBG.hidden = NO;
        statisticItemCell.lblItemName.hidden = NO;
        NSString *itemImageURL = item.item_ImagePath;
        if ([[itemImageURL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""])
        {
            statisticItemCell.imgItemBG.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", @"RCR_NoImageForRingUp.png"]];
        }
        else if ([[itemImageURL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@"<null>"])
        {
            statisticItemCell.imgItemBG.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", @"RCR_NoImageForRingUp.png"]];
        }
        else
        {
            [statisticItemCell.imgItemBG loadImageFromURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",itemImageURL]]];
        }
        statisticItemCell.lblItemName.text = item.item_Desc;
        statisticItemCell.lblItemName.numberOfLines = 2;

    }
    else
    {
        statisticItemCell.imgNonItemBG.hidden = NO;
        statisticItemCell.imgItemBG.hidden = YES;
        statisticItemCell.lblItemName.hidden = YES;

    }
        cell = statisticItemCell;
    }
    else if(collectionView.tag == 2)
    {
        CL_StatisticTagCell *statisticTagCell = (CL_StatisticTagCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"CL_StatisticTagCell" forIndexPath:indexPath];
        statisticTagCell.layer.cornerRadius = 15.0f;
        
        statisticTagCell.lblTagName.text = customerTagsArray[indexPath.row];
        
        cell = statisticTagCell;

    }


    return cell;
}

- (Item*)fetchItemForItemId :(NSString *)itemId
{
    Item *item=nil;
    
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




-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *segueIdentifier = segue.identifier;
    if ([segueIdentifier isEqualToString:@"CL_StatisticInfoCollectionVC"])
    {
        self.cl_StatisticInfoCollectionVC = (CL_StatisticInfoCollectionVC*) segue.destinationViewController;
    }
    
}



@end
