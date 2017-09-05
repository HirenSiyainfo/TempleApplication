//
//  menuViewController.m
//  I-RMS
//
//  Created by Siya Infotech on 11/10/13.
//  Copyright (c) 2013 Siya Infotech. All rights reserved.
//

#import "RimIphonePresentMenu.h"
#import "RmsDbController.h"
#import "RimLoginVC.h"
#import "RimMenuVC.h"
@interface RimIphonePresentMenu () {
    NSArray * menuOptions;
    Configuration *configuration;
}
@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation RimIphonePresentMenu

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
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    configuration = [UpdateManager getConfigurationMoc:self.managedObjectContext];
    [self allocOperationComponents];
    // Do any additional setup after loading the view from its nib.
}



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


-(IBAction)HideMenu:(id)sender{
    [Appsee addEvent:kRIMMenuHide];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(IBAction)LogOutFromRIM:(id)sender{
    [Appsee addEvent:kRIMMenuDashboard];
    [self.rmsDbController playButtonSound];
    NSArray *viewControllerArray = self.sideMenuVCDelegate.currentNavigationController.viewControllers;
    for (UIViewController *vc in viewControllerArray) {
        if ([vc isKindOfClass:[RimLoginVC class]]) {
            [self dismissViewControllerAnimated:NO completion:^{
                [self.sideMenuVCDelegate.currentNavigationController popToViewController:vc animated:TRUE];
            }];
            return;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)isSubdepartmentActive
{
    BOOL isSubdepart = FALSE;
    NSPredicate *deactive = [NSPredicate predicateWithFormat:@"MacAdd == %@", (self.rmsDbController.globalDict)[@"DeviceId"]];
    NSArray *activeModulesArray = [[self.rmsDbController.appsActvDeactvSettingarray filteredArrayUsingPredicate:deactive] mutableCopy ];
    NSPredicate *restaurentActive = [NSPredicate predicateWithFormat:@"ModuleCode == %@ OR ModuleCode == %@ OR ModuleCode == %@ OR ModuleCode == %@", @"RCR",@"RCRGAS",@"RRRCR",@"RRCR"];
    NSArray *restaurentArray = [activeModulesArray filteredArrayUsingPredicate:restaurentActive];
    if (restaurentArray.count > 0)
    {
        NSString * moduleCode = [[restaurentArray valueForKey:@"ModuleCode"]firstObject];
        if ([moduleCode isEqualToString:@"RCR"] && [configuration.subDepartment isEqual:@(1)]) {
            isSubdepart = TRUE;
        }
        else if ([moduleCode isEqualToString:@"RRRCR"] && [configuration.subDepartment isEqual:@(1)]) {
            isSubdepart = TRUE;
        }
        else if([moduleCode isEqualToString:@"RCRGAS"])
        {
            isSubdepart= FALSE;
        }
        else if([moduleCode isEqualToString:@"RRCR"])
        {
            isSubdepart = TRUE;
        }
        
    }
    else if([configuration.subDepartment isEqual:@(1)]){
        isSubdepart = TRUE;
    }
    else{
        isSubdepart = FALSE;
    }
    return isSubdepart;
    
}

-(void)allocOperationComponents
{
    NSDictionary *itemMgtSectionDict = @{@"SectionName": @"",
                                         @"Menu Items" : @[
                                                 @{@"menuId": @"",
                                                   @"Image" : @"RIM_Menu_Home",
                                                   @"Selected Image" : @"RIM_Menu_Home_sel"},
                                                 @{@"menuId": @(IM_InventoryManagement),
                                                   @"Image" : @"RIM_Menu_Item",
                                                   @"Selected Image" : @"RIM_Menu_Item_sel"},
                                                 @{@"menuId": @(IM_InactiveItemManagement),
                                                   @"Image" : @"RIM_Menu_inactive_Item",
                                                   @"Selected Image" : @"RIM_Menu_inactive_Item_sel"},
                                                 @{@"menuId": @(IM_ChangeGroupPrice),
                                                   @"Image" : @"RIM_Menu_GroupPrice",
                                                   @"Selected Image" : @"RIM_Menu_GroupPrice_sel"},
                                                 ]
                                         };
    
    NSDictionary * masterSectionDict;
    if([self isSubdepartmentActive] && IsPad()){
        masterSectionDict = @{@"SectionName": @"MASTER",
                              @"Menu Items" : @[
                                      @{@"menuId": @(IM_DepartmentView),
                                        @"Image" : @"RIM_Menu_Department",
                                        @"Selected Image" : @"RIM_Menu_Department_sel"},
                                      
                                      @{@"menuId": @(IM_SubDepartment),
                                        @"Image" : @"RIM_Menu_SubDepartment",
                                        @"Selected Image" :@"RIM_Menu_SubDepartment_sel"},
                                      
                                      @{@"menuId": @(IM_GroupModifier),
                                        @"Image" : @"RIM_Menu_ModifierGroup",
                                        @"Selected Image" : @"RIM_Menu_ModifierGroup_sel"},
                                      
                                      @{@"menuId": @(IM_GroupItemModifier),
                                        @"Image" : @"RIM_Menu_Modifier",
                                        @"Selected Image" : @"RIM_Menu_Modifier_sel"},
                                      
                                      @{@"menuId": @(IM_TaxMaster),
                                        @"Image" : @"RIM_Menu_TaxMaster",
                                        @"Selected Image" : @"RIM_Menu_TaxMaster_sel"},
                                      
                                      @{@"menuId": @(IM_PaymentMaster),
                                        @"Image" : @"RIM_Menu_PaymentMaster",
                                        @"Selected Image" : @"RIM_Menu_PaymentMaster_sel"
                                        },
                                      ]
                              };
    }
    else if(![self isSubdepartmentActive] && IsPad()){
        masterSectionDict = @{@"SectionName": @"MASTER",
                              @"Menu Items" : @[
                                      @{@"menuId": @(IM_DepartmentView),
                                        @"Image" : @"RIM_Menu_Department",
                                        @"Selected Image" : @"RIM_Menu_Department_sel"},
                                      
                                      @{@"menuId": @(IM_GroupModifier),
                                        @"Image" : @"RIM_Menu_ModifierGroup",
                                        @"Selected Image" : @"RIM_Menu_ModifierGroup_sel"},
                                      
                                      @{@"menuId": @(IM_GroupItemModifier),
                                        @"Image" : @"RIM_Menu_Modifier",
                                        @"Selected Image" : @"RIM_Menu_Modifier_sel"},
                                      
                                      @{@"menuId": @(IM_TaxMaster),
                                        @"Image" : @"RIM_Menu_TaxMaster",
                                        @"Selected Image" : @"RIM_Menu_TaxMaster_sel"},
                                      
                                      @{@"menuId": @(IM_PaymentMaster),
                                        @"Image" : @"RIM_Menu_PaymentMaster",
                                        @"Selected Image" : @"RIM_Menu_PaymentMaster_sel"
                                        },
                                      ]
                              };
    }
    else
    {
        masterSectionDict = @{@"SectionName": @"MASTER",
                              @"Menu Items" : @[
                                      @{@"menuId": @(IM_DepartmentView),
                                        @"Image" : @"RIM_Menu_Department",
                                        @"Selected Image" : @"RIM_Menu_Department_sel"},
                                      
                                      @{@"menuId": @(IM_TaxMaster),
                                        @"Image" : @"RIM_Menu_TaxMaster",
                                        @"Selected Image" : @"RIM_Menu_TaxMaster_sel"},
                                      
                                      @{@"menuId": @(IM_PaymentMaster),
                                        @"Image" : @"RIM_Menu_PaymentMaster",
                                        @"Selected Image" : @"RIM_Menu_PaymentMaster_sel"
                                        },
                                      ]
                              };
    }
    
    NSDictionary *itemSectionDict =  @{@"SectionName": @"",
                                       @"Menu Items" : @[
                                               @{@"menuId": @(IM_NewOrderScannerView),
                                                 @"Image" : @"RIM_Menu_IN",
                                                 @"Selected Image" : @"RIM_Menu_IN_sel"},
                                               
                                               @{@"menuId": @(IM_InventoryOutScannerView),
                                                 @"Image" : @"RIM_Menu_Out",
                                                 @"Selected Image" : @"RIM_Menu_Out_sel"},
                                               
                                               @{@"menuId": @(IM_OpenOrderViewController),
                                                 @"Image" : @"RIM_Menu_OpenOder",
                                                 @"Selected Image" : @"RIM_Menu_OpenOder_sel"},
                                               
                                               @{@"menuId": @(IM_CloseOrderViewController),
                                                 @"Image" : @"RIM_Menu_CloseOder",
                                                 @"Selected Image" : @"RIM_Menu_CloseOder_sel"},
                                               ]
                                       };
    
    NSDictionary *supplierSectionDict = @{@"SectionName": @"",
                                          @"Menu Items" : @[
                                                  @{@"menuId": @(IM_SupplierInventoryView),
                                                    @"Image" : @"RIM_Menu_Vendor",
                                                    @"Selected Image" : @"RIM_Menu_Vendor_sel"},
                                                  ]
                                          };
    
    menuOptions = [[NSMutableArray alloc] initWithObjects:itemMgtSectionDict,masterSectionDict,itemSectionDict,supplierSectionDict, nil];
}

#pragma mark - UITableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return menuOptions.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *sectionDictionary = menuOptions[section];
    NSArray *menuItems = sectionDictionary[@"Menu Items"];
    return menuItems.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 23.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 23.0f)];
    
    
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, view.frame.size.width-20, view.frame.size.height)];
    [label setFont:[UIFont fontWithName:@"Lato-Bold" size:14.0]];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    NSString *sectionTitle = @"";
    switch (section) {
        case 0:
            sectionTitle = @"ITEM MANAGEMENT";
            break;
        case 1:
            sectionTitle = @"ITEM MASTER";
            break;
        case 2:
            sectionTitle = @"IN-OUT";
            break;
        case 3:
            sectionTitle = @"VENDOR";
            break;
            
        default:
            break;
    }
    label.text = sectionTitle;
    label.textColor = [UIColor whiteColor];
    UIView * ovjSepreter = [[UIView alloc]initWithFrame:CGRectMake(20, view.frame.size.height-1, view.frame.size.width-20, 1)];
    ovjSepreter.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.200];
    
    [view addSubview:label];
    [view addSubview:ovjSepreter];
    [view setBackgroundColor:[UIColor clearColor]]; //your background color...
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RIMMenuCell  *cell=[tableView dequeueReusableCellWithIdentifier:@"MenuCell"];
    NSDictionary *sectionDictionary = menuOptions[indexPath.section];
    NSArray *menuItems = sectionDictionary[@"Menu Items"];
    NSDictionary *menuItemDictionary = menuItems [indexPath.row];
    
    cell.imgBG.image = [UIImage imageNamed:menuItemDictionary[@"Image"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section==0 && indexPath.row==0) {
        [self dismissViewControllerAnimated:NO completion:^{
            UINavigationController * objNav = self.sideMenuVCDelegate.currentNavigationController;
            NSArray * arrListVC=objNav.viewControllers;
            for (int i=0; i < arrListVC.count; i++) {
                UIViewController * objVC=arrListVC[i];
                if ([objVC isKindOfClass:[RimMenuVC class]]) {
                    [objNav popToViewController:objVC animated:YES];
                    return ;
                }
            }
        }];
    }
    else {
        NSDictionary *sectionDictionary = menuOptions[indexPath.section];
        NSArray *menuItems = sectionDictionary[@"Menu Items"];
        NSDictionary *menuItemDictionary = menuItems [indexPath.row];
        
        ItemManagementVCType menuItem = [menuItemDictionary [@"menuId"] integerValue];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self dismissViewControllerAnimated:YES completion:^{
            [self.sideMenuVCDelegate showViewControllerFromPopUpMenu:menuItem];
        }];
    }
}
@end
