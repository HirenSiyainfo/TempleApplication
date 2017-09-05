


#import "MICheckBox.h"

@implementation MICheckBox

@synthesize isChecked, delegate, indexPath, isCustomCheckBox;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		// Initialization code
		isCustomCheckBox = NO;
		//self.frame =frame;
		self.contentHorizontalAlignment  = UIControlContentHorizontalAlignmentRight;
		[self setImage:nil forState:UIControlStateNormal];
		[self addTarget:self action:@selector(checkBoxClicked) forControlEvents:UIControlEventTouchUpInside];
	}
    return self;
}

- (void) setDefault {
	if(self.isChecked == NO)
    {
		[self setImage:nil forState:UIControlStateNormal];
	}
    else
    {
		[self setImage:[UIImage imageNamed:@"soundCheckMark.png"] forState:UIControlStateNormal];
	}
}

-(IBAction) checkBoxClicked {
	if (!isCustomCheckBox) {
		if(self.isChecked == NO){
			self.isChecked =YES;
			[self setImage:[UIImage imageNamed:@"soundCheckMark.png"] forState:UIControlStateNormal];
		}else{
			self.isChecked =NO;
			[self setImage:nil forState:UIControlStateNormal];
		}
	}
	
	[delegate taxCheckBoxClickedAtIndex:[NSString stringWithFormat:@"%ld",(long)self.tag] withValue:self.isChecked withIndexPath:indexPath];
}

- (void)dealloc {
//    [super dealloc];
}


@end
