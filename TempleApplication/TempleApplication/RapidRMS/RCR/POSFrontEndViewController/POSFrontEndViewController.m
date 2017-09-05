//
//  POSFrontEndViewController.m
//  POSRetail
//
//  Created by Nirav Patel on 08/11/12.
//  Copyright (c) 2012 Nirav Patel. All rights reserved.
//

#import "POSFrontEndViewController.h"
#import "OLImageView.h"
#import "OLImage.h"
@interface POSFrontEndViewController ()
{
    AppDelegate * appDelegate;
    IntercomHandler *intercomHandler;

}
@property (nonatomic, strong) UtilityManager * util;
@property (nonatomic, weak) IBOutlet UIView * logoBackGround;;
@property (nonatomic, weak) IBOutlet UIButton *btnIntercom;


@end

@implementation POSFrontEndViewController

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

    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.navigationController = self.navigationController;
//    self.util = [[UtilityManager alloc]init];
//    [self.util showActivityViewer:self.view ];
    
    OLImageView *imageView = [[OLImageView alloc] initWithImage:[OLImage imageNamed:@"RapidLoadingLogo.gif"]];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.layer.shadowOffset = CGSizeMake(0, 2);
    imageView.frame = CGRectMake(self.view.center.x-27, self.view.frame.size.height * 0.66, 55, 55);
    //imageView.center = self.view.center;
    
    imageView.layer.cornerRadius = 5;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:imageView ];
    
    _logoBackGround.layer.cornerRadius = 10.0;
    intercomHandler = [[IntercomHandler alloc] initWithButtton:_btnIntercom normalImage:@"helpbtn_blackbtn.png" selectedImage:@"dr_helpbtnselected.png" withViewController:self];

   // [self getRegistrationDetail];
    // Do any additional setup after loading the view from its nib.
}

/*
// go to the login screen.
- (void) loginScreen {
	POSLoginView * loginView = [[POSLoginView alloc] initWithNibName:@"POSLoginView" bundle:nil];
	[self.navigationController pushViewController:loginView animated:YES];
}*/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
