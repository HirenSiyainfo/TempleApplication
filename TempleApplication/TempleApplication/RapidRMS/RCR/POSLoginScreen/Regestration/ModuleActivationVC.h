//
//  ModuleActivationVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 04/04/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ModuleActivationVC : UIViewController <UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,UpdateDelegate>
{
   
    
    // UITableView variable
    UIImageView *imgBackGround;
    UILabel *lblDeviceName;
    UIButton *btnChecked;
    UILabel *lblStatus;
    UILabel *lblAvailableCount;
    UILabel *lblActiveDeviceName;
    
      UINavigationController *availableAppsNav;
}
@property (nonatomic, strong) UpdateManager *updateManager;

@property (nonatomic,strong) NSMutableArray *arrDeviceAuthentication;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

-(IBAction)btnMenuClicked:(id)sender;

-(IBAction)btnNotActivatedClicked:(id)sender;
-(IBAction)btnActiveClicked:(id)sender;
-(IBAction)btnOthersClicked:(id)sender;

-(IBAction)btnDoneClicked:(id)sender;
-(IBAction)btnCancelClicked:(id)sender;

-(IBAction)btnYesClicked:(id)sender;
-(IBAction)btnNoClicked:(id)sender;

-(void)goToAvailableAppsMenu;
-(void)goToActiveAppsMenu;
-(void)goTODeviceActivation;

@end
