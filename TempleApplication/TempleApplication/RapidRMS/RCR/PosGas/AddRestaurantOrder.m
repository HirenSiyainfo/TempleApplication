//
//  AddRestaurantOrder.m
//  RapidRMS
//
//  Created by siya-IOS5 on 4/7/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "AddRestaurantOrder.h"
#import "RmsDbController.h"

@interface AddRestaurantOrder ()
{
   
    NSInteger selectedSegment;
}
@property (nonatomic, weak) IBOutlet UITextField *tableName;
@property (nonatomic, weak) IBOutlet UITextField *noOfGuest;
@property (nonatomic, weak) IBOutlet UIView *viewText;
@property (nonatomic, weak) IBOutlet UIView *viewBG;
@property (nonatomic, weak) IBOutlet UIButton *btnSave;
@property (nonatomic, weak) IBOutlet UIButton *btnClose;
@property (nonatomic, weak) IBOutlet UIButton *btnDivineIn;
@property (nonatomic, weak) IBOutlet UIButton *btnTakeAway;

@property (nonatomic, strong) RmsDbController *rmsDbController;

@end



@implementation AddRestaurantOrder

@synthesize managedObjectContext = _managedObjectContext;

- (void)viewDidLoad
{
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
   
    _viewText.layer.cornerRadius = 5.0f;
    _viewBG.layer.cornerRadius = 5.0f;

    _btnSave.layer.borderColor = [UIColor whiteColor].CGColor;
    _btnSave.layer.borderWidth = 1.0f;
    _btnSave.layer.cornerRadius = 5.0;
    
    _btnClose.layer.borderColor = [UIColor whiteColor].CGColor;
    _btnClose.layer.borderWidth = 1.0f;
    _btnClose.layer.cornerRadius = 5.0;
    
    _btnDivineIn.selected = YES;
    _btnTakeAway.selected = NO;
    selectedSegment = 1;


    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(IBAction)addRestaurantOrder:(id)sender
{
    NSDictionary *orderDetail = @{@"TabelName": _tableName.text,@"NoOfGuest": _noOfGuest.text,@"isDineIn": @(selectedSegment)};
    [self.addRestaurantOrderDelegate didInsertRestaurantOrder:orderDetail];
}
-(IBAction)cancelRestaurantOrder:(id)sender
{
    [self.addRestaurantOrderDelegate didCancelRestaurantOrder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)btnDivineInClick:(id)sender
{
    if ([sender tag]==100)
    {
        _btnDivineIn.selected = YES;
        _btnTakeAway.selected = NO;
        selectedSegment = 1;
    }
    else
    {
        _btnTakeAway.selected = YES;
        _btnDivineIn.selected = NO;
        selectedSegment = 0;
    }
}

@end
