//
//  FTCoreTextView.m
//  FTCoreText
//
//  Created by Francesco Freezone <cescofry@gmail.com> on 20/07/2011.
//  Copyright 2011 Fuerte International. All rights reserved.
//

#import "FTCoreTextView.h"
#import <QuartzCore/QuartzCore.h>
#import <regex.h>
#import <CoreText/CoreText.h>

#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

NSString * const FTCoreTextTagDefault = @"_default";
NSString * const FTCoreTextTagImage = @"_image";
NSString * const FTCoreTextTagBullet = @"_bullet";
NSString * const FTCoreTextTagPage = @"_page";
NSString * const FTCoreTextTagLink = @"_link";

typedef enum {
	FTCoreTextTagOpen,
	FTCoreTextTagClose,
	FTCoreTextTagSelfClose
} FTCoreTextTagType;

@interface FTCoreTextNode : NSObject

@property (nonatomic, assign) FTCoreTextNode	*supernode;
@property (nonatomic, retain) NSArray			*subnodes;
@property (nonatomic, retain) FTCoreTextStyle	*style;
@property (nonatomic, assign) NSRange			styleRange;
@property (nonatomic, assign) BOOL				isClosed;
@property (nonatomic, assign) NSInteger			startLocation;
@property (nonatomic, assign) BOOL				isLink;
@property (nonatomic, assign) BOOL				isImage;
@property (nonatomic, assign) BOOL				isBullet;
@property (nonatomic, retain) NSString			*imageName;

- (NSString *)descriptionOfTree;
- (NSString *)descriptionToRoot;
- (void)addSubnode:(FTCoreTextNode *)node;
- (void)adjustStylesAndSubstylesRangesByRange:(NSRange)insertedRange;
- (void)insertSubnode:(FTCoreTextNode *)subnode atIndex:(NSUInteger)index;
- (void)insertSubnode:(FTCoreTextNode *)subnode beforeNode:(FTCoreTextNode *)node;
- (FTCoreTextNode *)previousNode;
- (FTCoreTextNode *)nextNode;
- (NSUInteger)nodeIndex;
- (FTCoreTextNode *)subnodeAtIndex:(NSUInteger)index;

@end

@implementation FTCoreTextNode

@synthesize supernode = _supernode;
@synthesize subnodes = _subnodes;
@synthesize style = _style;
@synthesize styleRange = _styleRange;
@synthesize isClosed = _isClosed;
@synthesize isLink = _isLink;
@synthesize isImage = _isImage;
@synthesize startLocation = _startLocation;
@synthesize isBullet = _isBullet;
@synthesize imageName = _imageName;

- (NSArray *)subnodes
{
	if (_subnodes == nil) {
		_subnodes = [NSMutableArray new];
	}
	return _subnodes;
}

- (void)addSubnode:(FTCoreTextNode *)node
{
	[self insertSubnode:node atIndex:[_subnodes count]];
}

- (void)insertSubnode:(FTCoreTextNode *)subnode atIndex:(NSUInteger)index
{
	subnode.supernode = self;
	
	NSMutableArray *subnodes = (NSMutableArray *)self.subnodes;
	if (index <= [_subnodes count]) {
		[subnodes insertObject:subnode atIndex:index];
	}
	else {
		[subnodes addObject:subnode];
	}
}

- (void)insertSubnode:(FTCoreTextNode *)subnode beforeNode:(FTCoreTextNode *)node
{
	NSInteger existingNodeIndex = [_subnodes indexOfObject:node];
	if (existingNodeIndex == NSNotFound) {
		[self addSubnode:subnode];
	}
	else {
		[self insertSubnode:subnode atIndex:existingNodeIndex];
	}
}

- (NSInteger)numberOfParents
{
	NSInteger returnedValue = 0;
	FTCoreTextNode *node = self.supernode;
	while (node) {
		returnedValue++;
		node = node.supernode;
	}
	return returnedValue;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@\t-\t%@ - \t%@", [super description], _style.name, NSStringFromRange(_styleRange)];
}

- (NSString *)descriptionToRoot
{
	NSMutableString *description = [NSMutableString stringWithString:@"\n\n"];
	
	FTCoreTextNode *node = self;
	do {
		[description insertString:[NSString stringWithFormat:@"%@",[self description]] atIndex:0];
		
		for (int i = 0; i < [self numberOfParents]; i++) {
			[description insertString:@"\t" atIndex:0];
		}
		[description insertString:@"\n" atIndex:0];
		node = node.supernode;
		
	} while (node);
	
	return description;
}

- (NSString *)descriptionOfTree
{
	NSMutableString *description = [NSMutableString string];
	for (int i = 0; i < [self numberOfParents]; i++) {
		[description insertString:@"\t" atIndex:0];
	}
	[description appendFormat:@"%@\n", [self description]];
	for (FTCoreTextNode *node in _subnodes) {
		[description appendString:[node descriptionOfTree]];
	}
	return description;
}

- (NSArray *)_allSubnodes
{
	NSMutableArray *subnodes = [[NSMutableArray new] autorelease];
	for (FTCoreTextNode *node in _subnodes) {
		[subnodes addObject:node];
		if (node.subnodes) [subnodes addObjectsFromArray:[node _allSubnodes]];
	}
	
	return subnodes;
}

//return an array of nodes starting with the current and recursively adding all its child nodes
- (NSArray *)allSubnodes
{
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	NSArray *allSubnodes = [[self _allSubnodes] copy];
	[pool release];
	NSMutableArray *returnedArray = [NSMutableArray arrayWithObject:self];
	[returnedArray addObjectsFromArray:allSubnodes];
	[allSubnodes release];
	return returnedArray;
}

- (void)adjustStylesAndSubstylesRangesByRange:(NSRange)insertedRange
{
	NSRange range = self.styleRange;
	if (range.length + range.location > insertedRange.location) {
		range.location += insertedRange.length;
	}
	self.styleRange = range;
	
	for (FTCoreTextNode *node in _subnodes) {
		[node adjustStylesAndSubstylesRangesByRange:insertedRange];
	}
}

- (NSUInteger)nodeIndex
{
	return [_supernode.subnodes indexOfObject:self];
}

- (FTCoreTextNode *)subnodeAtIndex:(NSUInteger)index
{
	if (index < [_subnodes count]) {
		return [_subnodes objectAtIndex:index];
	}
	return nil;
}

- (FTCoreTextNode *)previousNode
{
	NSUInteger index = [self nodeIndex];
	if (index != NSNotFound) {
		return [_supernode subnodeAtIndex:index - 1];
	}
	return nil;
}

- (FTCoreTextNode *)nextNode
{
	NSUInteger index = [self nodeIndex];
	if (index != NSNotFound) {
		return [_supernode subnodeAtIndex:index + 1];
	}
	return nil;	
}

- (void)dealloc
{
	[_subnodes release];
	[_style release];
	[_imageName release];
	[super dealloc];
}

@end



@interface FTCoreTextView ()

@property (nonatomic, assign) CTFramesetterRef framesetter;
@property (nonatomic, retain) FTCoreTextNode *rootNode;

- (void)updateFramesetterIfNeeded;
- (void)processText;
CTFontRef CTFontCreateFromUIFont(UIFont *font);

@end

@implementation FTCoreTextView

@synthesize text = _text;
@synthesize processedString = _processedString;
@synthesize path = _path;
@synthesize context = _context;
@synthesize URLs = _URLs;
@synthesize images = _images;
@synthesize delegate = _delegate;
@synthesize framesetter = _framesetter;
@synthesize rootNode = _rootNode;

CTFontRef CTFontCreateFromUIFont(UIFont *font)
{
    CTFontRef ctFont = CTFontCreateWithName((CFStringRef)font.fontName, 
                                            font.pointSize, 
                                            NULL);
    return ctFont;
}

- (NSDictionary *)dataForPoint:(CGPoint)point
{
	CGMutablePathRef mainPath = CGPathCreateMutable();
    if (!_path) {
        CGPathAddRect(mainPath, NULL, 
                      CGRectMake(0, 0, 
                                 self.bounds.size.width,
                                 self.bounds.size.height));  
    }
    else {
        CGPathAddPath(mainPath, NULL, _path);
    }
	
    CTFrameRef ctframe = CTFramesetterCreateFrame(_framesetter, CFRangeMake(0, 0), mainPath, NULL);
    CGPathRelease(mainPath);
	
    NSArray *lines = (NSArray *)CTFrameGetLines(ctframe);
    NSInteger lineCount = [lines count];
    CGPoint origins[lineCount];
    
    if (lineCount == 0) return nil;
	
	CTFrameGetLineOrigins(ctframe, CFRangeMake(0, 0), origins);
	for (int i = 0; i < lineCount; i++) {
		CGPoint baselineOrigin = origins[i];
		//the view is inverted, the y origin of the baseline is upside down
		baselineOrigin.y = CGRectGetHeight(self.frame) - baselineOrigin.y;
		
		CTLineRef line = (CTLineRef)[lines objectAtIndex:i];
		CGFloat ascent, descent;
		CGFloat lineWidth = CTLineGetTypographicBounds(line, &ascent, &descent, NULL);
		
		CGRect lineFrame = CGRectMake(baselineOrigin.x, baselineOrigin.y - ascent, lineWidth, ascent + descent);
		
		if (CGRectContainsPoint(lineFrame, point)) {
			//we look if the position of the touch is correct on the line
			
			CFIndex index = CTLineGetStringIndexForPosition(line, point);
			NSArray *urlsKeys = [_URLs allKeys];
			
			for (NSString *key in urlsKeys) {
				NSRange range = NSRangeFromString(key);
				if (index >= range.location && index < range.location + range.length) {
					NSURL *url = [_URLs objectForKey:key];
					NSMutableDictionary *dict = [NSMutableDictionary dictionary];
					if (url) [dict setObject:url forKey:@"url"];
					return dict;
				}
			}
		}
	}
	return nil;
}

- (void)applyStyle:(FTCoreTextStyle *)style inRange:(NSRange)styleRange onString:(NSMutableAttributedString **)attributedString
{
	[*attributedString addAttribute:(id)kCTForegroundColorAttributeName
							  value:(id)style.color.CGColor
							  range:styleRange];
	
	CTFontRef ctFont = CTFontCreateFromUIFont(style.font);
	
	[*attributedString addAttribute:(id)kCTFontAttributeName
							  value:(id)ctFont
							  range:styleRange];
	CFRelease(ctFont);
	
	CTTextAlignment alignment = style.textAlignment;
	CGFloat maxLineHeight = style.maxLineHeight;
	CGFloat minLineHeight = style.minLineHeight;
	CGFloat paragraphLeading = style.leading;
	
	CGFloat paragraphSpacingBefore = style.paragraphInset.top;
	CGFloat paragraphSpacingAfter = style.paragraphInset.bottom;
	CGFloat paragraphFirstLineHeadIntent = style.paragraphInset.left;
	CGFloat paragraphHeadIntent = style.paragraphInset.left;
	CGFloat paragraphTailIntent = style.paragraphInset.right;
	
	//if (SYSTEM_VERSION_LESS_THAN(@"5.0")) {
	paragraphSpacingBefore = 0;
	//}
	
	CFIndex numberOfSettings = 9;
	CGFloat tabSpacing = 28.f;
	
	BOOL applyParagraphStyling = style.applyParagraphStyling;
	
	if ([style.name isEqualToString:FTCoreTextTagBullet]) {
		applyParagraphStyling = YES;
	}
	else if ([style.name isEqualToString:@"_FTBulletStyle"]) {
		applyParagraphStyling = YES;
		numberOfSettings++;
		tabSpacing = style.paragraphInset.right;
		paragraphSpacingBefore = 0;
		paragraphSpacingAfter = 0;
		paragraphFirstLineHeadIntent = 0;
		paragraphTailIntent = 0;
	}
	else if ([style.name hasPrefix:@"_FTTopSpacingStyle"]) {
		[*attributedString removeAttribute:(id)kCTParagraphStyleAttributeName range:styleRange];
	}
	
	if (applyParagraphStyling) {
		
		CTTextTabRef tabArray[] = { CTTextTabCreate(0, tabSpacing, NULL) };
		
		CFArrayRef tabStops = CFArrayCreate( kCFAllocatorDefault, (const void**) tabArray, 1, &kCFTypeArrayCallBacks );
		CFRelease(tabArray[0]);
		
		CTParagraphStyleSetting settings[] = {
			{kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment},
			{kCTParagraphStyleSpecifierMaximumLineHeight, sizeof(CGFloat), &maxLineHeight},
			{kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(CGFloat), &minLineHeight},
			{kCTParagraphStyleSpecifierParagraphSpacingBefore, sizeof(CGFloat), &paragraphSpacingBefore},
			{kCTParagraphStyleSpecifierParagraphSpacing, sizeof(CGFloat), &paragraphSpacingAfter},
			{kCTParagraphStyleSpecifierFirstLineHeadIndent, sizeof(CGFloat), &paragraphFirstLineHeadIntent},
			{kCTParagraphStyleSpecifierHeadIndent, sizeof(CGFloat), &paragraphHeadIntent},
			{kCTParagraphStyleSpecifierTailIndent, sizeof(CGFloat), &paragraphTailIntent},
			{kCTParagraphStyleSpecifierLineSpacing, sizeof(CGFloat), &paragraphLeading},
			{kCTParagraphStyleSpecifierTabStops, sizeof(CFArrayRef), &tabStops}//always at the end
		};
		
		CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, numberOfSettings);
		[*attributedString addAttribute:(id)kCTParagraphStyleAttributeName
								  value:(id)paragraphStyle 
								  range:styleRange];
		CFRelease(tabStops);
		CFRelease(paragraphStyle);
	}
}

- (void)updateFramesetterIfNeeded
{
    if (_changesMade) {
		_changesMade = NO;
		[self processText];
		
		if (!_processedString || [_processedString length] == 0) {
			if (_framesetter) {
				CFRelease(_framesetter);
				_framesetter = NULL;
			}
			return;
		}
		
		NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:_processedString];
		
		for (FTCoreTextNode *node in [_rootNode allSubnodes]) {
			[self applyStyle:node.style inRange:node.styleRange onString:&string];
		}
		
		// layout master 
		if (_framesetter != NULL) CFRelease(_framesetter);
		_framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)string);
		[string release];
    }
}

/*!
 * @abstract get the supposed size of the drawn text
 *
 */

- (CGSize)suggestedSizeConstrainedToSize:(CGSize)size
{
	[self updateFramesetterIfNeeded];
	if (_framesetter == NULL) {
		return CGSizeZero;
	}
	CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(_framesetter, CFRangeMake(0, 0), NULL, size, NULL);
	suggestedSize = CGSizeMake(ceilf(suggestedSize.width), ceilf(suggestedSize.height));
    return suggestedSize;
}

/*!
 * @abstract handy method to fit to the suggested height in one call
 *
 */

- (void)fitToSuggestedHeight
{
	CGSize suggestedSize = [self suggestedSizeConstrainedToSize:CGSizeMake(CGRectGetWidth(self.frame), MAXFLOAT)];
	CGRect viewFrame = self.frame;
	viewFrame.size.height = suggestedSize.height;
	self.frame = viewFrame;
}

/*!
 * @abstract divide the text in different pages according to the tags <_page/> found
 *
 */

- (NSMutableArray *)divideTextInPages:(NSString *)string
{
    NSMutableArray *result = [NSMutableArray array];
    int prevStart = 0;
    while (YES) {
        NSRange rangeStart = [string rangeOfString:@"<_page/>"];
        if (rangeStart.location != NSNotFound) {
            NSString *page = [string substringWithRange:NSMakeRange(prevStart, rangeStart.location)];
            [result addObject:page];
            string = [string stringByReplacingCharactersInRange:rangeStart withString:@""];
            prevStart = rangeStart.location;
        }
        else {
            NSString *page = [string substringWithRange:NSMakeRange(prevStart, (string.length - prevStart))];
            [result addObject:page];
            break;
        }
    }
    return result;
}

/*!
 * @abstract process the text before drawing.
 *
 */

- (void)processText
{    
    if (!_text || [_text length] == 0) return;
	
	FTCoreTextStyle *defaultStyle = [[_styles objectForKey:FTCoreTextTagDefault] retain];
	if (defaultStyle == nil) {
		defaultStyle = [FTCoreTextStyle new];
		[self addStyle:defaultStyle];
	}
	if (![_styles objectForKey:FTCoreTextTagLink]) {
		//we add a default style for links
		FTCoreTextStyle *linksStyle = [defaultStyle copy];
		linksStyle.color = [UIColor blueColor];
		linksStyle.name = FTCoreTextTagLink;
		[_styles setValue:linksStyle forKey:linksStyle.name];
		[linksStyle release];
	}
	
    [_URLs removeAllObjects];
    [_images removeAllObjects];
	
	FTCoreTextNode *rootNode = [[FTCoreTextNode new] autorelease];
	rootNode.style = defaultStyle;
	[defaultStyle release];
	
	FTCoreTextNode *currentSupernode = rootNode;
	
	NSMutableString *processedString = [NSMutableString stringWithString:_text];
	
	BOOL finished = NO;
	NSRange remainingRange = NSMakeRange(0, [processedString length]);
	
	NSString *regEx = @"<(/){0,1}[_a-zA-Z0-9]*( /){0,1}>";
	
	while (!finished) {
		
		NSRange tagRange = [processedString rangeOfString:regEx options:NSRegularExpressionSearch range:remainingRange];
		if (tagRange.location == NSNotFound) {
			if (currentSupernode != rootNode && !currentSupernode.isClosed) {
				NSLog(@"FTCoreTextView :%@ - Couldn't parse text because tag '%@' at position %d is not closed - aborting rendering", self, currentSupernode.style.name, currentSupernode.startLocation);
				return;
			}
			finished = YES;
		}
		else {
			NSString *fullTag = [processedString substringWithRange:tagRange];
			
			FTCoreTextTagType tagType;
			
			if ([fullTag rangeOfString:@"</"].location == 0) {
				tagType = FTCoreTextTagClose;
			}
			else if ([fullTag rangeOfString:@"/"].location == NSNotFound) {
				tagType = FTCoreTextTagOpen;
			}
			else if ([fullTag rangeOfString:@" /"].location != NSNotFound || [fullTag rangeOfString:@"/"].location != NSNotFound) {
				tagType = FTCoreTextTagSelfClose;
			}
			else {
				NSLog(@"FTCoreTextView :%@ - Couldn't parse tag '%@' at range %@ - aborting rendering", self, fullTag, NSStringFromRange(tagRange));
				return;
			}
			
			NSString *tagName = [fullTag stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"< />"]];
			FTCoreTextStyle *style = [_styles objectForKey:tagName];
			
			if (style == nil) {
				style = [_styles objectForKey:FTCoreTextTagDefault];
				NSLog(@"FTCoreTextView :%@ - Couldn't find style for tag '%@'", self, tagName);
			}
			
			switch (tagType) {
				case FTCoreTextTagOpen:
				{
					if (currentSupernode.isLink || currentSupernode.isImage) {
						NSString *predefinedTag = nil;
						if (currentSupernode.isLink) predefinedTag = FTCoreTextTagLink;
						else if (currentSupernode.isImage) predefinedTag = FTCoreTextTagImage;
						NSLog(@"FTCoreTextView :%@ - You can't open a new tag inside a '%@' tag - aborting rendering", self, predefinedTag);
						return;
					}
					
					FTCoreTextNode *newNode = [FTCoreTextNode new];
					newNode.style = style;
					newNode.startLocation = tagRange.location;
					
					if ([tagName isEqualToString:FTCoreTextTagLink]) {
						newNode.isLink = YES;
					}
					else if ([tagName isEqualToString:FTCoreTextTagBullet]) {
						newNode.isBullet = YES;
						
						NSString *appendedString = [NSString stringWithFormat:@"%@\t", newNode.style.bulletCharacter];
						
						[processedString insertString:appendedString atIndex:tagRange.location + tagRange.length];
						
						//bullet styling
						FTCoreTextStyle *bulletStyle = [FTCoreTextStyle new];
						bulletStyle.name = @"_FTBulletStyle";
						bulletStyle.font = newNode.style.bulletFont;
						bulletStyle.color = newNode.style.bulletColor;
						bulletStyle.applyParagraphStyling = NO;
						bulletStyle.paragraphInset = UIEdgeInsetsMake(0, 0, 0, newNode.style.paragraphInset.left);
						
						FTCoreTextNode *bulletNode = [FTCoreTextNode new];
						bulletNode.style = bulletStyle;
						[bulletStyle release];
						bulletNode.styleRange = NSMakeRange(tagRange.location, [appendedString length]);
						
						[newNode addSubnode:bulletNode];
						[bulletNode release];
					}
					else if ([tagName isEqualToString:FTCoreTextTagImage]) {
						newNode.isImage = YES;
					}
					
					[processedString replaceCharactersInRange:tagRange withString:@""];
					
					[currentSupernode addSubnode:newNode];
					[newNode release];
					
					currentSupernode = newNode;
					
					remainingRange.location = tagRange.location;
					remainingRange.length = [processedString length] - tagRange.location;
				}
					break;
				case FTCoreTextTagClose:
				{
					if ([currentSupernode.style.name isEqualToString:FTCoreTextTagDefault] || [currentSupernode.style.name isEqualToString:tagName]) {
						currentSupernode.isClosed = YES;
						
						if (currentSupernode.isLink) {
							//replace active string with url text
							
							NSRange elementContentRange = NSMakeRange(currentSupernode.startLocation, tagRange.location - currentSupernode.startLocation);
							NSString *elementContent = [processedString substringWithRange:elementContentRange];
							NSRange pipeRange = [elementContent rangeOfString:@"|"];
							NSString *urlString = nil;
							NSString *urlDescription = nil;
							if (pipeRange.location != NSNotFound) {
								urlString = [elementContent substringToIndex:pipeRange.location];
								urlDescription = [elementContent substringFromIndex:pipeRange.location + 1];
							}
							
							[processedString replaceCharactersInRange:NSMakeRange(elementContentRange.location, elementContentRange.length + tagRange.length) withString:urlDescription];
							NSURL *url = [NSURL URLWithString:urlString];
							NSRange urlDescriptionRange = NSMakeRange(elementContentRange.location, [urlDescription length]);
							[_URLs setObject:url forKey:NSStringFromRange(urlDescriptionRange)];
							
							currentSupernode.styleRange = urlDescriptionRange;
						}
						else if (currentSupernode.isImage) {
							//replace active string with emptySpace
							
							NSRange elementContentRange = NSMakeRange(currentSupernode.startLocation, tagRange.location - currentSupernode.startLocation);
							NSString *elementContent = [processedString substringWithRange:elementContentRange];
							
							UIImage *img = [UIImage imageNamed:elementContent];
							
							if (img) {
								int skipLine = floorf(img.size.height / currentSupernode.style.font.leading);
								NSMutableString *lines = [NSMutableString string];
								for (int i = 0; i < skipLine; i++) {
									[lines appendFormat:@"\n"];
								}
								
								currentSupernode.imageName = elementContent;
								[processedString replaceCharactersInRange:NSMakeRange(elementContentRange.location, elementContentRange.length + tagRange.length) withString:lines];
								[_images addObject:currentSupernode];
								currentSupernode.styleRange = NSMakeRange(elementContentRange.location, [lines length]);
							}
							else {
								NSLog(@"FTCoreTextView :%@ - Couldn't find image '%@' in main bundle", self, elementContentRange);
								[processedString replaceCharactersInRange:tagRange withString:@""];
							}
						}
						else {
							currentSupernode.styleRange = NSMakeRange(currentSupernode.startLocation, tagRange.location - currentSupernode.startLocation);
							[processedString replaceCharactersInRange:tagRange withString:@""];
						}
						
						if ([currentSupernode.style.appendedCharacter length] > 0) {
							[processedString insertString:currentSupernode.style.appendedCharacter atIndex:currentSupernode.styleRange.location + currentSupernode.styleRange.length];
							NSRange newStyleRange = currentSupernode.styleRange;
							newStyleRange.length += [currentSupernode.style.appendedCharacter length];
							currentSupernode.styleRange = newStyleRange;							
						}
						
						if (style.paragraphInset.top > 0) {
							if (![style.name isEqualToString:FTCoreTextTagBullet] ||  [[currentSupernode previousNode].style.name isEqualToString:FTCoreTextTagBullet]) {
								
								//fix: add a new line for each new line and set its height to 'top' value
								[processedString insertString:@"\n" atIndex:currentSupernode.startLocation];
								NSRange topSpacingStyleRange = NSMakeRange(currentSupernode.startLocation, [@"\n" length]);
								FTCoreTextStyle *topSpacingStyle = [[FTCoreTextStyle alloc] init];
								topSpacingStyle.name = [NSString stringWithFormat:@"_FTTopSpacingStyle_%@", currentSupernode.style.name];
								topSpacingStyle.minLineHeight = currentSupernode.style.paragraphInset.top;
								topSpacingStyle.maxLineHeight = currentSupernode.style.paragraphInset.top;
								FTCoreTextNode *topSpacingNode = [[FTCoreTextNode alloc] init];
								topSpacingNode.style = topSpacingStyle;
								[topSpacingStyle release];
								
								topSpacingNode.styleRange = topSpacingStyleRange;
								
								[currentSupernode.supernode insertSubnode:topSpacingNode beforeNode:currentSupernode];
								[topSpacingNode release];
								
								[currentSupernode adjustStylesAndSubstylesRangesByRange:topSpacingStyleRange];
							}
						}
						
						remainingRange.location = currentSupernode.styleRange.location + currentSupernode.styleRange.length;
						remainingRange.length = [processedString length] - remainingRange.location;
						
						currentSupernode = currentSupernode.supernode;
					}
					else {
						NSLog(@"FTCoreTextView :%@ - Closing tag '%@' at range %@ doesn't match open tag '%@' - aborting rendering", self, fullTag, NSStringFromRange(tagRange), currentSupernode.style.name);
						return;
					}
				}
					break;
				case FTCoreTextTagSelfClose:
				{
					FTCoreTextNode *newNode = [FTCoreTextNode new];
					newNode.style = style;
					[processedString replaceCharactersInRange:tagRange withString:newNode.style.appendedCharacter];
					newNode.styleRange = NSMakeRange(tagRange.location, [newNode.style.appendedCharacter length]);
					[currentSupernode addSubnode:newNode];	
					[newNode release];
					
					remainingRange.location = tagRange.location;
					remainingRange.length = [processedString length] - tagRange.location;
				}
					break;
			}
		}
	}	
	
	rootNode.styleRange = NSMakeRange(0, [processedString length]);
	
	self.rootNode = rootNode;	
	self.processedString = processedString;
}

- (void)drawImages
{    
	CGMutablePathRef mainPath = CGPathCreateMutable();
    if (!_path) {
        CGPathAddRect(mainPath, NULL, 
                      CGRectMake(0, 0, 
                                 self.bounds.size.width,
                                 self.bounds.size.height));  
    }
    else {
        CGPathAddPath(mainPath, NULL, _path);
    }
	
    CTFrameRef ctframe = CTFramesetterCreateFrame(_framesetter, CFRangeMake(0, 0), mainPath, NULL);
    CGPathRelease(mainPath);
	
    NSArray *lines = (NSArray *)CTFrameGetLines(ctframe);
    NSInteger lineCount = [lines count];
    CGPoint origins[lineCount];
	
	CTFrameGetLineOrigins(ctframe, CFRangeMake(0, 0), origins);
	
	FTCoreTextNode *imageNode = [_images objectAtIndex:0];
	
	for (int i = 0; i < lineCount; i++) {
		CGPoint baselineOrigin = origins[i];
		//the view is inverted, the y origin of the baseline is upside down
		baselineOrigin.y = CGRectGetHeight(self.frame) - baselineOrigin.y;
		
		CTLineRef line = (CTLineRef)[lines objectAtIndex:i];
		CFRange cfrange = CTLineGetStringRange(line);        
		
        if (cfrange.location > imageNode.styleRange.location) {
			CGFloat ascent, descent;
			CGFloat lineWidth = CTLineGetTypographicBounds(line, &ascent, &descent, NULL);
			
			CGRect lineFrame = CGRectMake(baselineOrigin.x, baselineOrigin.y - ascent, lineWidth, ascent + descent);
			
			CTTextAlignment alignment = imageNode.style.textAlignment;
			
			UIImage *img = [UIImage imageNamed:imageNode.imageName];
			if (img) {
				int x = 0;
				if (alignment == kCTRightTextAlignment) x = (self.frame.size.width - img.size.width);
				if (alignment == kCTCenterTextAlignment) x = ((self.frame.size.width - img.size.width) / 2);
				
				CGRect frame = CGRectMake(x, lineFrame.origin.y, img.size.width, img.size.height);
				[img drawInRect:CGRectIntegral(frame)];
			}
			
			NSInteger imageNodeIndex = [_images indexOfObject:imageNode];
			if (imageNodeIndex < [_images count] - 1) {
				imageNode = [_images objectAtIndex:imageNodeIndex + 1];
			}
			else {
				break;
			}
		}
	}
	CFRelease(ctframe);
}

/*!
 * @abstract Remove all the tags and return a clean text to be used in case Core Text is not supported (iOS 4.0 on)
 *
 */

+ (NSString *)stripTagsforString:(NSString *)string
{
    FTCoreTextView *instance = [[FTCoreTextView alloc] initWithFrame:CGRectZero];
    [instance setText:string];
    [instance processText];
    NSString *result = [NSString stringWithString:instance.processedString];
    [instance release];
    return result;
}

/*!
 * @abstract divide the text in different pages according to the tags <_page/> found
 *
 */

+ (NSArray *)pagesFromText:(NSString *)string
{
    FTCoreTextView *instance = [[FTCoreTextView alloc] initWithFrame:CGRectZero];
    NSArray *result = [instance divideTextInPages:string];
	[instance release];
    return (NSArray *)result;
}


#pragma mark Initialization

- (void)doInit
{
	// Initialization code
	_framesetter = NULL;
	_styles = [[NSMutableDictionary alloc] init];
	_URLs = [[NSMutableDictionary alloc] init];
    _images = [[NSMutableArray alloc] init];
	self.opaque = NO;
	self.backgroundColor = [UIColor clearColor];
	self.contentMode = UIViewContentModeRedraw;
	[self setUserInteractionEnabled:YES];
}

- (id)init
{
    self = [super init];
    if (self) {
        [self doInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self doInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self doInit];
    }
    return self;
}

#pragma mark Draw rect

/*!
 * @abstract draw the actual coretext on the context
 *
 */

- (void)drawRect:(CGRect)rect
{
	[self updateFramesetterIfNeeded];
	
	_context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(_context);
	[self.backgroundColor setFill];
	CGContextFillRect(_context, rect);
	CGContextRestoreGState(_context);
	
	CGMutablePathRef mainPath = CGPathCreateMutable();
   	
    if (!_path) {
        CGPathAddRect(mainPath, NULL, 
                      CGRectMake(0, 0, 
                                 self.bounds.size.width,
                                 self.bounds.size.height));  
    }
    else {
        CGPathAddPath(mainPath, NULL, _path);
    }
    
	
    
	CTFrameRef drawFrame = CTFramesetterCreateFrame(_framesetter, 
                                                    CFRangeMake(0, 0),
                                                    mainPath, NULL);
    
    // flip coordinate system
    _context = UIGraphicsGetCurrentContext();
    CGContextClearRect(self.context, self.frame);
    
    //draw images
    if ([_images count] > 0) [self drawImages];
    
    
	CGContextSetTextMatrix(self.context, CGAffineTransformIdentity);
	CGContextTranslateCTM(self.context, 0, self.bounds.size.height);
	CGContextScaleCTM(self.context, 1.0, -1.0);
	// draw
	CTFrameDraw(drawFrame, self.context);
    CGContextSaveGState(self.context);
	
	// cleanup
	CFRelease(drawFrame);
	CGPathRelease(mainPath);
}


#pragma mark --
#pragma mark custom setters

- (void)setText:(NSString *)text
{
    [_text release];
    _text = [text retain];
	_changesMade = YES;
    if ([self superview]) [self setNeedsDisplay];
}

- (void)addStyle:(FTCoreTextStyle *)style
{
    [_styles setValue:style forKey:style.name];
	_changesMade = YES;
    if ([self superview]) [self setNeedsDisplay];
}

- (void)addStyles:(NSArray *)styles
{
	for (FTCoreTextStyle *style in styles) {
		[_styles setValue:style forKey:style.name];
	}
	_changesMade = YES;
    if ([self superview]) [self setNeedsDisplay];
}

- (NSArray *)stylesArray
{
	return [_styles allValues];
}

//only here to assure compatibility with previous versions
- (NSDictionary *)styles
{
	return [[_styles copy] autorelease];
}

//only here to assure compatibility with previous versions
- (void)setStyles:(NSDictionary *)styles
{
	[_styles release];
    _styles = [styles mutableCopy];
	_changesMade = YES;
    if ([self superview]) [self setNeedsDisplay];
}

- (void)setPath:(CGPathRef)path
{
    _path = CGPathRetain(path);
	_changesMade = YES;
    if ([self superview]) [self setNeedsDisplay];
}

- (void)dealloc
{
	if (_framesetter) CFRelease(_framesetter);
	[_rootNode release];
    [_text release];
    [_styles release];
    [_processedString release];
    [_URLs release], _URLs = nil;
    [_images release], _images = nil;
    _delegate = nil;
    [super dealloc];
}

#pragma mark touches

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [(UITouch *)[touches anyObject] locationInView:self];
    NSDictionary *data = [self dataForPoint:point];
    
    if (data && self.delegate && [self.delegate respondsToSelector:@selector(touchedData:inCoreTextView:)]) {
        [self.delegate touchedData:data inCoreTextView:self];
    }
}

@end

@implementation NSString (FTCoreText)
- (NSString *)stringByAppendingTagName:(NSString *)tagName
{
	return [NSString stringWithFormat:@"<%@>%@</%@>", tagName, self, tagName];
}
@end