# sprite
Crypto-NI is a new instruction set in the field of encryption and decryption for Intel Icelake/Whitely-SP processors and it adds new instructions such as Vectorized AES and Integer Fused Multiply Add on. Crypto-NI adds a QAT engine with a bi-directional request/response ring into the processor, which provide batch submission of multiple SSL requests and parallel asynchronous processing mechanism based on the new instruction set, greatly improving the performance.

Sprite is a simple script that acts as a network-level change in the Crypto-NI optimization step, it attempts to bind each queue of a multi-queue NIC to the same numbered core, example :
trx|rx0 --> cpu0, t1|rx1 --> cpu1


## Usage
```
$ sh sprite.sh <NIC name here>
```
