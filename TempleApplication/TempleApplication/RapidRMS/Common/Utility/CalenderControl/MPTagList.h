

#import <UIKit/UIKit.h>

@protocol MPTagListDelegate <NSObject>

@required

- (void)selectedTag:(NSString*)tagName withTabView:(id) tagView;

@end

@interface MPTagList : UIScrollView
{
    UIView *view;
    NSArray *textArray;
    CGSize sizeFit;
    UIColor *lblBackgroundColor;
    UIColor *lblTextColor;
    UIImage *imgCloseBtn;
}

@property (nonatomic) BOOL viewOnly;
@property (nonatomic, strong) UIView *view;
@property (nonatomic, strong) NSArray *textArray;
@property (nonatomic, weak) id<MPTagListDelegate> tagDelegate;
@property (nonatomic, strong) UIColor *highlightedBackgroundColor;
@property (nonatomic) BOOL automaticResize;
@property (nonatomic, retain) UIFont *font;
@property (nonatomic, assign) CGFloat labelMargin;
@property (nonatomic, assign) CGFloat bottomMargin;
@property (nonatomic, assign) CGFloat horizontalPadding;
@property (nonatomic, assign) CGFloat verticalPadding;
@property (nonatomic, assign) CGFloat minimumWidth;

- (void)setTagBackgroundColor:(UIColor *)color;
- (void)setTagHighlightColor:(UIColor *)color;
- (void)setTags:(NSArray *)array;
- (void)display;
@property (NS_NONATOMIC_IOSONLY, readonly) CGSize fittedSize;
- (void)setTagTextColor:(UIColor *)color;
- (void)setTagImagesColor:(UIImage *)image;
@end

@interface MPTagView : UIView

@property (nonatomic, strong) UIButton      *button;
@property (nonatomic, strong) UILabel       *label;

- (void)updateWithString:(NSString*)text font:(UIFont*)font constrainedToWidth:(CGFloat)maxWidth padding:(CGSize)padding minimumWidth:(CGFloat)minimumWidth textColor:(UIColor *) textColor textImage:(UIImage *) textImage;
- (void)setLabelText:(NSString*)text;

@end
