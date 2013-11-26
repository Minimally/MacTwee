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
            
            /*
            double startPointX = startNode.position.x + kShapeOutgoingXPosition;
            double startPointY = startNode.position.y;
            
            double endPointX = [endNode.xPosition doubleValue] + kShapeIncomingXPosition;
            double endPointY = [endNode.yPosition doubleValue];
            */
            
            double startPointX = startNode.position.x + kShapeOutgoingXPosition;
            double startPointY = startNode.position.y + kShapeOutgoingYPosition;
            
            double endPointX = [endNode.xPosition doubleValue] + kShapeIncomingXPosition;
            double endPointY = [endNode.yPosition doubleValue] + kShapeIncomingYPosition;
            
            // create the path for the SKShapeNode
            CGMutablePathRef path = CGPathCreateMutable();
            CGPathMoveToPoint(path, NULL, startPointX, startPointY);
            CGPathAddLineToPoint(path, NULL, endPointX, endPointY);
            
            /* // pretty bad attempt at using Bezier Curves between nodes
            double midpointBetweenNodesX = (startPointX + endPointX) / 2;
            double midpointBetweenNodesY = (startPointY + endPointY) / 2;
            
            double distanceBetweenNodesX = sqrt( pow((endPointX - startPointX), 2) + pow((endPointY - endPointY), 2) );
            //double distanceBetweenNodesY = (startPointY + endPointY) / 2;
            
            double controlPoint1X = startPointX + midpointBetweenNodesX / 3;
            double controlPoint1Y = startPointY + midpointBetweenNodesY / 3;
            
            double controlPoint2X = endPointX + midpointBetweenNodesX / 3;
            double controlPoint2Y = endPointY + midpointBetweenNodesY / 3;
            
            [rootNode addChild:[self debugSpriteNode:CGPointMake(controlPoint1X, controlPoint1Y) color:[NSColor orangeColor]]];
            [rootNode addChild:[self debugSpriteNode:CGPointMake(controlPoint2X, controlPoint2Y) color:[NSColor redColor]]];
            
            
            CGPathAddCurveToPoint(path,
                                  NULL,
                                  // control 1
                                  controlPoint1X,
                                  controlPoint1Y,
                                  // control 2
                                  controlPoint2X,
                                  controlPoint2Y,
                                  // endpoint
                                  endPointX,
                                  endPointY
                                  );
             */
            
            //[rootNode addChild:[self debugSpriteNode:CGPointMake(startPointX, startPointY) color:[NSColor blueColor]]];
            [rootNode addChild:[self debugSpriteNode:CGPointMake(endPointX, endPointY) color:[NSColor blueColor]]];
            
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
