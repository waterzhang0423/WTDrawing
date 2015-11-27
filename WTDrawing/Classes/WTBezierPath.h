//
//  WTBezierPath.h
//
//  Created by Water Zhang on 11/24/15
//

#import <UIKit/UIKit.h>

/**
 *  Extend UIBezierPath for store some extra properties.
 */
@interface WTBezierPath : UIBezierPath

/**
 *  Path stroke color, each path can have it's own stroke color.
 */
@property (nonatomic, strong) UIColor *color;

/**
 *  Set this to kCGBlendModeClear when drawing eraser.
 */
@property (nonatomic, assign) CGBlendMode blendMode;

@end
