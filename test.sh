#!/usr/bin/bash

for message_number in 1 2; do
     echo "Round ${message_number}: Sending messages";
     for i in `seq 1 10`; do
          echo "foo|{\"message\":\"${message_number}\"}" | kafka-console-producer --broker-list zaius:9092 --topic direct${i} --property parse.key=true --property key.separator="|";
          sleep 1;
          echo "foo|{\"message\":\"${message_number}\"}" | kafka-console-producer --broker-list zaius:9092 --topic ${i}_events --property parse.key=true --property key.separator="|";
          sleep 2;
     done;
     echo "Round ${message_number}: Send complete. Topics in aggregate cluster at end of round";
     kafka-topics --zookeeper zaius2:2181 --list;
     echo "---";
done

for topic in `kafka-topics --zookeeper zaius:2181 --list`; do
     echo "Messages in topic ${topic} in edge cluster";
     kafka-console-consumer --zookeeper zaius:2181 --topic ${topic} --from-beginning --timeout-ms 500 2> /dev/null;
     echo "Messages in topic ${topic} in aggregate cluster";
     kafka-console-consumer --zookeeper zaius2:2181 --topic ${topic} --from-beginning --timeout-ms 500 2> /dev/null;
     echo "---";
done
