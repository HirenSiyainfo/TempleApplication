//
//  DepartmetCollectionVC.h
//  RapidRMS
//
//  Created by siya-IOS5 on 6/30/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Department+Dictionary.h"

@protocol DepartmetCollectionVcDelegate <NSObject>
-(void)didSelectedDepartment:(Department *)selectedDepartment withUICollectionViewCell:(UICollectionViewCell *)collectionCell;
-(void)didAddItemFromFavouriteList :(NSString *)itemId;

@end

@protocol DepartmetCollectionCountDelegate <NSObject>
-(void)didChangeDepartmentCount:(NSInteger )count;
@end

@interface DepartmetCollectionVC : UIViewController <NSFetchedResultsControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UIScrollViewDelegate,DepartmetCollectionVcDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, weak) id<DepartmetCollectionVcDelegate> departmetCollectionVcDelegate;
@property (nonatomic, weak) id<DepartmetCollectionCountDelegate>departmetCollectionCountDelegate;

@property (assign) CGFloat numerOfItemPerPage;

-(void)scrollDepartmentCollectionViewToTop;

- (void)updateDepartmentPageControl;

@end
