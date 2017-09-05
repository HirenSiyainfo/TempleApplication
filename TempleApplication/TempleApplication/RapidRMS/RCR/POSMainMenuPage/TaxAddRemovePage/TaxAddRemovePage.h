//
//  TaxAddRemovePage.h
//  POSFrontEnd
//
//  Created by Triforce-Nirmal-Imac on 6/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TaxAddRemovePage : UIViewController <TaxCheckBoxDelegate> {
	
}
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

- (IBAction) toolBarActionHandler:(id)sender;
//- (NSString *) getItemTaxAmtForItemPrice:(NSString *)price withObjectAtIndex:(NSString *)index;

@end
