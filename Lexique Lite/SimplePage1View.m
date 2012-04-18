//
//  SimplePage1View.m
//  FireUIPagedScrollViewiPhoneSample
//
//  Created by Johan Hernandez on 8/24/11.
//  Copyright 2011 Firebase. All rights reserved.
//  http://www.firebase.co
//

#import "SimplePage1View.h"

@implementation SimplePage1View

@synthesize word;
@synthesize definition;
@synthesize coreTextView;
@synthesize scrollView;



- (void)dealloc
{
    [super dealloc];

    [word release];
    [definition release];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSString *)formatDefinition
{
    
    NSMutableString *sample = [[NSMutableString alloc] initWithFormat:@"%@", definition];
    
    sample = [NSMutableString stringWithFormat:@"%@", [sample stringByReplacingOccurrencesOfString:@"(" withString:@"<example>("]];
    
    sample = [NSMutableString stringWithFormat:@"%@", [sample stringByReplacingOccurrencesOfString:@")" withString:@")</example>"]];
    
    sample = [NSMutableString stringWithFormat:@"%@", [sample stringByReplacingOccurrencesOfString:@"•" withString:@""]];

    return sample;
}

- (NSString *)textForView
{
    NSString *result = [NSString stringWithFormat:@"<subtitle>%@</subtitle> : %@", word, [self formatDefinition]];
    return result;
}


- (NSArray *)coreTextStyle
{
    NSMutableArray *result = [NSMutableArray array];
    
	FTCoreTextStyle *defaultStyle = [FTCoreTextStyle new];
	defaultStyle.name = FTCoreTextTagDefault;	//thought the default name is already set to FTCoreTextTagDefault
	defaultStyle.font = [UIFont fontWithName:@"TimesNewRomanPSMT" size:19.f];
	defaultStyle.textAlignment = FTCoreTextAlignementJustified;
	[result addObject:defaultStyle];
	[defaultStyle release];
    
    FTCoreTextStyle *exampleStyle = [FTCoreTextStyle new];
	exampleStyle.name = @"example";
	exampleStyle.font = [UIFont fontWithName:@"TimesNewRomanPSMT" size:18.f];
	exampleStyle.color = [UIColor lightGrayColor];
	[result addObject:exampleStyle];
	[exampleStyle release];
    
	FTCoreTextStyle *subtitleStyle = [FTCoreTextStyle new];
	subtitleStyle.name = @"subtitle";
	subtitleStyle.font = [UIFont fontWithName:@"TimesNewRomanPS-BoldMT" size:20.f];
	subtitleStyle.color = [UIColor redColor];
	subtitleStyle.paragraphInset = UIEdgeInsetsMake(10, 0, 10, 0);
	[result addObject:subtitleStyle];
	[subtitleStyle release];
	
    return  result;
}



#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
////////////////////////////////////////////////////////////////////////////////
// configure l'affichage du texte formaté
    
    //add coretextview
	
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    coreTextView = [[FTCoreTextView alloc] initWithFrame:CGRectMake(15, 15, 280, 0)];

    // set text
    [coreTextView setText:[self textForView]];
    // set styles
    [coreTextView addStyles:[self coreTextStyle]];
    // set delegate
    [coreTextView setDelegate:self];
	
	[coreTextView fitToSuggestedHeight];
    
    [scrollView addSubview:coreTextView];
    [scrollView setContentSize:CGSizeMake(CGRectGetWidth(scrollView.bounds) -15, CGRectGetHeight(coreTextView.frame) + 40)];
    
	[scrollView release];
    [coreTextView release];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
