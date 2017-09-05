//
//  SideMenuVCDelegate.h
//  RapidRMS
//
//  Created by Siya Infotech on 17/08/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#ifndef RapidRMS_SideMenuVCDelegate_h
#define RapidRMS_SideMenuVCDelegate_h

typedef NS_ENUM(NSInteger, ItemManagementVCType) {
    IM_InventoryManagement,
    IM_InactiveItemManagement,

    IM_DepartmentView,
    IM_SubDepartment,
    IM_GroupModifier,
    IM_GroupItemModifier,

    IM_NewOrderScannerView,
    IM_InventoryOutScannerView,
    IM_OpenOrderViewController,
    IM_CloseOrderViewController,
    
    IM_InventoryCountView,
    IM_SupplierInventoryView,
    IM_MixMatch,
    IM_Supplier,
    IM_Group,
    IM_VcCount,
    IM_TaxMaster,
    IM_PaymentMaster,
    
    IM_DashBoardLoad,
    IM_ChangeGroupPrice,
};

@protocol SideMenuVCDelegate <NSObject>
    -(void)willPushViewController:(UIViewController *)viewController animated:(BOOL)animated;
    -(UIViewController *)willPopViewControllerAnimated:(BOOL)animated;

    -(void)willPresentViewController:(UIViewController *)viewControllerToPresent animated: (BOOL)flag completion:(void (^)(void))completion;
    -(void)willDismissViewControllerAnimated: (BOOL)flag completion: (void (^)(void))completion;

    - (UIViewController *)viewContorllerFor:(ItemManagementVCType)vcType;
    - (void)showViewController:(ItemManagementVCType)vcType;
    @property (NS_NONATOMIC_IOSONLY, getter=getCurrentNavigationController, readonly, strong) UINavigationController *currentNavigationController;

    -(void)showViewControllerFromPopUpMenu:(ItemManagementVCType)vcType;
@end

#endif
