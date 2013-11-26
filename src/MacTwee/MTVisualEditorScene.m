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
    BOOL draggingActive;
    SKNode * selectedNode;
    SKNode * rootNode;
    SKNode * linkRootNode;
}

static NSString * const labelString = @"label";


#pragma mark - initialization

- (void)didMoveToView:(SKView *)view {
    if (contentCreated) { return; }
    
    self.backgroundColor = [SKColor grayColor];
    self.scaleMode = SKSceneScaleModeResizeFill;
    
    rootNode = [[SKNode alloc]init];
    [self addChild:rootNode];
    linkRootNode = [[SKNode alloc]init];
    [rootNode addChild:linkRootNode];
    
    [self applyPassagesToScene];
    
    contentCreated = YES;
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
        if ( [[hitNode name] isEqualToString:labelString] ) { // getting the parent if label was clicked
            hitNode = hitNode.parent;
        }
        selectedNode = hitNode;
        
        [[MTProjectEditor sharedMTProjectEditor] selectCurrentPassageWithName:selectedNode.name];
        
        //TODO: grab the delta between mouse pos and node and add that during reposition
        
        draggingActive = YES;
    }
}

- (void)mouseDragged:(NSEvent *)theEvent {
    if (draggingActive) {
        CGPoint location = [theEvent locationInNode:rootNode];
        selectedNode.position = location;
    }
}

- (void)mouseUp:(NSEvent *)theEvent {
    [self saveSelectedNodePosition];
    selectedNode = nil;
    draggingActive = NO;
    self.needsUpdate = YES;
}

- (void)rightMouseDown:(NSEvent *)theEvent {
    [super rightMouseDown:theEvent];
    //NSLog(@"%d | %s - ", __LINE__, __func__);
}

- (void)scrollWheel:(NSEvent *)event {
    // move the root node to fake scrolling (note: flip the y sign for normal scrolling)
    
    if ( event.deltaX != 0) { // NSLog(@"%d | %s - deltaX:'%f'", __LINE__, __func__, event.deltaX);
        SKAction * move = [SKAction moveByX: event.deltaX y: 0 duration: 0.5];
        [rootNode runAction:move];
    }
    
    if ( event.deltaY != 0) { // NSLog(@"%d | %s - deltaY:'%f'", __LINE__, __func__, event.deltaY);
        SKAction * move = [SKAction moveByX: 0 y: -event.deltaY duration: 0.5];
        [rootNode runAction:move];
    }
}

- (void)otherMouseDragged:(NSEvent *)theEvent {
    //NSLog(@"%d | %s - ", __LINE__, __func__);
}


#pragma mark - Node Construction

/// grab all passages and make nodes with them and add to scene
- (void)applyPassagesToScene {
    NSArray * passages = [[MTProjectEditor sharedMTProjectEditor].currentProject.passages allObjects];
    
    // draw passages
    double nextY = 15;
    double nextX = 50;
    for (MTPassage * passage in passages) {
        SKNode * node = [rootNode childNodeWithName:passage.title];
        
        if ( node == nil ) {
            node = [self buildANode:passage.title];
            NSAssert(node != nil, @"node is nil");
            [rootNode addChild:node];
        }
        
        if ([passage.xPosition isEqualToNumber:@0] || [passage.yPosition isEqualToNumber:@0]) {
            node.position = CGPointMake(nextX, nextY);
            nextX += 150;
            if (nextX > 900) {
                nextX = 50;
                nextY += 35;
            }
            passage.xPosition = [NSNumber numberWithDouble:nextX];
            passage.yPosition = [NSNumber numberWithDouble:nextY];
        } else {
            node.position = CGPointMake(passage.xPosition.doubleValue, passage.yPosition.doubleValue);
        }
    }
    
    // draw links
    
    //[linkRootNode removeAllChildren]; // redraw links
    
    for (MTPassage * passage in passages) {
        if (passage.outgoing.count == 0) { continue; }
        
        SKNode * node = [rootNode childNodeWithName:passage.title];
        if (node == nil) { continue; }
        
        for (MTPassage * outgoingPassage in passage.outgoing) {
            if ( [passage.title isEqualToString:outgoingPassage.title] ) { continue; } // ignore links to self
            
            SKShapeNode * line = (SKShapeNode *)[linkRootNode childNodeWithName:[NSString stringWithFormat:@"%@%@", passage.title, outgoingPassage.title]];
            
            if ( line == nil ) {
                line = [[SKShapeNode alloc] init];
                
                line.lineWidth = 1.0;
                line.fillColor = [SKColor whiteColor];
                //line.strokeColor = [SKColor blackColor];
                //line.glowWidth = 0.5;
                
                line.zPosition = 5;
                line.name = [NSString stringWithFormat:@"%@%@",passage.title, outgoingPassage.title];
                [linkRootNode addChild:line];
            }
            
            CGMutablePathRef path = CGPathCreateMutable();
            CGPathMoveToPoint(path, NULL, node.position.x, node.position.y);
            CGPathAddLineToPoint(path, NULL, [outgoingPassage.xPosition doubleValue], [outgoingPassage.yPosition doubleValue]);
            line.path = path;
            CGPathRelease(path);
        }
    }
    
}

- (SKNode *)buildANode:(NSString *)name {
    SKSpriteNode * sprite = [SKSpriteNode spriteNodeWithColor:[NSColor blackColor] size:CGSizeMake(100, 30)];
    
    sprite.name = name;
    sprite.zPosition = 10;
    
    SKLabelNode * label = [SKLabelNode node];
    label.text = name;
    label.fontColor = [SKColor whiteColor];
    label.fontName = @"monaco";
    label.fontSize = 14;
    
    label.name = labelString;
    label.zPosition = 100;
    
    [sprite addChild:label];
    return sprite;
}


#pragma mark - Private

/*! saves position of a moved node to the passage for that node */
- (void)saveSelectedNodePosition {
    NSString * name = selectedNode.name;
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"title == %@", name];
    NSArray * passages = [[MTCoreDataManager sharedMTCoreDataManager]executeFetchWithPredicate:predicate entity:@"Passage"];
    if (passages.count == 1) {
        MTPassage * passage = passages[0];
        // save node positions
        passage.xPosition = [NSNumber numberWithDouble:selectedNode.position.x];
        passage.yPosition = [NSNumber numberWithDouble:selectedNode.position.y];
    }
    else if (passages.count > 1) {
        for (MTPassage * p in passages) {
            //NSLog(@"%d | %s - passage:'%@'", __LINE__, __func__, p);
            if (p.isFault) { continue; }
            // save node positions
            p.xPosition = [NSNumber numberWithDouble:selectedNode.position.x];
            p.yPosition = [NSNumber numberWithDouble:selectedNode.position.y];
            return;
        }
    }
}


@end
