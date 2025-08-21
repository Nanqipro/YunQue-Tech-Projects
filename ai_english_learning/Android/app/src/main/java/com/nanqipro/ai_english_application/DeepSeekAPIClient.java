package com.nanqipro.ai_english_application;

import okhttp3.*;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.JsonArray;
import java.io.IOException;
import java.util.List;
import java.util.concurrent.TimeUnit;

public class DeepSeekAPIClient {
    
    private static final String API_URL = "https://api.deepseek.com/v1/chat/completions";
    private static final String API_KEY = "sk-60e54dd882314d11b6dd43fe1bf55f11";
    private static final MediaType JSON = MediaType.get("application/json; charset=utf-8");
    
    private OkHttpClient client;
    private Gson gson;
    
    public interface APICallback {
        void onSuccess(String sentence, String translation);
        void onError(String error);
    }
    
    public DeepSeekAPIClient() {
        client = new OkHttpClient.Builder()
                .connectTimeout(30, TimeUnit.SECONDS)
                .readTimeout(60, TimeUnit.SECONDS)
                .writeTimeout(30, TimeUnit.SECONDS)
                .build();
        gson = new Gson();
    }
    
    public void generateMemorySentence(List<String> words, APICallback callback) {
        // 构建提示词
        String wordsString = String.join(", ", words);
        String prompt = String.format(
            "请用以下英语单词创造一个有趣、生动、容易记忆的英语句子，帮助学习者联想记忆这些单词：%s\n\n" +
            "要求：\n" +
            "1. 句子要包含所有给定的单词\n" +
            "2. 句子要有逻辑性和趣味性，便于记忆\n" +
            "3. 句子长度适中，不要太复杂\n" +
            "4. 请同时提供中文翻译\n\n" +
            "请按以下格式回复：\n" +
            "英文句子：[你的英文句子]\n" +
            "中文翻译：[对应的中文翻译]",
            wordsString
        );
        
        // 构建请求体
        JsonObject requestBody = new JsonObject();
        requestBody.addProperty("model", "deepseek-chat");
        requestBody.addProperty("max_tokens", 500);
        requestBody.addProperty("temperature", 0.7);
        
        JsonArray messages = new JsonArray();
        JsonObject systemMessage = new JsonObject();
        systemMessage.addProperty("role", "system");
        systemMessage.addProperty("content", "你是一个专业的英语教学助手，擅长创造有趣的记忆句子帮助学生学习英语单词。");
        messages.add(systemMessage);
        
        JsonObject userMessage = new JsonObject();
        userMessage.addProperty("role", "user");
        userMessage.addProperty("content", prompt);
        messages.add(userMessage);
        
        requestBody.add("messages", messages);
        
        RequestBody body = RequestBody.create(gson.toJson(requestBody), JSON);
        
        Request request = new Request.Builder()
                .url(API_URL)
                .addHeader("Authorization", "Bearer " + API_KEY)
                .addHeader("Content-Type", "application/json")
                .post(body)
                .build();
        
        // 异步执行请求
        client.newCall(request).enqueue(new Callback() {
            @Override
            public void onFailure(Call call, IOException e) {
                callback.onError("网络请求失败: " + e.getMessage());
            }
            
            @Override
            public void onResponse(Call call, Response response) throws IOException {
                try {
                    if (!response.isSuccessful()) {
                        String errorBody = response.body() != null ? response.body().string() : "未知错误";
                        callback.onError("API请求失败 (" + response.code() + "): " + errorBody);
                        return;
                    }
                    
                    String responseBody = response.body().string();
                    JsonObject jsonResponse = gson.fromJson(responseBody, JsonObject.class);
                    
                    if (jsonResponse.has("choices") && jsonResponse.getAsJsonArray("choices").size() > 0) {
                        JsonObject choice = jsonResponse.getAsJsonArray("choices").get(0).getAsJsonObject();
                        JsonObject message = choice.getAsJsonObject("message");
                        String content = message.get("content").getAsString();
                        
                        // 解析返回的内容
                        String[] result = parseResponse(content);
                        if (result != null && result.length == 2) {
                            callback.onSuccess(result[0], result[1]);
                        } else {
                            // 如果解析失败，返回原始内容
                            callback.onSuccess(content, "解析翻译失败，请查看原文");
                        }
                    } else {
                        callback.onError("API返回格式错误");
                    }
                } catch (Exception e) {
                    callback.onError("解析响应失败: " + e.getMessage());
                } finally {
                    response.close();
                }
            }
        });
    }
    
    private String[] parseResponse(String content) {
        try {
            String[] lines = content.split("\n");
            String englishSentence = null;
            String chineseTranslation = null;
            
            for (String line : lines) {
                line = line.trim();
                if (line.startsWith("英文句子：") || line.startsWith("English:") || line.startsWith("Sentence:")) {
                    englishSentence = line.substring(line.indexOf("：") + 1).trim();
                    if (englishSentence.isEmpty() && line.contains(":")) {
                        englishSentence = line.substring(line.indexOf(":") + 1).trim();
                    }
                } else if (line.startsWith("中文翻译：") || line.startsWith("Chinese:") || line.startsWith("Translation:")) {
                    chineseTranslation = line.substring(line.indexOf("：") + 1).trim();
                    if (chineseTranslation.isEmpty() && line.contains(":")) {
                        chineseTranslation = line.substring(line.indexOf(":") + 1).trim();
                    }
                }
            }
            
            // 如果没有找到标准格式，尝试其他解析方式
            if (englishSentence == null || chineseTranslation == null) {
                // 尝试按行分割，第一行是英文，第二行是中文
                String[] nonEmptyLines = content.split("\n");
                java.util.List<String> validLines = new java.util.ArrayList<>();
                for (String line : nonEmptyLines) {
                    line = line.trim();
                    if (!line.isEmpty() && !line.startsWith("要求") && !line.startsWith("请")) {
                        validLines.add(line);
                    }
                }
                
                if (validLines.size() >= 2) {
                    englishSentence = validLines.get(0);
                    chineseTranslation = validLines.get(1);
                } else if (validLines.size() == 1) {
                    englishSentence = validLines.get(0);
                    chineseTranslation = "翻译生成中...";
                }
            }
            
            if (englishSentence != null && chineseTranslation != null) {
                return new String[]{englishSentence, chineseTranslation};
            }
            
        } catch (Exception e) {
            android.util.Log.e("DeepSeekAPI", "解析响应失败", e);
        }
        
        return null;
    }
    
    public void destroy() {
        if (client != null) {
            client.dispatcher().executorService().shutdown();
            client.connectionPool().evictAll();
        }
    }
}