package com.sun2.chessclock

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
        val jsonString = prefs.getString("tasks", "[]") ?: "[]"
        val allTasks = JSONArray(jsonString)
        
        // Local filtering similar to iOS to handle auto-removal on expiration
        val now = System.currentTimeMillis()
        val filtered = JSONArray()
        
        val format = java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", java.util.Locale.US)
        format.timeZone = java.util.TimeZone.getTimeZone("UTC")

        for (i in 0 until allTasks.length()) {
            val task = allTasks.getJSONObject(i)
            if (task.optBoolean("isCompleted", false)) continue
            
            val deadlineStr = task.getString("deadline")
            val deadlineMillis = try {
                format.parse(deadlineStr)?.time ?: 0L
            } catch (e: Exception) {
                0L
            }
            
            if (deadlineMillis > now) {
                filtered.put(task)
            }
        }
        taskList = filtered
    }

    override fun onDestroy() {
        // No-op
    }

    override fun getCount(): Int {
        return taskList.length()
    }

    override fun getViewAt(position: Int): RemoteViews {
        // Double check bounds to avoid crash
        if (position >= taskList.length()) return RemoteViews(context.packageName, R.layout.task_item)
        
        val task = taskList.getJSONObject(position)
        val name = task.getString("name")
        val deadlineStr = task.getString("deadline")
        
        val format = java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", java.util.Locale.US)
        format.timeZone = java.util.TimeZone.getTimeZone("UTC")
        
        val deadlineMillis = try {
            format.parse(deadlineStr)?.time ?: 0L
        } catch (e: Exception) {
            0L
        }

        val now = System.currentTimeMillis()
        val diff = deadlineMillis - now
        
        val views = RemoteViews(context.packageName, R.layout.task_item)
        views.setTextViewText(R.id.widget_item_task_name, name)

        // Same approach as iOS: check if the deadline hasn't passed yet
        if (diff > 0) {
            val totalSeconds = diff / 1000
            val days = totalSeconds / 86400
            val hours = (totalSeconds % 86400) / 3600
            val remainingSecondsInHour = totalSeconds % 3600

            // Days
            if (days > 0) {
                views.setTextViewText(R.id.widget_item_days, "${days}d:")
                views.setViewVisibility(R.id.widget_item_days, android.view.View.VISIBLE)
            } else {
                views.setViewVisibility(R.id.widget_item_days, android.view.View.GONE)
            }
            
            // Hours
            views.setTextViewText(R.id.widget_item_hours, String.format("%02dh:", hours))
            views.setViewVisibility(R.id.widget_item_hours, android.view.View.VISIBLE)
            
            // Chronometer for Minutes and Seconds
            views.setChronometer(R.id.widget_item_chronometer, android.os.SystemClock.elapsedRealtime() + (remainingSecondsInHour * 1000), "%s", true)
            views.setViewVisibility(R.id.widget_item_chronometer, android.view.View.VISIBLE)
            
            // Set color to orange (active)
            views.setTextColor(R.id.widget_item_hours, 0xFFFF9800.toInt())
            views.setTextColor(R.id.widget_item_chronometer, 0xFFFF9800.toInt())
        } else {
            // Expired state: Hide everything and show "Expired" (Red)
            views.setViewVisibility(R.id.widget_item_days, android.view.View.GONE)
            views.setTextViewText(R.id.widget_item_hours, "Expired")
            views.setViewVisibility(R.id.widget_item_hours, android.view.View.VISIBLE)
            views.setViewVisibility(R.id.widget_item_chronometer, android.view.View.GONE)
            views.setTextColor(R.id.widget_item_hours, 0xFFF44336.toInt())
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
