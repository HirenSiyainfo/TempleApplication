//
//  FavouriteCollectionVC.h
//  RapidRMS
//
//  Created by siya-IOS5 on 8/6/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol FavouriteCollectionDelegate<NSObject>

-(void)didAddItemFromFavouriteList :(NSString *)itemId;

@end

@protocol FavouriteCollectionCountDelegate<NSObject>

-(void)didChangeFavouriteCount:(NSInteger)count;

@end


@interface FavouriteCollectionVC : UIViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, weak) id<FavouriteCollectionDelegate> favouriteCollectionDelegate;
@property (nonatomic, weak) id<FavouriteCollectionCountDelegate> favouriteCollectionCountDelegate;

@property (assign) CGFloat numerOfItemPerPage;
-(void)scrollFavouriteCollectionViewToTop;
-(void)updateFavouritePageControl;


@end
