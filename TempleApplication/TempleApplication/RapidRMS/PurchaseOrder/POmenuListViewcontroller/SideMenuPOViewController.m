//
//  SideMenuPOViewController.m
//  RapidRMS
//
//  Created by Siya on 07/08/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "SideMenuPOViewController.h"
#import "POSideMenuCustomCell.h"

@interface SideMenuPOViewController ()<UIGestureRecognizerDelegate>
{
    
}

@property (nonatomic, weak) IBOutlet UIButton *btndashboard;
@property (nonatomic, weak) IBOutlet UIView *touchView;

@end

@implementation SideMenuPOViewController

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
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    recognizer.delegate = self;
    UINib *nib = [UINib nibWithNibName:@"POSideMenuCustomCell" bundle:nil];
    [self.tblMenuOperation registerNib:nib forCellReuseIdentifier:@"POSideMenuCustomCell"];
    self.indPath=[NSIndexPath indexPathForRow:0 inSection:0];
    [_touchView addGestureRecognizer:recognizer];

    // Do any additional setup after loading the view from its nib.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tableView.backgroundColor = [UIColor clearColor];
    POSideMenuCustomCell *pOSideMenuCustomCell = (POSideMenuCustomCell *)[self.tblMenuOperation dequeueReusableCellWithIdentifier:@"POSideMenuCustomCell"];

    NSString *normalImage = @"";
    NSString *highlightedImage = @"";

    Menu menu = indexPath.row;
    switch (menu) {
        case GenerateOrderMenu:
            normalImage = @"generateOrder_ipad.png";
            highlightedImage = @"generateOrderActive_ipad.png";
            break;
          
        case PurchaseOrderListMenu:
            normalImage = @"PurchaseOrderList_ipad.png";
            highlightedImage = @"PurchaseOrderListActive_ipad.png";
            break;
            
        case OpenOrderMenu:
            normalImage = @"openMenu_ipad_po.png";
            highlightedImage = @"openMenuActive_ipad.png";
            break;
            
        case DeliveryPendingMenu:
            normalImage = @"DeliveryPending_ipad.png";
            highlightedImage = @"DeliveryPendingActive_ipad.png";
            break;
            
        case CloseOrderMenu:
            normalImage = @"closeMenu_ipad_po.png";
            highlightedImage = @"closeMenuActive_ipad.png";
            break;

        default:
            break;
    }

    if (self.indPath.row == indexPath.row) {
        normalImage = highlightedImage;
    }
    
    [pOSideMenuCustomCell configaureImageViewWithNoramalImage:normalImage];
    [pOSideMenuCustomCell configaureImageViewWithHighlightedImage:highlightedImage];

    return pOSideMenuCustomCell;
}

#pragma mark - UITableView delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.indPath.row != indexPath.row) {
        NSArray *indexPathArray = @[self.indPath, indexPath];
        [self.tblMenuOperation reloadRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationNone];
    }
    self.indPath = indexPath;
    [self.sideMenuPODelegate menuButtonOperationCell:indexPath.row];
    [self.sideMenuPODelegate SlideInout];
}

- (void)handleTap:(UITapGestureRecognizer *)recognizer {
   [self.sideMenuPODelegate SlideInout];
}


-(IBAction)menuOperationCall:(id)sender{
    [Appsee addEvent:kPOMenuLogout];
    [self.sideMenuPODelegate btnDashboard:self.btndashboard];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
