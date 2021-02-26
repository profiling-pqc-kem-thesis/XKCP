# What is the XKCP?

This version of **eXtended Keccak Code Package** is comprised of only the relevant code for our project, and only uses GNU make to build. See https://github.com/XKCP/XKCP for the original version.

* The SHAKE extendable-output functions and SHA-3 hash functions from [FIPS 202][fips202_standard]

The code in this repository can be built as a library called libkeccak.

# How can I build the XKCP?

To build on Linux or macOS, the following tools are needed:

* *GCC* or *clang*
* *GNU make*

## Build library
```
make plain-64bits/ua
```

or

```
make AVX2
```
etc. see Makefile

## Build UnitTests
```
make test
```
Note: This will build unit tests for all compiled versions of the liberty.


# Acknowledgments to the original authors

We wish to thank all the contributors, and in particular:

- Andre C. de Moraes for ARMv8-A assembly code
- Andy Polyakov and Ronny Van Keer for the AVX2 and AVX-512 assembly implementations of Keccak-_p_[1600]
- Anna Guinet for the hummingbird logo design
- Brian Gladman's `brg_endian.h`
- Bruno Pairault for testing and benchmarking on ARM platforms
- Conno Boel for the NEON implementations of Xoodoo
- D.J. Bernstein, Peter Schwabe and Gilles Van Assche for the tweetable FIPS 202 implementation `TweetableFIPS202.c`
- Hussama Ismail for setting up the continuous integration with Travis
- Kent Ross for various improvements in [XKCP/K12](https://github.com/XKCP/K12) imported here
- Larry Bassham, NIST for the original `genKAT.c` developed during the SHA-3 contest
- Stéphane Léon for helping support macOS
