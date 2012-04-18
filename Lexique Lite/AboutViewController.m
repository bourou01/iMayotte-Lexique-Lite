//
//  AboutViewController.m
//  FTCoreText
//
//  Created by Francesco Frison on 18/08/2011.
//  Copyright 2011 Fuerte International. All rights reserved.
//

#import "AboutViewController.h"

@implementation AboutViewController
@synthesize scrollView;
@synthesize coreTextView;


- (NSString *)textForView
{
    return [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"about" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil];
}


- (NSArray *)coreTextStyle
{
    NSMutableArray *result = [NSMutableArray array];
    
	FTCoreTextStyle *defaultStyle = [FTCoreTextStyle new];
	defaultStyle.name = FTCoreTextTagDefault;	//thought the default name is already set to FTCoreTextTagDefault
	defaultStyle.font = [UIFont fontWithName:@"TimesNewRomanPSMT" size:16.f];
	defaultStyle.textAlignment = FTCoreTextAlignementJustified;
	[result addObject:defaultStyle];
	[defaultStyle release];
	
	FTCoreTextStyle *titleStyle = [FTCoreTextStyle new];
	titleStyle.name = @"title";
	titleStyle.font = [UIFont fontWithName:@"TimesNewRomanPSMT" size:35.f];
	titleStyle.paragraphInset = UIEdgeInsetsMake(0, 0, 25, 0);
	titleStyle.textAlignment = FTCoreTextAlignementCenter;
	[result addObject:titleStyle];
	[titleStyle release];
	
	FTCoreTextStyle *imageStyle = [FTCoreTextStyle new];
	imageStyle.paragraphInset = UIEdgeInsetsMake(0, 0, 1, 0);
	imageStyle.name = FTCoreTextTagImage;
	imageStyle.textAlignment = FTCoreTextAlignementCenter;
	[result addObject:imageStyle];
	[imageStyle release];	
	
	FTCoreTextStyle *firstLetterStyle = [FTCoreTextStyle new];
	firstLetterStyle.name = @"firstLetter";
	firstLetterStyle.font = [UIFont fontWithName:@"TimesNewRomanPS-BoldMT" size:30.f];
	[result addObject:firstLetterStyle];
	[firstLetterStyle release];
	
	FTCoreTextStyle *linkStyle = [defaultStyle copy];
	linkStyle.name = FTCoreTextTagLink;
	linkStyle.color = [UIColor orangeColor];
	[result addObject:linkStyle];
	[linkStyle release];
	
	FTCoreTextStyle *subtitleStyle = [FTCoreTextStyle new];
	subtitleStyle.name = @"subtitle";
	subtitleStyle.font = [UIFont fontWithName:@"TimesNewRomanPS-BoldMT" size:20.f];
	subtitleStyle.color = [UIColor brownColor];
	subtitleStyle.paragraphInset = UIEdgeInsetsMake(10, 0, 10, 0);
	[result addObject:subtitleStyle];
	[subtitleStyle release];
	
	FTCoreTextStyle *bulletStyle = [defaultStyle copy];
	bulletStyle.name = FTCoreTextTagBullet;
	bulletStyle.bulletFont = [UIFont fontWithName:@"TimesNewRomanPSMT" size:16.f];
	bulletStyle.bulletColor = [UIColor orangeColor];
	bulletStyle.bulletCharacter = @"❧";
	[result addObject:bulletStyle];
	[bulletStyle release];
	
    return  result;
}


- (void)touchedData:(NSDictionary *)data inCoreTextView:(FTCoreTextView *)textView
{
    NSURL *url = [data objectForKey:@"url"];
    if (!url) return;
    [[UIApplication sharedApplication] openURL:url];
}



#pragma mark - View Controller Methods

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.navigationController.topViewController.title = @"A propos de";
    
    
    
    
    //add coretextview
    scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
	scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    coreTextView = [[FTCoreTextView alloc] initWithFrame:CGRectMake(20, 20, 280, 0)];
	coreTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    // set text
    [coreTextView setText:[self textForView]];
    // set styles
    [coreTextView addStyles:[self coreTextStyle]];
    // set delegate
    [coreTextView setDelegate:self];
	
	[coreTextView fitToSuggestedHeight];
    
    [scrollView addSubview:coreTextView];
    [scrollView setContentSize:CGSizeMake(CGRectGetWidth(scrollView.bounds), CGRectGetHeight(coreTextView.frame) + 40)];
    
    [self.view addSubview:scrollView];
	[scrollView release];
    [coreTextView release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return (toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[scrollView setContentSize:CGSizeMake(CGRectGetWidth(scrollView.bounds), CGRectGetHeight(coreTextView.frame) + 40)];
}

- (void)dealloc
{
	[super dealloc];
}

@end
