//
//  DashBoardIconSelectionVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 03/02/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DashBoardIconSelectionVCDelegate

-(void)selectedDashBoardIcon:(NSMutableArray *)selectedDashBoardModule;
-(void)skipDashBoardIconSelection;

@end

@interface DashBoardIconSelectionVC : UIViewController

@property (nonatomic, weak) id<DashBoardIconSelectionVCDelegate> dashBoardIconSelectionVCDelegate;

@property (nonatomic, weak) IBOutlet UIView *OperationBtnView;

@property (nonatomic, weak) IBOutlet UITableView *iconSelectionTableView;

@end
