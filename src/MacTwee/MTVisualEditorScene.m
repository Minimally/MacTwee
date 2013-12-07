//
//  MTVisualEditorScene.m
//  MacTwee
//
//  Created by Chris Braithwaite on 11/24/13.
//  Copyright (c) 2013 MacTwee. Released under MIT License.
//

#import "MTVisualEditorScene.h"
#import "MTProjectEditor.h"
#import "MTProject.h"
#import "MTPassage.h"
#import "MTCoreDataManager.h"


@implementation MTVisualEditorScene {
    BOOL contentCreated;
    BOOL passageDraggingActive;
    SKNode * selectedNode;
    SKNode * rootNode;
    SKNode * linkRootNode;
    int smartLevel;
    double smartX;
    double smartY;
    BOOL smartYFlipper;
    NSMutableArray * smartPassages;
    NSMutableSet * smartCheckedPassages;
}

// scrolling speed (NSTimeInterval for action)
static double kScrollingTimeInterval = 0.5;
static double  kScrollingSpeed = 1;

/// name given to all labels so clicks will go through to parent sprite
static NSString * const kLabelName = @"label";

/// name given to things to be ignored
static NSString * const kIgnoreName = @"ignore";

// values for creating links
static double kShapeLineWidth = 0.5;
static double kShapeIncomingXPosition = -50;
static double kShapeIncomingYPosition = 0;
static double kShapeOutgoingXPosition = 50;
static double kShapeOutgoingYPosition = 0;
static int controlPntDist = 30;

// values for creating nodes
static double kSpriteSizeX = 100;
static double kSpriteSizeY = 20;
static NSString * const kLabelFont = @"monaco";
static int kLabelMaxCharacters = 13;
static int kLabelFontSize = 12;

// values for positioning automatically
static double kBaseX = 50;
static double kBaseY = 15;
static double kIncrementX = 150;
static double kIncrementY = 35;
static double kCapX = 900;

// values for z depth of nodes
static double kShapeDepth = 9;
static double kSpriteDepth = 10;
static double kLabelDepth = 11;


#pragma mark - initialization

- (void)didMoveToView:(SKView *)view {
    if (contentCreated) { return; }
    contentCreated = YES;
    
    self.backgroundColor = [SKColor grayColor];
    self.scaleMode = SKSceneScaleModeResizeFill;
    
    rootNode = [[SKNode alloc]init];
    [self addChild:rootNode];
    linkRootNode = [[SKNode alloc]init];
    [rootNode addChild:linkRootNode];
    
    [self applyPassagesToScene];
}


#pragma mark - Sprite Kit Callbacks

-(void)update:(CFTimeInterval)currentTime {
    if (!self.needsUpdate) { return; }
    
    selectedNode = nil;
    
    [rootNode removeAllChildren];
    
    linkRootNode = [[SKNode alloc]init];
    [rootNode addChild:linkRootNode];
    
    [self applyPassagesToScene];
    
    self.needsUpdate = NO;
}


#pragma mark - Responder Events

- (void)mouseDown:(NSEvent *)theEvent {
    // this stuff is to allow drag and move of nodes
    CGPoint location = [theEvent locationInNode:self];
    SKNode * hitNode = [self nodeAtPoint:location];
    //NSLog(@"%d | %s - hitNode:'%@'", __LINE__, __func__, hitNode);
    if ( [hitNode isKindOfClass:[SKSpriteNode class]] || [hitNode isKindOfClass:[SKLabelNode class]]) {
        if ( [[hitNode name] isEqualToString:kLabelName] ) { // getting the parent if label was clicked
            hitNode = hitNode.parent;
        }
        selectedNode = hitNode;
        
        [[MTProjectEditor sharedMTProjectEditor] selectCurrentPassageWithName:selectedNode.name];
        
        //TODO: grab the delta between mouse pos and node and add that during reposition
        
        passageDraggingActive = YES;
    }
}

- (void)mouseDragged:(NSEvent *)theEvent {
    if (passageDraggingActive) {
        CGPoint location = [theEvent locationInNode:rootNode];
        selectedNode.position = location;
    }
}

- (void)mouseUp:(NSEvent *)theEvent {
    if (passageDraggingActive) {
        NSAssert(selectedNode != nil, @"selectedNode is nil");
        if (selectedNode != nil) { [self trySaveSelectedNodePosition]; }
        selectedNode = nil;
        self.needsUpdate = YES;
        passageDraggingActive = NO;
    }
}

- (void)rightMouseDown:(NSEvent *)theEvent {
    [super rightMouseDown:theEvent];
    //NSLog(@"%d | %s - ", __LINE__, __func__);
    
    CGPoint location = [theEvent locationInNode:rootNode];
    SKNode * hitNode = [self nodeAtPoint:location];
    
    if ([hitNode isKindOfClass:[SKSpriteNode class]] ||
        [hitNode isKindOfClass:[SKLabelNode class]] ||
        [hitNode isKindOfClass:[SKShapeNode class]] ) {
        NSLog(@"%d | %s - hitnode:'%@'", __LINE__, __func__, hitNode);
        return;
    }
    
    //NSLog(@"%d | %s - create passage at this point", __LINE__, __func__);
    
    [MTProjectEditor sharedMTProjectEditor].currentPassage = [[MTProjectEditor sharedMTProjectEditor] createPassageAtXPos:[NSNumber numberWithDouble:location.x] yPos:[NSNumber numberWithDouble:location.y]];
    
    self.needsUpdate = YES;    
}

- (void)scrollWheel:(NSEvent *)event {
    // move the root node to fake scrolling (note: flip the y sign for normal scrolling)
    
    if ( event.deltaX != 0 || event.deltaY != 0) {
        // NSLog(@"%d | %s - deltaX:'%f'", __LINE__, __func__, event.deltaX);
        SKAction * move = [SKAction moveByX:event.deltaX * kScrollingSpeed
                                          y:-event.deltaY * kScrollingSpeed
                                   duration:kScrollingTimeInterval];
        [rootNode runAction:move];
    }
}

- (void)otherMouseDragged:(NSEvent *)theEvent {
    //NSLog(@"%d | %s - ", __LINE__, __func__);
}


#pragma mark - Node Construction

/// grab all passages and make nodes with them and add to scene via rootNode
- (void)applyPassagesToScene {
    //NSLog(@"%d | %s - ", __LINE__, __func__);
    NSArray * passages = [[MTProjectEditor sharedMTProjectEditor].currentProject.passages allObjects];
    [self drawPassages:passages];
    [self drawLinks:passages];
}

- (void)drawPassages:(NSArray *)passages {
    // initial draw check
    if ( passages.count > 0 && ( [[passages[0] xPosition] isEqualToNumber:@0] || [[passages[0] yPosition] isEqualToNumber:@0]) ) {
        if ( ![self smartDraw:passages] ) {
            return;
        }
    }
    
    double nextX = kBaseX;
    double nextY = kBaseY;
    for (MTPassage * passage in passages) {
        SKNode * node = [rootNode childNodeWithName:passage.title]; //TODO: passages could have some kind of unique id so that if the name changes we can still find them via data in nodes, or we could iterate children looking for a node at the position of the passage if one is saved
        
        if ( node == nil ) {
            node = [self buildPassageNode:passage.title body:passage.text];
            NSAssert(node != nil, @"node is nil");
            [rootNode addChild:node];
        }
        
        if ( [passage.xPosition isEqualToNumber:@0] || [passage.yPosition isEqualToNumber:@0] ) {
            node.position = CGPointMake(nextX, nextY);
            nextX += kIncrementX;
            if (nextX > kCapX) {
                nextX = kBaseX;
                nextY += kIncrementY;
            }
            passage.xPosition = [NSNumber numberWithDouble:nextX];
            passage.yPosition = [NSNumber numberWithDouble:nextY];
        } else {
            node.position = CGPointMake(passage.xPosition.doubleValue, passage.yPosition.doubleValue);
        }
    }
}

- (BOOL)smartDraw:(NSArray *)passages {
    BOOL result = NO;
    // find Start passage
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"(title == %@) and (project == %@)", @"Start", [MTProjectEditor sharedMTProjectEditor].currentProject];
    NSArray * foundStart = [[MTCoreDataManager sharedMTCoreDataManager]executeFetchWithPredicate:predicate entity:@"Passage"];
    if (foundStart.count == 1) {
        smartPassages = [NSMutableArray array];
        smartCheckedPassages = [NSMutableSet set];
        MTPassage * start = foundStart[0];
        // build, position & get links
        smartY = 0.1;
        [smartPassages addObjectsFromArray:[self smartBuildAndPosition:start]];
        
        if ( smartPassages.count == 0 ) { // this means start has no outgoing links
            
        }
        else {
            // repeat
            [self smartRepeat:smartPassages];
        }
    }
    
    return result;
}

/*! builds a node if needed, and returns all outgoing links from the passage sent in */
- (NSArray *)smartBuildAndPosition:(MTPassage *)passage {
    if ([rootNode childNodeWithName:passage.title] == nil) {
        // build
        SKNode * node = [self buildPassageNode:passage.title body:passage.text]; NSAssert(node != nil, @"node is nil"); [rootNode addChild:node];
        // position
        node.position = CGPointMake(smartX, [self smartYMake]);
        // save position in passage
        passage.xPosition = [NSNumber numberWithDouble:node.position.x];
        passage.yPosition = [NSNumber numberWithDouble:node.position.y];
    }
    [smartCheckedPassages addObject:passage];
    // return links if any
    return (passage.outgoing.count > 0) ? [passage.outgoing allObjects] : nil;
}

- (double)smartYMake {
    double result = smartY;
    if (smartYFlipper) {
        result *= -1;
    }
    smartY += kIncrementY;
    smartYFlipper = !smartYFlipper;
    return result;
}

- (void)smartRepeat:(NSArray *)passagesToCheck {
    // update smart stuff
    smartX += kIncrementX;
    smartY = kIncrementY;
    smartYFlipper = NO;
    smartLevel++;
    
    smartPassages = [NSMutableArray array];
    // position links
    for (MTPassage * passage in passagesToCheck) {
        if ( ![smartCheckedPassages containsObject:passage] ) {
            [smartPassages addObjectsFromArray:[self smartBuildAndPosition:passage]];
        }
    }
    if (smartPassages.count == 0) { // we are done
        // but iterate passages to ensure they all have a position
        [self drawPassages:[[MTProjectEditor sharedMTProjectEditor].currentProject.passages allObjects]];
        // clear all smart values
        smartLevel = 0;
        smartX = 0;
        smartY = 0;
        smartYFlipper = 0;
        smartPassages = nil;
        smartCheckedPassages = nil;
    }
    else { // we need to repeat
        [self smartRepeat:smartPassages];
    }
}

/*! builds a passage node for the visual editor @returns the built node */

- (SKNode *)buildPassageNode:(NSString *)name body:(NSString *)body {
    SKSpriteNode * sprite = [SKSpriteNode spriteNodeWithColor:[NSColor blackColor] size:CGSizeMake(kSpriteSizeX, kSpriteSizeY)];
    sprite.name = name;
    sprite.zPosition = kSpriteDepth;
    
    SKLabelNode * label = [SKLabelNode labelNodeWithFontNamed:kLabelFont];
    label.name = kLabelName;
    label.zPosition = kLabelDepth;
    label.text = [name substringToIndex:(name.length < kLabelMaxCharacters) ? name.length : kLabelMaxCharacters];
    label.fontColor = [SKColor whiteColor];
    label.fontSize = kLabelFontSize;
    label.position = sprite.position;
    label.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    label.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    
    [sprite addChild:label];
    return sprite;
}

- (void)drawLinks:(NSArray *)passages {
    BOOL useCurves = [[NSUserDefaults standardUserDefaults] boolForKey:kVisualUseCurves];
    
    for (MTPassage * passage in passages) {
        if (passage.outgoing.count == 0) { continue; }
        
        SKNode * startNode = [rootNode childNodeWithName:passage.title];
        if (startNode == nil) { continue; }
        
        for (MTPassage * endNode in passage.outgoing) { // Note all passages should exist with positions saved
            if ( [passage.title isEqualToString:endNode.title] ) { continue; } // ignore links to self
            
            // find or initialize the SKShapeNode
            SKShapeNode * line = (SKShapeNode *)[linkRootNode childNodeWithName:[NSString stringWithFormat:@"%@%@", passage.title, endNode.title]];
            if ( line == nil ) {
                line = [[SKShapeNode alloc] init];
                
                line.lineWidth = kShapeLineWidth;
                line.strokeColor = [SKColor whiteColor];
                
                line.zPosition = kShapeDepth;
                line.name = [NSString stringWithFormat:@"%@%@",passage.title, endNode.title];
                [linkRootNode addChild:line];
            }
            
            //set up end points for links
            CGPoint startPoint = CGPointMake(startNode.position.x + kShapeOutgoingXPosition, startNode.position.y + kShapeOutgoingYPosition);
            CGPoint endPoint = CGPointMake([endNode.xPosition doubleValue] + kShapeIncomingXPosition, [endNode.yPosition doubleValue] + kShapeIncomingYPosition);
            
            // create the path for the SKShapeNode
            CGMutablePathRef path = CGPathCreateMutable();
            CGPathMoveToPoint(path, NULL, startPoint.x, startPoint.y);
            
            if (useCurves) {
                double controlPoint1X = startPoint.x + controlPntDist;
                double controlPoint1Y = startPoint.y;
                
                double controlPoint2X = endPoint.x - controlPntDist;
                double controlPoint2Y = endPoint.y;
                
                /* // debug control points [rootNode addChild:[self debugSpriteNode:CGPointMake(controlPoint1X, controlPoint1Y) color:[NSColor orangeColor]]];
                 [rootNode addChild:[self debugSpriteNode:CGPointMake(controlPoint2X, controlPoint2Y) color:[NSColor redColor]]];*/
                
                CGPathAddCurveToPoint(path,
                                      NULL,
                                      // control 1
                                      controlPoint1X, controlPoint1Y,
                                      // control 2
                                      controlPoint2X, controlPoint2Y,
                                      // endpoint
                                      endPoint.x, endPoint.y
                                      );
            }
            
            else {
                CGPathAddLineToPoint(path, NULL, endPoint.x, endPoint.y);
            }
            
            // create indicators for outgoing / incoming points
            /*
            SKNode * start = [rootNode nodeAtPoint:startPoint];
            if (start != nil && [start.name isEqualToString:kIgnoreName]) {
                NSLog(@"%d | %s - skipping a node", __LINE__, __func__);
            } else {
                [rootNode addChild:[self debugSpriteNode:startPoint color:[NSColor greenColor]]];
            }
            
            SKNode * end = [rootNode nodeAtPoint:endPoint];
            if (end != nil && [end.name isEqualToString:kIgnoreName]) {
                NSLog(@"%d | %s - skipping a node", __LINE__, __func__);
            } else {
                [rootNode addChild:[self debugSpriteNode:endPoint color:[NSColor blueColor]]];
            }
            */
            //[rootNode addChild:[self debugSpriteNode:startPoint color:[NSColor greenColor]]];
            //[rootNode addChild:[self debugSpriteNode:endPoint color:[NSColor blueColor]]];
            
             SKNode * start = [rootNode nodeAtPoint:startPoint];
             if (start == nil || ![start.name isEqualToString:kIgnoreName]) {
                 [rootNode addChild:[self debugSpriteNode:startPoint color:[NSColor greenColor]]];
             }
             
             SKNode * end = [rootNode nodeAtPoint:endPoint];
             if (end == nil || ![end.name isEqualToString:kIgnoreName]) {
                 [rootNode addChild:[self debugSpriteNode:endPoint color:[NSColor blueColor]]];
             }
            
            
            line.path = path;
            CGPathRelease(path);
        }
    }
}

- (SKSpriteNode *)debugSpriteNode:(CGPoint)position color:(NSColor *)color {
    SKSpriteNode * sprite = [SKSpriteNode spriteNodeWithColor:color size:CGSizeMake(5, 5)];
    sprite.position = position;
    sprite.name = kIgnoreName;
    sprite.zPosition = kSpriteDepth;
    return sprite;
}

#pragma mark - Private

/*! attempts to save the position of a node to a Passage @param name - the name of the passage */

- (void)trySaveSelectedNodePosition {
    NSAssert(selectedNode != nil, @"selectedNode is nil");
    NSString * name = selectedNode.name;
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"(title == %@) and (project == %@)", name, [MTProjectEditor sharedMTProjectEditor].currentProject];
    
    NSArray * passages = [[MTCoreDataManager sharedMTCoreDataManager]executeFetchWithPredicate:predicate entity:@"Passage"];
    
    if (passages.count == 1) {
        MTPassage * passage = passages[0];
        passage.xPosition = [NSNumber numberWithDouble:selectedNode.position.x];
        passage.yPosition = [NSNumber numberWithDouble:selectedNode.position.y];
    }
    
    else if (passages.count > 1) {
        for (MTPassage * p in passages) { //NSLog(@"%d | %s - passage:'%@'", __LINE__, __func__, p);
            if (p.isFault) { continue; }
            p.xPosition = [NSNumber numberWithDouble:selectedNode.position.x];
            p.yPosition = [NSNumber numberWithDouble:selectedNode.position.y];
            return;
        }
    }
}


@end
