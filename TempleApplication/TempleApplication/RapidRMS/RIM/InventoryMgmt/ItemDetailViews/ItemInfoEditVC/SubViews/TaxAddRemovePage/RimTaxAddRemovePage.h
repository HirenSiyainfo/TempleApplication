//
//  TaxAddRemovePage.h
//  POSFrontEnd
//
//  Created by Triforce-Nirmal-Imac on 6/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RimTaxAddRemovePageDelegate <NSObject>
- (void)didSelectTax:(NSMutableArray *)taxListArray;
@end

@interface RimTaxAddRemovePage : UIViewController

@property (nonatomic, weak) id<RimTaxAddRemovePageDelegate> rimTaxAddRemovePageDelegate;

@property (nonatomic, strong) NSString *strItemcode;
@property (nonatomic, strong) NSMutableArray *checkedTaxItem;

@end