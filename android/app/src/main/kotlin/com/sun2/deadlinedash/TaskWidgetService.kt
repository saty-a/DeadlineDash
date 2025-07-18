package com.sun2.deadlinedash

import android.content.Intent
import android.widget.RemoteViewsService

class TaskWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return TaskWidgetFactory(applicationContext, intent)
    }
} 