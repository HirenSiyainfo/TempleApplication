//
//  LoadingViewController.m
//  POSRetail
//
//  Created by siya-IOS5 on 3/26/14.
//  Copyright (c) 2014 Nirav Patel. All rights reserved.
//

#import "LoadingViewController.h"
#import "RmsDbController.h"

@interface LoadingViewController ()
{
    NSMutableArray *arraySteps;
    IntercomHandler *intercomHandler;
    NSLock *operationLock;

}

@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, weak) IBOutlet UILabel *lblPercentage;
@property (nonatomic, weak) IBOutlet UILabel *lblPeaseWait;
@property (nonatomic, weak) IBOutlet UIProgressView *downLoadView;
@property (nonatomic, weak) IBOutlet UITableView *tblStepWiseProcess;
@property (nonatomic, weak) IBOutlet UILabel *lblProgressText;
@property (nonatomic, weak) IBOutlet UILabel *configurationMessageLabel;
@property (nonatomic, weak) IBOutlet UIButton *btnRetry;
@property (nonatomic, weak) IBOutlet UIButton *btnIntercom;

@end

@implementation LoadingViewController
@synthesize startingTime;
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
    [_downLoadView  setHidden:YES];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    [self.btnRetry setHidden:YES];
    arraySteps = [[NSMutableArray alloc]init];
    
    intercomHandler = [[IntercomHandler alloc] initWithButtton:_btnIntercom normalImage:@"helpbtn_blackbtn.png" selectedImage:@"dr_helpbtnselected.png" withViewController:self];

    NSMutableDictionary *step1Dict = [@{
                                                @"stepmsg":@"Inventory Data Download",
                                                @"status":@"",
                                                @"duration":@"",
                                                @"progress":@"",
                                                } mutableCopy ];
    
    [arraySteps addObject:[step1Dict mutableCopy ]];
    
    NSMutableDictionary *step2Dict = [@{
                                        @"stepmsg":@"Inventory Data Configuration",
                                        @"status":@"",
                                        @"duration":@"",
                                        @"progress":@"",
                                        } mutableCopy ];
    
    [arraySteps addObject:[step2Dict mutableCopy ]];
    
    NSMutableDictionary *step3Dict = [@{
                                        @"stepmsg":@"Master Data Download",
                                        @"status":@"",
                                        @"duration":@"",
                                        @"progress":@"",
                                        } mutableCopy ];
    
    [arraySteps addObject:[step3Dict mutableCopy ]];
    
    NSMutableDictionary *step4Dict = [@{
                                        @"stepmsg":@"Master Data Configuration",
                                        @"status":@"",
                                        @"duration":@"",
                                        @"progress":@"",
                                        } mutableCopy ];
    
    [arraySteps addObject:[step4Dict mutableCopy ]];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downLoadProgressData:) name:kDownLoadProgressNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(configurationMessageNotification:) name:kConfigurationMessageNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(configurationDownloadProgressMessageNotification:) name:kConfigurationDownloadStatusMessageNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setpwiseconfigurationMessageNotification:) name:kStepWiseConfigurationMessageNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setpwiseprogressNotification:) name:kStepWiseProgressNotification object:nil];

    // Do any additional setup after loading the view from its nib.
}
- (void)viewWillAppear:(BOOL)animated{
    [self.rmsDbController addEventForMasterUpdateWithKey:kMasterUpdateView];
    
}
-(void)downLoadProgressData:(NSNotification *)notification
{
      NSNumber *num = notification.object;
      self.lblProgressText.text = [NSString stringWithFormat:@"%.f%%",num.floatValue*100];
      [_downLoadView setProgress:num.floatValue animated:YES];
}

-(void)configurationMessageNotification:(NSNotification *)notification
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
    
        _lblPeaseWait.text = @"Please Wait";
        if([[notification.userInfo valueForKey:@"Configuration Status"] integerValue ] == 1)
        {
            self.configurationMessageLabel.textColor = [UIColor redColor];
            [self.btnRetry setHidden:NO];
            [_lblPeaseWait setHidden:YES];
        }
        else
        {
            self.configurationMessageLabel.textColor = [UIColor colorWithRed:138.0/255.0 green:138.0/255.0 blue:138.0/255.0 alpha:1.0];
            [_lblPeaseWait setHidden:NO];
        }
        NSString *message = [notification.userInfo valueForKey:@"Configuration Message"];
        self.configurationMessageLabel.text = message;
    });
}


-(void)configurationDownloadProgressMessageNotification:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
    
        NSString *message = [notification.userInfo valueForKey:@"Configuration Message"];
        _lblPeaseWait.text = message;
    });
}



-(void)setpwiseconfigurationMessageNotification:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if([[notification.userInfo valueForKey:@"SetpWiseConfiguration Status"] integerValue ] == 1)
        {
            //self.configurationMessageLabel.textColor = [UIColor redColor];
        }
        else
        {
            
            
            //self.configurationMessageLabel.textColor = [UIColor colorWithRed:138.0/255.0 green:138.0/255.0 blue:138.0/255.0 alpha:1.0];
        }
        NSString *stepwisemessage = [notification.userInfo valueForKey:@"SetpWiseConfiguration Message"];
        
        if(stepwisemessage.integerValue>=1)
        {
            NSInteger index = stepwisemessage.integerValue;
            NSMutableDictionary *dict= arraySteps[index-1];
            dict[@"status"] = @"done";
            
            double duration = [self calculateTimeDuration:startingTime date2:[notification.userInfo valueForKey:@"SetpWiseConfiguration Duration"]];
            
            startingTime=[notification.userInfo valueForKey:@"SetpWiseConfiguration Duration"];

            dict[@"duration"] = [NSString stringWithFormat:@"%.2f",duration];
            
            
        }
        else{
            NSInteger index = labs(stepwisemessage.integerValue);
            NSMutableDictionary *dict= arraySteps[index-1];
            dict[@"status"] = @"fail";
            
            double duration = [self calculateTimeDuration:startingTime date2:[notification.userInfo valueForKey:@"SetpWiseConfiguration Duration"]];
            startingTime=[notification.userInfo valueForKey:@"SetpWiseConfiguration Duration"];
            
            dict[@"duration"] = [NSString stringWithFormat:@"%.2f",duration];
            
        }
        [_tblStepWiseProcess reloadData];
        
       // self.configurationMessageLabel.text = message;
    });
}

-(void)setpwiseprogressNotification:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if([[notification.userInfo valueForKey:@"SetpWiseConfiguration Status"] integerValue ] == 1)
        {
            //self.configurationMessageLabel.textColor = [UIColor redColor];
        }
        else
        {
            // 
            //self.configurationMessageLabel.textColor = [UIColor colorWithRed:138.0/255.0 green:138.0/255.0 blue:138.0/255.0 alpha:1.0];
        }
        NSString *stepwisemessage = [notification.userInfo valueForKey:@"SetpWiseConfiguration Message"];
        _downLoadView.progress = [[notification.userInfo valueForKey:@"SetpWiseItemUpdate Progress"]floatValue] / 100;
        _lblPercentage.text=[NSString stringWithFormat:@"%.f%%", _downLoadView.progress*100];
        if([[notification.userInfo valueForKey:@"SetpWiseItemUpdate Progress"] floatValue] >= 100.0f){
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [_downLoadView  setHidden:YES];
                [_lblPercentage setHidden:YES];
                [_lblPeaseWait setHidden:NO];
            });
            
        }
        else{
            [_downLoadView  setHidden:NO];
            [_lblPercentage setHidden:NO];
             [_lblPeaseWait setHidden:YES];
        }
        
        if(stepwisemessage.integerValue>=1)
        {
            NSInteger index = stepwisemessage.integerValue;
            NSMutableDictionary *dict= arraySteps[index-1];
            
            dict[@"progress"] = [NSString stringWithFormat:@"%ld",(long)[[notification.userInfo valueForKey:@"SetpWiseItemUpdate Progress"]integerValue]];
            
            
        }
        else{
            NSInteger index = labs(stepwisemessage.integerValue);
            NSMutableDictionary *dict= arraySteps[index-1];
            dict[@"status"] = @"fail";
            dict[@"progress"] = [NSString stringWithFormat:@"%ld",(long)[[notification.userInfo valueForKey:@"SetpWiseItemUpdate Progress"]integerValue]];
            
        }
        [_tblStepWiseProcess reloadData];
        
        // self.configurationMessageLabel.text = message;
    });
}

-(double)calculateTimeDuration:(NSDate *)pdate1 date2:(NSDate *)pdate2{
    
    NSDate* date1 = startingTime;
    NSDate* date2 = pdate2;
    NSTimeInterval distanceBetweenDates = [date2 timeIntervalSinceDate:date1];

   // double hoursBetweenDates = distanceBetweenDates / 60;
    
    return distanceBetweenDates;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    return 80.0;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return arraySteps.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCellStyle style =  UITableViewCellStyleDefault;
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"];
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor=[UIColor clearColor];
    
    UILabel *lbltemp = (UILabel *)[cell viewWithTag:600];
    [lbltemp removeFromSuperview];
    
    UILabel *lbltemp2 = (UILabel *)[cell viewWithTag:601];
    [lbltemp2 removeFromSuperview];
    
    NSMutableDictionary *dict = arraySteps[indexPath.row];
    
    UILabel *lblSetpName = [[UILabel alloc]initWithFrame:CGRectMake(10.0, 15.0, 300.0, 20.0)];
    //[lblSetpName setText:[dict valueForKey:@"stepmsg"]];
    
    NSString *lblStep;
    
    if([[dict valueForKey:@"progress"] integerValue]>0)
    {
         lblStep = [NSString stringWithFormat:@"%@     %@%%",[dict valueForKey:@"stepmsg"],[dict valueForKey:@"progress"]];
    }
    else{
        lblStep = [NSString stringWithFormat:@"%@     %@",[dict valueForKey:@"stepmsg"],[dict valueForKey:@"progress"]];

    }

    lblSetpName.text = lblStep;
    
    if([[dict valueForKey:@"status"] isEqualToString:@"done"])
    {
        lblSetpName.textColor = [UIColor colorWithRed:21.0/255.0 green:172.0/255.0 blue:127.0/255.0 alpha:1.0];
    }
    else if([[dict valueForKey:@"status"] isEqualToString:@"fail"])
    {
        lblSetpName.textColor = [UIColor redColor];
    }
    else{
        
        lblSetpName.textColor = [UIColor blackColor];

    }
    lblSetpName.tag = 600;
    lblSetpName.backgroundColor=[UIColor clearColor];
    [cell addSubview:lblSetpName];
    
    UILabel *lblStepStatus = [[UILabel alloc]initWithFrame:CGRectMake(10.0, 44.0, 300.0, 20.0)];
  
    if([[dict valueForKey:@"status"] isEqualToString:@"done"])
    {
          lblStepStatus.text = [NSString stringWithFormat:@"%@ seconds",[dict valueForKey:@"duration"]];
        lblStepStatus.textColor = [UIColor colorWithRed:21.0/255.0 green:172.0/255.0 blue:127.0/255.0 alpha:1.0];
    }
    else if([[dict valueForKey:@"status"] isEqualToString:@"fail"])
    {
          lblStepStatus.text = [NSString stringWithFormat:@"%@ seconds",[dict valueForKey:@"duration"]];
        lblStepStatus.textColor = [UIColor redColor];
    }
    else{
    
        lblStepStatus.textColor = [UIColor blackColor];
        
    }
    lblStepStatus.backgroundColor = [UIColor clearColor];
    lblStepStatus.tag = 601;
    [cell addSubview:lblStepStatus];
    
    return cell;
}

-(IBAction)retryClick:(id)sender{
    
    [self.rmsDbController resumeConfiguration];
    [self.btnRetry setHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDownLoadProgressNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kConfigurationMessageNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kStepWiseConfigurationMessageNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kStepWiseProgressNotification object:nil];
    
    
}

@end
