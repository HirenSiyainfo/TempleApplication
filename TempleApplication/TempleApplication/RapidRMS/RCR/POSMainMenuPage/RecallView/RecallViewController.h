//
//  RecallViewController.h
//  POSRetail
//
//  Created by Keyur Patel on 23/07/13.
//  Copyright (c) 2013 Nirav Patel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RecallDelegate<NSObject>
-(void)didCancelRecallOrder;
-(void)didRecallOrderWithInvoiceId :(NSString *)invoiceId;
-(void)didRecallOrderWithOfflineInvoiceId :(NSString *)invoiceId withOfflineData:(NSData *)recallOfflineData;

@end

@interface RecallViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate>
{
   
}
-(void) GetRecallData;

@property (nonatomic, weak) id<RecallDelegate> recallDelegate;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
