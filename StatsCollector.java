package utilities;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.List;

/**
 * Collects performance metrics separately for API and UI tests.
 */
public class StatsCollector {

    // === API Metrics ===
    private static final List<Long> apiResponseTimes = new CopyOnWriteArrayList<>();
    private static final AtomicInteger apiRequests = new AtomicInteger(0);
    private static final AtomicInteger apiFailures = new AtomicInteger(0);

    // === UI Metrics ===
    private static final List<Long> uiStepTimes = new CopyOnWriteArrayList<>();
    private static final AtomicInteger uiSteps = new AtomicInteger(0);
    private static final AtomicInteger uiFailures = new AtomicInteger(0);

    private static long suiteStartTime;
    private static long suiteEndTime;

    private StatsCollector() {}

    // -------------------------------
    // Suite timing
    // -------------------------------
    public static void setStartTime(long startTime) { suiteStartTime = startTime; }
    public static void setEndTime(long endTime) { suiteEndTime = endTime; }

    // -------------------------------
    // API Metrics
    // -------------------------------
    public static void recordApiResponse(long responseTime, int statusCode) {
        apiResponseTimes.add(responseTime);
        apiRequests.incrementAndGet();
        if (statusCode >= 400) {
            apiFailures.incrementAndGet();
        }
    }

    private static double getAverage(List<Long> times) {
        if (times.isEmpty()) return 0.0;
        return times.stream().mapToLong(Long::longValue).average().orElse(0.0);
    }

    private static long getMin(List<Long> times) {
        return times.stream().mapToLong(Long::longValue).min().orElse(0L);
    }

    private static long getMax(List<Long> times) {
        return times.stream().mapToLong(Long::longValue).max().orElse(0L);
    }

    private static double getErrorRate(int failures, int total) {
        if (total == 0) return 0.0;
        return (failures * 100.0) / total;
    }

    private static double getThroughput(int total) {
        if (suiteStartTime == 0 || suiteEndTime == 0) return 0.0;
        long totalDuration = suiteEndTime - suiteStartTime; // ms
        if (totalDuration <= 0) return 0.0;
        return (total * 1000.0) / totalDuration;
    }

    // -------------------------------
    // UI Metrics
    // -------------------------------
    public static void recordUiStep(long duration, boolean failed) {
        uiStepTimes.add(duration);
        uiSteps.incrementAndGet();
        if (failed) {
            uiFailures.incrementAndGet();
        }
    }

    // -------------------------------
    // Final Report
    // -------------------------------
    public static void generateReport(String filePath) {
        JSONObject report = new JSONObject();

        // API metrics
        JSONObject apiJson = new JSONObject();
        apiJson.put("totalRequests", apiRequests.get());
        apiJson.put("failedRequests", apiFailures.get());
        apiJson.put("avgResponseTime", getAverage(apiResponseTimes));
        apiJson.put("minResponseTime", getMin(apiResponseTimes));
        apiJson.put("maxResponseTime", getMax(apiResponseTimes));
        apiJson.put("throughput", getThroughput(apiRequests.get()));
        apiJson.put("errorRate", getErrorRate(apiFailures.get(), apiRequests.get()));

        // UI metrics
        JSONObject uiJson = new JSONObject();
        uiJson.put("totalSteps", uiSteps.get());
        uiJson.put("failedSteps", uiFailures.get());
        uiJson.put("avgStepTime", getAverage(uiStepTimes));
        uiJson.put("minStepTime", getMin(uiStepTimes));
        uiJson.put("maxStepTime", getMax(uiStepTimes));
        uiJson.put("throughput", getThroughput(uiSteps.get()));
        uiJson.put("errorRate", getErrorRate(uiFailures.get(), uiSteps.get()));

        report.put("apiMetrics", apiJson);
        report.put("uiMetrics", uiJson);

        try {
            Files.write(Paths.get(filePath), report.toString(2).getBytes());
            System.out.println("📊 Performance report written to: " + filePath);
            System.out.println(report.toString(2));
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}

// API Usage
/*
Response response = given().when().get("/endpoint").then().extract().response();
StatsCollector.recordApiResponse(response.getTime(), response.getStatusCode());

 */
// StepTimingHooks.java
import io.cucumber.java.BeforeStep;
import io.cucumber.java.AfterStep;
import io.cucumber.java.Scenario;
import utilities.StatsCollector;

public class StepTimingHooks {
    private long stepStartTime;

    @BeforeStep
    public void beforeStep() {
        stepStartTime = System.currentTimeMillis();
    }

    @AfterStep
    public void afterStep(Scenario scenario) {
        long duration = System.currentTimeMillis() - stepStartTime;
        StatsCollector.recordUiStep(duration, scenario.isFailed());
    }
}
