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
        long stepEndTime = System.currentTimeMillis();
        long duration = stepEndTime - stepStartTime;

        // Generic logging for ANY step (UI or API)
        boolean failed = scenario.isFailed();
        StatsCollector.recordResponse(duration, failed ? 500 : 200);
    }
}
