---
title: golang notes | shira.at
toc: true
lang: en
description: How to develop better golang applications easily
header-includes:
    <link rel="stylesheet" href="/style.css">
---


# Golang development made easy

This is a collection of golang commands, improvements, information and other stuff.  
This page has all my knowledge that I wished I had in the beginning already.



# Tools


## Lint

[https://golangci-lint.run](https://golangci-lint.run)

`golangci-lint` is a very easy and simple tool for checking your go code.  
To install it run

```bash
curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin v1.58.1
```

To analyze your go project run

```bash
golangci-lint run
```


## Vulnerabilities

[https://go.dev/doc/tutorial/govulncheck](https://go.dev/doc/tutorial/govulncheck)

To check for known vulnerabilities in your code or packages you can use the `govulncheck` application.  
To install it run

```bash
go install golang.org/x/vuln/cmd/govulncheck@latest
```

To check your project run

```bash
govulncheck ./...
```

If it says "command not found" then verify that you have your home folder's go/bin folder in your path (`/home/user/go/bin`), if not you can use the following to add it:

```bash
export PATH=$PATH:/home/$(whoami)/go/bin
```


## Inbuilt tools

Go has, by default, many tools for testing and linting already inbuilt.

 - To execute your test cases in `_test.go` files use `go test .`
 - To lint your code you can use `go vet .`
 - To check for race conditions you can use -race like `go run -race .`


## Building

[https://pkg.go.dev/cmd/go#hdr-Compile_packages_and_dependencies](https://pkg.go.dev/cmd/go#hdr-Compile_packages_and_dependencies)  
[https://medium.com/@diogok/on-golang-static-binaries-cross-compiling-and-plugins-1aed33499671](https://medium.com/@diogok/on-golang-static-binaries-cross-compiling-and-plugins-1aed33499671)  
[https://stackoverflow.com/questions/61319677/flags-needed-to-create-static-binaries-in-golang](https://stackoverflow.com/questions/61319677/flags-needed-to-create-static-binaries-in-golang)  

To build a static executable I personally use the following command:

```bash
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags '-w -s' .
```

The "ldflags" are only for a smaller executable size, the main magic happens with the "CGO_ENABLED=0" at the beginning.  
To verify if an executable is static use the `ldd` command.

To create an executable for another platform you can provide different GOOS/GOARCH variables like the following 32/64bit for win/linux:

```bash
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags '-w -s' -o myapp-linux-amd64 .
CGO_ENABLED=0 GOOS=linux GOARCH=386 go build -ldflags '-w -s' -o myapp-linux-386 .
CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build -ldflags '-w -s' -o myapp-windows-amd64 .
CGO_ENABLED=0 GOOS=windows GOARCH=386 go build -ldflags '-w -s' -o myapp-windows-386 .
```


## Post-Build

[https://github.com/upx/upx/releases](https://github.com/upx/upx/releases)

To make the executable smaller after building you can use `upx`.  
To install it into your `~/.local/bin` folder you can use the following commands:

```bash
wget -qO- https://github.com/upx/upx/releases/download/v4.2.4/upx-4.2.4-amd64_linux.tar.xz | tar xJvO upx-4.2.4-amd64_linux/upx > ~/.local/bin/upx
chmod +x ~/.local/bin/upx
```

To minify your executable use the following command (after building it with go build):

```bash
upx --best myapp
```



# Favorite packages

After programming with go for years I have come to like a few specific packages or solutions to problems.  
This is a short list of packages I can personally recommend using.


## Web framework

If you only have to write a small REST API or a single-page status site then I recommend using the inbuilt `net/http` package with the inbuilt `html/template` package if needed.

For bigger projects I can recommend gin: [https://pkg.go.dev/github.com/gin-gonic/gin](https://pkg.go.dev/github.com/gin-gonic/gin)  
It is very easy to use, fast and has a lot functions inbuilt that you would need to code anyways (e.g. logging middleware).


## Databases

My current database system is a `mariadb`, which means I can only use and recommend [https://github.com/go-sql-driver/mysql](https://github.com/go-sql-driver/mysql).  
It has never failed me and works perfectly, auto reconnecting and pooling of connections has never created any problems for me.

For postgres I tested multiple frameworks but I enjoy the one from uptrace/bun the most: [github.com/uptrace/bun/driver/pgdriver](github.com/uptrace/bun/driver/pgdriver).  
It uses the database/sql interface, which means everything is the same as always and no code needs to be changed if you do a mysql->postgres switch.

If you need more functions than the default `database/sql` package can provide then I can recommend `sqlx`: [https://github.com/jmoiron/sqlx](https://github.com/jmoiron/sqlx).  
You can easily read sql into structs and write structs into sql.


## Configuration

For configuring applications I use 3 different packages:

 - the inbuilt `flag` package for commandline flags: [https://pkg.go.dev/flag](https://pkg.go.dev/flag)  
 - the inbuilt `os` package for environment variables: [https://pkg.go.dev/os#LookupEnv](https://pkg.go.dev/os#LookupEnv)
 - the k8s yaml package for yaml config files: [https://pkg.go.dev/sigs.k8s.io/yaml](https://pkg.go.dev/sigs.k8s.io/yaml)

I personally enjoy yaml config files the most because they support comments (which json doesn't) and are very easy to write and read (which xml doesn't).  

Passwords are provided by environment, the rest are either configured via flags or config file.


## Logging

At the beginning I was using the inbuilt `log` module, then uber's `zap` module and I now ended up using the inbuilt `log/slog` package.  
The `slog` package supports structured logging with different levels (info,error,etc.) and can log to different formats (logfmt,json,plain) and locations (stdout,file).

If your application doesn't log much then simple `fmt` prints could be enough aswell, e.g. for commandline applications I prefer to just print information in plaintext instead of using a logger.



# Jenkins pipeline

With the above tools combined, my current jenkins pipeline looks like this:

```
pipeline {
    agent any
    tools { go 'go1.22.2' }
    stages {
        stage('GitPull') {
            steps {
                git credentialsId: '11111111-1111-4111-1111-111111111111', url: 'http://10.0.0.2/git/me/testproject.git'
            }
        }
        stage('Test') {
            steps {
                sh 'go version'
                sh 'go test'
            }
        }
        stage('Lint') {
            steps {
                sh 'curl -sfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | bash -s -- -b . v1.58.1'
                sh './golangci-lint run'
                sh 'go vet ./...'
            }
        }
        stage('VulnCheck') {
            steps {
                sh 'GOBIN=$GOROOT/bin go install golang.org/x/vuln/cmd/govulncheck@latest'
                sh 'govulncheck ./...'
            }
        }
        stage('Build') {
            steps {
                sh 'go build .'
            }
        }
    }
}
```