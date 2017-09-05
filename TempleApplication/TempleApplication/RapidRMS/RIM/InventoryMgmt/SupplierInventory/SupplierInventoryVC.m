//
//  SupplierInventoryView.m
//  I-RMS
//
//  Created by Siya Infotech on 11/01/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "SupplierInventoryVC.h"
#import "RimSupplierPage.h"
#import "RmsDbController.h"
#import "RimIphonePresentMenu.h"
@interface SupplierInventoryVC () <RimSupplierChangeDelegate>{

    IntercomHandler *intercomHandler;
    
    RimIphonePresentMenu *objMenubar;
    
    UILabel * lblBarcodedata;
    UILabel * lblItemNamedata;
    UILabel * lblQtydata;
    UILabel * lblMindata;
    UILabel * lblMaxdata;
    
    UILabel * lblQty;
    UILabel * lblMin;
    UILabel * lblMax;
    
    NSMutableArray *arrAlphabetString;
    BOOL isSorting;
}
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) RimsController * rimsController;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;

@property (nonatomic, strong) NSMutableArray *arrFilterSupplier;
@property (nonatomic, strong) NSMutableArray *arrayWithData;
@property (nonatomic, strong) NSMutableArray *arrDisplayData;

@property (nonatomic, weak) IBOutlet UITableView *tblSupplierItem;
@property (nonatomic, weak) IBOutlet UIView *uvItemTitle;
@property (nonatomic, weak) IBOutlet UILabel *lblSelectSupplier;
@property (nonatomic, weak) IBOutlet UIButton *btnVander;
@property (nonatomic, weak) IBOutlet UIButton *btnMinimum;
@property (nonatomic, weak) IBOutlet UIButton *btnMaximum;
@property (nonatomic, weak) IBOutlet UIButton *btnIntercom;

@property (nonatomic, strong) RapidWebServiceConnection * itemSearchBySupplierWC;

@end

@implementation SupplierInventoryVC

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
    self.rimsController = [RimsController sharedrimController];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.itemSearchBySupplierWC = [[RapidWebServiceConnection alloc]init];
    
    if (IsPhone()) {
        objMenubar = [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"RimIphonePresentMenu_sid"];
        objMenubar.sideMenuVCDelegate = self.sideMenuVCDelegate;
    }
    
    arrAlphabetString = [[NSMutableArray alloc] initWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",@"#",nil];
    
    _arrayWithData=[[NSMutableArray alloc]init];
    
    _lblSelectSupplier.hidden = FALSE;
    _tblSupplierItem.hidden = TRUE;
    _uvItemTitle.hidden = TRUE;
    intercomHandler = [[IntercomHandler alloc] initWithButtton:_btnIntercom withViewController:self];
    isSorting = FALSE;
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(IBAction)btnMenuSliderIn:(id)sender {
    
    [self.rmsDbController playButtonSound];
    self.rimsController.scannerButtonCalled=@"";
    [self presentViewController:objMenubar animated:YES completion:nil];
}

-(void)allocLabels
{
    if (IsPhone())
    {
        lblItemNamedata = [[UILabel alloc] initWithFrame:CGRectMake(10 , 3, 280, 30)];
        lblBarcodedata = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 150, 30)];
        lblQty = [[UILabel alloc] initWithFrame:CGRectMake(10, 37, 50, 30)];
        lblQtydata = [[UILabel alloc] initWithFrame:CGRectMake(50, 37, 50, 30)];
        lblMin = [[UILabel alloc] initWithFrame:CGRectMake(100, 37, 50, 30)];
        lblMindata = [[UILabel alloc] initWithFrame:CGRectMake(140, 37, 50, 30)];
        lblMax = [[UILabel alloc] initWithFrame:CGRectMake(200, 37, 50, 30)];
        lblMaxdata = [[UILabel alloc] initWithFrame:CGRectMake(240, 37, 50, 30)];
    }
    else
    {
        lblBarcodedata = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 150, 30)];
        lblItemNamedata = [[UILabel alloc] initWithFrame:CGRectMake(200, 20, 400, 30)];
        lblQtydata = [[UILabel alloc] initWithFrame:CGRectMake(726, 20, 60, 30)];
        lblMindata = [[UILabel alloc] initWithFrame:CGRectMake(806, 20, 60, 30)];
        lblMaxdata = [[UILabel alloc] initWithFrame:CGRectMake(916, 20, 60, 30)];
    }
}

- (IBAction)btnSupplierClick:(UIButton *)sender
{
    [Appsee addEvent:kRIMItemSupplierInventory];
    [self.rmsDbController playButtonSound];
    
    RimSupplierPage *supplierNew = [[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:@"RimSupplierPageMenu_sid"];
    
    supplierNew.rimSupplierChangeDelegate = self;
    supplierNew.strItemcode = @"1";
    supplierNew.callingFunction = @"SearchSupp";
    supplierNew.rimSupplierChangeDelegate = self;
    [self.navigationController pushViewController:supplierNew animated:YES];
}
- (void)didChangeSupplier:(NSMutableArray *)SupplierListArray{
    self.arrFilterSupplier = [SupplierListArray mutableCopy];
    [self getSupplierSearchData];
}
- (NSMutableArray *)getItemSupplierData
{
    NSMutableArray *itemSupplierData = [[NSMutableArray alloc] init];
    if(self.arrFilterSupplier.count>0)
    {
        for (int isup = 0; isup < self.arrFilterSupplier.count; isup++)
        {
            NSMutableDictionary *supplierDict = [[NSMutableDictionary alloc] init];
            NSArray *salesRepresentatives = [(self.arrFilterSupplier)[isup] valueForKey:@"SalesRepresentatives"];
            if(salesRepresentatives.count > 0)
            {
                NSMutableString *strResult = [NSMutableString string];
                for (int i = 0; i < salesRepresentatives.count; i++)
                {
                    NSMutableDictionary *tmpSup = [salesRepresentatives[i] mutableCopy ];
                    NSString *ch = tmpSup[@"Id"];
                    [strResult appendFormat:@"%@,", ch];
                    NSString *strId = [strResult substringToIndex:strResult.length-1];
                    supplierDict[@"SupIds"] = strId;
                }
                supplierDict[@"VendorIds"] = [(self.arrFilterSupplier)[isup] valueForKey:@"VendorId"];
                [itemSupplierData addObject:supplierDict];
            }
            else
            {
                NSMutableDictionary *tmpSup = [(self.arrFilterSupplier)[isup] mutableCopy ];
                supplierDict[@"VendorIds"] = [tmpSup valueForKey:@"VendorId"];
                [supplierDict setValue:@"0" forKey:@"SupIds"];
                [itemSupplierData addObject:supplierDict];
            }
        }
    }
    return itemSupplierData;
}

-(void)getSupplierSearchData
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    NSMutableDictionary *itemparam=[[NSMutableDictionary alloc]init];
    [itemparam setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    itemparam[@"listSupplier"] = [self getItemSupplierData];

    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self getSearchBySupplierResponse:response error:error];
        });
    };
    
    self.itemSearchBySupplierWC = [self.itemSearchBySupplierWC initWithRequest:KURL actionName:WSM_ITEM_SEARCH_BY_SUPPLIER params:itemparam completionHandler:completionHandler];
}

- (void)getSearchBySupplierResponse:(id)response error:(NSError *)error {

    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                [Appsee addEvent:kRIMItemSISearchBySupplierWebServiceResponse withProperties:@{kRIMItemSISearchBySupplierWebServiceResponseKey : @"Response Successful"}];
                
                NSMutableArray * responsearray = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                
                if(responsearray.count>0)
                {
                    [self.arrFilterSupplier removeAllObjects];
                    self.arrFilterSupplier=[responsearray mutableCopy];
                    [self setUpGroupedArray:self.arrFilterSupplier];
                    [_tblSupplierItem reloadData];
                }
            }
            else
            {

                [Appsee addEvent:kRIMItemSISearchBySupplierWebServiceResponse withProperties:@{kRIMItemSISearchBySupplierWebServiceResponseKey : @"No Supplier record found."}];
                
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"No Supplier record found." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }

        }
    }
}

-(void)setUpGroupedArray:(NSMutableArray *)pArray
{
    [_arrayWithData removeAllObjects];
    
    for(int j=0;j<arrAlphabetString.count;j++)
    {
        NSMutableDictionary *dict =[[NSMutableDictionary alloc]init];
        NSMutableArray *arrayTemp =[[NSMutableArray alloc]init];
        NSString *searchText = [arrAlphabetString[j] substringToIndex:1];
        dict[@"Title"] = searchText;
        dict[@"section"] = [NSString stringWithFormat:@"%d",j];
        
        NSMutableArray *searchArray = [[NSMutableArray alloc] init];
        [searchArray addObjectsFromArray:pArray];
        
        NSSortDescriptor *itemName = [[NSSortDescriptor alloc] initWithKey:@"Description" ascending:YES];
        NSMutableArray *sortDescriptors = [[NSMutableArray alloc] initWithObjects:itemName,nil];
        [searchArray sortUsingDescriptors:sortDescriptors];
        
        for(NSMutableDictionary *dictTemp in searchArray)
        {
            NSString *str=[dictTemp[@"Description"] substringToIndex:1];
            NSRange titleResultsRange = [str rangeOfString:searchText options:NSCaseInsensitiveSearch];
            
            if([searchText isEqualToString:@"#"])
            {
                BOOL eb=[self validateNumber:str];
                if(eb)
                {
                    [arrayTemp addObject:dictTemp];
                    dict[@"Data"] = arrayTemp;
                }
            }
            else
            {
                if (titleResultsRange.length > 0)
                {
                    [arrayTemp addObject:dictTemp];
                    dict[@"Data"] = arrayTemp;
                }
            }
        }
        [_arrayWithData addObject:dict];
    }
}

-(BOOL)validateNumber:(NSString *)tempstr
{
    NSString *numRegex = @"[0-9]";
    NSPredicate *numberTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", numRegex];
    return [numberTest evaluateWithObject:tempstr];
}

- (IBAction)btnMinimumClicked:(UIButton *)sender
{
    isSorting = TRUE;
    [Appsee addEvent:kRIMItemSupplierInventoryMinimum];
    [self.rmsDbController playButtonSound];
    // arrow_down.png & arrow_up.png, MinStockLevel
    if(_btnMinimum.selected)
    {
        _btnMinimum.selected = NO;
        [_btnMinimum setImage:[UIImage imageNamed:@"RIM_Min_Order_Descending"] forState:UIControlStateNormal];
        [self sortArrayItem:@"MinStockLevel" withAscendingType:NO setUpGroupedArray:self.arrFilterSupplier];
    }
    else
    {
        _btnMinimum.selected = YES;
        [_btnMinimum setImage:[UIImage imageNamed:@"RIM_Min_Order_Ascending"] forState:UIControlStateNormal];
        [self sortArrayItem:@"MinStockLevel" withAscendingType:YES setUpGroupedArray:self.arrFilterSupplier];
    }
    [_btnMaximum setImage:[UIImage imageNamed:@"RIM_Max_Order_None"] forState:UIControlStateNormal];
    [self.tblSupplierItem reloadData];
}

- (IBAction)btnMaximumClicked:(UIButton *)sender
{
    isSorting = TRUE;
    [Appsee addEvent:kRIMItemSupplierInventoryMaximum];
    [self.rmsDbController playButtonSound];
    if(_btnMaximum.selected)
    {
        _btnMaximum.selected = NO;
        [_btnMaximum setImage:[UIImage imageNamed:@"RIM_Max_Order_Descending"] forState:UIControlStateNormal];
        [self sortArrayItem:@"MaxStockLevel" withAscendingType:NO setUpGroupedArray:self.arrFilterSupplier];
    }
    else
    {
        _btnMaximum.selected = YES;
        [_btnMaximum setImage:[UIImage imageNamed:@"RIM_Max_Order_Ascending"] forState:UIControlStateNormal];
        [self sortArrayItem:@"MaxStockLevel" withAscendingType:YES setUpGroupedArray:self.arrFilterSupplier];
    }
    [_btnMinimum setImage:[UIImage imageNamed:@"RIM_Min_Order_None"] forState:UIControlStateNormal];
    [self.tblSupplierItem reloadData];
}

-(void)sortArrayItem :(NSString *)KeyName withAscendingType:(BOOL)Type setUpGroupedArray:(NSMutableArray *)pArray
{
    [_arrayWithData removeAllObjects];
    
    for(int j=0;j<arrAlphabetString.count;j++)
    {
        NSMutableDictionary *dict =[[NSMutableDictionary alloc]init];
        NSMutableArray *arrayTemp =[[NSMutableArray alloc]init];
        NSString *searchText = [arrAlphabetString[j] substringToIndex:1];
        dict[@"Title"] = searchText;
        dict[@"section"] = [NSString stringWithFormat:@"%d",j];
        
        NSMutableArray *searchArray = [[NSMutableArray alloc] init];
        [searchArray addObjectsFromArray:pArray];
        
        NSSortDescriptor *itemName = [[NSSortDescriptor alloc] initWithKey:KeyName ascending:Type];
        NSMutableArray *sortDescriptors = [[NSMutableArray alloc] initWithObjects:itemName,nil];
        [searchArray sortUsingDescriptors:sortDescriptors];
        
        for(NSMutableDictionary *dictTemp in searchArray)
        {
            if([searchText isEqualToString:@"#"])
            {
                [arrayTemp addObject:dictTemp];
                dict[@"Data"] = arrayTemp;
            }
        }
        [_arrayWithData addObject:dict];
    }
}

-(void)ItemLabel:(UILabel *)sender
{
    sender.numberOfLines = 0;
    sender.textAlignment = NSTextAlignmentLeft;
    sender.backgroundColor = [UIColor clearColor];
    sender.textColor = [UIColor blackColor];
    sender.font = [UIFont fontWithName:@"Lato" size:14];
}

// tableview data start

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.arrayWithData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (isSorting) {
        return 0;
    }
    else{
        NSMutableDictionary *dict = (self.arrayWithData)[section];
        NSMutableArray *arrayDate = dict[@"Data"];
        if(arrayDate && arrayDate.count>0)
        {
            return 25;
        }
        else {
            return 0;
        }
    }
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    NSMutableDictionary *dict = (self.arrayWithData)[section];
    NSMutableArray *arrayDate = dict[@"Data"];
    NSString *strTitle = @"";
    if(arrayDate.count>0)
    {
        strTitle = dict[@"Title"];
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 25)];
    
    
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(RIMLeftMargin(), 0, view.frame.size.width-20, view.frame.size.height)];
    [label setFont:[UIFont fontWithName:@"Lato-Bold" size:14.0]];
    [label setText:strTitle.uppercaseString];
    [view addSubview:label];
    [view setBackgroundColor:[UIColor colorWithWhite:0.933 alpha:1.000]]; //your background color...
    return view;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSMutableDictionary *dict = (self.arrayWithData)[section];
    NSMutableArray *arrayDate = dict[@"Data"];
    if(arrayDate.count>0)
    {
        NSString *str = dict[@"Title"];
        return str;
    }
    else{
        return @"";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.arrayWithData.count > 0)
    {
        NSMutableDictionary *dict = (self.arrayWithData)[section];
        NSMutableArray *rows = dict[@"Data"];
        return rows.count;
    }
    else
    {
        return 0;
    }
}
//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
//{
//    return index;
//}
//
//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
//{
//    if((self.arrayWithData).count > 0)
//    {
//        return arrAlphabetString;
//    }
//    else
//        return nil;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellStyle style =  UITableViewCellStyleDefault;
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if(self.arrayWithData.count > 0)
    {
        
        _lblSelectSupplier.hidden = TRUE;
        _tblSupplierItem.hidden = FALSE;
        _uvItemTitle.hidden = FALSE;
        
        _arrDisplayData = [[[NSMutableArray alloc] initWithArray:_arrayWithData] mutableCopy ];
        _arrDisplayData = [[_arrDisplayData[indexPath.section] valueForKey:@"Data"] mutableCopy ];
        
        [self allocLabels];
        
        // barcode
        lblBarcodedata.text = [NSString stringWithFormat:@"%@",[(self.arrDisplayData)[indexPath.row] valueForKey:@"UPC"]];
        [self ItemLabel:lblBarcodedata];
        [cell addSubview:lblBarcodedata];
        
        // description
        lblItemNamedata.text = [NSString stringWithFormat:@"%@",[(self.arrDisplayData)[indexPath.row] valueForKey:@"Description"]];
        [self ItemLabel:lblItemNamedata];
        [cell addSubview:lblItemNamedata];
        
        
        // Quantity
        lblQty.text = @"QTY :";
        [self ItemLabel:lblQty];
        [cell addSubview:lblQty];
        
        lblQtydata.text = [NSString stringWithFormat:@"%@",[(self.arrDisplayData)[indexPath.row] valueForKey:@"avaibleQty"]];
        [self ItemLabel:lblQtydata];
        lblQtydata.textAlignment = NSTextAlignmentCenter;
        [cell addSubview:lblQtydata];
        
        // Maximum
        lblMax.text = @"Max :";
        [self ItemLabel:lblMax];
        [cell addSubview:lblMax];
        
        lblMaxdata.text = [NSString stringWithFormat:@"%@",[(self.arrDisplayData)[indexPath.row] valueForKey:@"MaxStockLevel"]];
        [self ItemLabel:lblMaxdata];
        lblMaxdata.textAlignment = NSTextAlignmentCenter;
        [cell addSubview:lblMaxdata];
        
        // Minimum
        lblMin.text = @"Min :";
        [self ItemLabel:lblMin];
        [cell addSubview:lblMin];
        
        lblMindata.text = [NSString stringWithFormat:@"%@",[(self.arrDisplayData)[indexPath.row] valueForKey:@"MinStockLevel"]];
        [self ItemLabel:lblMindata];
        lblMindata.textAlignment = NSTextAlignmentCenter;
        [cell addSubview:lblMindata];
        
        if (IsPad())
        {
            int y = 45;
//            int x = 210;
            NSMutableArray *arrItemSupplier = [(self.arrDisplayData)[indexPath.row] valueForKey:@"ItemSupplier"];
            for (int i = 0; i < arrItemSupplier.count; i++)
            {
                UILabel *lblSuppName = [[UILabel alloc] initWithFrame:CGRectMake(210, y, 150, 20)];
                lblSuppName.text = [arrItemSupplier[i] valueForKey:@"SupName"];
                lblSuppName.numberOfLines = 0;
                lblSuppName.textAlignment = NSTextAlignmentLeft;
                lblSuppName.backgroundColor = [UIColor clearColor];
                lblSuppName.textColor = [UIColor blackColor];
                lblSuppName.font = [UIFont fontWithName:@"Lato" size:14];
//                x+=100;
//                if(x > 320)
//                {
                    y+=20;
//                    x = 210;
//                }
                [cell addSubview:lblSuppName];
            }
        }
        else
        {
            int y = 65;
//            int x = 10;
            NSMutableArray *arrItemSupplier = [(self.arrDisplayData)[indexPath.row] valueForKey:@"ItemSupplier"];
            for (int i = 0; i < arrItemSupplier.count; i++)
            {
                UILabel *lblSuppName = [[UILabel alloc] initWithFrame:CGRectMake(10, y, 150, 20)];
                
                lblSuppName.text = [arrItemSupplier[i] valueForKey:@"SupName"];
                lblSuppName.numberOfLines = 0;
                lblSuppName.textAlignment = NSTextAlignmentLeft;
                lblSuppName.backgroundColor = [UIColor clearColor];
//                lblSuppName.textColor = [UIColor lightGrayColor];
                lblSuppName.font = [UIFont fontWithName:@"Lato" size:14];
                
//                x+=100;
//                if(x > 110)
//                {
                    y+=20;
//                    x = 10;
//                }
                [cell addSubview:lblSuppName];
            }
        }
    }
    else
    {
        _lblSelectSupplier.hidden = FALSE;
        _tblSupplierItem.hidden = TRUE;
        _uvItemTitle.hidden = TRUE;
    }
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.arrDisplayData = [[[NSMutableArray alloc] initWithArray:self.arrayWithData] mutableCopy ];
    
    self.arrDisplayData = [[(self.arrDisplayData)[indexPath.section] valueForKey:@"Data"] mutableCopy ];
    
     NSMutableArray *arrItemSupplier = [(self.arrDisplayData)[indexPath.row] valueForKey:@"ItemSupplier"];
    
    int rowHeight = 65;
    
    if (IsPhone()) // iPhone row height
    {
        for( int i = 0 ;i < arrItemSupplier.count ; i++)
        {
            rowHeight += 20;
        }
    }
    else
    {
        for( int i = 0 ;i < arrItemSupplier.count ; i++)
        {
            rowHeight += 20;
        }
    }
    return rowHeight;
    //    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
