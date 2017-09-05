//
//  DeptFavSelectionViewController.m
//  RapidRMS
//
//  Created by Siya Infotech on 19/06/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "DeptFavSelectionViewController.h"
#import "RmsDbController.h"

@interface DeptFavSelectionViewController ()
{
    IntercomHandler *intercomHandler;
}

@property (nonatomic, weak) IBOutlet UILabel *lbldepartment;
@property (nonatomic, weak) IBOutlet UILabel *lblFavorite;

@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, strong) NSMutableDictionary *dictSet;;

@end

@implementation DeptFavSelectionViewController
@synthesize btnDepartment,btnFavorite,dictSet;

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

    dictSet = [[NSMutableDictionary alloc] init];
    [self setSelection];

    // Do any additional setup after loading the view from its nib.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title=@"Cash Register";

    UIImage* image3 = [UIImage imageNamed:@"RmsheaderLogo.png"];
    CGRect frameimg = CGRectMake(0, 0, image3.size.width, image3.size.height);
    UIButton *someButton = [[UIButton alloc] initWithFrame:frameimg];
    [someButton setBackgroundImage:image3 forState:UIControlStateNormal];
    UIBarButtonItem *mailbutton =[[UIBarButtonItem alloc] initWithCustomView:someButton];
   
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
    UIBarButtonItem *intercom =[[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItems = @[mailbutton,intercom];
    intercomHandler = [[IntercomHandler alloc] initWithButtton:button withViewController:self];
   //self.navigationItem.hidesBackButton = YES;
}
-(void)setSelection
{
    NSString *Str = [[NSUserDefaults standardUserDefaults]objectForKey:@"Selection"];
    if(Str.length > 0)
    {
        if ([Str isEqualToString:@"Department"])
        {
            btnDepartment.selected = YES;
            btnFavorite.selected = NO;
//            self.lbldepartment.textColor = [UIColor colorWithRed:30.0/255.0 green:114.0/255.0 blue:174.0/255.0 alpha:1.0];
//            self.lblFavorite.textColor = [UIColor blackColor];

        }
        if ([Str isEqualToString:@"Favorite"])
        {
            btnDepartment.selected = NO;
            btnFavorite.selected = YES;
//            self.lblFavorite.textColor = [UIColor colorWithRed:30.0/255.0 green:114.0/255.0 blue:174.0/255.0 alpha:1.0];
//            self.lbldepartment.textColor = [UIColor blackColor];
        }
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnDepartmentClicked:(id)sender {
    [self.rmsDbController playButtonSound];
    btnFavorite.selected = NO;
    btnDepartment.selected = YES;
//    self.lbldepartment.textColor = [UIColor colorWithRed:30.0/255.0 green:114.0/255.0 blue:174.0/255.0 alpha:1.0];
//    self.lblFavorite.textColor = [UIColor blackColor];
    [self departmentSelect];
}
- (IBAction)btnFavoriteClicked:(id)sender {
    [self.rmsDbController playButtonSound];
    btnDepartment.selected = NO;
    btnFavorite.selected = YES;
//    self.lblFavorite.textColor = [UIColor colorWithRed:30.0/255.0 green:114.0/255.0 blue:174.0/255.0 alpha:1.0];
//    self.lbldepartment.textColor = [UIColor blackColor];
    [self favoriteSelect];
}

-(void)departmentSelect
{
    if ([dictSet[@"Selection"]isEqualToString:@"Favorite"])
    {
        [dictSet removeObjectForKey:@"Selection"];
        dictSet[@"Selection"] = @"Department";
    }
    else
    {
        dictSet[@"Selection"] = @"Department";
    }
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"Selection"];
       [[NSUserDefaults standardUserDefaults] setObject:[dictSet valueForKey:@"Selection" ] forKey:@"Selection" ];
    [[NSUserDefaults standardUserDefaults] synchronize ];

}


-(void)favoriteSelect
{
    if ([dictSet[@"Selection"]isEqualToString:@"Department"])
    {
        [dictSet removeObjectForKey:@"Selection"];
        dictSet[@"Selection"] = @"Favorite";
    }
    else
    {

        dictSet[@"Selection"] = @"Favorite";
    }

    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"Selection"];
    [[NSUserDefaults standardUserDefaults] setObject:[dictSet valueForKey:@"Selection" ] forKey:@"Selection" ];
    [[NSUserDefaults standardUserDefaults] synchronize ];
}




@end
