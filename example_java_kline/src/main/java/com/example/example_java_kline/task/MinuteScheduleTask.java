package com.example.example_java_kline.task;

import java.util.ArrayList;
import java.util.List;

import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;

import com.example.example_java_kline.example.ExampleMinuteData;
import com.example.example_java_kline.vo.ResponseResult;
import com.example.example_java_kline.websocket.WebSocketTest;

/**
 * 分时定时任务
 */
@Configuration
@EnableScheduling
@EnableAsync
public class MinuteScheduleTask {

    /**
     * 分时 - 全部数据索引位置
     */
    private static int minuteAllIndex = 0;

    /**
     * 分时 - 单根数据
     */
    @Scheduled(fixedRate=300)
    private void minuteSingleTask() {
        // System.err.println("执行静态定时任务时间: " + LocalDateTime.now());
        if (ExampleMinuteData.index >= ExampleMinuteData.lineData2.size()) {
            ExampleMinuteData.index = 0;
        }
        List<Double> dataList = ExampleMinuteData.lineData2.get(ExampleMinuteData.index);
        // 时间
        Double date = dataList.get(8);
        // 值
        Double value = dataList.get(5);
        List<Double> sendData = new ArrayList<>();
        sendData.add(date);
        sendData.add(value);
        sendData.add(ExampleMinuteData.a1.get(ExampleMinuteData.index));
        ResponseResult<List<Double>> responseResult = ResponseResult.success("minute", sendData);

        WebSocketTest.sendMessage(responseResult);
        ExampleMinuteData.index += 1;
    }

    /**
     * 分时 - 全部数据
     */
    @Scheduled(fixedRate = 300)
    private void minuteAllTask() {
        // System.err.println("执行静态定时任务时间: " + LocalDateTime.now());
        if (minuteAllIndex >= ExampleMinuteData.lineData2.size()) {
            minuteAllIndex = 0;
        }

        List<List<Double>> sendDataList = new ArrayList<>();
        for (int i = 0; i <= minuteAllIndex; ++i) {
            List<Double> dataList = ExampleMinuteData.lineData2.get(i);
            // 时间
            Double date = dataList.get(8);
            // 值
            Double value = dataList.get(5);
            List<Double> sendData = new ArrayList<>();
            sendData.add(date);
            sendData.add(value);
            sendData.add(ExampleMinuteData.a1.get(i));
            sendDataList.add(sendData);
        }

        ResponseResult<List<List<Double>>> responseResult = ResponseResult.success("minuteAll", sendDataList);

        WebSocketTest.sendMessage(responseResult);
        minuteAllIndex += 1;
    }
}
