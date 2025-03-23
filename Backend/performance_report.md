# Spello Backend Performance Test Report

Test executed on: 2025-03-23 06:03:41

## Summary

| API Endpoint | Success Rate | Avg Response (ms) | Median (ms) | 95th Percentile (ms) | Max (ms) |
|-------------|--------------|-------------------|-------------|----------------------|---------|
| Login API | 100.00% | 969.99 | 759.67 | 2044.23 | 3656.32 |
| Get User Profile | 100.00% | 347.52 | 317.78 | 473.60 | 1261.08 |
| Get Target Word | 100.00% | 273.87 | 231.90 | 375.05 | 1506.89 |
| Dashboard Data | 100.00% | 254.11 | 217.35 | 356.45 | 1271.14 |
| Speech-to-Text API | 100.00% | 70.92 | 55.52 | 78.58 | 888.29 |

## Detailed Results

### Login API

- **Total Requests**: 100
- **Success Rate**: 100.00%
- **Min Response Time**: 326.02 ms
- **Max Response Time**: 3656.32 ms
- **Average Response Time**: 969.99 ms
- **Median Response Time**: 759.67 ms
- **90th Percentile**: 1849.33 ms
- **95th Percentile**: 2044.23 ms
- **99th Percentile**: 2535.59 ms

![Response Time Distribution for Login API](login_api_performance.png)

### Get User Profile

- **Total Requests**: 100
- **Success Rate**: 100.00%
- **Min Response Time**: 187.18 ms
- **Max Response Time**: 1261.08 ms
- **Average Response Time**: 347.52 ms
- **Median Response Time**: 317.78 ms
- **90th Percentile**: 441.38 ms
- **95th Percentile**: 473.60 ms
- **99th Percentile**: 1249.08 ms

![Response Time Distribution for Get User Profile](get_user_profile_performance.png)

### Get Target Word

- **Total Requests**: 100
- **Success Rate**: 100.00%
- **Min Response Time**: 164.97 ms
- **Max Response Time**: 1506.89 ms
- **Average Response Time**: 273.87 ms
- **Median Response Time**: 231.90 ms
- **90th Percentile**: 367.64 ms
- **95th Percentile**: 375.05 ms
- **99th Percentile**: 1500.89 ms

![Response Time Distribution for Get Target Word](get_target_word_performance.png)

### Dashboard Data

- **Total Requests**: 100
- **Success Rate**: 100.00%
- **Min Response Time**: 161.57 ms
- **Max Response Time**: 1271.14 ms
- **Average Response Time**: 254.11 ms
- **Median Response Time**: 217.35 ms
- **90th Percentile**: 324.74 ms
- **95th Percentile**: 356.45 ms
- **99th Percentile**: 1265.14 ms

![Response Time Distribution for Dashboard Data](dashboard_data_performance.png)

### Speech-to-Text API

- **Total Requests**: 50
- **Success Rate**: 100.00%
- **Min Response Time**: 31.33 ms
- **Max Response Time**: 888.29 ms
- **Average Response Time**: 70.92 ms
- **Median Response Time**: 55.52 ms
- **90th Percentile**: 76.93 ms
- **95th Percentile**: 78.58 ms
- **99th Percentile**: 95.38 ms

![Response Time Distribution for Speech-to-Text API](speech-to-text_api_performance.png)

## Recommendations

The following endpoints have slow response times (95th percentile > 1000ms):

- **Login API**: 2044.23 ms

Possible improvement areas:

1. Implement caching for frequently accessed data
2. Optimize database queries
3. Consider implementing connection pooling
4. Review any heavy processing in these endpoints
