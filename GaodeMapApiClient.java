package xiaocx;

import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;
import java.net.URLEncoder;

@SpringBootApplication
@RestController
public class GaodeMapApiClient {
    private static final String API_KEY = "dc78d27ad971318cb94c72c5a7ee5a36";
    private static final String BIZ_TOKEN = "5Rg0Wh50BH0tK4";
    private static final String BIZ_SECRET = "bf21af90-7849-4c5a-9fa7-4f5d1597d06a";

    // 地点搜索API示例
    @GetMapping("/searchPlace")
    public JSONArray searchPlace(@RequestParam String keywords, @RequestParam String city) {
        JSONArray resultArray = new JSONArray();
        try {
            // 构建请求URL
            StringBuilder urlBuilder = new StringBuilder("https://restapi.amap.com/v3/place/text?");
            urlBuilder.append("key=").append(API_KEY);
            urlBuilder.append("&keywords=").append(URLEncoder.encode(keywords, "UTF-8"));
            urlBuilder.append("&city=").append(URLEncoder.encode(city, "UTF-8"));
            urlBuilder.append("&output=json");

            // 创建HTTP客户端和GET请求
            HttpClient httpClient = HttpClients.createDefault();
            HttpGet httpGet = new HttpGet(urlBuilder.toString());

            // 添加bizToken（如果需要）
            httpGet.addHeader("X-Biz-Token", BIZ_TOKEN);

            // 执行请求
            HttpResponse response = httpClient.execute(httpGet);

            // 处理响应
            if (response.getStatusLine().getStatusCode() == 200) {
                String result = EntityUtils.toString(response.getEntity());
                JSONObject jsonResult = JSONObject.parseObject(result);

                // 检查API返回状态
                if ("1".equals(jsonResult.getString("status"))) {
                    JSONArray pois = jsonResult.getJSONArray("pois");
                    for (int i = 0; i < pois.size(); i++) {
                        JSONObject poi = pois.getJSONObject(i);
                        JSONObject item = new JSONObject();
                        item.put("name", poi.getString("name"));
                        item.put("location", poi.getString("location"));
                        resultArray.add(item);
                    }
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return resultArray;
    }

    public static void main(String[] args) {
        SpringApplication.run(GaodeMapApiClient.class, args);
    }
}