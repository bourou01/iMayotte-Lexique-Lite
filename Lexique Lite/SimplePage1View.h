//
//  SimplePage1View.h
//  FireUIPagedScrollViewiPhoneSample
//
//  Created by Johan Hernandez on 8/24/11.
//  Copyright 2011 Firebase. All rights reserved.
//  http://www.firebase.co
//

#import <UIKit/UIKit.h>
#import "FTCoreTextView.h"


@interface SimplePage1View : UIViewController <FTCoreTextViewDelegate>

@property (nonatomic, retain) NSString *word;
@property (nonatomic, retain) NSString *definition;

@property (nonatomic, retain) FTCoreTextView *coreTextView;

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

@end
