//
//  CCbatchReportVC.m
//  RapidRMS
//
//  Created by siya-IOS5 on 6/27/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "CCbatchReportVC.h"
#import "RmsDbController.h"
#import "CCbatchReportCell.h"
#import "CommonLabel.h"

@interface CCbatchReportVC ()
{
    IBOutlet UIView *datePickerView;
}
@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) NSMutableArray *totalCardDisplayArray;
@property (nonatomic, strong) NSMutableArray *totalCardArray;
@property (nonatomic, strong) NSMutableArray *cardDetail;
@property (nonatomic, strong) NSMutableArray *cardDetailDisplayList;
@property (nonatomic, strong) NSMutableArray *cardDetailList;


@property (nonatomic, weak) IBOutlet UILabel *lblTotalTransaction;
@property (nonatomic, weak) IBOutlet UILabel *lblTotalTicket;
@property (nonatomic, weak) IBOutlet UILabel *lblTotalTransactionAmount;


@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, weak) IBOutlet UITableView *tblCardSettlement;
@property (nonatomic, weak) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, weak) IBOutlet UILabel *lblDate;

@property (nonatomic, weak) IBOutlet UIView *cardSelectionView;
@property (nonatomic, weak) IBOutlet UIPickerView *cardSelectionPickerView;
@property (nonatomic, weak) IBOutlet UILabel *selectedCardName;
@property (nonatomic, weak) IBOutlet UIButton *cardSelectionButton;
@property (nonatomic, strong) RapidWebServiceConnection *cCbatchDataWC;

@property (nonatomic, strong) NSDate *selectedDate;
@end

@implementation CCbatchReportVC

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
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.cCbatchDataWC = [[RapidWebServiceConnection alloc] init];
    self.tblCardSettlement.layer.borderWidth = 0.3;
    self.tblCardSettlement.layer.borderColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:244.0/255.0 alpha:1.0].CGColor;
    
    datePickerView.layer.borderWidth = 0.3;
    datePickerView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    self.selectedDate = [NSDate date];
    [self configureDatelable:self.selectedDate];
    
    [self.tblCardSettlement registerNib:[UINib nibWithNibName:@"CCbatchReportCell" bundle:nil] forCellReuseIdentifier:@"CCbatchReportCell"];
    self.datePicker.hidden = YES;
    datePickerView.hidden = YES;
    [self.datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    
    NSDate *date = [NSDate date];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSString *currentDate = [dateFormatter stringFromDate:date];
    
    [self GetCardData:currentDate];
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.cardSelectionPickerView.hidden = YES;
    //call didSelectRow of tableView again, by passing the touch to the super class
    [super touchesBegan:touches withEvent:event];
}

-(void)GetCardData :(NSString*)date
{
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"] forKey:@"BranchId"];
    [param setValue:date forKey:@"BillDate"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        [self ccBatchResponse:response error:error];
    };
    
    self.cCbatchDataWC = [self.cCbatchDataWC initWithRequest:KURL actionName:WSM_CC_BATCH_DATA params:param completionHandler:completionHandler];
}

-(void)ccBatchResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0)
            {
                [self configureDatelable:self.selectedDate];
                NSMutableArray *responeArray = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                self.cardDetail = [[NSMutableArray alloc]init];
                self.cardDetail = [responeArray mutableCopy];
                self.selectedCardName.text = @"All";
                [self getNumberOfcards:responeArray];
                [self.cardSelectionView setHidden:NO];
                
                self.lblTotalTransaction.text = [NSString stringWithFormat:@"Grand Total Count = %lu",(unsigned long)responeArray.count];
                
                self.lblTotalTicket.text = [NSString stringWithFormat:@"Average Ticket = %@",[self averageTransactionForAll]];
                self.lblTotalTransactionAmount.text = [self.rmsDbController applyCurrencyFomatter:[self totalTransactionForAll]];
                
                [self.cardSelectionPickerView reloadAllComponents];
            }
            else if ([[response valueForKey:@"IsError"] intValue] == 1)
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"No Record found." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                [self.cardSelectionView setHidden:YES];
                [self.cardSelectionPickerView setHidden:YES];
                self.selectedCardName.text = @"";
            }
        }
    }
}

-(NSString *)averageTransactionForAll
{
    NSMutableArray * cardCountDict = [self.cardDetail mutableCopy];
    NSNumber *sum=[cardCountDict valueForKeyPath:@"@sum.BillAmount"];
    NSString *str = [NSString stringWithFormat:@"%f",sum.floatValue];
    float averageTotal = str.floatValue / cardCountDict.count;
    return [NSString stringWithFormat:@"%.2f",averageTotal];
}
-(NSString *)totalTransactionForAll
{
    NSMutableArray * cardCountDict = [self.cardDetail mutableCopy];
    NSNumber *sum=[cardCountDict valueForKeyPath:@"@sum.BillAmount"];
    NSString *str = [NSString stringWithFormat:@"%.2f",sum.floatValue];
    return str;
}


-(void)getNumberOfcards :(NSMutableArray*)responseArray
{
    self.totalCardDisplayArray = [[NSMutableArray alloc]init];
    for (int i=0; i<responseArray.count; i++)
    {
        NSString *strCardType = [responseArray[i] valueForKey:@"CardType"];
        if (![self.totalCardDisplayArray containsObject:strCardType])
        {
            [self.totalCardDisplayArray addObject:strCardType];
        }
    }
    
    [self setCardarray];
    self.totalCardArray = [self.totalCardDisplayArray mutableCopy];
    [self.tblCardSettlement reloadData];
}

-(void)setCardarray
{
    self.cardDetailDisplayList = [[NSMutableArray alloc]init];
    for (int i=0; i<self.totalCardDisplayArray.count; i++)
    {
        [self setCardList:i];
    }
    self.cardDetailList = [self.cardDetailDisplayList mutableCopy];
}


-(void)setCardList :(int)index
{
    NSPredicate *cardType = [NSPredicate predicateWithFormat:@"CardType == %@", (self.totalCardDisplayArray)[index]];
    NSArray *cardArray = [[self.cardDetail filteredArrayUsingPredicate:cardType] mutableCopy ];
    NSMutableDictionary *cardDict = [[NSMutableDictionary alloc]init];
    cardDict[(self.totalCardDisplayArray)[index]] = cardArray;
    [self.cardDetailDisplayList addObject:cardDict];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self.selectedCardName.text isEqualToString:@"All"]) {
        return self.totalCardDisplayArray.count;
    }
    else
    {
    return self.cardDetailDisplayList.count;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([self.selectedCardName.text isEqualToString:@"All"]) {
        return nil;
    }
    else
    {
    UIView *headerView = [[UIView alloc]init];
    headerView.frame = CGRectMake(0, 0, tableView.frame.size.width, tableView.frame.size.height);
    
    CommonLabel *cardName = [[CommonLabel alloc]init];
    [cardName configureLable:CGRectMake(10, 30, 200, 25) withFontName:@"Helvetica" withFontSize:17.00 withTextAllignment:NSTextAlignmentLeft withTextColor:[UIColor blackColor]];
    cardName.text = (self.totalCardDisplayArray)[section];
    [headerView addSubview:cardName];
    
//    CommonLabel *totalTransaction = [[CommonLabel alloc]init];
//    [totalTransaction configureLable:CGRectMake(555, 15, 100, 40) withFontName:@"Helvetica" withFontSize:24.00 withTextAllignment:NSTextAlignmentRight withTextColor:[UIColor blackColor]];
//    totalTransaction.text = [NSString stringWithFormat:@"$%@",[self totalTransactionAtSection:section]];
//    [headerView addSubview:totalTransaction];
    
    return headerView;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if ([self.selectedCardName.text isEqualToString:@"All"])
    {
        return nil;
    }
    else
    {
        UIView *footerView = [[UIView alloc]init];
        footerView.frame = CGRectMake(0, 0, tableView.frame.size.width, tableView.frame.size.height);
        footerView.layer.borderWidth = 0.3;
        footerView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        
        UILabel *TotalTransaction = [[UILabel alloc] initWithFrame:CGRectMake(10, 10,200, 25)];
        TotalTransaction.textAlignment=NSTextAlignmentLeft;
        TotalTransaction.textColor = [UIColor blackColor];
        TotalTransaction.backgroundColor=[UIColor clearColor];
        TotalTransaction.font = [UIFont fontWithName:@"Helvetica" size:14.00];
        NSString *totalTransaction = [NSString stringWithFormat:@"Total Transaction = %ld",(long)[self numberofRowsAtSection:section]];
        TotalTransaction.text = [NSString stringWithFormat:@"%@",totalTransaction];
        [footerView addSubview:TotalTransaction];
        
        UILabel *avgTicket = [[UILabel alloc] initWithFrame:CGRectMake(200, 10,200, 25)];
        avgTicket.textAlignment=NSTextAlignmentLeft;
        avgTicket.textColor = [UIColor blackColor];
        avgTicket.backgroundColor=[UIColor clearColor];
        avgTicket.font = [UIFont fontWithName:@"Helvetica" size:14.00];
        NSString *averageTicket = [NSString stringWithFormat:@"Average Ticket = %@",[self averageTransactionAtSection:section]];
        avgTicket.text = [NSString stringWithFormat:@"%@",averageTicket];
        [footerView addSubview:avgTicket];
        
        CommonLabel *totalTransactionAmount = [[CommonLabel alloc]init];
        [totalTransactionAmount configureLable:CGRectMake(505, 2, 150, 40) withFontName:@"Helvetica" withFontSize:24.00 withTextAllignment:NSTextAlignmentRight withTextColor:[UIColor blackColor]];
        totalTransactionAmount.text = [self.rmsDbController applyCurrencyFomatter:[self totalTransactionAtSection:section]];
        [footerView addSubview:totalTransactionAmount];
        
        return footerView;
    }
}

-(NSString *)averageTransactionAtSection :(NSInteger)index
{
    NSMutableArray * cardCountDict = [(self.cardDetailDisplayList)[index] valueForKey:(self.totalCardDisplayArray)[index]];
    NSNumber *sum=[cardCountDict valueForKeyPath:@"@sum.BillAmount"];
    NSString *str = [NSString stringWithFormat:@"%f",sum.floatValue];
    float averageTotal = str.floatValue / cardCountDict.count;
    return [NSString stringWithFormat:@"%.2f",averageTotal];
}

-(NSString *)totalTransactionAtSection :(NSInteger)index
{
    NSMutableArray * cardCountDict = [(self.cardDetailDisplayList)[index] valueForKey:(self.totalCardDisplayArray)[index]];
    NSNumber *sum=[cardCountDict valueForKeyPath:@"@sum.BillAmount"];
    NSString *str = [NSString stringWithFormat:@"%.2f",sum.floatValue];
    return str;
}

-(NSInteger)numberofRowsAtSection :(NSInteger)index
{
    NSDictionary *cardTypeDictionary = (self.cardDetailDisplayList)[index];
    NSMutableArray *cardCountDict = [cardTypeDictionary valueForKey:(self.totalCardDisplayArray)[index]];
    return cardCountDict.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    for (int i=0; i<[self.totalCardDisplayArray count]; i++)
//    {
//        if (section == i)
//        {
//            int rows = [self numberofRowsAtSection:i];
//            return rows;
//        }
//    }
//    return 1;

    return [self numberofRowsAtSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([self.selectedCardName.text isEqualToString:@"All"]) {
        CGFloat height = 0.001;
        return height;
    }
    else
    {
    return 60;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)sectionh
{
    if ([self.selectedCardName.text isEqualToString:@"All"]) {
        CGFloat height = 0.001;
        return height;
    }
    else
    {
    return 45;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    CCbatchReportCell *cell = (CCbatchReportCell*)[tableView dequeueReusableCellWithIdentifier:@"CCbatchReportCell"];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor whiteColor];
    
    NSMutableArray * cardCountDict = [(self.cardDetailDisplayList)[indexPath.section] valueForKey:(self.totalCardDisplayArray)[indexPath.section]];
    cell.lblDate.text = [cardCountDict[indexPath.row] valueForKey:@"BillDate"];
    cell.accountNo.text = [cardCountDict[indexPath.row] valueForKey:@"AccNo"];
    cell.amount.text = [NSString stringWithFormat:@"%@",[cardCountDict[indexPath.row] valueForKey:@"BillAmount"]];
    cell.authCode.text = [NSString stringWithFormat:@"%@",[cardCountDict[indexPath.row] valueForKey:@"AuthCode"]];
    cell.invoice.text = [NSString stringWithFormat:@"%@",[cardCountDict[indexPath.row] valueForKey:@"RegisterInvNo"]];
    
    return cell;
}

-(IBAction)dateChanged:(id)sender
{
    self.selectedDate = self.datePicker.date;
}

-(IBAction)datePickerDone:(id)sender
{
    [self.rmsDbController playButtonSound];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSString *currentDate = [dateFormatter stringFromDate:self.selectedDate];
    // [self configureDatelable:self.selectedDate];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self GetCardData:currentDate];
    });
    self.datePicker.hidden = YES;
    datePickerView.hidden = YES;
}

-(IBAction)datePickerCancel:(id)sender
{
   [self.rmsDbController playButtonSound];
    self.datePicker.hidden = YES;
    datePickerView.hidden = YES;
}

-(IBAction)showDatePicker:(id)sender
{
    [self.rmsDbController playButtonSound];
    self.datePicker.hidden = NO;
    datePickerView.hidden = NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.cardSelectionPickerView.hidden = YES;
}

-(void)configureDatelable :(NSDate*)date
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    dateFormatter.dateFormat = @"MMMM dd, yyyy";
    NSString *lableDate = [dateFormatter stringFromDate:date];
    self.lblDate.text = lableDate;
}

#pragma mark - Card Selection 

-(IBAction)cardTypeSelectionClicked:(id)sender
{
    [self.cardSelectionPickerView setHidden:NO];
}

#pragma mark - UIPickerView Delegate

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* tView = (UILabel*)view;
    if (!tView){
        tView = [[UILabel alloc] init];
        tView.font = [UIFont fontWithName:@"Helvetica" size:14.00];
        tView.textAlignment = NSTextAlignmentCenter;
    }
    if(row == 0)
    {
        tView.text = @"All";
    }
    else
    {
        tView.text = (self.totalCardArray)[row-1];
    }
    return tView;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// Total rows in our component.
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.totalCardArray.count+1;
}

//- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
//    
//    NSString *title = [self.totalCardDisplayArray objectAtIndex:row];
//    return title;
//}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString *selectedCardType;
    
    if(row == 0)
    {
        selectedCardType = @"All";
        self.cardDetailDisplayList = [self.cardDetailList mutableCopy ];
        self.totalCardDisplayArray = [self.totalCardArray mutableCopy ];
    }
    else
    {
        selectedCardType = (self.totalCardArray)[row-1];
        NSDictionary *cardDetails = (self.cardDetailList)[row-1];
        NSArray *keys = cardDetails.allKeys;
        NSString *cardType = keys.firstObject;
        self.totalCardDisplayArray = [@[cardType] mutableCopy];
        self.cardDetailDisplayList = [@[@{cardType:[cardDetails valueForKey:cardType]} ]mutableCopy];
        //[cardTypeDictionary valueForKey:[self.totalCardDisplayArray objectAtIndex:index]]
    }
    self.selectedCardName.text = selectedCardType;
    self.cardSelectionPickerView.hidden = YES;
    [self.tblCardSettlement reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
