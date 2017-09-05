//
//  CL_CustomerSearchVC.m
//  RapidRMS
//
//  Created by siya-IOS5 on 12/9/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "CL_CustomerSearchVC.h"
#import "CL_CustomeSearchCell.h"
#import "RmsDbController.h"

typedef NS_ENUM(NSInteger, CS_DatePicker) {
    CS_FromDatePicker,
    CS_ToDatePicker,
    };

@interface CL_CustomerSearchVC ()<UICollectionViewDataSource , UICollectionViewDelegate>
{
    NSArray *customerSearchEnumArray;
    NSInteger selectedDatePickerFormat;
}

@property (nonatomic , weak) IBOutlet UICollectionView *dateSearchCollection;
@property (nonatomic , weak) IBOutlet UIDatePicker *fromDatePicker;
@property (nonatomic , weak) IBOutlet UIView * viewBGDatePicker;
@property (nonatomic , weak) IBOutlet UILabel *fromDateLabel;
@property (nonatomic , weak) IBOutlet UILabel *fromTimeLabel;
@property (nonatomic , weak) IBOutlet UILabel *toDateLabel;
@property (nonatomic , weak) IBOutlet UILabel *toTimeLabel;
@property (nonatomic , weak) IBOutlet UIButton *btnSubmit;

@property (nonatomic , strong) RmsDbController *rmsDbController;

@end

@implementation CL_CustomerSearchVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    selectedDatePickerFormat = -1;
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    
    customerSearchEnumArray = @[@(CS_SearchType_Today),@(CS_SearchType_YesterDay),@(CS_SearchType_Monthly),@(CS_SearchType_Weekly),@(CS_SearchType_Quarterly),@(CS_SearchType_Yearly),@(CS_SearchType_Nov2015),@(CS_SearchType_JanToDec2015),@(CS_SearchType_Nov2014),@(CS_SearchType_JanToDec2014)];
    [_fromDatePicker setValue:[UIColor whiteColor] forKey:@"textColor"];
    _btnSubmit.layer.cornerRadius = 5.0;
    _btnSubmit.layer.borderWidth = 1.0;
    _btnSubmit.layer.borderColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.3].CGColor;
    // Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_dateSearchCollection reloadData];

    NSUInteger selectedCustomerType = [customerSearchEnumArray indexOfObject:@(self.cl_CustomerSearchData.cl_SelectedSerachType)];
        [_dateSearchCollection selectItemAtIndexPath:[NSIndexPath indexPathForItem:selectedCustomerType inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionNone];
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
    return customerSearchEnumArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"CL_CustomeSearchCell";
    
    CL_CustomeSearchCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    NSString *titleForCell = @"";;
    
    CS_SearchType cs_SearchType = [customerSearchEnumArray[indexPath.row] integerValue];
    titleForCell = [self.cl_CustomerSearchData dateSearchString:cs_SearchType];
    
    cell.lblSearch.text = titleForCell;
    return cell;
}

-(IBAction)submitButton:(id)sender
{
    self.cl_CustomerSearchData.cl_SelectedSerachType = CS_SearchType_DateRange ;
    if (self.cl_CustomerSearchData.startDateRange == nil)
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please Select From Date-Time." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    }
    else if (self.cl_CustomerSearchData.endDateRange == nil)
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please Select To Date-Time." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    }
    else if ([self.cl_CustomerSearchData.startDateRange compare:self.cl_CustomerSearchData.endDateRange] == NSOrderedDescending)
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please provide valid Date range." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    }
    else
    {
        [self.cl_CustomerSearchVCDelegate didUpdateCustomerWithStartDate:self.cl_CustomerSearchData.startDateRange withEndDate:self.cl_CustomerSearchData.endDateRange withSearchCustomType:@"Custom"];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CS_SearchType cs_SearchType = [customerSearchEnumArray[indexPath.row] integerValue];
    self.cl_CustomerSearchData.cl_SelectedSerachType = cs_SearchType ;
   // [self.cl_CustomerSearchData fromDateToStartdateStringFor:cs_SearchType];
    [self.cl_CustomerSearchVCDelegate didUpdateCustomerWithStartDate:[NSDate date] withEndDate:[NSDate date] withSearchCustomType:[self.cl_CustomerSearchData webserviceParameterStringFor:[customerSearchEnumArray[indexPath.row] integerValue]]];
}



-(IBAction)datePickerValueChanged:(id)sender
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/yyyy";
    
    NSDateFormatter* timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateFormat = @"hh:mm a";
    


    NSDate *datePickerSelectedDate = _fromDatePicker.date;
 
    if (selectedDatePickerFormat == CS_FromDatePicker) {
        self.cl_CustomerSearchData.startDateRange = datePickerSelectedDate;
        _fromDateLabel.text = [dateFormatter stringFromDate:datePickerSelectedDate];
        _fromTimeLabel.text = [timeFormatter stringFromDate:datePickerSelectedDate];

    }
    
    if (selectedDatePickerFormat == CS_ToDatePicker) {
        self.cl_CustomerSearchData.endDateRange = datePickerSelectedDate;
        _toDateLabel.text = [dateFormatter stringFromDate:datePickerSelectedDate];
        _toTimeLabel.text = [timeFormatter stringFromDate:datePickerSelectedDate];
    }
    
    _viewBGDatePicker.hidden = YES;
}
-(IBAction)displayDatePicker:(UIButton *)sender
{
    _viewBGDatePicker.hidden = NO;

    if (sender.tag == 1) {
        selectedDatePickerFormat = CS_FromDatePicker;
    }
    else
    {
        selectedDatePickerFormat = CS_ToDatePicker;
    }
}




@end
