package com.example.example_java_kline.websocket;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import javax.websocket.*;
import javax.websocket.server.PathParam;
import javax.websocket.server.ServerEndpoint;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 使用 websocket 模拟即时通讯。
 */
@Component // 注意：如果使用 spring boot ，则该注解不可以去掉。
@ServerEndpoint("/websocket/{id}")
public class WebSocketTest {

    /**
     * 日志信息
     */
    private static final Logger LOGGER = LoggerFactory.getLogger(WebSocketTest.class);
    /**
     * 存储所有连接 websocket 的用户，所以必须考虑线程的安全性。
     */
    private final static Map<String, Session> CLIENTS = new ConcurrentHashMap<>();
    /**
     * 当前用户的主键。
     */
    private String id;

    /**
     * 建立连接
     *
     * @param session
     */
    @OnOpen
    public void onOpen(@PathParam("id") String id, Session session) {
        try {
            CLIENTS.put(id, session);
            this.id = id;
            LOGGER.info("user {} login", id);
        } catch (Exception e) {
            LOGGER.error(e.getMessage());
        }

    }

    /**
     * 连接关闭
     */
    @OnClose
    public void onClose() {
        try {
            CLIENTS.remove(this.id);
            LOGGER.info("client {} close", this.id);
        } catch (Exception e) {
            LOGGER.error("client close error: {}", e.getMessage());
        }

    }

    /**
     * 报错。
     * 
     * @param session
     * @param error
     */
    @OnError
    public void onError(Session session, Throwable error) {
        LOGGER.error("error: {}", error.getMessage());
    }

    /**
     * 收到客户端的消息
     *
     * @param message 消息
     * @param session 会话
     */
    @OnMessage
    public void onMessage(String message, Session session) {
        try {
            System.out.println("message : " + message);
            JSONObject msgJO = JSON.parseObject(message);
            String toUserId = msgJO.getString("toUserId"); // 接受人id。
            String content = msgJO.getString("content"); // 消息内容。
            if (StringUtils.isEmpty(toUserId))
                throw new RuntimeException("must to user id");

            Session toUserSession = CLIENTS.get(toUserId);
            // 如果 session 不为空，则发送消息。
            if (toUserSession != null) {
                toUserSession.getAsyncRemote().sendText(content);
            }
        } catch (Exception e) {
            LOGGER.error("send message error: {}", e.getMessage());
        }

    }

    public static Map<String, Session> getClients() {
        return CLIENTS;
    }

    /*
     * 发送消息
     */
    public static void sendMessage(Object data) {
        String dataJson = JSON.toJSONString(data);
        System.out.println("发送数据：" + dataJson);
        for (Session session : CLIENTS.values()) {
            session.getAsyncRemote().sendText(dataJson);
        }
    }
}