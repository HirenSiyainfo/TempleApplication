//
//  AgeVerificationVC.m
//  RapidRMS
//
//  Created by siya-IOS5 on 8/5/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "AgeVerificationVC.h"
#import "RmsDbController.h"
@interface AgeVerificationVC ()
{
    BOOL btxtMonth;
    BOOL btxtDay;
    BOOL btxtYear;
}

@property (nonatomic, weak) IBOutlet UITextField *txtMonth;
@property (nonatomic, weak) IBOutlet UITextField *txtDay;
@property (nonatomic, weak) IBOutlet UITextField *txtYear;
@property (nonatomic, weak) IBOutlet UILabel *lblAgeDate;
@property (nonatomic, weak) IBOutlet UIButton *btnAgeCheckClicked;
@property (nonatomic, weak) IBOutlet UILabel * lblmonthDate;
@property (nonatomic, weak) IBOutlet UILabel *lbldayDate;
@property (nonatomic, weak) IBOutlet UILabel *lblyearDate;
@property (nonatomic, weak) IBOutlet UILabel *ageLimit;

@property (nonatomic, strong) RmsDbController *rmsDbController;

@end

@implementation AgeVerificationVC

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
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    btxtMonth=YES;
    btxtDay=NO;
    btxtYear=NO;
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setbirthdate:self.age.integerValue];
    _ageLimit.text = self.age;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)setbirthdate:(NSInteger)sage
{
    NSDate *todayDate = [NSDate date];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.year = -sage;
    NSDate *afterSevenDays = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:todayDate options:0];
    NSDateFormatter *dateFormat1 = [[NSDateFormatter alloc] init];
    dateFormat1.dateFormat = @"MM-dd-yyyy";
    NSString *result = [dateFormat1 stringFromDate:afterSevenDays];
    
    NSArray *myArray = [result componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-"]];
    _lblmonthDate.text=[NSString stringWithFormat:@"%@",myArray[0]];
    _lbldayDate.text=[NSString stringWithFormat:@"%@",myArray[1]];
    _lblyearDate.text=[NSString stringWithFormat:@"%@",myArray[2]];
}


-(IBAction)ageYes:(id)sender
{
    [self.ageVerificationDelegate didVerifiedAge];
}
-(IBAction)ageNo:(id)sender
{
    [self.ageVerificationDelegate didDeclineAge];
}

- (IBAction) ageRestrickedKeyPadButton:(id)sender
{
	if ([sender tag] >= 0 && [sender tag] < 10) {
        
        if(btxtMonth){
            [self dateDispay:_txtMonth tag:[sender tag]];
        }
        else if(btxtDay){
            [self dateDispay:_txtDay tag:[sender tag]];
            
        }
        else if(btxtYear){
            [self dateDispay:_txtYear tag:[sender tag]];
            
        }
        
	} else if ([sender tag] == -99) {
        _txtMonth.text=@"";
        _txtMonth.placeholder=@"MM";
        _txtDay.text=@"";
        _txtDay.placeholder=@"DD";
        _txtYear.text=@"";
        _txtYear.placeholder=@"YYYY";
        btxtMonth=YES;
        btxtDay=NO;
        btxtYear=NO;
        [_btnAgeCheckClicked setImage:nil forState:UIControlStateNormal];
        
	} else if ([sender tag] == 101) {
        
        if(btxtYear){
            
            [self dateDispay:_txtYear tag:[sender tag]];
            
        }
	}
}

-(void)dateDispay:(UITextField *)txtField tag:(NSInteger)ptag{
    
    if(txtField==_txtMonth)
    {
        if(txtField.text.length<2)
        {
            NSString * displyValue;
            
            displyValue = [txtField.text stringByAppendingFormat:@"%ld",(long)ptag];
            txtField.text = displyValue;
            
            if (txtField.text.length >= 2)
            {
                if(txtField.text.intValue > 12)
                {
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please Enter Correct Date." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                }
                else
                {
                    //hiten
                    //[txtDay becomeFirstResponder];
                    if(txtField.text.length>3)
                    {
                        _txtDay.text = displyValue;
                    }
                    else if(txtField.text.length==2){
                        
                        btxtDay=YES;
                        btxtYear=NO;
                        btxtMonth=NO;
                    }
                    
                    
                }
            }
        }
        
    }
    else if(txtField==_txtDay){
        
        if(txtField.text.length<2)
        {
            
            NSString * displyValue;
            displyValue = [txtField.text stringByAppendingFormat:@"%ld",(long)ptag];
            txtField.text = displyValue;
            
            
            if (txtField.text.length >= 2)
            {
                if(txtField.text.intValue > 31)
                {
                    UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                    {
                    };
                    [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please Enter Correct Date." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                    
                }
                else
                {
                    //hiten
                    //[txtDay becomeFirstResponder];
                    if(txtField.text.length>3)
                    {
                        _txtDay.text = displyValue;
                    }
                    else if(txtField.text.length==2){
                        
                        btxtDay=NO;
                        btxtYear=YES;
                        btxtMonth=NO;
                    }
                }
            }
        }
        
    }
    else if(txtField==_txtYear){
        
        if(txtField.text.length<4)
        {
            NSString * displyValue;
            if(ptag==101)
            {
                NSString *strpTag = @"00";
                displyValue = [txtField.text stringByAppendingFormat:@"%@",strpTag];
                txtField.text = displyValue;
                
            }
            else{
                displyValue = [txtField.text stringByAppendingFormat:@"%ld",(long)ptag];
                txtField.text = displyValue;
                
            }
            if (txtField.text.length == 4)
            {
                [self btnAgeCalcClick:nil];
                
            }
            else if(txtField.text.length > 4)
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Invalid year" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
            }
        }
        else
        {
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Invalid year" buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        }
    }
}
- (IBAction)btnAgeCalcClick:(UIButton *)sender
{
    if(_txtMonth.text.intValue > 12)
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please Enter Correct Date." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        return;
    }
    else if(_txtDay.text.intValue > 31)
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please Enter Correct Date." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        return;
    }
    else
    {
        [self ageCalc:_txtDay.text :_txtMonth.text :_txtYear.text];
    }
}

-(void) ageCalc:(NSString *)sDay :(NSString *)sMonth :(NSString *)sYear
{
    if(![sDay isEqualToString:@""] && ![sMonth isEqualToString:@""] && ![sYear isEqualToString:@""])
    {
        NSString *dateStr=[NSString stringWithFormat:@"%@%@%@",sYear,sMonth,sDay];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        dateFormat.dateFormat = @"yyyyMMdd";
        NSDate *date = [dateFormat dateFromString:dateStr];
        
        NSDate *currentdate=[NSDate date];
        NSDateFormatter *dateFormat1 = [[NSDateFormatter alloc] init];
        dateFormat1.dateFormat = @"yyyyMMdd";
        NSString *result = [dateFormat1 stringFromDate:currentdate];
        NSDate *date2 = [dateFormat1 dateFromString:result];
        
        NSTimeInterval interval = [date2 timeIntervalSinceDate:date];
        
        // Get the system calendar
        NSCalendar *sysCalendar = [NSCalendar currentCalendar];
        
        // Create the NSDates
        NSDate *date3 = [[NSDate alloc] initWithTimeInterval:interval sinceDate:date];
        
        // Get conversion to months, days, hours, minutes
        unsigned int unitFlags = NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear;
        
        NSDateComponents *breakdownInfo = [sysCalendar components:unitFlags fromDate:date  toDate:date3  options:0];
        
        _lblAgeDate.hidden = NO;
        _lblAgeDate.text= [NSString stringWithFormat:@"Customer Age is %ld Years ",(long)breakdownInfo.year];
        
        if(breakdownInfo.year >= self.age.integerValue)
        {
            _lblAgeDate.textColor = [UIColor blackColor];
            [_btnAgeCheckClicked setImage:[UIImage imageNamed:@"DeviceActiveArrow.png"] forState:UIControlStateNormal];
            [self.ageVerificationDelegate didVerifiedAge];

        }
        else
        {
            _lblAgeDate.textColor = [UIColor redColor];
            UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
            {
            };
            [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Customer is NOT 21+ or 18+." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];

            [_btnAgeCheckClicked setImage:[UIImage imageNamed:@"NotAgeVerificationIcon.png"] forState:UIControlStateNormal];
        }
    }
    else
    {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please Enter Correct Date." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
    }
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if (textField == _txtMonth)
    {
        if (_txtMonth.text.length == 2 && range.length == 0)
        {
            if(_txtMonth.text.intValue > 12)
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please Enter Correct Date." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                
                return NO;
            }
            else
            {
                //hiten
                //[txtDay becomeFirstResponder];
                _txtDay.text = string;
                return NO;
            }
        }
    }
    if (textField == _txtDay)
    {
        if (_txtDay.text.length == 2 && range.length == 0)
        {
            if(_txtDay.text.intValue > 31)
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:@"Please Enter Correct Date." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
                return NO;
            }
            else
            {
                _txtYear.text = string;
                return NO;
            }
        }
        
    }
    if (textField == _txtYear)
    {
        if (_txtYear.text.length == 3 && range.length == 0)
        {
            _txtYear.text = [_txtYear.text stringByAppendingString:string];
            [_txtYear resignFirstResponder];
            [self btnAgeCalcClick:nil];
            return NO;
        }
        
    }
    
     return YES;
}
-(IBAction)ageClearAction:(id)sender
{
    _txtMonth.text=@"";
    _txtMonth.placeholder=@"MM";
    _txtDay.text=@"";
    _txtDay.placeholder=@"DD";
    _txtYear.text=@"";
    _txtYear.placeholder=@"YYYY";
    btxtMonth=YES;
    btxtDay=NO;
    btxtYear=NO;
    [_btnAgeCheckClicked setImage:nil forState:UIControlStateNormal];
}


@end
