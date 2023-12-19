package com.example.example_java_kline.task;

import java.util.ArrayList;
import java.util.List;

import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;

import com.example.example_java_kline.example.ExampleDayData;
import com.example.example_java_kline.vo.ResponseResult;
import com.example.example_java_kline.websocket.WebSocketTest;

/**
 * 日K数据
 */
@Configuration
@EnableScheduling
@EnableAsync
public class DayScheduleTask {

    int singleIndex = 0;

    @Scheduled(fixedRate = 2000)
    private void candlestickSingleTask() {
        if (singleIndex >= ExampleDayData.datatList.size()) {
            singleIndex = 0;
        }
        List<String> candlestickDataList = ExampleDayData.datatList.get(singleIndex);
        List<List<String>> dataList = new ArrayList<>();
        dataList.add(candlestickDataList);
        ResponseResult<List<List<String>>> responseResult = ResponseResult.success("candlestickSingle", dataList);
        System.out.println("日K数据 - 单：" + dataList);
        WebSocketTest.sendMessage(responseResult);
        singleIndex += 1;
    }

    @Scheduled(fixedRate = 2000)
    private void candlestickAllTask() {
        List<List<String>> dataList = new ArrayList<>();
        for (int i = 0; i < ExampleDayData.datatList.size(); i++) {
            List<String> candlestickDataList = ExampleDayData.datatList.get(i);
            dataList.add(candlestickDataList);
        }

        ResponseResult<List<List<String>>> responseResult = ResponseResult.success("candlestickAll",
                ExampleDayData.datatList);
        System.out.println("蜡烛数据 - 全部");
        WebSocketTest.sendMessage(responseResult);
    }
}
