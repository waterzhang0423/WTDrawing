//
//  WTDrawingView.h
//
//  Created by Water Zhang on 11/24/15
//


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface WTDrawingView : UIView

@property (nonatomic, strong) UIColor *strokeColor;

@property (nonatomic, assign) CGFloat strokeWidth;

@property (nonatomic, assign) CGFloat eraserWidth;

@property (nonatomic, assign) BOOL eraserMode;

/**
 *  Capture a snapshot.
 */
- (UIImage *) snapshot;

/**
 *  Clear drawings.
 */
- (void) clear;

/**
 *  Undo last path.
 */
- (void) undo;

@end
