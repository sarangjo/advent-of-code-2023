import java.io.File;
import java.io.FileNotFoundException;
import java.util.Scanner;

public class day6 {
    public static void main(String[] args) {
        String time, distance;
        try {
            Scanner scanner = new Scanner(new File("day6.txt"));

            time = scanner.nextLine();
            distance = scanner.nextLine();
        } catch (FileNotFoundException e) {
            System.out.println("File not found");
            return;
        }

        System.out.println("Part 1: " + part1(time, distance));
        System.out.println("Part 2: " + part2(time, distance));
    }

    // n * (t-n) > d  ===> boundaries = (t +/- sqrt(t^2 - 4d)) / 2
    private static long numWaysToBeat(long time, long distance) {
        double det = Math.sqrt(Math.pow(time, 2) - 4 * distance);
        long lo = (long) Math.ceil((time - det) / 2);
        if (lo * (time - lo) == distance) {
            lo++;
        }
        long hi = (long) Math.floor((time + det) / 2);
        if (hi * (time - hi) == distance) {
            hi--;
        }

        return hi - lo + 1;
    }

    private static long part1(String time, String distance) {
        String[] times = time.substring(time.indexOf(':') + 1).split("\\s+");
        String[] distances = distance.substring(distance.indexOf(':') + 1).split("\\s+");

        long prod = 1;

        // Skip the useless beginning empty
        for (int i = 1; i < times.length; i++) {
            prod *= numWaysToBeat(Long.valueOf(times[i]), Long.valueOf(distances[i]));
        }

        return prod;
    }

    private static long part2(String time, String distance) {
        long parsedTime = Long.valueOf(time.replaceAll("\\s+", "").split(":")[1]);
        long parsedDistance = Long.valueOf(distance.replaceAll("\\s+", "").split(":")[1]);

        return numWaysToBeat(parsedTime, parsedDistance);
    }
}
