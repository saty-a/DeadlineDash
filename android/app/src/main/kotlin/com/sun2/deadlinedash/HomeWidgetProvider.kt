package com.sun2.deadlinedash

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
                val nearestName = widgetData.getString("nearest_task_name", "No Active Tasks")
                val nearestDeadlineStr = widgetData.getString("nearest_task_deadline_str", "0")
                val nearestDeadline = nearestDeadlineStr?.toLongOrNull() ?: 0L

                setTextViewText(R.id.widget_nearest_task, nearestName)
                
                // Bind the ListView to our service
                val intent = android.content.Intent(context, TaskWidgetService::class.java).apply {
                    putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId)
                    android.net.Uri.parse(toUri(android.content.Intent.URI_INTENT_SCHEME))
                }
                setRemoteAdapter(R.id.widget_list_view, intent)
                appWidgetManager.notifyAppWidgetViewDataChanged(widgetId, R.id.widget_list_view)
                
                if (nearestDeadline > 0) {
                    val now = System.currentTimeMillis()
                    val diff = nearestDeadline - now
                    
                    if (diff > 0) {
                        // Calculate days
                        val days = TimeUnit.MILLISECONDS.toDays(diff)
                        
                        // Set Days Text
                        if (days > 0) {
                           setTextViewText(R.id.widget_timer_days, "${days}d")
                           setViewVisibility(R.id.widget_timer_days, View.VISIBLE)
                        } else {
                           setViewVisibility(R.id.widget_timer_days, View.GONE)
                        }

                        // Calculate remaining time for the chronometer to tick
                        // We deduct the milliseconds corresponding to the full days
                        val daysMillis = TimeUnit.DAYS.toMillis(days)
                        val remainingMillis = diff - daysMillis

                        // Set Chronometer base
                        // base = SystemClock.elapsedRealtime() + remainingMillis
                        setChronometer(R.id.widget_chronometer, SystemClock.elapsedRealtime() + remainingMillis, null, true)
                        setViewVisibility(R.id.widget_chronometer, View.VISIBLE)
                         
                    } else {
                        // Expired
                        setTextViewText(R.id.widget_timer_days, "EXPIRED")
                        setViewVisibility(R.id.widget_timer_days, View.VISIBLE)
                        setViewVisibility(R.id.widget_chronometer, View.GONE)
                    }
                } else {
                     setViewVisibility(R.id.widget_timer_days, View.GONE)
                     setViewVisibility(R.id.widget_chronometer, View.GONE)
                }
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
