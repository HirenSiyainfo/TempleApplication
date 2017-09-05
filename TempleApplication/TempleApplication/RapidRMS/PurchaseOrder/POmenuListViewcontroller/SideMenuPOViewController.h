//
//  SideMenuPOViewController.h
//  RapidRMS
//
//  Created by Siya on 07/08/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, Menu) {
    GenerateOrderMenu,
    PurchaseOrderListMenu,
    OpenOrderMenu,
    DeliveryPendingMenu,
    CloseOrderMenu,
};

@protocol SideMenuPODelegate <NSObject>

-(void)menuButtonOperationCell:(NSInteger)ptag;
-(void)SlideInout;
-(IBAction)btnDashboard:(UIButton *)sender;
-(IBAction)menuButtonOperations:(id)sender;

@end

@interface SideMenuPOViewController : UIViewController
{
}

@property (nonatomic,weak) id<SideMenuPODelegate> sideMenuPODelegate;

@property (nonatomic, weak) IBOutlet UITableView *tblMenuOperation;
@property (nonatomic, strong) NSIndexPath *indPath;

@end
