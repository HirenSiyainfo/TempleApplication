//
//  NotificationViewController.m
//  POSRetail
//
//  Created by Siya Infotech on 31/12/13.
//  Copyright (c) 2013 Nirav Patel. All rights reserved.
//

#import "NotificationViewController.h"
#import "RmsDbController.h"

@interface NotificationViewController ()

@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) RapidWebServiceConnection *updateNotificationDetailWC;

@property(nonatomic,strong)NSMutableArray *arrayNotification;
@property(nonatomic,strong)NSString *strUrlUpdate;

@end

@implementation NotificationViewController
@synthesize arrayNotification,strUrlUpdate;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
//aaa
- (void)viewDidLoad
{
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.updateNotificationDetailWC = [[RapidWebServiceConnection alloc] init];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrayNotification.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellStyle style =  UITableViewCellStyleDefault;
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
  
    
    UILabel * UrlUpdate= [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 320, 35)];
    UrlUpdate.font = [UIFont boldSystemFontOfSize:14];
    
    UrlUpdate.text= [NSString stringWithFormat:@"%@",[arrayNotification[indexPath.row] valueForKey:@"Details"]];
    
    
	UrlUpdate.numberOfLines = 0;
	UrlUpdate.textAlignment = NSTextAlignmentLeft;
	UrlUpdate.backgroundColor = [UIColor clearColor];
	UrlUpdate.textColor = [UIColor blackColor];
	[cell.contentView addSubview:UrlUpdate];

    
    
 /*   UILabel * Subject = [[UILabel alloc] initWithFrame:CGRectMake(170, 5, 50, 30)];
	Subject.text = @"Subject:";
	Subject.numberOfLines = 0;
	Subject.textAlignment = NSTextAlignmentLeft;
	Subject.backgroundColor = [UIColor clearColor];
	Subject.textColor = [UIColor blackColor];
	Subject.font = [UIFont systemFontOfSize:12];
	[cell.contentView addSubview:Subject];*/
    
    UILabel * lblSubject = [[UILabel alloc] initWithFrame:CGRectMake(10, 38, 190, 30)];
	lblSubject.text = [NSString stringWithFormat:@"%@",[arrayNotification[indexPath.row] valueForKey:@"Subject"]];
	lblSubject.numberOfLines = 0;
	lblSubject.textAlignment = NSTextAlignmentLeft;
	lblSubject.backgroundColor = [UIColor clearColor];
	lblSubject.textColor = [UIColor darkGrayColor];
	lblSubject.font = [UIFont systemFontOfSize:13];
	[cell.contentView addSubview:lblSubject];
//	[lblSubject release];

    
    
    /*UILabel * Date = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 50, 30)];
	Date.text = @"Date:";
	Date.numberOfLines = 0;
	Date.textAlignment = NSTextAlignmentLeft;
	Date.backgroundColor = [UIColor clearColor];
	Date.textColor = [UIColor blackColor];
	Date.font = [UIFont systemFontOfSize:12];
	[cell.contentView addSubview:Date];*/
    
    UILabel * taxTypeName = [[UILabel alloc] initWithFrame:CGRectMake(230, 38, 130, 30)];
   
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"MM/dd/yyyy";
    NSDate *now = [self.rmsDbController getDateFromJSONDate:[arrayNotification[indexPath.row] valueForKey:@"CreatedDate"]];
    NSString *dateString = [format stringFromDate:now];

	taxTypeName.text = dateString;
	taxTypeName.numberOfLines = 0;
	taxTypeName.textAlignment = NSTextAlignmentLeft;
	taxTypeName.backgroundColor = [UIColor clearColor];
	taxTypeName.textColor = [UIColor darkGrayColor];
	taxTypeName.font = [UIFont systemFontOfSize:13];
	[cell.contentView addSubview:taxTypeName];
//	[taxTypeName release];
	
    ((UILabel *)[cell.contentView viewWithTag:906]).text = dateString;
    

    
   /* UILabel * Url= [[UILabel alloc] initWithFrame:CGRectMake(170, 40, 30, 30)];
    Url.text=@"URL:";
	Url.numberOfLines = 0;
	Url.textAlignment = NSTextAlignmentRight;
	Url.backgroundColor = [UIColor clearColor];
	Url.textColor = [UIColor blackColor];
	Url.font = [UIFont systemFontOfSize:12];
	[cell.contentView addSubview:Url];
    */
    
    
    
    
   /* UILabel * CreatedBy = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, 70, 30)];
	CreatedBy.text = @"CreatedBy:";
	CreatedBy.numberOfLines = 0;
	CreatedBy.textAlignment = NSTextAlignmentLeft;
	CreatedBy.backgroundColor = [UIColor clearColor];
	CreatedBy.textColor = [UIColor blackColor];
	CreatedBy.font = [UIFont systemFontOfSize:12];
	[cell.contentView addSubview:CreatedBy];
    
    UILabel * CreatedByName = [[UILabel alloc] initWithFrame:CGRectMake(75, 40, 150, 30)];
	CreatedByName.text = [NSString stringWithFormat:@"%@",[[arrayNotification objectAtIndex:indexPath.row] valueForKey:@"CreatedBy"]];
	CreatedByName.numberOfLines = 0;
	CreatedByName.textAlignment = NSTextAlignmentLeft;
	CreatedByName.backgroundColor = [UIColor clearColor];
	CreatedByName.textColor = [UIColor blackColor];
	CreatedByName.font = [UIFont systemFontOfSize:12];
	[cell.contentView addSubview:CreatedByName];*/

     return cell;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 70;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger strType = [[arrayNotification[indexPath.row] valueForKey:@"Type"] integerValue];
    if(strType==0)
    {
     //   NSString *strNotificationId=[[arrayNotification objectAtIndex:indexPath.row] valueForKey:@"NotificationId"];
        self.strUrlUpdate=[NSString stringWithFormat:@"%@",[arrayNotification[indexPath.row] valueForKey:@"Details"]];
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:self.strUrlUpdate]];

       // [self UpdateNotification:strNotificationId];
    }
}

-(void)UpdateNotification:(NSString *)strNotificationId
{
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setValue:(self.rmsDbController.globalDict)[@"BranchID"]forKey:@"BranchId"];
    [param setValue:strNotificationId forKey:@"NotificationId"];
    
    CompletionHandler completionHandler = ^(id response, NSError *error) {
        [self UpdateNotificationResultResponse:response error:error];
    };
    
    self.updateNotificationDetailWC = [self.updateNotificationDetailWC initWithRequest:KURL actionName:WSM_UPDATE_NOTIFICATION_DETAIL params:param completionHandler:completionHandler];
}

-(void)UpdateNotificationResultResponse:(id)response error:(NSError *)error
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.strUrlUpdate]];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
