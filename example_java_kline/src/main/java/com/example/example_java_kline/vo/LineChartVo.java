package com.example.example_java_kline.vo;

import java.util.Date;
import java.util.List;

public class LineChartVo extends BaseChartVo {
    List<LineChartData> dataList;

    public LineChartVo() {
    }

    public LineChartVo(String id, String name, Double maxValue, Double minValue, List<LineChartData> dataList) {
        super(id, name, maxValue, minValue);
        this.dataList = dataList;
    }

    public List<LineChartData> getDataList() {
        return dataList;
    }

    public void setDataList(List<LineChartData> dataList) {
        this.dataList = dataList;
    }

}

class LineChartData {
    Date dateTime;

    Double value;

    public LineChartData() {
    }

    public LineChartData(Date dateTime, Double value) {
        this.dateTime = dateTime;
        this.value = value;
    }

    public Date getDateTime() {
        return dateTime;
    }

    public void setDateTime(Date dateTime) {
        this.dateTime = dateTime;
    }

    public Double getValue() {
        return value;
    }

    public void setValue(Double value) {
        this.value = value;
    };

}