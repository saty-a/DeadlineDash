package com.sun2.deadlinedash

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import org.json.JSONArray
import java.util.concurrent.TimeUnit

class TaskWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return TaskRemoteViewsFactory(this.applicationContext, intent)
    }
}

class TaskRemoteViewsFactory(private val context: Context, intent: Intent) : RemoteViewsService.RemoteViewsFactory {
    private val widgetId = intent.getIntExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, AppWidgetManager.INVALID_APPWIDGET_ID)
    private var taskList = JSONArray()

    override fun onCreate() {
        // No-op
    }

    override fun onDataSetChanged() {
        val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        val jsonString = prefs.getString("tasks", "[]")
        taskList = JSONArray(jsonString)
    }

    override fun onDestroy() {
        // No-op
    }

    override fun getCount(): Int {
        return taskList.length()
    }

    override fun getViewAt(position: Int): RemoteViews {
        val task = taskList.getJSONObject(position)
        val name = task.getString("name")
        val deadlineStr = task.getString("deadline")
        // Remove trailing 'Z' if present for parsing (though Instant handles it usually, simple string replace is safer for basic SimpleDateFormat if needed, but here we might manually parse or assume ISO)
        // Actually, let's do a simple calculation if possible, or just show the deadline string for now.
        // Better: Calculate remaining time.
        
        // Parse ISO 8601
        // 2026-01-20T12:00:00.000Z
        val deadlineMillis = try {
            val format = java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", java.util.Locale.US)
            format.timeZone = java.util.TimeZone.getTimeZone("UTC")
            format.parse(deadlineStr)?.time ?: 0L
        } catch (e: Exception) {
            0L
        }

        val now = System.currentTimeMillis()
        val diff = deadlineMillis - now
        
        val views = RemoteViews(context.packageName, R.layout.task_item)
        views.setTextViewText(R.id.widget_item_task_name, name)

        if (diff > 0) {
            val days = TimeUnit.MILLISECONDS.toDays(diff)
            
            if (days > 0) {
                 views.setTextViewText(R.id.widget_item_days, "${days}d")
                 views.setViewVisibility(R.id.widget_item_days, android.view.View.VISIBLE)
            } else {
                 views.setViewVisibility(R.id.widget_item_days, android.view.View.GONE)
            }
            
            val daysMillis = TimeUnit.DAYS.toMillis(days)
            val remainingMillis = diff - daysMillis

            views.setChronometer(R.id.widget_item_chronometer, android.os.SystemClock.elapsedRealtime() + remainingMillis, "%s", true)
            views.setViewVisibility(R.id.widget_item_chronometer, android.view.View.VISIBLE)
        } else {
             // Fallback for overdue (though they should be filtered out)
             views.setViewVisibility(R.id.widget_item_days, android.view.View.GONE)
             views.setViewVisibility(R.id.widget_item_chronometer, android.view.View.GONE)
        }

        return views
    }

    override fun getLoadingView(): RemoteViews? {
        return null
    }

    override fun getViewTypeCount(): Int {
        return 1
    }

    override fun getItemId(position: Int): Long {
        return position.toLong()
    }

    override fun hasStableIds(): Boolean {
        return true
    }
}
