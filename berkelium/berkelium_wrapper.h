#ifndef __BERKELIUM_WRAPPER__
#define __BERKELIUM_WRAPPER__

#include <iostream>
#include "berkelium/Berkelium.hpp"
#include "berkelium/WindowDelegate.hpp"
#include "berkelium/ScriptUtil.hpp"
#include "berkelium/StringUtil.hpp"

using namespace Berkelium;

typedef void (*tp_onAddressBarChanged)(PyObject *obj, Window *win, char *newURL, int newURL_length);
typedef void (*tp_onStartLoading)(PyObject *obj, Window *win, char *newURL, int newURL_length);
typedef void (*tp_onLoad)(PyObject *obj, Window *win);
typedef void (*tp_onCrashedWorker)(PyObject *obj, Window *win);
typedef void (*tp_onCrashedPlugin)(PyObject *obj, Window *win, char *pluginName, int pluginName_length);
typedef void (*tp_onProvisionalLoadError)(PyObject *obj, Window *win, char *url, int url_length, int errorCode, bool isMainFrame);
typedef void (*tp_onConsoleMessage)(PyObject *obj, Window *win, char *message, int message_length, char *sourceId, int sourceId_length, int line_no);
typedef void (*tp_onScriptAlert)(PyObject *obj, Window *win, char *message, int message_length, char *defaultValue, int defaultValue_length, char *url, int url_length, int flags, bool &success, char **value, int *value_length);
typedef void (*tp_onNavigationRequested)(PyObject *obj, Window *win, char *newURL, int newURL_length, char *referrer, int referrer_length, bool isNewWindow, bool &cancelDefaultAction);
typedef void (*tp_onLoadingStateChanged)(PyObject *obj, Window *win, bool isLoading);
typedef void (*tp_onTitleChanged)(PyObject *obj, Window *win, char *title, int title_length);
typedef void (*tp_onTooltipChanged)(PyObject *obj, Window *win, char *text, int text_length);
typedef void (*tp_onCrashed)(PyObject *obj, Window *win);
typedef void (*tp_onUnresponsive)(PyObject *obj, Window *win);
typedef void (*tp_onResponsive)(PyObject *obj, Window *win);
typedef void (*tp_onCreatedWindow)(PyObject *obj, Window *win, Window *newWindow, const Rect &initialRect);
typedef void (*tp_onWidgetCreated)(PyObject *obj, Window *win, Widget *newWidget, int zIndex);
typedef void (*tp_onWidgetResize)(PyObject *obj, Window *win, Widget *wid, int newWidth, int newHeight);
typedef void (*tp_onWidgetMove)(PyObject *obj, Window *win, Widget *wid, int newX, int newY);
typedef void (*tp_onWidgetPaint)(PyObject *obj, Window *wini, Widget *wid, const unsigned char *bitmap_in, const Rect &bitmap_rect, size_t num_copy_rects, const Rect *copy_rects, int dx, int dy, const Rect &scroll_rect);
typedef void (*tp_onWidgetDestroyed)(PyObject *obj, Window *win, Widget *wid);
typedef void (*tp_onPaint)(PyObject *obj, Window *wini, const unsigned char *bitmap_in, const Rect &bitmap_rect, size_t num_copy_rects, const Rect *copy_rects, int dx, int dy, const Rect &scroll_rect);

#if 0
typedef void (*tp_onExternalHost)(PyObject *obj,  Berkelium::Window *win, char *message, int message_length, char *origin, int origin_length, char *target, int target_length);
typedef void (*tp_onShowContextMenu)(PyObject *obj, Window *win, const ContextMenuEventArgs& args);
typedef void (*tp_onJavascriptCallback)(PyObject *obj, Window *win, void* replyMsg, char *url, int url_length, char *funcName, int funcName_length, Script::Variant *args, size_t numArgs);
typedef void (*tp_onRunFileChooser)(PyObject *obj, Window *win, int mode, char *title, int title_length, FileString defaultFile);
#endif

class CyWindowDelegate : public Berkelium::WindowDelegate {
public:
	CyWindowDelegate(PyObject *obj) {
		this->impl_onAddressBarChanged = NULL;
		this->impl_onStartLoading = NULL;
		this->impl_onLoad = NULL;
		this->impl_onCrashedWorker = NULL;
		this->impl_onCrashedPlugin = NULL;
		this->impl_onProvisionalLoadError = NULL;
		this->impl_onConsoleMessage = NULL;
		this->impl_onScriptAlert = NULL;
		this->impl_onNavigationRequested = NULL;
		this->impl_onLoadingStateChanged = NULL;
		this->impl_onTitleChanged = NULL;
		this->impl_onTooltipChanged = NULL;
		this->impl_onCrashed = NULL;
		this->impl_onUnresponsive = NULL;
		this->impl_onResponsive = NULL;
		this->impl_onCreatedWindow = NULL;
		this->impl_onWidgetCreated = NULL;
		this->impl_onWidgetResize = NULL;
		this->impl_onWidgetMove = NULL;
		this->impl_onWidgetPaint = NULL;
		this->impl_onWidgetDestroyed = NULL;
		this->impl_onPaint = NULL;
#if 0
		this->impl_onShowContextMenu = NULL;
		this->impl_onJavascriptCallback = NULL;
		this->impl_onRunFileChooser = NULL;
		this->impl_onExternalHost = NULL;
#endif

		this->obj = obj;
		Py_XINCREF(this->obj);
	}

	~CyWindowDelegate() {
		Py_XDECREF(this->obj);
	}

    void init(unsigned int _w, unsigned int _h, int _usetrans) {
        Berkelium::Context *context = Berkelium::Context::create();
        this->bk_window = Berkelium::Window::create(context);
        delete context;

        this->bk_window->setDelegate(this);
        this->bk_window->resize(_w, _h);
        this->bk_window->setTransparent(_usetrans);
	}

    Berkelium::Window* getWindow() {
        return bk_window;
    }

	// implementations
	tp_onAddressBarChanged		impl_onAddressBarChanged;
	tp_onStartLoading			impl_onStartLoading;
	tp_onLoad					impl_onLoad;
	tp_onCrashedWorker			impl_onCrashedWorker;
	tp_onCrashedPlugin			impl_onCrashedPlugin;
	tp_onProvisionalLoadError	impl_onProvisionalLoadError;
	tp_onConsoleMessage			impl_onConsoleMessage;
	tp_onScriptAlert			impl_onScriptAlert;
	tp_onNavigationRequested	impl_onNavigationRequested;
	tp_onLoadingStateChanged	impl_onLoadingStateChanged;
	tp_onTitleChanged			impl_onTitleChanged;
	tp_onTooltipChanged			impl_onTooltipChanged;
	tp_onCrashed				impl_onCrashed;
	tp_onUnresponsive			impl_onUnresponsive;
	tp_onResponsive				impl_onResponsive;
	tp_onCreatedWindow			impl_onCreatedWindow;
	tp_onWidgetCreated			impl_onWidgetCreated;
	tp_onWidgetResize			impl_onWidgetResize;
	tp_onWidgetMove				impl_onWidgetMove;
	tp_onWidgetPaint			impl_onWidgetPaint;
	tp_onWidgetDestroyed			impl_onWidgetDestroyed;
	tp_onPaint				impl_onPaint;
#if 0
	tp_onShowContextMenu		impl_onShowContextMenu;
	tp_onJavascriptCallback		impl_onJavascriptCallback;
	tp_onRunFileChooser			impl_onRunFileChooser;
	tp_onExternalHost			impl_onExternalHost;
#endif

	void onAddressBarChanged(Window *win, URLString newURL) {
		if ( this->impl_onAddressBarChanged == NULL )
			return;
		this->impl_onAddressBarChanged(this->obj, win,
				(char*)newURL.get<std::string>().c_str(), newURL.length());
	}

	void onStartLoading(Window *win, URLString newURL) {
		if ( this->impl_onStartLoading == NULL )
			return;
		this->impl_onStartLoading(this->obj, win,
				(char *)newURL.get<std::string>().c_str(), newURL.length());
	}

	void onLoad(Window *win) {
		if ( this->impl_onLoad == NULL )
			return;
		this->impl_onLoad(this->obj, win);
	}

	void onCrashedWorker(Window *win) {
		if ( this->impl_onCrashedWorker == NULL )
			return;
		this->impl_onCrashedWorker(this->obj, win);
	}

	void onCrashedPlugin(Window *win, WideString pluginName) {
		if ( this->impl_onCrashedPlugin == NULL )
			return;
		UTF8String utf8 = WideToUTF8(pluginName);
		this->impl_onCrashedPlugin(this->obj, win, (char *)utf8.get<std::string>().c_str(), pluginName.length());
	}

	void onProvisionalLoadError(Window *win, URLString url, int errorCode, bool isMainFrame) {
		if ( this->impl_onProvisionalLoadError == NULL )
			return;
		this->impl_onProvisionalLoadError(this->obj, win,
				(char *)url.get<std::string>().c_str(),
				url.length(), errorCode, isMainFrame);
	}

	void onConsoleMessage(Window *win, WideString message, WideString sourceId, int line_no) {
		if ( this->impl_onConsoleMessage == NULL )
			return;
		UTF8String u1 = WideToUTF8(message);
		UTF8String u2 = WideToUTF8(sourceId);
		this->impl_onConsoleMessage(this->obj, win,
				(char *)u1.get<std::string>().c_str(), message.length(),
				(char *)u2.get<std::string>().c_str(), sourceId.length(), line_no);
	}

	void onScriptAlert(Window *win, WideString message, WideString defaultValue, URLString url, int flags, bool &success, WideString &value) {
		if ( this->impl_onScriptAlert == NULL )
			return;
		UTF8String u1 = WideToUTF8(message);
		UTF8String u2 = WideToUTF8(defaultValue);
		char *retvalue = NULL;
		int retvalue_length = 0;
		this->impl_onScriptAlert(this->obj, win,
				(char *)u1.get<std::string>().c_str(), message.length(),
				(char *)u2.get<std::string>().c_str(), defaultValue.length(),
				(char *)url.get<std::string>().c_str(), url.length(),
				flags, success, &retvalue, &retvalue_length);
		if ( retvalue != NULL && retvalue_length > 0 ) {
			UTF8String u3 = UTF8String().point_to(retvalue, retvalue_length);
			value = UTF8ToWide(u3);
		}
	}

	void onNavigationRequested(Window *win, URLString newURL, URLString referrer, bool isNewWindow, bool &cancelDefaultAction) {
		if ( this->impl_onNavigationRequested == NULL )
			return;
		this->impl_onNavigationRequested(this->obj, win,
			(char *)newURL.get<std::string>().c_str(), newURL.length(),
			(char *)referrer.get<std::string>().c_str(), referrer.length(),
			isNewWindow, cancelDefaultAction);
	}

	void onLoadingStateChanged(Window *win, bool isLoading) {
		if ( this->impl_onLoadingStateChanged == NULL )
			return;
		this->impl_onLoadingStateChanged(this->obj, win, isLoading);
	}

	void onTitleChanged(Window *win, WideString title) {
		if ( this->impl_onTitleChanged == NULL )
			return;
		UTF8String u1 = WideToUTF8(title);
		this->impl_onTitleChanged(this->obj, win, 
				(char *)u1.get<std::string>().c_str(), title.length());
	}

	void onTooltipChanged(Window *win, WideString text) {
		if ( this->impl_onTooltipChanged == NULL )
			return;
		UTF8String u1 = WideToUTF8(text);
		this->impl_onTooltipChanged(this->obj, win,
				(char *)u1.get<std::string>().c_str(), u1.length());
	}

	void onCrashed(Window *win) {
		if ( this->impl_onCrashed == NULL )
			return;
		this->impl_onCrashed(this->obj, win);
	}

	void onUnresponsive(Window *win) {
		if ( this->impl_onUnresponsive == NULL )
			return;
		this->impl_onUnresponsive(this->obj, win);
	}

	void onResponsive(Window *win) {
		if ( this->impl_onResponsive == NULL )
			return;
		this->impl_onResponsive(this->obj, win);
	}

	void onCreatedWindow(Window *win, Window *newWindow, const Rect &initialRect) {
		if ( this->impl_onCreatedWindow == NULL )
			return;
		this->impl_onCreatedWindow(this->obj, win, newWindow, initialRect);
	}

	void onWidgetCreated(Window *win, Widget *newWidget, int zIndex) {
		if ( this->impl_onWidgetCreated == NULL )
			return;
		this->impl_onWidgetCreated(this->obj, win, newWidget, zIndex);
	}

	void onWidgetResize(Window *win, Widget *wid, int newWidth, int newHeight) {
		if ( this->impl_onWidgetResize == NULL )
			return;
		this->impl_onWidgetResize(this->obj, win, wid, newWidth, newHeight);
	}

	void onWidgetMove(Window *win, Widget *wid, int newX, int newY) {
		if ( this->impl_onWidgetMove == NULL )
			return;
		this->impl_onWidgetMove(this->obj, win, wid, newX, newY);
	}
	
	void onWidgetPaint(Window *wini, Widget *wid, const unsigned char *bitmap_in, const Rect &bitmap_rect, size_t num_copy_rects, const Rect *copy_rects, int dx, int dy, const Rect &scroll_rect) {
		if ( this->impl_onWidgetPaint == NULL )
			return;
		this->impl_onWidgetPaint(this->obj, wini, wid, bitmap_in, bitmap_rect, num_copy_rects, copy_rects, dx, dy, scroll_rect);
	}
	
	void onWidgetDestroyed(Window *win, Widget *wid) {
		if (this->impl_onWidgetDestroyed == NULL)
			return;
		this->impl_onWidgetDestroyed(this->obj, win, wid);
	}

	void onPaint(Window *wini, const unsigned char *bitmap_in, const Rect &bitmap_rect, size_t num_copy_rects, const Rect *copy_rects, int dx, int dy, const Rect &scroll_rect) {
		if ( this->impl_onPaint == NULL )
			return;
		this->impl_onPaint(this->obj, wini, bitmap_in, bitmap_rect, num_copy_rects, copy_rects, dx, dy, scroll_rect);
	}

#if 0
	void onExternalHost( Berkelium::Window *win, char *message, int message_length, char *origin, int origin_length, char *target, int target_length) {
		if ( this->impl_onExternalHost == NULL )
			return;
		this->impl_onExternalHost(this->obj, win, message, message_length,
				origin, origin_length, target, target_length);
	}

	void onShowContextMenu(Window *win, const ContextMenuEventArgs& args) {
		if ( this->impl_onShowContextMenu == NULL )
			return;
		this->impl_onShowContextMenu(this->obj, win, args);
	}

	void onJavascriptCallback(Window *win, void* replyMsg, char *url, int url_length, char *funcName, int funcName_length, Script::Variant *args, size_t numArgs) {
		if ( this->impl_onJavascriptCallback == NULL )
			return;
		this->impl_onJavascriptCallback(this->obj, win);
	}

	void onRunFileChooser(Window *win, int mode, char *title, int title_length, FileString defaultFile) {
		if ( this->impl_onRunFileChooser == NULL )
			return;
		this->impl_onRunFileChooser(this->obj, win);
	}
#endif


private:
	// Python representation
	PyObject *obj;
    // The Berkelium window, i.e. our web page
    Berkelium::Window* bk_window;
};

#endif
