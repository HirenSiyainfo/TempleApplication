//
//  MultipleBarcodeRingUpForItemMovement.h
//  RapidRMS
//
//  Created by siya8 on 17/04/17.
//  Copyright © 2017 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopupSuperVC.h"

#ifdef LINEAPRO_SUPPORTED
#import "DTDevices.h"
#endif

@protocol MultipleBarcodePopUpForIMVCDelegate <NSObject>
-(void)didSelectItemsForScanningItemForDuplicateBarcode:(NSArray *)selectedItems;
-(void)didCanceItemsSelection;
@end

@interface MultipleBarcodeRingUpForItemMovement : UIViewController{
}

@property (nonatomic) BOOL isDuplicateBarcodeAllowed;
@property (nonatomic, weak) id<MultipleBarcodePopUpForIMVCDelegate> multipleBarcodePopUpForIMVCDelegate;

@property (nonatomic, strong) NSString *itemBarcode;
@property (nonatomic, strong) Item *anItem;
@property (nonatomic, strong) NSMutableArray *multipleItemArray;

@end
