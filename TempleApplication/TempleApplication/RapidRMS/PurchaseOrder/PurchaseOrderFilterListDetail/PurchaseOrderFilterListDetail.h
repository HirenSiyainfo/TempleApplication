//
//  PurchaseOrderFilterListDetail.h
//  RapidRMS
//
//  Created by Siya on 14/08/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ManualFilterOptionViewController.h"
#import "UpdateManager.h"
#import "NDHTMLtoPDF.h"
#import "POmenuListDelegateVC.h"

@interface PurchaseOrderFilterListDetail : UIViewController<UpdateDelegate,UITextFieldDelegate,UIActionSheetDelegate,UpdateDelegate,NDHTMLtoPDFDelegate,UIDocumentInteractionControllerDelegate>

@property (nonatomic, weak) id<POmenuListVCDelegate> pOmenuListVCDelegate;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) NSMutableArray *arrSelectedManualList;
@property (nonatomic, strong) NSMutableArray *arrdepartmentList;
@property (nonatomic, strong) NSMutableArray *arrsupplierlist;
@property (nonatomic, strong) NSMutableArray *arrUpdatePoData;

@property (nonatomic, strong) NSString *strPredicateDept;
@property (nonatomic, strong) NSString *strPredicateSupp;
@property (nonatomic, strong) NSString *strDeprtidList;
@property (nonatomic, strong) NSString *strSuppidList;
@property (nonatomic, strong) NSString *strPopUpDepartment;
@property (nonatomic, strong) NSString *strPopUpSupplier;
@property (nonatomic, strong) NSString *strPopUpTags;
@property (nonatomic, strong) NSString *strPopUpTimeDuration;
@property (nonatomic, strong) NSString *strPopUpFromDate;
@property (nonatomic, strong) NSString *strPopUpToDate;

-(void)supplierDepartmentArray:(NSMutableArray *)pArrayTemp;
-(void)filterDepartmentamdSupplierforFilterList;
@end
