//
//  ExampleViewController.m
//  WTDrawing
//
//  Created by WaterZhang on 11/25/15.
//
//

#import "ExampleViewController.h"
#import "WTDrawingView.h"

@interface ExampleViewController ()

@property (nonatomic, strong) WTDrawingView *drawingView;

@end

@implementation ExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    _drawingView = [[WTDrawingView alloc] initWithFrame:self.view.bounds];
    
    [self.view insertSubview:_drawingView atIndex:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)undo:(id)sender {
    [_drawingView undo];
}

- (IBAction)clear:(id)sender {
    [_drawingView clear];
}

- (IBAction)drawingModeChange:(UISegmentedControl *)seg {
    _drawingView.eraserMode = seg.selectedSegmentIndex == 1;
}

- (IBAction)changeColor:(UIButton *)colorButton {
    _drawingView.strokeColor = colorButton.titleLabel.textColor;
}


@end
