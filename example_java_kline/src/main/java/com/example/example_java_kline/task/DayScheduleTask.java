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

    int allIndex = 0;

    @Scheduled(fixedRate = 2000)
    private void daySingleTask() {
        if (singleIndex >= ExampleDayData.datatList.size()) {
            singleIndex = 0;
        }

        List<List<String>> candlestickData = new ArrayList<>();
        List<String> candlestickDataList = ExampleDayData.datatList.get(singleIndex);
        candlestickData.add(candlestickDataList);

        System.out.println("蜡烛数据 - 单根：" + candlestickData.size());

        List<List<List<String>>> dataList = new ArrayList<>();
        dataList.add(candlestickData);

        ResponseResult<List<List<List<String>>>> responseResult = ResponseResult.success("daySingle",
                dataList);
        WebSocketTest.sendMessage(responseResult);
        singleIndex += 1;
    }

    @Scheduled(fixedRate = 2000)
    private void dayAllTask() {
        if (allIndex >= ExampleDayData.datatList.size()) {
            allIndex = 0;
        }

        List<List<String>> candlestickData = new ArrayList<>();
        for (int i = 0; i < allIndex; i++) {
            List<String> candlestickDataList = ExampleDayData.datatList.get(i);
            candlestickData.add(candlestickDataList);
        }

        System.out.println("蜡烛数据 - 全部：" + candlestickData.size());

        List<List<List<String>>> dataList = new ArrayList<>();
        dataList.add(candlestickData);

        ResponseResult<List<List<List<String>>>> responseResult = ResponseResult.success("dayAll",
                dataList);
        System.out.println("蜡烛数据 - 全部");
        WebSocketTest.sendMessage(responseResult);
        allIndex += 1;
    }


    /**
     * 一次推送所有数据
     */
    @Scheduled(fixedRate = 2000)
    private void daySingleAllTask() {
        List<List<String>> candlestickData = ExampleDayData.datatList;

        System.out.println("蜡烛数据 - 一次全部：" + candlestickData.size());

        List<List<List<String>>> dataList = new ArrayList<>();
        dataList.add(candlestickData);

        ResponseResult<List<List<List<String>>>> responseResult = ResponseResult.success("daySingleAll",
                dataList);
        WebSocketTest.sendMessage(responseResult);
    }
}
