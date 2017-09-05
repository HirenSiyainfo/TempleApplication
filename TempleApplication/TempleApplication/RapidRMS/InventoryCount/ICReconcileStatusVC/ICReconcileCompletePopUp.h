//
//  ICReconcileCompletePopUp.h
//  RapidRMS
//
//  Created by siya8 on 17/10/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ReconcileCompletePopupVCDelegate <NSObject>
-(void)completeReconcile :(BOOL)isSelected;
-(void)didCancel;

@end

@interface ICReconcileCompletePopUp : UIViewController
@property (nonatomic, strong) id<ReconcileCompletePopupVCDelegate> reconcileCompletePopupVCDelegate;
@property (nonatomic, strong) IBOutlet UIView *deptView;
@property (nonatomic, strong)NSMutableArray *arrSelectedDepartment;

@end
