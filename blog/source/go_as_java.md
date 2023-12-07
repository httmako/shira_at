---
title: go as java | shira.at
toc: true
header-includes:
    <link rel="stylesheet" href="https://shira.at/style.css">
---


## Intro

<u>**__Warning: This is based in favor of Golang.__**</u>  
This is supposed to be a powerpoint-like presentation on why I personally think that Go can be the future of Java in cloud environment.  
This isn't a full comparison yet as im missing the time to do lots of benchmarks and feature comparisons.  


## Environment setup differences

With Java you have a lot to setup.  
First the IDE: Would you rather use Eclipse, IntelliJ or NetBeans?  
Then decide on a Java version: Stuck with Java8/11 (due to legacy code) or choose Java16?  
Then the package manager: Ant, Maven or Gradle? And which version of the choosen one?  
Last but not least: Wildfly or Tomcat for websites? Or Spring Boot? JSP or Angular?  

Comparing that to Golang it's very complicated.  
With Go you only have the Go version to worry about.  
You can program with VisualStudioCode or even vim.  
The package manager is built into the go commandline with `go get`. Go features, by default, linting, race condition detecting and version management.  
The webserver is built into the default golang packages and doesn't need anything like a tomcat to run.


This environment setup process can be explained really easily with an example.  
**Try to setup a simple webserver that responds to /ping with a "pong" response.**

With Java you need, as mentioned before, the IDE+PackageManager+Tomcat.  
With Golang you only need a text file in combination with 3 commands: `go mod init example.com/app && go get . && go run .`


## Performance

I always hear that Java is the best performing language. Many people, who are not based upon the historic legacy of Java in their company, see this different nowadays.

I have 3 benchmarks that show my point pretty well. Java is not the only one at the top anymore.


### Web Framework Benchmark

An example of the performance of common web frameworks we learned at University:

[https://web-frameworks-benchmark.netlify.app/compare?f=laravel,rails,flask,express,spring,gin](https://web-frameworks-benchmark.netlify.app/compare?f=laravel,rails,flask,express,spring,gin)

In these examples "spring boot" is used for Java and "gin-gonic" for Golang. (With Java11 and Go11.7)  
These 2 are the most common frameworks I found when working with them.  
As you can see, gin destroys the other frameworks in performance. 

Here are all the frameworks that this website has compared:  
[https://web-frameworks-benchmark.netlify.app/result?l=go,java](https://web-frameworks-benchmark.netlify.app/result?l=go,java)

The only thing this comparison doesn't show is the popularity. The framework that is the fastest could be buggy and missing a lot of features, but is still the fastest because of it.

Summary: Gin wins over Spring, but use this comparison with caution.


### Julia's Benchmark

The programming language Julia made a benchmark of specific algorithms using many different languages. It uses Golang1.9 and Java8.

[https://julialang.org/benchmarks/](https://julialang.org/benchmarks/)

Here you can see that Go wins over Java in performance. The only category Golang doesn't work better than Java is with "Matrix Statistics", where it is a bit worse than Java.

This benchmark is, ofcourse, to be used with caution. The date and specific execution of it is unknown.


### RAM & CPU Usage

It is common knowledge that Java is a RAM eating monster.

I created 2 webservers: One with Go's "gin" and one with Java's "Spring-Boot" web framework.

For Spring I used their "REST Api" example: [https://spring.io/guides/tutorials/rest/](https://spring.io/guides/tutorials/rest/)  
For Go I used the gin example from here with an added struct for greeting: [https://github.com/gin-gonic/gin/blob/master/README.md#quick-start](https://github.com/gin-gonic/gin/blob/master/README.md#quick-start)

Both applications have the same speed on my machine (1100 req/s) and the same average response time (44ms) when I load tested them with apache benchmark (50 concurrent clients with 10000 requests).  

The main difference: **Java used 262.1MB of RAM and Go only used 8.7MB of RAM!**  
Another small difference: Go's RAM usage was 2.9MB before the load test, while Java's RAM usage was always at 262.1MB.

Another benchmark I found for this is the following medium article:

[https://medium.com/@dexterdarwich/comparison-between-java-go-and-rust-fdb21bd5fb7c](https://medium.com/@dexterdarwich/comparison-between-java-go-and-rust-fdb21bd5fb7c)

Ofcourse, never trust a random benchmark you found on the internet, but I tested these myself and got similar results.

Some key points I want to point out from the article:

 - While running idle, Java used a massive 162MB of RAM, while Go only used 0.86MB of RAM.  
 - Java has, for 2 of the 3 endpoints, higher CPU usage than Go. In the last one it has a 1% lower usage than Go.
 - The /hello endpoint, which simply replies with "Hello World", made Java use 1.5GB of RAM, while Go only used 18.38MB of RAM.
 - Java was, with the /fibonacci endpoint, able to answer more requests, but is that really worth the immense RAM usage in a cloud environment?

Some people may say "I have the RAM, so i don't care", but that's the wrong approach for the cloud.  
Java uses 22.5 times more RAM then Go for around 20% better performance.  
You could deploy a second Go application, which is quite easy in the cloud, and get a way better performance out of it, with still less RAM usage than the Java application.



## Cloud

### Docker Container

A comparison between moving Java and moving Go applications into a container.

With Java you have to create a custom "run.sh" start script which adds the classpath and all the other configuration to the start command.  
You also need a base FROM image like `openjdk:8u332-jre-slim-bullseye` which bloats up the container size.

Example Dockerfile for Java:

    FROM openjdk:8-jre-slim-bullseye
    MAINTAINER Me Myself <me@example.com>

    WORKDIR /srv/myapp

    COPY myapp-1.0.0.jar myapp-1.0.0.jar
    COPY jars jars/
    COPY lib lib/
    COPY run.sh run.sh

    ENTRYPOINT ["/srv/myapp/run.sh"]


With Go you can simply move the binary file into an empty container and run it, no special FROM image needed. This makes the container 90% more lightweight.

Example Dockerfile for Go:

    FROM scratch
    COPY myapp /myapp
    CMD ["/myapp"]

If you need to have config files or web resources then you have to ofcourse COPY them into it too.


To show the difference in size I compared my minimalistic NodeJS REST API container to my Go REST API container (the first 2 in the list):

    REPOSITORY    TAG            IMAGE ID        CREATED         SIZE
    gotest        latest         8a2491c7a736    2 days ago      8.77MB
    nodetest      latest         8780b334ac5d    2 days ago      173MB
    alpine        3.13           20e452a0a81a    3 weeks ago     5.61MB
    mariadb       latest         6e0162b44a5f    5 weeks ago     414MB
    node          17.6-alpine    eb56d56623e5    2 months ago    168MB
    nginx         latest         c316d5a335a5    3 months ago    142MB
    hello-world   latest         feb5d9fea6a5    7 months ago    13.3kB

The gotest image is way smaller than the nodetest image, even though they do practically the same.

Ofcourse, the size itself is not much of a "game breaker", nobody would choose a programming language over another just because the application filesize is smaller. But it shows that Go is more the "one final package" solution which is easier to deploy in the cloud.


### Cloud RAM ressources

I have 3 different namespaces: myapp-dev, myapp-int and myapp-prod. This means my application is running ATLEAST 3 times at once.  

The current java application needs ~500MB of RAM to run. (-Xmx is set to 512MB)  
This means that im currently using atleast 2GB of RAM (1dev, 1int and 2prod if not more) of my 12GB in total. This is quite a lot, because the CPU usage is really low compared to my RAM usage.  

If I compare that to my Go application, which needs around 30MB of RAM, I could run a lot more instances while only having to worry about CPU pretty much. (My 4 Go instances would use less RAM than one Java instance)



## Benefits of using Golang


### Enables users to write good code

Go has multiple features built in that prohibits you from building bad or unoptimized code. For example:

```go
result, err := myFunction(input)
if err != nil {
    return false
}
return true
```

This function would not compile because go would see the variable result as never used and thus fail during building. If you import a package but never use it go will also fail to build.

This enables you to build predictable and high quality code. For another feature for predictable code see the next paragraph about Race Conditions.


### Race Condition Detector

You can run your code with a "race condition detector", which is build into the go commandline tool.

An example file would be:

```go
package main

import "fmt"

func main() {
    done := make(chan bool)
    m := make(map[string]string)
    m["name"] = "world"
    go func() {
        m["name"] = "data race"
        done <- true
    }()
    fmt.Println("Hello,", m["name"])
    <-done
}
```

With `go func()` you create a "goroutine" aka. a lightweight thread. This thread then changes the map "name", but at the same time the main thread continues and reads from the map "name" index. This creates a race condition.

To test it simply run the file with

    go run -race .

and the output is similar to

    me@manjaro:~/dev/go/racy$ go run -race racy.go
    Hello, world
    ==================
    WARNING: DATA RACE
    Write at 0x00c000124088 by goroutine 7:
      main.main.func1()
          /home/kate/dev/go/racy/racy.go:10 +0x5c

    Previous read at 0x00c000124088 by main goroutine:
      main.main()
          /home/kate/dev/go/racy/racy.go:13 +0x175

    Goroutine 7 (running) created at:
      main.main()
          /home/kate/dev/go/racy/racy.go:9 +0x14e
    ==================
    Found 1 data race(s)
    exit status 66

This also works with for example the gin web framework. You can start it with the -race flag and then just run a benchmark / throughput test on the endpoints. For me it works best with apache benchmark / 10 clients at once / 2000 requests in total.

To read more about the race detection visit the go blog:  
[https://go.dev/blog/race-detector](https://go.dev/blog/race-detector)


### defer replaces finally

In other programming languages you have a try{}catch{}final{} setup.  
If you want to close a file or connection no matter what happens you place it in the finally part of the code.

In Go you can simply use the `defer` keyword. Defer executes the given function when the current function returns.

An example with reading a file line-by-line:

```go
package main

import (
    "fmt"
    "os"
    "bufio"
)

func main() {
    file, err := os.Open("text.txt")
    if err != nil {
        panic(err)
    }
    defer file.Close()

    scanner := bufio.NewScanner(file)
    for scanner.Scan() {
        fmt.Println(scanner.Text())
    }

    if err := scanner.Err(); err != nil {
        fmt.Println(err)
    }
}
```
In the main function we first try to open a file. If it fails we print an error and exit. If it succeeds, we "defer" the closing of the file.  
This means that after the main function is finished, the file will be closed.

This makes developing with files and connections really easy, because you don't have to worry about closing anything anymore.

To learn more about defer visit the "A Tour of Go" playground:  
[https://go.dev/tour/flowcontrol/12](https://go.dev/tour/flowcontrol/12)


### Amazing Standard Library

For example: In Go you don't need any special logging library.  
The built in "log" library is working really well and can be enhanced with special features if necessary. This makes your code less dependant on other people's code and thus can also help you against exploits found there (e.g. log4j exploit in dec 2021).

To browse the standard Go packages visit [https://pkg.go.dev/std](https://pkg.go.dev/std)


### A grown and battle-tested language

If you google "Golang" you will often find the statement that it's "Too young to be used in production" or "Still an underdog in the enterprise area".

This is wrong.

These posts are very old and thus obsolete. It may have been so 5 years ago, but now, in 2022, Go is a very popular language.

If you visit the official Go website ([https://go.dev/](https://go.dev/)) You can see the companies that use Go, including:

 - Microsoft
 - Meta
 - Google
 - Paypal
 - Twitter
 - Netflix
 - Salesforce
 - Cloudflare
 - Dropbox

To add to it: Docker, Kubernetes and kubectl have also been written in Go. It is not a young and barely-known language anymore.


### Easy Concurrency and Synced methods

Go uses so called "goroutines" for multithreading. It is a "lightweight thread" and can work in parallel to the main thread.

To run a function in a goroutine simply call

    go myFunction()

in your code. This will run myFunction() parallel to the execution of the main thread.

You can use this for e.g. "Fire and forget" API calls or for background backup jobs. You can also use this to group a bunch of API calls together and execute them simultaneously.

```go
package main

import (
    "sync"
)

type httpPkg struct{}

func (httpPkg) Get(url string) {}

var http httpPkg

func main() {
    var wg sync.WaitGroup
    var urls = []string{
        "http://www.golang.org/",
        "http://www.google.com/",
        "http://www.example.com/",
    }
    for _, url := range urls {
        // Increment the WaitGroup counter.
        wg.Add(1)
        // Launch a goroutine to fetch the URL.
        go func(url string) {
            // Decrement the counter when the goroutine completes.
            defer wg.Done()
            // Fetch the URL.
            http.Get(url)
        }(url)
    }
    // Wait for all HTTP fetches to complete.
    wg.Wait()
}
```


### Inbuilt HTTP server

Compared to Java most modern languages have the web server directly built into the language. No need for a Tomcat or Wildfly server to host your application on the web.

Go has its own HTTP library which automatically creates a goroutine (lightweight thread for parallel processing) when a request comes in, enabling it to automatically use multiple cores on a machine without any extra configuration.

A very popular framework for web applications is gin (https://github.com/gin-gonic/gin/blob/master/README.md). It enables quick and production ready code that can serve a thousand requests per second easily.



### Complexity and Speed of Implementation

A colleague of mine wanted to implement a mock web server that simply verifies the structure of a json you POST to it.  
With Go I have finished this task in 10 minutes. The outcome is a single .go file written in vim which can be run anywhere without the need of an IDE. (In total there are 3 files, but none of them are needed except the main.go file to run somewhere else)

With java (according to the Spring Boot REST API example I did above in the comparison of RAM usage) I would first need to decide which IDE I use. Then decide between maven or gradle and if I use spring boot or Tomcat standalone. In the end (of the example rest api) I had 25 files in the project folder.

What I mean with this comparison: A Java project needs to be setup first while a Go project can immediately start with "vim main.go" and work on a solution that is immediately ready to run.


