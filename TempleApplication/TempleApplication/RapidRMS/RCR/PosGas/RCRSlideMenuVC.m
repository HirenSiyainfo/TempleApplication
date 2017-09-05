//
//  RCRSlideMenuVC.m
//  RapidRMS
//
//  Created by siya-IOS5 on 6/18/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "RCRSlideMenuVC.h"
#import "RcrSlideMenuCell.h"

@interface RCRSlideMenuVC ()<UIGestureRecognizerDelegate>
{
   
}
@property(nonatomic , weak) IBOutlet UIView *gesterView;
@property(nonatomic , weak) IBOutlet UITableView *rcrMenuTabelView;
@property(nonatomic , weak) IBOutlet UIView *viewForSlideMenuTabel;

@end

@implementation RCRSlideMenuVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.


    UITapGestureRecognizer *singleTapMenuHideShow = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rcrMenuHideShow:)];
    singleTapMenuHideShow.delegate = self;
    singleTapMenuHideShow.delaysTouchesBegan = YES;
    [_gesterView addGestureRecognizer:singleTapMenuHideShow];
    
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _viewForSlideMenuTabel.hidden = NO;

    if(self.isPresentAsPopOver == FALSE)
    {
        self.view.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:0.5];
    }
    else
    {
        _viewForSlideMenuTabel.layer.cornerRadius = 10.0;
        _viewForSlideMenuTabel.layer.borderWidth = 2.0;
        _viewForSlideMenuTabel.layer.borderColor = [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255.0 alpha:1.0].CGColor;
    }
    [_rcrMenuTabelView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _viewForSlideMenuTabel.hidden = YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.rcrSlideMenuItemEnum.count;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    float headerHeight = 55;
//    return headerHeight;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RcrSlideMenuCell *rcrSlideMenuCell = [tableView dequeueReusableCellWithIdentifier:@"RcrSlideMenuCell"];
    
    rcrSlideMenuCell.backgroundColor = [UIColor clearColor];
    rcrSlideMenuCell.textLabel.textColor = [UIColor whiteColor];
    
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor colorWithRed:0.086 green:0.075 blue:0.141 alpha:1.000];
    rcrSlideMenuCell.selectedBackgroundView = selectionColor;
    rcrSlideMenuCell.selectedBackgroundView.layer.cornerRadius = 10.0;

    
    UIView *backColor = [[UIView alloc] init];
    backColor.backgroundColor = [UIColor clearColor];
    rcrSlideMenuCell.backgroundView = backColor;
 
    UIImage *cellNormalImage = [UIImage imageNamed:self.rcrSlideMenuNormalImages[indexPath.row]];
    
    rcrSlideMenuCell.rcrSlideItemCellImage.image = cellNormalImage;

    UIImage *cellSelectedImage = [UIImage imageNamed:self.rcrSlideMenuSelectedImages[indexPath.row]];
    rcrSlideMenuCell.rcrSlideItemCellImage.highlightedImage = cellSelectedImage;

    rcrSlideMenuCell.rcrSlideItemCellName.text = self.rcrSlideMenuNames[indexPath.row];

    return rcrSlideMenuCell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RcrSlideMenuItem rcrSlideMenuItem = [(self.rcrSlideMenuItemEnum)[indexPath.row] integerValue];
    [self.rcrSlideMenuVCDelegate didSelectRCRMenuItem:rcrSlideMenuItem forRCRSlideMenuVC:self];
}

- (void)rcrMenuHideShow:(UITapGestureRecognizer *)recognizer {
    [self.rcrSlideMenuVCDelegate hideShowRCRSlideMenu:self];
}


@end
