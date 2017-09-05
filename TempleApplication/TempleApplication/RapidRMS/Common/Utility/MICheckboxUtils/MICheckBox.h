

#import <UIKit/UIKit.h>

@protocol TaxCheckBoxDelegate <NSObject>

- (void) taxCheckBoxClickedAtIndex:(NSString *)index withValue:(BOOL)checked withIndexPath:(NSIndexPath *)indexPath;

@end


@interface MICheckBox : UIButton {
	
	BOOL isCustomCheckBox;
	BOOL isChecked;
	id<TaxCheckBoxDelegate> delegate;
	
	NSIndexPath * indexPath;
}

@property (nonatomic,assign) BOOL isCustomCheckBox;
@property (nonatomic,assign) BOOL isChecked;
@property (nonatomic,retain) id delegate;
@property (nonatomic,retain) NSIndexPath * indexPath;

- (void) setDefault;
-(IBAction) checkBoxClicked;

@end
