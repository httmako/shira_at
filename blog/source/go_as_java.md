---
title: go as java | shira.at
toc: true
header-includes:
    <link rel="stylesheet" href="/style.css">
---


## Intro

<u>**__Warning: I am biased and enjoy Golang more, but the article should be objective nonetheless.__**</u>  
This is supposed to be a powerpoint-like presentation on why I personally think that Go can be the future of Java in cloud environment.  


## Environment setup differences

With Java you have a lot to setup.  
You have to decide which IDE to use, maybe Eclipse, IntelliJ or NetBeans?  
Then decide on a Java version: Stuck with Java8?  
Then the package manager: Ant, Maven or Gradle?  
Wildfly or Tomcat for websites? Or Spring Boot? JSP or Angular?  

Comparing that to Golang it's very complicated.  
With Go you do not have to worry about the version upgrade, as each version is backwards compatible.  
You can program with VisualStudioCode or even vim.  
The package manager is built into the go commandline with `go get`. Golang features, by default, linting, race condition detecting and version management.  
The webserver is built into the default golang packages and doesn't need anything like a tomcat to run.


This environment setup process can be explained really easily with an example.  
**Try to setup a simple webserver that responds to /ping with a "pong" response.**

With Java you need, as mentioned before, the IDE+PackageManager+Tomcat.  
With Golang you only need a text file in combination with 3 commands: `go mod init example.com/app && go get . && go run .`


## Performance


### Web Framework Benchmark

An example of the performance of common web frameworks we learned at University:

[https://web-frameworks-benchmark.netlify.app/compare?f=laravel,rails,flask,express,spring,gin](https://web-frameworks-benchmark.netlify.app/compare?f=laravel,rails,flask,express,spring,gin)

In these examples "spring boot" is used for Java and "gin-gonic" for Golang.  
These 2 are the most common frameworks I found when working with both languages.  
As you can see, gin has better performance than the other frameworks.  



### Julia's Benchmark

The programming language Julia made a benchmark of specific algorithms using many different languages. It uses outdated Golang1.9 and Java8.

[https://julialang.org/benchmarks/](https://julialang.org/benchmarks/)

In the above link you can see that Golang has, on average, better performance than Java.


### RAM & CPU Usage

Java uses a lot of RAM.  
To compare both languages we create 2 webservers with the most popular web frameworks: Golang's "gin-gonic" and Java's "spring-boot".

For Spring I used their "REST Api" example: [https://spring.io/guides/tutorials/rest/](https://spring.io/guides/tutorials/rest/)  
For Go I used the gin example from here with an added struct for greeting: [https://github.com/gin-gonic/gin/blob/master/README.md#quick-start](https://github.com/gin-gonic/gin/blob/master/README.md#quick-start)

Both applications have the same speed (1100 req/s) and the same average response time (44ms) when load-tested with apache benchmark (50 concurrent clients with 10000 requests).  

The main difference that can be observed: **Java used 262.1MB of RAM and Go only used 8.7MB of RAM!**  
(Golang's RAM usage was 2.9MB before the load test, while Java's RAM usage was always at 262.1MB)


Another benchmark, from medium:

[https://medium.com/@dexterdarwich/comparison-between-java-go-and-rust-fdb21bd5fb7c](https://medium.com/@dexterdarwich/comparison-between-java-go-and-rust-fdb21bd5fb7c)

Ofcourse, never trust a random benchmark you found on the internet, but I tested these myself and got similar results.

Some key points from the article:

 - While running idle, Java used a massive 162MB of RAM, while Go only used 0.86MB of RAM.  
 - Java has, for 2 of the 3 endpoints, higher CPU usage than Go. In the last one it has a 1% lower usage than Go.
 - The /hello endpoint, which simply replies with "Hello World", made Java use 1.5GB of RAM, while Go only used 18.38MB of RAM.
 - Java was, with the /fibonacci endpoint, able to answer more requests

Java uses 22.5 times more RAM then Go for around 20% better performance.  
You could deploy a second Go application, which is quite easy in containerized cloud environments, and get way better performance with less RAM usage than the Java application.



## Cloud

### Docker Container

A comparison between moving Java and moving Go applications into a container.

With Java you have to add the classpath and all the other configuration to the start command.  
You also need a base image like `openjdk:8u332-jre-slim-bullseye` which bloats up the container size.

Example Dockerfile for Java:

    FROM openjdk:8-jre-slim-bullseye
    WORKDIR /srv/myapp
    COPY myapp-1.0.0.jar myapp-1.0.0.jar
    COPY jars jars/
    COPY lib lib/
    COPY run.sh run.sh
    ENTRYPOINT ["/srv/myapp/run.sh"]


With Golang you can simply move the statically-compiled binary file into an empty container and run it, no special FROM image needed. This makes the container 90% more lightweight (in filesize).

Example Dockerfile for Go:

    FROM scratch
    COPY myapp /myapp
    CMD ["/myapp"]


To show the difference in size I compared my minimalistic NodeJS REST API container to my Go REST API container (the first 2 in the list):

    REPOSITORY    TAG            IMAGE ID        CREATED         SIZE
    gotest        latest         8a2491c7a736    2 days ago      8.77MB
    nodetest      latest         8780b334ac5d    2 days ago      173MB
    alpine        3.13           20e452a0a81a    3 weeks ago     5.61MB
    mariadb       latest         6e0162b44a5f    5 weeks ago     414MB
    node          17.6-alpine    eb56d56623e5    2 months ago    168MB
    nginx         latest         c316d5a335a5    3 months ago    142MB
    hello-world   latest         feb5d9fea6a5    7 months ago    13.3kB

My "gotest" container uses only 3MB more than the base alpine:3.13 image and is over 150MB smaller than the nodetest image.


## Benefits of using Golang


### Stricter compiling

Golang does not let you compile if you define a variable and never use it. Example:

```go
result, err := myFunction(input)
if err != nil {
    return false
}
return true
```

The above example defines "result" but never uses it, thus it would not compile or run and print out an error.


### Race Condition Detector

You can run your code with a "race condition detector", which is build into the main go toolchain.

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
The built in "log" (or slog) library is working really well and can be enhanced with special features if necessary. This makes your code less dependant on other people's code and thus can also help you against exploits found there (e.g. log4j exploit in dec 2021).

To browse the standard Go packages visit [https://pkg.go.dev/std](https://pkg.go.dev/std)


### A grown and battle-tested language

If you search "Golang" you will often find the statement that it's "Too young to be used in production" or "Still an underdog in the enterprise area".

These posts can be quite old. If you visit the official Go website ([https://go.dev/](https://go.dev/)) You can see the companies that use Go, including:

 - Microsoft
 - Meta
 - Google
 - Paypal
 - Twitter
 - Netflix
 - Salesforce
 - Cloudflare
 - Dropbox

Also, some of the most popular container tools are written in Golang, including:

 - Docker
 - cri-o
 - containerd
 - kubectl
 - Rook (storage k8s)
 - podman


### Easy Concurrency and Synced methods

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

