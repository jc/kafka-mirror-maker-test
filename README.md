# Overview

This repository demonstrates that Kafka Mirror Maker can miss the first batch of
messages produced to a new topic.

In this test we setup two kafka clusters (1 zk, 1 kafka-server). And mirror
messages from dc1 to dc2. Mirror maker runs in dc2 using a whitelist explicitly
listing topics `direct[1-10]` and a regular expression for topics
`[1-10]_events` (`.+_events$`).

`test.sh` produces two messages to topics `[1-10]_events` and `direct[1-10]`. It
then reads the messages off the topics in dc2. We expect all topics to be
present in dc2 with two messages each matching the messages in dc1.

What we see is that some topics in dc2 are created after the first round of
messages. After the second round of messages all topics are present in dc2. All
messages are present in dc1, all topics in dc2 contain message 2, while only
some topics in dc2 contain message 1.

# Setup

Two docker-machines are required to simulate two kafka clusters.

```
$ docker-machine create --driver virtualbox zaius
$ docker-machine create --driver virtualbox zaius2
```

The config and compose files assume the machines have the following IP addresses:

```
$ docker-machine ip zaius
192.168.99.100
$ docker-machine ip zaius2
192.168.99.101
```

We will use `zaius` as an edge data center (dc1) and `zaius2` will be the
aggregate data center (dc2).

Setup dc1:

```
$ eval $(docker-machine env zaius)
$ docker-compose -f docker-compose.dc1.yml up
```

Setup dc2 (in another terminal window):

```
$ eval $(docker-machine env zaius2)
$ docker-compose -f docker-compose.dc2.yml up
```

# Running the test

Run `test.sh` on the kafka running on `zaius` (dc1):

```
$ eval $(docker-machine env zaius)
$ docker exec -t kafka bash /opt/test.sh
```

# Tear down

Stop docker-compose process (`^C`) then tear down the containers:

dc1:


```
$ docker-compose -f docker-compose.dc1.yml down -v
```

dc2:

```
$ docker-compose -f docker-compose.dc2.yml down -v
```


# Actual output

```
Round 1: Sending messages
Round 1: Send complete. Topics in aggregate cluster at end of round
2_events
3_events
4_events
direct2
direct3
direct4
direct5
---
Round 2: Sending messages
Round 2: Send complete. Topics in aggregate cluster at end of round
10_events
2_events
3_events
4_events
5_events
6_events
7_events
8_events
9_events
direct1
direct10
direct2
direct3
direct4
direct5
direct6
direct7
direct8
direct9
---
Messages in topic 10_events in edge cluster
{"message":"1"}
{"message":"2"}
Messages in topic 10_events in aggregate cluster
{"message":"2"}
---
Messages in topic 1_events in edge cluster
{"message":"1"}
Messages in topic 1_events in aggregate cluster
---
Messages in topic 2_events in edge cluster
{"message":"1"}
{"message":"2"}
Messages in topic 2_events in aggregate cluster
{"message":"1"}
{"message":"2"}
---
Messages in topic 3_events in edge cluster
{"message":"1"}
{"message":"2"}
Messages in topic 3_events in aggregate cluster
{"message":"1"}
{"message":"2"}
---
Messages in topic 4_events in edge cluster
{"message":"1"}
{"message":"2"}
Messages in topic 4_events in aggregate cluster
{"message":"1"}
{"message":"2"}
---
Messages in topic 5_events in edge cluster
{"message":"1"}
{"message":"2"}
Messages in topic 5_events in aggregate cluster
{"message":"2"}
---
Messages in topic 6_events in edge cluster
{"message":"1"}
{"message":"2"}
Messages in topic 6_events in aggregate cluster
{"message":"2"}
---
Messages in topic 7_events in edge cluster
{"message":"1"}
{"message":"2"}
Messages in topic 7_events in aggregate cluster
{"message":"2"}
---
Messages in topic 8_events in edge cluster
{"message":"1"}
{"message":"2"}
Messages in topic 8_events in aggregate cluster
{"message":"2"}
---
Messages in topic 9_events in edge cluster
{"message":"1"}
{"message":"2"}
Messages in topic 9_events in aggregate cluster
{"message":"2"}
---
Messages in topic direct1 in edge cluster
{"message":"2"}
Messages in topic direct1 in aggregate cluster
{"message":"2"}
---
Messages in topic direct10 in edge cluster
{"message":"1"}
{"message":"2"}
Messages in topic direct10 in aggregate cluster
{"message":"2"}
---
Messages in topic direct2 in edge cluster
{"message":"1"}
{"message":"2"}
Messages in topic direct2 in aggregate cluster
{"message":"1"}
{"message":"2"}
---
Messages in topic direct3 in edge cluster
{"message":"1"}
{"message":"2"}
Messages in topic direct3 in aggregate cluster
{"message":"1"}
{"message":"2"}
---
Messages in topic direct4 in edge cluster
{"message":"1"}
{"message":"2"}
Messages in topic direct4 in aggregate cluster
{"message":"1"}
{"message":"2"}
---
Messages in topic direct5 in edge cluster
{"message":"1"}
{"message":"2"}
Messages in topic direct5 in aggregate cluster
{"message":"1"}
{"message":"2"}
---
Messages in topic direct6 in edge cluster
{"message":"1"}
{"message":"2"}
Messages in topic direct6 in aggregate cluster
{"message":"2"}
---
Messages in topic direct7 in edge cluster
{"message":"1"}
{"message":"2"}
Messages in topic direct7 in aggregate cluster
{"message":"2"}
---
Messages in topic direct8 in edge cluster
{"message":"1"}
{"message":"2"}
Messages in topic direct8 in aggregate cluster
{"message":"2"}
---
Messages in topic direct9 in edge cluster
{"message":"1"}
{"message":"2"}
Messages in topic direct9 in aggregate cluster
{"message":"2"}
---
```
