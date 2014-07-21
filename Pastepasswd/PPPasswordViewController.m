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
@property (nonatomic, strong) UILabel *allowCharsRepeatLabel;
@property (nonatomic, strong) UILabel *avoidAmbiguousLabel;
@property (nonatomic, strong) UILabel *lengthLabel;
@property (nonatomic, strong) UILabel *lengthValueLabel;
@property (nonatomic, strong) UISegmentedControl *letters;
@property (nonatomic, strong) UISegmentedControl *typeChar;
@property (nonatomic, strong) UISwitch *switchAmbiguous;
@property (nonatomic, strong) UISwitch *switchAllowRepeat;
@property (nonatomic, strong) UISwitch *passwordMode;
@property (nonatomic, strong) UITextField *passwordLabel;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UISlider *digitsSlider;
@property (nonatomic, strong) UILabel *digitsLabel;
@property (nonatomic, strong) UILabel *digitsValueLabel;
@property (nonatomic, strong) UISlider *symbolSlider;
@property (nonatomic, strong) UILabel *symbolLabel;
@property (nonatomic, strong) UILabel *symbolValueLabel;
@property (nonatomic, assign) NSInteger length;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, assign) int typeLetterValue;
@property (nonatomic, assign) int typeCharValue;

@property (nonatomic, assign) int digitsValue;
@property (nonatomic, assign) int symbolValue;

@property (nonatomic, assign) BOOL ambiguous;
@property (nonatomic, assign) BOOL allowRepeat;
@property (nonatomic, strong, readwrite) NSString *mode;
@property (nonatomic, strong) PPPasswordView *passwordView;
@property (nonatomic, strong) UILabel *secureText;

- (void)_changeSwitch:(id)sender;
- (void)_changeAllowRepeat:(id)sender;
- (void)_sliderValue:(id)sender;
- (void)_selectTypeOfLetter:(id)sender;
- (void)_selectTypeOfChar:(id)sender;
- (void)_changePasswordMode:(id)sender;
- (void)_generatePassword:(int)typeLetter typeChar:(int)typeChar;
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
    _mode = @"2";
    
    _passwordLabel = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 60.0f, self.view.frame.size.width, 65.0f)];
    _passwordLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _passwordLabel.backgroundColor = [UIColor clearColor];
    _passwordLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0f];
    _passwordLabel.textAlignment = NSTextAlignmentCenter;
    _passwordLabel.textColor = [UIColor colorWithRed:54.0f / 255.0f green:66.0f / 255.0f blue:75.0f / 255.0f alpha:1.0f];
    _passwordLabel.secureTextEntry = NO;
    [self.view addSubview:_passwordLabel];
    
    _passwordView = [[PPPasswordView alloc] initWithFrame:CGRectMake(0.0f, 64.0f, self.view.frame.size.width, 61.0f)];
    [self.view addSubview:_passwordView];
    
    _lengthLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 190.0, 290.0, 25.0f)];
    _lengthLabel.text = @"Length";
    _lengthLabel.font = [UIFont mediumFontWithSize:16.0f];
    _lengthLabel.textColor = [UIColor pastepasswdTextColor];
    [self.view addSubview:_lengthLabel];
    
    _slider = [[UISlider alloc] initWithFrame:CGRectMake(70.0f, 190.0f, 200.0f, 25.0f)];
    _slider.tintColor = [UIColor pastepasswdTextColor];
    _slider.minimumValue = 0.0f;
    _slider.maximumValue = maxChars;
    _slider.value = 4.0f;
    _slider.continuous = YES;
    [_slider addTarget:self action:@selector(_sliderValue:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_slider];
    
    _length = _slider.value;
    
    _lengthValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(280.0f, 190.0, 290.0, 25.0f)];
    _lengthValueLabel.text = [NSString stringWithFormat:@"%.0f", _slider.value];
    _lengthValueLabel.font = [UIFont mediumFontWithSize:16.0f];
    _lengthValueLabel.textColor = [UIColor pastepasswdTextColor];
    [self.view addSubview:_lengthValueLabel];
    
    _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    _progressView.frame = CGRectMake(10.0f, 160.0f, 290.0f, 10);
    _progressView.tintColor = [UIColor redColor];
   [self.progressView setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
    float progressValue = 4.0f / maxChars;
    [_progressView setProgress: progressValue];
    [_progressView setTrackTintColor:[UIColor pastepasswdTextColor]];
    [self.view addSubview:_progressView];
    
    NSArray *lettersArray = [NSArray arrayWithObjects:@"abc", @"aBc", @"ABC", nil];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont fontWithName:@"Avenir-Medium" size:16.0f], NSFontAttributeName,
                                [UIColor colorWithRed:125.0f / 255.0f green:138.0f / 255.0f blue:148.0f / 255.0f alpha:1.0f], NSForegroundColorAttributeName,
                                nil];
    
    _letters = [[UISegmentedControl alloc] initWithItems:lettersArray];
    _letters.tintColor = [UIColor colorWithRed:54.0f / 255.0f green:66.0f / 255.0f blue:75.0f / 255.0f alpha:1.0f];
    _letters.frame = CGRectMake(10.0f, 240.0f, 300.0f, 40.0f);
    _letters.selectedSegmentIndex = 1;
    [_letters addTarget:self action:@selector(_selectTypeOfLetter:) forControlEvents:UIControlEventValueChanged];
    
    [_letters setTitleTextAttributes:attributes forState:UIControlStateNormal];
    NSDictionary *highlightedAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    [_letters setTitleTextAttributes:highlightedAttributes forState:UIControlStateHighlighted];
    
    [[UISegmentedControl appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                             [UIColor colorWithRed:125.0f / 255.0f green:138.0f / 255.0f blue:148.0f / 255.0f alpha:1.0f],NSForegroundColorAttributeName, nil]
                                                   forState:UIControlStateSelected];
    [[UISegmentedControl appearance] setContentPositionAdjustment:UIOffsetMake(0.0, 2.0) forSegmentType:UISegmentedControlSegmentAny barMetrics:UIBarMetricsDefault];
    
    [self.view addSubview:_letters];
    
    NSArray *mixArray = [NSArray arrayWithObjects:@"Numbers", @"Punctuation", nil];
    
    _typeChar = [[UISegmentedControl alloc] initWithItems:mixArray];
    _typeChar.tintColor = [UIColor colorWithRed:54.0f / 255.0f green:66.0f / 255.0f blue:75.0f / 255.0f alpha:1.0f];
    _typeChar.frame = CGRectMake(10.0f, 300.0f, 300.0f, 40.0f);
    _typeChar.selectedSegmentIndex = 1;
    [_typeChar addTarget:self action:@selector(_selectTypeOfChar:) forControlEvents:UIControlEventValueChanged];
    
    [_typeChar setTitleTextAttributes:attributes forState:UIControlStateNormal];
    NSDictionary *highlightedAttributes2 = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    [_typeChar setTitleTextAttributes:highlightedAttributes2 forState:UIControlStateHighlighted];
    
    [self.view addSubview:_typeChar];
    
    _switchAmbiguous = [[UISwitch alloc] initWithFrame:CGRectMake(240, 350, 0, 0)];
    [_switchAmbiguous setOnTintColor:[UIColor pastepasswdMainColor]];
    [_switchAmbiguous addTarget:self action:@selector(_changeSwitch:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_switchAmbiguous];
    
    _switchAllowRepeat = [[UISwitch alloc] initWithFrame:CGRectMake(240, 400, 0, 0)];
    [_switchAllowRepeat setOn:YES];
    [_switchAllowRepeat setOnTintColor:[UIColor pastepasswdMainColor]];
    [_switchAllowRepeat addTarget:self action:@selector(_changeAllowRepeat:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_switchAllowRepeat];
    
    _passwordMode = [[UISwitch alloc] initWithFrame:CGRectMake(240, 450, 0, 0)];
    [_passwordMode setOn:NO];
    [_passwordMode setOnTintColor:[UIColor pastepasswdMainColor]];
    [_passwordMode addTarget:self action:@selector(_changePasswordMode:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_passwordMode];
    
    //labels
    _avoidAmbiguousLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 355, 240, 20)];
    _avoidAmbiguousLabel.text = @"Avoid ambiguity";
    _avoidAmbiguousLabel.textColor = [UIColor pastepasswdTextColor];
    _avoidAmbiguousLabel.font = [UIFont mediumFontWithSize:16.0f];
    [self.view addSubview:_avoidAmbiguousLabel];
    
    _allowCharsRepeatLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 405, 200, 20)];
    _allowCharsRepeatLabel.text = @"Allow repeats";
    _allowCharsRepeatLabel.textColor = [UIColor pastepasswdTextColor];
    _allowCharsRepeatLabel.font = [UIFont mediumFontWithSize:16.0f];
    [self.view addSubview:_allowCharsRepeatLabel];

    _secureText = [[UILabel alloc] initWithFrame:CGRectMake(10, 450, 200, 20)];
    _secureText.text = @"Secure Text";
    _secureText.textColor = [UIColor pastepasswdTextColor];
    _secureText.font = [UIFont mediumFontWithSize:16.0f];
    [self.view addSubview:_secureText];
    
    //mode 2
    _digitsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 260.0f, 290.0f, 25.0f)];
    _digitsLabel.text = @"Digits";
    _digitsLabel.font = [UIFont mediumFontWithSize:16.0f];
    _digitsLabel.textColor = [UIColor pastepasswdTextColor];
    [self.view addSubview:_digitsLabel];
    
    _digitsSlider = [[UISlider alloc] initWithFrame:CGRectMake(70.0f, 260.0f, 200.0f, 25.0f)];
    _digitsSlider.minimumValue = 0.0f;
    _digitsSlider.maximumValue = 10.0f;
    _digitsSlider.tintColor = [UIColor pastepasswdTextColor];
    _digitsSlider.value = 1.0f;
    [_digitsSlider setHidden:YES];
    _digitsSlider.continuous = YES;
    [_digitsSlider addTarget:self action:@selector(_digitsSliderValue:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_digitsSlider];
    
    _digitsValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(280.0f, 260.0f, 290.0f, 25.0f)];
    _digitsValueLabel.text = [NSString stringWithFormat:@"%.0f", _digitsSlider.value];
    _digitsValueLabel.font = [UIFont mediumFontWithSize:16.0f];
    _digitsValueLabel.textColor = [UIColor pastepasswdTextColor];
    [self.view addSubview:_digitsValueLabel];
    
    _digitsValue = _digitsSlider.value;
    
    _symbolLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 300.0f, 290.0f, 25.0f)];
    _symbolLabel.text = @"Symbols";
    _symbolLabel.font = [UIFont mediumFontWithSize:16.0f];
    _symbolLabel.textColor = [UIColor pastepasswdTextColor];
    [self.view addSubview:_symbolLabel];
    
    _symbolSlider = [[UISlider alloc] initWithFrame:CGRectMake(70.0f, 300.0f, 200.0f, 25.0f)];
    _symbolSlider.minimumValue = 0.0f;
    _symbolSlider.tintColor = [UIColor pastepasswdTextColor];
    _symbolSlider.maximumValue = 16;
    _symbolSlider.value = 0.0f;
    [_symbolSlider setHidden:YES];
    _symbolSlider.continuous = YES;
    [_symbolSlider addTarget:self action:@selector(_symbolSliderValue:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_symbolSlider];

    _symbolValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(280.0f, 300.0f, 290.0f, 25.0f)];
    _symbolValueLabel.text = [NSString stringWithFormat:@"%.0f", _symbolSlider.value];
    _symbolValueLabel.font = [UIFont mediumFontWithSize:16.0f];
    _symbolValueLabel.textColor = [UIColor pastepasswdTextColor];
    [self.view addSubview:_symbolValueLabel];
    
    _symbolValue = _symbolSlider.value;
    
    _typeLetterValue = 1;
    _typeCharValue = 1;
	
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_changeMode:) name:@"changeMode" object:nil];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *value = [userDefaults objectForKey:@"mode"];
    
    if ([value isEqualToString:@"1"]) {
        _mode = @"1";
        [_digitsSlider setHidden:YES];
        [_symbolSlider setHidden:YES];
        
        [_letters setHidden:NO];
        [_typeChar setHidden:NO];
        
        [self _generatePassword:_typeLetterValue typeChar:_typeCharValue];
    } else {
        _mode = @"2";
        [_digitsSlider setHidden:NO];
        [_symbolSlider setHidden:NO];
        
        [_letters setHidden:YES];
        [_typeChar setHidden:YES];
        
         [self _generatePasswordWithLength:_length digitsLength:_digitsValue symbolsLength:_symbolValue avoid:_allowRepeat];
    }
}

- (void)_changeMode:(NSNotification *)notification {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *value = [userDefaults objectForKey:@"mode"];
    
    if ([value isEqualToString:@"1"]) {
        _mode = @"1";
        [_digitsSlider setHidden:YES];
        [_symbolSlider setHidden:YES];
        
        [_letters setHidden:NO];
        [_typeChar setHidden:NO];
        
        [self _generatePassword:_typeLetterValue typeChar:_typeCharValue];
    } else {
        _mode = @"2";
        [_digitsSlider setHidden:NO];
        [_symbolSlider setHidden:NO];
        
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
    NSInteger totalDigits;
    NSInteger totalSymbols;
    
    if (digitsLength >= symbolsLength) {
        totalChars = length - digitsLength - symbolsLength;
         NSLog(@"before totalChars %ld", (long)totalChars);
        if (totalChars <= 0) {
            totalDigits = length;
            totalSymbols = length - digitsLength;
            if (totalSymbols <= 0) {
                totalSymbols = 0;
            }
            totalChars = 0;
            NSLog(@"0");
            NSLog(@"totalDigits %ld", (long)totalDigits);
            NSLog(@"totalSymbols %ld", (long)totalSymbols);
            NSLog(@"after totalChars %ld", (long)totalChars);
        } else {
            totalDigits = digitsLength;
            totalSymbols = symbolsLength;
            NSLog(@"1");
            NSLog(@"totalDigits %ld", (long)totalDigits);
             NSLog(@"totalSymbols %ld", (long)totalSymbols);
            NSLog(@"totalChars %ld", (long)totalChars);
        }
    } else {
        
        totalDigits = digitsLength;
        totalSymbols = symbolsLength;
        totalChars = length - digitsLength - symbolsLength;
        
        NSLog(@"after totalChars %ld", (long)totalChars);
        NSLog(@"test after totalChars %ld",  totalSymbols  + (long)totalChars);
        
        if (totalChars <= 0) {
            totalSymbols = totalSymbols + totalChars;
            NSLog(@"totalSymbols %ld", (long)totalSymbols);
            totalChars = 0;
        } else {
            NSLog(@">>>>>>>>> totalChars %ld", (long)totalChars);
        }
        
        NSLog(@"2");
        NSLog(@"totalDigits %ld", (long)totalDigits);
        NSLog(@"totalSymbols %ld", (long)totalSymbols);
        NSLog(@"totalChars %ld", (long)totalChars);
    }
    
    NSLog(@"RESULTS");
    NSLog(@"totalDigits %ld", (long)totalDigits);
    NSLog(@"totalSymbols %ld", (long)totalSymbols);
    NSLog(@"final totalChars %ld", (long)totalChars);
    
    NSArray *nums;
    
    if (_ambiguous) {
        nums = [[NSArray alloc] initWithObjects:@"3", @"4", @"7", @"9", nil];
    } else {
        nums = [[NSArray alloc] initWithObjects:@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", nil];
    }
    
    NSMutableSet *choice = [[NSMutableSet alloc] init];
    while ([choice count] < totalDigits) {
        int randomIndex = arc4random_uniform((uint32_t)[nums count]);
        [choice addObject:[nums objectAtIndex:randomIndex]];
    }

    selectedSet = [selectedSet stringByAppendingString:[[choice allObjects] componentsJoinedByString:@""]];
    
    NSLog(@"digits %@", selectedSet);
    
    NSArray *puncArr = [[NSArray alloc] initWithObjects:@"~", @"!", @"@", @"#", @"$", @"%", @"^", @"&", @"*", @"+", @"=", @"?", @"/", @"|", @":", @";", nil];
    
    NSMutableSet *punc = [[NSMutableSet alloc] init];
    while ([punc count] < totalSymbols) {
        int randomIndex = arc4random_uniform((uint32_t)[puncArr count]);
        [punc addObject:[puncArr objectAtIndex:randomIndex]];
    }
    
    selectedSet = [selectedSet stringByAppendingString:[[punc allObjects] componentsJoinedByString:@""]];

    if (totalChars > 0) {
        
        if (!avoid) {
            //NSLog(@"non allow repeats");
            
            NSArray *charsArr = [[NSArray alloc] initWithObjects:@"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o", @"p", @"q", @"r", @"s", @"t",@"u", @"v", @"w", @"x", @"y", @"z", @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S",@"T",@"U",@"V", @"W", @"X", @"Y", @"Z", nil];
            
            NSMutableSet *choiceChars = [[NSMutableSet alloc] init];
            
            while ([choiceChars count] < totalChars) {
                int randomIndex = arc4random_uniform((uint32_t)[charsArr count]);
                [choiceChars addObject:[charsArr objectAtIndex:randomIndex]];
            }
            
            NSLog(@"[[choiceChars allObjects] componentsJoinedByString:@""] %@", [[choiceChars allObjects] componentsJoinedByString:@""]);
            NSString *non = [[choiceChars allObjects] componentsJoinedByString:@""];
            
            NSLog(@"non %@", non);
            selectedSet = [selectedSet stringByAppendingString:non];
            
        } else {
            //NSLog(@"allow repeats");
            NSRange range;
            NSString *chars = @"";
            NSString *selectedChars = @"";
            range.length = 1;
            
            // selectedChars = [selectedChars stringByAppendingString:ALPHA_LC];
           // selectedChars = [selectedChars stringByAppendingString:ALPHA_UC];
            
            if (_ambiguous) {
                selectedChars = [selectedChars stringByAppendingString:@"ACEFHJKMNPRTUVWXY"];
                selectedChars = [selectedChars stringByAppendingString:@"acefhjkmnprtuvwxy"];
            } else {
                selectedChars = [selectedChars stringByAppendingString:ALPHA_UC];
                selectedChars = [selectedChars stringByAppendingString:ALPHA_LC];
            }
            
            //NSLog(@"selectedChars %lu", (unsigned long)[selectedChars length]);
            
            for (int i = 0; i < totalChars; i++) {
                range.location = arc4random() % [selectedChars length];
                chars = [chars stringByAppendingString:[selectedChars substringWithRange:range]];
            }

            //NSLog(@"chars %@",  chars);
            selectedSet = [selectedSet stringByAppendingString:chars];
        }
    }

    //NSLog(@"final selectedSet %@", selectedSet);
    
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
    
    NSLog(@"!!!!!!!!!!! result %@", result);
    
    NSString *copyString = result;
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:copyString];
    
    _passwordView.passwordLabel.text = result;
    _passwordView.passwordSecureLabel.text = result;
    
    NSCharacterSet *flags1 = [NSCharacterSet punctuationCharacterSet];
    NSCharacterSet *flags2 = [NSCharacterSet symbolCharacterSet];
    NSCharacterSet *flags3 = [NSCharacterSet whitespaceCharacterSet];
    
    [_passwordView.attributedLabel setText:result afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        
        for (int i = 0; i < [result length]; i++) {
            if (isdigit([result characterAtIndex:i])) {
                unichar word = [result characterAtIndex:i];
                NSString *value = [NSString stringWithCharacters:&word length:1];
                NSRange range = [result rangeOfString:value];
                [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:(id)[UIColor greenColor].CGColor range:range];
            }
            
            if ([flags1 characterIsMember:[result characterAtIndex:i]] | [flags2 characterIsMember:[result characterAtIndex:i]] | [flags3 characterIsMember:[result characterAtIndex:i]]) {
                unichar word = [result characterAtIndex:i];
                NSString *value = [NSString stringWithCharacters:&word length:1];
                NSRange range = [result rangeOfString:value];
                [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:(id)[UIColor redColor].CGColor range:range];
            }
        }
        return mutableAttributedString;
    }];
    
    //
    //check for dup
    NSString *input = result;
    
    //NSLog(@"input %@", input);
    
    NSMutableSet *seenCharacters = [NSMutableSet set];
    NSMutableString *resultString = [NSMutableString string];
    [input enumerateSubstringsInRange:NSMakeRange(0, input.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        
        if (![seenCharacters containsObject:substring]) {
            [seenCharacters addObject:substring];
            [resultString appendString:substring];
        } else {
            NSLog(@"duplicates %@", substring);
        }
    }];
}

//- (void)_generatePasswordWithLength:(NSInteger)length digitsLength:(NSInteger)digitsLength symbolsLength:(NSInteger)symbolsLength avoid:(BOOL)avoid
//{
//    NSString *result = @"";
//    NSString *selectedSet = @"";
//    
//    NSInteger diff = length - digitsLength - symbolsLength;
//    
//    NSArray *nums = [[NSArray alloc] initWithObjects:@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", nil];
//    
//    NSMutableSet *choice = [[NSMutableSet alloc] init];
//    while ([choice count] < digitsLength) {
//        int randomIndex = arc4random_uniform([nums count]);
//        [choice addObject:[nums objectAtIndex:randomIndex]];
//    }
//    
//    selectedSet = [selectedSet stringByAppendingString:[[choice allObjects] componentsJoinedByString:@""]];
//    
//    NSArray *puncArr = [[NSArray alloc] initWithObjects:@"~", @"!", @"@", @"#", @"$", @"%", @"^", @"&", @"*", @"+", @"=", @"?", @"/", @"|", @":", @";", nil];
//    
//    NSMutableSet *punc = [[NSMutableSet alloc] init];
//    while ([punc count] < symbolsLength) {
//        int randomIndex = arc4random_uniform([puncArr count]);
//        [punc addObject:[puncArr objectAtIndex:randomIndex]];
//    }
//    
//    selectedSet = [selectedSet stringByAppendingString:[[punc allObjects] componentsJoinedByString:@""]];
//    
//    NSRange range;
//    NSString *chars = @"";
//    NSString *selectedChars = @"";
//    range.length = 1;
//    
//    selectedChars = [selectedChars stringByAppendingString:ALPHA_LC];
//    selectedChars = [selectedChars stringByAppendingString:ALPHA_UC];
//    
//    NSLog(@"selectedChars %lu", (unsigned long)[selectedChars length]);
//    
//    for (int i = 0; i < diff; i++)
//    {
//        range.location = arc4random() % [selectedChars length];
//        chars = [chars stringByAppendingString:[selectedChars substringWithRange:range]];
//    }
//    
//    if (!avoid)
//    {
//        NSArray *charsArr = [[NSArray alloc] initWithObjects:@"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o", @"p", @"q", @"r", @"s", @"t",@"u", @"v", @"w", @"x", @"y", @"z", @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S",@"T",@"U",@"V", @"W", @"X", @"Y", @"Z", nil];
//        
//
//        NSMutableSet *choiceChars = [[NSMutableSet alloc] init];
//        
//        while ([choiceChars count] < diff)
//        {
//            int randomIndex = arc4random_uniform([charsArr count]);
//            [choiceChars addObject:[charsArr objectAtIndex:randomIndex]];
//        }
//        
//        NSLog(@"[[choiceChars allObjects] componentsJoinedByString:@""] %@", [[choiceChars allObjects] componentsJoinedByString:@""]);
//        NSString *non = [[choiceChars allObjects] componentsJoinedByString:@""];
//        NSString *temp = selectedSet;
//        
//        temp = [temp stringByAppendingString:non];
//        
//        NSLog(@"temp %@", temp);
//        
//        //shuffle
//        NSUInteger strLength = [temp length];
//        
//        unichar *buffer = calloc(strLength, sizeof(unichar));
//        
//        [temp getCharacters:buffer range:NSMakeRange(0, strLength)];
//        
//        for (int i = strLength - 1; i >= 0; i--)
//        {
//            int j = arc4random() % (i + 1);
//            unichar c = buffer[i];
//            buffer[i] = buffer[j];
//            buffer[j] = c;
//        }
//        
//        NSString *result2 = [NSString stringWithCharacters:buffer length:strLength];
//        free(buffer);
//        
//        NSLog(@"result2 %@", result2);
//        
//        NSString *copyString = result2;
//        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
//        [pasteboard setString:copyString];
//        
//        _passwordView.passwordLabel.text = result2;
//        _passwordView.passwordSecureLabel.text = result2;
//        
//        NSCharacterSet *flags1 = [NSCharacterSet punctuationCharacterSet];
//        NSCharacterSet *flags2 = [NSCharacterSet symbolCharacterSet];
//        NSCharacterSet *flags3 = [NSCharacterSet whitespaceCharacterSet];
//        
//        [_passwordView.attributedLabel setText:result2 afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
//            
//            for (int i = 0; i < [result2 length]; i++)
//            {
//                if (isdigit([result2 characterAtIndex:i]))
//                {
//                    unichar word = [result2 characterAtIndex:i];
//                    NSString *value = [NSString stringWithCharacters:&word length:1];
//                    NSRange range = [result2 rangeOfString:value];
//                    [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:(id)[UIColor redColor].CGColor range:range];
//                }
//                
//                if ([flags1 characterIsMember:[result2 characterAtIndex:i]] | [flags2 characterIsMember:[result2 characterAtIndex:i]] | [flags3 characterIsMember:[result2 characterAtIndex:i]])
//                {
//                    unichar word = [result2 characterAtIndex:i];
//                    NSString *value = [NSString stringWithCharacters:&word length:1];
//                    NSRange range = [result2 rangeOfString:value];
//                    [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:(id)[UIColor redColor].CGColor range:range];
//                }
//                
//            }
//            
//            return mutableAttributedString;
//        }];
//
//        
//        //check for dup
//        NSString *input = result2;
//        
//        NSMutableSet *seenCharacters = [NSMutableSet set];
//        NSMutableString *resultString = [NSMutableString string];
//        [input enumerateSubstringsInRange:NSMakeRange(0, input.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
//            
//            if (![seenCharacters containsObject:substring]) {
//                
//                [seenCharacters addObject:substring];
//                [resultString appendString:substring];
//            }
//            else
//            {
//                //NSLog(@"duplicates %@", substring);
//            }
//        }];
//    }
//    else
//    {
//        
//        NSLog(@"chars %@", chars);
//        
//        selectedSet = [selectedSet stringByAppendingString:chars];
//        
//        NSLog(@"final selectedSet %@", selectedSet);
//        
//        NSUInteger strLength = [selectedSet length];
//        
//        unichar *buffer = calloc(strLength, sizeof(unichar));
//        
//        [selectedSet getCharacters:buffer range:NSMakeRange(0, strLength)];
//        
//        for (int i = strLength - 1; i >= 0; i--)
//        {
//            int j = arc4random() % (i + 1);
//            unichar c = buffer[i];
//            buffer[i] = buffer[j];
//            buffer[j] = c;
//        }
//        
//        result = [NSString stringWithCharacters:buffer length:strLength];
//        free(buffer);
//        
//        NSLog(@"result %@", result);
//        
//        NSString *copyString = result;
//        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
//        [pasteboard setString:copyString];
//        
//        _passwordView.passwordLabel.text = result;
//        _passwordView.passwordSecureLabel.text = result;
//        
//        NSCharacterSet *flags1 = [NSCharacterSet punctuationCharacterSet];
//        NSCharacterSet *flags2 = [NSCharacterSet symbolCharacterSet];
//        NSCharacterSet *flags3 = [NSCharacterSet whitespaceCharacterSet];
//        
//        [_passwordView.attributedLabel setText:result afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
//            
//            for (int i = 0; i < [result length]; i++)
//            {
//                if (isdigit([result characterAtIndex:i]))
//                {
//                    unichar word = [result characterAtIndex:i];
//                    NSString *value = [NSString stringWithCharacters:&word length:1];
//                    NSRange range = [result rangeOfString:value];
//                    [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:(id)[UIColor redColor].CGColor range:range];
//                }
//                
//                if ([flags1 characterIsMember:[result characterAtIndex:i]] | [flags2 characterIsMember:[result characterAtIndex:i]] | [flags3 characterIsMember:[result characterAtIndex:i]])
//                {
//                    unichar word = [result characterAtIndex:i];
//                    NSString *value = [NSString stringWithCharacters:&word length:1];
//                    NSRange range = [result rangeOfString:value];
//                    [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:(id)[UIColor redColor].CGColor range:range];
//                }
//                
//            }
//            
//            return mutableAttributedString;
//        }];
//        
//        //check for dup
//        NSString *input = result;
//        
//        //NSLog(@"input %@", input);
//        
//        NSMutableSet *seenCharacters = [NSMutableSet set];
//        NSMutableString *resultString = [NSMutableString string];
//        [input enumerateSubstringsInRange:NSMakeRange(0, input.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
//            
//            if (![seenCharacters containsObject:substring]) {
//                
//                [seenCharacters addObject:substring];
//                [resultString appendString:substring];
//            }
//            else
//            {
//                //NSLog(@"duplicates %@", substring);
//            }
//        }];
//    }
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
        _passwordLabel.secureTextEntry = YES;
        [_passwordView slideOut];
    } else {
        _passwordLabel.secureTextEntry = NO;
        [_passwordView slideIn];
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

        _passwordLabel.text = non;
        NSString *copyString = non;
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setString:copyString];
        
        _passwordView.passwordLabel.text = non;
        _passwordView.passwordSecureLabel.text = non;
        
        NSCharacterSet *flags1 = [NSCharacterSet punctuationCharacterSet];
        NSCharacterSet *flags2 = [NSCharacterSet symbolCharacterSet];
        NSCharacterSet *flags3 = [NSCharacterSet whitespaceCharacterSet];
        
        [_passwordView.attributedLabel setText:non afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
            
            for (int i = 0; i < [non length]; i++)
            {
                if (isdigit([non characterAtIndex:i]))
                {
                    unichar word = [non characterAtIndex:i];
                    NSString *value = [NSString stringWithCharacters:&word length:1];
                    NSRange range = [non rangeOfString:value];
                    [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:(id)[UIColor redColor].CGColor range:range];
                }
                
                if ([flags1 characterIsMember:[non characterAtIndex:i]] | [flags2 characterIsMember:[non characterAtIndex:i]] | [flags3 characterIsMember:[non characterAtIndex:i]])
                {
                    unichar word = [non characterAtIndex:i];
                    NSString *value = [NSString stringWithCharacters:&word length:1];
                    NSRange range = [non rangeOfString:value];
                    [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:(id)[UIColor redColor].CGColor range:range];
                }
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
        
        _passwordLabel.text = result;
        NSString *copyString = result;
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setString:copyString];
        
        _passwordView.passwordLabel.text = result;
        _passwordView.passwordSecureLabel.text = result;
        
        NSCharacterSet *flags1 = [NSCharacterSet punctuationCharacterSet];
        NSCharacterSet *flags2 = [NSCharacterSet symbolCharacterSet];
        NSCharacterSet *flags3 = [NSCharacterSet whitespaceCharacterSet];
        
        [_passwordView.attributedLabel setText:result afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
            
            for (int i = 0; i < [result length]; i++)
            {
                if (isdigit([result characterAtIndex:i]))
                {
                    unichar word = [result characterAtIndex:i];
                    NSString *value = [NSString stringWithCharacters:&word length:1];
                    NSRange range = [result rangeOfString:value];
                    [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:(id)[UIColor redColor].CGColor range:range];
                }
                
                if ([flags1 characterIsMember:[result characterAtIndex:i]] | [flags2 characterIsMember:[result characterAtIndex:i]] | [flags3 characterIsMember:[result characterAtIndex:i]])
                {
                    unichar word = [result characterAtIndex:i];
                    NSString *value = [NSString stringWithCharacters:&word length:1];
                    NSRange range = [result rangeOfString:value];
                    [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:(id)[UIColor redColor].CGColor range:range];
                }
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
                //NSLog(@"duplicates %@", substring);
            }
        }];
    }
}


@end
