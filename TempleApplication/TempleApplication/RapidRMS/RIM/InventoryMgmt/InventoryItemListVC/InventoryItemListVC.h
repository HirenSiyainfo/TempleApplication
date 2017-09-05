//
//  InventoryItemListVC.h
//  RapidRMS
//
//  Created by Siya9 on 13/06/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SideMenuVCDelegate.h"
#import "Item+Dictionary.h"
#ifdef LINEAPRO_SUPPORTED
#import "DTDevices.h"
#endif

@interface InventoryItemListVC : UIViewController<UpdateDelegate>

@property (nonatomic) BOOL isItemActive;
@property (nonatomic) BOOL isItemInSelectMode;

@property (nonatomic, strong) NSString * strSearchText;

@property (nonatomic, weak) id<SideMenuVCDelegate> sideMenuVCDelegate;


@property (nonatomic, weak) IBOutlet UIView *footerView;



// For Subclass Used

@property (nonatomic, strong) NSFetchedResultsController *itemListRC;

@property (nonatomic, strong) NSMutableArray *arrItemSelected;

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

-(void)showMessage:(NSString *)strMessage;
@end
