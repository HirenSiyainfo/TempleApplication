//
//  PODateSelection.m
//  RapidRMS
//
//  Created by Siya10 on 13/10/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "PODateSelection.h"

@interface PODateSelection ()<UIGestureRecognizerDelegate>
{
    NSInteger selecteDateFormate;
}
@property(nonatomic,weak)IBOutlet UILabel *lblFromDate;
@property(nonatomic,weak)IBOutlet UILabel *lblToDate;
@property(nonatomic,weak)IBOutlet UIButton *closeBtn;
@property(nonatomic,weak)IBOutlet UIButton *submitBtn;
@property(nonatomic,weak)IBOutlet UIDatePicker *datetime;
@property(nonatomic,weak)IBOutlet UIView *viewBGDatePicker;
@property(nonatomic,strong)NSString *predefinedDateRange;
@end

@implementation PODateSelection
@synthesize pODateSelectionDelegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.datetime setValue:[UIColor whiteColor] forKey:@"textColor"];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"];
    [self.datetime setLocale:locale];
    
    [self.datetime setValue:[UIColor whiteColor] forKey:@"textColor"];
    SEL selector = NSSelectorFromString(@"setHighlightsToday:");
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDatePicker instanceMethodSignatureForSelector:selector]];
    BOOL no = NO;
    [invocation setSelector:selector];
    [invocation setArgument:&no atIndex:2];
    [invocation invokeWithTarget:self.datetime];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidePopupIphoneView)];
    [tapRecognizer setNumberOfTapsRequired:1];
    [tapRecognizer setDelegate:self];
    [self.view addGestureRecognizer:tapRecognizer];
    
}
- (void)hidePopupIphoneView {
    [self.pODateSelectionDelegate didCancelDateRange];
}

#pragma mark - Display Date Picker

-(IBAction)displayDatePicker:(UIButton *)sender
{
    self.viewBGDatePicker.hidden = NO;
    selecteDateFormate = [sender tag];
}

-(IBAction)selectPredefinedDateRange:(id)sender{
    
    [self selectDateFormate:(UIButton *)sender];
    switch ([sender tag]) {
            case 11:
            {
                self.predefinedDateRange = @"None";
            }
            break;
        case 12:
            {
                self.predefinedDateRange = @"Daily";
            }
            break;
        case 13:
            {
                self.predefinedDateRange = @"Weekly";
            }
            break;
        case 14:
            {
                self.predefinedDateRange = @"Monthly";
            }
            break;
        case 15:
            {
                self.predefinedDateRange = @"Quarterly";
            }
            break;
        case 16:
        {
            self.predefinedDateRange = @"Yearly";
        }
            break;
        default:
            break;
    }
}

-(IBAction)dateValueChange:(id)sender{
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/yyyy";
    if(selecteDateFormate == 1){
        
        self.lblFromDate.text = [dateFormatter stringFromDate:self.datetime.date];
        
    }
    else{
        self.lblToDate.text = [dateFormatter stringFromDate:self.datetime.date];
    }
     self.viewBGDatePicker.hidden = YES;
    
}

-(IBAction)hideDateSelection:(id)sender{
    
    [self.pODateSelectionDelegate didCancelDateRange];
}
-(IBAction)submitDateSelection:(id)sender{
    
    if(self.lblFromDate.text.length>0 && self.lblToDate.text.length>0){
        
        [self.pODateSelectionDelegate didSubmitwithDate:self.lblFromDate.text toDate:self.lblToDate.text];

    }
    else{
        [self.pODateSelectionDelegate didSubmitwithTimeRange:self.predefinedDateRange];
 
    }
}

-(void)selectDateFormate:(UIButton *)button{

    UIButton *btnNone = [self.view viewWithTag:11];
    btnNone.titleLabel.textColor = [UIColor whiteColor];
    UIButton *btnDaily = [self.view viewWithTag:12];
    btnDaily.titleLabel.textColor = [UIColor whiteColor];

    UIButton *btnWeekly = [self.view viewWithTag:13];
    btnWeekly.titleLabel.textColor = [UIColor whiteColor];

    UIButton *btnMonthly = [self.view viewWithTag:14];
    btnMonthly.titleLabel.textColor = [UIColor whiteColor];

    UIButton *btnQuarterly = [self.view viewWithTag:15];
     btnQuarterly.titleLabel.textColor = [UIColor whiteColor];
    UIButton *btnYearly = [self.view viewWithTag:16];
    btnYearly.titleLabel.textColor = [UIColor whiteColor];
    
    UIButton *btn = button;
    
    [btn setTitleColor:[UIColor colorWithRed:255.0/255.0 green:155.0/255.0 blue:51.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    
    //[btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    
   // btn.titleLabel.textColor = [UIColor colorWithRed:255/255 green:155/255 blue:51/255 alpha:1.0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
