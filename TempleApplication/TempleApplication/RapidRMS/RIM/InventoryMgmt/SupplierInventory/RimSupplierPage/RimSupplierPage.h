//
//  SupplierPage.h
//

#import <UIKit/UIKit.h>
#import "ItemInfoEditVC.h"
@protocol RimSupplierChangeDelegate <NSObject>
- (void)didChangeSupplier:(NSMutableArray *)SupplierListArray;
@end
@interface RimSupplierPage : UIViewController <UITableViewDataSource,UITableViewDelegate>


@property (nonatomic, strong) id<RimSupplierChangeDelegate> rimSupplierChangeDelegate;

@property(nonatomic,strong) NSMutableArray *checkedSupplier;

@property (nonatomic, strong) NSString *strItemcode;
@property (nonatomic, strong) NSString *callingFunction;

@end
