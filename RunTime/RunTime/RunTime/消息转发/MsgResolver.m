//
//  MsgResolver.m
//  RunTime
//
//  Created by qinxuliang on 2022/9/26.
//

#import "MsgResolver.h"
#import <objc/runtime.h>


@interface ForwardingTarget : NSObject

@end

@implementation ForwardingTarget



@end

@implementation MsgResolver


///第一次可以处理
+ (BOOL)resolveInstanceMethod:(SEL)sel{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if (sel == @selector(callInstanceMethod:)){
       // class_addMethod([self class],sel,(IMP)callTestImp,@"v@:@");
        
        IMP insteadIMP = class_getMethodImplementation(self, @selector(callInstanceMethod:));
        Method insteadMethod = class_getInstanceMethod(self, @selector(callInstanceMethod:));
        const char *instead = method_getTypeEncoding(insteadMethod);
        return class_addMethod(self, sel, insteadIMP, instead);

#pragma clang diagnostic pop
        return true;
    }
    
    return [super resolveInstanceMethod:sel];
}

+ (BOOL)resolveClassMethod:(SEL)sel{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if (sel == @selector(callClassMethod:)){
//        class_addMethod(objc_getMetaClass("MsgResolver") ,sel,(IMP)callClassMethodImp,@"v@:@");
        IMP insteadIMP = class_getMethodImplementation(self, @selector(callClassMethod:));
        Method insteadMethod = class_getClassMethod(self.class, @selector(callClassMethod:));
        const char *instead = method_getTypeEncoding(insteadMethod);
        return class_addMethod(objc_getMetaClass("MsgResolver"), sel, insteadIMP, instead);
#pragma clang diagnostic pop
        return true;
    }
    return [super resolveClassMethod:sel];
}

- (void)callInstanceMethod:(NSString*)msg{
    
    NSLog(@"%@", msg);
}

+ (void)callClassMethod:(NSString*)msg{
    
    NSLog(@"%@", msg);
}

void callInstanceMethodImp(id self, SEL _cmd, NSString*msg){
    
    NSLog(@"%@", msg);
}

void callClassMethodImp(id self, SEL _cmd, NSString*msg){
    
    NSLog(@"%@", msg);
}

///第二次可以处理
///
-(id)forwardingTargetForSelector:(SEL)aSelector{
    NSLog(@"%s -- %@",__func__,NSStringFromSelector(aSelector));
       
    if (aSelector == @selector(doInstanceNoImplementation)) {
        return [[ForwardingTarget alloc] init];
        
    }

    return [super forwardingTargetForSelector:aSelector];
}

@end


