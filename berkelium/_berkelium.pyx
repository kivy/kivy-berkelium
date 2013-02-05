# Wrapper to berkelium. All the internal work is done inside berkelium, except
# the rendering. He's changed to match our Kivy graphics class, and OpenGL ES
# 2.0 requirement.
#

from libcpp cimport bool
from array import array
from kivy.graphics.opengl import *
from kivy.graphics.fbo import Fbo

cdef extern from "stdlib.h":
    ctypedef unsigned long size_t
    void free(void *ptr)
    void *realloc(void *ptr, size_t size)
    void *malloc(size_t size)

cdef extern from "string.h":
    void *memcpy(void *dest, void *src, size_t n)

cdef extern from "Python.h":
    object PyString_FromStringAndSize(char *s, Py_ssize_t len)

cdef extern from "berkelium/Platform.hpp" namespace "Berkelium":
    ctypedef unsigned int size_t

cdef extern from "berkelium/WeakString.hpp":
    cdef void *berkelium_filestring_empty "Berkelium::FileString::empty"()
    cdef void *berkelium_filestring_point_to "Berkelium::FileString::point_to"(char *, int)

cdef extern from "berkelium/Berkelium.hpp":
    cdef bool berkelium_init "Berkelium::init"(void *, void *, unsigned int, char **)
    cdef void berkelium_destroy "Berkelium::destroy"()
    cdef void berkelium_update "Berkelium::update"()

cdef extern from "berkelium/Context.hpp":
    cdef cppclass Context "Berkelium::Context":
        pass
    cdef Context *Context_create "Berkelium::Context::create"()

cdef extern from "berkelium/StringUtil.hpp":
    cdef cppclass WideString:
        pass
    cdef cppclass UTF8String:
        UTF8String()
        UTF8String point_to(char *, int)
    cdef WideString UTF8ToWide(UTF8String)

cdef extern from "berkelium/Window.hpp":
    ctypedef char* const_wchar_ptr "const wchar_t*"
    ctypedef char* wchar_t "wchar_t*"
    cdef cppclass Window "Berkelium::Window":
        #int is_crashed()
        void ShowRepostFormWarningDialog()
        int getId()
        void focus()
        void unfocus()
        void mouseMoved(int xPos, int yPos)
        void mouseButton(unsigned int buttonID, int down)
        void mouseWheel(int xScroll, int yScroll)
        void textEvent(const_wchar_ptr evt, size_t evtLength)
        void keyEvent(int pressed, int mods, int vk_code, int scancode)
        void adjustZoom(int mode)
        void refresh()
        void stop()
        void cut()
        void copy()
        void paste()
        void undo()
        void redo()
        void selectAll()
        void goBack()
        void goForward()
        void resize(int width, int height)
        void navigateTo(char *url, size_t length)
        bool canGoBack()
        bool canGoForward()
        void setTransparent(bool istrans)
        void executeJavascript(WideString js)

    cdef Window *Window_create "Berkelium::Window::create"(Context *)

cdef extern from "berkelium/Widget.hpp":
    ctypedef object _Rect "Rect"
    cdef cppclass Widget "Berkelium::Widget":
        int getId()
        void focus()
        void unfocus()
        bool hasFocus()
        void mouseMoved(int xPos, int yPos)
        void mouseButton(unsigned int buttonID, bool down)
        void mouseWheel(int xScroll, int yScroll)
        void textEvent(const_wchar_ptr evt, size_t evtLength)
        void keyEvent(bool pressed, int mods, int vk_code, int scancode)
        _Rect getRect()
        void setPos(int x, int y)

cdef extern from "berkelium_wrapper.h":
    cdef cppclass Rect:
        int mLeft
        int mTop
        int mWidth
        int mHeight
        int y()
        int x()
        int top()
        int left()
        int width()
        int height()
        int right()
        int bottom()
        Rect translate(int dx, int dy)
        Rect intersect(Rect &rect)
    ctypedef void (*tp_onAddressBarChanged)(object obj, Window *win, char *newURL, int newURL_length)
    ctypedef void (*tp_onStartLoading)(object obj, Window *win, char *newURL, int newURL_length)
    ctypedef void (*tp_onLoad)(object obj, Window *win)
    ctypedef void (*tp_onCrashedWorker)(object obj, Window *win)
    ctypedef void (*tp_onCrashedPlugin)(object obj, Window *win, char *pluginName, int pluginName_length)
    ctypedef void (*tp_onProvisionalLoadError)(object obj, Window *win, char *url, int url_length, int errorCode, int isMainFrame)
    ctypedef void (*tp_onConsoleMessage)(object obj, Window *win, char *message, int message_length, char *sourceId, int sourceId_length, int line_no)
    ctypedef void (*tp_onScriptAlert)(object obj, Window *win, char *message, int message_length, char *defaultValue, int defaultValue_length, char *url, int url_length, int flags, int &success, char *value, int value_length)
    ctypedef void (*tp_onNavigationRequested)(object obj, Window *win, char *newURL, int newURL_length, char *referrer, int referrer_length, int isNewWindow, int &cancelDefaultAction)
    ctypedef void (*tp_onLoadingStateChanged)(object obj, Window *win, int isLoading)
    ctypedef void (*tp_onTitleChanged)(object obj, Window *win, char *title, int title_length)
    ctypedef void (*tp_onTooltipChanged)(object obj, Window *win, char *text, int text_length)
    ctypedef void (*tp_onCrashed)(object obj, Window *win)
    ctypedef void (*tp_onUnresponsive)(object obj, Window *win)
    ctypedef void (*tp_onResponsive)(object obj, Window *win)
    ctypedef void (*tp_onCreatedWindow)(object obj, Window *win, Window *newWindow, Rect initialRect)
    ctypedef void (*tp_onWidgetCreated)(object obj, Window *win, Widget *newWidget, int zIndex)
    ctypedef void (*tp_onWidgetResize)(object obj, Window *win, Widget *wid, int newWidth, int newHeight)
    ctypedef void (*tp_onWidgetMove)(object obj, Window *win, Widget *wid, int newX, int newY)
    ctypedef void (*tp_onWidgetPaint)(object obj, Window *win, Widget *wid, unsigned char * bitmap_in,  Rect &bitmap_rect, size_t num_copy_rects, Rect *copy_rects, int dx,  int dy,  Rect &scroll_rect)
    ctypedef void (*tp_onWidgetDestroyed)(object obj, Window *win, Widget *wid)
    ctypedef void (*tp_onPaint)(object obj, Window *wini, unsigned char *bitmap_in, Rect &bitmap_rect, size_t num_copy_rects, Rect *copy_rects, int dx, int dy, Rect &scroll_rect)

    cdef cppclass CyWindowDelegate:
        CyWindowDelegate(object obj)
        void init(unsigned int w, unsigned int h, int usetrans)
        Window *getWindow()
        tp_onAddressBarChanged		impl_onAddressBarChanged
        tp_onStartLoading			impl_onStartLoading
        tp_onLoad					impl_onLoad
        tp_onCrashedWorker			impl_onCrashedWorker
        tp_onCrashedPlugin			impl_onCrashedPlugin
        tp_onProvisionalLoadError	impl_onProvisionalLoadError
        tp_onConsoleMessage			impl_onConsoleMessage
        tp_onScriptAlert			impl_onScriptAlert
        tp_onNavigationRequested	impl_onNavigationRequested
        tp_onLoadingStateChanged	impl_onLoadingStateChanged
        tp_onTitleChanged			impl_onTitleChanged
        tp_onTooltipChanged			impl_onTooltipChanged
        tp_onCrashed				impl_onCrashed
        tp_onUnresponsive			impl_onUnresponsive
        tp_onResponsive				impl_onResponsive
        tp_onCreatedWindow			impl_onCreatedWindow
        tp_onWidgetCreated			impl_onWidgetCreated
        tp_onWidgetResize			impl_onWidgetResize
        tp_onWidgetMove				impl_onWidgetMove
        tp_onWidgetPaint			impl_onWidgetPaint
        tp_onWidgetDestroyed			impl_onWidgetDestroyed
        tp_onPaint                  impl_onPaint


def init(bytes berkelium_path):
    berkelium_init(
        berkelium_filestring_point_to(berkelium_path, len(berkelium_path)),
        berkelium_filestring_point_to(berkelium_path, len(berkelium_path)),
        0, NULL)

def destroy():
    berkelium_destroy()

def update():
    berkelium_update()


cdef int _debug = 0
def set_debug(activate):
    global _debug
    _debug = int(activate)

cdef GL_BGRA = 0x80E1
cdef int mapOnPaintToTexture(
    object window_or_widget,
    unsigned char* bitmap_in, Rect& bitmap_rect,
    size_t num_copy_rects, Rect *copy_rects,
    int dx, int dy,
    Rect& scroll_rect,
    object fbo,
    unsigned int dest_texture_width,
    unsigned int dest_texture_height,
    int ignore_partial,
    char* scroll_buffer):

    cdef object tex = fbo.texture
    cdef object tmp

    tex.bind()
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1)

    cdef int kBytesPerPixel = 4
    cdef object py_bytes

    # If we've reloaded the page and need a full update, ignore updates
    # until a full one comes in.  This handles out of date updates due to
    # delays in event processing.
    if ignore_partial:
        if bitmap_rect.left() != 0 or \
            bitmap_rect.top() != 0 or \
            bitmap_rect.right() != dest_texture_width or \
            bitmap_rect.bottom() != dest_texture_height:
            return 0

        py_bytes = PyString_FromStringAndSize(
            <char *>bitmap_in, dest_texture_width * dest_texture_height * kBytesPerPixel)
        glTexImage2D(GL_TEXTURE_2D, 0, kBytesPerPixel, dest_texture_width, dest_texture_height, 0,
            GL_BGRA, GL_UNSIGNED_BYTE, py_bytes)
        return 1

    if window_or_widget == 'widget':
        py_bytes = PyString_FromStringAndSize(<char *>bitmap_in, bitmap_rect.width() * bitmap_rect.height() * kBytesPerPixel)
        glTexSubImage2D(GL_TEXTURE_2D, 0,
                copy_rects[0].left(), copy_rects[0].top(),
                bitmap_rect.width(), bitmap_rect.height(), GL_BGRA, GL_UNSIGNED_BYTE, py_bytes)
        glBindTexture(GL_TEXTURE_2D, 0)
        return 0

    # Now, we first handle scrolling. We need to do this first since it
    # requires shifting existing data, some of which will be overwritten by
    # the regular dirty rect update.
    cdef Rect scrolled_shared_rect, shader_rect
    cdef int wid, hig, inc, jj
    cdef char *outputBuffer, *inputBuffer
    if dx != 0 or dy != 0:
        # scroll_rect contains the Rect we need to move
        # First we figure out where the the data is moved to by translating it
        scrolled_rect = scroll_rect.translate(-dx, -dy)
        # Next we figure out where they intersect, giving the scrolled
        # region
        scrolled_shared_rect = scroll_rect.intersect(scrolled_rect)
        # Only do scrolling if they have non-zero intersection
        if scrolled_shared_rect.width() > 0 and scrolled_shared_rect.height() > 0:
            # And the scroll is performed by moving shared_rect by (dx,dy)
            shared_rect = scrolled_shared_rect.translate(dx, dy)
            wid = scrolled_shared_rect.width()
            hig = scrolled_shared_rect.height()
            inc = 1
            outputBuffer = scroll_buffer
            # source data is offset by 1 line to prevent memcpy aliasing
            # In this case, it can happen if dy==0 and dx!=0.
            inputBuffer = scroll_buffer+(dest_texture_width*1*kBytesPerPixel)
            jj = 0
            if dy > 0:
                # Here, we need to shift the buffer around so that we start in the
                # extra row at the end, and then copy in reverse so that we
                # don't clobber source data before copying it.
                outputBuffer = scroll_buffer+(
                    (scrolled_shared_rect.top()+hig+1)*dest_texture_width
                    - hig*wid)*kBytesPerPixel
                inputBuffer = scroll_buffer
                inc = -1
                jj = hig-1

            # Copy the data out of the texture, using the fbo
            fbo.bind()
            tmp = glReadPixels(0, 0, fbo.size[0], fbo.size[1], GL_RGBA, GL_UNSIGNED_BYTE)
            fbo.release()
            tex.bind()

            # We swap RGBA -> BGRA, since glReadPixels dosn't support BGRA
            a = array('b', tmp)
            a[0::4], a[2::4] = a[2::4], a[0::4]
            tmp = a.tostring()
            inputBuffer = <char *>tmp

            # Annoyingly, OpenGL doesn't provide convenient primitives, so
            # we manually copy out the region to the beginning of the
            # buffer
            while jj < hig and jj >= 0:
                memcpy(
                    outputBuffer + (jj*wid) * kBytesPerPixel,
                    inputBuffer + (
                        (scrolled_shared_rect.top()+jj)*dest_texture_width
                        + scrolled_shared_rect.left()) * kBytesPerPixel,
                    wid*kBytesPerPixel)
                jj += inc

            # And finally, we push it back into the texture in the right
            # location
            py_bytes = PyString_FromStringAndSize(outputBuffer,
                shared_rect.width() * shared_rect.height() * kBytesPerPixel)
            glTexSubImage2D(GL_TEXTURE_2D, 0,
                shared_rect.left(), shared_rect.top(),
                shared_rect.width(), shared_rect.height(),
                GL_BGRA, GL_UNSIGNED_BYTE, py_bytes)

    cdef int i, top, left
    cdef object py_scroll_buffer
    for i in xrange(num_copy_rects):
        wid = copy_rects[i].width()
        hig = copy_rects[i].height()
        top = copy_rects[i].top() - bitmap_rect.top()
        left = copy_rects[i].left() - bitmap_rect.left()
        for jj in xrange(hig):
            memcpy(
                scroll_buffer + jj*wid*kBytesPerPixel,
                bitmap_in + (left + (jj+top)*bitmap_rect.width())*kBytesPerPixel,
                wid*kBytesPerPixel)

        # Finally, we perform the main update, just copying the rect that is
        # marked as dirty but not from scrolled data.
        py_bytes = PyString_FromStringAndSize(scroll_buffer, wid * hig * kBytesPerPixel)
        glTexSubImage2D(GL_TEXTURE_2D, 0,
                        copy_rects[i].left(), copy_rects[i].top(),
                        wid, hig, GL_BGRA, GL_UNSIGNED_BYTE, py_bytes)

    glBindTexture(GL_TEXTURE_2D, 0)

    return 1

cdef class My_Widget:
    cdef Widget *wid
    cdef public int top
    cdef public int left
    cdef public int width
    cdef public int height
    cdef public char *scroll_buffer
    cdef public object fbo

    def __cinit__(self, *largs):
        self.wid = NULL

    def __init__(self, **kwargs):
        pass

    def get_id(self):
        return self.wid.getId()

    def focus(self):
        self.wid.focus()

    def unfocus(self):
        self.wid.unfocus()

    def mouseMoved(self, xPos, yPos):
        self.wid.mouseMoved(xPos, yPos)

    def mouseButton(self, buttonID, down):
        self.wid.mouseButton(buttonID, down)

    def textEvent(self, evt):
        cdef wchar_t *text = <wchar_t *>malloc(sizeof(wchar_t) * len(evt))
        if text == NULL:
            return
        for index, c in enumerate(evt):
            text[index] = <wchar_t><int>int(ord(c))
        self.wid.textEvent(<wchar_t>text, len(evt))


    def keyEvent(self, pressed, mods, vk_code, scancode):
        self.wid.keyEvent(pressed, mods, vk_code, scancode)

    def widgetCreated(self):
        self.fbo = None

    cdef void setWidget(self, Widget *_wid):
        self.wid = _wid

    def widgetResize(self, newWidth, newHeight):
        self.width = newWidth
        self.height = newHeight
        if self.fbo is None:
            self.scroll_buffer = <char *>malloc(newWidth*(newHeight+1)*4)
            self.fbo = Fbo(size=(self.width, self.height), colorfmt='rgba')
            self.fbo.texture.flip_vertical()

    def widgetMove(self, newX, newY):
        self.left = newX
        self.top = newY

    def destroy(self):
        free(self.scroll_buffer)
        self.fbo = None

cdef class WindowDelegate:

    cdef CyWindowDelegate *impl
    cdef int width
    cdef int height
    cdef int needs_full_refresh
    cdef int widget_needs_full_refresh
    cdef char *scroll_buffer
    cdef object fbo

    def __cinit__(self, *largs):
        self.needs_full_refresh = 1
        self.impl = new CyWindowDelegate(self)
        self.impl.impl_onLoad = <tp_onLoad>self.impl_onLoad
        self.impl.impl_onAddressBarChanged = <tp_onAddressBarChanged>self.impl_onAddressBarChanged
        self.impl.impl_onStartLoading = <tp_onStartLoading>self.impl_onStartLoading
        self.impl.impl_onLoad = <tp_onLoad>self.impl_onLoad
        self.impl.impl_onCrashedWorker = <tp_onCrashedWorker>self.impl_onCrashedWorker
        self.impl.impl_onCrashedPlugin = <tp_onCrashedPlugin>self.impl_onCrashedPlugin
        self.impl.impl_onProvisionalLoadError = <tp_onProvisionalLoadError>self.impl_onProvisionalLoadError
        self.impl.impl_onConsoleMessage = <tp_onConsoleMessage>self.impl_onConsoleMessage
        self.impl.impl_onScriptAlert = <tp_onScriptAlert>self.impl_onScriptAlert
        self.impl.impl_onNavigationRequested = <tp_onNavigationRequested>self.impl_onNavigationRequested
        self.impl.impl_onLoadingStateChanged = <tp_onLoadingStateChanged>self.impl_onLoadingStateChanged
        self.impl.impl_onTitleChanged = <tp_onTitleChanged>self.impl_onTitleChanged
        self.impl.impl_onTooltipChanged = <tp_onTooltipChanged>self.impl_onTooltipChanged
        self.impl.impl_onCrashed = <tp_onCrashed>self.impl_onCrashed
        self.impl.impl_onUnresponsive = <tp_onUnresponsive>self.impl_onUnresponsive
        self.impl.impl_onResponsive = <tp_onResponsive>self.impl_onResponsive
        self.impl.impl_onCreatedWindow = <tp_onCreatedWindow>self.impl_onCreatedWindow
        self.impl.impl_onWidgetCreated = <tp_onWidgetCreated>self.impl_onWidgetCreated
        self.impl.impl_onWidgetResize = <tp_onWidgetResize>self.impl_onWidgetResize
        self.impl.impl_onWidgetMove = <tp_onWidgetMove>self.impl_onWidgetMove
        self.impl.impl_onWidgetPaint = <tp_onWidgetPaint>self.impl_onWidgetPaint
        self.impl.impl_onWidgetDestroyed = <tp_onWidgetDestroyed>self.impl_onWidgetDestroyed
        self.impl.impl_onPaint = <tp_onPaint>self.impl_onPaint

    def __init__(self, int width, int height, int usetrans):
        self.scroll_buffer = <char *>malloc(width*(height+1)*4)
        self.width = width
        self.height = height
        self.fbo = Fbo(size=(self.width, self.height), colorfmt='rgba')
        self.fbo.texture.flip_vertical()
        self.impl.init(width, height, usetrans)
        self.my_widgets_list = []

    property modifiers:
        def __get__(self):
            return {
                'shift': 1 << 0,
                'ctrl': 1 << 1,
                'alt': 1 << 2,
                'meta': 1 << 3
            }


    #
    # Default implementation handlers to translate c++ -> Python
    #

    cdef void impl_onAddressBarChanged(self, Window *win, char *newURL,
                                       int newURL_length):
        cdef str py_newURL = PyString_FromStringAndSize(newURL, newURL_length)
        self.onAddressBarChanged(py_newURL)

    cdef void impl_onStartLoading(self, Window *win, char *newURL,
                                  int newURL_length):
        cdef str py_newURL = PyString_FromStringAndSize(newURL, newURL_length)
        self.onStartLoading(py_newURL)

    cdef void impl_onLoad(self, Window *win):
        self.onLoad()

    cdef void impl_onCrashedWorker(self, Window *win):
        self.onCrashedWorker()

    cdef void impl_onCrashedPlugin(self, Window *win, char *pluginName,
                                   int pluginName_length):
        cdef str py_pluginName = PyString_FromStringAndSize(
            pluginName, pluginName_length)
        self.onCrashedPlugin(py_pluginName)

    cdef void impl_onProvisionalLoadError(self, Window *win, char *url,
                                          int url_length, int errorCode,
                                          int isMainFrame):
        cdef str py_url = PyString_FromStringAndSize(url, url_length)
        self.onProvisionalLoadError(py_url, errorCode, isMainFrame)

    cdef void impl_onConsoleMessage(self, Window *win, char *message, int
                                    message_length, char *sourceId, int
                                    sourceId_length, int line_no):
        cdef str py_message = PyString_FromStringAndSize(
            message, message_length)
        cdef str py_sourceId = PyString_FromStringAndSize(
            sourceId, sourceId_length)
        self.onConsoleMessage(py_message, py_sourceId, line_no)

    cdef void impl_onScriptAlert(self, Window *win, char *message, int
                                 message_length, char *defaultValue, int
                                 defaultValue_length, char *url, int url_length,
                                 int flags, int &success, char **value, int
                                 *value_length):
        cdef str py_message = PyString_FromStringAndSize(
            message, message_length)
        cdef str py_defaultValue = PyString_FromStringAndSize(
            defaultValue, defaultValue_length)
        cdef str py_url = PyString_FromStringAndSize(
            url, url_length)
        self.onScriptAlert(py_message, py_defaultValue, py_url, flags, success)

    cdef void impl_onNavigationRequested(self, Window *win, char *newURL, int
                                         newURL_length, char *referrer, int
                                         referrer_length, int isNewWindow, int
                                         &cancelDefaultAction):
        cdef py_url = PyString_FromStringAndSize(newURL, newURL_length)
        cdef py_referrer = PyString_FromStringAndSize(referrer, referrer_length)
        ret = self.onNavigationRequested(py_url, py_referrer, isNewWindow)
        cdef int default_action = int(not ret)
        try:
            #print 'cancel default action', ret
            cancelDefaultAction = default_action
            #print 'cancel default action OK', ret
        except:
            pass

    cdef void impl_onLoadingStateChanged(self, Window *win, int isLoading):
        self.onLoadingStateChanged(isLoading)

    cdef void impl_onTitleChanged(self, Window *win, char *title,
                                  int title_length):
        cdef str py_title = PyString_FromStringAndSize(title, title_length)
        self.onTitleChanged(py_title)

    cdef void impl_onTooltipChanged(self, Window *win, char *text,
                                    int text_length):
        cdef str py_text = PyString_FromStringAndSize(text, text_length)
        self.onTooltipChanged(py_text)

    cdef void impl_onCrashed(self, Window *win):
        self.onCrashed()

    cdef void impl_onUnresponsive(self, Window *win):
        self.onUnresponsive()

    cdef void impl_onResponsive(self, Window *win):
        self.onResponsive()

    cdef void impl_onCreatedWindow(self, Window *win, Window *newWindow,
                                   Rect initialRect):
        self.onCreatedWindow()

    cdef int getMyWidgetPos(self, int _id):
        count = 0
        for myWidget in self.my_widgets_list:
            if myWidget.get_id == _id:
                return count
            count+=1
        return -1

    cdef void impl_onWidgetCreated(self, Window *win, Widget *newWidget,
                                   int zIndex):
        _id = newWidget.getId()
        if win.getId() == _id :
            return
        m = My_Widget()
        m.widgetCreated()
        m.setWidget(newWidget)
        self.my_widgets_list.append(m)
        self.onWidgetCreated(_id)

    cdef void impl_onWidgetDestroyed(self, Window *win, Widget *wid):
        _id = wid.getId()
        if win.getId() == _id:
            return
        self.onWidgetDestroyed(_id)
        pos  = self.getMyWidgetPos(_id)
        m = self.my_widgets_list[pos]
        self.my_widgets_list.pop(pos)
        m.destroy()

    cdef void impl_onWidgetResize(self, Window *win, Widget *wid, int newWidth,
                                  int newHeight):
        _id = wid.getId()
        if win.getId() == _id:
            return
        self.my_widgets_list[self.getMyWidgetPos(_id)].widgetResize(newWidth, newHeight)
        self.widget_needs_full_refresh = 1
        self.onWidgetResize(_id, (newWidth, newHeight))

    cdef void impl_onWidgetMove(self, Window *win, Widget *wid, int newX,
                                int newY):
        _id = wid.getId()
        if win.getId() == _id:
            return
        self.my_widgets_list[self.getMyWidgetPos(_id)].widgetMove(newX, newY)
        self.onWidgetMove(_id, (newX, newY))

    cdef void impl_onWidgetPaint (self, Window *wini, Widget *wid, unsigned char *bitmap_in, Rect
                           &bitmap_rect, size_t num_copy_rects, Rect
                           *copy_rects, int dx, int dy, Rect &scroll_rect):
        _id = wid.getId()
        if wini.getId() == _id:
            return
        cdef Rect _bitmap_rect = bitmap_rect
        cdef Rect _scroll_rect = scroll_rect
        my_widget = self.my_widgets_list[self.getMyWidgetPos(_id)]
        cdef int updated = mapOnPaintToTexture(
            'widget', bitmap_in, _bitmap_rect, num_copy_rects, copy_rects,
            dx, dy, _scroll_rect,
            my_widget.fbo, my_widget.width, my_widget.height,
            self.widget_needs_full_refresh, my_widget.scroll_buffer)
        if updated:
            self.widget_needs_full_refresh = 0
        self.onWidgetPaint(_id, my_widget.fbo.texture)

    cdef void impl_onPaint(self, Window *wini, unsigned char *bitmap_in, Rect
                           &bitmap_rect, size_t num_copy_rects, Rect
                           *copy_rects, int dx, int dy, Rect &scroll_rect):
        cdef Rect _bitmap_rect = bitmap_rect
        cdef Rect _scroll_rect = scroll_rect
        cdef int updated = mapOnPaintToTexture(
            'wini', bitmap_in, _bitmap_rect, num_copy_rects, copy_rects,
            dx, dy, _scroll_rect,
            self.fbo, self.width, self.height, self.needs_full_refresh, self.scroll_buffer)
        if updated:
            self.needs_full_refresh = 0
        self.onPaint()

    #
    # Default Python handlers
    # XXX This could be removed, since they are all already defined in the
    # Python part
    #

    def onAddressBarChanged(self, newURL):
        pass

    def onStartLoading(self, newURL):
        pass

    def onLoad(self):
        pass

    def onCrashedWorker(self):
        pass

    def onCrashedPlugin(self, pluginName):
        pass

    def onProvisionalLoadError(self, url, errorCode, isMain):
        pass

    def onConsoleMessage(self, message, sourceId, line_no):
        pass

    def onScriptAlert(self, message, defaultValue, url, flags, success):
        pass

    def onNavigationRequested(self, newURL, referrer, isNewWindow):
        pass

    def onLoadingStateChanged(self, isLoading):
        pass

    def onTitleChanged(self, title):
        pass

    def onTooltipChanged(self, text):
        pass

    def onCrashed(self):
        pass

    def onUnresponsive(self):
        pass

    def onResponsive(self):
        pass

    def onCreatedWindow(self):
        pass

    def onWidgetCreated(self):
        pass

    def onWidgetResize(self):
        pass

    def onWidgetMove(self):
        pass

    def onPaint(self):
        pass

    #
    # Public methods
    #

    def navigateTo(self, bytes url):
        self.impl.getWindow().navigateTo(url, len(url))

    def resize(self, int width, int height):
        cdef char *tmp = <char *>realloc(self.scroll_buffer, width*(height+1)*4)
        if tmp == NULL:
            raise MemoryError('Unable to resize scroll_buffer')
        self.impl.getWindow().resize(width, height)
        self.scroll_buffer = tmp
        self.width = width
        self.height = height
        self.needs_full_refresh = 1
        self.fbo.size = width, height
        self.fbo.texture.flip_vertical()

    def focus(self):
        self.impl.getWindow().focus()

    def unfocus(self):
        self.impl.getWindow().unfocus()

    def widget_focus(self, _id):
        self.my_widgets_list[self.getMyWidgetPos(_id)].focus()

    def widget_unfocus(self, _id):
        self.my_widgets_list[self.getMyWidgetPos(_id)].unfocus()

    def mouseMoved(self, int xPos, int yPos):
        self.impl.getWindow().mouseMoved(xPos, yPos)

    def widget_mouseMoved(self, _id, int xPos, int yPos):
        self.my_widgets_list[self.getMyWidgetPos(_id)].mouseMoved(xPos, yPos)

    def mouseButton(self, unsigned int buttonID, int down):
        self.impl.getWindow().mouseButton(buttonID, down)

    def widget_mouseButton(self, _id, unsigned int buttonID, int down):
        self.my_widgets_list[self.getMyWidgetPos(_id)].mouseButton(buttonID, down)

    def mouseWheel(self, int xScroll, int yScroll):
        self.impl.getWindow().mouseWheel(xScroll, yScroll)

    def textEvent(self, evt):
        cdef wchar_t *text = <wchar_t *>malloc(sizeof(wchar_t) * len(evt))
        if text == NULL:
            return
        for index, c in enumerate(evt):
            text[index] = <wchar_t><int>int(ord(c))
        self.impl.getWindow().textEvent(<const_wchar_ptr>text, len(evt))

    def widget_textEvent(self, _id, evt):
        self.my_widgets_list[self.getMyWidgetPos(_id)].textEvent( evt)

    def keyEvent(self, int pressed, int mods, int vk_code, int scancode):
        self.impl.getWindow().keyEvent(pressed, mods, vk_code, scancode)

    def widget_keyEvent(self, _id, int pressed, int mods, int vk_code, int scancode):
        self.my_widgets_list[self.getMyWidgetPos(_id)].keyEvent(pressed, mods, vk_code, scancode)

    def adjustZoom(self, int mode):
        self.impl.getWindow().adjustZoom(mode)

    def refresh(self):
        self.impl.getWindow().refresh()

    def stop(self):
        self.impl.getWindow().stop()

    def cut(self):
        self.impl.getWindow().cut()

    def copy(self):
        self.impl.getWindow().copy()

    def paste(self):
        self.impl.getWindow().paste()

    def undo(self):
        self.impl.getWindow().undo()

    def redo(self):
        self.impl.getWindow().redo()

    def selectAll(self):
        self.impl.getWindow().selectAll()

    def goBack(self):
        self.impl.getWindow().goBack()

    def goForward(self):
        self.impl.getWindow().goForward()

    def canGoBack(self):
        return self.impl.getWindow().canGoBack()

    def canGoForward(self):
        return self.impl.getWindow().canGoForward()

    def setTransparent(self, bool is_trans):
        self.impl.getWindow().setTransparent(is_trans)

    def executeJavascript(self, js):
        cdef char *c_js = <bytes>js
        cdef UTF8String u1 = UTF8String().point_to(c_js, len(js))
        cdef WideString w1 = UTF8ToWide(u1)
        self.impl.getWindow().executeJavascript(w1)

    property texture:
        def __get__(self):
            return self.fbo.texture

