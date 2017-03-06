# Condet

# Congestion Detection in Real Time
- A program written in **Elixir** for detection Congestion in Reat-time on the Internet

The following are components form the basis and are required for the program to work correctly -
- [Elixir/Erlang](http://elixir-lang.org/install.html)
- [PostgreSQL](https://www.postgresql.org/download/)
- [Scamper](https://www.caida.org/tools/measurement/scamper/)

The program can be built and run from the command line on any environment. It can accept three (optional) arguments -
- file (a file containing a list of ips)
- ip (a single IP)
- type (TCP, UDP or ICMP)

To build and run the program:
```
$ mix escript.build
$ ./condet --file=file.txt --ip=8.8.8.8 --type=ICMP
```

The following dependencies (Hex packages) are required for development -
- [Ecto](https://hex.pm/packages/ecto)
- [Postgrex](https://hex.pm/packages/postgrex)
- [ASN](https://hex.pm/packages/asn)
- [GeoIP](https://hex.pm/packages/geoip)
- [Geocalc](https://hex.pm/packages/geocalc)

Dependencies and versions can be added/edited in the _mix.exs_ file.
Further configurations to our database can be made in the _config/config.exs_ file.

The models used in this application and their schema are found under the _lib/condet/models_ directory. A more detailed version can be found [here](https://creately.com/diagram/isuenvth1/iF3mN3dUJbSc5mUGlHzMrrWhqc%3D).

A small description of the program structure can be found below:

## Condet Module

We leverage Elixir and Erlang/OTP to make our measurements in several parallel processes. For now we use 5 processes with 5 more available if resources permit it. This value can be changed in the main method.

Our geolocation and IP is also statically set in this module and can be changed when required.

After parsing command line arguments, we start our measurements using the _Task.async_ method, spawning different asynchronous processes for different types of measurements. These tasks each make a call to the **worker** module.

## Worker Module

The initial call from the condet module is handeled by the def_call method in the worker module, which in turn uses scamper to do a traceroute and parses the results. The result is then passed on to the detect_congestion method which does all the heavylifting of comparing, retrieving and writing to our database.

