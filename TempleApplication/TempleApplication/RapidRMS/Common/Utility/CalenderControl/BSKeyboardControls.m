//
//  BSKeyboardControls.m
//  Example
//
//  Created by Simon B. Støvring on 11/01/13.
//  Copyright (c) 2013 simonbs. All rights reserved.
//

#import "BSKeyboardControls.h"
#import "iOSCombobox.h"

@interface BSKeyboardControls ()
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UIBarButtonItem *doneButton;
@property (nonatomic, strong) UIBarButtonItem *segmentedControlItem;
@end

@implementation BSKeyboardControls

#pragma mark -
#pragma mark Lifecycle

- (instancetype)init
{
    return [self initWithFields:nil];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFields:nil];
}

- (instancetype)initWithFields:(NSArray *)fields
{
    if (self = [super initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)])
    {
        self.toolbar = [[UIToolbar alloc] initWithFrame:self.frame];
        self.toolbar.barStyle = UIBarStyleBlackTranslucent;
        self.toolbar.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth);
        [self addSubview:self.toolbar];
        
        self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[ NSLocalizedStringFromTable(@"Previous", @"BSKeyboardControls", @"Previous button title."),
                                                                               NSLocalizedStringFromTable(@"Next", @"BSKeyboardControls", @"Next button title.") ]];
        [self.segmentedControl addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.segmentedControl setMomentary:YES];
        //[self.segmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
        [self.segmentedControl setEnabled:NO forSegmentAtIndex:BSKeyboardControlsDirectionPrevious];
        [self.segmentedControl setEnabled:NO forSegmentAtIndex:BSKeyboardControlsDirectionNext];
        self.segmentedControlItem = [[UIBarButtonItem alloc] initWithCustomView:self.segmentedControl];
        
        self.doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Done", @"BSKeyboardControls", @"Done button title.")
                                                             style:UIBarButtonItemStyleDone
                                                            target:self
                                                            action:@selector(doneButtonPressed:)];
        
        self.visibleControls = (BSKeyboardControlPreviousNext | BSKeyboardControlDone);
        
        self.fields = fields;
    }
    
    return self;
}

- (void)dealloc
{
    [self setFields:nil];
    [self setSegmentedControlTintControl:nil];
    [self setPreviousTitle:nil];
    [self setBarTintColor:nil];
    [self setNextTitle:nil];
    [self setDoneTitle:nil];
    [self setDoneTintColor:nil];
    [self setActiveField:nil];
    [self setToolbar:nil];
    [self setSegmentedControl:nil];
    [self setSegmentedControlItem:nil];
    [self setDoneButton:nil];
}

#pragma mark -
#pragma mark Public Methods

- (void)setActiveField:(id)activeField
{
    if (activeField != _activeField)
    {
        if ([self.fields containsObject:activeField])
        {
            _activeField = activeField;
        
            if (![activeField isFirstResponder])
            {
                [activeField becomeFirstResponder];
            }
        
            [self updateSegmentedControlEnabledStates];
        }
    }
}

- (void)setFields:(NSArray *)fields
{
    if (fields != _fields)
    {
        for (UIView *field in fields)
        {
            if ([field isKindOfClass:[UITextField class]])
            {
                ((UITextField *)field).inputAccessoryView = self;
            }
            else if ([field isKindOfClass:[UITextView class]])
            {
                ((UITextView *)field).inputAccessoryView = self;
            }
            else if ([field isKindOfClass:[iOSCombobox class]])
            {
                ((iOSCombobox *)field).inputAccessoryView = self;
            }
        }
        
        _fields = fields;
    }
}

- (void)setBarStyle:(UIBarStyle)barStyle
{
    if (barStyle != _barStyle)
    {
        self.toolbar.barStyle = barStyle;
        
        _barStyle = barStyle;
    }
}

- (void)setBarTintColor:(UIColor *)barTintColor
{
    if (barTintColor != _barTintColor)
    {
        self.toolbar.tintColor = barTintColor;
        
        _barTintColor = barTintColor;
    }
}

- (void)setSegmentedControlTintControl:(UIColor *)segmentedControlTintControl
{
    if (segmentedControlTintControl != _segmentedControlTintControl)
    {
        self.segmentedControl.tintColor = segmentedControlTintControl;
        
        _segmentedControlTintControl = segmentedControlTintControl;
    }
}

- (void)setPreviousTitle:(NSString *)previousTitle
{
    if (![previousTitle isEqualToString:_previousTitle])
    {
        [self.segmentedControl setTitle:previousTitle forSegmentAtIndex:BSKeyboardControlsDirectionPrevious];
        
        _previousTitle = previousTitle;
    }
}

- (void)setNextTitle:(NSString *)nextTitle
{
    if (![nextTitle isEqualToString:_nextTitle])
    {
        [self.segmentedControl setTitle:nextTitle forSegmentAtIndex:BSKeyboardControlsDirectionNext];
        
        _nextTitle = nextTitle;
    }
}

- (void)setDoneTitle:(NSString *)doneTitle
{
    if (![doneTitle isEqualToString:_doneTitle])
    {
        self.doneButton.title = doneTitle;
        
        _doneTitle = doneTitle;
    }
}

- (void)setDoneTintColor:(UIColor *)doneTintColor
{
    if (doneTintColor != _doneTintColor)
    {
        self.doneButton.tintColor = doneTintColor;
        
        _doneTintColor = doneTintColor;
    }
}

- (void)setVisibleControls:(BSKeyboardControl)visibleControls
{
    if (visibleControls != _visibleControls)
    {
        _visibleControls = visibleControls;

        self.toolbar.items = [self toolbarItems];
    }
}

#pragma mark -
#pragma mark Private Methods

- (void)segmentedControlValueChanged:(id)sender
{
    switch (self.segmentedControl.selectedSegmentIndex)
    {
        case BSKeyboardControlsDirectionPrevious:
            [self selectPreviousField];
            break;
        case BSKeyboardControlsDirectionNext:
            [self selectNextField];
            break;
        default:
            break;
    }
}

- (void)doneButtonPressed:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(keyboardControlsDonePressed:)])
    {
        [self.delegate keyboardControlsDonePressed:self];
    }
}

- (void)updateSegmentedControlEnabledStates
{
    NSInteger index = [self.fields indexOfObject:self.activeField];
    if (index != NSNotFound)
    {
        [self.segmentedControl setEnabled:(index > 0) forSegmentAtIndex:BSKeyboardControlsDirectionPrevious];
        [self.segmentedControl setEnabled:(index < self.fields.count - 1) forSegmentAtIndex:BSKeyboardControlsDirectionNext];
    }
}

- (void)selectPreviousField
{
    NSInteger index = [self.fields indexOfObject:self.activeField];
    if (index > 0)
    {
        index -= 1;
        UIView *field = (self.fields)[index];
        self.activeField = field;
        
        if ([self.delegate respondsToSelector:@selector(keyboardControls:selectedField:inDirection:)])
        {
            [self.delegate keyboardControls:self selectedField:field inDirection:BSKeyboardControlsDirectionPrevious];
        }
    }
}

- (void)selectNextField
{
    NSInteger index = [self.fields indexOfObject:self.activeField];
    if (index < self.fields.count - 1)
    {
        index += 1;
        UIView *field = (self.fields)[index];
        self.activeField = field;
        
        if ([self.delegate respondsToSelector:@selector(keyboardControls:selectedField:inDirection:)])
        {
            [self.delegate keyboardControls:self selectedField:field inDirection:BSKeyboardControlsDirectionNext];
        }
    }
}

- (NSArray *)toolbarItems
{
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:3];
    if (self.visibleControls & BSKeyboardControlPreviousNext)
    {
        [items addObject:self.segmentedControlItem];
    }
    
    if (self.visibleControls & BSKeyboardControlDone)
    {
        [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
        [items addObject:self.doneButton];
    }
    
    return items;
}

@end
