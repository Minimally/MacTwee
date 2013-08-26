/*
 Copyright (c) 2013 Chris Braithwaite. All rights reserved.
 */

#import "CBPrimaryWindowController.h"
#import "CBHomeViewController.h"
#import "CBProjectViewController.h"
#import "CBTweeFileTools.h"
#import "CBProjectEditor.h"

@implementation CBPrimaryWindowController

CBTweeFileTools * tweeFileTools;

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (void)awakeFromNib {
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(processNotification:)
												 name:kCBPrimaryWindowControllerWillOpenViewNotification
											   object:nil];

	[self selectView:CBPageHome];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Public
////////////////////////////////////////////////////////////////////////

- (void)selectView:(NSInteger)whichViewTag {
	[self changeViewController:whichViewTag];
}

- (IBAction)newPassage:(id)sender {
	[[CBProjectEditor sharedCBProjectEditor] newPassage];
}

- (IBAction)buildStory:(id)sender {
	if (tweeFileTools == nil)
		tweeFileTools = [[CBTweeFileTools alloc]init];
	[tweeFileTools buildStory];
}

- (IBAction)buildAndRun:(id)sender {
	if (tweeFileTools == nil)
		tweeFileTools = [[CBTweeFileTools alloc]init];
	[tweeFileTools buildAndRunStory];
}

- (IBAction)importStory:(id)sender {
	if (tweeFileTools == nil)
		tweeFileTools = [[CBTweeFileTools alloc]init];
	[tweeFileTools importTweeFile];
}

- (IBAction)exportStory:(id)sender {
	if (tweeFileTools == nil)
		tweeFileTools = [[CBTweeFileTools alloc]init];
	[tweeFileTools exportTweeFile];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

- (void)processNotification:(NSNotification *) notification {
	//NSLog(@"%s:%d:Notification is successfully received! %@", __func__, __LINE__, notification);
	
    if ([notification.name isEqualToString:kCBPrimaryWindowControllerWillOpenViewNotification]) {
		if ( [[notification userInfo] objectForKey:@"index"] ) {
			//NSLog(@"The object for key index is %@", [[notification userInfo] objectForKey:@"index"]);
			NSNumber *aNumber = [[notification userInfo] objectForKey:@"index"];
			[self changeViewController:[aNumber integerValue]];
		}
	}
}

- (void)changeViewController:(NSInteger)whichViewTag {
	//NSLog(@"%s 'Line:%d' - view:'%ld'", __func__, __LINE__, (long)whichViewTag);
		
	if (_currentViewController.view != nil)
		[_currentViewController.view removeFromSuperview];	// remove the current view
	
	if (_currentViewController != nil)
		_currentViewController = nil;		// remove the current view controller
	
	switch (whichViewTag)
	{
		case CBPageHome:	// swap in the "CBProjectSelectionViewController"
		{
			[self.window.toolbar setVisible:NO];
			self.window.title = @"MacTwee - Story Manager";
			CBHomeViewController* view = [[CBHomeViewController alloc] initWithNibName:@"CBHomeView" bundle:nil];
			NSAssert(view != nil, @"CBHomeView is nil");
			if (view != nil)
			{
				_currentViewController = view;	// keep track of the current view controller
				_currentViewController.title = @"Projects";
			}
			break;
		}
		
		case CBPageProject:	// swap in the "CBProjectViewController"
		{
			self.window.title = @"MacTwee - Story Editor";
			[self.window.toolbar setVisible:YES];
			CBProjectViewController * view = [[CBProjectViewController alloc] initWithNibName:@"CBProjectView" bundle:nil];
			NSAssert(view != nil, @"CBProjectView is nil");
			if (view != nil)
			{
				_currentViewController = view;	// keep track of the current view controller
				_currentViewController.title = @"Project";
			}
			break;
		}
			
		default: break;
	}
	
	NSAssert(_currentViewController != nil, @"_currentViewController is nil");
	
	//constrain a view so that it occupies the entire window’s content view, resizing when appropriate.
	NSView *customView = _currentViewController.view;
	NSAssert(customView != nil, @"customView is nil");
	
	customView.translatesAutoresizingMaskIntoConstraints = NO;
		
	// embed the current view to our host view
	[self.holderView addSubview:customView];
	
	NSDictionary *views = NSDictionaryOfVariableBindings(customView);
	[self.holderView addConstraints:
	 [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[customView]|"
											 options:0
											 metrics:nil
											   views:views]];
	[self.holderView addConstraints:
	[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[customView]|"
											 options:0
											 metrics:nil
											   views:views]];
	
	for (NSView * view in [customView subviews]) {
		view.translatesAutoresizingMaskIntoConstraints = NO;
	}
}

@end
