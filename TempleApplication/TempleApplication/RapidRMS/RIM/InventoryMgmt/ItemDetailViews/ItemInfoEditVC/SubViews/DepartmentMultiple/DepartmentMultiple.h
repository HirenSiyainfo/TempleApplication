//
//  DepartmentMultiple.h
//

#import <UIKit/UIKit.h>


@protocol AddDepartmentMultipleDelegate <NSObject>

    -(void)didselectDepartment :(NSMutableArray *)selectedDepartment;

@end

@interface DepartmentMultiple : UIViewController 

@property (nonatomic, weak) id<AddDepartmentMultipleDelegate> addDepartmentMultipleDelegate;

@property (nonatomic) BOOL isMultipleAllow;
@property (nonatomic, strong) NSMutableArray *checkedDepartment;
@property (nonatomic, strong) NSString *strItemcode;

@end
