//
//  PPPasswordViewController.m
//  Pastepasswd
//
//  Created by Spiros Gerokostas on 3/24/14.
//  Copyright (c) 2014 Spiros Gerokostas. All rights reserved.
//

#import "PPPasswordViewController.h"
#import "PPLabel.h"
#import "NJOPasswordStrengthEvaluator.h"
#import "NSString+CountString.h"
#import "UIProgressView+Pastepasswd.h"

#define ALPHA_LC            @"abcdefghijklmnopqrstuvwxyz"
#define ALPHA_UC            [ALPHA_LC uppercaseString]
#define NUMBERS             @"0123456789"
#define PUNCTUATION         @"~!@#$%^&*+=?/|:;"
#define AMBIGUOUS_UC        @"ACEFHJKMNPRTUVWXY"
#define AMBIGUOUS           @"B8G6I1l0OQDS5Z2"
#define AMBIGUOUS_NUMBERS   @"861052"

const float maxChars = 30;

@interface PPPasswordViewController ()

@property (nonatomic, strong) UILabel *titleMainView;
@property (nonatomic, strong) UISegmentedControl *letters;
@property (nonatomic, strong) UISegmentedControl *typeChar;
@property (nonatomic, strong) UISwitch *switchAmbiguous;
@property (nonatomic, strong) UISwitch *switchAllowRepeat;
@property (nonatomic, strong) UITextField *passwordLabel;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, assign) NSInteger length;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong, readwrite) NJOPasswordValidator *passwordValidator;
@property (nonatomic, assign) int typeLetterValue;
@property (nonatomic, assign) int typeCharValue;
@property (nonatomic, assign) BOOL ambiguous;
@property (nonatomic, assign) BOOL allowRepeat;
@property (nonatomic, strong, readwrite) NSString *prevChar;
@property (nonatomic, strong, readwrite) NSString *latestChar2;

- (void)_changeSwitch:(id)sender;
- (void)_changeAllowRepeat:(id)sender;
- (void)_sliderValue:(id)sender;
- (void)_selectTypeOfLetter:(id)sender;
- (void)_selectTypeOfChar:(id)sender;
- (void)_generatePassword:(int)typeLetter typeChar:(int)typeChar;

@end

@implementation PPPasswordViewController

#pragma mark - Accessors

- (UILabel *)titleMainView
{
    if (!_titleMainView)
    {
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.titleView = self.titleMainView;
    self.view.backgroundColor = [UIColor colorWithRed:248.0f / 255.0f green:248.0f / 255.0f blue:248.0f / 255.0f alpha:1.0f];
    
    _passwordValidator = [NJOPasswordValidator standardValidator];
    
    _length = 8;
    _ambiguous = NO;
    _allowRepeat = YES;
    
    _passwordLabel = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 60.0f, self.view.frame.size.width, 65.0f)];
    //_passwordLabel.numberOfLines = 1;
    _passwordLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _passwordLabel.backgroundColor = [UIColor clearColor];
    _passwordLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0f];
    _passwordLabel.textAlignment = NSTextAlignmentCenter;
    _passwordLabel.textColor = [UIColor colorWithRed:54.0f / 255.0f green:66.0f / 255.0f blue:75.0f / 255.0f alpha:1.0f];
    _passwordLabel.secureTextEntry = NO;
    [self.view addSubview:_passwordLabel];
    
    _slider = [[UISlider alloc] initWithFrame:CGRectMake(10.0f, 140.0f, 290.0f, 25.0f)];
    _slider.minimumValue = 0.0f;
    _slider.maximumValue = maxChars;
    _slider.value = 4.0f;
    _slider.continuous = YES;
    [_slider addTarget:self action:@selector(_sliderValue:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_slider];
    
    //_progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(10.0f, 120.0f, 290.0f, 104)];
    _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    _progressView.frame = CGRectMake(10.0f, 120.0f, 290.0f, 10);
    _progressView.tintColor = [UIColor redColor];
   [self.progressView setTransform:CGAffineTransformMakeScale(1.0, 2.0)];
    float progressValue = 4.0f / maxChars;
    [_progressView setProgress: progressValue];
    
    [_progressView setTrackTintColor:[UIColor darkGrayColor]];
    
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
    
    NSArray *mixArray = [NSArray arrayWithObjects:@"alpha only", @"add numbers", @"add numbers and punctuation", nil];
    
    _typeChar = [[UISegmentedControl alloc] initWithItems:mixArray];
    _typeChar.tintColor = [UIColor colorWithRed:54.0f / 255.0f green:66.0f / 255.0f blue:75.0f / 255.0f alpha:1.0f];
    _typeChar.frame = CGRectMake(10.0f, 300.0f, 300.0f, 40.0f);
    _typeChar.selectedSegmentIndex = 1;
    [_typeChar addTarget:self action:@selector(_selectTypeOfChar:) forControlEvents:UIControlEventValueChanged];
    
    [_typeChar setTitleTextAttributes:attributes forState:UIControlStateNormal];
    NSDictionary *highlightedAttributes2 = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    [_typeChar setTitleTextAttributes:highlightedAttributes2 forState:UIControlStateHighlighted];
    
    [self.view addSubview:_typeChar];
    
    _switchAmbiguous = [[UISwitch alloc] initWithFrame:CGRectMake(10, 350, 0, 0)];
    [_switchAmbiguous addTarget:self action:@selector(_changeSwitch:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_switchAmbiguous];
    
    _switchAllowRepeat = [[UISwitch alloc] initWithFrame:CGRectMake(10, 400, 0, 0)];
    [_switchAllowRepeat addTarget:self action:@selector(_changeAllowRepeat:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_switchAllowRepeat];
    
    _typeLetterValue = 1;
    _typeCharValue = 1;
	
    [self _generatePassword:_typeLetterValue typeChar:_typeCharValue];
    
    //test
    NSString *unfilteredString = @"!@#$%^&*()_+|abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
    NSCharacterSet *allowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"] invertedSet];
    NSString *resultString = [[unfilteredString componentsSeparatedByCharactersInSet:allowedChars] componentsJoinedByString:@""];
    NSLog (@"Result: %@", resultString);
    
//    NSUInteger const kChoiceSize = 3;
//    NSArray * allColors = [[NSArray alloc] initWithObjects:@"r", @"g", @"b", @"y", @"p", @"o", nil];
//    
//    NSMutableSet *choice = [[NSMutableSet alloc] init];
//    while ([choice count] < kChoiceSize) {
//        int randomIndex = arc4random_uniform([allColors count]);
//        [choice addObject:[allColors objectAtIndex:randomIndex]];
//    }
//    
//    NSLog(@"choice %@", [[choice allObjects] componentsJoinedByString:@""]);
    
    
    NSString *input = @"ulcs3vZyI7Dpb7CWMlG";
    NSLog(@"length is %lu", (unsigned long)[input length]);
    NSMutableSet *seenCharacters = [NSMutableSet set];
    NSMutableString *result = [NSMutableString string];
    [input enumerateSubstringsInRange:NSMakeRange(0, input.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        
        
        
        if (![seenCharacters containsObject:substring]) {
            
            [seenCharacters addObject:substring];
            [result appendString:substring];
        }
        else
        {
            NSLog(@"%@", substring);
        }
    }];
    NSLog(@"String with duplicate characters removed: %@ and length is %lu", result, (unsigned long)[result length]);
    NSLog(@"Sorted characters in input: %@", [seenCharacters.allObjects sortedArrayUsingSelector:@selector(compare:)]);
    //steps
    
    /* 1. convert result to array
    2. convert unfilteredString to array
    3. compare result and unfilteredString
    4. create new array combine with the result
    5. convert combine to nsstring
    6 . use the following code
     
     NSString *unfilteredString = selectedSet;
     create new password with combine password
     NSCharacterSet *allowedChars = [[NSCharacterSet characterSetWithCharactersInString:combine] invertedSet];
     NSString *resultString = [[unfilteredString componentsSeparatedByCharactersInSet:allowedChars] componentsJoinedByString:@""];
     NSLog (@"Result: %@", resultString);
     
     for (i = 0; i < targetLength; i++)
     
     {
        range.location = arc4random() % [unfilteredString length];
     
        resultString = [resultString stringByAppendingString:[unfilteredString substringWithRange:range]];
     
     }

     
     
     */

}

#pragma mark - Private Implementation

- (void)_changeAllowRepeat:(id)sender
{
    if([sender isOn]){
        // Execute any code when the switch is ON
        NSLog(@"Switch is ON");
        _allowRepeat = YES;
    } else{
        // Execute any code when the switch is OFF
        NSLog(@"Switch is OFF");
        _allowRepeat = NO;
    }
    [self _generatePassword:_typeLetterValue typeChar:_typeCharValue];
}

- (void)_changeSwitch:(id)sender
{
    if([sender isOn]){
        // Execute any code when the switch is ON
        NSLog(@"Switch is ON");
        _ambiguous = YES;
    } else{
        // Execute any code when the switch is OFF
        NSLog(@"Switch is OFF");
        _ambiguous = NO;
    }
    
    //[self _generatePassword:_typeLetterValue typeChar:_typeCharValue];
}

- (void)_sliderValue:(id)sender
{
    UISlider *slider = (UISlider *)sender;
    _length = slider.value;
    
    float progressValue = (float)slider.value / maxChars;
    [_progressView setProgress:progressValue animated:YES];
    
    //NSLog(@"_length %ld", (long)_length);
    
    if (_length >= 0 && _length <= 6)
    {
        //NSLog(@"invalid password");
        _progressView.tintColor = [UIColor redColor];
    }
    else if (_length >= 6 && _length <= 9)
    {
        //NSLog(@"very weak password");
        _progressView.tintColor = [UIColor redColor];
    }
    else if (_length >= 9 && _length <= 11)
    {
        //NSLog(@"weak password");
        _progressView.tintColor = [UIColor orangeColor];
    }
    else if (_length >= 11 && _length <= 19)
    {
        //NSLog(@"reasonable password");
        _progressView.tintColor = [UIColor yellowColor];
    }
    else if (_length >= 19 && _length <= 39)
    {
        //NSLog(@"strong password");
        _progressView.tintColor = [UIColor greenColor];
    }
    else if (_length >= maxChars)
    {
        //NSLog(@"very strong password");
        _progressView.tintColor = [UIColor cyanColor];
    }

    [self _generatePassword:_typeLetterValue typeChar:_typeCharValue];
}

- (void)_selectTypeOfLetter:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
   
    int value = (int)segmentedControl.selectedSegmentIndex;
    _typeLetterValue = value;
    [self _generatePassword:value typeChar:_typeCharValue];
}

- (void)_selectTypeOfChar:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    
    int value = (int)segmentedControl.selectedSegmentIndex;
    _typeCharValue = value;
    [self _generatePassword:_typeLetterValue typeChar:value];
}

-(void)_generatePassword:(int)typeLetter typeChar:(int)typeChar
{
    NSString *selectedSet = @"";
    
    //NSLog(@"typeLetter %d", typeLetter);
 
    switch (typeLetter)
    {
        case 0: // lowercase
            selectedSet = [selectedSet stringByAppendingString:ALPHA_LC];
            break;
        case 1: // mixed case
            selectedSet = [selectedSet stringByAppendingString:ALPHA_LC];
            selectedSet = [selectedSet stringByAppendingString:ALPHA_UC];
            break;
        case 2: // uppercase
            selectedSet = [selectedSet stringByAppendingString:ALPHA_UC];
        
           
            break;
        default: // should never get here
            break;
    }
    
    switch (typeChar)
    {
        case 0: // alpha only
            
            break;
            
        case 1: // add numbers
            
            /*
             #define NUMBERS             @"0123456789"
           
             #define AMBIGUOUS_NUMBERS   @"861052"*/
            
            if (_ambiguous)
            {
                selectedSet = [selectedSet stringByAppendingString:@"3479"];
               
            }
            else
            {
                selectedSet = [selectedSet stringByAppendingString:NUMBERS];
            }
            
             //selectedSet = [selectedSet stringByAppendingString:NUMBERS];
            
         
            break;
            
        case 2: // add numbers and punctuation
            
            //selectedSet = [selectedSet stringByAppendingString:NUMBERS];
            
            if (_ambiguous)
            {
                selectedSet = [selectedSet stringByAppendingString:@"3479"];
            }
            else
            {
                selectedSet = [selectedSet stringByAppendingString:NUMBERS];
            }
         
            
            selectedSet = [selectedSet stringByAppendingString:PUNCTUATION];
            
            break;
            
        default: // should never get here
            
            break;
            
    }
    
    
    
    NSString *result = @"";
    
    NSRange range;
    
    range.length = 1;
    
    int targetLength = (int)_length;

    // Select n items from the selected sets to produce the password
    
    int i;
    
    for (i = 0; i < targetLength; i++)
        
    {
        
        //range.location = random() % [selectedSet length];
        
        range.location = arc4random() % [selectedSet length];
        
        result = [result stringByAppendingString:[selectedSet substringWithRange:range]];
        
    }
    
    if (!_allowRepeat)
    {
        
    }
    
    
    _passwordLabel.text = result;
    
    NSLog(@"result %@", result);
    
    NSString *copyString = result;
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:copyString];
    
   
    
}


@end
