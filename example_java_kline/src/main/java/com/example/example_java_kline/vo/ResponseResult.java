package com.example.example_java_kline.vo;

public class ResponseResult<T> {
    private Integer code;
    private String msg;
    private String type;
    private T data;

    public ResponseResult() {
    }

    public ResponseResult(Integer code, String msg, String type, T data) {
        this.code = code;
        this.msg = msg;
        this.type = type;
        this.data = data;
    }

    public static <T> ResponseResult<T> success(String type, T data) {
        return new ResponseResult<T>(200, "", type, data);
    }

    public Integer getCode() {
        return code;
    }

    public void setCode(Integer code) {
        this.code = code;
    }

    public String getMsg() {
        return msg;
    }

    public void setMsg(String msg) {
        this.msg = msg;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public T getData() {
        return data;
    }

    public void setData(T data) {
        this.data = data;
    }

}
