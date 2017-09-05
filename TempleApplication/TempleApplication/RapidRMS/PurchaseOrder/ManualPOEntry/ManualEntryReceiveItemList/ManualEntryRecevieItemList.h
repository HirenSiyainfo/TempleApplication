//
//  ManualEntryRecevieItemList.h
//  RapidRMS
//
//  Created by Siya on 16/01/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "MEBaseVC.h"
#import "MESearchItemSelectionVC.h"
#import "SlidingManuVC.h"
#import "NDHTMLtoPDF.h"

@interface ManualEntryRecevieItemList : MEBaseVC <NSFetchedResultsControllerDelegate,MESearchItemSelectionVCDelegate,UpdateDelegate,ManuSelecteItemDelegate,NDHTMLtoPDFDelegate,UIDocumentInteractionControllerDelegate,UITextFieldDelegate>

@property (nonatomic, strong) ManualPOSession *posession;

@property (nonatomic, strong) NSString *strManualPoID;
@property (nonatomic, strong) NSString *strInvoiceNo;
@property (nonatomic, strong) NSString *strTitle;


@property (nonatomic, strong) NSMutableDictionary *dictSupplier;

@property (nonatomic, assign) BOOL showView;
@property (nonatomic, assign) BOOL isHistory;

@end
