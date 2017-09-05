//
//  DepartmentMultiple.h
//

#import <UIKit/UIKit.h>
#import "ItemInfoEditVC.h"

@protocol MultipleSubDepartmentDelegate <NSObject>
    -(void)newSubDepartmentSelected:(NSDictionary *)addedSubDepatmentDict;
    -(void)didChangeSubSelectedDepartment:(NSDictionary *)changeSubDepatmentDict;
@end

@interface MultipleSubDepartment : UIViewController

@property (nonatomic, weak) id<MultipleSubDepartmentDelegate> multipleSubDepartmentDelegate;

@property (nonatomic, strong) ItemInfoEditVC *objAddDelegate;

@property (nonatomic, strong) NSString *selectedDeptId;
@property (nonatomic, strong) NSString *strSubDeptName;
@property (nonatomic, strong) NSString *strSubDeptId;

@end