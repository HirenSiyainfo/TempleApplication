//
//  MEBaseVC.m
//  RapidRMS
//
//  Created by Siya on 21/01/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "MEBaseVC.h"

@interface MEBaseVC ()

@property (nonatomic, strong) SlidingManuVC *slidingMenuVC;

@property (nonatomic,weak) UIView *menuView;
@property (nonatomic,weak) UIView *menuContainerView;

@end

@implementation MEBaseVC

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setUpMenuView
{
    UIStoryboard *storyBoard = self.storyboard;
    _slidingMenuVC = [storyBoard instantiateViewControllerWithIdentifier:@"SlidingManuVC"];
    _slidingMenuVC.manuSelecteItemDelegate=self;
    CGRect menuFrame = CGRectMake(0.0, 0.0, 330.0, 768.0);
    _slidingMenuVC.view.frame=menuFrame;
   // _slidingMenuVC.view.hidden=YES;
    _menuView=_slidingMenuVC.view;
    
    UIView *viewContainer = [[UIView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:viewContainer];
    _menuContainerView=viewContainer;
    
    _menuContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
//    CGRect menuButtonFrame =CGRectMake(340.0, 19.0, 50.0, 44.0);
//    
//    UIButton *menuButton = [self menuButtonWithFrame:menuButtonFrame];
    //[_menuContainerView addSubview:menuButton];

   // [_menuContainerView addSubview:_slidingMenuVC.view];
}

- (UIButton *)menuButtonWithFrame:(CGRect)menuButtonFrame
{
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    menuButton.frame = menuButtonFrame;
    [menuButton setImage:[UIImage imageNamed:@"headerMenu_PO.png"] forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(OpenMenu:) forControlEvents:UIControlEventTouchUpInside];
    return menuButton;
}

- (void)setUpMenuButton
{
    CGRect menuButtonFrame =CGRectMake(10.0, 19.0, 50.0, 44.0);
    
    UIButton *menuButton;
    menuButton = [self menuButtonWithFrame:menuButtonFrame];
    [self.view addSubview:menuButton];
}

      
- (void)viewDidLoad
{
    [super viewDidLoad];
  //  [self setUpMenuButton];
   // [self setUpMenuView];

    // Do any additional setup after loading the view.
}


-(IBAction)OpenMenu:(id)sender{
    
    [self displayMenu];
    
}

-(void)displayMenu{
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.25];
    _menuContainerView.hidden=NO;
     [UIView commitAnimations];
}
-(void)hideMenu{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.25];
    _menuContainerView.hidden=YES;
    [UIView commitAnimations];
}


-(void)didSelectManu:(NSString *) strManuName{
    
    [self hideMenu];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
