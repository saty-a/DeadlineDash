package com.sun2.chessclock

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.os.SystemClock
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import java.util.concurrent.TimeUnit

class HomeWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                val intent = android.content.Intent(context, TaskWidgetService::class.java).apply {
                    putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId)
                    android.net.Uri.parse(toUri(android.content.Intent.URI_INTENT_SCHEME))
                }
                setRemoteAdapter(R.id.widget_list_view, intent)
                appWidgetManager.notifyAppWidgetViewDataChanged(widgetId, R.id.widget_list_view)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
        scheduleNextUpdate(context, widgetData)
    }

    private fun scheduleNextUpdate(context: Context, widgetData: SharedPreferences) {
        val tasksJson = widgetData.getString("tasks", "[]") ?: "[]"
        val allTasks = org.json.JSONArray(tasksJson)
        val now = System.currentTimeMillis()
        var nextExpiry = Long.MAX_VALUE

        val format = java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", java.util.Locale.US)
        format.timeZone = java.util.TimeZone.getTimeZone("UTC")

        for (i in 0 until allTasks.length()) {
            val task = allTasks.getJSONObject(i)
            if (task.optBoolean("isCompleted", false)) continue
            
            val deadlineStr = task.getString("deadline")
            val deadlineMillis = try { format.parse(deadlineStr)?.time ?: 0L } catch (e: Exception) { 0L }
            
            if (deadlineMillis > now && deadlineMillis < nextExpiry) {
                nextExpiry = deadlineMillis
            }
        }

        if (nextExpiry != Long.MAX_VALUE) {
            val intent = android.content.Intent(context, HomeWidgetProvider::class.java).apply {
                action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                val ids = AppWidgetManager.getInstance(context).getAppWidgetIds(
                    android.content.ComponentName(context, HomeWidgetProvider::class.java)
                )
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
                addFlags(android.content.Intent.FLAG_RECEIVER_FOREGROUND)
            }
            
            val pendingIntent = android.app.PendingIntent.getBroadcast(
                context, 0, intent,
                android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE
            )
            
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as android.app.AlarmManager
            // Use standard alarm that doesn't require SCHEDULE_EXACT_ALARM permission.
            // Systems will batch this, so it might be slightly delayed after the actual expiry.
            alarmManager.setAndAllowWhileIdle(
                android.app.AlarmManager.RTC_WAKEUP,
                nextExpiry,
                pendingIntent
            )
        }
    }
}
