# Crypto Engineering ARM project

Crypto Engineering ARM RECTANGLE project [https://rucryptoengineering.wordpress.com/assignment/](https://rucryptoengineering.wordpress.com/assignment/). 

## Speed optimized version

The folder `speed` contains the RECTANGLE 80 implementation optimized for speed.

The file `roundkeys-0.s` contains the pregenerated key. It is just the result
of the `genroundkey` (`genroundkey > roundkeys-0.s`) tool you can find in 
the tools folder.

## Size optimized version

The folder `size` contains the RECTANGLE 80 implementation optimized for size.

The file `roundkeys-0.s` contains the pregenerated key. It is just the result
of the `genroundkey` (`genroundkey -size > roundkeys-0.s`) tool you can find in 
the tools folder.

## Tools

The tools folder contains the `genroudkey` tool and the C implementation of
both RECTANGLE 80 and 128.