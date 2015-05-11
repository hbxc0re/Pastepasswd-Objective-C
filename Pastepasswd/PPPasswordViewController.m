//
//  PPPasswordViewController.m
//  Pastepasswd
//
//  Created by Spiros Gerokostas on 3/24/14.
//  Copyright (c) 2014 Spiros Gerokostas. All rights reserved.
//

#import "PPPasswordViewController.h"
#import "PPLabel.h"
#import "UIProgressView+Pastepasswd.h"
#import "PPPasswordView.h"
#import "NSString+Pastepasswd.h"
#import "PPSettingsViewController.h"
#import "TTTAttributedLabel.h"
#import "UIColor+Pastepasswd.h"
#import "UIFont+Pastepasswd.h"

#define ALPHA_LC            @"abcdefghijklmnopqrstuvwxyz"
#define ALPHA_UC            [ALPHA_LC uppercaseString]
#define NUMBERS             @"0123456789"
#define PUNCTUATION         @"~!@#$%^&*+=?/|:;"
#define AMBIGUOUS_UC        @"ACEFHJKMNPRTUVWXY"
#define AMBIGUOUS           @"B8G6I1l0OQDS5Z2"
#define AMBIGUOUS_NUMBERS   @"861052"
#define ALL                 @"!@#$%^&*()_+|abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"

const float maxChars = 30;

@interface PPPasswordViewController () <PPSettingsViewControllerDelegate>

@property (nonatomic, strong) UILabel *titleMainView;
@property (nonatomic, strong) TTTAttributedLabel *allowCharsRepeatLabel;
@property (nonatomic, strong) TTTAttributedLabel *avoidAmbiguousLabel;
@property (nonatomic, strong) TTTAttributedLabel *lengthLabel;
@property (nonatomic, strong) TTTAttributedLabel *lengthValueLabel;
@property (nonatomic, strong) UISegmentedControl *letters;
@property (nonatomic, strong) UISegmentedControl *typeChar;
@property (nonatomic, strong) UISwitch *switchAmbiguous;
@property (nonatomic, strong) UISwitch *switchAllowRepeat;
@property (nonatomic, strong) UISwitch *passwordMode;
@property (nonatomic, strong) UISlider *lengthSlider;
@property (nonatomic, strong) UISlider *digitsSlider;
@property (nonatomic, strong) TTTAttributedLabel *digitsLabel;
@property (nonatomic, strong) UILabel *digitsValueLabel;
@property (nonatomic, strong) UISlider *symbolSlider;
@property (nonatomic, strong) TTTAttributedLabel *symbolLabel;
@property (nonatomic, strong) TTTAttributedLabel *symbolValueLabel;

@property (nonatomic, strong) TTTAttributedLabel *clipboardLabel;
@property (nonatomic, strong) UISwitch *clipboard;

@property (nonatomic, assign) NSInteger length;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, assign) int typeLetterValue;
@property (nonatomic, assign) int typeCharValue;

@property (nonatomic, assign) int digitsValue;
@property (nonatomic, assign) int symbolValue;

@property (nonatomic, assign) BOOL ambiguous;
@property (nonatomic, assign) BOOL allowRepeat;
@property (nonatomic, assign) BOOL clipboardMode;
@property (nonatomic, strong, readwrite) NSString *mode;
@property (nonatomic, strong) PPPasswordView *passwordView;
@property (nonatomic, strong) TTTAttributedLabel *secureText;

- (void)_changeSwitch:(id)sender;
- (void)_changeAllowRepeat:(id)sender;
- (void)_sliderValue:(id)sender;
- (void)_selectTypeOfLetter:(id)sender;
- (void)_selectTypeOfChar:(id)sender;
- (void)_changePasswordMode:(id)sender;
- (void)_changeClipboard:(id)sender;
- (void)_generatePassword:(int)typeLetter typeChar:(int)typeChar;
//- (void)_generatePasswordWithLength:(NSInteger)length digitsLength:(NSInteger)digitsLength symbolsLength:(NSInteger)symbolsLength avoid:(BOOL)avoid;
- (void)_generatePasswordWithLength:(NSInteger)length digitsLength:(NSInteger)digitsLength symbolsLength:(NSInteger)symbolsLength avoid:(BOOL)avoid;


@end

@implementation PPPasswordViewController

#pragma mark - Accessors

- (UILabel *)titleMainView {
    if (!_titleMainView) {
        NSString *text = @"Pastepasswd";
        CGSize textSize = [text sizeWithAttributes:[NSDictionary dictionaryWithObject:[UIFont fontWithName:@"Avenir-Medium" size:18.0f] forKey:NSFontAttributeName]];
        _titleMainView = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, textSize.width, 44.0f)];
        _titleMainView.backgroundColor = [UIColor clearColor];
        _titleMainView.textAlignment = NSTextAlignmentCenter;
        _titleMainView.textColor = [UIColor whiteColor];
        _titleMainView.font = [UIFont fontWithName:@"Avenir-Medium" size:18.0f];
        _titleMainView.text = text;
        [_titleMainView sizeToFit];
    }
    return _titleMainView;
}

#pragma mark - NSObject

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.titleView = self.titleMainView;
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingsButton addTarget:self action:@selector(displaySettings:) forControlEvents:UIControlEventTouchDown];
    [settingsButton setFrame:CGRectMake(0.0f, 0.0f, 28.0f, 28.0f)];
    [settingsButton setBackgroundImage:[UIImage imageNamed:@"settings"] forState:UIControlStateNormal];
    [settingsButton setBackgroundImage:[UIImage imageNamed:@"settings"] forState:UIControlStateHighlighted];
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:settingsButton];
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
    for (UIView *parentView in self.navigationController.navigationBar.subviews)
        for (UIView *childView in parentView.subviews)
            if ([childView isKindOfClass:[UIImageView class]])
                [childView removeFromSuperview];
    
    _ambiguous = NO;
    _allowRepeat = YES;
    //_mode = @"1";
    _clipboardMode = YES;
    
    _passwordView = [[PPPasswordView alloc] initWithFrame:CGRectMake(0.0f, 64.0f, self.view.frame.size.width, 61.0f)];
    [self.view addSubview:_passwordView];
    
    _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    _progressView.frame = CGRectMake(0.0f, _passwordView.frame.origin.y + [PPPasswordView height], self.view.frame.size.width, 64.0f);
    _progressView.tintColor = [UIColor redColor];
    _progressView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    float progressValue = 4.0f / maxChars;
    [_progressView setProgress: progressValue];
    [_progressView setTrackTintColor:[UIColor pastepasswdTextColor]];
    [self.view addSubview:_progressView];

    CGFloat totalHeight = self.view.frame.size.height - 64 + [PPPasswordView height] + 2;
    //NSLog(@"self.view.frame.size.height %f", self.view.frame.size.height);
    //NSLog(@"totalHeight %f", totalHeight);
    CGFloat itemHeight = roundf(totalHeight / 7);
    
    //NSLog(@"itemHeight %f", itemHeight);
    CGSize result = [[UIScreen mainScreen] bounds].size;
    
    if (result.height == 480) {
        itemHeight -= 15.0f;
    } else if (result.height == 568) {
        itemHeight -= 16.0f;
    }
    //NSLog(@"after itemHeight %f", itemHeight);
    
   // UIView *t = [[UIView alloc] initWithFrame:CGRectMake(0,  _progressView.frame.origin.y + _progressView.frame.size.height, self.view.frame.size.width, totalHeight)];
    //t.backgroundColor = [UIColor redColor];
   // [self.view addSubview:t];
    
    UIView *t1 = [[UIView alloc] initWithFrame:CGRectMake(0,  _progressView.frame.origin.y + _progressView.frame.size.height, self.view.frame.size.width, itemHeight )];
    t1.backgroundColor = [UIColor colorWithRed:250.0f / 255.0f green:250.0f / 255.0f blue:250.0f / 255.0f alpha:1.0f];
    [self.view addSubview:t1];
    
    UIView *t2 = [[UIView alloc] initWithFrame:CGRectMake(0,  t1.frame.origin.y + itemHeight, self.view.frame.size.width, itemHeight)];
   //t2.backgroundColor = [UIColor blueColor];
    [self.view addSubview:t2];
    
    UIView *t3 = [[UIView alloc] initWithFrame:CGRectMake(0,  t2.frame.origin.y + itemHeight, self.view.frame.size.width, itemHeight )];
    t3.backgroundColor = [UIColor colorWithRed:250.0f / 255.0f green:250.0f / 255.0f blue:250.0f / 255.0f alpha:1.0f];
    [self.view addSubview:t3];

    UIView *t4 = [[UIView alloc] initWithFrame:CGRectMake(0,  t3.frame.origin.y + itemHeight, self.view.frame.size.width, itemHeight )];
    //t4.backgroundColor = [UIColor blueColor];
    [self.view addSubview:t4];
    
    UIView *t5 = [[UIView alloc] initWithFrame:CGRectMake(0,  t4.frame.origin.y + itemHeight, self.view.frame.size.width, itemHeight )];
    t5.backgroundColor = [UIColor colorWithRed:250.0f / 255.0f green:250.0f / 255.0f blue:250.0f / 255.0f alpha:1.0f];
    [self.view addSubview:t5];
    
    UIView *t6 = [[UIView alloc] initWithFrame:CGRectMake(0,  t5.frame.origin.y + itemHeight, self.view.frame.size.width, itemHeight )];
    //t6.backgroundColor = [UIColor blueColor];
    [self.view addSubview:t6];
    
    UIView *t7 = [[UIView alloc] initWithFrame:CGRectMake(0,  t6.frame.origin.y + itemHeight, self.view.frame.size.width, itemHeight)];
    t7.backgroundColor = [UIColor colorWithRed:250.0f / 255.0f green:250.0f / 255.0f blue:250.0f / 255.0f alpha:1.0f];
    [self.view addSubview:t7];
    
    _lengthLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    _lengthLabel.font = [UIFont mediumFontWithSize:16.0f];
    _lengthLabel.textColor = [UIColor pastepasswdTextColor];
    _lengthLabel.text = @"Length";
    _lengthLabel.numberOfLines = 0;
    [_lengthLabel sizeToFit];
    [self.view addSubview:_lengthLabel];
    
    CGRect lengthLabelRect = _lengthLabel.frame;
    lengthLabelRect.origin.x = 10.0f;
    lengthLabelRect.origin.y = t1.frame.origin.y + t1.frame.size.height / 2.0f - _lengthLabel.frame.size.height / 2.0f;
    _lengthLabel.frame = lengthLabelRect;
    
    _lengthSlider = [[UISlider alloc] initWithFrame:CGRectZero];
    _lengthSlider.tintColor = [UIColor pastepasswdTextColor];
    _lengthSlider.minimumValue = 0.0f;
    _lengthSlider.maximumValue = maxChars;
    _lengthSlider.value = 4.0f;
    _lengthSlider.continuous = YES;
    [_lengthSlider addTarget:self action:@selector(_sliderValue:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_lengthSlider];
    
    CGRect lengthSliderRect = _lengthSlider.frame;
    lengthSliderRect.origin.x = 80.0f;
    lengthSliderRect.origin.y = t1.frame.origin.y + t1.frame.size.height / 2.0f - itemHeight / 2.0f;
    lengthSliderRect.size.width = 200.0f;
    lengthSliderRect.size.height = itemHeight;
    _lengthSlider.frame = lengthSliderRect;
    
    _length = _lengthSlider.value;
    
    _lengthValueLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];

    _lengthValueLabel.numberOfLines = 0;
    _lengthValueLabel.font = [UIFont mediumFontWithSize:16.0f];
    _lengthValueLabel.textColor = [UIColor pastepasswdTextColor];
    _lengthValueLabel.text = [NSString stringWithFormat:@"%.0f", _lengthSlider.value];
    [_lengthValueLabel sizeToFit];
    _lengthValueLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_lengthValueLabel];

    CGRect lengthValueLabelRect = _lengthValueLabel.frame;
    lengthValueLabelRect.origin.x = self.view.frame.size.width - _lengthValueLabel.frame.size.width - 20.0f;
    lengthValueLabelRect.origin.y = t1.frame.origin.y + t1.frame.size.height / 2.0f - _lengthValueLabel.frame.size.height / 2.0f;
    lengthValueLabelRect.size.width = 20.0f;
    _lengthValueLabel.frame = lengthValueLabelRect;

    
    NSArray *lettersArray = [NSArray arrayWithObjects:@"abc", @"aBc", @"ABC", nil];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont fontWithName:@"Avenir-Medium" size:16.0f], NSFontAttributeName,
                                [UIColor pastepasswdMainColor], NSForegroundColorAttributeName,
                                nil];
    
    _letters = [[UISegmentedControl alloc] initWithItems:lettersArray];
    _letters.tintColor = [UIColor pastepasswdMainColor];
    _letters.selectedSegmentIndex = 1;
    [_letters addTarget:self action:@selector(_selectTypeOfLetter:) forControlEvents:UIControlEventValueChanged];
    
    CGRect lettersRect = _letters.frame;
    lettersRect.origin.x = 10.0f;
    lettersRect.origin.y = t2.frame.origin.y + t2.frame.size.height / 2.0f - 40.0f / 2.0f;
    lettersRect.size.width = self.view.frame.size.width - 20.0f;
    lettersRect.size.height = 40.0f;
    _letters.frame = lettersRect;
    [_letters setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [self.view addSubview:_letters];
    
    NSArray *mixArray = [NSArray arrayWithObjects:@"Numbers", @"Punctuation", nil];
    
    _typeChar = [[UISegmentedControl alloc] initWithItems:mixArray];
    _typeChar.tintColor = [UIColor pastepasswdMainColor];
    _typeChar.selectedSegmentIndex = 1;
    [_typeChar addTarget:self action:@selector(_selectTypeOfChar:) forControlEvents:UIControlEventValueChanged];
    
    CGRect typeCharRect = _typeChar.frame;
    typeCharRect.origin.x = 10.0f;
    typeCharRect.origin.y = t3.frame.origin.y + t3.frame.size.height / 2.0f - 40.0f / 2.0f;
    typeCharRect.size.width = self.view.frame.size.width - 20.0f;
    typeCharRect.size.height = 40.0f;
    _typeChar.frame = typeCharRect;
    [_typeChar setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [self.view addSubview:_typeChar];
    
    [[UISegmentedControl appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                             [UIColor whiteColor],NSForegroundColorAttributeName, nil]
                                                   forState:UIControlStateSelected];
    [[UISegmentedControl appearance] setContentPositionAdjustment:UIOffsetMake(0.0, 2.0) forSegmentType:UISegmentedControlSegmentAny barMetrics:UIBarMetricsDefault];
    
    _switchAmbiguous = [[UISwitch alloc] initWithFrame:CGRectZero];
    [_switchAmbiguous setOnTintColor:[UIColor pastepasswdMainColor]];
    [_switchAmbiguous addTarget:self action:@selector(_changeSwitch:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_switchAmbiguous];
    
    CGRect switchAmbiguousRect = _switchAmbiguous.frame;
    switchAmbiguousRect.origin.x = self.view.frame.size.width - _switchAmbiguous.frame.size.width - 10.0f;
    switchAmbiguousRect.origin.y = t4.frame.origin.y + t4.frame.size.height / 2.0f - _switchAmbiguous.frame.size.height / 2.0f;
    _switchAmbiguous.frame = switchAmbiguousRect;
    
    _switchAllowRepeat = [[UISwitch alloc] initWithFrame:CGRectZero];
    [_switchAllowRepeat setOn:YES];
    [_switchAllowRepeat setOnTintColor:[UIColor pastepasswdMainColor]];
    [_switchAllowRepeat addTarget:self action:@selector(_changeAllowRepeat:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_switchAllowRepeat];
    
    CGRect switchAllowRepeatRect = _switchAllowRepeat.frame;
    switchAllowRepeatRect.origin.x = self.view.frame.size.width - _switchAllowRepeat.frame.size.width - 10.0f;
    switchAllowRepeatRect.origin.y = t5.frame.origin.y + t5.frame.size.height / 2.0f - _switchAllowRepeat.frame.size.height / 2.0f;
    _switchAllowRepeat.frame = switchAllowRepeatRect;
    
    _passwordMode = [[UISwitch alloc] initWithFrame:CGRectMake(240, 450, 0, 0)];
    [_passwordMode setOn:NO];
    [_passwordMode setOnTintColor:[UIColor pastepasswdMainColor]];
    [_passwordMode addTarget:self action:@selector(_changePasswordMode:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_passwordMode];
    
    CGRect passwordModeRect = _passwordMode.frame;
    passwordModeRect.origin.x = self.view.frame.size.width - _passwordMode.frame.size.width - 10.0f;
    passwordModeRect.origin.y = t6.frame.origin.y + t6.frame.size.height / 2.0f - _passwordMode.frame.size.height / 2.0f;
    _passwordMode.frame = passwordModeRect;
    
    //labels
    _avoidAmbiguousLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    _avoidAmbiguousLabel.numberOfLines = 0;
    _avoidAmbiguousLabel.textColor = [UIColor pastepasswdTextColor];
    _avoidAmbiguousLabel.font = [UIFont mediumFontWithSize:16.0f];
    //_avoidAmbiguousLabel.text = @"Avoid ambiguity";
    _avoidAmbiguousLabel.text = @"Avoid ambiguous characters";
    [_avoidAmbiguousLabel sizeToFit];
    [self.view addSubview:_avoidAmbiguousLabel];
    
    CGRect avoidAmbiguousLabelRect = _avoidAmbiguousLabel.frame;
    avoidAmbiguousLabelRect.origin.x = 10.0f;
    avoidAmbiguousLabelRect.origin.y = t4.frame.origin.y + t4.frame.size.height / 2.0f - _avoidAmbiguousLabel.frame.size.height / 2.0f;
    _avoidAmbiguousLabel.frame = avoidAmbiguousLabelRect;
    
    _allowCharsRepeatLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    _allowCharsRepeatLabel.numberOfLines = 0;
    _allowCharsRepeatLabel.textColor = [UIColor pastepasswdTextColor];
    _allowCharsRepeatLabel.font = [UIFont mediumFontWithSize:16.0f];
     _allowCharsRepeatLabel.text = @"Allow characters to repeat";
    [_allowCharsRepeatLabel sizeToFit];
    [self.view addSubview:_allowCharsRepeatLabel];
    
    CGRect allowCharsRepeatLabelRect = _allowCharsRepeatLabel.frame;
    allowCharsRepeatLabelRect.origin.x = 10.0f;
    allowCharsRepeatLabelRect.origin.y = t5.frame.origin.y + t5.frame.size.height / 2.0f - _allowCharsRepeatLabel.frame.size.height / 2.0f;
    _allowCharsRepeatLabel.frame = allowCharsRepeatLabelRect;
    
    _secureText = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    _secureText.numberOfLines = 0;
    _secureText.textColor = [UIColor pastepasswdTextColor];
    _secureText.font = [UIFont mediumFontWithSize:16.0f];
    _secureText.text = @"Secure Text";
    [_secureText sizeToFit];
    [self.view addSubview:_secureText];
    
    CGRect secureTextLabelRect = _secureText.frame;
    secureTextLabelRect.origin.x = 10.0f;
    secureTextLabelRect.origin.y = t6.frame.origin.y + t6.frame.size.height / 2.0f - _secureText.frame.size.height / 2.0f;
    _secureText.frame = secureTextLabelRect;
    
    //mode 2
    _digitsLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    _digitsLabel.numberOfLines = 0;
    _digitsLabel.font = [UIFont mediumFontWithSize:16.0f];
    _digitsLabel.textColor = [UIColor pastepasswdTextColor];
    _digitsLabel.text = @"Digits";
    [_digitsLabel sizeToFit];
    [self.view addSubview:_digitsLabel];
    
    CGRect digitsLabelRect = _digitsLabel.frame;
    digitsLabelRect.origin.x = 10.0f;
    digitsLabelRect.origin.y = t2.frame.origin.y + t2.frame.size.height / 2.0f - _digitsLabel.frame.size.height / 2.0f;
    _digitsLabel.frame = digitsLabelRect;
    
    _digitsSlider = [[UISlider alloc] initWithFrame:CGRectMake(70.0f, 260.0f, 200.0f, 25.0f)];
    _digitsSlider.minimumValue = 0.0f;
    _digitsSlider.maximumValue = 10.0f;
    _digitsSlider.tintColor = [UIColor pastepasswdTextColor];
    _digitsSlider.value = 1.0f;
    [_digitsSlider setHidden:YES];
    _digitsSlider.continuous = YES;
    [_digitsSlider addTarget:self action:@selector(_digitsSliderValue:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_digitsSlider];
    
    CGRect digitsSliderRect = _digitsSlider.frame;
    digitsSliderRect.origin.x = 80.0f;
    digitsSliderRect.origin.y = t2.frame.origin.y + t2.frame.size.height / 2.0f - itemHeight / 2.0f;
    digitsSliderRect.size.width = 200.0f;
    digitsSliderRect.size.height = itemHeight;
    _digitsSlider.frame = digitsSliderRect;
    
    _digitsValueLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    _digitsValueLabel.numberOfLines = 0;
    _digitsValueLabel.font = [UIFont mediumFontWithSize:16.0f];
    _digitsValueLabel.textColor = [UIColor pastepasswdTextColor];
    _digitsValueLabel.text = [NSString stringWithFormat:@"%.0f", _digitsSlider.value];
    [_digitsValueLabel sizeToFit];
    _digitsValueLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_digitsValueLabel];
    
    CGRect digitsValueLabelRect = _digitsValueLabel.frame;
    digitsValueLabelRect.origin.x = self.view.frame.size.width - _digitsValueLabel.frame.size.width - 20.0f;
    digitsValueLabelRect.origin.y = t2.frame.origin.y + t2.frame.size.height / 2.0f - itemHeight / 2.0f;
    digitsValueLabelRect.size.width = 20.0;
    digitsValueLabelRect.size.height = itemHeight;
    _digitsValueLabel.frame = digitsValueLabelRect;

    _digitsValue = _digitsSlider.value;
    
    _symbolLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    _symbolLabel.numberOfLines = 0;
    _symbolLabel.font = [UIFont mediumFontWithSize:16.0f];
    _symbolLabel.textColor = [UIColor pastepasswdTextColor];
    _symbolLabel.text = @"Symbols";
    [_symbolLabel sizeToFit];
    [self.view addSubview:_symbolLabel];
    
    CGRect symbolsLabelRect = _symbolLabel.frame;
    symbolsLabelRect.origin.x = 10.0f;
    symbolsLabelRect.origin.y = t3.frame.origin.y + t3.frame.size.height / 2.0f - _symbolLabel.frame.size.height / 2.0f;
    _symbolLabel.frame = symbolsLabelRect;
    
    _symbolSlider = [[UISlider alloc] initWithFrame:CGRectZero];
    _symbolSlider.minimumValue = 0.0f;
    _symbolSlider.tintColor = [UIColor pastepasswdTextColor];
    _symbolSlider.maximumValue = 16;
    _symbolSlider.value = 0.0f;
    [_symbolSlider setHidden:YES];
    _symbolSlider.continuous = YES;
    [_symbolSlider addTarget:self action:@selector(_symbolSliderValue:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_symbolSlider];
    
    CGRect symbolSliderRect = _symbolSlider.frame;
    symbolSliderRect.origin.x = 80.0f;
    symbolSliderRect.origin.y = t3.frame.origin.y + t3.frame.size.height / 2.0f - itemHeight / 2.0f;
    symbolSliderRect.size.width = 200.0f;
    symbolSliderRect.size.height = itemHeight;
    _symbolSlider.frame = symbolSliderRect;

    _symbolValueLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    _symbolValueLabel.numberOfLines = 0;
    _symbolValueLabel.font = [UIFont mediumFontWithSize:16.0f];
    _symbolValueLabel.textColor = [UIColor pastepasswdTextColor];
    _symbolValueLabel.text = [NSString stringWithFormat:@"%.0f", _symbolSlider.value];
    [_symbolValueLabel sizeToFit];
    _symbolValueLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_symbolValueLabel];
    
    CGRect symbolValueLabelRect = _symbolValueLabel.frame;
    symbolValueLabelRect.origin.x = self.view.frame.size.width - _symbolValueLabel.frame.size.width - 20.0f;
    symbolValueLabelRect.origin.y = t3.frame.origin.y + t3.frame.size.height / 2.0f - itemHeight / 2.0f;
    symbolValueLabelRect.size.width = 20.0;
    symbolValueLabelRect.size.height = itemHeight;
    _symbolValueLabel.frame = symbolValueLabelRect;
    
    _symbolValue = _symbolSlider.value;
    
    _clipboardLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    _clipboardLabel.numberOfLines = 0;
    _clipboardLabel.font = [UIFont mediumFontWithSize:16.0f];
    _clipboardLabel.textColor = [UIColor pastepasswdTextColor];
    _clipboardLabel.text = @"Copy to Clipboard";
    [_clipboardLabel sizeToFit];
    [self.view addSubview:_clipboardLabel];
    
    CGRect clipboardLabelRect = _clipboardLabel.frame;
    clipboardLabelRect.origin.x = 10.0f;
    clipboardLabelRect.origin.y = t7.frame.origin.y + t7.frame.size.height / 2.0f - _clipboardLabel.frame.size.height / 2.0f;
    _clipboardLabel.frame = clipboardLabelRect;
    
    _clipboard = [[UISwitch alloc] initWithFrame:CGRectMake(240.0f, 500.0f, 0.0f, 0.0f)];
    [_clipboard setOn:YES];
    [_clipboard setOnTintColor:[UIColor pastepasswdMainColor]];
    [_clipboard addTarget:self action:@selector(_changeClipboard:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_clipboard];
    
    CGRect clipboardRect = _clipboard.frame;
    clipboardRect.origin.x = self.view.frame.size.width - _clipboard.frame.size.width - 10.0f;
    clipboardRect.origin.y = t7.frame.origin.y + t7.frame.size.height / 2.0f - _clipboard.frame.size.height / 2.0f;
    _clipboard.frame = clipboardRect;
    
    _typeLetterValue = 1;
    _typeCharValue = 1;
	
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_changeMode:) name:@"changeMode" object:nil];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *value = [userDefaults objectForKey:@"mode"];
    
    if ([value isEqualToString:@"1"]) {
        _mode = @"1";
        [_digitsSlider setHidden:YES];
        [_symbolSlider setHidden:YES];
        [_digitsLabel setHidden:YES];
        [_symbolLabel setHidden:YES];
        [_digitsValueLabel setHidden:YES];
        [_symbolValueLabel setHidden:YES];
        
        [_letters setHidden:NO];
        [_typeChar setHidden:NO];
        
        [self _generatePassword:_typeLetterValue typeChar:_typeCharValue];
    } else {
        _mode = @"2";
        [_digitsSlider setHidden:NO];
        [_symbolSlider setHidden:NO];
        [_digitsLabel setHidden:NO];
        [_symbolLabel setHidden:NO];
        [_digitsValueLabel setHidden:NO];
        [_symbolValueLabel setHidden:NO];
        
        [_letters setHidden:YES];
        [_typeChar setHidden:YES];
        
        [self _generatePasswordWithLength:_length digitsLength:_digitsValue symbolsLength:_symbolValue avoid:_allowRepeat];
    }
}

- (void)_changeMode:(NSNotification *)notification {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *value = [userDefaults objectForKey:@"mode"];
    
    //NSLog(@"value %@", value);
    
    if ([value isEqualToString:@"1"]) {
        _mode = @"1";
        [_digitsSlider setHidden:YES];
        [_symbolSlider setHidden:YES];
        [_digitsLabel setHidden:YES];
        [_symbolLabel setHidden:YES];
        [_digitsValueLabel setHidden:YES];
        [_symbolValueLabel setHidden:YES];
        
        [_letters setHidden:NO];
        [_typeChar setHidden:NO];
        
        [self _generatePassword:_typeLetterValue typeChar:_typeCharValue];
    } else {
        _mode = @"2";
        [_digitsSlider setHidden:NO];
        [_symbolSlider setHidden:NO];
        [_digitsLabel setHidden:NO];
        [_symbolLabel setHidden:NO];
        [_digitsValueLabel setHidden:NO];
        [_symbolValueLabel setHidden:NO];
        
        [_letters setHidden:YES];
        [_typeChar setHidden:YES];
        
        [self _generatePasswordWithLength:_length digitsLength:_digitsValue symbolsLength:_symbolValue avoid:_allowRepeat];
    }
}

- (void)displaySettings:(id)sender {
    PPSettingsViewController *settingsViewController = [[PPSettingsViewController alloc] init];
    settingsViewController.delegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

- (void)closeSettings {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private Implementation

- (void)_generatePasswordWithLength:(NSInteger)length digitsLength:(NSInteger)digitsLength symbolsLength:(NSInteger)symbolsLength avoid:(BOOL)avoid {
    
   NSString *result = @"";
    NSString *selectedSet = @"";
    
    NSInteger totalChars = 0;
    NSInteger totalDigits = 0;
    NSInteger totalSymbols = 0;
    
    totalChars = length - digitsLength - symbolsLength;
    //NSLog(@"totalChars %ld", (long)totalChars);
    
    if (totalChars <= 0) {
       
        if (digitsLength >= length) {
           totalDigits = length;
            totalSymbols = 0;
            totalChars = 0;
            //NSLog(@"0 !!!!!");
            //NSLog(@"totalDigits %ld", (long)totalDigits);
            //NSLog(@"totalSymbols %ld", (long)totalSymbols);
            //NSLog(@"totalChars %ld", (long)totalChars);

        } else {
            totalDigits = digitsLength;
            //its negative to we are doing add instead of sub because we want to sub
            //NSInteger s = symbolsLength + totalChars;
            totalSymbols = symbolsLength + totalChars;
            
            //NSLog(@"before totalChars %ld", (long)totalChars);
            totalChars = 0;
             //NSLog(@"1 !!!!!");
            //NSLog(@"totalDigits %ld", (long)totalDigits);
            //NSLog(@"totalSymbols %ld", (long)totalSymbols);
            //NSLog(@"totalChars %ld", (long)totalChars);
            
            if (totalDigits + totalSymbols == length) {
                //NSLog(@"PASS 1 !!!!!");
                
            }
        }
    } else {
        
        totalDigits = digitsLength;
        totalSymbols = symbolsLength;

        
        //NSLog(@"2 !!!!!");
        //NSLog(@"totalDigits %ld", (long)totalDigits);
        //NSLog(@"totalSymbols %ld", (long)totalSymbols);
        //NSLog(@"totalChars %ld", (long)totalChars);
        
        if (totalChars + totalDigits + totalSymbols == length) {
            //NSLog(@"PASS 2 !!!!!");
            
        }
    }
    //NSLog(@"Results");
    //NSLog(@"totalDigits %ld", (long)totalDigits);
    //NSLog(@"totalSymbols %ld", (long)totalSymbols);
    //NSLog(@"totalChars %ld", (long)totalChars);
    
    //updates digits
    
    NSString *selectedDigits = @"";
    
    if (_ambiguous) {
        selectedDigits = [selectedDigits stringByAppendingString:@"3479"];
    } else {
        selectedDigits = [selectedDigits stringByAppendingString:NUMBERS];
    }
    
    NSRange range;
    range.length = 1;
    
    for (int i = 0; i < totalDigits; i++) {
        range.location = arc4random_uniform((uint32_t)[selectedDigits length]);
        selectedSet = [selectedSet stringByAppendingString:[selectedDigits substringWithRange:range]];
    }
    
    //end updates
    
    //updates punctuation
    NSString *selectedPunc = @"";
    
    selectedPunc = [selectedPunc stringByAppendingString:PUNCTUATION];
    
    NSRange rangePunc;
    rangePunc.length = 1;
    
    for (int i = 0; i < totalSymbols; i++) {
        rangePunc.location = arc4random_uniform((uint32_t)[selectedPunc length]);
        selectedSet = [selectedSet stringByAppendingString:[selectedPunc substringWithRange:rangePunc]];
    }
    
    //end
    
    if (totalChars > 0) {
        
        if (!avoid) {
            
            NSArray *charsArr = [[NSArray alloc] initWithObjects:@"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o", @"p", @"q", @"r", @"s", @"t",@"u", @"v", @"w", @"x", @"y", @"z", @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S",@"T",@"U",@"V", @"W", @"X", @"Y", @"Z", nil];
            
            NSMutableSet *choiceChars = [[NSMutableSet alloc] init];
            
            while ([choiceChars count] < totalChars) {
                int randomIndex = arc4random_uniform((uint32_t)[charsArr count]);
                [choiceChars addObject:[charsArr objectAtIndex:randomIndex]];
            }
            
            NSString *non = [[choiceChars allObjects] componentsJoinedByString:@""];
            NSLog(@"non %@", non);
            selectedSet = [selectedSet stringByAppendingString:non];
            
        } else {
            
            NSRange range;
            NSString *chars = @"";
            NSString *selectedChars = @"";
            range.length = 1;
            
            if (_ambiguous) {
                selectedChars = [selectedChars stringByAppendingString:@"ACEFHJKMNPRTUVWXY"];
                selectedChars = [selectedChars stringByAppendingString:@"acefhjkmnprtuvwxy"];
            } else {
                selectedChars = [selectedChars stringByAppendingString:ALPHA_UC];
                selectedChars = [selectedChars stringByAppendingString:ALPHA_LC];
            }
            
            for (int i = 0; i < totalChars; i++) {
                range.location = arc4random() % [selectedChars length];
                chars = [chars stringByAppendingString:[selectedChars substringWithRange:range]];
            }
            
            selectedSet = [selectedSet stringByAppendingString:chars];
        }
    }
    
    
    NSUInteger strLength = [selectedSet length];
    unichar *buffer = calloc(strLength, sizeof(unichar));
    [selectedSet getCharacters:buffer range:NSMakeRange(0, strLength)];
    
    for (int i = (uint32_t)strLength - 1; i >= 0; i--) {
        int j = arc4random() % (i + 1);
        unichar c = buffer[i];
        buffer[i] = buffer[j];
        buffer[j] = c;
    }
    
    result = [NSString stringWithCharacters:buffer length:strLength];
    free(buffer);
    
    //NSLog(@"Result %@", result);
    
    if (_clipboardMode) {
        NSString *copyString = result;
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setString:copyString];
    }
    
    _passwordView.passwordSecureLabel.text = result;
    
//    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:result];
//    
//    NSRange  searchedRange = NSMakeRange(0, [result length]);
//    NSString *pattern = @"\\d+";
//    NSError  *error = nil;
//    
//    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
//    
//    NSArray* matches = [regex matchesInString:result options:0 range: searchedRange];
//    for (NSTextCheckingResult* match in matches)
//    {
//        NSString* matchText = [result substringWithRange:[match range]];
//        [attStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:16] range:[match range]];
//        NSLog(@"Match: %@", matchText);
//    }
//    
//    _passwordLabel.attributedText = attStr;
    
    //updates
    
    [_passwordView.attributedLabel setText:result afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        
        NSRange  searchedRange = NSMakeRange(0, [result length]);
        NSString *pattern = @"\\d+";
        NSError  *error = nil;
        
        NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
        
        NSArray* matches = [regex matchesInString:result options:0 range: searchedRange];
        
        for (NSTextCheckingResult* match in matches) {
            //NSString* matchText = [result substringWithRange:[match range]];
           // NSLog(@"Match: %@", matchText);
             [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:(id)[UIColor colorWithRed:76.0f / 255.0f green:90.0f / 255.0f blue:100.0f / 255.0f alpha:1.0f].CGColor range:[match range]];
        }
        
        NSString *patternWords = @"[a-zA-Z]+";
        NSError  *error2 = nil;

        NSRegularExpression* regexWords = [NSRegularExpression regularExpressionWithPattern:patternWords options:0 error:&error2];
        
        NSArray* matchesWords = [regexWords matchesInString:result options:0 range: searchedRange];
        
        for (NSTextCheckingResult* match in matchesWords) {
            //NSString* matchText = [result substringWithRange:[match range]];
            //NSLog(@"Match2: %@", matchText);
            [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:(id)[UIColor pastepasswdMainColor].CGColor range:[match range]];
        }

        
        return mutableAttributedString;
    }];
    
    //check for duplicates
    NSString *input = result;
    
    NSMutableSet *seenCharacters = [NSMutableSet set];
    NSMutableString *resultString = [NSMutableString string];
    [input enumerateSubstringsInRange:NSMakeRange(0, input.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        
        if (![seenCharacters containsObject:substring]) {
            [seenCharacters addObject:substring];
            [resultString appendString:substring];
        } else {
           // NSLog(@"duplicates %@", substring);
        }
    }];
}

//- (void)_generatePasswordWithLength:(NSInteger)length digitsLength:(NSInteger)digitsLength symbolsLength:(NSInteger)symbolsLength avoid:(BOOL)avoid {
//    
//    NSString *result = @"";
//    NSString *selectedSet = @"";
//    
//    NSInteger totalChars = 0;
//    NSInteger totalDigits;
//    NSInteger totalSymbols;
//    
//    if (digitsLength >= symbolsLength) {
//        totalChars = length - digitsLength - symbolsLength;
//         NSLog(@"before totalChars %ld", (long)totalChars);
//        if (totalChars <= 0) {
//            totalDigits = length;
//            totalSymbols = length - digitsLength;
//            if (totalSymbols <= 0) {
//                totalSymbols = 0;
//            }
//            totalChars = 0;
//            NSLog(@"0");
//            NSLog(@"totalDigits %ld", (long)totalDigits);
//            NSLog(@"totalSymbols %ld", (long)totalSymbols);
//            NSLog(@"after totalChars %ld", (long)totalChars);
//        } else {
//            totalDigits = digitsLength;
//            totalSymbols = symbolsLength;
//            NSLog(@"1");
//            NSLog(@"totalDigits %ld", (long)totalDigits);
//             NSLog(@"totalSymbols %ld", (long)totalSymbols);
//            NSLog(@"totalChars %ld", (long)totalChars);
//        }
//    } else {
//        
//        totalDigits = digitsLength;
//        totalSymbols = symbolsLength;
//        totalChars = length - digitsLength - symbolsLength;
//        
//       NSLog(@"after totalChars %ld", (long)totalChars);
//        NSLog(@"test after totalChars %ld",  totalSymbols  + (long)totalChars);
//        
//        if (totalChars <= 0) {
//            totalSymbols = totalSymbols + totalChars;
//            NSLog(@"totalSymbols %ld", (long)totalSymbols);
//            if (totalSymbols <= 0) {
//                totalSymbols = 0;
//            }
//            totalChars = 0;
//        } else {
//           // NSLog(@">>>>>>>>> totalChars %ld", (long)totalChars);
//        }
//        
//        NSLog(@"2");
//        NSLog(@"totalDigits %ld", (long)totalDigits);
//       NSLog(@"totalSymbols %ld", (long)totalSymbols);
//        NSLog(@"totalChars %ld", (long)totalChars);
//    }
//    
//    //NSLog(@"RESULTS");
//    //NSLog(@"totalDigits %ld", (long)totalDigits);
//   // NSLog(@"totalSymbols %ld", (long)totalSymbols);
//    //NSLog(@"final totalChars %ld", (long)totalChars);
//    
//    NSArray *nums;
//    
//    if (_ambiguous) {
//        nums = [[NSArray alloc] initWithObjects:@"3", @"4", @"7", @"9", nil];
//    } else {
//        nums = [[NSArray alloc] initWithObjects:@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", nil];
//    }
//    
//    NSMutableSet *choice = [[NSMutableSet alloc] init];
//    while ([choice count] < totalDigits) {
//        int randomIndex = arc4random_uniform((uint32_t)[nums count]);
//        [choice addObject:[nums objectAtIndex:randomIndex]];
//    }
//
//    selectedSet = [selectedSet stringByAppendingString:[[choice allObjects] componentsJoinedByString:@""]];
//    
//    NSArray *puncArr = [[NSArray alloc] initWithObjects:@"~", @"!", @"@", @"#", @"$", @"%", @"^", @"&", @"*", @"+", @"=", @"?", @"/", @"|", @":", @";", nil];
//    
//    NSMutableSet *punc = [[NSMutableSet alloc] init];
//    while ([punc count] < totalSymbols) {
//        int randomIndex = arc4random_uniform((uint32_t)[puncArr count]);
//        [punc addObject:[puncArr objectAtIndex:randomIndex]];
//    }
//    
//    selectedSet = [selectedSet stringByAppendingString:[[punc allObjects] componentsJoinedByString:@""]];
//
//    if (totalChars > 0) {
//        
//        if (!avoid) {
//            
//            NSArray *charsArr = [[NSArray alloc] initWithObjects:@"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o", @"p", @"q", @"r", @"s", @"t",@"u", @"v", @"w", @"x", @"y", @"z", @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S",@"T",@"U",@"V", @"W", @"X", @"Y", @"Z", nil];
//            
//            NSMutableSet *choiceChars = [[NSMutableSet alloc] init];
//            
//            while ([choiceChars count] < totalChars) {
//                int randomIndex = arc4random_uniform((uint32_t)[charsArr count]);
//                [choiceChars addObject:[charsArr objectAtIndex:randomIndex]];
//            }
//            
//          
//            NSString *non = [[choiceChars allObjects] componentsJoinedByString:@""];
//            
//           
//            selectedSet = [selectedSet stringByAppendingString:non];
//            
//        } else {
//           
//            NSRange range;
//            NSString *chars = @"";
//            NSString *selectedChars = @"";
//            range.length = 1;
//            
//            
//            if (_ambiguous) {
//                selectedChars = [selectedChars stringByAppendingString:@"ACEFHJKMNPRTUVWXY"];
//                selectedChars = [selectedChars stringByAppendingString:@"acefhjkmnprtuvwxy"];
//            } else {
//                selectedChars = [selectedChars stringByAppendingString:ALPHA_UC];
//                selectedChars = [selectedChars stringByAppendingString:ALPHA_LC];
//            }
//            
//           
//            
//            for (int i = 0; i < totalChars; i++) {
//                range.location = arc4random() % [selectedChars length];
//                chars = [chars stringByAppendingString:[selectedChars substringWithRange:range]];
//            }
//
//            
//            selectedSet = [selectedSet stringByAppendingString:chars];
//        }
//    }
//
//    
//    NSUInteger strLength = [selectedSet length];
//    unichar *buffer = calloc(strLength, sizeof(unichar));
//    [selectedSet getCharacters:buffer range:NSMakeRange(0, strLength)];
//    
//    for (int i = (uint32_t)strLength - 1; i >= 0; i--) {
//        int j = arc4random() % (i + 1);
//        unichar c = buffer[i];
//        buffer[i] = buffer[j];
//        buffer[j] = c;
//    }
//    
//    result = [NSString stringWithCharacters:buffer length:strLength];
//    free(buffer);
//    
//   
//    
//    if (_clipboardMode) {
//        NSString *copyString = result;
//        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
//        [pasteboard setString:copyString];
//    }
//
//    _passwordView.passwordSecureLabel.text = result;
//    
//    NSCharacterSet *flags1 = [NSCharacterSet punctuationCharacterSet];
//    NSCharacterSet *flags2 = [NSCharacterSet symbolCharacterSet];
//    NSCharacterSet *flags3 = [NSCharacterSet whitespaceCharacterSet];
//    
//    [_passwordView.attributedLabel setText:result afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
//        
//        for (int i = 0; i < [result length]; i++) {
//            if (isdigit([result characterAtIndex:i])) {
//                unichar word = [result characterAtIndex:i];
//                NSString *value = [NSString stringWithCharacters:&word length:1];
//                NSRange range = [result rangeOfString:value];
//                [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:(id)[UIColor colorWithRed:76.0f / 255.0f green:90.0f / 255.0f blue:100.0f / 255.0f alpha:1.0f].CGColor range:range];
//            }
//            
//            if ([flags1 characterIsMember:[result characterAtIndex:i]] | [flags2 characterIsMember:[result characterAtIndex:i]] | [flags3 characterIsMember:[result characterAtIndex:i]]) {
//                unichar word = [result characterAtIndex:i];
//                NSString *value = [NSString stringWithCharacters:&word length:1];
//                NSRange range = [result rangeOfString:value];
//                [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:(id)[UIColor colorWithRed:70.0f / 255.0f green:195.0f / 255.0f blue:182.0f / 255.0f alpha:1.0f].CGColor range:range];
//            }
//        }
//        return mutableAttributedString;
//    }];
//    
//    
//    //check for dup
//    NSString *input = result;
//    
//    
//    
//    NSMutableSet *seenCharacters = [NSMutableSet set];
//    NSMutableString *resultString = [NSMutableString string];
//    [input enumerateSubstringsInRange:NSMakeRange(0, input.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
//        
//        if (![seenCharacters containsObject:substring]) {
//            [seenCharacters addObject:substring];
//            [resultString appendString:substring];
//        } else {
//            //NSLog(@"duplicates %@", substring);
//        }
//    }];
//}

- (void)_digitsSliderValue:(id)sender {
    UISlider *slider = (UISlider *)sender;
    _digitsValue = (int)slider.value;
    _digitsValueLabel.text = [NSString stringWithFormat:@"%d", _digitsValue];
     [self _generatePasswordWithLength:_length digitsLength:_digitsValue symbolsLength:_symbolValue avoid:_allowRepeat];
}

- (void)_symbolSliderValue:(id)sender {
    UISlider *slider = (UISlider *)sender;
    _symbolValue = (int)slider.value;
    _symbolValueLabel.text = [NSString stringWithFormat:@"%d", _symbolValue];
     [self _generatePasswordWithLength:_length digitsLength:_digitsValue symbolsLength:_symbolValue avoid:_allowRepeat];
}

- (void)_changePasswordMode:(id)sender {
    if([sender isOn]) {
        [_passwordView slideOut];
    } else {
        [_passwordView slideIn];
    }
}

- (void)_changeClipboard:(id)sender {
    if ([sender isOn]) {
        _clipboardMode = YES;
    } else {
        _clipboardMode = NO;
    }
}

- (void)_changeAllowRepeat:(id)sender {
    if([sender isOn]) {
        _allowRepeat = YES;
    } else {
        _allowRepeat = NO;
    }
   
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *value = [userDefaults objectForKey:@"mode"];
    
    if ([value isEqualToString:@"1"]) {
        [self _generatePassword:_typeLetterValue typeChar:_typeCharValue];
    } else {
         [self _generatePasswordWithLength:_length digitsLength:_digitsValue symbolsLength:_symbolValue avoid:_allowRepeat];
    }
}

- (void)_changeSwitch:(id)sender {
    if([sender isOn]) {
        _ambiguous = YES;
    } else {
        _ambiguous = NO;
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *value = [userDefaults objectForKey:@"mode"];
    
    if ([value isEqualToString:@"1"]) {
        [self _generatePassword:_typeLetterValue typeChar:_typeCharValue];
    } else {
         [self _generatePasswordWithLength:_length digitsLength:_digitsValue symbolsLength:_symbolValue avoid:_allowRepeat];
    }
}

- (void)_sliderValue:(id)sender {
    UISlider *slider = (UISlider *)sender;
    _length = slider.value;
    //NSLog(@"_length %ld", (long)_length);
     _lengthValueLabel.text = [NSString stringWithFormat:@"%ld", (long)_length];
    
    float progressValue = (float)slider.value / maxChars;
    [_progressView setProgress:progressValue animated:YES];
    
    //NSLog(@"_length %ld", (long)_length);
    
    if (_length >= 0 && _length <= 6) {
        //NSLog(@"invalid password");
        _progressView.tintColor = [UIColor redColor];
    } else if (_length >= 6 && _length <= 9) {
        //NSLog(@"very weak password");
        _progressView.tintColor = [UIColor redColor];
    } else if (_length >= 9 && _length <= 11) {
        //NSLog(@"weak password");
        _progressView.tintColor = [UIColor orangeColor];
    } else if (_length >= 11 && _length <= 19) {
        //NSLog(@"reasonable password");
        _progressView.tintColor = [UIColor yellowColor];
    } else if (_length >= 19 && _length <= 39) {
        //NSLog(@"strong password");
        _progressView.tintColor = [UIColor greenColor];
    } else if (_length >= maxChars) {
        //NSLog(@"very strong password");
        _progressView.tintColor = [UIColor cyanColor];
    }
    
    if (_length >= 0 && _length < 30) {
        if ([_mode isEqualToString:@"1"]) {
            [self _generatePassword:_typeLetterValue typeChar:_typeCharValue];
        } else {
             [self _generatePasswordWithLength:_length digitsLength:_digitsValue symbolsLength:_symbolValue avoid:_allowRepeat];
        }
    }
}

- (void)_selectTypeOfLetter:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    int value = (int)segmentedControl.selectedSegmentIndex;
    _typeLetterValue = value;
    [self _generatePassword:value typeChar:_typeCharValue];
}

- (void)_selectTypeOfChar:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    int value = (int)segmentedControl.selectedSegmentIndex;
    _typeCharValue = value;
    [self _generatePassword:_typeLetterValue typeChar:value];
}

-(void)_generatePassword:(int)typeLetter typeChar:(int)typeChar {
    NSString *selectedSet = @"";
    
    switch (typeLetter) {
        case 0: // lowercase
            selectedSet = [selectedSet stringByAppendingString:ALPHA_LC];
            break;
        case 1: // mixed case
            selectedSet = [selectedSet stringByAppendingString:ALPHA_LC];
            selectedSet = [selectedSet stringByAppendingString:ALPHA_UC];
            break;
        case 2: // uppercase
            
            if (_ambiguous) {
                selectedSet = [selectedSet stringByAppendingString:@"ACEFHJKMNPRTUVWXY"];
            } else {
                 selectedSet = [selectedSet stringByAppendingString:ALPHA_UC];
            }
            break;
        default:
            break;
    }
    
    switch (typeChar) {
        //case 0: // alpha only
          
            //break;
        case 0: // add numbers
            if (_ambiguous) {
                selectedSet = [selectedSet stringByAppendingString:@"3479"];
            } else {
                selectedSet = [selectedSet stringByAppendingString:NUMBERS];
            }
            break;
        case 1: // add numbers and punctuation
            if (_ambiguous) {
                selectedSet = [selectedSet stringByAppendingString:@"3479"];
            } else {
                selectedSet = [selectedSet stringByAppendingString:NUMBERS];
            }
            selectedSet = [selectedSet stringByAppendingString:PUNCTUATION];
            break;
        default:
            break;
    }
    
    NSString *result = @"";
    NSRange range;
    range.length = 1;
    
    int targetLength = (int)_length;
    
    for (int i = 0; i < targetLength; i++) {
        range.location = arc4random() % [selectedSet length];
        result = [result stringByAppendingString:[selectedSet substringWithRange:range]];
    }
    
    NSString *non;
    
    if (!_allowRepeat) {
        int targetLength = (int)_length;
        
        NSMutableArray *chars = [[NSMutableArray alloc] initWithCapacity:[selectedSet length]];
        
        for (int i=0; i < [selectedSet length]; i++) {
            NSString *ichar  = [NSString stringWithFormat:@"%C", [selectedSet characterAtIndex:i]];
            [chars addObject:ichar];
        }
        
        NSUInteger const kChoiceSize = targetLength;
        NSMutableSet *choice = [[NSMutableSet alloc] init];
        while ([choice count] < kChoiceSize) {
            int randomIndex = arc4random_uniform((uint32_t)[chars count]);
            [choice addObject:[chars objectAtIndex:randomIndex]];
        }
        
        non = [[choice allObjects] componentsJoinedByString:@""];
        
        NSMutableSet *seenCharacters = [NSMutableSet set];
        NSMutableString *resultString = [NSMutableString string];
        [non enumerateSubstringsInRange:NSMakeRange(0, non.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
            
            if (![seenCharacters containsObject:substring]) {
                
                [seenCharacters addObject:substring];
                [resultString appendString:substring];
            }
            else
            {
                //NSLog(@"duplicates %@", substring);
            }
        }];

        if (_clipboardMode) {
            NSString *copyString = non;
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setString:copyString];
        }
        
        _passwordView.passwordSecureLabel.text = non;
        
        [_passwordView.attributedLabel setText:non afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
            
            NSRange  searchedRange = NSMakeRange(0, [result length]);
            NSString *pattern = @"\\d+";
            NSError  *error = nil;
            
            NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
            
            NSArray* matches = [regex matchesInString:result options:0 range: searchedRange];
            
            for (NSTextCheckingResult* match in matches) {
               //NSString* matchText = [result substringWithRange:[match range]];
                //NSLog(@"Match: %@", matchText);
                [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:(id)[UIColor colorWithRed:76.0f / 255.0f green:90.0f / 255.0f blue:100.0f / 255.0f alpha:1.0f].CGColor range:[match range]];
            }
            
            NSString *patternWords = @"[a-zA-Z]+";
            NSError  *error2 = nil;
            
            NSRegularExpression* regexWords = [NSRegularExpression regularExpressionWithPattern:patternWords options:0 error:&error2];
            
            NSArray* matchesWords = [regexWords matchesInString:result options:0 range: searchedRange];
            
            for (NSTextCheckingResult* match in matchesWords) {
                //NSString* matchText = [result substringWithRange:[match range]];
               // NSLog(@"Match2: %@", matchText);
                [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:(id)[UIColor pastepasswdMainColor].CGColor range:[match range]];
            }
            return mutableAttributedString;
        }];
    }
    else
    {
        NSString *result = @"";
        NSRange range;
        range.length = 1;
        
        int targetLength = (int)_length;
        
        for (int i = 0; i < targetLength; i++)
        {
            range.location = arc4random() % [selectedSet length];
            result = [result stringByAppendingString:[selectedSet substringWithRange:range]];
        }
        
        
        if (_clipboardMode) {
            NSString *copyString = result;
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setString:copyString];
        }
        
        _passwordView.passwordSecureLabel.text = result;
        
        [_passwordView.attributedLabel setText:result afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
            
            NSRange  searchedRange = NSMakeRange(0, [result length]);
            NSString *pattern = @"\\d+";
            NSError  *error = nil;
            
            NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
            
            NSArray* matches = [regex matchesInString:result options:0 range: searchedRange];
            
            for (NSTextCheckingResult* match in matches) {
                //NSString* matchText = [result substringWithRange:[match range]];
                //NSLog(@"Match: %@", matchText);
                [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:(id)[UIColor colorWithRed:76.0f / 255.0f green:90.0f / 255.0f blue:100.0f / 255.0f alpha:1.0f].CGColor range:[match range]];
            }
            
            NSString *patternWords = @"[a-zA-Z]+";
            NSError  *error2 = nil;
            
            NSRegularExpression* regexWords = [NSRegularExpression regularExpressionWithPattern:patternWords options:0 error:&error2];
            
            NSArray* matchesWords = [regexWords matchesInString:result options:0 range: searchedRange];
            
            for (NSTextCheckingResult* match in matchesWords) {
                //NSString* matchText = [result substringWithRange:[match range]];
                //NSLog(@"Match2: %@", matchText);
                [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:(id)[UIColor pastepasswdMainColor].CGColor range:[match range]];
            }

            return mutableAttributedString;
        }];

        
        NSMutableSet *seenCharacters = [NSMutableSet set];
        NSMutableString *resultString = [NSMutableString string];
        [result enumerateSubstringsInRange:NSMakeRange(0, result.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
            
            if (![seenCharacters containsObject:substring]) {
                
                [seenCharacters addObject:substring];
                [resultString appendString:substring];
            }
            else
            {
                //NSLog(@"2 duplicates %@", substring);
            }
        }];
    }
}


@end
