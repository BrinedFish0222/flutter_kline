package com.example.example_java_kline.vo;

public class BaseChartVo {
    String id;
    String name;

    /// 最大值
    Double maxValue;

    /// 最小值
    /// 柱图如果不支持负数，设置成0。
    Double minValue;

    public BaseChartVo() {
    }

    public BaseChartVo(String id, String name, Double maxValue, Double minValue) {
        this.id = id;
        this.name = name;
        this.maxValue = maxValue;
        this.minValue = minValue;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Double getMaxValue() {
        return maxValue;
    }

    public void setMaxValue(Double maxValue) {
        this.maxValue = maxValue;
    }

    public Double getMinValue() {
        return minValue;
    }

    public void setMinValue(Double minValue) {
        this.minValue = minValue;
    }

}
