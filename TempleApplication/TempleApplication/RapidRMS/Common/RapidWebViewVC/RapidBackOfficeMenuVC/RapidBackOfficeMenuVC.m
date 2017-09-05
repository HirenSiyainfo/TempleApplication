//
//  RapidBackOfficeMenuVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 26/06/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "RapidBackOfficeMenuVC.h"
#import "RapidWebViewVC.h"
@interface RapidBackOfficeMenuVC (){
    NSArray *menuOptions;
}
@property (nonatomic, strong) IBOutlet UIButton *btnSlidingMenu;
@property (nonatomic,retain) IBOutlet UIView *slidingMenuView;
@property (nonatomic,assign) BOOL boolslidingMenuView;
@property (nonatomic,retain) IBOutlet UIView *gestureView;
@end

@implementation RapidBackOfficeMenuVC

- (void)viewDidLoad {
    [super viewDidLoad];
    menuOptions=@[                                                  @{@"menuId": @(PageIdDashboard),
                                                                      @"text" : @"Dashboard",
                                                                      @"Image" : @"Dashboard_ipad.png",
                                                                      @"Selected Image" : @"webPortal_dashboard_active_ipad"},
                                                                    @{@"menuId": @(PageIdGroup),
                                                                      @"text" : @"Group",
                                                                      @"Image" : @"GroupMasterMenu_ipad.png",
                                                                      @"Selected Image" : @"GroupMasterMenuActive_ipad.png"},
                                                                    @{@"menuId": @(PageIdManagerReports),
                                                                      @"text" : @"Manager Reports"},];
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    recognizer.delegate = self;
    recognizer.delaysTouchesBegan = YES;
    [self.gestureView addGestureRecognizer:recognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return menuOptions.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"    Management Portal";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCellStyle style =  UITableViewCellStyleDefault;
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"];
    
    NSDictionary *sectionDictionary = menuOptions[indexPath.row];
    
    if (sectionDictionary[@"Image"]==nil) {
        cell.textLabel.text=sectionDictionary[@"text"];
    }
    else{
        UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:sectionDictionary [@"Image"]] highlightedImage:[UIImage imageNamed:sectionDictionary [@"Selected Image"]]];
        imageView.tag = 1212;
        [[cell.contentView viewWithTag:1212] removeFromSuperview];
        [cell.contentView addSubview:imageView];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *sectionDictionary = menuOptions[indexPath.row];
    [self.rapidWebMenuVDelegate didSelectionChangeManu:[sectionDictionary[@"menuId"] integerValue]];
    [self showMenu:nil];
}

-(IBAction)showMenu:(id)sender{
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame;
        if(self.boolslidingMenuView == FALSE)
        {
            frame = self.slidingMenuView.frame;
            frame.origin.x = 0;
            self.view.hidden=FALSE;
        }
        else
        {
            frame = self.slidingMenuView.frame;
            frame.origin.x = -270;
        }
        self.slidingMenuView.frame = frame;
        [self.view bringSubviewToFront:self.slidingMenuView];
        
    } completion:^(BOOL finished) {
        if(self.boolslidingMenuView == FALSE)
        {
            self.boolslidingMenuView = TRUE;
            self.view.hidden=FALSE;
        }
        else{
            self.boolslidingMenuView = FALSE;
            self.view.hidden=TRUE;
        }
    }];
}
-(IBAction)Logout:(id)sender{
    AppDelegate * appDel=(AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDel.navigationController popViewControllerAnimated:YES];
}
- (void)handleTap:(UITapGestureRecognizer *)recognizer {
    [self showMenu:nil];
}
@end
