//
//  TicketValidationDetail.m
//  RapidRMS
//
//  Created by siya-IOS5 on 6/25/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "TicketValidationDetail.h"
#import "RmsDbController.h"
#import "TicketValidationPassDetail.h"
#import "TicketValidationSubDetailCell.h"

@interface TicketValidationDetail ()
{
    NSArray *enumArrayForTicketValidationDetail;
}
@property (nonatomic, weak) IBOutlet UITableView *ticketValidationDetailTabelView;
@property (nonatomic, weak) IBOutlet UIView *headerView;
@property (nonatomic, weak) IBOutlet UILabel *headerTitle;
@property (nonatomic, weak) IBOutlet UIButton *doneButton;

@property (nonatomic,strong) RmsDbController *rmsDbController;
@property (nonatomic,strong) RapidWebServiceConnection *itemTicketValidationCountServiceConnection;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@end
@implementation TicketValidationDetail


- (void)viewDidLoad
{
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.itemTicketValidationCountServiceConnection = [[RapidWebServiceConnection alloc]init];

    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
     enumArrayForTicketValidationDetail = @[@(TicketValidationPassDetails),
                                            @(TicketValidationDate),@(TicketValidationPurchaseDate),@(TicketValidationLastVisitDate),@(TicketValidationRemark)];
    
    NSArray *status = [self colorForPassType:self.validationDetailRapidPass.validityStatus.integerValue];
    if (status.count > 0) {
        _headerView.backgroundColor = status[0];
        _headerTitle.text = [NSString stringWithFormat:@"%@",status[1]].uppercaseString ;
    }
  
    [_ticketValidationDetailTabelView reloadData];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return enumArrayForTicketValidationDetail.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat headerHeight = 44.0;
    
    TicketValidationDetailType ticketValidationDetailType =  [enumArrayForTicketValidationDetail[indexPath.row] integerValue];
    switch (ticketValidationDetailType) {
        case TicketValidationPassDetails:
            headerHeight = 233;
            break;
            
        case   TicketValidationDate:
            headerHeight = 55;
            break;
            
        case   TicketValidationPurchaseDate:
        case   TicketValidationLastVisitDate:
        case TicketValidationRemark:
            headerHeight = 46;
            break;
            default:
            break;
    }
    return headerHeight;
}

-( NSArray *)colorForPassType:(PassStatus)passStatus
{
    UIColor *backGroundColor;
    NSString *validityStatus = @"";
    switch (passStatus) {
        case Valid:
            backGroundColor = [UIColor greenColor];
            validityStatus = @"Valid";
            
            break;
        case Invalid:
            backGroundColor = [UIColor redColor];
            validityStatus = @"Invalid";
            _doneButton.enabled = NO;
            break;
         case SameDay:
            validityStatus = @"SameDay";
            backGroundColor = [UIColor greenColor];
            break;
        case Expired:
            backGroundColor = [UIColor redColor];
            validityStatus = @"Expired";
            _doneButton.enabled = NO;
            break;
        default:
            backGroundColor = [UIColor clearColor] ;
            break;
    }
    return @[backGroundColor,validityStatus];
}

-(TicketValidationPassDetail *)configureTicketValidationPassDetail:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TicketValidationPassDetail *ticketValidationPassDetail = [tableView dequeueReusableCellWithIdentifier:@"TicketValidationPassDetail"];
    [ticketValidationPassDetail updateCellWithPassDetail:self.validationDetailRapidPass];
    return ticketValidationPassDetail;
}
-(TicketValidationSubDetailCell *)configureTicketValidationSubDetailCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
                                                                  ForKey:(NSString *)keyName forValue:(NSString *)value withIdentifier:(NSString *)identiFier
{
    TicketValidationSubDetailCell *ticketValidationSubDetailCell = [tableView dequeueReusableCellWithIdentifier:identiFier];
    if ([identiFier isEqualToString:@"TicketValidationSubDetailRow"]) {
        ticketValidationSubDetailCell.key.text = keyName;
        ticketValidationSubDetailCell.value.text = value;
    }
    else
    {
        ticketValidationSubDetailCell.key.text = keyName;
    }
   
    return ticketValidationSubDetailCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BaseCell"];
    cell.backgroundColor = [UIColor clearColor];

    TicketValidationDetailType ticketValidationDetailType = [enumArrayForTicketValidationDetail[indexPath.row] integerValue];
    
    NSString *keyName = @"";
    NSString *value = @"";
    
    switch (ticketValidationDetailType) {
        case   TicketValidationPassDetails:
            break;
       
        case   TicketValidationPurchaseDate:
            keyName = @"Purchase Date";
            value = self.validationDetailRapidPass.purchaseDate;
            break;
        case   TicketValidationLastVisitDate:
            keyName = @"LastVisit Date";
            value = self.validationDetailRapidPass.lastVisitDateTime;
            break;
        case   TicketValidationRemark:
            keyName = @"Remark";
            value = @"";
            break;
        case   TicketValidationDate:
            keyName = @"Date";
            value = @"";
            break;
    }
  
    
    switch (ticketValidationDetailType) {
        case   TicketValidationPassDetails:
            cell = [self configureTicketValidationPassDetail:tableView cellForRowAtIndexPath:indexPath];
            break;
            
        case   TicketValidationPurchaseDate:
        case   TicketValidationLastVisitDate:
        case   TicketValidationRemark:
            cell = [self configureTicketValidationSubDetailCell:tableView cellForRowAtIndexPath:indexPath ForKey:keyName forValue:value withIdentifier:@"TicketValidationSubDetailRow"];
            break;
            
        case   TicketValidationDate:
            cell = [self configureTicketValidationSubDetailCell:tableView cellForRowAtIndexPath:indexPath ForKey:keyName forValue:value withIdentifier:@"TicketValidationSubDetailSection"];
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

-(IBAction)doneButton:(id)sender
{
    [self addInvTicketDetail];
}
-(void)addInvTicketDetail
{
    
    _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
    
    NSMutableDictionary *itemparam=[[NSMutableDictionary alloc]init];
    
    NSMutableDictionary *dict =[[NSMutableDictionary alloc]init];
    dict[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    dict[@"RegisterId"] = (self.rmsDbController.globalDict)[@"RegisterId"];
    dict[@"UserId"] = [[self.rmsDbController.globalDict valueForKey:@"UserInfo"] valueForKey:@"UserId"];
    dict[@"TicketInvId"] = self.validationDetailRapidPass.passTicketId;
    
    if (self.validationDetailRapidPass.validityStatus.integerValue == SameDay ) {
        dict[@"Days"] = @"0";
     }
    else
    {
        dict[@"Days"] = @"1";
    }
    dict[@"ZId"] = [self.rmsDbController.globalDict valueForKey:@"ZId"];
    dict[@"Remarks"] = @"";

    NSDate * date = [NSDate date];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/yyyy HH:mm:ss";
    dict[@"Date"] = [dateFormatter stringFromDate:date];
    
    itemparam[@"InvTicketDetail"] = dict;
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self responseAddInvTicketDetailResponse:response error:error];
        });
    };
    
    self.itemTicketValidationCountServiceConnection = [self.itemTicketValidationCountServiceConnection initWithRequest:KURL actionName:WSM_ADD_INVOICE_TICKET_DETAILS params:itemparam completionHandler:completionHandler];

}

-(void)responseAddInvTicketDetailResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            [self.ticketValidationDetailDelegate hideTicketValidationDetail];

        }
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
