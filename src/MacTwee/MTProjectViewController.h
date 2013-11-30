//
//  MacTwee
//
//  Created by Chris Braithwaite on 11/23/13.
//  Copyright 2013 Chris Braithwaite. Released under MIT License.
//

#import <Cocoa/Cocoa.h>
#import <SpriteKit/SpriteKit.h>
#import <WebKit/WebKit.h>


@interface MTProjectViewController : NSViewController <NSTableViewDelegate>

@property (weak) IBOutlet NSTabView * leftTabView;

@property (strong) IBOutlet NSArrayController * passageArrayController;
@property (unsafe_unretained) IBOutlet NSTextView * passageTextView;
@property (strong) NSArray * passagesArrayControllerSortDescriptors;
@property (weak) IBOutlet SKView * visualEditorSKView;
@property (weak) IBOutlet WebView * webView;
@property (weak) IBOutlet NSTextField * webViewAddressBar;

- (IBAction)deletePassage:(id)sender;

/// back and forward buttons for webview
- (IBAction)webViewNavigate:(id)sender;

@end
