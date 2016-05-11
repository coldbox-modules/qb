#!/bin/bash
curl http://127.0.0.1:7777/tests/runner.cfm\?propertiesSummary\=true\&reporter\=text

if ! grep 'test.passed=true' tests/results/TEST.properties
then
    exit 1
else
    exit 0
fi