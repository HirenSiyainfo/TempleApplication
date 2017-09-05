//
//  TaxAddRemovePage.h
//  POSFrontEnd
//
//  Created by Triforce-Nirmal-Imac on 6/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ItemTaxEditDelegate<NSObject>
-(void)didEditItemWithItemTaxDetail :(NSMutableArray *)taxDetailArray;
-(void)didCancelItemTaxEdit;
@end

@interface TaxAddPage : UIViewController <TaxCheckBoxDelegate> {
	
		
}
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, weak) id<ItemTaxEditDelegate> itemTaxEditDelegate;

- (NSString *) getItemTaxAmtForItemPrice:(NSString *)price withObjectAtIndex:(NSString *)index;

@end
