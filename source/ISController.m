#import "ISController.h"
#import "ISModel.h"

@implementation ISController
@synthesize kbkeys, scribbles, swipe, charAdded;

+(ISController*)sharedInstance{
    static ISController *sharedInstance = nil;
    if(!sharedInstance)sharedInstance = [[ISController alloc] init];
    return sharedInstance;
}

-(id)init{
    self = [super init];
    if(self){
        self.kbkeys = [NSMutableArray array];
    }
    return self;
}

-(void)forwardMethod:(id)sender sel:(SEL)cmd touches:(NSSet *)touches event:(UIEvent *) event{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:touch.view];
    NSString *key = [[[sender keyHitTest:point] displayString] lowercaseString];
    if(cmd == @selector(touchesBegan:withEvent:) )
        [self setupSwipe];
    
    [self.scribbles drawToTouch:touch];
    if( key.length == 1 ){
        bool disp;
        if( !show & (disp=[self.swipe addData:point forKey:key])){
            show = true;
            
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.5];
            self.scribbles.alpha = 1;
            [UIView commitAnimations];
            
        }
        if( disp ){
            [self hideKeys];
        }
    }
    
    if( cmd == @selector(touchesEnded:withEvent:) ){
        [self.swipe end];
        lastShift = NO;
        /*for(ISKey *k in self.swipe.keys){
            NSLog(@"%c %.2f %@", k.letter, k.angle, NSStringFromCGPoint(k.avg));
        }
        */
        if( self.swipe.keys.count >= 2){
            NSArray * arr = [[ISModel sharedInstance] findMatch:self.swipe];
            //NSLog(@"ret:%@", arr);
            
            if( arr.count != 0){
                if( UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad){//self.charAdded ){
                    [self deleteChar];
                    //self.charAdded = NO;
                }
                [self addInput:[arr[0] word]];
                if( arr.count > 1){
                    UIKeyboard *kb = [UIKeyboard activeKeyboard];
                    suggestions = [[ISSuggestionsView alloc] initWithFrame:CGRectMake(0, kb.frame.origin.y-30, kb.frame.size.width, 30) suggestions:arr delegate:self];
                    [kb.superview addSubview:suggestions];
                }
            }else{
                if( [key isEqualToString:@"delete"] && matchLength != -1)
                    [self deleteLast];
                matchLength = -1;
            }
        }else{
            if( [key isEqualToString:@"delete"] && matchLength != -1)
                [self deleteLast];
            matchLength = -1;
        }
        [self cleanSwipe];
    }
    
    /*if(cmd == @selector(touchesBegan:withEvent:) )
        [self addKey:key state:@"DidStart" sender:sender touches:touches];
    else if( cmd == @selector(touchesMoved:withEvent:) )
        [self addKey:key state:@"DidMove" sender:sender touches:touches];
    else if( cmd == @selector(touchesEnded:withEvent:) )
        [self addKey:key state:@"DidEnd" sender:sender touches:touches];*/
}

-(void)setupSwipe{
    self.swipe = [[ISData alloc] init];
    
    [self shouldClose:nil];
    
    show = false;
    
    //load scribble view
    UIKeyboard * kb = [UIKeyboard activeKeyboard];
    CGRect frame = kb.frame;
    if( self.scribbles )
        [self.scribbles removeFromSuperview];
    self.scribbles = [[ISScribbleView alloc] initWithFrame:CGRectMake(0,0,frame.size.width, frame.size.height)];
    self.scribbles.userInteractionEnabled = NO;
    self.scribbles.alpha = 0;
    [kb addSubview:scribbles];
}

-(void)cleanSwipe{
    self.swipe = nil;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self.scribbles];
    self.scribbles.alpha = 0;
    self.scribbles = nil;
    [UIView commitAnimations];
    
    [self performSelector:@selector(showKeys) withObject:nil afterDelay:0.1]; //should keys always stay hidden?
}

-(BOOL) isSwyping{
    return self.swipe != nil;
}

-(void)hideKeys{
    for(UIKBKeyView *k in self.kbkeys)
        if( (k.state & 0x11) != 0 && [[[k key] displayString] length] == 1)
            k.hidden = YES;
}
-(void)showKeys{
    for(UIKBKeyView *k in self.kbkeys)
        if( (k.state & 0x11) != 0 && [[[k key] displayString] length] == 1)
            k.hidden = NO;
}

-(void)shouldClose:(id)sender{
    [suggestions removeFromSuperview];
    suggestions = nil;
}

-(void)deleteChar{
    [[UIKeyboardImpl activeInstance] handleDelete];
}

-(void)deleteLast{
    for(int i = 0; i<matchLength; i++)
        [self deleteChar];
}

-(void)didSelect:(id)sender{
    [self deleteLast];
    [self deleteChar];
    [self addInput:[[sender titleLabel] text]];
    [self shouldClose:nil];
}

-(void)addInput:(NSString *)input{
    UIKeyboardImpl *kb = [UIKeyboardImpl activeInstance];
    
    matchLength = [input length];
    if([kb isShifted]){
        lastShift = YES;
        char c = [input characterAtIndex:0];
        if( c <= 'z' && c >= 'a' ){
            [self kbinput:[NSString stringWithFormat:@"%c", [input characterAtIndex:0]-'a'+'A']];
            if(input.length>1)
                [self kbinput:[input substringFromIndex:1]];
        }else{
            [self kbinput:input];
        }
    }else{
        [self kbinput:input];
        lastShift = NO;
    }
    [self kbinput:@" "];
}
    
-(void)kbinput:(NSString *)input{
    UIKeyboardImpl *kb = [UIKeyboardImpl activeInstance];
    if( [kb respondsToSelector:@selector(addInputString:)])
        [kb addInputString: input];
    else if( [kb respondsToSelector:@selector(handleStringInput:fromVariantKey:)])
        [kb handleStringInput:input fromVariantKey:NO];
}


@end