# Condet

# Congestion Detection in Real Time
- A program written in **Elixir** for detection Congestion in Reat-time on the Internet

The following are components form the basis and are required for the program to work correctly -
- [Elixir/Erlang](http://elixir-lang.org/install.html)
- [PostgreSQL](https://www.postgresql.org/download/)
- [Scamper](https://www.caida.org/tools/measurement/scamper/)

The following dependencies (Hex packages) are required for development -
- Ecto
- Postgrex
- ASN
- GeoIP
- Geocalc

The program can be built and run from the command line on any environment. It can accept three (optional) arguments -
- file (a file containing a list of ips
- ip (a single IP)
- type (TCP, UDP or ICMP)

To build and run the program:
```
$ mix escript.build
$ ./condet --file=file.txt --ip=8.8.8.8 --type=ICMP
```

