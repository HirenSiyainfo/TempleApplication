//
//  SupplierPage.h
//

#import <UIKit/UIKit.h>

@protocol RimSupplierPagePODelegate <NSObject>
- (void)didChangeSupplierPagePO:(NSMutableArray *)SupplierListArray withOtherData:(NSDictionary *) dictInfo;
@end
@interface RimSupplierPagePO : UIViewController <UITableViewDataSource,UITableViewDelegate>


@property (nonatomic, weak) id<RimSupplierPagePODelegate> rimSupplierPagePODelegate;

@property (nonatomic, strong) NSMutableArray *checkedSupplier;

@property (nonatomic, strong) NSString *strItemcode;
@property (nonatomic, strong) NSString *callingFunction;

@end
