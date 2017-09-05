//
//  I-RMS
//
//  Created by Siya Infotech on 12/09/13.
//  Copyright (c) 2013 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, TaxType) {
    TaxTypeDepartmentWise,
    TaxTypeTaxWise,
};

@protocol TaxTypePopoverDelegate <NSObject>
- (void)didSelectTaxType:(TaxType)taxType;
- (void)didCancelTaxType;
@end

@interface TaxTypePopover : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, weak) id<TaxTypePopoverDelegate> taxTypePopoverDelegate;

@property (nonatomic, strong) NSString *selectedTaxType;
@property (nonatomic, strong) NSString *getTaxName;
@property (nonatomic, strong) NSMutableArray * resposeTaxArray;

@end