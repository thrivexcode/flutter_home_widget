package com.thrivexcode.flutter_home_widget;

import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.util.Log;
import android.view.View;
import android.widget.RemoteViews;

import com.thrivexcode.flutter_home_widget.R;
import es.antonborri.home_widget.HomeWidgetProvider;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;


/**
 * MyNotesWidgetProvider
 * ---------------------
 * Widget Provider untuk menampilkan 3 catatan terakhir di home screen.
 * Menggunakan HomeWidget library untuk integrasi dengan Flutter.
 *
 * Fitur:
 *  - Menampilkan hingga 3 note dari SharedPreferences.
 *  - Setiap note bisa diklik untuk membuka MainActivity dengan ID note terkait.
 *  - Tombol refresh memperbarui tampilan widget.
 *  - Menampilkan waktu terakhir update.
 *
 * ⚠️ Catatan:
 * Pastikan key di SharedPreferences sesuai dengan Flutter-side HomeWidget (misal note_id_1, note_title_1, dll.)
 */
public class MyNotesWidgetProvider extends HomeWidgetProvider {

    private static final String TAG = "MyNotesWidgetProvider";
    private static final String ACTION_REFRESH = "com.thrivexcode.flutter_home_widget.ACTION_REFRESH";

    /**
     * Dipanggil setiap kali widget perlu diperbarui (misal saat refresh atau update interval).
     */
    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds, SharedPreferences prefs) {
        for (int appWidgetId : appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId, prefs);
        }
    }

    /**
     * Fungsi utama untuk memperbarui tampilan widget berdasarkan data dari SharedPreferences.
     */
    private void updateAppWidget(Context context, AppWidgetManager appWidgetManager, int appWidgetId, SharedPreferences prefs) {
        try {
            
            RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.notes_widget_layout);

            // data dari SharedPreferences
            // 🧠 Ambil data note (ID, title, content)
            String noteId1 = prefs.getString("note_id_1", "");
            String noteTitle1 = prefs.getString("note_title_1", "");
            String noteContent1 = prefs.getString("note_content_1", "");

            String noteId2 = prefs.getString("note_id_2", "");
            String noteTitle2 = prefs.getString("note_title_2", "");
            String noteContent2 = prefs.getString("note_content_2", "");

            String noteId3 = prefs.getString("note_id_3", "");
            String noteTitle3 = prefs.getString("note_title_3", "");
            String noteContent3 = prefs.getString("note_content_3", "");

            // 🔍 Cek apakah semua note kosong
            boolean isAllEmpty = (isEmpty(noteTitle1) && isEmpty(noteContent1)
                    && isEmpty(noteTitle2) && isEmpty(noteContent2)
                    && isEmpty(noteTitle3) && isEmpty(noteContent3));

            if (isAllEmpty) {
                // Jika tidak ada note, sembunyikan kontainer dan footer
                views.setViewVisibility(R.id.notes_container, View.GONE);
                views.setViewVisibility(R.id.widget_footer, View.GONE);
                views.setTextViewText(R.id.widget_header, "No notes yet");
                Log.d(TAG, "⚠️ Tidak ada catatan — tampilkan tampilan kosong.");
            } else {
                // Tampilkan kontainer dan footer jika ada data
                views.setViewVisibility(R.id.notes_container, View.VISIBLE);
                views.setViewVisibility(R.id.widget_footer, View.VISIBLE);

                views.setTextViewText(R.id.widget_header, "Recent Notes");

                // Set teks untuk masing-masing note (title + content)
                setNoteText(views, R.id.note_title_1, R.id.note_content_1, noteTitle1, noteContent1);
                setNoteText(views, R.id.note_title_2, R.id.note_content_2, noteTitle2, noteContent2);
                setNoteText(views, R.id.note_title_3, R.id.note_content_3, noteTitle3, noteContent3);

                // 🔗 Pasang click listener untuk membuka MainActivity sesuai noteId
                setNoteClickIntent(context, views, R.id.note_item_1, noteId1);
                setNoteClickIntent(context, views, R.id.note_item_2, noteId2);
                setNoteClickIntent(context, views, R.id.note_item_3, noteId3);
            }

            // 🔁 Tombol Refresh Widget
            Intent refreshIntent = new Intent(context, MyNotesWidgetProvider.class);
            refreshIntent.setAction(ACTION_REFRESH);
            PendingIntent refreshPendingIntent = PendingIntent.getBroadcast(
                    context,
                    0,
                    refreshIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
            );
            views.setOnClickPendingIntent(R.id.refresh_button, refreshPendingIntent);


            // 🕒 Tambahkan waktu update terakhir di footer
            String time = new SimpleDateFormat("HH:mm", Locale.getDefault()).format(new Date());
            views.setTextViewText(R.id.last_updated, "Updated: " + time);
            Log.d(TAG, "✅ Widget updated at " + time);

            appWidgetManager.updateAppWidget(appWidgetId, views);

        } catch (Exception e) {
            Log.e(TAG, "❌ Error updating widget: " + e.getMessage(), e);
        }
    }

    /**
     * Utilitas: Mengecek apakah string kosong/null.
     */
    private boolean isEmpty(String s) {
        return s == null || s.trim().isEmpty();
    }

    /**
     * Menampilkan atau menyembunyikan note (title + content) berdasarkan datanya.
     */
    private void setNoteText(RemoteViews views, int titleId, int contentId, String title, String content) {
        if (isEmpty(title) && isEmpty(content)) {
            views.setViewVisibility(titleId, View.GONE);
            views.setViewVisibility(contentId, View.GONE);
        } else {
            views.setViewVisibility(titleId, View.VISIBLE);
            views.setViewVisibility(contentId, View.VISIBLE);
            views.setTextViewText(titleId, title);
            views.setTextViewText(contentId, content);
        }
    }
    
    /**
     * Mengatur klik pada item note agar membuka MainActivity dengan membawa noteId.
     * Gunakan hashCode noteId sebagai requestCode agar PendingIntent unik.
     */
    private void setNoteClickIntent(Context context, RemoteViews views, int containerId, String noteId) {
        try {
            Intent intent = new Intent(context, MainActivity.class);
            intent.putExtra("noteId", noteId);

            // Gunakan hashCode() sebagai requestCode yang unik & valid integer
            int requestCode = isEmpty(noteId) ? containerId : noteId.hashCode();

            PendingIntent pendingIntent = PendingIntent.getActivity(
                    context,
                    requestCode,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
            );

            views.setOnClickPendingIntent(containerId, pendingIntent);
            Log.d(TAG, "✅ setNoteClickIntent success for noteId=" + noteId);

        } catch (Exception e) {
            Log.w(TAG, "⚠️ Gagal set click intent untuk noteId=" + noteId + ", fallback digunakan.", e);

            // Fallback aman kalau ada error
            Intent fallbackIntent = new Intent(context, MainActivity.class);
            PendingIntent fallbackPendingIntent = PendingIntent.getActivity(
                    context,
                    containerId,
                    fallbackIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
            );

            views.setOnClickPendingIntent(containerId, fallbackPendingIntent);
        }
    }

    /**
     * Menerima broadcast dari tombol refresh widget.
     * Ketika ditekan, semua instance widget akan diperbarui.
     */
    @Override
    public void onReceive(Context context, Intent intent) {
        super.onReceive(context, intent);

        if (intent != null && ACTION_REFRESH.equals(intent.getAction())) {
            AppWidgetManager appWidgetManager = AppWidgetManager.getInstance(context);
            int[] appWidgetIds = appWidgetManager.getAppWidgetIds(
                    new android.content.ComponentName(context, MyNotesWidgetProvider.class)
            );
            SharedPreferences prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE);
            onUpdate(context, appWidgetManager, appWidgetIds, prefs);
            Log.d(TAG, "🔄 Refresh button clicked — widget updated");
        }
    }

    @Override
    public void onEnabled(Context context) {
        Log.d(TAG, "🟢 Widget enabled");
    }

    @Override
    public void onDisabled(Context context) {
        Log.d(TAG, "🔴 Widget disabled");
    }
}
