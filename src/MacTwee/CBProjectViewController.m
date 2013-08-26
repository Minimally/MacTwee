/*
 Copyright (c) 2013 Chris Braithwaite. All rights reserved.
 */

#import "CBProjectViewController.h"
#import "CBProjectEditor.h"

@implementation CBProjectViewController

- (void)awakeFromNib {
	//self.passageTextView.backgroundColor = [NSColor blackColor];
	//self.passageTextView.insertionPointColor = [NSColor whiteColor];
	//self.passageTextView.textColor = [NSColor whiteColor];
	self.passageTextView.font = [NSFont userFontOfSize:16];
	self.passagesArrayControllerSortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(caseInsensitiveCompare:)] ];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Protocol
////////////////////////////////////////////////////////////////////////

@end
