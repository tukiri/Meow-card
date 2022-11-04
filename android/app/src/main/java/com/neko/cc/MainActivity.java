package com.neko.cc;


import android.content.ClipData;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.alibaba.excel.EasyExcel;
import com.alibaba.excel.ExcelReader;
import com.alibaba.excel.context.AnalysisContext;
import com.alibaba.excel.read.listener.ReadListener;
import com.alibaba.excel.read.metadata.ReadSheet;

import org.apache.commons.compress.utils.Lists;
import org.json.JSONException;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.Log;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    EventChannel.EventSink eventSink;

    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {

        GeneratedPluginRegistrant.registerWith(flutterEngine);

        MethodChannel methodChannel = new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), "neko.method.channel");
        methodChannel.setMethodCallHandler((call, result) -> {
            if ("excel.read".equals(call.method)) {
                excelRead(result, call.argument("name"), call.argument("bytes"));
            }
        });

        new EventChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), "neko.event.channel").setStreamHandler(new EventChannel.StreamHandler() {

            @Override
            public void onListen(Object arguments, EventChannel.EventSink events) { //初始化
                eventSink = events;
            }

            @Override
            public void onCancel(Object arguments) {
            }
        });

        Log.i("Android", "android端监听到启动");

        try {
            getIntentData(getIntent(), 3000);
        } catch (JSONException e) {
            Log.e("MainActivity", e.toString());
        }


    }


    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    } //存储消息的逻辑


    protected void onNewIntent(@NonNull Intent intent) {
        super.onNewIntent(intent);
        Log.i("Android", "Android端监听到重载");
        try {
            getIntentData(intent, 100);
        } catch (JSONException e) {
            Log.e("MainActivity", e.toString());
        }
    }

    private void getIntentData(Intent intent, int i) throws JSONException {
        if (intent.getData() != null) {
            intent.addFlags(
                    Intent.FLAG_GRANT_READ_URI_PERMISSION);
            Uri uri = intent.getData();
            String str = uri.getPath();
            byte[] uriBytes = new byte[0];
            try {
                InputStream fis = getContentResolver().openInputStream(uri);
                uriBytes = toByteArray(fis);
            } catch (FileNotFoundException e) {
                Log.e("MainActivity", "File not found.");
            } catch (IOException e) {
                Log.e("MainActivity", "File not read found.");
            }
            List<Object> object = new ArrayList<>();
            object.add(str);
            object.add(uriBytes);
            pushMsgEvent(object, i);
        } else if(intent.getClipData()!=null){
            Uri uri  = intent.getClipData().getItemAt(0).getUri();
            String str = uri.getPath();
            byte[] uriBytes = new byte[0];
            try {
                InputStream fis = getContentResolver().openInputStream(uri);
                uriBytes = toByteArray(fis);
            } catch (FileNotFoundException e) {
                Log.e("MainActivity", "File not found.");
            } catch (IOException e) {
                Log.e("MainActivity", "File not read found.");
            }
            List<Object> object = new ArrayList<>();
            object.add(str);
            object.add(uriBytes);
            pushMsgEvent(object, i);
        }else

        {
            Log.i("Android", "android端未监听到路径");
        }
    }

    public static byte[] toByteArray(InputStream input) throws IOException {
        ByteArrayOutputStream output = new ByteArrayOutputStream();
        byte[] buffer = new byte[4096];
        int n;
        while (-1 != (n = input.read(buffer))) {
            output.write(buffer, 0, n);
        }
        return output.toByteArray();
    }

    //
//
    private void pushMsgEvent(List<Object> content, int i) {
        new Handler().postDelayed(() -> {
            if (eventSink != null) {
                eventSink.success(content);
            }
        }, i);
    }



    private static void excelRead(MethodChannel.Result result, String name, byte[] bytes) {
        Log.i("Excel", "开始读取excel");
        Map<String, List<Map<Integer, String>>> data = new HashMap<>();
        ExcelReader excel = EasyExcel.read(new ByteArrayInputStream(bytes)).build();
        List<ReadSheet> sheets = excel.excelExecutor().sheetList();

        int i;
        for (i = 0; i < sheets.size(); i ++) {
            Log.i("Excel", "读取第"+i+"个sheet");
            ExcelListener cacheListener = new ExcelListener();
            ReadSheet cacheSheet = EasyExcel.readSheet(i).registerReadListener(cacheListener).build();
            excel.read(cacheSheet);
            data.put(sheets.get(i).getSheetName(),cacheListener.getList());
        }
        Log.i("Excel", "全部读取完成！");
        excel.finish();
        result.success(data);
    }

    public static class ExcelListener implements ReadListener<Map<Integer, String>>{
        final List<Map<Integer, String>> cache = Lists.newArrayList();

        @Override
        public void invoke(Map<Integer, String> row, AnalysisContext analysisContext) {
            cache.add(row);
        }

        @Override
        public void doAfterAllAnalysed(AnalysisContext context) {
        }

        public List<Map<Integer, String>> getList() {
            return cache;
        }

    }
}

