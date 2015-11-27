//
//  WTDrawingView.m
//
//  Created by Water Zhang on 11/24/15
//

#import "WTDrawingView.h"
#import <QuartzCore/QuartzCore.h>
#import "WTBezierPath.h"

#define kDefaultStrokeColor [UIColor blackColor]
#define kDefaultStrokeAlpha 1.0f
#define kDefaultStrokeWidth 2.0f
#define kDefaultEraserWidth 20.f

typedef enum : NSUInteger {
    DRAW   = 1,
    CLEAR  = 2,
    UNDO   = 4,
    ERASER = 8
} DrawingMode;

@implementation WTDrawingView {
    UIImage *_bitmap;
    
    CGPoint _points[5];
    
    NSInteger _ctr;
    
    NSInteger _movedPointCount;
    
    NSMutableArray *_pathArray;
    
    WTBezierPath *_path;
    
    DrawingMode _drawingMode;
    
    CGFloat _screenScale;
}

#pragma mark - public methods

- (UIImage *) snapshot {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, _screenScale);
    
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

- (void) clear {
    _drawingMode = CLEAR;
    _path = nil;
    _bitmap = nil;
    [self setNeedsDisplay];
}

- (void) undo {
    _drawingMode = UNDO;
    [self setNeedsDisplay];
}

#pragma mark -

- (void) dealloc {
    [_pathArray removeAllObjects];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        _pathArray = [NSMutableArray new];
        _ctr = 0;
        _movedPointCount = 0;
        
        _strokeWidth = kDefaultStrokeWidth;
        _strokeColor = kDefaultStrokeColor;
        _eraserWidth = kDefaultEraserWidth;
        _eraserMode = NO;
        _drawingMode = DRAW;
        _screenScale = [UIScreen mainScreen].scale;
        
        self.multipleTouchEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    if (_drawingMode == DRAW || _drawingMode == ERASER) {
        
        [_strokeColor setStroke];
        [_bitmap drawInRect:rect];
        
        [_path strokeWithBlendMode:_path.blendMode alpha:kDefaultStrokeAlpha];
        
    }
    else if (_drawingMode == CLEAR) {
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextClearRect(context, rect);
        
        [_pathArray removeAllObjects];
        _ctr = 0;
        
    }
    else if (_drawingMode == UNDO) {
        
        if(_pathArray.count > 0){
            
            [_pathArray removeLastObject];
            
            for (WTBezierPath *path in _pathArray) {
                [path.color setStroke];
                [path strokeWithBlendMode:path.blendMode alpha:kDefaultStrokeAlpha];
            }
            
            UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, _screenScale);
            
            [self.layer renderInContext:UIGraphicsGetCurrentContext()];
            _bitmap = UIGraphicsGetImageFromCurrentImageContext();
            
            UIGraphicsEndImageContext();
            
            [_bitmap drawAtPoint:CGPointZero];
        }
        
    }
    [super drawRect:rect];
}

#pragma mark - Handle touches event

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_drawingMode != DRAW && _drawingMode != ERASER) {
        _drawingMode = DRAW;
    }
    
    UITouch *touch = [touches anyObject];
    
    _ctr = 0;
    _points[_ctr] = [touch locationInView:self];
    _movedPointCount = 0;
    
    _path = [[WTBezierPath alloc] init];
    _path.lineCapStyle = kCGLineCapRound;
    _path.lineJoinStyle = kCGLineJoinRound;
    _path.color = _strokeColor;
    _path.blendMode = _eraserMode ? kCGBlendModeClear : kCGBlendModeNormal;
    [_path setLineWidth:_eraserMode ? _eraserWidth : _strokeWidth];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch  = [touches anyObject];
    
    _movedPointCount ++;
    _ctr ++;
    _points[_ctr] = [touch locationInView:self];
    
    // We got 5 points here, now we can draw a bezier path,
    // use 4 points to draw a bezier,and the last point is cached for next segment.
    if (_ctr == 4) {
        
        _points[3] = CGPointMake((_points[2].x + _points[4].x) * 0.5, (_points[2].y + _points[4].y) * 0.5);
        
        [_path moveToPoint:_points[0]];
        [_path addCurveToPoint:_points[3] controlPoint1:_points[1] controlPoint2:_points[2]];
        
        [self setNeedsDisplay];
        
        _points[0] = _points[3];
        _points[1] = _points[3]; // this is the "magic"
        _points[2] = _points[4];
        _ctr = 2;
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // Handle if there are no enough points to draw a bezier,
    // draw a circle instead.
    if (_movedPointCount < 4) {
        CGFloat startAngle = - ((float)M_PI / 2); // 90 degrees
        CGFloat endAngle = (360 * 2 * (float)M_PI) + startAngle;
        
        CGFloat radius = _eraserMode ? _eraserWidth / 2.0 : _strokeWidth / 2.0;
        [_path addArcWithCenter:_points[0] radius:radius startAngle:startAngle endAngle:endAngle clockwise:0];
    }
    
    [_pathArray addObject:_path];
    
    [self drawBitmap];
    [self setNeedsDisplay];
}

#pragma mark - Private functions

- (void)drawBitmap {
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, _screenScale);
    
    [_path.color setStroke];
    
    [_bitmap drawAtPoint:CGPointZero];
    
    [_path strokeWithBlendMode:_path.blendMode alpha:kDefaultStrokeAlpha];
    
    _bitmap = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
}

@end


