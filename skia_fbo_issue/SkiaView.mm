//
//  SkiaView.m
//  skia_fbo_issue
//
//  Created by ghostshi(施啸天) on 9/4/20.
//  Copyright © 2020 ghostshi(施啸天). All rights reserved.
//

#import "SkiaView.h"

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <QuartzCore/CAEAGLLayer.h>

#include "GrDirectContext.h"
#include "GrContextOptions.h"
#include "GrGLInterface.h"
#include "SkSurface.h"
#include "SkCanvas.h"

@interface SkiaView() {
    EAGLContext *context_;
    sk_sp<GrDirectContext> gr_context_;
    sk_sp<SkSurface> offscreen_surface_;
}

@end

@implementation SkiaView

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSkia];
    }
    return self;
}

- (void) initSkia {
    context_ = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:context_];
    
    GrContextOptions options;
    auto context = GrDirectContext::MakeGL(GrGLMakeNativeInterface(), options);
    
    gr_context_ = std::move(context);
    
    const SkImageInfo image_info = SkImageInfo::Make(
        300, 150, kRGBA_8888_SkColorType, kPremul_SkAlphaType, SkColorSpace::MakeSRGB());

    
    offscreen_surface_ = SkSurface::MakeRenderTarget(gr_context_.get(), SkBudgeted::kYes, image_info, 0,
                                                    kBottomLeft_GrSurfaceOrigin,
                                                    nullptr);
}

- (void)reproductIssue {
    [EAGLContext setCurrentContext:context_];
    
    offscreen_surface_->getCanvas()->flush();
    
    GLint prevFbo;
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, &prevFbo);
    
    GLuint framebuffer, colorbuffer;
    
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    
    glGenRenderbuffers(1, &colorbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, colorbuffer);
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorbuffer);
    
    [context_ renderbufferStorage:GL_RENDERBUFFER fromDrawable:((CAEAGLLayer *)(self.layer))];
    
    GLint storage_size_width, storage_size_height;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &storage_size_width);

    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &storage_size_height);
    
//    glBindFramebuffer(GL_FRAMEBUFFER, prevFbo);
    
    offscreen_surface_->getCanvas()->clear(SK_ColorGREEN);
    offscreen_surface_->flush();
    
    [context_ presentRenderbuffer:framebuffer];
}

@end
