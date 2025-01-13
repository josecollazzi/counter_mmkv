package com.josecollazzi.counter_mmkv

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.util.Log
import android.widget.RemoteViews
import com.ctrip.flight.mmkv.initialize
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import com.tencent.mmkv.MMKV
import android.net.Uri
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetBackgroundService


/**
 * Implementation of App Widget functionality.
 */
class CounterAppWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {

        initializeMMKV(context)
        // There may be multiple widgets active, so update all of them
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onEnabled(context: Context) {
        // Enter relevant functionality for when the first widget is created
    }

    override fun onDisabled(context: Context) {
        // Enter relevant functionality for when the last widget is disabled
    }

    private fun initializeMMKV(context: Context) {
        val rootDir = initialize(context)
        Log.d("MMKV Path", rootDir)
    }
}

internal fun parseInteractionJson(json: String): List<CounterInteraction> {
    return try {
        val type = object : TypeToken<List<CounterInteraction>>() {}.type
        Gson().fromJson(json, type) ?: emptyList()
    } catch (e: Exception) {
        emptyList() // Return an empty list if parsing fails
    }
}

internal fun updateAppWidget(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetId: Int
) {
    val mmkv = MMKV.defaultMMKV()
    var listJson = mmkv.getString("counter_interactions", "[]");
    if (listJson == null) {
        listJson = "[]";
    }
    val listInteraction = parseInteractionJson(listJson);
    val lastCounterInteraction = if (listInteraction.isEmpty()) {
        CounterInteraction(0, "", "")
    } else {
        listInteraction.last()
    }

    // Construct the RemoteViews object
    val views = RemoteViews(context.packageName, R.layout.counter_app_widget)

    views.setTextViewText(R.id.counterValue, lastCounterInteraction.counterValue.toString())
    views.setTextViewText(R.id.interactionButtonLocation, "interaction Button Location: " + lastCounterInteraction.interactionButtonLocation)
    views.setTextViewText(R.id.persistedLogicLocation, "Persisted Logic Location: " + lastCounterInteraction.persistedLogicLocation)

    val pendingIntent = HomeWidgetBackgroundIntent.getBroadcast(
        context,
        Uri.parse("myapp://increment_counter")
    )

    views.setOnClickPendingIntent(R.id.button, pendingIntent)

    // Instruct the widget manager to update the widget
    appWidgetManager.updateAppWidget(appWidgetId, views)
}


